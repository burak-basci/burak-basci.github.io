#!/usr/bin/env python3
"""Install hover-cover images for portfolio projects.

Source PNGs live in `tools/ai_prompts/originals/<slug>.png`, one per
project (the same slug the URLs use). For each one this script:

  1. Resizes to exactly 1600x900 (Lanczos) — matches the typographic
     main covers, so the hover crossfade stays pixel-aligned.
  2. Writes XMP + EXIF metadata for SEO: title, description, creator,
     copyright, keywords (category, tech, portfolio).
  3. Saves as WebP at quality 90, method 6 (smallest possible without
     visible loss) at `assets/images/projects/<folder>/cover-color.webp`.
  4. Removes any leftover `cover-color.png` from older migrations.
  5. Makes sure `projects.dart` references the `.webp` file, adding the
     `coverColorUrl` field for entries that don't have it yet.

Idempotent — safe to re-run after replacing any single image. Projects
without a matching source PNG are skipped silently.
"""
from __future__ import annotations

import html
import re
from datetime import datetime
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
SOURCE_IMAGES = ROOT / "tools" / "ai_prompts" / "originals"
PROJECTS_DART = ROOT / "lib" / "data" / "projects.dart"
ASSETS_ROOT = ROOT / "assets" / "images" / "projects"

W, H = 1600, 900
WEBP_QUALITY = 90
WEBP_METHOD = 6  # 0=fastest, 6=slowest/smallest

PORTFOLIO_BASE_URL = "https://www.burakbasci.de"


# --- Projects.dart parsing ------------------------------------------------
PROJECT_BLOCK = re.compile(
    r"ProjectItemData\(\s*(?P<body>(?:[^()]|\([^()]*\))*?)\)\s*,",
    re.DOTALL,
)


def _string_field(body: str, field: str) -> str | None:
    pattern = re.compile(rf"{field}:\s*((?:'(?:[^'\\]|\\.)*'\s*)+)", re.DOTALL)
    m = pattern.search(body)
    if not m:
        return None
    pieces = re.findall(r"'((?:[^'\\]|\\.)*)'", m.group(1), re.DOTALL)
    return "".join(pieces).replace(r"\'", "'")


def _folder_field(body: str) -> str | None:
    m = re.search(r"image:\s*'\$_d/([^/]+)/cover\.png'", body)
    return m.group(1) if m else None


def _slugify(text: str) -> str:
    t = text.lower()
    t = re.sub(r"[^a-z0-9\s-]", "", t)
    t = re.sub(r"\s+", "-", t)
    t = re.sub(r"-+", "-", t)
    return t.strip("-")


def parse_projects() -> list[dict]:
    src = PROJECTS_DART.read_text()
    out: list[dict] = []
    for block in PROJECT_BLOCK.finditer(src):
        body = block.group("body")
        title = _string_field(body, "title")
        subtitle = _string_field(body, "subtitle")
        category = _string_field(body, "category")
        tech = _string_field(body, "technologyUsed") or ""
        folder = _folder_field(body)
        if not (title and subtitle and category and folder):
            continue
        out.append({
            "title": title,
            "subtitle": subtitle,
            "category": category,
            "tech": tech,
            "folder": folder,
            "slug": _slugify(title),
        })
    return out


# --- Metadata --------------------------------------------------------------
def build_xmp(p: dict) -> str:
    """A minimal but valid XMP packet with Dublin Core + Photoshop fields
    that Google Image Search, Bing, and most CMSes look at."""
    year = datetime.now().year
    keywords: list[str] = ["Burak Basci", "portfolio", "software engineering"]
    keywords += [t.strip() for t in re.split(r"[/·,]+", p["category"]) if t.strip()]
    keywords += [
        t.strip()
        for t in re.split(r"·|,|\s·\s|\s—\s", p["tech"])
        if t.strip() and 1 < len(t.strip()) < 40
    ][:8]
    # De-dup preserving order.
    seen: set[str] = set()
    keywords = [k for k in keywords if not (k.lower() in seen or seen.add(k.lower()))]

    title = html.escape(p["title"])
    description = html.escape(f"{p['subtitle']} — Portfolio cover by Burak Basci.")
    source = html.escape(f"{PORTFOLIO_BASE_URL}/projects/{p['slug']}")
    keyword_xml = "\n     ".join(
        f"<rdf:li>{html.escape(k)}</rdf:li>" for k in keywords
    )

    return (
        '<?xpacket begin="﻿" id="W5M0MpCehiHzreSzNTczkc9d"?>\n'
        '<x:xmpmeta xmlns:x="adobe:ns:meta/" x:xmptk="burakbasci.de cover pipeline">\n'
        ' <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">\n'
        '  <rdf:Description rdf:about=""\n'
        '    xmlns:dc="http://purl.org/dc/elements/1.1/"\n'
        '    xmlns:xmp="http://ns.adobe.com/xap/1.0/"\n'
        '    xmlns:photoshop="http://ns.adobe.com/photoshop/1.0/">\n'
        f'   <dc:title><rdf:Alt><rdf:li xml:lang="x-default">{title}</rdf:li></rdf:Alt></dc:title>\n'
        f'   <dc:description><rdf:Alt><rdf:li xml:lang="x-default">{description}</rdf:li></rdf:Alt></dc:description>\n'
        '   <dc:creator><rdf:Seq><rdf:li>Burak Basci</rdf:li></rdf:Seq></dc:creator>\n'
        f'   <dc:rights><rdf:Alt><rdf:li xml:lang="x-default">© {year} Burak Basci. All rights reserved.</rdf:li></rdf:Alt></dc:rights>\n'
        f'   <dc:subject><rdf:Bag>\n     {keyword_xml}\n    </rdf:Bag></dc:subject>\n'
        '   <photoshop:Credit>Burak Basci</photoshop:Credit>\n'
        f'   <photoshop:Source>{source}</photoshop:Source>\n'
        f'   <photoshop:Headline>{title} — Portfolio of Burak Basci</photoshop:Headline>\n'
        '  </rdf:Description>\n'
        ' </rdf:RDF>\n'
        '</x:xmpmeta>\n'
        '<?xpacket end="w"?>'
    )


