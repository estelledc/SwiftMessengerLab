#!/usr/bin/env python3
"""Audit the static showcase without network or third-party dependencies."""

from __future__ import annotations

import re
import struct
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT / "docs"
HTML = DOCS / "index.html"
WORKFLOW = ROOT / ".github" / "workflows" / "pages.yml"


def fail(message: str) -> None:
    print(f"showcase audit failed: {message}", file=sys.stderr)
    raise SystemExit(1)


def png_size(path: Path) -> tuple[int, int]:
    data = path.read_bytes()[:24]
    if len(data) != 24 or data[:8] != b"\x89PNG\r\n\x1a\n":
        fail(f"not a PNG: {path.relative_to(ROOT)}")
    return struct.unpack(">II", data[16:24])


def verify_local_links(html: str) -> None:
    for target in re.findall(r'(?:href|src)="([^"]+)"', html):
        if target.startswith(("https://", "#", "mailto:")):
            continue
        clean = target.split("#", 1)[0]
        if clean and not (DOCS / clean).is_file():
            fail(f"missing local page asset: {clean}")


def verify_action_pins(workflow: str) -> None:
    uses = re.findall(r"^\s*-?\s*uses:\s*([^\s]+)", workflow, re.MULTILINE)
    if len(uses) < 4:
        fail("expected at least four action references")
    for reference in uses:
        if reference.startswith("./"):
            continue
        if not re.search(r"@[0-9a-f]{40}$", reference):
            fail(f"action is not pinned to a full commit: {reference}")


def main() -> None:
    required = [
        HTML,
        DOCS / "assets" / "style.css",
        DOCS / "assets" / "app.js",
        DOCS / "assets" / "app-icon.png",
        DOCS / "assets" / "favicon.png",
        DOCS / "assets" / "og-image.png",
        DOCS / "assets" / "screenshot-messenger.png",
        DOCS / "assets" / "screenshot-learn.png",
        DOCS / "assets" / "screenshot-uiview.png",
        WORKFLOW,
    ]
    for path in required:
        if not path.is_file() or path.stat().st_size == 0:
            fail(f"missing or empty: {path.relative_to(ROOT)}")

    html = HTML.read_text(encoding="utf-8")
    javascript = (DOCS / "assets" / "app.js").read_text(encoding="utf-8")
    workflow = WORKFLOW.read_text(encoding="utf-8")
    catalog = (ROOT / "SwiftMessengerLab" / "Core" / "LearningCatalog.swift").read_text(encoding="utf-8")

    for marker in ('data-lessons="20"', 'data-types="52"', 'data-samples="5"'):
        if marker not in html:
            fail(f"missing verified metric marker: {marker}")
    if len(re.findall(r'^\s*card\("', catalog, re.MULTILINE)) != 52:
        fail("TypeCatalog does not contain exactly 52 card declarations")
    if len(re.findall(r'^\s*lesson\(\d+', catalog, re.MULTILINE)) != 20:
        fail("LearningCatalog does not contain exactly 20 lesson declarations")
    if len(list((ROOT / "CompilerLab" / "Samples").glob("*.swift"))) != 5:
        fail("CompilerLab does not contain exactly five Swift samples")
    if len(re.findall(r'^\s*"[^"]+",?$', javascript, re.MULTILINE)) != 52:
        fail("web type explorer does not list exactly 52 types")

    verify_local_links(html)
    verify_action_pins(workflow)

    if png_size(DOCS / "assets" / "og-image.png") != (1200, 630):
        fail("Open Graph image must be 1200x630")
    for name in ("screenshot-messenger.png", "screenshot-learn.png", "screenshot-uiview.png"):
        width, height = png_size(DOCS / "assets" / name)
        if height <= width or width < 300:
            fail(f"unexpected simulator screenshot dimensions: {name} {width}x{height}")

    forbidden = ["TO" + "DO", "lorem " + "ipsum", "replace" + "-me", "/" + "Us" + "ers/", "byte" + "dance", "la" + "rk"]
    visible_sources = "\n".join(
        path.read_text(encoding="utf-8", errors="ignore")
        for path in [HTML, DOCS / "assets" / "style.css", DOCS / "assets" / "app.js"]
    ).lower()
    for term in forbidden:
        if term.lower() in visible_sources:
            fail(f"forbidden public marker found: {term}")

    print("Showcase audit: links, metrics, images, boundaries, and action pins passed")


if __name__ == "__main__":
    main()
