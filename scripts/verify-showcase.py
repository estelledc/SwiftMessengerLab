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


def verify_layout_composition(html: str) -> None:
    for raw_classes in re.findall(r'class="([^"]+)"', html):
        classes = set(raw_classes.split())
        if {"jx-container", "jx-proof-rail"} <= classes:
            fail("jx-proof-rail must be nested inside jx-container, not composed with it")
    if not re.search(r'<div class="jx-container">\s*<ul class="jx-proof-rail"', html):
        fail("proof rail is missing its shared layout container")


def verify_screenshot_contract(html: str, css: str) -> None:
    rule = re.search(r"\.lab-screen img\s*\{([^}]*)\}", css, re.DOTALL)
    if rule is None or not re.search(r"\bheight\s*:\s*auto\s*;", rule.group(1)):
        fail("responsive screenshots must declare height: auto")
    for name in ("screenshot-messenger.png", "screenshot-learn.png", "screenshot-uiview.png"):
        tag = re.search(rf'<img\b[^>]*\bsrc="assets/{re.escape(name)}"[^>]*>', html)
        if tag is None:
            fail(f"missing screenshot tag: {name}")
        attributes = dict(re.findall(r'(\w+)="([^"]*)"', tag.group(0)))
        if attributes.get("width") != "1206" or attributes.get("height") != "2622":
            fail(f"screenshot intrinsic dimensions are missing or incorrect: {name}")


def main() -> None:
    required = [
        HTML,
        DOCS / "404.html",
        DOCS / "assets" / "style.css",
        DOCS / "assets" / "app.js",
        DOCS / "assets" / "jx" / "VERSION",
        DOCS / "assets" / "jx" / "tokens.css",
        DOCS / "assets" / "jx" / "base.css",
        DOCS / "assets" / "jx" / "components.css",
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
    not_found = (DOCS / "404.html").read_text(encoding="utf-8")
    css = (DOCS / "assets" / "style.css").read_text(encoding="utf-8")
    javascript = (DOCS / "assets" / "app.js").read_text(encoding="utf-8")
    tokens = (DOCS / "assets" / "jx" / "tokens.css").read_text(encoding="utf-8")
    components = (DOCS / "assets" / "jx" / "components.css").read_text(encoding="utf-8")
    workflow = WORKFLOW.read_text(encoding="utf-8")
    catalog = (ROOT / "SwiftMessengerLab" / "Core" / "LearningCatalog.swift").read_text(encoding="utf-8")

    for marker in ('data-lessons="20"', 'data-types="52"', 'data-samples="5"'):
        if marker not in html:
            fail(f"missing verified metric marker: {marker}")
    design_markers = [
        '<meta name="theme-color" content="#f6f6f3">',
        'assets/jx/tokens.css',
        'assets/jx/base.css',
        'assets/jx/components.css',
        'This lab answers',
        'jx-proof-rail',
        'jx-footer',
        'https://estelledc.github.io/">← Jason Xun',
    ]
    for marker in design_markers:
        if marker not in html:
            fail(f"missing main-site design marker: {marker}")
    if html.count("<h1>") != 1:
        fail("showcase must contain exactly one h1")
    if (DOCS / "assets" / "jx" / "VERSION").read_text(encoding="utf-8").strip() != "2.2.0":
        fail("Jason DS vendor version must be 2.2.0")
    if "Jason DS · Tokens v2.2.0" not in tokens or ".jx-site-header" not in components:
        fail("Jason DS vendor bundle is incomplete")
    for marker in ("var(--jx-ink)", "var(--jx-surface)", "var(--jx-font-mono)", "@media (max-width: 760px)"):
        if marker not in css:
            fail(f"project stylesheet is missing Jason DS mapping: {marker}")
    if "transition: all" in css or "transition: all" in components:
        fail("transition: all is not allowed")
    if len(re.findall(r'^\s*card\("', catalog, re.MULTILINE)) != 52:
        fail("TypeCatalog does not contain exactly 52 card declarations")
    if len(re.findall(r'^\s*lesson\(\d+', catalog, re.MULTILINE)) != 20:
        fail("LearningCatalog does not contain exactly 20 lesson declarations")
    if len(list((ROOT / "CompilerLab" / "Samples").glob("*.swift"))) != 5:
        fail("CompilerLab does not contain exactly five Swift samples")
    if len(re.findall(r'^\s*"[^"]+",?$', javascript, re.MULTILINE)) != 52:
        fail("web type explorer does not list exactly 52 types")

    verify_local_links(html)
    verify_local_links(not_found)
    verify_action_pins(workflow)
    verify_layout_composition(html)
    verify_screenshot_contract(html, css)

    if png_size(DOCS / "assets" / "og-image.png") != (1200, 630):
        fail("Open Graph image must be 1200x630")
    for name in ("screenshot-messenger.png", "screenshot-learn.png", "screenshot-uiview.png"):
        width, height = png_size(DOCS / "assets" / name)
        if height <= width or width < 300:
            fail(f"unexpected simulator screenshot dimensions: {name} {width}x{height}")

    forbidden = [
        "TO" + "DO",
        "lorem " + "ipsum",
        "replace" + "-me",
        "/" + "Us" + "ers/",
        "byte" + "dance",
        "la" + "rk",
        "#061534",
        "#27c9ff",
        "#ff8b73",
    ]
    visible_sources = "\n".join(
        path.read_text(encoding="utf-8", errors="ignore")
        for path in [HTML, DOCS / "404.html", DOCS / "assets" / "style.css", DOCS / "assets" / "app.js"]
    ).lower()
    for term in forbidden:
        if term.lower() in visible_sources:
            fail(f"forbidden public marker found: {term}")

    print("Showcase audit: Jason DS 2.2.0, links, metrics, images, boundaries, and action pins passed")


if __name__ == "__main__":
    main()
