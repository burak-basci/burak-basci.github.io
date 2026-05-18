#!/usr/bin/env python3
"""Emit two ready-to-paste AI cover-prompts per portfolio project — one
per slot in the dual-cover system.

Output:
    tools/ai_prompts/hover/<slug>.txt   cinematic "colour" film still
                                        (crossfaded in on tile hover,
                                        saved as cover-color.png)
    tools/ai_prompts/main/<slug>.txt    minimalist Bauhaus / Swiss-design
                                        background that complements the
                                        procedural typography overlay
                                        (saved as cover.png)

Each file is meant to be copy-pasted directly into Midjourney, FLUX,
SD/SDXL, DALL·E 3 or Imagen without further editing. Run again whenever
projects.dart changes — it overwrites idempotently.

Usage:
    python3 tools/gen_ai_prompts.py
"""
from __future__ import annotations

import os
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "lib" / "data" / "projects.dart"
OUTPUT_DIR = ROOT / "tools" / "ai_prompts"
HOVER_DIR = OUTPUT_DIR / "hover"
MAIN_DIR = OUTPUT_DIR / "main"


# --- Subject map · HOVER (cinematic) ---------------------------------------
# Used for the cover-color.png that crossfades in on tile hover. Describes
# one atmospheric film still per category — Christopher-Nolan-title-card
# lighting, hero colour as the single dominant emission.
#
# Matching is exact-token (so `AR` doesn't accidentally hit `SEARCH`).
# Walked top-to-bottom — first hit wins, so put specific keys first.
HOVER_RECIPES: list[tuple[tuple[str, ...], str]] = [
    # --- Paper / forensic / docs ----------------------------------------
    (
        ("LEGAL", "EVIDENCE"),
        "stacked paper-toned strata in low slanting light, a single sealed "
        "edge catching the hero colour, sense of weight and consequence — "
        "the geometry of forensic documentation, nothing literal.",
    ),
    (
        ("DOCUMENTS", "DOCUMENT"),
        "clean folded paper strata, ink-like shadows, a single sharp crease "
        "lit in the hero colour, deep negative space on either side — the "
        "feel of formal correspondence translated into pure form.",
    ),
    # --- Research / VR / Game -------------------------------------------
    (
        ("ROBOTICS",),
        "a precise machined component half-lit by a single rim of the hero "
        "colour against deep shadow, engineered intent rather than literal "
        "robots, museum-of-industrial-design lighting.",
    ),
    (
        ("VR", "HEALTHCARE"),
        "an empty stage seen through soft volumetric light, a single ground "
        "marker glowing in the hero colour, walls dissolving into haze — "
        "the spatial premise of an exposure environment.",
    ),
    (
        ("GAME", "UNREAL", "ITCH.IO"),
        "a cinematic landscape distilled from the game's own world — "
        "brutalist arena for a shooter, warm dusk for a flyer, close-up "
        "wood grain and folded fabric for a card game — single hero "
        "colour pushed into the lighting.",
    ),
    # --- Infra ----------------------------------------------------------
    (
        ("SELF-HOSTED", "EDGE", "IOT", "INFRA", "PROXMOX"),
        "a single monumental architectural object in deep shadow, cold "
        "metallic light grazing one edge in the hero colour, quiet and "
        "immovable — the feel of infrastructure that refuses to depend on "
        "anyone else.",
    ),
    (
        ("KUBERNETES", "CLOUD"),
        "orbiting solid masses with subtle gravitational geometry, clean "
        "industrial materials, engineered scale; the hero colour as a "
        "single rim light across the largest mass.",
    ),
    (
        ("3D", "PROPERTY", "REAL-ESTATE", "PROPTECH"),
        "an architectural silhouette half in shadow, a single window or "
        "aperture lit in the hero colour, ground-plane fog. Read as "
        "'premises', never as a literal building photograph.",
    ),
    # --- AI sub-flavours -----------------------------------------------
    (
        ("SEARCH", "RAG", "VECTOR"),
        "a constellation of fine points across the frame with one or two "
        "drawn light-beams between them, the hero colour as the only "
        "signal in vast near-black space — like looking at distant "
        "transmission in a dark room.",
    ),
    (
        ("VOICE", "STT", "TTS"),
        "horizontal mist layers and soft waveform ridges suggested by "
        "light rather than drawn, the hero colour as the only emission "
        "from the deepest layer.",
    ),
    (
        ("TOOL",),
        "a small precise object held in the centre of the frame by deep "
        "shadow, a single rim of the hero colour, museum-still lighting — "
        "the feel of a sharp single-purpose instrument.",
    ),
    # --- Commerce / outreach -------------------------------------------
    (
        ("E-COMMERCE", "COMMERCE", "PRINT-ON-DEMAND"),
        "product-still language: a single hero object centred and deep-set, "
        "dramatic single-source lighting from above-left in the hero colour, "
        "shallow depth of field. No commercial cliché.",
    ),
    (
        ("SALES", "OUTREACH", "BROWSER", "SCRAPING"),
        "a sparse field of distant lit points connected by faint vectors, "
        "mostly dark, one stronger node in the foreground lit in the hero "
        "colour. The premise of outreach as signal, not noise.",
    ),
    # --- Web3 (before generic WEB) -------------------------------------
    (
        ("WEB3", "CHARITY"),
        "an orbiting solid mass in deep shadow with a single thread of the "
        "hero colour wrapping it like a slow, deliberate signal — the "
        "premise of token-aligned intent rather than cryptocurrency cliché.",
    ),
    # --- Library --------------------------------------------------------
    (
        ("PACKAGE",),
        "a small precise object held in the centre of the frame by deep "
        "shadow, a single rim of the hero colour, museum-still lighting — "
        "the feel of a sharp single-purpose instrument shared on a shelf.",
    ),
    # --- Web (theatre, portfolio, etc.) --------------------------------
    (
        ("WEB",),
        "an architectural silhouette in deep shadow, a single window lit "
        "warmly in the hero colour, ground fog. Old-craft venue distilled "
        "to its geometry.",
    ),
    # --- DevSecOps fallback --------------------------------------------
    (
        ("DEVSECOPS",),
        "orbiting solid masses with subtle gravitational geometry, clean "
        "industrial materials, engineered scale; the hero colour as a "
        "single rim light across the largest mass.",
    ),
    # --- SaaS / B2B / Ops / generic AI / Automation --------------------
    (
        (
            "SAAS",
            "AI",
            "AUTOMATION",
            "B2B",
            "OPERATIONS",
            "OPS",
            "FINANCE",
        ),
        "strata of layered translucent planes, one rising through the "
        "others, soft directional light catching only the rising plane in "
        "the hero colour. The premise of orchestration over chaos.",
    ),
    # --- Mobile / META catch-all ---------------------------------------
    (
        ("MOBILE",),
        "a single hero object centred in the frame with shallow depth of "
        "field, the hero colour as the only light source from below, deep "
        "near-black surrounding it.",
    ),
    (
        ("META", "PORTFOLIO"),
        "a single architectural form in deep shadow seen at a slight angle, "
        "a single thin shaft of the hero colour cutting across the frame — "
        "the feel of a self-portrait expressed in geometry.",
    ),
]

