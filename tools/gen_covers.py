#!/usr/bin/env python3
"""Generate the *background* cover image for every portfolio project.

Each cover is a 1600x900 WebP @ quality 90 with XMP + EXIF metadata
(title, description, creator, copyright, keywords). The composition is
deliberately graphic-design / Swiss-style rather than photographic:

  1. Diagonal hero-colour gradient — base.
  2. Soft radial glow centred upper-right in the hero colour, blurred.
  3. Faint constellation of ~120 random small dots — atmosphere.
  4. A category-driven abstract illustration (orbiting circles for
     cloud, scattered dots-with-beam for AI search, stacked rectangles
     for legal evidence, etc.) drawn in a paler tone of the hero colour.
  5. Faint diagonal-line texture, very low contrast.
  6. Soft elliptical vignette.

No typography is baked in any more. The project title / subtitle /
category are rendered live by Flutter on top of this background so the
overlay is language-aware and pixel-sharp at any zoom — and the
background can slowly zoom in/out beneath static text for a calm
cinematic ambience.

Reads `lib/data/projects.dart` for title / subtitle / category /
technologyUsed / primaryColor / asset-folder of every project. Metadata
uses the canonical English fields (search engines see EN; the visible
text is rendered live). Writes ONE file per project:

  * `assets/images/projects/<folder>/cover.webp`    — text-less background

Any pre-existing `cover-de.webp` from earlier runs is left in place as
an orphan; Flutter no longer references it. A leftover `cover.png` from
even older runs is removed. The projects.dart helper at the bottom
rewrites every `image:` / `coverUrl:` reference so the dart side stays
in sync.
"""
from __future__ import annotations

import html
import math
import random
import re
import textwrap
from datetime import datetime
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "lib" / "data" / "projects.dart"
OUT_ROOT = ROOT / "assets" / "images" / "projects"

FONTS = ROOT / "assets" / "fonts"
TITLE_FONT_CANDIDATES = [
    FONTS / "urw-gothic" / "URWGothic-Demi.otf",
    FONTS / "visuelt" / "VisueltPro-Bold.ttf",
    "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
]
SUBTITLE_FONT_CANDIDATES = [
    FONTS / "inter" / "Inter-Light.ttf",
    FONTS / "inter" / "Inter-Regular.ttf",
    "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
]
CATEGORY_FONT_CANDIDATES = [
    FONTS / "inter" / "Inter-Medium.ttf",
    FONTS / "inter" / "Inter-Regular.ttf",
    "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
]

W, H = 1600, 900
WEBP_QUALITY = 90
WEBP_METHOD = 6
PORTFOLIO_BASE_URL = "https://www.burakbasci.de"


# --- Colour helpers --------------------------------------------------------
def hex_to_rgb(h: str) -> tuple[int, int, int]:
    h = h.lstrip("#")
    return tuple(int(h[i : i + 2], 16) for i in (0, 2, 4))  # type: ignore


def darken(rgb, factor):
    return tuple(max(0, int(c * factor)) for c in rgb)


def lighten(rgb, factor):
    return tuple(min(255, int(c + (255 - c) * factor)) for c in rgb)


def _load_font(candidates, size):
    for c in candidates:
        try:
            return ImageFont.truetype(str(c), size=size)
        except (OSError, IOError):
            continue
    return ImageFont.load_default()


# --- Background layers -----------------------------------------------------
def diagonal_gradient(top_left, bottom_right):
    img = Image.new("RGB", (W, H), top_left)
    px = img.load()
    diag = math.hypot(W, H)
    for y in range(H):
        for x in range(0, W, 2):
            t = (x + y) / diag
            r = int(top_left[0] * (1 - t) + bottom_right[0] * t)
            g = int(top_left[1] * (1 - t) + bottom_right[1] * t)
            b = int(top_left[2] * (1 - t) + bottom_right[2] * t)
            px[x, y] = (r, g, b)
            if x + 1 < W:
                px[x + 1, y] = (r, g, b)
    return img


def add_diagonal_lines(img, color, spacing=220, alpha=14):
    overlay = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    for i in range(-H, W + H, spacing):
        draw.line([(i, 0), (i + H, H)], fill=(*color, alpha), width=2)
    return Image.alpha_composite(img.convert("RGBA"), overlay).convert("RGB")


