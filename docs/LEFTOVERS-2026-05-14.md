# burakbasci.de — Open follow-ups

Last updated: **2026-05-14**

## Recent fix round (in response to "all the animation issues come from David Cobbina; my repo is far superior")

You were right — I had rewritten `lib/widgets/project_item.dart` from scratch
with a "simpler" Row layout, which dropped the original cascading-Stack
design, all the hover animations, and the ability to click into project
detail pages. Reverted that overreach.

What changed in this round (commit `c4a67fb` on the source side; rebuilt
into the live repo):

- ✅ `useMaterial3: false` on the theme — keeps Material 2 ink ripples,
  default button padding, scrollbar widths, and elevation. This was the
  root cause of the **top-nav-bar hover drift**, the **bigger white
  spacing below**, and the subtle animation timing issues.
- ✅ Restored the upstream `ProjectItemLarge` / `ProjectItemSm` /
  `ProjectData` / `NextProject` widgets 1:1 — image slide-in on hover,
  animated coloured accent container, bubble button, the lot. The only
  diff from upstream is the M3 TextTheme name migration that the new
  Flutter SDK requires (`headline4` → `headlineMedium` etc.).
- ✅ Restored `ProjectDetailPage` with the original gallery layout and
  wired it into `RouteConfiguration`. Project cards are clickable
  again. Also restored `WorksPage` and `NoteWorthyProjects` (kept
  available, not yet in the nav menu).
- ✅ Restored the home page's cascading-Stack layout with the "There's
  more / view all projects" link below the showcase.
- ✅ Side-title fix: `TopNavigationBar`'s side title used
  `AnimatedTextSlideBoxTransition` whose cover-box ends as a light-grey
  (`AppColors.primaryColor`) rectangle. Invisible on the light page,
  but visible against the dark footer — the "white box behind
  EXPERIENCE on the dark footer" bug. Set `boxColor: Colors.transparent`
  and `coverColor: Colors.transparent` for the side title only, so the
  text renders straight on the page background.
- ✅ Experience page now reads from a dynamically-sized controller list
  and shows 5 positions (newest first) from the current resume:
  Freelance DevSecOps · VW Patent Search · Utopia Web3 · TU Dortmund
  Robotics · Multiplayer Card Game.
- ✅ About story rewritten as "Technical Product Owner + DevSecOps"
  with the Industrial Engineering / Psychology dual background. Tech
  lists refreshed: programming languages, applications (k8s,
  Terraform, ArgoCD, FastAPI, Django, ElasticSearch…), and other
  software (RAG, vector DBs, synthetic data, SRE, etc.).
- ✅ Project data replaced 1:1 with your real projects, using the full
  upstream `ProjectItemData` shape so the original widgets work
  unchanged. 11 projects total; home highlights the top 6.

What's likely still off and worth a sanity check in your real browser:
- The "white line on opening" — should be fixed by `useMaterial3:false`
  (the line came from M3's default `LoadingSlider` ink behaviour). If
  you still see it, the next step is to instrument `LoadingSlider` and
  pin down the offending paint.
- The "Experience" centering — appears centered to me in screenshots
  (centre of text at x=721 of 1440 viewport = pixel-perfect). If you
  still see drift in your browser, screenshot it and I can chase the
  remaining 1-2 px.
- Per-project cover artwork is still the generated gradient placeholder.
  Real screenshots from `/home/burak/drive/Projects/Flutter/Durak/Design/Screenshots/`,
  `…/utopia_community/assets/banner/`, `…/CaterSmart/screenshots/`,
  and the Unreal thesis renders would lift the look a lot.

---

This file tracks everything left to do on the portfolio-site rebuild so you
don't have to scroll through chat. Claude will keep editing this file as
state changes; feel free to edit by hand and Claude will respect what you
wrote.

---

## TL;DR — what's currently true

- Source repo: `Branding/burak_basci_website/` — has 2 unpushed commits.
- Live repo: `Branding/burak-basci.github.io/` — has 1 unpushed commit
  containing a fresh build of the site (Firebase-free, brand fonts, projects
  showcase).
- Local preview running at **http://localhost:18080** (Podman container
  `bbweb-test`). To stop: `podman rm -f bbweb-test`. To restart:
  `podman run -d --rm --name bbweb-test -p 18080:80 -v "/home/burak/Desktop/Work/Formalia/Branding/burak_basci_website/build/web:/usr/share/nginx/html:ro,Z" docker.io/library/nginx:alpine`