DEFAULT_HOVER_SUBJECT = (
    "a single hero object or geometry centred by deep negative space, "
    "the project's hero colour as the only directional light, no literal "
    "subject matter — atmosphere over illustration."
)


# --- Subject map · MAIN (minimalist Bauhaus) -------------------------------
# Used for the cover.png that the home tile shows at rest and the detail
# page uses as its hero. Pure geometry on a flat near-black field, hero
# colour as the only chromatic accent. No text — title and subtitle are
# composited on top later by `gen_covers.py` (or the AI image is used
# as-is and the typographic version is generated separately).
MAIN_RECIPES: list[tuple[tuple[str, ...], str]] = [
    (
        ("LEGAL", "EVIDENCE"),
        "three thin horizontal rectangles stacked with small vertical "
        "offsets, the topmost one filled with the hero colour, the rest "
        "drawn as 1px outlines.",
    ),
    (
        ("DOCUMENTS", "DOCUMENT"),
        "two overlapping rectangles folded along a single sharp diagonal "
        "crease, the crease line drawn 2px in the hero colour, the "
        "rectangles in near-black with 1px outlines.",
    ),
    (
        ("ROBOTICS",),
        "one perfect circle and one small square placed off-centre on a "
        "flat near-black field. The square is filled with the hero "
        "colour, the circle is a 1px outline. Bauhaus geometry.",
    ),
    (
        ("VR", "HEALTHCARE"),
        "one small circle low in the frame on a flat near-black field "
        "with a single thin concentric ring around it in the hero "
        "colour. Generous negative space everywhere else.",
    ),
    (
        ("GAME", "UNREAL", "ITCH.IO"),
        "one bold geometric icon evoking the game's mood (triangle for a "
        "shooter, soft arc for a flyer, rounded rectangle for a card "
        "game), filled flat in the hero colour, on a flat near-black "
        "field. No detail beyond the silhouette.",
    ),
    (
        ("SELF-HOSTED", "EDGE", "IOT", "INFRA", "PROXMOX"),
        "one solid rectangle anchored centrally on a flat near-black "
        "field with a single 2px vertical line in the hero colour "
        "running along its right edge.",
    ),
    (
        ("KUBERNETES", "CLOUD"),
        "three or four perfect circles arranged on a flat near-black "
        "field in a triangular grid; the central circle is filled with "
        "the hero colour, the others are 1px outlines. Swiss-design "
        "spacing.",
    ),
    (
        ("3D", "PROPERTY", "REAL-ESTATE", "PROPTECH"),
        "one tall vertical rectangle (building silhouette) on a flat "
        "near-black field with one small square 'window' inside it "
        "filled with the hero colour.",
    ),
    (
        ("SEARCH", "RAG", "VECTOR"),
        "a sparse scatter of small dots on a flat near-black field; one "
        "dot is enlarged and filled with the hero colour, with one thin "
        "straight line drawn from it to one other dot.",
    ),
    (
        ("VOICE", "STT", "TTS"),
        "one thin horizontal line at the vertical centre of the frame "
        "on a flat near-black field, with a 2px segment near its right "
        "end painted in the hero colour. Nothing else.",
    ),
    (
        ("TOOL",),
        "one small precise geometric primitive (square, triangle or "
        "ring) centred on a flat near-black field with a single edge or "
        "fill in the hero colour.",
    ),
    (
        ("E-COMMERCE", "COMMERCE", "PRINT-ON-DEMAND"),
        "one centred geometric package silhouette (isometric cube or "
        "stylised box outline) on a flat near-black field, with one "
        "face filled in the hero colour.",
    ),
    (
        ("SALES", "OUTREACH", "BROWSER", "SCRAPING"),
        "three or four small dots scattered on a flat near-black field, "
        "connected by single thin straight lines; the foremost dot is "
        "filled with the hero colour, the others are outlines.",
    ),
    (
        ("WEB3", "CHARITY"),
        "one perfect circle centred on a flat near-black field with one "
        "thin orbital ring drawn around it in the hero colour. Two "
        "shapes, nothing else.",
    ),
    (
        ("PACKAGE",),
        "one small isometric cube centred on a flat near-black field; "
        "one face is filled in the hero colour, the other two faces are "
        "1px outlines.",
    ),
    (
        ("WEB",),
        "one flat rectangle outlined in 1px on a near-black field, with "
        "one small square inside it filled in the hero colour.",
    ),
    (
        ("DEVSECOPS",),
        "three or four perfect circles arranged on a flat near-black "
        "field in a triangular grid; the central circle is filled with "
        "the hero colour, the others are 1px outlines.",
    ),
    (
        (
            "SAAS",
            "AI",
            "AUTOMATION",
            "B2B",
            "OPERATIONS",
            "OPS",
            "FINANCE",
        ),
        "three thin parallel horizontal lines stacked with small vertical "
        "offsets on a flat near-black field; the topmost line is painted "
        "in the hero colour, the others are pale outlines.",
    ),
    (
        ("MOBILE",),
        "one tall rounded rectangle (phone outline) centred on a flat "
        "near-black field, with one small square inside filled in the "
        "hero colour.",
    ),
    (
        ("META", "PORTFOLIO"),
        "one single thin diagonal line drawn across an otherwise empty "
        "near-black field, painted in the hero colour. Nothing else.",
    ),
]

