#!/usr/bin/env python3

import re
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
CATALOG_SOURCE = "SwiftMessengerLab/Core/LearningCatalog.swift"
EXPERIMENT_DOCS = "docs/experiment-cards.md"
CARD_FIELDS = (
    "学习目标",
    "机制",
    "真实源码锚点",
    "App 操作",
    "Xcode / LLDB 操作",
    "预期真实证据",
    "Reset / 复验",
    "误区 / 边界",
    "思考题",
)


def require(path: str, token: str) -> None:
    content = (ROOT / path).read_text()
    if token not in content:
        raise SystemExit(f"{path}: missing {token!r}")


def reject(path: str, token: str) -> None:
    content = (ROOT / path).read_text()
    if token in content:
        raise SystemExit(f"{path}: compact App must not contain {token!r}")


def catalog_experiments() -> dict[str, str]:
    source = (ROOT / CATALOG_SOURCE).read_text()
    type_names = re.findall(r'\bcard\(\s*"([^"]+)"\s*,', source)
    concepts = re.findall(
        r'\bconcept\(\s*"([^"]+)"\s*,\s*"([^"]+)"',
        source,
    )

    if len(type_names) != 52 or len(set(type_names)) != 52:
        raise SystemExit(
            f"{CATALOG_SOURCE}: expected 52 unique type cards, got {len(type_names)}"
        )
    if len(concepts) != 18 or len({item[0] for item in concepts}) != 18:
        raise SystemExit(
            f"{CATALOG_SOURCE}: expected 18 unique concepts, got {len(concepts)}"
        )

    experiments = {f"type.{name}": name for name in type_names}
    experiments.update({f"concept.{identifier}": name for identifier, name in concepts})
    if len(experiments) != 70:
        raise SystemExit(f"{CATALOG_SOURCE}: expected 70 unique experiment IDs")
    return experiments


def markdown_cards() -> dict[str, tuple[str, str]]:
    content = (ROOT / EXPERIMENT_DOCS).read_text()
    headings = list(
        re.finditer(
            r"^## ((?:type|concept)\.[^ ·\n]+) · (.+)$",
            content,
            re.MULTILINE,
        )
    )
    cards: dict[str, tuple[str, str]] = {}

    for index, match in enumerate(headings):
        experiment_id = match.group(1)
        name = match.group(2).strip()
        end = headings[index + 1].start() if index + 1 < len(headings) else len(content)
        body = content[match.end():end]
        if experiment_id in cards:
            raise SystemExit(f"{EXPERIMENT_DOCS}: duplicate card {experiment_id}")
        cards[experiment_id] = (name, body)

    return cards


