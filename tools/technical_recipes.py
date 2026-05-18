"""Per-project technical-illustration recipes.

Each entry is a list of dicts describing one diagram for that project:

    {
        "id": "01",
        "caption": short explanatory sentence shown under the image,
        "title": short diagram name shown in the prompt's SUBJECT block,
        "subject": prose description of what the diagram should depict —
                   what nodes / arrows / shapes / labels appear, what they
                   represent, and how they're laid out.
    }

The number of diagrams per project tracks architectural complexity:

  - 3-4 diagrams: dense / multi-system projects (VW Patent Search,
                   Hetzner k3s, Sovereign Real-Estate, PostPilot,
                   ImmoPilot, Night-Drive, CaterSmart, Dynamic Property,
                   Sovereign Smart Home, LLM Mail Triage)
  - 2 diagrams:    medium complexity (Coldmailing, LuminaRep, AI Voice,
                   Shop, AI Screenshot Recall, Legal Evidence, Formal
                   Docs, Utopia, VR Anxiety, Durak)
  - 1 diagram:     simple / single-concept projects (the remaining games,
                   small CLI tools, single-utility projects)

`gen_technical_prompts.py` reads this mapping, writes one text prompt per
diagram, and `install_technical_covers.py` later expects source PNGs at
`tools/ai_prompts/originals/technical/<slug>-<id>.png`.
"""
from __future__ import annotations