DEFAULT_MAIN_SUBJECT = (
    "one single geometric primitive (circle, square or rectangle) centred "
    "on a flat near-black field, with one edge or fill in the hero colour. "
    "Nothing else in the frame."
)


# --- Helpers ----------------------------------------------------------------
def slugify(text: str) -> str:
    text = text.lower()
    text = re.sub(r"[^a-z0-9\s-]", "", text)
    text = re.sub(r"\s+", "-", text)
    text = re.sub(r"-+", "-", text)
    return text.strip("-")


def _pick(category: str, recipes, default: str) -> str:
    cat = category.upper()
    # Tokens preserve dots (ITCH.IO) and hyphens (REAL-ESTATE, PRINT-ON-
    # DEMAND, SELF-HOSTED) so multi-word category fragments stay intact.
    tokens = set(re.findall(r"[A-Z0-9][A-Z0-9.\-]*", cat))
    for keywords, recipe in recipes:
        if any(k in tokens for k in keywords):
            return recipe
    return default


def pick_hover_subject(category: str) -> str:
    return _pick(category, HOVER_RECIPES, DEFAULT_HOVER_SUBJECT)


def pick_main_subject(category: str) -> str:
    return _pick(category, MAIN_RECIPES, DEFAULT_MAIN_SUBJECT)