- Flutter is **not** installed on the host. Everything builds inside
  `ghcr.io/cirruslabs/flutter:stable` (Flutter 3.41.9 / Dart 3.11.5).

---

## 1. Push the commits to GitHub  ⚠️ blocking

Both repos have HTTPS remotes with no cached credentials. Pick one:

**(a) Switch to SSH** — your `~/.ssh/id_ed25519` is already set up locally;
add `~/.ssh/id_ed25519.pub` to GitHub → Settings → SSH keys, then:
```bash
cd /home/burak/Desktop/Work/Formalia/Branding/burak_basci_website
git remote set-url origin git@github.com:burak-basci/burak_basci_website.git
git push

cd ../burak-basci.github.io
git remote set-url origin git@github.com:burak-basci/burak-basci.github.io.git
git push
```

**(b) GitHub Personal Access Token** — create one at
<https://github.com/settings/tokens?type=beta> with `Contents: Read & Write`
on both repos, then:
```bash
git config --global credential.helper store
git push   # paste token when prompted
```

Pushing the live repo (`burak-basci.github.io`) goes live within ~60s via
GitHub Pages on www.burakbasci.de (CNAME is preserved).

The source-repo `firebase-hosting` GitHub Action is **gone** — pushing
source no longer auto-deploys to Firebase. Only the live-repo push affects
the public site.

---

## 2. Verify in a real browser  ⚠️ blocking

The headless Chromium used for screenshots falls back to CPU-only rendering
(no WebGL) and a known Flutter 3.41 CanvasKit bug means **cover images
don't render in screenshots**. Real browsers with WebGL handle this
correctly.

Before pushing the live repo, open <http://localhost:18080> in your normal
browser, scroll past the hero into the projects showcase, and confirm:

- [ ] Hero text uses Century Gothic style (geometric, all-caps look)
- [ ] Body text (subtitle, navigation, project descriptions) uses Calibri
      style (humanist sans, "fl" ligature etc.)
- [ ] All 14 project covers render with the gradient + project initials
      watermark
- [ ] Hovering a project card animates the side-accent + bubble button
- [ ] Clicking a project with a URL (Open Design, burakbasci_widgets, this
      site) opens it in a new tab
- [ ] Contact form, when submitted, opens your mail client with the body
      pre-filled (no backend deployed yet — see §4)

---

## 3. Per-project cover images

Currently every project shows a generated gradient + initials placeholder
(`tools/gen_covers.py` produced them). Real imagery is available for some
and would look better:

| Slug | Source path | Notes |
|---|---|---|
| `durak` | SFTP `/home/burak/drive/Projects/Flutter/Durak/Design/Screenshots/` | Lots of mobile screenshots — pick the most-iconic shot |
| `utopia` | SFTP `/home/burak/drive/Projects/Flutter/github/utopia_community/assets/banner/` | `1.png`, `benefits.png`, `help.png` — landscape banners |
| `open-design` | local `Self Employed/open-design/docs/assets/banner.png` | Project banner, fits 16:9 well |
| `catersmart` | local `Self Employed/CaterSmart/screenshots/WhatsApp Image 2026-04-28...jpeg` | Single screenshot |
| `thesis-night` | SFTP `/home/burak/drive/Projects/Unreal/SHK/NVIDIA_Plugin_Backups/.../NVCapturedData/PluginTest/` | Pick a striking synthetic-night render |

