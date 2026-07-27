#!/usr/bin/env python3
"""Wrap org-mode's exported <div id="content"> in the AmberConsole ac-screen
frame (ac-screen/ac-bloom + the mesh overlay child + ac-screen__body), so the
console glass is real ac-screen markup rather than a CSS-only approximation.

Deliberately bloom-only: no .ac-crt (scanlines/vignette) and no .ac-afterglow
(decay/ghosting/scroll-smear) — those simulations cost readability on
long-form text and code, so the site never enables them. See amber-theme.css
for the full rationale.

Idempotent: files already carrying the frame are left untouched. Run after
process.sh / category-process.sh regenerate *.html from *.org.
"""
import re
import sys
from pathlib import Path

OPEN_OLD = '<div id="content" class="content">'
OPEN_NEW = (
    '<div id="content" class="content ac-screen ac-bloom">\n'
    '<span class="ac-mesh"></span>\n'
    '<div class="ac-screen__body">'
)

CLOSE_OLD = "</div>\n</body>\n</html>"
CLOSE_NEW = "</div>\n</div>\n</body>\n</html>"

MARKER = "ac-screen"


def apply_frame(path: Path) -> bool:
    text = path.read_text()
    if MARKER in text:
        return False
    if OPEN_OLD not in text or not text.rstrip().endswith("</html>"):
        print(f"skip (unexpected structure): {path}", file=sys.stderr)
        return False
    text = text.replace(OPEN_OLD, OPEN_NEW, 1)
    if not text.endswith(CLOSE_OLD):
        # Tolerate trailing newline differences.
        if text.rstrip("\n").endswith(CLOSE_OLD.rstrip("\n")):
            trailing_nl = text[len(text.rstrip("\n")):]
            text = text.rstrip("\n")[: -len(CLOSE_OLD.rstrip("\n"))] + CLOSE_NEW.rstrip("\n") + trailing_nl
        else:
            print(f"skip (unexpected tail): {path}", file=sys.stderr)
            return False
    else:
        text = text[: -len(CLOSE_OLD)] + CLOSE_NEW
    path.write_text(text)
    return True


def main(argv):
    if len(argv) < 2:
        print("usage: apply-amber-frame.py <file.html> [...]", file=sys.stderr)
        return 1
    changed = 0
    for arg in argv[1:]:
        p = Path(arg)
        if apply_frame(p):
            changed += 1
    print(f"framed {changed}/{len(argv) - 1} file(s)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