def initials_of(title: str, max_chars: int = 4) -> str:
    """First letter of each significant word, max four characters. Falls
    back to the first letters of the title for single-word names."""
    words = [w for w in re.findall(r"[A-Za-z0-9]+", title) if w]
    if not words:
        return title[:max_chars].upper()
    chars = "".join(w[0].upper() for w in words)
    if len(chars) >= 2:
        return chars[:max_chars]
    return words[0][:3].upper()


PROJECT_BLOCK = re.compile(
    r"ProjectItemData\(\s*(?P<body>(?:[^()]|\([^()]*\))*?)\)\s*,",
    re.DOTALL,
)


def extract_field(body: str, field: str) -> str | None:
    # Single-quoted single- or multi-line concatenated string literal:
    #     title: 'foo',
    #     subtitle: 'a long thing '
    #         'continued here',
    pattern = re.compile(
        rf"{field}:\s*((?:'(?:[^'\\]|\\.)*'\s*)+)",
        re.DOTALL,
    )
    m = pattern.search(body)
    if not m:
        return None
    raw = m.group(1)
    pieces = re.findall(r"'((?:[^'\\]|\\.)*)'", raw, re.DOTALL)
    joined = "".join(pieces)
    # Decode the handful of Dart escapes we actually use in the source.
    return joined.replace(r"\'", "'").replace(r"\n", "\n")


def extract_hex(body: str) -> str | None:
    m = re.search(
        r"primaryColor:\s*const\s+Color\(0x(?:FF|ff)([0-9A-Fa-f]{6})\)",
        body,
    )
    return ("#" + m.group(1).upper()) if m else None


def parse_projects() -> list[dict]:
    src = SOURCE.read_text()
    projects: list[dict] = []
    for block in PROJECT_BLOCK.finditer(src):
        body = block.group("body")
        title = extract_field(body, "title")
        subtitle = extract_field(body, "subtitle")
        category = extract_field(body, "category")
        hex_color = extract_hex(body)
        if not (title and subtitle and category and hex_color):
            continue
        projects.append({
            "title": title,
            "subtitle": subtitle,
            "category": category,
            "hex": hex_color,
            "slug": slugify(title),
        })
    return projects


