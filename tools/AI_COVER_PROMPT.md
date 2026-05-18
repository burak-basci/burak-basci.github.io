# AI cover-image prompt

For projects that have no shippable screenshot or that can't be published
verbatim (NDA, client work, CLI-only tools), use the prompt block below to
generate a cinematic abstract cover that matches the rest of the site's
visual language. The title and subtitle are *not* drawn by the AI — they
get composited over the image later by `tools/gen_covers.py`, which
already handles typography reliably. The AI only renders the background.

> **Per-project ready-to-paste prompts** live in `tools/ai_prompts/*.md`,
> one file per portfolio entry, each pre-filled with that project's
> title, subtitle, category and hero colour, plus a subject recipe
> matched to its category. Regenerate them with
> `python3 tools/gen_ai_prompts.py` whenever `lib/data/projects.dart`
> changes.

## How to use it

1. Copy the **Master Prompt** block.
2. Fill the `<PASTE …>` fields under `PROJECT` with values from
   `lib/data/projects.dart` (title, subtitle, category, `primaryColor`).
3. Run it through your generator of choice. Suggested settings:
   - **Midjourney**: append `--ar 16:9 --style raw --q 2`.
   - **FLUX / SD / SDXL**: paste the `Negative prompt` block into the
     negative-prompt field; keep guidance around 6–8, ~28 steps.
   - **DALL·E 3 / Imagen**: paste the master prompt as-is; it already
     contains the structural guidance these models follow well.
4. Generate four variants, pick the one with **the most near-black
   negative space in the upper-left quadrant** — that's where the title
   overlay sits later, so the title needs a clean, low-contrast bed.
5. Output to **PNG, 1600×900**. If the generator outputs a different
   resolution (Midjourney 1456×816, SDXL 1344×768), upscale to exactly
   1600×900 with Real-ESRGAN (`realesr-general-x4v3`, denoise 0) — that
   pipeline is already running for the e-commerce shop project.
6. Drop the result in `assets/images/projects/<slug>/cover.png` and
   register the folder in `pubspec.yaml`. The title typography is then
   added by `tools/gen_covers.py` in "overlay mode" (see *Layered
   workflow* below).

## Master prompt