To swap: drop a 1600×900 PNG (or JPG) at
`burak_basci_website/assets/images/projects/<slug>/cover.png`, rebuild.

If you want flagship hero art for **vr-anxiety** and **utopia** generated
with your local Stable Diffusion / ComfyUI rig, tell Claude the SSH path to
the SD inference endpoint and prompts; it can drive the pipeline.

---

## 4. SMTP contact-form backend  ⚠️ if you want the form to actually send

The contact form was using Firestore's "Trigger Email" extension. Firebase
is now removed. The form currently has two modes:

**Default (no setup):** opens the visitor's mail client with `mailto:`.
Works on GitHub Pages, requires nothing. The downside is the visitor needs
a configured mail client.

**Backend mode:** the form POSTs to a small Python service that relays the
message to your Gmail via SMTP. To enable:

```bash
cd burak_basci_website/backend/contact-api

# 1. Build + push the image (anywhere your k3s cluster can pull from)
docker build -t ghcr.io/burak-basci/contact-api:latest .
docker push  ghcr.io/burak-basci/contact-api:latest

# 2. Create the SMTP secret in k3s
kubectl create secret generic contact-smtp \
  --from-literal=user='burakbascidev@gmail.com' \
  --from-literal=password='ilsk qqar mxel peki'   # your Gmail App Password

# 3. Deploy
kubectl apply -f k8s.yaml

# 4. Point api.burakbasci.de at your cluster ingress IP

# 5. Rebuild + republish the Flutter site with the backend URL baked in:
cd ..
podman run --rm -v "$PWD:/app" -w /app -e PUB_CACHE=/app/.pub-cache \
  ghcr.io/cirruslabs/flutter:stable bash -c \
  "git config --global --add safe.directory /app && \
   flutter pub get && \
   flutter build web --release --no-tree-shake-icons \
   --dart-define=CONTACT_BACKEND_URL=https://api.burakbasci.de/contact"
# then copy build/web/* into burak-basci.github.io/ and push.
```

**Why a backend at all?** Browsers can't speak SMTP directly (no socket
support, CORS, etc.). Anything claiming "send email from a static site"
goes through a relay; this is just yours.

**Alternatives if you'd rather not run a backend:**
- **Web3Forms** / **Formspree** / **EmailJS** — paste an access key, point
  the form at their endpoint, they handle SMTP. Free tier covers a portfolio.
- **Cloudflare Worker** — same idea as the FastAPI service but ~30 lines of
  JS on Cloudflare's free tier (no k3s needed).

Credentials currently noted in this file by user; they live nowhere in the
committed source. Keep them out of git — they only belong in `kubectl create
secret` or `.env` files that match `backend/contact-api/.env` (gitignored).

The Gmail App Password (`ilsk qqar mxel peki`) is valid only for SMTP —
your normal Google account password won't work. If you regenerate it,
update the k8s secret and rolling-restart the deployment.

---

## 5. Brand fonts

| Role | Bundled file | Real font | Notes |
|---|---|---|---|
| Title | `URWGothic-Demi.otf` / `URWGothic-Book.otf` | Century Gothic | URW Gothic is the OFL-licensed metric-equivalent shipped with most Linux distros. Visually 95% Century Gothic. To use the real thing, drop `Century Gothic.ttf` into `assets/fonts/century-gothic/` and switch the family entries in `pubspec.yaml`. |
| Body | `Carlito-Regular.ttf` etc. | Calibri | Carlito is Google's free, metric-compatible Calibri (same widths, same x-height, very similar shapes). Microsoft's Calibri TTFs are digitally signed (DSIG table) and don't render correctly in Flutter Web's CanvasKit — the unsigned Carlito does. |
| Accent | `Inter-Regular.ttf` / `Inter-Medium.ttf` / `Inter-Bold.ttf` | Inter | Pulled from Google Fonts (gstatic). Free under OFL. Used for small text — labels, ratings, "FROM PROTOTYPE TO PRODUCTION" tagline. |