# --- Prompt rendering · HOVER (cinematic) ----------------------------------
# Pure prompt text. No headers, no markdown, no commentary — open file,
# Ctrl+A, Ctrl+C, paste straight into the generator. Pairs with the
# typographic main cover rendered procedurally by `gen_covers.py`.
def render_hover_prompt(p: dict) -> str:
    subject = pick_hover_subject(p["category"])
    return f"""ROLE
You are an art-director generating one cinematic cover image for a
senior software-engineer's portfolio. The cover sits behind a project
title that will be composited later, so the image itself must NOT
contain any letters, digits, words or readable glyphs.

VISUAL LANGUAGE
- Aspect: 16:9, target 1600x900.
- Hero colour: {p["hex"]} as the single dominant emission, set against
  a deep near-black gradient. Treat it like a Christopher Nolan title
  card or a high-end SaaS hero — moody, controlled, premium.
- Composition: rule of thirds, sweeping diagonals, pronounced negative
  space (at least 40% of the frame near-black or low-detail so an
  overlay headline can read cleanly on top later). Keep the upper-
  left quadrant the cleanest.
- Depth: foreground macro geometry, mid-ground volumetric haze or
  light scatter, dark vignetted corners, subtle film grain.
- Texture: faint geometric / line / lattice / strata pattern allowed,
  always low contrast (~10% opacity feel), never busy.
- Lighting: low-angle cinematic, single dominant rim or shaft of light
  in the hero colour, plus deep shadow. No flat illumination.
- Camera: shallow depth of field, slight tilt or off-axis perspective,
  35–50 mm equivalent.

HARD RULES
- NO text, letters, numbers, signs, watermarks, logos, brand marks.
- NO people, faces, hands, body parts, silhouettes of humans.
- NO UI mockups, screenshots, dashboards, code on screens.
- NO AI clichés: glowing brains, hex-grid meshes with neon dots,
  Matrix rain, hooded figures, rotating data-spheres, holographic
  blueprints, robot heads.
- NO stock-photo aesthetic, no clip-art, no flat illustration.
- One image, one film still — not a collage, not a poster, not a
  slideshow grid.

SUBJECT FOR THIS COVER
{subject}

PROJECT
- title: {p["title"]}
- subtitle: {p["subtitle"]}
- category: {p["category"]}
- hero colour (hex): {p["hex"]}

OUTPUT
A single 16:9 photoreal cinematic frame, {p["hex"]} as the dominant
emission, deep near-black negative space, no letters anywhere.
Treat it as a film still, Roger Deakins / Hoyte van Hoytema
cinematography, Kodak 5219 colour science. Quality at maximum.
"""


