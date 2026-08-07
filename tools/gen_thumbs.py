#!/usr/bin/env python3
"""Generate the small `-thumb.webp` cover variants used by the home cascade.

The home page paints its project tiles ~770px wide and angled, but the
covers ship at 1600x900 for the detail pages. Serving the full asset there
cost 16.4 MB of WebP over the wire and ~5.8 MB of decoded RGBA per cover.

Run from the project root after adding or regenerating any cover:

    python3 tools/gen_thumbs.py

Idempotent: existing thumbs are overwritten, and files already at or below
the target width are skipped. See `ProjectItemData._thumb` for the naming
convention the Dart side expects.
"""
import glob
import os

from PIL import Image

TARGET_W = 900
QUALITY = 82


def main() -> None:
    sources = sorted(
        set(glob.glob('assets/images/projects/*/cover*.webp')
            + glob.glob('assets/images/projects/*/cover*.jpg'))
    )
    sources = [f for f in sources if '-thumb' not in f]

    made = skipped = 0
    src_bytes = out_bytes = 0
    for path in sources:
        stem, _ = os.path.splitext(path)
        out = f'{stem}-thumb.webp'
        with Image.open(path) as im:
            if im.width <= TARGET_W:
                skipped += 1
                continue
            rgb = im.convert('RGB')
            height = round(rgb.height * TARGET_W / rgb.width)
            rgb.resize((TARGET_W, height), Image.LANCZOS).save(
                out, 'WEBP', quality=QUALITY, method=6
            )
        src_bytes += os.path.getsize(path)
        out_bytes += os.path.getsize(out)
        made += 1

    print(f'generated {made} thumbs at {TARGET_W}px wide ({skipped} skipped)')
    if src_bytes:
        print(f'  {src_bytes / 1048576:.1f} MB -> {out_bytes / 1048576:.1f} MB '
              f'({100 * out_bytes / src_bytes:.0f}% of source)')


if __name__ == '__main__':
    main()