def add_radial_glow(img, color, cx, cy, radius, max_alpha=90):
    """Soft hero-colour glow centred at (cx, cy). Implemented as a stack of
    blurred concentric circles to approximate a radial gradient."""
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    steps = 32
    for i in range(steps, 0, -1):
        r = int(radius * (i / steps))
        a = int(max_alpha * (1 - i / steps) ** 2.4)
        draw.ellipse((cx - r, cy - r, cx + r, cy + r), fill=(*color, a))
    layer = layer.filter(ImageFilter.GaussianBlur(radius=24))
    return Image.alpha_composite(img.convert("RGBA"), layer).convert("RGB")


def add_particles(img, color, n=120, seed=0):
    """Scatter small dots across the frame in the hero colour, randomised
    per-project so each cover gets a unique constellation but the
    procedural generation is deterministic for a given seed."""
    rng = random.Random(seed)
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    for _ in range(n):
        x = rng.randint(40, W - 40)
        y = rng.randint(40, H - 40)
        radius = rng.choice([1, 1, 1, 2, 2, 3])
        alpha = rng.randint(40, 110)
        draw.ellipse((x - radius, y - radius, x + radius, y + radius), fill=(*color, alpha))
    return Image.alpha_composite(img.convert("RGBA"), layer).convert("RGB")


def add_vignette(img, strength=0.55):
    overlay = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    cx, cy = W // 2, H // 2
    max_d = math.hypot(cx, cy)
    for r in range(int(max_d), 0, -8):
        a = int(strength * 255 * (r / max_d) ** 3)
        draw.ellipse(
            [cx - r, cy - r * 0.7, cx + r, cy + r * 0.7],
            outline=(0, 0, 0, a),
            width=4,
        )
    return Image.alpha_composite(img.convert("RGBA"), overlay).convert("RGB")


# --- Category-driven illustration -----------------------------------------
def category_tokens(category: str) -> set[str]:
    return set(re.findall(r"[A-Z0-9][A-Z0-9.\-]*", category.upper()))


# Each illustration draws into a 720x480 region anchored upper-right of
# the frame. They use the hero colour (paler tones) so they read as
# atmosphere rather than as the dominant element.
def draw_constellation(d, base_color, accent_color):
    """AI / SEARCH / RAG / VECTOR — 12 small dots, one filled, with a
    single thin line connecting it to one other."""
    rng = random.Random(1)
    cx, cy = 1200, 360
    points = []
    for _ in range(13):
        x = cx + rng.randint(-280, 280)
        y = cy + rng.randint(-180, 180)
        points.append((x, y))
        d.ellipse((x - 3, y - 3, x + 3, y + 3), fill=(*base_color, 150))
    # Filled focal point + a single connecting line to one other point.
    fx, fy = points[3]
    tx, ty = points[8]
    d.line((fx, fy, tx, ty), fill=(*accent_color, 130), width=2)
    d.ellipse((fx - 9, fy - 9, fx + 9, fy + 9), fill=(*accent_color, 220))


def draw_orbiting_circles(d, base_color, accent_color):
    """KUBERNETES / CLOUD — three concentric/orbital circles, central one
    filled in the accent colour, others as thin outlines."""
    cx, cy = 1200, 360
    radii = [160, 220, 300]
    for i, r in enumerate(radii):
        d.ellipse((cx - r, cy - r, cx + r, cy + r),
                  outline=(*base_color, 80 + 30 * i), width=2)
    d.ellipse((cx - 60, cy - 60, cx + 60, cy + 60), fill=(*accent_color, 200))


def draw_monumental_block(d, base_color, accent_color):
    """SELF-HOSTED / EDGE / IOT / INFRA — one solid rectangle with a thin
    vertical accent line down its right edge."""
    x0, y0, x1, y1 = 980, 130, 1480, 580
    d.rectangle((x0, y0, x1, y1), outline=(*base_color, 120), width=2,
                fill=(*base_color, 30))
    d.line((x1 - 6, y0, x1 - 6, y1), fill=(*accent_color, 220), width=4)