# --- Prompt rendering · MAIN (minimalist Bauhaus, with typography) ---------
# This is the AI alternative to `tools/gen_covers.py`. It mirrors the
# procedural placeholder's layout: large faded initials watermark,
# foreground title + subtitle + category line, two short accent rules,
# and an optional small abstract glyph for the project's category. The
# image model is responsible for rendering all four text strings legibly.
def render_main_prompt(p: dict) -> str:
    subject = pick_main_subject(p["category"])
    initials = initials_of(p["title"])
    return f"""ROLE
You are an art-director generating one minimalist editorial cover
poster for a senior software-engineer's portfolio. This is graphic
design, not photography — flat colour fields, clean geometric type,
zero atmospheric detail. The poster must include the project's title,
subtitle, category and a large faded watermark of the initials.

LAYOUT (mirror this exact template across every cover)

Background:
- 16:9, target 1600x900.
- Hero colour {p["hex"]} as a smooth diagonal gradient — slightly
  lighter top-left, slightly darker bottom-right.
- A very faint diagonal-line texture is allowed (~8% opacity), never
  busy. A subtle vignette darkening the corners.

Initials watermark (the heroic background element):
- The four letters "{initials}" rendered HUGE in a clean geometric
  sans-serif (DIN, Inter Display, URW Gothic style), all caps.
- White at ~10–14% opacity, very slightly blurred.
- Positioned upper-right or visually centred, occupying roughly 55–
  65% of the frame height. Dominant but quiet.

Foreground typography stack (lower-left, ~6% margin from left edge):
1. Category line — "{p["category"]}" — small uppercase, letter-spaced
   ~3 px, at ~60% white opacity. Sits above the title.
2. Project title — "{p["title"]}" — large bold geometric sans-serif,
   pure white, single line if it fits, two lines otherwise.
3. Subtitle / description — "{p["subtitle"]}" — lighter weight, ~80%
   opacity, wrapped to a maximum of two lines.
4. Two thin horizontal accent rules under the subtitle, ~90 px and
   ~40 px wide, drawn in the hero colour {p["hex"]}.

Abstract accent (small, secondary — never the main subject):
- One small geometric primitive that complements the project's
  category. Placed off-centre, far from the title stack so it never
  competes with the type.
- Always one element only — never a literal illustration.
- Style: {subject}

STYLE
Swiss International Style, Bauhaus, Dieter Rams editorial design.
Flat colour fields. No smoke, no haze, no atmosphere, no grain, no
photo depth, no lens flare. The composition feels like a museum-shop
poster, not a film still.

TEXT — RENDER THESE FOUR STRINGS LITERALLY
- INITIALS (watermark, huge):   "{initials}"
- CATEGORY (small uppercase):   "{p["category"]}"
- TITLE (large foreground):     "{p["title"]}"
- SUBTITLE (smaller, under):    "{p["subtitle"]}"

HARD RULES
- The four strings above MUST appear, spelled exactly as written. Do
  not invent additional copy, numbers, signatures, dates or labels.
- NO people, faces, hands, body parts, silhouettes.
- NO UI mockups, screenshots, dashboards, code-on-screen.
- NO smoke, fog, haze, particles, sparkles, atmospheric scatter.
- NO film grain, ISO noise, dust, scratches.
- NO realistic surface textures (concrete, brushed metal, patina,
  woodgrain, fabric, paper fibre).
- NO photographic depth-of-field, bokeh, lens flare.
- NO cinematic treatment, no film-still framing.
- NO AI clichés: glowing brains, hex-grid meshes with neon dots,
  Matrix rain, hooded figures, rotating data-spheres, holographic
  blueprints, robot heads.
- One composition — no collage, no grid, no multi-panel layout.

PROJECT
- title: {p["title"]}
- subtitle: {p["subtitle"]}
- category: {p["category"]}
- initials: {initials}
- hero colour (hex): {p["hex"]}

OUTPUT
One 16:9 minimalist editorial poster. Hero colour {p["hex"]} as the
gradient background; "{initials}" rendered huge as a faded watermark;
"{p["category"]}", "{p["title"]}" and "{p["subtitle"]}" cleanly set
bottom-left; two short accent rules below; one small abstract glyph
placed quietly elsewhere in the frame. Swiss / Bauhaus / Dieter Rams
sensibility. Quality at maximum.
"""


# --- Entry point ------------------------------------------------------------
def main() -> None:
    projects = parse_projects()
    if not projects:
        raise SystemExit("No projects parsed — check the regex / source path.")
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    HOVER_DIR.mkdir(parents=True, exist_ok=True)
    MAIN_DIR.mkdir(parents=True, exist_ok=True)
    # Remove any previously-emitted variants in either location so the
    # output directories only contain the current bare-text prompts.
    for stale in (
        *OUTPUT_DIR.glob("*.md"),
        *OUTPUT_DIR.glob("*.txt"),
        *HOVER_DIR.glob("*.md"),
        *HOVER_DIR.glob("*.txt"),
        *MAIN_DIR.glob("*.md"),
        *MAIN_DIR.glob("*.txt"),
    ):
        stale.unlink()
    for p in projects:
        (HOVER_DIR / f"{p['slug']}.txt").write_text(render_hover_prompt(p))
        (MAIN_DIR / f"{p['slug']}.txt").write_text(render_main_prompt(p))
        print(f"  {p['slug']:46s} {p['hex']}  -> hover/ + main/")
    print(
        f"\nWrote {len(projects)} hover prompts to {HOVER_DIR.relative_to(ROOT)}/ "
        f"and {len(projects)} main prompts to {MAIN_DIR.relative_to(ROOT)}/."
    )


if __name__ == "__main__":
    main()