RECIPES: dict[str, list[dict[str, str]]] = {
    # ---------------- Top tier: 3-4 diagrams ----------------
    "volkswagen-ai-patent-search": [
        {
            "id": "01",
            "title": "Hybrid retrieval flow",
            "caption": "Hybrid retrieval — BM25 keyword scoring fused with dense vector embeddings, then a single A/B-tested ranking layer fronts the result list.",
            "subject": "A horizontal flow diagram, left-to-right. On the left, an input node labelled 'QUERY'. The query forks into two parallel branches: an upper branch labelled 'BM25 · keyword' that runs through an 'ELASTICSEARCH' node, and a lower branch labelled 'DENSE · embedding' that runs through a 'VECTOR STORE' node. Both branches converge into a 'RANKER · A/B' node, then a single output node labelled 'RESULTS'. Thin lines, arrowheads at each node, hero-colour fills on the two terminal nodes only, the rest as outlined squares.",
        },
        {
            "id": "02",
            "title": "Indexing + export pipeline",
            "caption": "Patents land in a tuned ElasticSearch index alongside dense vectors; the same Django backend renders branded export PDFs and result-page images on demand.",
            "subject": "Two parallel pipelines stacked vertically on a near-black field. Top pipeline left-to-right: 'PATENTS' → 'TOKENIZER' → 'EMBEDDING MODEL' → 'INDEX' (split into ES + Vector). Bottom pipeline: 'SEARCH HIT' → 'DJANGO CANVAS' → branches to 'PDF' and 'IMAGE'. The two pipelines share the 'INDEX' node visually (or a thin vertical line connects them). Hero-colour accents only on the terminal nodes.",
        },
        {
            "id": "03",
            "title": "System landscape (UML / SysML)",
            "caption": "The full landscape modelled in Enterprise Architect before any code was written — every infra-to-code dependency mapped, a missing security boundary caught in the diagram, not the audit.",
            "subject": "A loose UML/SysML-style block diagram on a near-black field. Four labelled boxes — 'WEB UI', 'API', 'INDEX', 'STORAGE' — connected by thin labelled lines. A dashed perimeter labelled 'SECURITY BOUNDARY' encloses the API + INDEX + STORAGE boxes; the WEB UI sits outside that boundary with a single arrow crossing in. Boxes outlined 1px in pale tone, one cross-boundary arrow accented in the hero colour.",
        },
    ],

    "hetzner-k3s-infrastructure": [
        {
            "id": "01",
            "title": "Cluster topology",
            "caption": "Three-node HA k3s with taints + tolerations splitting control-plane / storage from application workloads — an app deploy can't starve the databases.",
            "subject": "A triangular layout of three large circles labelled 'NODE-1', 'NODE-2', 'NODE-3' on a near-black field. Each circle is divided horizontally into two regions: an upper region labelled 'STORAGE / DB' (outlined) and a lower region labelled 'APPS' (hero-colour filled). Thin lines connect the three nodes pairwise. A label 'taints + tolerations' annotates the divider lines.",
        },
        {
            "id": "02",
            "title": "Storage architecture",
            "caption": "Hetzner Volumes (RWO, single-replica) carry the database tier; Longhorn (RWX) only earns its keep where pods actually need shared state.",
            "subject": "A two-column comparison diagram. Left column labelled 'HETZNER VOLUMES · RWO': two stacked cylinder shapes connected to a 'POSTGRES' box. Right column labelled 'LONGHORN · RWX': three cylinder shapes connected to two 'APP' boxes via thin lines. A vertical divider between the columns. Hero-colour fills on the cylinders in the RWO column only; the RWX column is outlined.",
        },
        {
            "id": "03",
            "title": "GitOps deployment pipeline",
            "caption": "One `terraform apply` provisions the cluster; ArgoCD GitOps-syncs every Helm release from there — lead time fell from 4 days to 45 minutes.",
            "subject": "A horizontal pipeline left-to-right. Stages: 'GIT' → 'GITLAB CI' → 'TERRAFORM' → 'K3S CLUSTER' → 'ARGOCD' → 'HELM RELEASES'. Arrows between stages. Labels under each. The 'K3S CLUSTER' and 'HELM RELEASES' nodes are hero-colour filled; the rest are outlined. A small annotation 'lead time: 4d → 45m' attached to the pipeline.",
        },
        {
            "id": "04",
            "title": "Secret + config split",
            "caption": "Configuration knobs live in a single .env per cluster, in Git; credentials, TLS, OAuth tokens live as native Kubernetes Secret resources mounted at runtime.",
            "subject": "A divided-frame diagram with a clear vertical split. Left side labelled '.ENV · CONFIG' contains an outlined rectangle with bullet-style horizontal lines representing config values. Right side labelled 'K8S SECRETS · CREDS' contains three outlined keyhole / padlock icons. Both sides feed into a central 'HELM RELEASE' node via arrows. The left side is outlined; the right side has the keyholes filled in the hero colour.",
        },
    ],

    "sovereign-real-estate-infrastructure": [
        {
            "id": "01",
            "title": "Container topology",
            "caption": "Twenty-eight Podman containers, twelve databases, eight customer-facing services running on one hardened Netcup vServer — every SaaS subscription replaced with its self-hosted equivalent.",
            "subject": "A radial diagram: one large central node labelled 'NETCUP vSERVER'. Around it, three concentric rings of small filled circles. Innermost ring (5 nodes): databases ('POSTGRES', 'MARIADB', 'MONGO', 'REDIS', 'QDRANT'). Middle ring (8 nodes): services ('PORTAINER', 'N8N', 'BASEROW', 'GHOST', 'OPENWEBUI', 'FASTAPI', 'CASAVI', 'WP'). Outer ring: small unlabelled dots representing the remaining ~15 containers. The central node is hero-colour filled; inner-ring nodes outlined; outer dots small.",
        },
        {
            "id": "02",
            "title": "5-day disaster-recovery rebuild",
            "caption": "Netcup hardware upgrade corrupted GRUB and crashed everything on day 0; the entire stack was rebuilt on openSUSE + Podman by day 5 with zero data loss.",
            "subject": "A horizontal timeline diagram. A long thin horizontal line spans the frame, with day-marker ticks: 'D0 · CRASH', 'D1 · OPENSUSE INSTALL', 'D2 · PODMAN', 'D3 · DBS RESTORED', 'D4 · APPS UP', 'D5 · DONE · ZERO DATA LOSS'. Below the line, small icons for each milestone. The line itself is hero-colour. The 'CRASH' and 'DONE' marker labels in slightly larger type. A small dashed arrow from D0 looping back via the line to D5, suggesting the recovery arc.",
        },
        {
            "id": "03",
            "title": "Self-hosted service map",
            "caption": "Fifteen-plus commercial SaaS replaced by open-source equivalents — Portainer, n8n, Baserow, Ghost, OpenWebUI — plus a thin FastAPI shim onto Casavi / Immoware.",
            "subject": "A two-column 'before vs after' diagram. Left column labelled 'COMMERCIAL SAAS' lists fifteen small outlined squares stacked. Right column labelled 'SELF-HOSTED' lists fifteen small filled squares (hero colour) — each with a tiny label ('PORTAINER', 'N8N', 'BASEROW', 'GHOST', 'OPENWEBUI', 'FASTAPI', etc.). A wide arrow between the columns labelled '−€20k / yr'. Minimal lines, lots of negative space.",
        },
    ],

    "postpilot-social-media-automation": [
        {
            "id": "01",
            "title": "Temporal workflow",
            "caption": "Each post moves through a deterministic five-step workflow with replay and retry built in — draft, moderate, schedule, post, confirm.",
            "subject": "A horizontal state-machine diagram, left-to-right. Five oval state nodes connected by arrows: 'DRAFT', 'MODERATE', 'SCHEDULE', 'POST', 'CONFIRM'. Two retry-arrows arc back from 'POST' to 'MODERATE' (labelled 'retry'). A small badge above the diagram reads 'TEMPORAL'. Hero-colour fill on the 'POST' and 'CONFIRM' nodes; the rest outlined.",
        },
        {
            "id": "02",
            "title": "LangGraph agent flow",
            "caption": "Captions and platform-specific variants come from a LangGraph DAG, not a chain — multi-step LLM routing stays legible at scale.",
            "subject": "A directed acyclic graph on a near-black field. A single 'BRIEF' node at the top branches into three nodes 'CAPTION', 'HASHTAGS', 'IMAGE PROMPT'. Each branches again into two platform-variant nodes (six leaves total) labelled 'IG', 'X', 'LI', 'TT', 'FB', 'YT'. Thin lines, small arrowheads, leaves are hero-colour filled, the BRIEF node outlined.",
        },
        {
            "id": "03",
            "title": "Multi-platform fan-out",
            "caption": "Nine social networks, one scheduled post — under 15 minutes a day for SMB content owners.",
            "subject": "A radial fan-out diagram: one central node labelled 'POSTPILOT' connects to nine outer nodes arranged in an arc on the right half of the frame: 'INSTAGRAM', 'X', 'LINKEDIN', 'TIKTOK', 'FACEBOOK', 'YOUTUBE', 'PINTEREST', 'THREADS', 'BLUESKY'. Thin lines from the central node to each outer node. The central node is hero-colour filled; outer nodes outlined.",
        },
    ],

    "immopilot-real-estate-saas": [
        {
            "id": "01",
            "title": "Multi-tenant RLS",
            "caption": "PostgreSQL row-level security is the defence-in-depth — SQLAlchemy filters are the primary check, RLS catches the bugs in the primary check before they leak.",
            "subject": "A layered cake diagram. Three horizontal layers stacked. Top layer labelled 'SQLALCHEMY FILTERS · primary'. Middle layer labelled 'POSTGRES RLS · defence-in-depth'. Bottom layer labelled 'TENANT DATA'. Each layer outlined in 1 px, hero-colour fills on the middle layer only. A small label on the right reads 'rls · row level security'.",
        },
        {
            "id": "02",
            "title": "Domain service graph",
            "caption": "Three domain services — Lead Processor, Object Matcher, Email Composer — orchestrated by ARQ workers polling the onOffice API.",
            "subject": "A graph diagram with four labelled circles connected by arrows. A central 'ARQ · POLL' node connects to three peripheral nodes: 'LEAD PROCESSOR', 'OBJECT MATCHER', 'EMAIL COMPOSER'. Each peripheral node has one outgoing arrow toward a single 'ONOFFICE' node on the right. Thin lines, hero-colour fills on 'EMAIL COMPOSER' (the user-visible output).",
        },
        {
            "id": "03",
            "title": "Integration map",
            "caption": "onOffice as single source of truth, polled via ARQ — onPreo has no API, Outlook authenticated via OAuth, Casavi via FastAPI shim.",
            "subject": "A hub-and-spoke diagram. Central node labelled 'IMMOPILOT'. Four spokes radiating outward to peripheral nodes: 'onOFFICE · poll' (top-right), 'OUTLOOK · OAuth' (bottom-right), 'CASAVI · FastAPI' (bottom-left), 'onPREO · n/a' (top-left, drawn dimmer). The 'onPREO' node is shown with a dashed line to indicate no API. Hub is hero-colour filled.",
        },
    ],

    "night-drive-object-detection": [
        {
            "id": "01",
            "title": "Synthetic-data pipeline",
            "caption": "Six thousand training samples generated from Epic's UE5 CitySample with a custom in-engine labeller — zero manual annotation cost.",
            "subject": "A horizontal pipeline diagram. Five stages left-to-right: 'UE5 CITYSAMPLE · scene', 'C++ PLUGIN · render-thread capture', 'CUSTOM LABELLER · bbox / mask', 'DATASET · 6,000 samples', 'YOLOv8 · training'. Connected by arrows. Stage 3 has a tiny annotation 'labels bundled with frames'. Stage 4 is hero-colour filled. Subtle dotted lines under the pipeline showing the data flow.",
        },
        {
            "id": "02",
            "title": "Sim-to-real gap analysis",
            "caption": "Five environmental parameters dominate CNN feature extraction at night; the thesis ablated those before touching architecture.",
            "subject": "A radar / pentagon-shape chart. Five axes labelled around the perimeter: 'STREETLIGHT INTENSITY', 'HEADLIGHT GLARE', 'WET ROAD REFLECT', 'AMBIENT FOG', 'CAMERA NOISE'. A pentagonal outline connecting all five at full extent (the dominant set). A second smaller pentagonal outline inside, slightly inset (the rest of the params). Hero-colour fill on the outer pentagon, the inner pentagon outlined.",
        },
        {
            "id": "03",
            "title": "Unreal C++ plugin architecture",
            "caption": "Segmentation logic + custom labeller baked into a first-party Unreal C++ plugin — no copy-out-to-disk per frame, the renderer and the labeller share the render thread.",
            "subject": "A two-column architecture diagram. Left column labelled 'GAME THREAD'. Right column labelled 'RENDER THREAD'. Inside the right column: three stacked boxes labelled 'CITYSAMPLE SCENE', 'SEGMENTATION PLUGIN · C++', 'CUSTOM LABELLER · bbox / mask'. Arrows between them show 'SAME THREAD · no IPC'. The plugin box is hero-colour filled. Cleaner negative space on the left column.",
        },
    ],

    "catersmart-catering-ops-ai-core": [
        {
            "id": "01",
            "title": "Mail triage pipeline",
            "caption": "Each inbound mail runs through an eleven-category classifier with strict JSON-schema enforcement on the LLM reply; mock mode default makes the contract testable without tokens.",
            "subject": "A horizontal pipeline. Stages left-to-right: 'INBOUND MAIL' → 'PROVIDER · MISTRAL' (with smaller boxes branching: 'CLAUDE', 'OPENAI', 'OPENWEBUI' as alternates) → 'CLASSIFY · 11 cats' → 'SCHEMA · enforce' → 'RAG · pgvector' → 'TICKET'. Hero-colour fills on 'SCHEMA' and 'TICKET'. A small 'mock mode' label hovering near the PROVIDER node.",
        },
        {
            "id": "02",
            "title": "Provider abstraction + tenant isolation",
            "caption": "One env var swaps Mistral / Claude / OpenAI / OpenWebUI; per-tenant RAG embedding scoping prevents cross-tenant feedback leak.",
            "subject": "A layered diagram. Top layer: four boxes side by side labelled 'MISTRAL', 'CLAUDE', 'OPENAI', 'OPENWEBUI' — only one (MISTRAL) is hero-colour filled, others outlined. Middle layer: single wide box labelled 'LLM_PROVIDER · env var'. Bottom layer: three side-by-side boxes labelled 'TENANT A', 'TENANT B', 'TENANT C', each with its own outlined pgvector store. A vertical dashed line separates the tenants showing isolation.",
        },
        {
            "id": "03",
            "title": "Phase-1 success metric",
            "caption": "Shipped against an explicit 60/30/10 success bar — 60% perfect, 30% light edit, 10% manual — naming acceptable failure up front shipped the product months earlier.",
            "subject": "A horizontal bar chart with three stacked segments. The bar is wide and short. From left to right: a 60%-wide segment hero-colour filled ('PERFECT'), a 30%-wide segment outlined ('LIGHT EDIT'), a 10%-wide segment outlined and slightly dashed ('MANUAL'). Each segment labelled inside. Above the bar: 'PHASE 1 · SUCCESS GATE'.",
        },
    ],

    "dynamic-property-3d-tours": [
        {
            "id": "01",
            "title": "Microservice mesh",
            "caption": "Per-concern microservices — geometry, video, AI staging, optimisation, compression — each on its own GPU/CPU profile; failure in one never takes the rest down.",
            "subject": "A graph diagram with five service nodes arranged in a horizontal row: 'GEOMETRY', 'VIDEO · ffmpeg', 'AI STAGING', 'OPTIMISER', 'COMPRESS · Sharp'. Above them, a central 'ORCHESTRATOR · Node + TypeScript' node connects down to each. Below, a single 'OBJECT STORAGE · MinIO' node connects up to each. Thin lines, arrowheads, hero-colour fills on the optimiser and compress nodes only.",
        },
        {
            "id": "02",
            "title": "Presigned upload + GLB optimisation",
            "caption": "Browsers push directly into MinIO via presigned URLs; the GLB worker uses glTF Transform + Meshoptimizer to keep tours under the streaming budget.",
            "subject": "A two-row diagram. Top row left-to-right: 'BROWSER' → 'PRESIGNED URL' → 'MINIO BUCKET' (large filled cylinder). Bottom row: 'GLB FILE' → 'glTF TRANSFORM' → 'MESHOPTIMIZER' → 'STREAMING TOUR'. The cylinder is hero-colour filled. Annotation between the rows: 'app server never sees the bytes'.",
        },
    ],

    "llm-mail-triage-intent-engine": [
        {
            "id": "01",
            "title": "Three-stage triage",
            "caption": "Classify → extract → draft, every stage behind a strict JSON-schema gate with retry-on-parse-failure. Bigger model with loose JSON still hallucinated tags.",
            "subject": "A horizontal three-stage pipeline. Three large nodes connected by arrows: 'CLASSIFY · 11 cats', 'EXTRACT · fields', 'DRAFT · reply'. Each node has a small downward arrow into a single 'JSON SCHEMA' gate. The 'JSON SCHEMA' gate is hero-colour filled. Above the pipeline: small label 'retry on parse-failure'.",
        },
        {
            "id": "02",
            "title": "Pluggable provider via one env var",
            "caption": "EU-residency clients flip Mistral / Claude / OpenAI / OpenWebUI with one config change — no per-tenant builds, no deployment matrix.",
            "subject": "A four-port switch diagram. A central 'LLM_PROVIDER' rotating switch (rendered as a circle with a small arrow). Four arms point to outer boxes labelled 'MISTRAL', 'CLAUDE', 'OPENAI', 'OPENWEBUI'. Only the 'MISTRAL' box is hero-colour filled to show the active selection; the others outlined.",
        },
    ],

    "sovereign-smart-home": [
        {
            "id": "01",
            "title": "Proxmox VM topology",
            "caption": "Every component on its own lightweight VM — a single bad upgrade can't take the broker and the database down with it.",
            "subject": "A grid of four labelled VM rectangles inside a larger outlined 'PROXMOX' boundary. The four VMs: 'HAOS', 'MQTT BROKER', 'INFLUXDB', 'GRAFANA'. Each VM rectangle outlined. The PROXMOX boundary is hero-colour outlined. Thin connecting lines between MQTT-HAOS and INFLUX-GRAFANA pairs.",
        },
        {
            "id": "02",
            "title": "VLAN segmentation",
            "caption": "OpenWRT puts cameras, lights, presence sensors behind segmented VLANs from day one — retrofitting that after a CVE costs much more than starting with it.",
            "subject": "Three horizontal VLAN bands stacked vertically. From top to bottom: 'TRUSTED · LAN', 'IOT · cameras + lights', 'PRESENCE · sensors'. Each band has 3-4 small device icons inside. A central 'OPENWRT' node sits on the left, connected to each band with a labelled line. The 'IOT' band is hero-colour outlined; others outlined.",
        },
        {
            "id": "03",
            "title": "Room-owned automation graph",
            "caption": "Forty-plus automations tied to rooms, not chained-trigger global scenes — a misbehaving rule's blast-radius stays in its room.",
            "subject": "A floor-plan-style grid of room rectangles labelled 'LIVING', 'KITCHEN', 'BEDROOM', 'OFFICE', 'BATH', 'HALL'. Each room contains 2-3 small automation node icons. Thin lines connect each room's automations to a small 'MQTT' badge inside that room. No cross-room connections. Hero-colour fill on one room ('OFFICE') as the example.",
        },
    ],

    # ---------------- Medium tier: 2 diagrams ----------------
    "coldmailing-lead-platform": [
        {
            "id": "01",
            "title": "Campaign state model",
            "caption": "Outbound modelled as campaign + sequence + opt-out — the lead's lifecycle is the unit that matters, not the individual message.",
            "subject": "A state-diagram on a near-black field. Five oval state nodes connected by arrows: 'NEW LEAD' → 'SEGMENTED' → 'IN-SEQUENCE' → 'ENGAGED' / 'OPT-OUT'. The 'OPT-OUT' state is hero-colour filled and has its own arrow branching from any other state via a thin red-ish line. The other states are outlined.",
        },
        {
            "id": "02",
            "title": "NocoDB-backed CRM-lite",
            "caption": "NocoDB is the business UI — operators edit lists, sequences, offers without a developer; the Flask app is just the campaign engine behind it.",
            "subject": "A two-layer architecture. Top layer: a wide outlined rectangle labelled 'NOCODB · BUSINESS UI'. Inside it, three smaller boxes labelled 'LEADS', 'SEQUENCES', 'OFFERS'. Bottom layer: a smaller outlined rectangle labelled 'FLASK · CAMPAIGN ENGINE'. A thick arrow between the layers labelled 'API'. The Flask layer is hero-colour outlined; the NocoDB layer plain outlined.",
        },
    ],

    "luminarep-clinic-review-saas": [
        {
            "id": "01",
            "title": "Review → Multi-channel content",
            "caption": "Each 5-star Google review is auto-extracted and fanned out into three Instagram captions, a TikTok script, and Midjourney/DALL-E image prompts in the clinic's tone.",
            "subject": "A fan-out diagram. A single 'REVIEW · ⭐ 5/5' node on the left. An arrow into a central 'GEMINI · clinic tone' node. From there, four branches to: '3× INSTAGRAM CAPTION', 'TIKTOK SCRIPT', 'MIDJOURNEY PROMPT', 'DALL-E PROMPT'. Hero-colour fill on the central GEMINI node; outputs outlined.",
        },
        {
            "id": "02",
            "title": "Self-hostable architecture",
            "caption": "Whole stack bundled in Docker Compose with a production deploy guide — clinics that need patient-adjacent data on-premises run it on their own server.",
            "subject": "A compose-file-style architecture. Three horizontally-stacked container rectangles labelled 'NEXT.JS', 'POSTGRES', 'NEXTAUTH'. Outside the cluster, a single 'STRIPE' badge with a thin arrow inward. The cluster is wrapped by a thin dashed line labelled 'DOCKER COMPOSE · on-premises possible'. Hero-colour fill on NEXT.JS.",
        },
    ],

    "local-ai-voice-assistant": [
        {
            "id": "01",
            "title": "On-device voice pipeline",
            "caption": "Wake-word → faster-whisper STT → local LLM → Piper TTS — sub-second round-trip, no audio ever leaves the LAN.",
            "subject": "A horizontal pipeline. Five stages: 'WAKE WORD · openWakeWord', 'STT · faster-whisper int8', 'LLM · local', 'INTENT', 'TTS · Piper'. Connected by arrows. Below the pipeline, a single 'MQTT' node connects up to 'INTENT' with a labelled arrow 'home assistant'. Hero-colour fill on 'STT' and 'TTS'.",
        },
        {
            "id": "02",
            "title": "Two consumers, one sidecar",
            "caption": "Whisper exposed as an OpenAI-compatible sidecar on :10300 — one model also feeds the CaterSmart AI core, no code duplication.",
            "subject": "A branch diagram. A central 'WHISPER :10300' node (hero-colour filled). Two outgoing arrows: one to a 'VOICE ASSISTANT' node, one to a 'CATERSMART AI CORE' node. Both consumer nodes outlined.",
        },
    ],

    "ai-driven-print-on-demand-shop": [
        {
            "id": "01",
            "title": "Generation → distribution pipeline",
            "caption": "ComfyUI + FLUX.1 on local GPU, Real-ESRGAN upscale via SFTP, Selenium uploads to Adobe Stock, Printify API places designs on POD products that ship to the WooCommerce storefront.",
            "subject": "A long horizontal pipeline, left-to-right. Stages: 'COMFYUI · FLUX.1' → 'REAL-ESRGAN · 4×' → 'SELENIUM · Adobe Stock' / 'PRINTIFY API' / 'PINTEREST API' (three parallel branches) → 'WOOCOMMERCE'. Hero-colour fill on the terminal WOOCOMMERCE node and the central pipeline.",
        },
        {
            "id": "02",
            "title": "Prompt-to-order reconciliation",
            "caption": "Pandas matches every order back to the original prompt + latent seed — once shipping works, the next bug becomes 'do the generated designs sell?'.",
            "subject": "A reconciliation flow. Top row left-to-right: 'PROMPT' → 'SEED' → 'DESIGN' → 'SKU' → 'ORDER'. Bottom row: a 'PANDAS · join' box with vertical arrows up to each top-row node. The bottom node is hero-colour filled.",
        },
    ],

    "ai-screenshot-recall": [
        {
            "id": "01",
            "title": "Wayland evdev daemon",
            "caption": "Mouse-triggered capture via direct /dev/input/eventN read — EVIOCGRAB blocks grabbing but not reading; every other approach (Wayland portal, X11 hooks) failed.",
            "subject": "A vertical stack of three labelled bands. Top: 'WAYLAND COMPOSITOR · NVIDIA'. Middle: 'EVDEV · /dev/input/eventN · read-only'. Bottom: 'PYTHON DAEMON · user systemd'. A small note attached to the middle band: 'EVIOCGRAB → grab=NO read=YES'. The middle band is hero-colour outlined.",
        },
        {
            "id": "02",
            "title": "Gemini vs Copilot model racing",
            "caption": "Two providers race on parallel threads; whichever responds first streams sentences via SSE to a local PWA overlay.",
            "subject": "A two-lane race diagram. Two horizontal lanes converging right-to-left. Upper lane labelled 'GEMINI' with a forward chevron. Lower lane labelled 'COPILOT' with a forward chevron. The lanes converge at a 'WHICHEVER FIRST' switch node that outputs to 'SSE · LOCAL OVERLAY'. The output node is hero-colour filled.",
        },
    ],

    "legal-evidence-organization": [
        {
            "id": "01",
            "title": "Hash-on-ingest chain of custody",
            "caption": "Every artefact gets a SHA-256 fingerprint at the moment it enters the room — chain-of-custody questions later have a deterministic answer.",
            "subject": "A linear chain diagram. Five stages left-to-right with hash icons (rendered as small rectangles with 'A1B2' style markers): 'EMAIL', 'PDF', 'WHATSAPP', 'LOG', 'AUDIO'. Each connected to a single 'EVIDENCE ROOM' node on the right. Each input has a small badge above it labelled 'sha256'. The room node is hero-colour outlined.",
        },
        {
            "id": "02",
            "title": "Typed chronology",
            "caption": "Structured events — email / chat / file / log / call — never free-text narrative; every entry carries source + date + medium.",
            "subject": "A vertical timeline. Five typed event icons stacked at different y-positions on a single vertical line. Each event has a small typed icon (email envelope, chat bubble, file, log, phone) and small text 'src · date · medium'. The timeline itself is hero-colour. Each event is outlined.",
        },
    ],

    "formal-document-automation": [
        {
            "id": "01",
            "title": "Template engine pipeline",
            "caption": "Structured input → python-docx + Jinja2 → DOCX/PDF — German legal formality is template work, not LLM work.",
            "subject": "A horizontal pipeline. Stages: 'STRUCT INPUT' → 'JINJA2 TEMPLATE' → 'PYTHON-DOCX' → 'DOCX / PDF'. Below the pipeline, a separate node 'EPC / GIROCODE · QR' connects up into the final output. Hero-colour fill on the QR node and the final DOCX/PDF output.",
        },
        {
            "id": "02",
            "title": "Mahnstufen cadence",
            "caption": "Reminders are a cadence — M1 → M2 → M3 → Inkasso — not one-shot events. The schedule did the work, not the wording.",
            "subject": "A horizontal timeline with four day-marker ticks: 'M1 · 14d', 'M2 · 28d', 'M3 · 42d', 'INKASSO · 60d'. Below each tick, a small icon for the reminder type. Above the timeline, a 'PAYMENT' label that can short-circuit any tick with a downward arrow. The 'INKASSO' tick is hero-colour filled; others outlined.",
        },
    ],

    "utopia-community": [
        {
            "id": "01",
            "title": "UUPS upgradeable proxy",
            "caption": "ERC-20 UWCT on Polygon behind a UUPS proxy — protocol logic evolves without forcing token holders to migrate.",
            "subject": "A two-layer architecture. Top layer: outlined box labelled 'UUPS PROXY · UWCT'. Bottom layer: three side-by-side boxes labelled 'IMPL v1', 'IMPL v2', 'IMPL v3'. A single arrow from the proxy down to the currently-active implementation (v3). The proxy is hero-colour outlined; the active implementation is hero-colour filled, the others dimmed.",
        },
        {
            "id": "02",
            "title": "Multi-sig governance",
            "caption": "Every supply-mutating operation (mint, burn, pause) is multi-sig — a single key on a charity token is a single point of failure for the entire mission.",
            "subject": "A diagram with three signer icons on the left (small key shapes), each connected to a central 'MULTISIG' node, then a single arrow to a 'CONTRACT · mint/burn/pause' node. The 'MULTISIG' node is hero-colour filled. The signer nodes outlined.",
        },
    ],

    "vr-anxiety-trainer": [
        {
            "id": "01",
            "title": "Scene composition",
            "caption": "Stage of a virtual opera house, walk to centre, deliver a short speech to a virtual audience while a coach script guides breathing — depth reads as polish, breadth as half-finished.",
            "subject": "A stage-plan-style diagram seen from above. A large rectangle labelled 'STAGE'. On it, a single small dot labelled 'CENTRE MARKER' in hero colour. In front of the stage, a series of small audience-row marks. Above, a thin horizontal line labelled 'AUDIO COACH · breathing'. Minimal labels, lots of negative space.",
        },
    ],

    "durak-cross-platform-card-game": [
        {
            "id": "01",
            "title": "GameRules + GameRegistry",
            "caption": "Phase-13 extraction so the engine can ship Hearts, Spades, Belote, Preferans and Uno without forking the game logic.",
            "subject": "A class-diagram-style box. A central 'GameRegistry' box. Below it, four child boxes labelled 'Durak', 'Hearts', 'Spades', 'Uno'. Each connected to the registry with thin inheritance-style lines (open triangles). The registry is hero-colour filled; the children outlined.",
        },
        {
            "id": "02",
            "title": "WebSocket multiplayer",
            "caption": "Sockets + Elo-based matchmaking with guest-token persistence — required registration on a cards app kills retention, the cost of supporting guests is rounding error.",
            "subject": "A network diagram. Three player phone icons on the left. A central 'WS GATEWAY' node. To the right, two stacked nodes labelled 'MATCHMAKER · Elo' and 'GAME STATE · authoritative'. Thin lines between players and the gateway, gateway to both right-side nodes. Hero-colour fills on the matchmaker.",
        },
    ],

    # ---------------- Single-diagram tier ----------------
    "pscoat-industrial-coatings-ops": [
        {
            "id": "01",
            "title": "Playwright scraper architecture",
            "caption": "Manual login once, reuse session jar afterward — Cloudflare Turnstile + browser-fingerprinting + fraud detection ruled out plain HTTP scraping.",
            "subject": "A two-stage diagram. Stage 1 ('one-time'): 'MANUAL LOGIN' → 'SESSION JAR · upwork_session.json'. Stage 2 ('every run'): 'PLAYWRIGHT' → 'TURNSTILE PASS' → 'LISTING · qualified'. Hero-colour on session jar node and qualified listing.",
        },
    ],

    "theater-website-ruhrbhne-witten": [
        {
            "id": "01",
            "title": "Stack + backup posture",
            "caption": "WordPress + Elementor Pro, programme / Eventim integration, versioned via timestamped backup archives — Git would have been heavier and more brittle for an editorial workflow.",
            "subject": "A simple system diagram. A central 'WORDPRESS · Elementor' box. Connections out to: 'EVENTIM · tickets', 'MYSQL · DB', 'UPLOADS · media'. A separate 'BACKUP · timestamped archive' node below, drawing from all the system parts. The WordPress core is hero-colour outlined.",
        },
    ],

    "nestnode-smart-home-concept": [
        {
            "id": "01",
            "title": "Direct MQTT path",
            "caption": "Direct MQTT from the phone — no cloud bridge. Archived at concept stage; the design language was rolled into Sovereign Smart Home.",
            "subject": "A simple two-node diagram. A 'PHONE' icon on the left. An 'MQTT BROKER · LAN' node in the middle. A 'HOME ASSISTANT' node on the right. Thin lines between them. A separate, dashed 'CLOUD BRIDGE' node above the broker with an 'X' across it (indicating not used). The MQTT broker is hero-colour outlined.",
        },
    ],

    "burakbasciwidgets": [
        {
            "id": "01",
            "title": "Library structure",
            "caption": "Animation primitives, layout helpers, UI components extracted from production projects — null-safety-first, widget tests + dartdoc on every widget before merging.",
            "subject": "A package-content diagram. A central 'burakbasci_widgets' badge. Around it, four labelled folders: 'animations/', 'layout/', 'buttons/', 'text/'. Each folder has 2-3 small file icons. Hero-colour fill on the central badge.",
        },
    ],

    "boxhead-unreal-fps": [
        {
            "id": "01",
            "title": "Weapon system architecture",
            "caption": "Per-shot feel needs single-frame tuning — weapon spread / ricochet / projectile pooling in C++, not Blueprints.",
            "subject": "A class-diagram-style boxes. Top: 'Weapon · C++'. Three child boxes: 'SPREAD', 'RICOCHET', 'PROJECTILE POOL'. Below them, a thin layer labelled 'BLUEPRINTS · visual effects only'. Hero-colour fill on the parent class.",
        },
    ],

    "flappy-griffon": [
        {
            "id": "01",
            "title": "Gameplay loop",
            "caption": "Ray-traced indie game shipped on itch.io — tap to flap, gravity does the rest.",
            "subject": "A simple game-state loop. Four state nodes connected in a circle: 'IDLE' → 'PLAYING' → 'CRASH' → 'RESULT' → 'IDLE'. Thin arrows around the loop. The PLAYING state is hero-colour filled.",
        },
    ],

    "myjumpnrun": [
        {
            "id": "01",
            "title": "Iterative game series",
            "caption": "Three iterations of the same platformer concept — each refining one core mechanic at a time.",
            "subject": "Three labelled boxes side by side: 'v1 · jump', 'v2 · run', 'v3 · climb'. Arrows from v1 → v2 → v3. Hero-colour fill on v3.",
        },
    ],

    "alsignal-asl-hackathon": [
        {
            "id": "01",
            "title": "ASL recognition pipeline",
            "caption": "Real-time American Sign Language recognition in Unity for a hackathon — hand pose → classifier → letter.",
            "subject": "A horizontal pipeline. Stages: 'CAMERA' → 'HAND POSE' → 'CLASSIFIER' → 'LETTER'. Connected by arrows. Hero-colour fill on the final LETTER node.",
        },
    ],

    "steam-market-arbitrage-bot": [
        {
            "id": "01",
            "title": "Arbitrage scoring",
            "caption": "Trading-card economy analyser with risk scoring — every offer scored before placing a buy.",
            "subject": "A horizontal scoring pipeline. Stages: 'OFFER' → 'PRICE HISTORY' → 'RISK SCORE' → 'BUY / SKIP'. Hero-colour fill on the BUY/SKIP node.",
        },
    ],

    "csfloat-sniper": [
        {
            "id": "01",
            "title": "Marketplace scanner",
            "caption": "MarketDataCache dedup cut API calls by 33% — environment-based token loading kept credentials out of the repo.",
            "subject": "A scanner diagram. A central 'CSFLOAT API' node. A 'MarketDataCache · dedup' node sitting between it and the application. A 'TOKEN · env' badge above the API node. Hero-colour fill on the cache.",
        },
    ],

    "binance-german-tax-pdf": [
        {
            "id": "01",
            "title": "CSV → Steuerbericht",
            "caption": "Binance CSV in, German tax report PDF out — every trade categorised against German tax brackets.",
            "subject": "A horizontal pipeline. Stages: 'BINANCE CSV' → 'CATEGORISE · FIFO' → 'BRACKETS' → 'STEUERBERICHT · PDF'. Hero-colour fill on the PDF terminal.",
        },
    ],

    "open-source-wordpress-plugins": [
        {
            "id": "01",
            "title": "Plugin structure",
            "caption": "Small GPL plugins for ImmoWare-style sites — utility helpers, not platform takeovers.",
            "subject": "A simple plugin-pack diagram. Three plugin file icons stacked vertically. Each connected to a central 'WORDPRESS' core via thin lines. Hero-colour outlines.",
        },
    ],

    "burakbascide": [
        {
            "id": "01",
            "title": "Site stack",
            "caption": "Flutter Web, Material 2, OFL fonts, Podman build container, two-repo deploy pattern.",
            "subject": "A simple two-column diagram. Left: 'FLUTTER WEB' with three child boxes 'Material 2', 'OFL fonts', 'Get'. Right: 'PIPELINE' with three child boxes 'PODMAN BUILD', 'FIREBASE HOSTING', 'GITHUB PAGES'. Hero-colour outlines.",
        },
    ],
}
