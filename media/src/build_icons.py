# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Ramingo (SOsintOps)
"""Build the Speculator launcher icons (SVG) in media/icons/.

Usage: python3 media/src/build_icons.py
Every icon is a rounded square in the colour of its investigation type with a
white line glyph, so the set stays consistent and needs no third-party art.
"""

from pathlib import Path

OUT = Path(__file__).resolve().parent.parent / "icons"
STROKE = 'stroke="#fff" stroke-width="8" stroke-linecap="round" stroke-linejoin="round" fill="none"'

PERSON = "#1d4ed8"
WEB = "#0f766e"
SOCIAL = "#be185d"
MEDIA = "#b91c1c"
TOOLS = "#4c1d95"
FILES = "#334155"


def line(d):
    return f'<path d="{d}" {STROKE}/>'


ICONS = {
    # name: (background, glyph)
    "user": (PERSON, f'<circle cx="64" cy="46" r="17" {STROKE}/>' + line("M30 102c0-20 15-32 34-32s34 12 34 32")),
    "domain": (WEB, f'<circle cx="64" cy="64" r="36" {STROKE}/><ellipse cx="64" cy="64" rx="15" ry="36" {STROKE}/>'
                    + line("M28 64h72M34 46h60M34 82h60")),
    "instagram": (SOCIAL, f'<rect x="28" y="28" width="72" height="72" rx="20" {STROKE}/>'
                          f'<circle cx="64" cy="64" r="16" {STROKE}/><circle cx="86" cy="42" r="5" fill="#fff"/>'),
    "reddit": (SOCIAL, line("M26 34h76v48H62l-20 16V82H26z") + line("M42 52h44M42 66h28")),
    "video": (MEDIA, f'<rect x="20" y="32" width="88" height="64" rx="12" {STROKE}/>' + line("M56 50l22 14-22 14z")),
    "archives": (FILES, f'<rect x="22" y="28" width="84" height="20" rx="4" {STROKE}/>'
                        + line("M30 48v50h68V48M54 66h20")),
    "image": (MEDIA, f'<rect x="20" y="26" width="88" height="76" rx="8" {STROKE}/><circle cx="48" cy="52" r="8" {STROKE}/>'
                     + line("M24 94l28-26 18 16 14-12 22 20")),
    "framework": (TOOLS, f'<rect x="20" y="28" width="88" height="72" rx="8" {STROKE}/>' + line("M38 52l14 12-14 12M60 80h28")),
    "update": (TOOLS, line("M96 56a34 34 0 0 0-62-14M32 72a34 34 0 0 0 62 14") + line("M34 26v16h16M94 102V86H78")),
    "evidence": (FILES, line("M24 42h30l9 10h41v50H24z")),
    "maigret": (PERSON, f'<circle cx="56" cy="56" r="28" {STROKE}/>' + line("M77 77l25 25")),
}


def main():
    OUT.mkdir(exist_ok=True)
    for name, (colour, glyph) in ICONS.items():
        svg = (
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 128 128" width="128" height="128">\n'
            f'<rect width="128" height="128" rx="26" fill="{colour}"/>\n{glyph}\n</svg>\n'
        )
        (OUT / f"speculator-{name}.svg").write_text(svg, encoding="utf-8", newline="\n")
        print(f"speculator-{name}.svg")


if __name__ == "__main__":
    main()