def draw_building_silhouette(d, base_color, accent_color):
    """3D / REAL-ESTATE / PROPTECH — tall rectangle (building) with a
    small lit window square inside."""
    x0, y0, x1, y1 = 1080, 90, 1340, 620
    d.rectangle((x0, y0, x1, y1), outline=(*base_color, 120), width=2)
    # The lit "window"
    wx, wy = x0 + 80, y0 + 380
    d.rectangle((wx, wy, wx + 90, wy + 90), fill=(*accent_color, 220))


def draw_stacked_strata(d, base_color, accent_color):
    """LEGAL / EVIDENCE — three thin horizontal rectangles stacked with
    small vertical offsets, topmost in accent colour."""
    bars = [(960, 220, 1480, 270),
            (940, 320, 1460, 370),
            (920, 420, 1440, 470)]
    for i, (x0, y0, x1, y1) in enumerate(bars):
        if i == 0:
            d.rectangle((x0, y0, x1, y1), fill=(*accent_color, 200))
        else:
            d.rectangle((x0, y0, x1, y1), outline=(*base_color, 110), width=2)


def draw_folded_paper(d, base_color, accent_color):
    """DOCUMENTS — two overlapping rectangles folded along a sharp
    diagonal crease drawn in the hero colour."""
    d.polygon([(960, 130), (1460, 130), (1460, 530), (960, 530)],
              outline=(*base_color, 130), width=2)
    d.polygon([(1010, 180), (1510, 180), (1510, 580), (1010, 580)],
              outline=(*base_color, 130), width=2)
    d.line((960, 530, 1510, 180), fill=(*accent_color, 220), width=3)


def draw_machined_component(d, base_color, accent_color):
    """ROBOTICS — one circle and one small square placed off-centre."""
    d.ellipse((1080, 200, 1320, 440), outline=(*base_color, 130), width=3)
    d.rectangle((1340, 380, 1480, 520), fill=(*accent_color, 220))


def draw_stage(d, base_color, accent_color):
    """VR / HEALTHCARE — small circle low in the frame with a concentric
    ring in the accent colour."""
    cx, cy = 1280, 440
    for i, r in enumerate([170, 130]):
        ring_color = accent_color if i == 0 else base_color
        d.ellipse((cx - r, cy - r, cx + r, cy + r),
                  outline=(*ring_color, 140 - i * 40), width=3)
    d.ellipse((cx - 24, cy - 24, cx + 24, cy + 24), fill=(*accent_color, 220))


def draw_game_arc(d, base_color, accent_color):
    """GAME / UNREAL / ITCH.IO — a bold geometric arc / triangle."""
    d.polygon([(1100, 540), (1260, 220), (1420, 540)],
              outline=(*base_color, 130), width=2, fill=(*accent_color, 35))
    d.line((1100, 540, 1420, 540), fill=(*accent_color, 220), width=4)


def draw_strata_lines(d, base_color, accent_color):
    """SAAS / AI / AUTOMATION / B2B / OPS — three thin parallel horizontal
    lines, topmost in accent colour."""
    for i, y in enumerate([220, 320, 420]):
        x0 = 960 + i * 24
        x1 = 1480
        if i == 0:
            d.rectangle((x0, y, x1, y + 6), fill=(*accent_color, 220))
        else:
            d.line((x0, y + 3, x1, y + 3), fill=(*base_color, 120), width=2)


def draw_sparse_network(d, base_color, accent_color):
    """SALES / OUTREACH / BROWSER / SCRAPING — three dots connected by
    thin lines, one filled in the accent colour."""
    nodes = [(1000, 220), (1380, 280), (1180, 460), (1450, 480)]
    for x, y in nodes:
        d.ellipse((x - 6, y - 6, x + 6, y + 6), outline=(*base_color, 160), width=2)
    d.line((nodes[0][0], nodes[0][1], nodes[1][0], nodes[1][1]),
           fill=(*base_color, 80), width=1)
    d.line((nodes[1][0], nodes[1][1], nodes[3][0], nodes[3][1]),
           fill=(*base_color, 80), width=1)
    d.line((nodes[0][0], nodes[0][1], nodes[2][0], nodes[2][1]),
           fill=(*base_color, 80), width=1)
    fx, fy = nodes[0]
    d.ellipse((fx - 10, fy - 10, fx + 10, fy + 10), fill=(*accent_color, 220))