For title spacing like `C E N T U R Y · G O T H I C` or `B U R A K  B A S C I`,
use Flutter's `letterSpacing: 12` in the relevant `TextStyle` rather than
literal spaces in the string. The pixel value depends on the font size —
about 0.15× font size reads "spaced" without being shouty.

---

## 6. Copy edits — `lib/data/projects.dart`

The project descriptions were drafted from your resume + folder inspection.
Skim them and revise voice/accuracy as needed. In particular:

- **Patent AI Search Tool** says "large automotive enterprise" — keep
  anonymous? Or name VW? You said employer/client work is OK to include
  with generic descriptions.
- **ImmoPilot** says "real-estate offices" — you may want a more specific
  pitch.
- **Web3 Environmental Platform** — confirm "Utopia Community" is the
  public-facing name.
- **Freelance Engagements** — generic by design (covers Patrick + any
  others). Edit if you'd rather break out specific clients.
- **Home Assistant Edge** — claims "local voice assistant" per your resume.
  Adjust to actual state.
- **burakbasci_widgets** — verify the pub.dev URL still exists.

Order matters for visual rhythm. The list is currently:
01 Patent AI Search → 02 ImmoPilot → 03 Utopia → 04 VR Anxiety → 05 Durak
→ 06 CaterSmart → 07 NestNode → 08 Freelance → 09 Open Design → 10 k3s →
11 Home Assistant → 12 Night-Detection Thesis → 13 widgets package →
14 this site.

Strongest impressions go first; consider swapping in your most-flagship
project to #01 if it isn't already.

---

## 7. Misc smaller items

- **Git email typo**: your global git email is `burakbasci98@gamil.com`
  ("gamil" not "gmail"). Past commits keep that authorship; new commits
  go out under the same address. Fix with
  `git config --global user.email burakbasci98@gmail.com` if you want
  future commits to look correct.

- **Old project-detail pages** (`lib/pages/old/`) still ship in the repo
  but are unused. Safe to delete — say the word and Claude will rip them
  out. Keeping them costs a few kB on disk and clutters search.

- **`lib/pages/contact/contact_page.dart`** still imports a few things
  it no longer strictly needs after the Firebase removal; `dart fix
  --apply` would clean them up but it's not blocking.

- **Old upstream-template demo assets** were deleted from the source repo
  but remain in git history (~6 MB of aerium/disneyplus/etc PNGs).
  `git filter-repo --invert-paths --path-glob 'assets/images/projects/aerium-*' ...`
  would purge them. Not worth it unless you care about repo size.

- **GitHub Pages 404 page**: currently none — visitors who land on
  unknown routes see Flutter's GetX router fallback. Adding a `404.html`
  to the live repo would be a nice polish.

- **Service worker**: Flutter's web service-worker is deprecated in 3.41
  but still ships. A future upgrade should switch to the new
  `flutter_bootstrap.js` flow (already used; just the SW is legacy).

---

## 8. Done — for reference

What's already complete and committed locally (not yet pushed):

- ✅ Cloned both repos into `Branding/`
- ✅ Set up Podman Flutter container (no host install)
- ✅ Migrated Flutter 3.0.5 → 3.41.9
- ✅ Re-enabled the projects showcase section
- ✅ Replaced upstream demo data with 14 of your real projects
- ✅ Generated branded placeholder covers
- ✅ Built + smoke-tested layout via headless Chromium
- ✅ Live-repo build artifacts staged with CNAME preserved
- ✅ Brand fonts applied (URW Gothic / Carlito / Inter)
- ✅ Firebase ripped out; contact form switched to HTTP-POST-or-mailto
- ✅ Backend SMTP relay service written (Dockerfile + k8s manifest +
       README) — needs deployment