def build_exif(p: dict) -> bytes:
    """Minimal EXIF block with ImageDescription / Artist / Copyright so
    image viewers that don't read XMP still get the canonical author + a
    short description."""
    from PIL import Image as _Image
    exif = _Image.Exif()
    # Tag IDs: 270 = ImageDescription, 305 = Software, 315 = Artist,
    #          33432 = Copyright
    exif[270] = f"{p['title']} — {p['subtitle']}"
    exif[305] = "burakbasci.de cover pipeline"
    exif[315] = "Burak Basci"
    exif[33432] = f"© {datetime.now().year} Burak Basci. All rights reserved."
    return exif.tobytes()


# --- The conversion --------------------------------------------------------
def install(projects: list[dict]) -> list[dict]:
    """For every project that has a matching `<slug>.png` source, render
    the WebP hover cover. Returns the projects that were actually wired
    so the dart-update step only touches those entries."""
    installed: list[dict] = []
    for p in projects:
        img_path = SOURCE_IMAGES / f"{p['slug']}.png"
        if not img_path.exists():
            print(f"  {p['folder']:18s} {p['slug']:42s}  (no source — skipped)")
            continue

        out_dir = ASSETS_ROOT / p["folder"]
        out_dir.mkdir(parents=True, exist_ok=True)
        out_path = out_dir / "cover-color.webp"
        legacy_png = out_dir / "cover-color.png"

        with Image.open(img_path) as im:
            resized = im.convert("RGB").resize((W, H), Image.LANCZOS)
            resized.save(
                out_path,
                format="WEBP",
                quality=WEBP_QUALITY,
                method=WEBP_METHOD,
                xmp=build_xmp(p),
                exif=build_exif(p),
            )

        if legacy_png.exists():
            legacy_png.unlink()

        src_sz = img_path.stat().st_size // 1024
        out_sz = out_path.stat().st_size // 1024
        ratio = (out_sz / src_sz) if src_sz else 0
        print(
            f"  {p['folder']:18s} {p['slug']:42s} "
            f"{src_sz:>5d} KB → {out_sz:>4d} KB ({ratio:.0%})"
        )
        installed.append(p)
    return installed


# --- projects.dart rewrite -------------------------------------------------
def update_dart_references(projects_sorted: list[dict]) -> None:
    """Make every coverColorUrl point at the new .webp file. Adds the field
    next to coverUrl for entries that don't have it yet."""
    src = PROJECTS_DART.read_text()

    # 1. Migrate existing .png references to .webp.
    src, n_renamed = re.subn(
        r"coverColorUrl: '\$_d/([^/]+)/cover-color\.png',",
        r"coverColorUrl: '$_d/\1/cover-color.webp',",
        src,
    )

    # 2. Add coverColorUrl right after coverUrl for entries that don't have it.
    n_added = 0
    for p in projects_sorted:
        folder = p["folder"]
        new_line = f"coverColorUrl: '$_d/{folder}/cover-color.webp',"
        if new_line in src:
            continue
        pattern = re.compile(
            rf"(image: '\$_d/{re.escape(folder)}/cover\.png',\s*\n\s*"
            rf"coverUrl: '\$_d/{re.escape(folder)}/cover\.png',)",
        )
        src, n = pattern.subn(rf"\1\n    {new_line}", src)
        n_added += n

    PROJECTS_DART.write_text(src)
    print(f"\n  Updated projects.dart: {n_renamed} migrated png→webp, "
          f"{n_added} entries gained a coverColorUrl.")


# --- Entry point -----------------------------------------------------------
def main() -> None:
    if not SOURCE_IMAGES.exists():
        raise SystemExit(
            f"Source folder missing: {SOURCE_IMAGES.relative_to(ROOT)}/"
        )
    images = sorted(SOURCE_IMAGES.glob("*.png"))
    print(f"Found {len(images)} source images in "
          f"{SOURCE_IMAGES.relative_to(ROOT)}/.")

    projects = parse_projects()
    print(f"Parsed {len(projects)} projects from "
          f"{PROJECTS_DART.relative_to(ROOT)}.\n")

    installed = install(projects)
    update_dart_references(installed)
    print(f"\nDone. {len(installed)} hover covers installed as WebP "
          f"@ {WEBP_QUALITY}% with SEO metadata.")


if __name__ == "__main__":
    main()
