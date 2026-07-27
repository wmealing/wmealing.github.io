#!/usr/bin/env python3
"""One-time migration: downgrade already-framed pages (ac-screen ac-bloom
ac-crt ac-afterglow + mesh/retrace/persist spans) to bloom-only. Superseded
by the updated apply-amber-frame.py for future regenerations; kept only for
the historical record of how the existing tree was migrated.
"""
import sys
from pathlib import Path

OLD = (
    '<div id="content" class="content ac-screen ac-bloom ac-crt ac-afterglow">\n'
    '<span class="ac-mesh"></span>\n'
    '<span class="ac-retrace"></span>\n'
    '<span class="ac-persist"></span>\n'
    '<div class="ac-screen__body">'
)
NEW = (
    '<div id="content" class="content ac-screen ac-bloom">\n'
    '<span class="ac-mesh"></span>\n'
    '<div class="ac-screen__body">'
)


def main(argv):
    changed = 0
    for arg in argv[1:]:
        p = Path(arg)
        text = p.read_text()
        if OLD in text:
            p.write_text(text.replace(OLD, NEW, 1))
            changed += 1
        elif "ac-crt" in text or "ac-afterglow" in text:
            print(f"unexpected structure, check by hand: {p}", file=sys.stderr)
    print(f"downgraded {changed}/{len(argv) - 1} file(s)")


if __name__ == "__main__":
    main(sys.argv)