def draw_orbital_token(d, base_color, accent_color):
    """WEB3 / CHARITY — central circle with a single thin orbital ring."""
    cx, cy = 1240, 360
    d.ellipse((cx - 240, cy - 240, cx + 240, cy + 240),
              outline=(*accent_color, 160), width=3)
    d.ellipse((cx - 60, cy - 60, cx + 60, cy + 60), fill=(*base_color, 180))


def draw_voice_wave(d, base_color, accent_color):
    """VOICE / STT / TTS — thin horizontal line through the centre with
    an accent segment near the right end."""
    y = 360
    d.line((980, y, 1480, y), fill=(*base_color, 130), width=2)
    d.line((1340, y, 1480, y), fill=(*accent_color, 220), width=4)


def draw_package_cube(d, base_color, accent_color):
    """E-COMMERCE / PACKAGE / TOOL — small isometric cube."""
    cx, cy = 1240, 360
    s = 130
    # Top face
    d.polygon([(cx, cy - s), (cx + s, cy - s // 2), (cx, cy), (cx - s, cy - s // 2)],
              outline=(*base_color, 140), width=2, fill=(*accent_color, 80))
    # Left face
    d.polygon([(cx - s, cy - s // 2), (cx, cy), (cx, cy + s), (cx - s, cy + s // 2)],
              outline=(*base_color, 140), width=2)
    # Right face
    d.polygon([(cx, cy), (cx + s, cy - s // 2), (cx + s, cy + s // 2), (cx, cy + s)],
              outline=(*base_color, 140), width=2, fill=(*accent_color, 200))


def draw_mobile_outline(d, base_color, accent_color):
    """MOBILE — tall rounded rectangle with a small lit square inside."""
    x0, y0, x1, y1 = 1150, 130, 1340, 590
    d.rounded_rectangle((x0, y0, x1, y1), radius=24,
                        outline=(*base_color, 140), width=3)
    d.rectangle((x0 + 50, y0 + 60, x0 + 140, y0 + 150), fill=(*accent_color, 220))


def draw_web_window(d, base_color, accent_color):
    """WEB / THEATRE — outlined rectangle with a small inner square."""
    x0, y0, x1, y1 = 980, 160, 1480, 560
    d.rectangle((x0, y0, x1, y1), outline=(*base_color, 130), width=2)
    d.rectangle((x0 + 60, y0 + 60, x0 + 180, y0 + 180), fill=(*accent_color, 220))


def draw_diagonal_line(d, base_color, accent_color):
    """META / PORTFOLIO — a single thin diagonal line."""
    d.line((960, 540, 1500, 180), fill=(*accent_color, 220), width=4)


ILLUSTRATIONS = [
    ({"LEGAL", "EVIDENCE"}, draw_stacked_strata),
    ({"DOCUMENTS", "DOCUMENT"}, draw_folded_paper),
    ({"ROBOTICS"}, draw_machined_component),
    ({"VR", "HEALTHCARE"}, draw_stage),
    ({"GAME", "UNREAL", "ITCH.IO"}, draw_game_arc),
    ({"SELF-HOSTED", "EDGE", "IOT", "INFRA", "PROXMOX"}, draw_monumental_block),
    ({"KUBERNETES", "CLOUD"}, draw_orbiting_circles),
    ({"3D", "PROPERTY", "REAL-ESTATE", "PROPTECH"}, draw_building_silhouette),
    ({"SEARCH", "RAG", "VECTOR"}, draw_constellation),
    ({"VOICE", "STT", "TTS"}, draw_voice_wave),
    ({"E-COMMERCE", "COMMERCE", "PRINT-ON-DEMAND", "PACKAGE", "TOOL"}, draw_package_cube),
    ({"SALES", "OUTREACH", "BROWSER", "SCRAPING"}, draw_sparse_network),
    ({"WEB3", "CHARITY"}, draw_orbital_token),
    ({"WEB"}, draw_web_window),
    ({"DEVSECOPS"}, draw_orbiting_circles),
    ({"SAAS", "AI", "AUTOMATION", "B2B", "OPERATIONS", "OPS", "FINANCE"},
        draw_strata_lines),
    ({"MOBILE"}, draw_mobile_outline),
    ({"META", "PORTFOLIO"}, draw_diagonal_line),
]


def add_category_illustration(img, base_color, accent_color, category):
    tokens = category_tokens(category)
    fn = None
    for keys, drawfn in ILLUSTRATIONS:
        if tokens & keys:
            fn = drawfn
            break
    if fn is None:
        fn = draw_constellation
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    fn(d, base_color, accent_color)
    return Image.alpha_composite(img.convert("RGBA"), layer).convert("RGB")


# --- Foreground typography -------------------------------------------------
def add_title_block(img, title, subtitle, category, accent):
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)

    # Extra-generous left margin so neither the category line nor the
    # title visually flirt with the frame edge, even at small render
    # sizes (e.g. when the cover is shown thumbnail-sized in a tile).
    margin_x = 120
    base_y = int(H * 0.58)

    # Category line first (small, uppercase, letter-spaced)
    category_font = _load_font(CATEGORY_FONT_CANDIDATES, size=18)
    cat_text = category.upper()
    # Manually add letter-spacing by drawing one character at a time.
    cat_y = base_y
    cursor = margin_x
    for char in cat_text:
        bbox = draw.textbbox((cursor, cat_y), char, font=category_font)
        draw.text((cursor, cat_y), char, font=category_font, fill=(255, 255, 255, 165))
        cursor = bbox[2] + 4
    base_y += 40

    # Title — auto-shrink if it's too wide for the left two-thirds.
    title_font = _load_font(TITLE_FONT_CANDIDATES, size=64)
    max_title_w = int(W * 0.66)
    while True:
        bbox = draw.textbbox((0, 0), title, font=title_font)
        if bbox[2] - bbox[0] <= max_title_w or title_font.size <= 28:
            break
        title_font = _load_font(TITLE_FONT_CANDIDATES, size=title_font.size - 2)
    draw.text((margin_x, base_y), title, font=title_font, fill=(255, 255, 255, 255))
    title_bbox = draw.textbbox((margin_x, base_y), title, font=title_font)
    next_y = title_bbox[3] + 16

    # Subtitle — wrapped at ~64 chars wide, max two lines.
    subtitle_font = _load_font(SUBTITLE_FONT_CANDIDATES, size=22)
    if subtitle:
        for line in textwrap.wrap(subtitle, width=68)[:2]:
            draw.text((margin_x, next_y), line, font=subtitle_font,
                      fill=(255, 255, 255, 200))
            lbb = draw.textbbox((margin_x, next_y), line, font=subtitle_font)
            next_y = lbb[3] + 4

    # Two short accent rules in the hero colour.
    rule_y = next_y + 24
    draw.rectangle((margin_x, rule_y, margin_x + 92, rule_y + 3),
                   fill=(*accent, 255))
    draw.rectangle((margin_x, rule_y + 12, margin_x + 44, rule_y + 14),
                   fill=(255, 255, 255, 110))

    return Image.alpha_composite(img.convert("RGBA"), layer).convert("RGB")


# --- SEO metadata (same shape as install_hover_covers.py) ------------------
def build_xmp(p, *, title_text=None, subtitle_text=None, category_text=None):
    """XMP packet. When the optional *_text args are supplied (e.g. when
    rendering the German variant) those strings are baked into the
    metadata instead of the canonical English ones so DE assets ship DE
    keywords / titles to search engines."""
    title_text = title_text if title_text is not None else p["title"]
    subtitle_text = subtitle_text if subtitle_text is not None else p["subtitle"]
    category_text = category_text if category_text is not None else p["category"]
    year = datetime.now().year
    keywords = ["Burak Basci", "portfolio", "software engineering"]
    keywords += [t.strip() for t in re.split(r"[/·,]+", category_text) if t.strip()]
    keywords += [
        t.strip()
        for t in re.split(r"·|,|\s·\s|\s—\s", p["tech"])
        if t.strip() and 1 < len(t.strip()) < 40
    ][:8]
    seen = set()
    keywords = [k for k in keywords if not (k.lower() in seen or seen.add(k.lower()))]
    title = html.escape(title_text)
    description = html.escape(f"{subtitle_text} — Portfolio cover by Burak Basci.")
    source = html.escape(f"{PORTFOLIO_BASE_URL}/projects/{p['slug']}")
    keyword_xml = "\n     ".join(f"<rdf:li>{html.escape(k)}</rdf:li>" for k in keywords)
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


def build_exif(p, *, title_text=None, subtitle_text=None):
    """EXIF bytes. Uses the supplied (e.g. German) title/subtitle when
    provided so per-language covers carry per-language metadata."""
    title_text = title_text if title_text is not None else p["title"]
    subtitle_text = subtitle_text if subtitle_text is not None else p["subtitle"]
    exif = Image.Exif()
    exif[270] = f"{title_text} — {subtitle_text}"
    exif[305] = "burakbasci.de cover pipeline"
    exif[315] = "Burak Basci"
    exif[33432] = f"© {datetime.now().year} Burak Basci. All rights reserved."
    return exif.tobytes()


# --- Render one cover ------------------------------------------------------
def _render_background(p):
    """Build the language-agnostic background image (gradient, glow,
    particles, illustration, diagonal lines, vignette). Returns an RGB
    Image without any baked text yet — `render_cover` then composites
    the typography on top once per language."""
    base = hex_to_rgb(p["hex"])
    top = lighten(base, 0.14)
    bottom = darken(base, 0.50)
    pale = lighten(base, 0.55)
    accent = lighten(base, 0.30)

    img = diagonal_gradient(top, bottom)
    img = add_radial_glow(img, lighten(base, 0.35), cx=1180, cy=320, radius=560, max_alpha=110)
    seed = sum(ord(c) for c in p["slug"])
    img = add_particles(img, pale, n=140, seed=seed)
    img = add_category_illustration(img, pale, accent, p["category"])
    img = add_diagonal_lines(img, pale, spacing=220, alpha=12)
    img = add_vignette(img, strength=0.62)
    return img, accent


def render_cover(p):
    """Bake the single text-less background cover for one project.

    The image is pure background (gradient + glow + particles +
    category illustration + diagonal lines + vignette) — title,
    subtitle and category are rendered live on top by Flutter, so a
    single file serves every language and the text stays pixel-sharp
    at any zoom. Returns a list with the one output path written."""
    out_dir = OUT_ROOT / p["folder"]
    out_dir.mkdir(parents=True, exist_ok=True)

    # Single text-less background. Metadata uses the English fields —
    # search engines see EN; the visible text is rendered live in Flutter.
    bg, _accent = _render_background(p)
    out_path = out_dir / "cover.webp"
    bg.save(out_path, format="WEBP", quality=WEBP_QUALITY,
            method=WEBP_METHOD, xmp=build_xmp(p), exif=build_exif(p))

    # Legacy PNG from very early runs — still cleaned up. The orphan
    # `cover-de.webp` from the previous baked-DE run is intentionally
    # left in place (Flutter no longer references it).
    legacy_png = out_dir / "cover.png"
    if legacy_png.exists():
        legacy_png.unlink()

    return [out_path]


# --- projects.dart parsing + rewrite --------------------------------------
def _iter_project_blocks(src):
    """Yield the body of each `ProjectItemData(...)` literal in `src`.
    Uses manual paren counting so arbitrarily deep nesting (e.g. the
    `translations: const <String, ProjectTranslation>{'de': ProjectTranslation(...)}`
    that lives inside every entry now) is handled correctly. Skips
    parens inside Dart string literals."""
    needle = "ProjectItemData("
    i = 0
    while True:
        start = src.find(needle, i)
        if start == -1:
            return
        body_start = start + len(needle)
        depth = 1
        j = body_start
        in_str = False
        str_quote = ""
        while j < len(src):
            c = src[j]
            if in_str:
                if c == "\\":
                    j += 2
                    continue
                if c == str_quote:
                    in_str = False
            else:
                if c == "'" or c == '"':
                    in_str = True
                    str_quote = c
                elif c == "(":
                    depth += 1
                elif c == ")":
                    depth -= 1
                    if depth == 0:
                        yield src[body_start:j]
                        i = j + 1
                        break
            j += 1
        else:
            return  # ran off the end without closing


def _string_field(body, field):
    pattern = re.compile(rf"{field}:\s*((?:'(?:[^'\\]|\\.)*'\s*)+)", re.DOTALL)
    m = pattern.search(body)
    if not m:
        return None
    pieces = re.findall(r"'((?:[^'\\]|\\.)*)'", m.group(1), re.DOTALL)
    return "".join(pieces).replace(r"\'", "'")


def _folder_field(body):
    m = re.search(r"image:\s*'\$_d/([^/]+)/cover\.(?:png|webp)'", body)
    return m.group(1) if m else None


def _slugify(text):
    t = text.lower()
    t = re.sub(r"[^a-z0-9\s-]", "", t)
    t = re.sub(r"\s+", "-", t)
    return re.sub(r"-+", "-", t).strip("-")


def _extract_hex(body):
    m = re.search(r"primaryColor:\s*const\s+Color\(0x(?:FF|ff)([0-9A-Fa-f]{6})\)", body)
    return ("#" + m.group(1).upper()) if m else None


def _extract_de_translation(body):
    """Drill into `translations: const <String, ProjectTranslation>{'de':
    ProjectTranslation(...body...)}` and return a dict with the German
    title / subtitle / category / platform (any subset present), or
    None if no `'de'` block is found. The outer literal is `{...}` and
    the inner one is `(...)` — we locate the `'de':` key, then balance
    parens after the following `ProjectTranslation(` to grab its body."""
    key_match = re.search(r"['\"]de['\"]\s*:\s*ProjectTranslation\(", body)
    if not key_match:
        return None
    body_start = key_match.end()
    depth = 1
    j = body_start
    in_str = False
    str_quote = ""
    while j < len(body):
        c = body[j]
        if in_str:
            if c == "\\":
                j += 2
                continue
            if c == str_quote:
                in_str = False
        else:
            if c == "'" or c == '"':
                in_str = True
                str_quote = c
            elif c == "(":
                depth += 1
            elif c == ")":
                depth -= 1
                if depth == 0:
                    inner = body[body_start:j]
                    return {
                        "title": _string_field(inner, "title"),
                        "subtitle": _string_field(inner, "subtitle"),
                        "category": _string_field(inner, "category"),
                        "platform": _string_field(inner, "platform"),
                    }
        j += 1
    return None


def parse_projects():
    src = SOURCE.read_text()
    out = []
    for body in _iter_project_blocks(src):
        title = _string_field(body, "title")
        subtitle = _string_field(body, "subtitle")
        category = _string_field(body, "category")
        tech = _string_field(body, "technologyUsed") or ""
        folder = _folder_field(body)
        hex_color = _extract_hex(body)
        if not (title and subtitle and category and folder and hex_color):
            continue
        out.append({
            "title": title,
            "subtitle": subtitle,
            "category": category,
            "tech": tech,
            "folder": folder,
            "hex": hex_color,
            "slug": _slugify(title),
            "de": _extract_de_translation(body),
        })
    return out


def update_dart_references():
    """Migrate every `image:` / `coverUrl:` / `screenshots:` reference from
    cover.png → cover.webp. coverColorUrl already points at .webp."""
    src = SOURCE.read_text()
    src, n1 = re.subn(r"image: '\$_d/([^/]+)/cover\.png'",
                       r"image: '$_d/\1/cover.webp'", src)
    src, n2 = re.subn(r"coverUrl: '\$_d/([^/]+)/cover\.png'",
                       r"coverUrl: '$_d/\1/cover.webp'", src)
    src, n3 = re.subn(r"'\$_d/([^/]+)/cover\.png'(\s*\])",
                       r"'$_d/\1/cover.webp'\2", src)
    SOURCE.write_text(src)
    print(f"\n  projects.dart: migrated {n1} image:, {n2} coverUrl:, "
          f"{n3} screenshots[] entries from .png → .webp")


# --- Entry point -----------------------------------------------------------
def main():
    projects = parse_projects()
    if not projects:
        raise SystemExit("No projects parsed.")
    OUT_ROOT.mkdir(parents=True, exist_ok=True)
    print(f"Rendering {len(projects)} text-less background covers as "
          f"WebP @ {WEBP_QUALITY}% with XMP + EXIF SEO metadata.\n")
    total_files = 0
    for p in projects:
        paths = render_cover(p)
        for path in paths:
            size_kb = path.stat().st_size // 1024
            print(f"  {p['folder']:18s} {p['hex']}  -> "
                  f"{path.relative_to(ROOT)}  ({size_kb} KB)")
            total_files += 1
    update_dart_references()
    print(f"\nDone. {len(projects)} projects, {total_files} cover files "
          f"refreshed.")


if __name__ == "__main__":
    main()
