#!/usr/bin/env python3
"""Write one ready-to-paste AI prompt per technical-illustration recipe.

Reads `tools/technical_recipes.py` (hand-written per-project list of
diagrams) plus `lib/data/projects.dart` (title / subtitle / category /
hero colour). For every entry it emits a bare prompt text file at:

    tools/ai_prompts/technical/<slug>-<id>.txt

Each prompt asks the image model for a Bauhaus / Swiss-style technical
diagram: thin lines, labelled nodes, hero-colour accents only on the
nodes that matter, generous negative space. Short labels are allowed
because they make the diagram readable; the rest of the rules from the
main + hover prompts (no atmosphere, no clichés, no UI mockups) still
apply.

Companion script `install_technical_covers.py` later resizes any source
PNGs in `tools/ai_prompts/originals/technical/<slug>-<id>.png` to
1600×900 WebP @ 90% with SEO metadata, installs them at
`assets/images/projects/<folder>/technical-<id>.webp`, and rewires
`projects.dart` accordingly.
"""
from __future__ import annotations

import re
from pathlib import Path

import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from technical_recipes import RECIPES  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "lib" / "data" / "projects.dart"
OUT_DIR = ROOT / "tools" / "ai_prompts" / "technical"


# --- Parse projects.dart ---------------------------------------------------
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


def _hex(body):
    m = re.search(r"primaryColor:\s*const\s+Color\(0x(?:FF|ff)([0-9A-Fa-f]{6})\)", body)
    return ("#" + m.group(1).upper()) if m else None


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
        folder = _folder(body)
        hex_color = _hex(body)
        if not (title and subtitle and category and folder and hex_color):
            continue
        slug = _slugify(title)
        out[slug] = {
            "title": title,
            "subtitle": subtitle,
            "category": category,
            "folder": folder,
            "hex": hex_color,
            "slug": slug,
        }
    return out


# --- Render -----------------------------------------------------------------
def render_prompt(p, illustration):
    return f"""ROLE
You are an art-director generating one minimalist technical-illustration
poster for a senior software-engineer's portfolio. This is graphic
design, not photography — flat colour fields, clean geometric type,
zero atmospheric detail. The image is a SYSTEM DIAGRAM rendered with
the same Swiss / Bauhaus / Dieter-Rams visual vocabulary the project's
main cover uses.

LAYOUT
- Aspect: 16:9, target 1600x900.
- Background: hero colour {p["hex"]} as a smooth diagonal gradient
  (slightly lighter top-left, slightly darker bottom-right). A very
  faint diagonal-line texture (~8% opacity) and a subtle vignette are
  allowed.
- The diagram lives in the centre / centre-right of the frame. The
  left ~25% of the frame is kept clean for visual breathing room.
- Diagram elements (nodes, arrows, labels) are drawn as thin
  geometric primitives — outlined rectangles, circles, lines —
  rendered in white or pale neutrals. Only the most important node or
  two are filled in the hero colour as accents.
- Short technical labels (1–3 words each) are allowed and EXPECTED
  on each node, so the diagram reads as a real architecture sketch
  rather than abstract decoration. Use a clean geometric sans-serif
  (DIN / Inter / URW Gothic vocabulary). Letter-spacing is loose.

DIAGRAM
{illustration["subject"]}

STYLE
Swiss International Style, Bauhaus, Dieter Rams industrial-design
simplicity. The composition feels like an engineering whitepaper
figure or a museum-shop architecture poster — never a film still and
never a photograph.

HARD RULES
- Allowed text: short technical labels on diagram nodes, plus the
  diagram's small title "{illustration["title"]}" set as a quiet
  caption near the top-left corner if it fits. No long sentences,
  no paragraphs, no marketing copy.
- NO people, faces, hands, body parts.
- NO UI mockups, screenshots, real dashboards, code-on-screen.
- NO smoke, fog, haze, particles, sparkles, atmospheric scatter.
- NO film grain, ISO noise, dust, scratches.
- NO realistic surface textures (concrete, brushed metal, patina,
  woodgrain, fabric, paper fibre).
- NO photographic depth-of-field, bokeh, lens flare.
- NO cinematic treatment.
- NO AI clichés: glowing brains, hex-grid meshes with neon dots,
  Matrix rain, hooded figures, rotating data-spheres, holographic
  blueprints, robot heads.
- One composition — no collage, no grid, no multi-panel layout.

PROJECT CONTEXT
- title: {p["title"]}
- subtitle: {p["subtitle"]}
- category: {p["category"]}
- diagram: {illustration["title"]}
- hero colour (hex): {p["hex"]}

OUTPUT
One 16:9 minimalist architecture diagram. Hero colour {p["hex"]} as
the gradient background; the diagram nodes / arrows / labels rendered
as crisp white-on-dark geometric primitives with the hero colour
called out only on the one or two nodes that carry the most weight.
Swiss / Bauhaus / Dieter Rams sensibility. Quality at maximum.
"""


# --- Entry point -----------------------------------------------------------
def main():
    projects = parse_projects()
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    for stale in OUT_DIR.glob("*.txt"):
        stale.unlink()
    written = 0
    skipped: list[str] = []
    for slug, illustrations in RECIPES.items():
        p = projects.get(slug)
        if not p:
            skipped.append(slug)
            continue
        for ill in illustrations:
            path = OUT_DIR / f"{slug}-{ill['id']}.txt"
            path.write_text(render_prompt(p, ill))
            written += 1
            print(f"  {slug}-{ill['id']:<3} {p['hex']}  {ill['title']}")
    if skipped:
        print(f"\n  SKIPPED slugs (not found in projects.dart): {skipped}")
    print(f"\nWrote {written} technical prompts to "
          f"{OUT_DIR.relative_to(ROOT)}/.")


if __name__ == "__main__":
    main()