def audit_experiment_cards() -> None:
    expected = catalog_experiments()
    cards = markdown_cards()
    if set(cards) != set(expected):
        missing = sorted(set(expected) - set(cards))
        extra = sorted(set(cards) - set(expected))
        raise SystemExit(
            f"{EXPERIMENT_DOCS}: catalog mismatch; missing={missing}, extra={extra}"
        )

    classification_counts = {"direct workload": 0, "related observation": 0}

    for experiment_id, expected_name in expected.items():
        name, body = cards[experiment_id]
        if name != expected_name:
            raise SystemExit(
                f"{EXPERIMENT_DOCS}: {experiment_id} title is {name!r}, "
                f"expected {expected_name!r}"
            )
        if f"<!-- experiment-card: {experiment_id} -->" not in (
            ROOT / EXPERIMENT_DOCS
        ).read_text():
            raise SystemExit(
                f"{EXPERIMENT_DOCS}: {experiment_id} is missing its stable marker"
            )
        if experiment_id not in body or expected_name not in body:
            raise SystemExit(
                f"{EXPERIMENT_DOCS}: {experiment_id} body lacks its ID or name"
            )
        if len(re.sub(r"\s+", "", body)) < 700:
            raise SystemExit(
                f"{EXPERIMENT_DOCS}: {experiment_id} is too shallow for an operation card"
            )

        for field in CARD_FIELDS:
            if body.count(f"### {field}") != 1:
                raise SystemExit(
                    f"{EXPERIMENT_DOCS}: {experiment_id} must contain one {field!r}"
                )

        classifications = re.findall(
            r"^- 证据分类：`(direct workload|related observation)`$",
            body,
            re.MULTILINE,
        )
        if len(classifications) != 1:
            raise SystemExit(
                f"{EXPERIMENT_DOCS}: {experiment_id} needs one evidence classification"
            )
        classification = classifications[0]
        classification_counts[classification] += 1
        token = f"target-evidence:{experiment_id}"
        if classification == "direct workload":
            if token not in body:
                raise SystemExit(
                    f"{EXPERIMENT_DOCS}: {experiment_id} direct workload lacks {token!r}"
                )
        else:
            if token in body:
                raise SystemExit(
                    f"{EXPERIMENT_DOCS}: {experiment_id} related observation exposes a target token"
                )
            if "关联观察不写入“已操作”证据" not in body:
                raise SystemExit(
                    f"{EXPERIMENT_DOCS}: {experiment_id} must reject operated evidence"
                )

        anchor = re.search(
            r"- File: \[([^\]]+)\]\(\.\./([^)]+)\)\n"
            r"- Symbol: `([^`]+)`",
            body,
        )
        if not anchor:
            raise SystemExit(
                f"{EXPERIMENT_DOCS}: {experiment_id} has no parseable source anchor"
            )
        label_path, linked_path, symbol = anchor.groups()
        if label_path != linked_path:
            raise SystemExit(
                f"{EXPERIMENT_DOCS}: {experiment_id} source label/link drifted"
            )
        source_path = ROOT / linked_path
        if not source_path.is_file():
            raise SystemExit(
                f"{EXPERIMENT_DOCS}: {experiment_id} source does not exist: {linked_path}"
            )
        symbol_name = symbol.split("(", 1)[0]
        if f"{symbol_name}(" not in source_path.read_text():
            raise SystemExit(
                f"{EXPERIMENT_DOCS}: {experiment_id} source lacks {symbol!r}"
            )

        lldb_blocks = re.findall(r"```lldb\n(.*?)\n```", body, re.DOTALL)
        if len(lldb_blocks) != 1:
            raise SystemExit(
                f"{EXPERIMENT_DOCS}: {experiment_id} needs exactly one LLDB block"
            )
        commands = [
            line for line in lldb_blocks[0].splitlines()
            if line.strip() and not line.lstrip().startswith("#")
        ]
        if not commands or experiment_id not in lldb_blocks[0]:
            raise SystemExit(
                f"{EXPERIMENT_DOCS}: {experiment_id} LLDB block is not card-specific"
            )
        if "Reset Experiment" not in body:
            raise SystemExit(
                f"{EXPERIMENT_DOCS}: {experiment_id} has no Reset replay instruction"
            )
        thought_section = body.split("### 思考题", 1)[1]
        if "？" not in thought_section:
            raise SystemExit(
                f"{EXPERIMENT_DOCS}: {experiment_id} needs an explicit question"
            )

    if classification_counts != {"direct workload": 51, "related observation": 19}:
        raise SystemExit(
            f"{EXPERIMENT_DOCS}: unexpected evidence audit counts {classification_counts}"
        )

    content = (ROOT / EXPERIMENT_DOCS).read_text()
    if "# 70 个真实操作卡" in content:
        raise SystemExit(f"{EXPERIMENT_DOCS}: must not claim every entry is a real workload")
    for marker in ("## 证据分类审计", "Related type（15）", "Related concept（4）"):
        if marker not in content:
            raise SystemExit(f"{EXPERIMENT_DOCS}: missing evidence audit marker {marker!r}")
    for experiment_id, required in {
        "type.Dictionary": "独立 `[String: Int]` workload",
        "type.MessageRepository": "enqueueOutgoing",
        "type.MessageTransport": "`any MessageTransport` existential",
    }.items():
        if required not in cards[experiment_id][1]:
            raise SystemExit(
                f"{EXPERIMENT_DOCS}: {experiment_id} lacks target-specific evidence {required!r}"
            )

    exporter = subprocess.run(
        ["swift", "run", "experiment-card-exporter", "--check"],
        cwd=ROOT,
        text=True,
        capture_output=True,
    )
    if exporter.returncode != 0:
        detail = (exporter.stderr or exporter.stdout).strip()
        raise SystemExit(
            f"{EXPERIMENT_DOCS}: generated cards drifted from ExperimentCatalog: {detail}"
        )


catalog_controller = (
    "SwiftMessengerLab/Learning/LearningCatalogViewController.swift"
)
console_ui = "SwiftMessengerLab/Learning/ExperimentConsoleUI.swift"
project = "SwiftMessengerLab.xcodeproj/project.pbxproj"
scheme = (
    "SwiftMessengerLab.xcodeproj/xcshareddata/xcschemes/"
    "SwiftMessengerLab.xcscheme"
)
makefile = "Makefile"

for token in (
    "subtitleCell",
    "secondaryText",
    "titleForHeaderInSection",
    "titleForFooterInSection",
):
    reject(catalog_controller, token)

for token in (
    "descriptor.expectedResult",
    "configuration.subtitle",
    "console-result",
):
    reject(console_ui, token)

for token in (
    'DEBUG_INFORMATION_FORMAT = dwarf;',
    "ENABLE_TESTABILITY = YES;",
    'SWIFT_OPTIMIZATION_LEVEL = "-Onone";',
    'DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";',
    "SWIFT_COMPILATION_MODE = wholemodule;",
    'SWIFT_OPTIMIZATION_LEVEL = "-O";',
    "VALIDATE_PRODUCT = YES;",
):
    require(project, token)

for token in (
    'selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"',
    'disableMainThreadChecker = "NO"',
    'enableThreadPerformanceChecker = "YES"',
    'queueDebuggingEnabled = "YES"',
    'viewDebuggingEnabled = "YES"',
):
    require(scheme, token)

for token in (
    "build-release:",
    "audit-project:",
    "release-check: test test-ui verify-type-cards verify-experiment-cards compiler-test "
    "audit-project build-release verify-showcase public-scan",
):
    require(makefile, token)

require(CATALOG_SOURCE, 'docsPath: "docs/experiment-cards.md"')
require("Package.swift", 'name: "ExperimentCardExporter"')
require(makefile, "verify-experiment-cards:")
audit_experiment_cards()

print(
    "project audit passed: title-only learning catalog, compact experiment "
    "console, 70 classified cards (51 direct / 19 related), debugger-ready scheme and "
    "explicit Debug/Release settings"
)
