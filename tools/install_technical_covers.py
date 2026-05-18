#!/usr/bin/env python3
"""Install technical-illustration source PNGs as WebP covers.

Walks `tools/ai_prompts/originals/technical/<slug>-<id>.png`, pairs each
file against the recipe in `technical_recipes.py` (for the caption) and
the entry in `lib/data/projects.dart` (for the folder + hero colour),
then:

  1. Resizes the source to 1600x900 (Lanczos).
  2. Writes WebP @ 90% / method 6 to
     `assets/images/projects/<folder>/technical-<id>.webp`.
  3. Embeds XMP + EXIF metadata: title (project title + diagram name),
     description (caption), creator (Burak Basci), copyright, keywords.
  4. Rewrites the project's `technicalImages:` list in
     `lib/data/projects.dart` so the new files are wired into the
     detail page section.

Idempotent — re-running after replacing or adding a single PNG only
re-encodes that one and only patches that project's `technicalImages:`
entry. Projects without any matching source PNG are left untouched
(empty `technicalImages:` lists stay empty).
"""
from __future__ import annotations

import html
import re
import sys
from datetime import datetime
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "lib" / "data" / "projects.dart"
SRC_DIR = ROOT / "tools" / "ai_prompts" / "originals" / "technical"
ASSETS_ROOT = ROOT / "assets" / "images" / "projects"

sys.path.insert(0, str(Path(__file__).resolve().parent))
from technical_recipes import RECIPES  # noqa: E402

W, H = 1600, 900
WEBP_QUALITY = 90
WEBP_METHOD = 6
PORTFOLIO_BASE_URL = "https://www.burakbasci.de"


# --- projects.dart parsing -------------------------------------------------
PROJECT_BLOCK = re.compile(
    r"ProjectItemData\(\s*(?P<body>(?:[^()]|\([^()]*\))*?)\)\s*,",
    re.DOTALL,
)


def _string_field(body, field):
    pattern = re.compile(rf"{field}:\s*((?:'(?:[^'\\]|\\.)*'\s*)+)", re.DOTALL)
    m = pattern.search(body)
    if not m:
        return None
    pieces = re.findall(r"'((?:[^'\\]|\\.)*)'", m.group(1), re.DOTALL)
    return "".join(pieces).replace(r"\'", "'")


def _folder(body):
    m = re.search(r"image:\s*'\$_d/([^/]+)/cover\.(?:png|webp)'", body)
    return m.group(1) if m else None


def _slugify(text):
    t = text.lower()
    t = re.sub(r"[^a-z0-9\s-]", "", t)
    t = re.sub(r"\s+", "-", t)
    return re.sub(r"-+", "-", t).strip("-")


def parse_projects():
    src = SOURCE.read_text()
    out = {}
    for m in PROJECT_BLOCK.finditer(src):
        body = m.group("body")
        title = _string_field(body, "title")
        subtitle = _string_field(body, "subtitle")
        category = _string_field(body, "category")
        tech = _string_field(body, "technologyUsed") or ""
        folder = _folder(body)
        if not (title and subtitle and category and folder):
            continue
        slug = _slugify(title)
        out[slug] = {
            "title": title,
            "subtitle": subtitle,
            "category": category,
            "tech": tech,
            "folder": folder,
            "slug": slug,
        }
    return out


# --- metadata --------------------------------------------------------------
def build_xmp(p, illustration):
    year = datetime.now().year
    keywords = ["Burak Basci", "portfolio", "software engineering",
                "system architecture", "technical diagram"]
    keywords += [t.strip() for t in re.split(r"[/·,]+", p["category"]) if t.strip()]
    keywords += [
        t.strip()
        for t in re.split(r"·|,|\s·\s|\s—\s", p["tech"])
        if t.strip() and 1 < len(t.strip()) < 40
    ][:8]
    seen = set()
    keywords = [k for k in keywords if not (k.lower() in seen or seen.add(k.lower()))]
    full_title = f"{p['title']} — {illustration['title']}"
    description = illustration["caption"]
    source = f"{PORTFOLIO_BASE_URL}/projects/{p['slug']}"
    keyword_xml = "\n     ".join(f"<rdf:li>{html.escape(k)}</rdf:li>" for k in keywords)
    return (
        '<?xpacket begin="﻿" id="W5M0MpCehiHzreSzNTczkc9d"?>\n'
        '<x:xmpmeta xmlns:x="adobe:ns:meta/" x:xmptk="burakbasci.de cover pipeline">\n'
        ' <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">\n'
        '  <rdf:Description rdf:about=""\n'
        '    xmlns:dc="http://purl.org/dc/elements/1.1/"\n'
        '    xmlns:xmp="http://ns.adobe.com/xap/1.0/"\n'
        '    xmlns:photoshop="http://ns.adobe.com/photoshop/1.0/">\n'
        f'   <dc:title><rdf:Alt><rdf:li xml:lang="x-default">{html.escape(full_title)}</rdf:li></rdf:Alt></dc:title>\n'
        f'   <dc:description><rdf:Alt><rdf:li xml:lang="x-default">{html.escape(description)}</rdf:li></rdf:Alt></dc:description>\n'
        '   <dc:creator><rdf:Seq><rdf:li>Burak Basci</rdf:li></rdf:Seq></dc:creator>\n'
        f'   <dc:rights><rdf:Alt><rdf:li xml:lang="x-default">© {year} Burak Basci. All rights reserved.</rdf:li></rdf:Alt></dc:rights>\n'
        f'   <dc:subject><rdf:Bag>\n     {keyword_xml}\n    </rdf:Bag></dc:subject>\n'
        '   <photoshop:Credit>Burak Basci</photoshop:Credit>\n'
        f'   <photoshop:Source>{html.escape(source)}</photoshop:Source>\n'
        f'   <photoshop:Headline>{html.escape(full_title)}</photoshop:Headline>\n'
        '  </rdf:Description>\n'
        ' </rdf:RDF>\n'
        '</x:xmpmeta>\n'
        '<?xpacket end="w"?>'
    )