```text
ROLE
You are an art-director generating a single cinematic cover image for a
senior software-engineer's portfolio. The cover sits behind a project
title that will be composited in later, so the image itself must NOT
contain any letters, digits, words or readable glyphs.

VISUAL LANGUAGE (consistent across every cover)
- Aspect: 16:9, target 1600x900.
- Hero colour: ONE dominant brand colour (see PROJECT block below),
  surrounded by a deep near-black gradient. Treat it like a Christopher
  Nolan title card or a high-end SaaS hero — moody, controlled, premium.
- Composition: rule of thirds, sweeping diagonals, pronounced negative
  space (at least 40% of the frame should be near-black or low-detail
  so an overlay headline reads cleanly later).
- Depth: foreground macro geometry, mid-ground volumetric haze or light
  scatter, dark vignetted corners, subtle film grain.
- Texture: faint geometric / line / lattice / strata pattern allowed,
  always low contrast (~10% opacity feel), never busy.
- Lighting: low-angle, cinematic, single dominant rim or shaft of light
  in the hero colour, plus deep shadow. No flat illumination.
- Camera: shallow depth of field, slight tilt or off-axis perspective,
  35–50 mm equivalent.

HARD RULES (do not violate)
- NO text, letters, numbers, signs, watermarks, logos, brand marks.
- NO people, faces, hands, body parts, silhouettes of humans.
- NO UI mockups, screenshots, dashboards, code on screens.
- NO "AI-cliché" tropes: glowing brain icons, hexagonal network meshes
  with neon dots, "Matrix" rain, hooded figures, generic robot heads,
  rotating data-spheres, holographic blueprints.
- NO stock-photo aesthetic, no clip-art, no flat illustration.
- Output is a single hero image, treated as a film still — not a
  collage, not a poster, not a slideshow grid.

SUBJECT MATTER MAP (pick the closest match to the project's category)
- Cloud / Kubernetes / DevSecOps   → orbiting solid masses with subtle
  gravitational geometry; clean industrial materials; engineered scale.
- Self-hosted Linux / sovereign infra → a single monumental architectural
  object in deep shadow; cold metallic light; quiet, immovable.
- AI search / RAG / vector DB → constellation of fine points across the
  frame, occasional drawn light-beams between two of them, vast negative
  space; like looking at distant signal in a dark room.
- LLM mail / triage / automation → strata of layered translucent planes,
  one rising through the others, soft directional light.
- Real-estate / property / 3D tours → an architectural silhouette half
  in shadow, a single window or aperture lit in the hero colour, ground
  plane fog. Read as "premises", never as a literal building photo.
- Legal / evidence / forensic → stacked paper-toned strata in low
  slanting light, a single sealed edge, sense of weight and consequence.
- Voice / STT / on-device AI → horizontal mist layers, soft waveform
  ridges suggested by light, never literal soundwaves.
- Game (Unreal / FPS / platformer / cards) → cinematic landscape of the
  game's own world: brutalist arena for an FPS, warm dusk for a flyer,
  close-up wood grain + folded fabric for a card game.
- Document automation / invoicing → clean folded paper strata, ink-like
  shadows, a single sharp crease lit in the hero colour.
- Browser-extension / outreach / sales tools → sparse field of distant
  lit points connected by faint vectors, mostly dark, one stronger node
  in the foreground.
- E-commerce / generation pipeline → product-still language: a single
  hero object in the centre, deep set, dramatic single-source lighting.
- Smart-home / IoT / edge → architectural interior at night, a single
  window or panel glowing in the hero colour, no people, no devices.
- VR / AR → empty stage seen through soft volumetric light, a single
  marker on the floor in the hero colour.
- Robotics / synthetic data → a precise machined component half-lit,
  sense of engineered intent, never literal robots.

TECHNICAL OUTPUT
- 1600 x 900 pixels (16:9). If the generator only takes ratios, use
  --ar 16:9. Quality at max (Midjourney --q 2 / FLUX dev / SD high
  guidance, ~28 steps).
- Render as a photoreal cinematic still — not illustration, not
  cartoon, not 3D-render-default. If unsure, lean toward "film still,
  cinematography, Roger Deakins / Hoyte van Hoytema, Kodak 5219".

Negative prompt (pass directly to FLUX / SD / SDXL):
  text, watermark, signature, letters, words, glyphs, logo, person,
  face, hand, fingers, robot, hologram, blueprint, network mesh,
  hexagons, glowing brain, matrix rain, neon grid, lens-flare overkill,
  stock photo, ui mockup, screenshot, dashboard, infographic, clip art,
  illustration, low detail, blurry, low contrast in foreground, busy
  corners.

PROJECT
- title: <PASTE TITLE>
- subtitle: <PASTE SUBTITLE>
- category: <PASTE CATEGORY>
- hero colour (hex): <PASTE PRIMARY HEX>
- key associations / objects to evoke (optional, 3–6 short words):
  <PASTE — e.g. "k3s, GitOps, sovereign, Hetzner, EU">
- mood (optional, one short phrase):
  <PASTE — e.g. "quiet engineered confidence">

PRODUCE
A single 16:9 cinematic frame, hero colour dominant, near-black
negative space, no letters anywhere in the image.
```

## Layered workflow (AI background + Python title overlay)

To get consistent, perfectly-set typography on every cover without
asking the image generator to render text (which it always botches),
keep the prompt above as a **background-only** prompt and let
`tools/gen_covers.py` compose the title on top in a second step.

The existing `tools/gen_covers.py` paints a procedural gradient and
overlays the title text. A future extension can take an optional
`--background <path-to-png>` argument: when present, the script skips
the gradient/lines/wordmark routine and uses the supplied AI image as
the bottom layer instead, then composes the same accent rules and
title typography on top. The Python script remains the single source of
truth for type, layout, weight and accent rules across every cover; the
AI just provides the cinematography.

When you decide which covers should be AI-backed instead of
typographic-placeholder, name them in a list and I'll add the
`--background` flag end-to-end.