def build_exif(p, illustration):
    exif = Image.Exif()
    exif[270] = f"{p['title']} — {illustration['title']}: {illustration['caption']}"
    exif[305] = "burakbasci.de cover pipeline"
    exif[315] = "Burak Basci"
    exif[33432] = f"© {datetime.now().year} Burak Basci. All rights reserved."
    return exif.tobytes()


# --- Install one PNG -------------------------------------------------------
def install_one(p, illustration, src_path):
    out_dir = ASSETS_ROOT / p["folder"]
    out_dir.mkdir(parents=True, exist_ok=True)
    out_path = out_dir / f"technical-{illustration['id']}.webp"

    with Image.open(src_path) as im:
        resized = im.convert("RGB").resize((W, H), Image.LANCZOS)
        resized.save(
            out_path,
            format="WEBP",
            quality=WEBP_QUALITY,
            method=WEBP_METHOD,
            xmp=build_xmp(p, illustration),
            exif=build_exif(p, illustration),
        )

    src_kb = src_path.stat().st_size // 1024
    out_kb = out_path.stat().st_size // 1024
    print(f"  {p['folder']:18s} {p['slug']:42s} technical-{illustration['id']}  "
          f"{src_kb:>4d} KB → {out_kb:>3d} KB")
    return out_path


# --- Rewrite projects.dart -------------------------------------------------
def _dart_literal_for(p, illustrations):
    """Return the source text for a `technicalImages: <TechnicalImage>[...]`
    list literal for one project."""
    if not illustrations:
        return "technicalImages: const <TechnicalImage>[],"
    rows = []
    for ill in illustrations:
        path = f"$_d/{p['folder']}/technical-{ill['id']}.webp"
        caption = ill["caption"].replace("\\", r"\\").replace("'", r"\'")
        rows.append(
            f"      TechnicalImage(\n"
            f"        path: '{path}',\n"
            f"        caption: '{caption}',\n"
            f"      ),"
        )
    return "technicalImages: const <TechnicalImage>[\n" + "\n".join(rows) + "\n    ],"


def update_dart(installed: dict[str, list[dict]]):
    """For each project that got at least one installed technical image,
    inject / replace its `technicalImages:` list. Idempotent — works
    whether the field is already present or not.
    """
    src = SOURCE.read_text()

    for slug, illustrations in installed.items():
        # Find the ProjectItemData block for this slug. We match by the
        # slug-derived title — but slug is the source of truth here, so
        # we re-derive it inside the loop.
        new_literal = _dart_literal_for(
            {"folder": illustrations[0]["folder"]}, illustrations
        )

        # Replace existing technicalImages:
        existing = re.compile(
            rf"technicalImages:\s*const\s*<TechnicalImage>\[[^\]]*\],?",
            re.DOTALL,
        )

        # Locate the project's ProjectItemData block by matching on a
        # unique-ish field (its image: line with the folder name).
        folder = illustrations[0]["folder"]
        block_pattern = re.compile(
            rf"(ProjectItemData\(\s*(?:(?!ProjectItemData).)*?"
            rf"image:\s*'\$_d/{re.escape(folder)}/cover\.(?:png|webp)'"
            rf"(?:(?!ProjectItemData).)*?)(\),)",
            re.DOTALL,
        )
        m = block_pattern.search(src)
        if not m:
            print(f"  WARN: could not locate ProjectItemData for folder {folder}")
            continue
        block, close = m.group(1), m.group(2)

        if existing.search(block):
            new_block = existing.sub(new_literal, block, count=1)
        else:
            # Insert just before the closing paren — keep at same indentation
            # level as other fields (4 spaces in this codebase).
            new_block = block.rstrip() + "\n    " + new_literal + "\n  "

        src = src[: m.start()] + new_block + close + src[m.end():]

    SOURCE.write_text(src)
    print(f"\n  projects.dart updated for {len(installed)} project(s).")


# --- Entry point -----------------------------------------------------------
def main():
    if not SRC_DIR.exists():
        print(f"  Source folder doesn't exist: {SRC_DIR.relative_to(ROOT)}/")
        print(f"  Create it and drop generated PNGs as <slug>-<id>.png.")
        return

    projects = parse_projects()
    installed: dict[str, list[dict]] = {}

    for slug, illustrations in RECIPES.items():
        p = projects.get(slug)
        if not p:
            continue
        for ill in illustrations:
            src_path = SRC_DIR / f"{slug}-{ill['id']}.png"
            if not src_path.exists():
                continue
            install_one(p, ill, src_path)
            installed.setdefault(slug, []).append(
                {**ill, "folder": p["folder"]}
            )

    if installed:
        update_dart(installed)
        n = sum(len(v) for v in installed.values())
        print(f"\nDone. {n} technical covers installed across "
              f"{len(installed)} project(s).")
    else:
        print(f"  No source PNGs found in {SRC_DIR.relative_to(ROOT)}/.")
        print(f"  Drop <slug>-<id>.png files into that folder and re-run.")


if __name__ == "__main__":
    main()
