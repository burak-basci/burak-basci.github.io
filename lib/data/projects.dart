import 'package:flutter/material.dart';

import '../widgets/project_item/project_item.dart';

const String _d = 'assets/images/projects';

/// Ordered MOST → LEAST prestigious. The home-page cascade renders the full
/// list; the per-entry `screenshots` + `decisions` + `learnings` lists drive
/// the detail page.
final List<ProjectItemData> recentWorks = <ProjectItemData>[
  // 01 ----------------------------------------------------------------------
  ProjectItemData(title: 'Volkswagen AI Patent Search',
    subtitle: 'Hybrid semantic search engine — VW Infotainment',
    category: 'AI / SEARCH',
    platform: 'Web · Internal',
    primaryColor: const Color(0xFF1E3A8A),
    image: '$_d/patent-search/cover.webp',
    coverUrl: '$_d/patent-search/cover.webp',
    coverColorUrl: '$_d/patent-search/cover-color.webp',
    technologyUsed:
        'Flutter Web · Django · ElasticSearch · Vector Embeddings · Django Canvas (PDF/image gen) · Kubernetes · UML/SysML',
    portfolioDescription:
        'Production AI patent-search tool I built end-to-end at Volkswagen '
        'Infotainment, scaled across three departments and 50+ internal '
        'engineers. Hybrid retrieval over a tuned ElasticSearch index '
        'combines BM25 keyword scoring with dense vector embeddings; an '
        'A/B-tested ranking layer lifted precision by 25% and cut '
        'researcher time-to-discovery by 40%. A small Django service '
        '("Django Canvas") renders branded export PDFs and result-page '
        'images on demand. Deployed onto VW\'s internal Kubernetes '
        'clusters so the patent corpus never crossed the corporate '
        'boundary. The full landscape was modelled in Enterprise '
        'Architect (UML/SysML), mapping 100% of infra-to-code '
        'dependencies for the DevSecOps handover.',
    isPublic: false,
    isLive: true,
    mockupType: 'laptop',
    screenshots: <String>[],
    decisions: <String>[
      'Picked **hybrid BM25 + dense-vector retrieval** instead of pure semantic search — pure embeddings consistently missed the exact-term matches that legal teams actually search for (Patent IDs, claim numbers, named entities), and that gap was a non-starter for the audience.',
      'Ran every ranking-weight change through an **A/B-test against a fixed query bank** rather than shipping by feel — only three configurations cleared the bar; the rest looked good in demos and lost on real searches.',
      'Embedded **PDF + image rendering inside the same Django backend** ("Django Canvas") rather than calling a third-party export service, because every export contained patent text under NDA and could not leave the boundary.',
      'Modelled the full system in **Enterprise Architect (UML/SysML) before writing code** — the upfront diagram surfaced a missing security boundary that would have failed the security audit if discovered later.',
      'Deployed onto **VW\'s internal Kubernetes clusters** instead of any external host — the patent corpus contained pre-publication IP, so every byte of indexing, search and rendering had to stay inside the corporate boundary; an on-cluster deployment was the only configuration the security review accepted.',
    ],
    learnings: <String>[
      'Cognitive-load audits with patent counsel showed the real bottleneck was *reading dozens of false positives*, not query latency — I rebalanced the roadmap toward ranking quality, away from response-time wins that wouldn\'t have moved the needle.',
      'Treating the infra-to-code dependency graph as a first-class deliverable — not a side-effect — survived three team rotations as the operational contract.',
    ],
    translations: const <String, ProjectTranslation>{
      'de': ProjectTranslation(
        title: 'Volkswagen KI-Patentsuche',
        subtitle: 'Hybride semantische Suchmaschine — VW Infotainment',
        category: 'KI / SUCHE',
        platform: 'Web · Intern',
        technologyUsed:
            'Flutter Web · Django · ElasticSearch · Vector Embeddings · Django Canvas (PDF-/Bild-Generierung) · Kubernetes · UML/SysML',
        portfolioDescription:
            'Produktives KI-Patentsuchwerkzeug, das ich bei Volkswagen '
            'Infotainment end-to-end gebaut und über drei Abteilungen mit '
            '50+ internen Engineers ausgerollt habe. Hybride Retrieval '
            'über einen abgestimmten ElasticSearch-Index kombiniert '
            'BM25-Keyword-Scoring mit dichten Vektor-Embeddings; eine '
            'A/B-getestete Ranking-Schicht hob die Präzision um 25 % und '
            'senkte die Time-to-Discovery der Researcher um 40 %. Ein '
            'kleiner Django-Service ("Django Canvas") rendert auf Abruf '
            'gebrandete Export-PDFs und Ergebnisseiten-Bilder. '
            'Deployed auf die internen Kubernetes-Cluster von VW, damit '
            'der Patent-Korpus die Unternehmensgrenze nie überquert. Die '
            'gesamte Landschaft wurde in Enterprise Architect (UML/SysML) '
            'modelliert und 100 % der Infrastructure-to-Code-Abhängigkeiten '
            'für die DevSecOps-Übergabe abgebildet.',
        decisions: <String>[
          '**Hybrides BM25- + Dense-Vector-Retrieval** statt rein semantischer Suche gewählt — reine Embeddings verfehlten konsequent die Exact-Term-Matches, die Rechtsteams tatsächlich suchen (Patent-IDs, Anspruchsnummern, Named Entities); diese Lücke war für das Zielpublikum ein K.-o.-Kriterium.',
          'Jede Änderung an Ranking-Gewichten durch einen **A/B-Test gegen eine feste Query-Bank** laufen lassen statt nach Bauchgefühl auszuliefern — nur drei Konfigurationen kamen über die Schwelle; der Rest sah in Demos gut aus und verlor bei echten Suchen.',
          '**PDF- + Bild-Rendering ins selbe Django-Backend eingebettet** ("Django Canvas") statt einen externen Export-Dienst aufzurufen, denn jeder Export enthielt NDA-geschützten Patenttext und durfte die Grenze nicht verlassen.',
          'Das gesamte System in **Enterprise Architect (UML/SysML) modelliert, bevor Code geschrieben wurde** — das Vorab-Diagramm legte eine fehlende Security-Boundary offen, die das Security-Audit später hätte scheitern lassen.',
          'Auf die **internen Kubernetes-Cluster von VW** deployed statt auf einen externen Host — der Patent-Korpus enthielt unveröffentlichte IP, also musste jedes Byte Indexing, Suche und Rendering innerhalb der Unternehmensgrenze bleiben; ein On-Cluster-Deployment war die einzige Konfiguration, die das Security-Review akzeptierte.',
        ],
        learnings: <String>[
          'Cognitive-Load-Audits mit Patentanwälten zeigten, dass der eigentliche Engpass das *Durchlesen dutzender False Positives* war, nicht die Query-Latenz — ich habe die Roadmap zugunsten der Ranking-Qualität umgeschichtet, weg von Response-Time-Wins, die nichts bewegt hätten.',
          'Den Infrastructure-to-Code-Abhängigkeitsgraphen als First-Class-Deliverable zu behandeln — nicht als Nebenprodukt — überlebte drei Team-Rotationen als operativer Vertrag.',
        ],
      ),
    },
  ),

  // 02 ----------------------------------------------------------------------
  ProjectItemData(title: 'Hetzner k3s Infrastructure',
    subtitle: 'GitOps Kubernetes platform — agency internal tools + client web hosting',
    category: 'DEVSECOPS / CLOUD',
    platform: 'Hetzner Cloud',
    primaryColor: const Color(0xFFEA580C),
    image: '$_d/k3s/cover.webp',
    coverUrl: '$_d/k3s/cover.webp',
    coverColorUrl: '$_d/k3s/cover-color.webp',
    technologyUsed:
        'k3s · Terraform · ArgoCD · Traefik · Helm · Longhorn · CloudNativePG · MariaDB Galera · cert-manager · Prometheus · Grafana',
    portfolioDescription:
        'A production-grade Kubernetes platform on Hetzner Cloud built for '
        'a digital agency: a single GitOps-driven cluster hosts the '
        'agency\'s own work tools alongside their clients\' WordPress '
        'installs and static HTML/CSS/JS sites — every workload gets the '
        'same HA primitives, the same TLS posture and the same backup '
        'discipline regardless of who it serves. Three-node HA k3s with '
        'CloudNativePG + MariaDB Galera; Longhorn for application RWX, '
        'Hetzner Volumes for the database tier. Provisioning is a single '
        '`terraform apply`; ArgoCD then GitOps-syncs every service. Lead '
        'time fell from 4 days to 45 minutes (95% improvement), and '
        'Prometheus + Grafana cut MTTD by 40%.',
    isPublic: false,
    isLive: true,
    mockupType: 'terminal',
    screenshots: <String>[],
    decisions: <String>[
      'Chose **Hetzner Cloud + k3s** over managed Kubernetes (EKS/GKE/AKS) because the workload is HA-stable and predictable — managed control planes would have cost roughly 10× more for zero functional gain.',
      'Split the cluster into **control-plane storage nodes vs. application nodes via taints/tolerations** — without that separation an app deploy could starve the databases of CPU/IO; learned that the hard way on an early test cluster.',
      'Used **Hetzner Volumes (RWO) for databases** but **Longhorn (RWX) for application state** — single-replica block devices are dramatically faster for Postgres, and Longhorn\'s replication only earns its keep where multiple pods actually need shared state.',
      'Opted for **DNS-01 wildcard TLS via Cloudflare cert-manager** over HTTP-01 — every new subdomain across the agency\'s namespaces inherits the wildcard, avoiding a per-service ACME round-trip on first request.',
      'Split configuration from secrets cleanly: a **single .env file** per cluster holds the non-sensitive Helm values (ingress domains, replica counts, feature flags), while credentials, TLS material and OAuth tokens live as native **Kubernetes Secret resources** mounted into pods at runtime. Disaster recovery is `terraform apply → re-apply the Secrets manifest → helm install` — config in Git, secrets in the cluster, no treasure hunt across YAML.',
    ],
    learnings: <String>[
      'WordPress Multisite was bottlenecked on Longhorn NFS share-manager (RWX); moving to a single-replica RWO ext4 block device cut TTFB from 110 ms to 65 ms — picked the wrong storage tier for the workload the first time around.',
      'Longhorn RWX share-manager pods silently fail to schedule without explicit taint-toleration entries; the only signal is "Pending forever" — instrument scheduler logs early.',
      'A GitOps-reproducible cluster pays back the most on its second incarnation: I rebuilt the whole platform in a fork during a major change and the round-trip was an afternoon.',
    ],
    translations: const <String, ProjectTranslation>{
      'de': ProjectTranslation(
        title: 'Hetzner k3s Infrastruktur',
        subtitle: 'GitOps-Kubernetes-Plattform — interne Tools + Kunden-Webhosting einer Agentur',
        category: 'DEVSECOPS / CLOUD',
        platform: 'Hetzner Cloud',
        technologyUsed:
            'k3s · Terraform · ArgoCD · Traefik · Helm · Longhorn · CloudNativePG · MariaDB Galera · cert-manager · Prometheus · Grafana',
        portfolioDescription:
            'Eine produktionsreife Kubernetes-Plattform auf Hetzner Cloud, '
            'gebaut für eine Digitalagentur: ein einziger GitOps-gesteuerter '
            'Cluster hostet die eigenen Arbeitstools der Agentur neben den '
            'WordPress-Installationen und statischen HTML/CSS/JS-Seiten '
            'ihrer Kunden — jeder Workload bekommt dieselben HA-Primitiven, '
            'dieselbe TLS-Posture und dieselbe Backup-Disziplin, egal wem '
            'er dient. Drei-Knoten-HA-k3s mit CloudNativePG + MariaDB '
            'Galera; Longhorn für Anwendungs-RWX, Hetzner Volumes für die '
            'Datenbank-Schicht. Provisionierung ist ein einziges '
            '`terraform apply`; ArgoCD synchronisiert dann jeden Service '
            'per GitOps. Lead Time fiel von 4 Tagen auf 45 Minuten '
            '(95 % Verbesserung), und Prometheus + Grafana senkten MTTD '
            'um 40 %.',
        decisions: <String>[
          '**Hetzner Cloud + k3s** gegenüber managed Kubernetes (EKS/GKE/AKS) gewählt, weil der Workload HA-stabil und vorhersehbar ist — managed Control Planes hätten rund 10× mehr gekostet für null funktionalen Gewinn.',
          'Den Cluster über Taints/Tolerations in **Control-Plane-Storage-Nodes vs. Application-Nodes** aufgeteilt — ohne diese Trennung kann ein App-Deploy die Datenbanken bei CPU/IO aushungern; auf einem frühen Testcluster auf die harte Tour gelernt.',
          '**Hetzner Volumes (RWO) für Datenbanken**, aber **Longhorn (RWX) für Anwendungs-State** verwendet — Single-Replica-Block-Devices sind für Postgres dramatisch schneller, und Longhorns Replikation lohnt sich nur dort, wo mehrere Pods tatsächlich Shared State brauchen.',
          'Auf **DNS-01-Wildcard-TLS via Cloudflare cert-manager** gegenüber HTTP-01 gesetzt — jede neue Subdomain in den Namespaces der Agentur erbt das Wildcard und spart sich den ACME-Round-Trip pro Service beim ersten Request.',
          'Konfiguration sauber von Secrets getrennt: eine **einzelne .env-Datei** pro Cluster hält die nicht-sensitiven Helm-Werte (Ingress-Domains, Replica-Counts, Feature Flags), während Credentials, TLS-Material und OAuth-Tokens als native **Kubernetes Secret Resources** liegen und zur Laufzeit in die Pods gemountet werden. Disaster Recovery ist `terraform apply → Secrets-Manifest erneut applyen → helm install` — Config in Git, Secrets im Cluster, keine Schatzsuche quer durch YAML.',
        ],
        learnings: <String>[
          'WordPress Multisite hing am Longhorn-NFS-Share-Manager (RWX); der Wechsel auf ein Single-Replica-RWO-ext4-Block-Device senkte TTFB von 110 ms auf 65 ms — beim ersten Mal die falsche Storage-Schicht für den Workload gewählt.',
          'Longhorn-RWX-Share-Manager-Pods scheitern still beim Schedulen ohne explizite Taint-Toleration-Einträge; das einzige Signal ist "Pending forever" — Scheduler-Logs früh instrumentieren.',
          'Ein GitOps-reproduzierbarer Cluster zahlt sich am meisten bei seiner zweiten Inkarnation aus: ich habe die ganze Plattform während einer großen Änderung in einem Fork neu aufgebaut, und der Round-Trip war ein Nachmittag.',
        ],
      ),
    },
  ),

  // 03 ----------------------------------------------------------------------
  ProjectItemData(title: 'Sovereign Real-Estate Infrastructure',
    subtitle: 'Self-hosted Linux platform for a 700-unit property manager — 15+ SaaS licenses replaced',
    category: 'DEVSECOPS / SELF-HOSTED',
    platform: 'Netcup · Linux',
    primaryColor: const Color(0xFF065F46),
    image: '$_d/sovereign-immo/cover.webp',
    coverUrl: '$_d/sovereign-immo/cover.webp',
    coverColorUrl: '$_d/sovereign-immo/cover-color.webp',
    technologyUsed:
        'Ubuntu 24.04 → openSUSE Tumbleweed · Docker → Podman · PostgreSQL · MariaDB · MongoDB · Redis · Qdrant · ChromaDB · Portainer · n8n · Baserow · Ghost · OpenWebUI · FastAPI · Casavi / Immoware integration',
    portfolioDescription:
        'A sovereign, fully self-hosted Linux platform built end-to-end '
        'for a property-management firm running 700+ residential units. '
        'Twenty-eight containers, twelve databases and eight customer-'
        'facing services run on a single hardened Netcup vServer; 15+ '
        'commercial SaaS subscriptions were retired in favour of self-'
        'hosted open-source equivalents (Portainer, n8n, Baserow, Ghost, '
        'OpenWebUI, plus a FastAPI integration into the Casavi / '
        'Immoware property-management systems), cutting annual OPEX by '
        '€20,000. When a Netcup hardware upgrade corrupted GRUB and '
        'crashed the whole server, the entire stack was rebuilt on '
        'openSUSE + Podman in five days with zero data loss.',
    isPublic: false,
    isLive: false,
    mockupType: 'terminal',
    screenshots: <String>[],
    decisions: <String>[
      'Picked a **single hardened Netcup vServer** over a Kubernetes cluster — for 700 units, 28 containers and a one-person operations team, the cluster\'s operational overhead would have cost more than the SaaS subscriptions it was meant to replace.',
      'Replaced **15+ commercial SaaS** subscriptions (CRM, internal wiki, no-code DB, ticketing, analytics, blog, vector store) with **Portainer + n8n + Baserow + Ghost + OpenWebUI** plus a small FastAPI shim onto the existing **Casavi / Immoware** property-management APIs. The trade was clear: one operator (me) versus the price of nine separate vendor accounts.',
      'After a **Netcup hardware upgrade corrupted the Ubuntu GRUB bootloader** and brought everything down, migrated the entire stack to **openSUSE Tumbleweed + Podman** rather than just restoring the old Ubuntu/Docker image — rootless Podman removes the daemon as a single point of failure, and Tumbleweed\'s rolling-release model fits a server that genuinely gets attention every week.',
      'Hardened SSH from day one with **publickey-only authentication, no passwords, no root logins**. The auth logs ended up showing **>100,000 brute-force attempts** over the engagement; zero of them got through, and zero ever could.',
      'Codified every host change in **versioned Markdown runbooks** (architecture overview, infra catalog, SSH access guide, SMTP guide, integration credentials) so a successor could rebuild the server without me being on the call.',
    ],
    learnings: <String>[
      '**Disaster recovery is the only honest test of an infrastructure**: rebuilding 28 containers, 12 databases and 8 services across an OS change in 5 days with zero data loss was only possible because every config sat in version control or in a documented runbook. Anything that "only lives in my head" wouldn\'t have survived day one of the rebuild.',
      'For the property-manager scale (~700 units), **n8n + Baserow covered roughly 80% of what would otherwise have been a custom internal-tools build** — n8n is fast for connecting systems and orchestrating simple workflows, but it hits a wall the moment logic needs real types, branching, retries-with-context, or anything that benefits from a debugger. The remaining 20% — the **Casavi / Immoware** legacy-API integration with its odd schemas and missing webhooks — went to a small **FastAPI** service precisely because code gives me proper control where n8n nodes get fragile.',
      'A **single VPS with a documented Docker → Podman migration path** turned out to be more resilient than a "we run Kubernetes" pitch would have implied — when the underlying hardware crashed, the recovery was a known runbook, not an architecture-board meeting.',
    ],
    translations: const <String, ProjectTranslation>{
      'de': ProjectTranslation(
        title: 'Souveräne Immobilien-Infrastruktur',
        subtitle: 'Selbst gehostete Linux-Plattform für einen 700-Einheiten-Verwalter — 15+ SaaS-Lizenzen ersetzt',
        category: 'DEVSECOPS / SELF-HOSTED',
        platform: 'Netcup · Linux',
        technologyUsed:
            'Ubuntu 24.04 → openSUSE Tumbleweed · Docker → Podman · PostgreSQL · MariaDB · MongoDB · Redis · Qdrant · ChromaDB · Portainer · n8n · Baserow · Ghost · OpenWebUI · FastAPI · Casavi-/Immoware-Integration',
        portfolioDescription:
            'Eine souveräne, vollständig selbst gehostete Linux-Plattform, '
            'end-to-end gebaut für ein Hausverwaltungsunternehmen mit '
            'über 700 Wohneinheiten. 28 Container, 12 Datenbanken und 8 '
            'kundennahe Services laufen auf einem einzigen gehärteten '
            'Netcup-vServer; 15+ kommerzielle SaaS-Abos wurden zugunsten '
            'selbst gehosteter Open-Source-Pendants abgelöst (Portainer, '
            'n8n, Baserow, Ghost, OpenWebUI sowie eine FastAPI-Integration '
            'in die Casavi-/Immoware-Hausverwaltungssysteme), was die '
            'jährliche OPEX um 20.000 € reduzierte. Als ein Netcup-'
            'Hardware-Upgrade GRUB beschädigte und den gesamten Server '
            'crashte, wurde der komplette Stack in fünf Tagen ohne '
            'Datenverlust auf openSUSE + Podman neu aufgebaut.',
        decisions: <String>[
          'Einen **einzelnen gehärteten Netcup-vServer** statt eines Kubernetes-Clusters gewählt — bei 700 Einheiten, 28 Containern und einem Ein-Mann-Operations-Team hätte der operative Overhead des Clusters mehr gekostet als die SaaS-Abos, die er ersetzen sollte.',
          '**15+ kommerzielle SaaS**-Abos (CRM, internes Wiki, No-Code-DB, Ticketing, Analytics, Blog, Vector Store) durch **Portainer + n8n + Baserow + Ghost + OpenWebUI** plus einen kleinen FastAPI-Shim auf die bestehenden **Casavi-/Immoware-APIs** ersetzt. Der Trade war klar: ein Operator (ich) gegen den Preis von neun separaten Vendor-Accounts.',
          'Nachdem ein **Netcup-Hardware-Upgrade den Ubuntu-GRUB-Bootloader beschädigte** und alles zum Stillstand brachte, wurde der gesamte Stack auf **openSUSE Tumbleweed + Podman** migriert, statt einfach das alte Ubuntu/Docker-Image wiederherzustellen — rootless Podman entfernt den Daemon als Single Point of Failure, und Tumbleweeds Rolling-Release-Modell passt zu einem Server, der wirklich jede Woche Pflege bekommt.',
          'SSH von Tag eins an mit **Public-Key-Only-Authentifizierung, ohne Passwörter, ohne Root-Logins** gehärtet. Die Auth-Logs zeigten am Ende **>100.000 Brute-Force-Versuche** über die Laufzeit; null davon kamen durch, und null hätten je durchkommen können.',
          'Jede Hoständerung in **versionierten Markdown-Runbooks** kodifiziert (Architektur-Übersicht, Infrastruktur-Katalog, SSH-Access-Guide, SMTP-Guide, Integrations-Credentials), damit ein Nachfolger den Server ohne mich am Telefon neu aufbauen kann.',
        ],
        learnings: <String>[
          '**Disaster Recovery ist der einzige ehrliche Test einer Infrastruktur**: 28 Container, 12 Datenbanken und 8 Services über einen OS-Wechsel in 5 Tagen ohne Datenverlust wieder aufzubauen war nur möglich, weil jede Config in Versionskontrolle oder in einem dokumentierten Runbook stand. Alles, was "nur im Kopf lebt", hätte den ersten Tag des Wiederaufbaus nicht überlebt.',
          'Für die Größenordnung des Hausverwalters (~700 Einheiten) deckten **n8n + Baserow rund 80 % dessen ab, was sonst ein Custom-Internal-Tools-Build geworden wäre** — n8n ist schnell beim Verbinden von Systemen und Orchestrieren einfacher Workflows, stößt aber in dem Moment an seine Grenzen, in dem die Logik echte Typen, Branching, Retries-mit-Kontext oder irgendetwas mit Debugger braucht. Die restlichen 20 % — die **Casavi-/Immoware**-Legacy-API-Integration mit ihren seltsamen Schemas und fehlenden Webhooks — übernahm ein kleiner **FastAPI**-Service, genau weil Code mir die richtige Kontrolle gibt, wo n8n-Nodes fragil werden.',
          'Ein **einzelner VPS mit dokumentiertem Docker-→-Podman-Migrationspfad** erwies sich als robuster als es ein "wir betreiben Kubernetes"-Pitch impliziert hätte — als die zugrundeliegende Hardware crashte, war die Recovery ein bekanntes Runbook, kein Architecture-Board-Meeting.',
        ],
      ),
    },
  ),

  // 04 ----------------------------------------------------------------------
  ProjectItemData(title: 'PostPilot — Social-Media Automation',
    subtitle: 'AI-driven multi-platform content SaaS for SMBs',
    category: 'SAAS / AI',
    platform: 'Web',
    primaryColor: const Color(0xFF0F766E),
    image: '$_d/postflow/cover.webp',
    coverUrl: '$_d/postflow/cover.webp',
    coverColorUrl: '$_d/postflow/cover-color.webp',
    technologyUsed:
        'Next.js 15 · FastAPI · SQLAlchemy 2 async · Alembic · PostgreSQL 16 + pgvector · MinIO · Temporal · LangGraph',
    portfolioDescription:
        'PostPilot is a social-media automation SaaS that lets small '
        'businesses post to nine networks in under 15 minutes a day. '
        'Strict-TypeScript Next.js 15 frontend with shadcn/ui and '
        'TanStack Query talks to an async FastAPI + SQLAlchemy 2 '
        'backend. Temporal orchestrates the long-running posting flows; '
        'LangGraph agents (on GitHub Copilot Pro) draft captions and '
        'platform-specific variants; PostgreSQL 16 + pgvector + MinIO '
        'hold structured data and media. Currently live at '
        'app.benotable.de while the PostPilot domain is provisioned.',
    isPublic: false,
    isLive: true,
    webUrl: 'https://app.benotable.de',
    mockupType: 'laptop',
    screenshots: <String>[],
    decisions: <String>[
      'Picked **Temporal over cron + Redis locks** for the workflow engine — a multi-step "draft → moderate → schedule → post → confirm" flow gets retry, deterministic replay and an inspectable history for free; rebuilding that on plain queues is months of work.',
      'Chose **PostgreSQL 16 + pgvector** instead of a separate vector DB — one backup, one wire protocol, one access-control surface. Operational simplicity beats best-of-breed when the team is one person.',
      'Used **strict TypeScript with no `any` escape hatches** end-to-end against the FastAPI schema; the discipline catches contract drift between client and server in the editor, before any deploy.',
      'Made the GitLab CI **db-backup-first** — the deploy job refuses to run without a fresh snapshot. Adding it cost ten minutes; not adding it would have cost a customer at some point.',
      'Self-hosted on **a single Hetzner CX33** today, but the whole stack is **Kubernetes-ready** from day one: every service ships as a container, every secret is mounted from an env file that maps cleanly onto Kubernetes Secrets, every long-running flow is a Temporal worker. A managed k3s / k8s cluster only earns its keep once the customer base outgrows one node — running a self-maintained cluster at this scale would be uneconomic and over-engineered. The whole stack costs less than the comparable managed Postgres SKU alone, and the platform stays portable to whatever the next scale tier needs.',
    ],
    learnings: <String>[
      'LangGraph-style agent graphs are easier to reason about than chains once you have more than two LLM steps with conditional routing; chains turn spaghetti, graphs stay legible.',
      'Routing GitHub Copilot Pro behind the agents (instead of OpenAI direct) made costs scale linearly with content volume, not exponentially with re-prompts.',
    ],
    translations: const <String, ProjectTranslation>{
      'de': ProjectTranslation(
        title: 'PostPilot — Social-Media-Automation',
        subtitle: 'KI-gestützte Multi-Plattform-Content-SaaS für KMUs',
        category: 'SAAS / KI',
        platform: 'Web',
        technologyUsed:
            'Next.js 15 · FastAPI · SQLAlchemy 2 async · Alembic · PostgreSQL 16 + pgvector · MinIO · Temporal · LangGraph',
        portfolioDescription:
            'PostPilot ist eine Social-Media-Automation-SaaS, mit der '
            'kleine Unternehmen in unter 15 Minuten täglich auf neun '
            'Netzwerken posten können. Ein Next.js-15-Frontend in '
            'strikter TypeScript-Variante mit shadcn/ui und TanStack '
            'Query spricht mit einem asynchronen FastAPI- + SQLAlchemy-2-'
            'Backend. Temporal orchestriert die langlaufenden Posting-'
            'Flows; LangGraph-Agenten (auf GitHub Copilot Pro) entwerfen '
            'Captions und plattformspezifische Varianten; PostgreSQL 16 '
            '+ pgvector + MinIO halten strukturierte Daten und Medien. '
            'Aktuell live unter app.benotable.de, während die PostPilot-'
            'Domain provisioniert wird.',
        decisions: <String>[
          '**Temporal statt cron + Redis-Locks** für die Workflow-Engine gewählt — ein mehrstufiger "Draft → Moderate → Schedule → Post → Confirm"-Flow bekommt Retries, deterministisches Replay und eine inspizierbare History gratis; das auf reinen Queues nachzubauen ist Monate Arbeit.',
          '**PostgreSQL 16 + pgvector** statt einer separaten Vector-DB gewählt — ein Backup, ein Wire-Protocol, eine Access-Control-Surface. Operative Einfachheit schlägt Best-of-Breed, wenn das Team eine Person ist.',
          'Durchgehend **strikte TypeScript ohne `any`-Notausstiege** gegen das FastAPI-Schema verwendet; die Disziplin fängt Contract-Drift zwischen Client und Server im Editor ab, noch vor jedem Deploy.',
          'Den GitLab-CI **db-backup-first** gemacht — der Deploy-Job weigert sich ohne frischen Snapshot. Den hinzuzufügen kostete zehn Minuten; ihn nicht hinzuzufügen hätte irgendwann einen Kunden gekostet.',
          'Heute selbst gehostet auf **einer einzelnen Hetzner CX33**, aber der gesamte Stack ist von Tag eins an **Kubernetes-ready**: jeder Service liefert als Container aus, jedes Secret kommt aus einer Env-Datei, die sauber auf Kubernetes Secrets abbildet, jeder Long-Running-Flow ist ein Temporal-Worker. Ein managed k3s/k8s-Cluster lohnt sich erst, wenn die Kundenbasis über einen Node hinauswächst — einen selbst gewarteten Cluster bei dieser Größenordnung zu betreiben wäre unwirtschaftlich und überengineered. Der gesamte Stack kostet weniger als die vergleichbare Managed-Postgres-SKU allein, und die Plattform bleibt portabel auf das nächste Skalierungsniveau.',
        ],
        learnings: <String>[
          'LangGraph-artige Agenten-Graphen sind einfacher zu durchdenken als Chains, sobald man mehr als zwei LLM-Schritte mit Conditional Routing hat; Chains werden zu Spaghetti, Graphen bleiben lesbar.',
          'GitHub Copilot Pro hinter die Agenten zu routen (statt OpenAI direkt) ließ die Kosten linear mit dem Content-Volumen skalieren, nicht exponentiell mit Re-Prompts.',
        ],
      ),
    },
  ),

  // 05 ----------------------------------------------------------------------
  ProjectItemData(title: 'Coldmailing Lead Platform',
    subtitle: 'CRM-lite outreach platform — segment, status, follow-up, opt-out',
    category: 'SAAS / SALES',
    primaryColor: const Color(0xFF0369A1),
    image: '$_d/coldmailing/cover.webp',
    coverUrl: '$_d/coldmailing/cover.webp',
    coverColorUrl: '$_d/coldmailing/cover-color.webp',
    platform: 'Web · Self-hosted',
    technologyUsed:
        'Python · Flask · NocoDB · PostgreSQL · Email API · Podman Compose',
    portfolioDescription:
        'A containerised outreach platform built around the parts of '
        'cold outreach that actually matter — segments, campaign status, '
        'follow-up cadences and opt-out plumbing — not blast volume. A '
        'small Flask app drives the campaign engine; NocoDB acts as the '
        'business UI so operators can edit lists, sequences and offers '
        'without a developer; Podman Compose keeps the whole stack '
        'portable for SMBs that want their own data. The point of the '
        'system is to turn a CSV-and-Outlook workflow into a measurable '
        'pipeline with deliverability monitoring and rule-of-law '
        'opt-out tracking.',
    isPublic: false,
    isLive: false,
    mockupType: 'laptop',
    screenshots: <String>[],
    decisions: <String>[
      'Built the back office on **NocoDB instead of a custom admin panel** — operators get sortable views, filters and inline edits for free; a hand-rolled CRUD admin would have eaten the whole MVP timeline and still been worse to use.',
      'Picked **Flask over Django** because the surface is small (a few campaign endpoints, a queue worker, a few webhooks) — Django\'s ORM and admin would have been dead weight for an app this thin.',
      'Modelled outreach as **campaigns + sequences + opt-out events**, not "send a mail" — the unit that matters is the lead\'s lifecycle, not the individual message; treating each send as a stateless action is exactly how outbound goes wrong.',
      'Made **opt-out a first-class write path with its own audit table** — German cold-outreach law is unforgiving, and "we lost the unsubscribe in a queue retry" is not a defence anyone wants to mount.',
    ],
    learnings: <String>[
      'Outbound rarely fails at sending; it fails at segment, status, follow-up and reporting. The platform that wins is the one that turns a CSV-plus-Outlook habit into a visible pipeline.',
      'Deliverability is mostly an IP-warmup and authentication problem, not a template-quality problem — moving SPF / DKIM / DMARC discipline up the priority list paid back faster than any prompt tuning.',
    ],
    translations: const <String, ProjectTranslation>{
      'de': ProjectTranslation(
        title: 'Coldmailing Lead-Plattform',
        subtitle: 'CRM-Lite Outreach-Plattform — Segment, Status, Follow-up, Opt-out',
        category: 'SAAS / VERTRIEB',
        platform: 'Web · Self-hosted',
        technologyUsed:
            'Python · Flask · NocoDB · PostgreSQL · Email-API · Podman Compose',
        portfolioDescription:
            'Eine containerisierte Outreach-Plattform, gebaut um die '
            'Teile von Cold Outreach, die wirklich zählen — Segmente, '
            'Kampagnen-Status, Follow-up-Kadenzen und Opt-out-Plumbing — '
            'nicht um Versand-Volumen. Eine kleine Flask-App treibt die '
            'Kampagnen-Engine; NocoDB dient als Business-UI, sodass '
            'Operatoren Listen, Sequenzen und Angebote ohne Entwickler '
            'bearbeiten können; Podman Compose hält den ganzen Stack '
            'portabel für KMUs, die ihre eigenen Daten wollen. Der Sinn '
            'des Systems ist, einen CSV-und-Outlook-Workflow in eine '
            'messbare Pipeline mit Deliverability-Monitoring und '
            'rechtskonformem Opt-out-Tracking zu verwandeln.',
        decisions: <String>[
          'Das Back-Office auf **NocoDB statt einem Custom-Admin-Panel** gebaut — Operatoren bekommen sortierbare Views, Filter und Inline-Edits gratis; ein selbstgebautes CRUD-Admin hätte das ganze MVP-Budget gefressen und wäre trotzdem schlechter zu bedienen gewesen.',
          '**Flask gegenüber Django** gewählt, weil die Surface klein ist (ein paar Kampagnen-Endpunkte, ein Queue-Worker, ein paar Webhooks) — Djangos ORM und Admin wären für eine so schlanke App totes Gewicht gewesen.',
          'Outreach als **Kampagnen + Sequenzen + Opt-out-Events** modelliert, nicht als "send a mail" — die Einheit, die zählt, ist der Lifecycle des Leads, nicht die einzelne Nachricht; jeden Versand als zustandslose Aktion zu behandeln, ist genau, wie Outbound schiefläuft.',
          '**Opt-out zu einem First-Class-Write-Path mit eigener Audit-Tabelle** gemacht — deutsches Recht im Cold Outreach ist unerbittlich, und "wir haben das Unsubscribe in einem Queue-Retry verloren" ist keine Verteidigung, die irgendjemand vortragen möchte.',
        ],
        learnings: <String>[
          'Outbound scheitert selten am Versand; es scheitert an Segment, Status, Follow-up und Reporting. Die Plattform, die gewinnt, ist die, die eine CSV-plus-Outlook-Routine in eine sichtbare Pipeline verwandelt.',
          'Deliverability ist meist ein IP-Warmup- und Authentifizierungs-Problem, kein Template-Qualitäts-Problem — die SPF-/DKIM-/DMARC-Disziplin in der Priorität nach oben zu schieben zahlte sich schneller aus als jedes Prompt-Tuning.',
        ],
      ),
    },
  ),

  // 06 ----------------------------------------------------------------------
  ProjectItemData(title: 'LuminaRep — Clinic Review SaaS',
    subtitle: 'AI social-proof platform for medical-aesthetics practices',
    category: 'SAAS / AI',
    platform: 'Web',
    primaryColor: const Color(0xFF047857),
    image: '$_d/luminarep/cover.webp',
    coverUrl: '$_d/luminarep/cover.webp',
    coverColorUrl: '$_d/luminarep/cover-color.webp',
    technologyUsed:
        'Next.js 15 · TypeScript · PostgreSQL · NextAuth · Google Gemini · Stripe · Tailwind · Docker Compose',
    portfolioDescription:
        'LuminaRep is a premium SaaS for medical-aesthetics and '
        'cosmetic-surgery clinics. It auto-extracts each clinic\'s '
        '5-star Google reviews and turns every one into three Instagram '
        'captions, a TikTok script and Midjourney/DALL-E image prompts '
        'in the practice\'s tone of voice. Email-and-password auth via '
        'NextAuth, Stripe metered subscriptions with a 7-day trial, '
        'and a luxury dark-mode UI in emerald + gold. Fully '
        'containerised — a clinic that wants self-hosting can run the '
        'whole platform on its own server.',
    isPublic: false,
    isLive: true,
    mockupType: 'laptop',
    screenshots: <String>[],
    decisions: <String>[
      'Picked **Gemini for the content-generation pass** over GPT-4 and Claude — in side-by-side testing on real clinic reviews, Gemini consistently produced the most clinic-friendly tone with the fewest hallucinated medical claims (which would have been a regulatory risk).',
      'Chose **NextAuth for email + password** instead of a third-party identity provider — clinics are GDPR-sensitive and a small attack surface I fully control beat outsourcing to a vendor I\'d have to audit anyway.',
      'Designed the **5-star-only review-extraction funnel** rather than letting clinics cherry-pick — auto-extraction removes the cognitive load that kills retention, and the constraint is a feature ("we only ever amplify your real wins").',
      'Bundled the whole stack into **Docker Compose with a production deploy guide** — clinics can keep patient-adjacent data on premises if they need to, without me having to support a second deployment path.',
    ],
    learnings: <String>[
      'A luxury dark-mode UI (emerald + gold) actually mattered more to clinic owners than the underlying tech — design investment paid back faster than feature work in early sales conversations.',
    ],
    translations: const <String, ProjectTranslation>{
      'de': ProjectTranslation(
        title: 'LuminaRep — Klinik-Bewertungs-SaaS',
        subtitle: 'KI-Social-Proof-Plattform für medizinisch-ästhetische Praxen',
        category: 'SAAS / KI',
        platform: 'Web',
        technologyUsed:
            'Next.js 15 · TypeScript · PostgreSQL · NextAuth · Google Gemini · Stripe · Tailwind · Docker Compose',
        portfolioDescription:
            'LuminaRep ist eine Premium-SaaS für Kliniken im Bereich '
            'medizinische Ästhetik und Schönheitschirurgie. Sie '
            'extrahiert automatisch die 5-Sterne-Google-Bewertungen '
            'jeder Klinik und macht aus jeder davon drei Instagram-'
            'Captions, ein TikTok-Skript und Midjourney-/DALL-E-Bild-'
            'Prompts im Tonfall der Praxis. E-Mail-Passwort-Auth via '
            'NextAuth, Stripe-Metered-Subscriptions mit 7-Tage-Trial '
            'und ein luxuriöses Dark-Mode-UI in Smaragd + Gold. '
            'Vollständig containerisiert — eine Klinik, die Self-Hosting '
            'will, kann die ganze Plattform auf ihrem eigenen Server '
            'betreiben.',
        decisions: <String>[
          '**Gemini für den Content-Generation-Pass** gegenüber GPT-4 und Claude gewählt — im direkten Vergleich auf echten Klinik-Bewertungen produzierte Gemini konsistent den klinikfreundlichsten Tonfall mit den wenigsten halluzinierten medizinischen Aussagen (was ein regulatorisches Risiko gewesen wäre).',
          '**NextAuth für E-Mail + Passwort** statt eines Third-Party-Identity-Providers gewählt — Kliniken sind DSGVO-sensibel, und eine kleine Angriffsfläche, die ich voll kontrolliere, schlug das Outsourcen an einen Vendor, den ich ohnehin hätte auditieren müssen.',
          'Den **Funnel auf reine 5-Sterne-Extraktion** ausgelegt, statt Kliniken Rosinen picken zu lassen — die Auto-Extraktion nimmt die kognitive Last raus, die Retention killt, und die Einschränkung ist ein Feature ("wir verstärken immer nur eure echten Wins").',
          'Den ganzen Stack in **Docker Compose mit Production-Deploy-Guide** gebündelt — Kliniken können patientennahe Daten on-premise halten, ohne dass ich einen zweiten Deployment-Pfad supporten muss.',
        ],
        learnings: <String>[
          'Ein luxuriöses Dark-Mode-UI (Smaragd + Gold) war für Klinikinhaber tatsächlich wichtiger als die zugrundeliegende Technik — das Design-Investment zahlte sich in frühen Sales-Gesprächen schneller aus als Feature-Arbeit.',
        ],
      ),
    },
  ),

  // 07 ----------------------------------------------------------------------
  ProjectItemData(title: 'LLM Mail Triage — Intent Engine',
    subtitle: 'Pluggable-provider email classification + drafting service',
    category: 'AI / AUTOMATION',
    platform: 'Backend',
    primaryColor: const Color(0xFF7C3AED),
    image: '$_d/llm-mail/cover.webp',
    coverUrl: '$_d/llm-mail/cover.webp',
    coverColorUrl: '$_d/llm-mail/cover-color.webp',
    technologyUsed:
        'Python · FastAPI · RAG · Vector DB · Pluggable Mistral / Claude / OpenAI / local OpenWebUI',
    portfolioDescription:
        'A multi-provider LLM service that turns a noisy inbox into '
        'structured tickets. A three-stage pipeline classifies each '
        'incoming mail into one of eleven categories, extracts sender + '
        'intent + structured fields, and drafts a reply — strictly '
        'behind a human-in-the-loop gate. Provider is pluggable via a '
        'single config (Mistral / Claude / OpenAI / local OpenWebUI), '
        'so EU-residency requirements get a config change instead of a '
        'refactor. Throughput climbed 80%, accuracy holds at 95%, and '
        'the service saves about 8 engineering-hours/week on a real '
        'customer mailbox.',
    isPublic: false,
    isLive: true,
    mockupType: 'terminal',
    screenshots: <String>[],
    decisions: <String>[
      'Enforced **strict JSON-schema mode on every LLM reply** with retry-on-parse-failure — the accuracy lift from that constraint alone was bigger than from swapping for a bigger model. Larger model with loose JSON still hallucinated tags.',
      'Designed an **LLM_PROVIDER abstraction over a single env var** so EU-residency clients can switch from OpenAI to Mistral or to a self-hosted OpenWebUI without code changes; the alternative — per-tenant builds — would have multiplied the deployment matrix.',
      'Kept the service **stateless** with a **mock mode default when keys are missing** — contributors can run and test the full stack without consuming tokens, and CI can run the end-to-end suite without a budget line.',
      'Made the **human-in-the-loop a hard gate** rather than an opt-in — auto-send in a regulated industry has unbounded downside, and the throughput win comes from triage + drafting, not from sending.',
    ],
    learnings: <String>[
      'Eleven-category classification needed three rounds of taxonomy refinement; the first gold set was missing three categories I only discovered by reading the long-tail of real mail.',
      'JSON-schema enforcement is the highest-leverage knob in LLM serving today — it bought more correctness than two model-size jumps would have.',
    ],
    translations: const <String, ProjectTranslation>{
      'de': ProjectTranslation(
        title: 'LLM Mail-Triage — Intent Engine',
        subtitle: 'Provider-agnostischer Dienst für E-Mail-Klassifizierung + Entwürfe',
        category: 'KI / AUTOMATION',
        platform: 'Backend',
        technologyUsed:
            'Python · FastAPI · RAG · Vector-DB · austauschbar Mistral / Claude / OpenAI / lokales OpenWebUI',
        portfolioDescription:
            'Ein Multi-Provider-LLM-Service, der aus einer lauten Inbox '
            'strukturierte Tickets macht. Eine dreistufige Pipeline '
            'klassifiziert jede eingehende Mail in eine von elf '
            'Kategorien, extrahiert Sender + Intent + strukturierte '
            'Felder und entwirft eine Antwort — strikt hinter einem '
            'Human-in-the-Loop-Gate. Der Provider ist über eine einzige '
            'Config austauschbar (Mistral / Claude / OpenAI / lokales '
            'OpenWebUI), sodass EU-Residency-Anforderungen einen Config-'
            'Change bekommen statt eines Refactors. Der Durchsatz stieg '
            'um 80 %, die Genauigkeit hält bei 95 %, und der Service '
            'spart etwa 8 Engineering-Stunden/Woche an einem echten '
            'Kundenpostfach.',
        decisions: <String>[
          'Bei jedem LLM-Reply **strikten JSON-Schema-Mode mit Retry-on-Parse-Failure** erzwungen — der Genauigkeits-Lift allein durch diese Constraint war größer als der Wechsel auf ein größeres Modell. Größere Modelle mit lockerem JSON halluzinierten weiterhin Tags.',
          'Eine **LLM_PROVIDER-Abstraktion über eine einzige Env-Variable** entworfen, damit EU-Residency-Kunden ohne Codeänderung von OpenAI auf Mistral oder ein selbst gehostetes OpenWebUI wechseln können; die Alternative — Builds pro Tenant — hätte die Deployment-Matrix vervielfacht.',
          'Den Service **zustandslos** gehalten mit einem **Mock-Mode als Default, wenn Keys fehlen** — Contributors können den ganzen Stack laufen und testen, ohne Tokens zu verbrauchen, und CI kann die End-to-End-Suite ohne Kostenstelle ausführen.',
          'Das **Human-in-the-Loop zu einem harten Gate** gemacht statt zu einem Opt-in — Auto-Send in einer regulierten Branche hat unbegrenztes Downside, und der Throughput-Gewinn kommt aus Triage + Drafting, nicht aus dem Senden.',
        ],
        learnings: <String>[
          'Die 11-Kategorien-Klassifikation brauchte drei Runden Taxonomie-Verfeinerung; im ersten Gold-Set fehlten drei Kategorien, die ich erst durch das Lesen des Long-Tails echter Mails entdeckt habe.',
          'JSON-Schema-Erzwingung ist heute der wirkungsvollste Hebel beim LLM-Serving — sie brachte mehr Korrektheit als zwei Modellgrößen-Sprünge gebracht hätten.',
        ],
      ),
    },
  ),

  // 08 ----------------------------------------------------------------------
  ProjectItemData(title: 'Utopia Community',
    subtitle: 'Environmental Web3 platform — Technical Lead',
    category: 'WEB3 / CHARITY',
    platform: 'iOS · Android · Web',
    primaryColor: const Color(0xFF16A34A),
    image: '$_d/utopia/cover.webp',
    coverUrl: '$_d/utopia/cover.webp',
    coverColorUrl: '$_d/utopia/cover-color.webp',
    technologyUsed:
        'Flutter · Solidity 0.8 · OpenZeppelin · UUPS Proxy · Polygon · Firebase',
    portfolioDescription:
        'A cross-platform Flutter app paired with an upgradeable ERC-20 '
        '(UWCT) on Polygon, channelling token-aligned donations into '
        'environmental and charitable causes. As Technical Lead of a '
        'remote agile team of two I owned the full roadmap from token '
        'economics through requirements engineering to UI, and shipped '
        'a feature-complete MVP in 12 months. Demoed at the KUER.NRW '
        'Green Entrepreneurship Fair to 20+ stakeholders and investors.',
    isPublic: false,
    isLive: true,
    mockupType: 'phone',
    screenshots: <String>[],
    decisions: <String>[
      'Picked **Polygon over Ethereum mainnet** for the token contract — gas costs on L1 would have killed any micro-donation use case before the first transaction settled.',
      'Used a **UUPS upgradeable proxy (OpenZeppelin)** rather than a non-upgradeable token because the protocol logic was certain to evolve, and forcing token holders to migrate is a one-way trip to abandonment.',
      'Made **every supply-mutating operation (mint, burn, pause) multi-signature** — a single key on a charity token is a single point of failure for the entire mission.',
      'Chose **Flutter cross-platform** for the wallet UI over a Web3 web frontend — donors are on phones, not desktops; meeting them where they are dropped onboarding friction.',
    ],
    learnings: <String>[
      'Demoing at KUER.NRW forced the team to articulate value to non-technical stakeholders in 30 seconds. That single exercise rewrote half the project documentation.',
      'Token-economics design (vesting, governance thresholds, burn mechanics) consumed more time than the smart-contract code itself — model the incentives before the code.',
    ],
    translations: const <String, ProjectTranslation>{
      'de': ProjectTranslation(
        title: 'Utopia Community',
        subtitle: 'Web3-Umweltplattform — Technical Lead',
        category: 'WEB3 / SPENDEN',
        platform: 'iOS · Android · Web',
        technologyUsed:
            'Flutter · Solidity 0.8 · OpenZeppelin · UUPS Proxy · Polygon · Firebase',
        portfolioDescription:
            'Eine plattformübergreifende Flutter-App gepaart mit einem '
            'upgradefähigen ERC-20 (UWCT) auf Polygon, die token-'
            'gebundene Spenden in Umwelt- und Wohltätigkeitsprojekte '
            'kanalisiert. Als Technical Lead eines remote arbeitenden '
            'agilen Zweier-Teams habe ich die volle Roadmap von der '
            'Token-Ökonomie über Requirements Engineering bis zum UI '
            'verantwortet und in 12 Monaten ein feature-vollständiges '
            'MVP ausgeliefert. Auf der KUER.NRW Green-Entrepreneurship-'
            'Messe vor 20+ Stakeholdern und Investoren demonstriert.',
        decisions: <String>[
          '**Polygon gegenüber Ethereum-Mainnet** für den Token-Vertrag gewählt — Gaskosten auf L1 hätten jeden Mikrospenden-Use-Case getötet, bevor die erste Transaktion settled wäre.',
          'Einen **UUPS-Upgradeable-Proxy (OpenZeppelin)** statt eines nicht-upgradefähigen Tokens verwendet, weil die Protokoll-Logik sich sicher weiterentwickeln würde, und Token-Holder zur Migration zu zwingen ist eine Einbahnstraße ins Vergessen.',
          '**Jede Supply-mutierende Operation (mint, burn, pause) multi-signatur** gemacht — ein einzelner Key auf einem Charity-Token ist ein Single Point of Failure für die gesamte Mission.',
          '**Flutter Cross-Platform** für das Wallet-UI gegenüber einem Web3-Web-Frontend gewählt — Spender sind am Handy, nicht am Desktop; sie dort abzuholen, wo sie sind, senkte die Onboarding-Hürde.',
        ],
        learnings: <String>[
          'Die Demo auf der KUER.NRW zwang das Team, den Wert in 30 Sekunden für nicht-technische Stakeholder zu artikulieren. Diese eine Übung schrieb die halbe Projektdokumentation neu.',
          'Token-Ökonomie-Design (Vesting, Governance-Schwellen, Burn-Mechanik) verschlang mehr Zeit als der Smart-Contract-Code selbst — die Anreize vor dem Code modellieren.',
        ],
      ),
    },
  ),

  // 09 ----------------------------------------------------------------------
  ProjectItemData(title: 'Night-Drive Object Detection',
    subtitle: 'TU Dortmund Institute of Robotics — thesis + paper + Unreal C++ plugin',
    category: 'ML / ROBOTICS RESEARCH',
    platform: 'Unreal · Python',
    primaryColor: const Color(0xFF1E1B4B),
    image: '$_d/thesis-night/cover.webp',
    coverUrl: '$_d/thesis-night/cover.webp',
    coverColorUrl: '$_d/thesis-night/cover-color.webp',
    technologyUsed:
        'Unreal Engine 5 (C++) · UE CitySample · custom labeller · YOLOv8 · Python · PyTorch · C++',
    portfolioDescription:
        'My full body of work at the TU Dortmund Institute of Robotics: a '
        'B.Sc. thesis on CNN-based night-time object detection and the '
        'companion paper formalising the lighting/training-parameter '
        'analysis (both graded 1.3 — top decile), plus a first-party '
        'Unreal Engine 5 C++ plugin that exposes semantic segmentation '
        'to gameplay and writes YOLOv8-ready datasets. Renders were '
        'taken from Epic\'s public UE5 CitySample so the visual '
        'fidelity was production-grade from day one; a custom labelling '
        'pipeline replaced NVIDIA\'s NDDS — which only ever shipped for '
        'Unreal 4 and could not be ported through UE5\'s rewritten '
        'rendering layer. The combination eliminated 100% of manual '
        'annotation across 6,000+ training samples.',
    isPublic: false,
    isLive: false,
    mockupType: 'unreal-still',
    screenshots: <String>[
      '$_d/thesis-night/shot-01.webp',
      '$_d/thesis-night/shot-02.webp',
      '$_d/thesis-night/shot-03.webp',
    ],
    decisions: <String>[
      'Generated the entire training set from a **synthetic Unreal Engine 5 city** instead of collecting real night-driving footage — annotation cost dropped to zero and every lighting parameter became exact, reproducible and ablatable. Real-world footage would have required either an army of annotators or a sketchy active-learning loop.',
      'Built a **custom labelling pipeline inside the UE5 C++ plugin** rather than relying on NVIDIA NDDS — NDDS only shipped for Unreal Engine 4 and porting it across UE5\'s rewritten rendering pipeline was a dead end (the changes were deep enough that no working migration path existed). The custom pipeline kept the labeller bundled with the renderer on the same render thread, no separate annotation infrastructure to drift out of sync with the simulator.',
      'Used **Epic\'s public UE5 CitySample** instead of generating geometry procedurally — CitySample ships a production-grade dense city for free; rebuilding that level of detail in Houdini or by hand would have consumed the thesis and added nothing the experiment actually needed.',
      'Built the segmentation logic as a **first-party Unreal C++ plugin** rather than an external Python pipeline so the dataset generator stayed on the same render thread as the scene — no copy-out-to-disk-and-back per frame.',
      'Treated the **paper as a parallel deliverable to the thesis**, not an afterthought — both were graded 1.3 (top decile) because writing the analysis up to publication standards forced the experimental method to be defended explicitly, which sharpened the thesis itself.',
    ],
    learnings: <String>[
      'Five environmental parameters disproportionately drove CNN feature extraction; everything else was noise. Future synthetic-data work should ablate on these five before touching architecture.',
      'Closing the sim-to-real gap is more about distribution matching than render fidelity — lower-quality renders with the right distribution beat photoreal renders with the wrong one.',
      'Treating the plugin as a deliverable in its own right (not buried in a thesis appendix) made the work reusable: anyone with UE5 can regenerate the dataset.',
      'When an upstream tool (here NDDS) stops at a version boundary you need to cross, **reimplementing the part you actually use is faster than porting it**. The custom labeller turned out to be ~200 lines of C++; the NDDS port would have been a months-long render-pipeline rewrite.',
    ],
    translations: const <String, ProjectTranslation>{
      'de': ProjectTranslation(
        title: 'Nachtfahrt-Objekterkennung',
        subtitle: 'TU Dortmund Institut für Robotik — Bachelorarbeit + Paper + Unreal C++ Plugin',
        category: 'ML / ROBOTIK-FORSCHUNG',
        platform: 'Unreal · Python',
        technologyUsed:
            'Unreal Engine 5 (C++) · UE CitySample · Custom-Labeller · YOLOv8 · Python · PyTorch · C++',
        portfolioDescription:
            'Meine gesamte Arbeit am TU Dortmund Institut für Robotik: '
            'eine B.Sc.-Thesis zu CNN-basierter Nacht-Objekterkennung '
            'und das begleitende Paper, das die Beleuchtungs-/Training-'
            'Parameter-Analyse formalisiert (beide mit 1,3 benotet — '
            'oberes Dezil), plus ein First-Party-Unreal-Engine-5-C++-'
            'Plugin, das semantische Segmentierung ans Gameplay '
            'exponiert und YOLOv8-fertige Datasets schreibt. Renderings '
            'kamen aus Epics öffentlichem UE5 CitySample, sodass die '
            'visuelle Qualität ab Tag eins produktionsreif war; eine '
            'Custom-Labelling-Pipeline ersetzte NVIDIAs NDDS — das nur '
            'für Unreal 4 ausgeliefert wurde und durch die neu '
            'geschriebene UE5-Rendering-Schicht nicht portierbar war. '
            'Die Kombination eliminierte 100 % der manuellen Annotation '
            'über mehr als 6.000 Trainings-Samples.',
        decisions: <String>[
          'Den gesamten Trainingsdatensatz aus einer **synthetischen Unreal-Engine-5-Stadt** generiert statt echtes Nacht-Fahrmaterial zu sammeln — die Annotation-Kosten fielen auf null, und jeder Beleuchtungsparameter wurde exakt, reproduzierbar und ablatierbar. Reales Material hätte entweder eine Armee Annotatoren oder einen zweifelhaften Active-Learning-Loop gebraucht.',
          'Eine **Custom-Labelling-Pipeline ins UE5-C++-Plugin** gebaut statt auf NVIDIA NDDS zu setzen — NDDS lieferte nur für Unreal Engine 4 aus, und die Portierung durch UE5s neu geschriebene Rendering-Pipeline war eine Sackgasse (die Änderungen waren tief genug, dass es keinen funktionierenden Migrationspfad gab). Die Custom-Pipeline hielt den Labeller mit dem Renderer auf demselben Render-Thread gebündelt, keine separate Annotation-Infrastruktur, die mit dem Simulator aus dem Tritt geraten kann.',
          '**Epics öffentliches UE5 CitySample** verwendet statt Geometrie prozedural zu erzeugen — CitySample liefert eine produktionsreife dichte Stadt kostenlos; dieses Detailniveau in Houdini oder von Hand nachzubauen hätte die Thesis verschlungen und dem Experiment nichts hinzugefügt, was es wirklich brauchte.',
          'Die Segmentierungs-Logik als **First-Party-Unreal-C++-Plugin** gebaut statt als externe Python-Pipeline, damit der Dataset-Generator auf demselben Render-Thread wie die Szene blieb — kein Copy-out-to-disk-and-back pro Frame.',
          '**Das Paper als paralleles Deliverable zur Thesis** behandelt, nicht als Nachgedanken — beide wurden mit 1,3 benotet (oberes Dezil), weil das Hochschreiben auf Publikationsniveau die experimentelle Methode zwang, explizit verteidigt zu werden, was die Thesis selbst geschärft hat.',
        ],
        learnings: <String>[
          'Fünf Umgebungsparameter trieben die CNN-Feature-Extraktion unverhältnismäßig stark; alles andere war Rauschen. Künftige synthetische-Daten-Arbeit sollte auf diesen fünf ablatieren, bevor sie an die Architektur geht.',
          'Den Sim-to-Real-Gap zu schließen ist mehr eine Frage von Distribution-Matching als von Render-Fidelity — Renderings niedrigerer Qualität mit der richtigen Verteilung schlagen photorealistische Renderings mit der falschen.',
          'Das Plugin als eigenständiges Deliverable zu behandeln (statt es im Thesis-Anhang zu vergraben) machte die Arbeit wiederverwendbar: jeder mit UE5 kann den Datensatz neu erzeugen.',
          'Wenn ein Upstream-Tool (hier NDDS) an einer Versionsgrenze stehen bleibt, die man überqueren muss, ist **das Stück, das man tatsächlich nutzt, neu zu implementieren, schneller als es zu portieren**. Der Custom-Labeller wurde am Ende ~200 Zeilen C++; der NDDS-Port wäre ein monatelanges Rendering-Pipeline-Rewrite gewesen.',
        ],
      ),
    },
  ),

  // 10 ----------------------------------------------------------------------
  ProjectItemData(title: 'VR Anxiety Trainer',
    subtitle: '1st place — TU Dortmund Startup Weekend 2023',
    category: 'VR / HEALTHCARE',
    platform: 'Meta Quest',
    primaryColor: const Color(0xFF6D28D9),
    // The opera-house cinematic lives ONLY in the /05 SHOTS gallery
    // (3D animated DeviceMockup) — not as a hover cover. The home tile
    // therefore falls back to the plain colour wipe on hover.
    image: '$_d/vr-anxiety/cover.webp',
    coverUrl: '$_d/vr-anxiety/cover.webp',
    technologyUsed: 'Unreal Engine 5 · Blueprints · OpenXR',
    portfolioDescription:
        'A VR exposure-therapy prototype for social anxiety, set on the '
        'stage of a virtual opera house. Own the room, walk to the '
        'centre, deliver a short speech to a virtual audience while a '
        'coach script guides the breathing. Won 1st place at TU '
        'Dortmund Startup Weekend 2023, outperforming nine competing '
        'teams on technical execution and market validation; selected '
        'to advance into the university\'s incubator pipeline.',
    isPublic: false,
    isLive: false,
    mockupType: 'unreal-still',
    screenshots: <String>[
      '$_d/vr-anxiety/shot-01.webp',
    ],
    decisions: <String>[
      'Picked **Unreal Engine 5** over Unity for the build because the team had Unreal expertise and the photoreal opera scene needed Lumen — Unity\'s URP at the time wouldn\'t have hit the same visual bar in a single weekend.',
      'Built the **smallest believable scenario** (walk to the stage, deliver a short speech) instead of trying for breadth across multiple anxiety triggers — depth reads as polish to judges; breadth at a hackathon reads as half-finished.',
      'Put the coach script + breathing guidance in **audio, not a HUD** — a heads-up display in VR breaks immersion the moment the user looks at it, and immersion is the entire therapeutic mechanism.',
    ],
    learnings: <String>[
      'Winning a hackathon comes down to demoable depth in 48 hours, not feature count — we rehearsed the demo more than we built features in the last twelve hours.',
      'Selection into the university\'s incubator pipeline turned out to be worth the weekend many times over.',
    ],
    translations: const <String, ProjectTranslation>{
      'de': ProjectTranslation(
        title: 'VR Anxiety Trainer',
        subtitle: '1. Platz — TU Dortmund Startup Weekend 2023',
        category: 'VR / GESUNDHEIT',
        platform: 'Meta Quest',
        technologyUsed: 'Unreal Engine 5 · Blueprints · OpenXR',
        portfolioDescription:
            'Ein VR-Expositions-Therapie-Prototyp für soziale Ängste, '
            'angesiedelt auf der Bühne eines virtuellen Opernhauses. '
            'Den Raum in Besitz nehmen, zur Bühnenmitte gehen, eine '
            'kurze Rede vor virtuellem Publikum halten, während ein '
            'Coach-Skript die Atmung führt. 1. Platz beim TU Dortmund '
            'Startup Weekend 2023 — vor neun konkurrierenden Teams in '
            'technischer Umsetzung und Marktvalidierung; ausgewählt für '
            'die Inkubator-Pipeline der Universität.',
        decisions: <String>[
          '**Unreal Engine 5** gegenüber Unity gewählt, weil das Team Unreal-Erfahrung hatte und die photorealistische Opernszene Lumen brauchte — Unitys URP hätte zu dem Zeitpunkt in einem einzigen Wochenende nicht denselben visuellen Standard erreicht.',
          'Das **kleinste glaubhafte Szenario** gebaut (zur Bühne gehen, kurze Rede halten) statt Breite über mehrere Angst-Trigger zu versuchen — Tiefe liest sich als Politur für Jurys; Breite an einem Hackathon liest sich als halb fertig.',
          'Das Coach-Skript + die Atemführung in **Audio statt in einem HUD** untergebracht — ein Heads-up-Display in VR bricht die Immersion in dem Moment, in dem der User hinschaut, und Immersion ist der gesamte therapeutische Mechanismus.',
        ],
        learnings: <String>[
          'Einen Hackathon zu gewinnen läuft auf demobare Tiefe in 48 Stunden hinaus, nicht auf Feature-Count — wir haben die Demo in den letzten zwölf Stunden mehr geprobt als Features gebaut.',
          'Die Auswahl für die Inkubator-Pipeline der Uni war das Wochenende vielfach wert.',
        ],
      ),
    },
  ),

  // 11 ----------------------------------------------------------------------
  ProjectItemData(title: 'Durak — Cross-Platform Card Game',
    subtitle: 'Six-platform Flutter card game — iOS · Android · Web · Desktop',
    category: 'GAME / MOBILE',
    platform: 'iOS · Android · Web · Desktop',
    primaryColor: const Color(0xFFDC2626),
    image: '$_d/durak/cover.webp',
    coverUrl: '$_d/durak/cover.webp',
    coverColorUrl: '$_d/durak/cover-color.webp',
    technologyUsed:
        'Flutter · Dart · GetX · WebSockets · PostgreSQL · Playwright E2E',
    portfolioDescription:
        'A polished Flutter implementation of the classic Russian Durak '
        'card game, shipped to six platforms (Android, iOS, Web, '
        'Windows, macOS, Linux) from a single codebase. Three AI '
        'difficulty levels run fully offline; the move generator scores '
        'every legal attack/defend pair against a heuristic that mirrors '
        'how strong human players think about trump leverage and '
        'hand-reduction. Custom rendering pushes 60 FPS on commodity '
        'hardware, GetX drives a reactive state graph, 31 unit tests + '
        'Playwright E2E protect the core rules, and the socket layer is '
        'staged for online multiplayer. The OPEN LIVE button below jumps '
        'straight to the running build.',
    isPublic: false,
    isLive: true,
    webUrl: 'https://durak.burakbasci.de',
    mockupType: 'phone',
    screenshots: <String>[
      '$_d/durak/shot-01.webp',
      '$_d/durak/shot-02.webp',
    ],
    decisions: <String>[
      'Extracted a **`GameRules` interface + `GameRegistry`** in Phase 13 so the engine could ship Hearts, Spades, Belote, Preferans and Uno without forking the game logic — previously every new variant was a copy-paste, which was bound to drift.',
      'Adopted **Playwright E2E (32 tests) + server API tests (10) + exhaustive rule unit tests (57)** only after a 15-bug spike around the card-flip z-index — total >100 tests now block every release. Skipping E2E once cost a full week of regressions.',
      'Used **WebSockets + Elo-based matchmaking with guest-token persistence** so people can play without registering. Required registration on a cards app destroys retention; the cost of supporting guests is rounding error.',
      'Picked **GetX over Bloc/Riverpod** for state — at the time it had the lowest boilerplate-per-feature for a small team, and the reactive bindings fit a turn-based game cleanly.',
    ],
    learnings: <String>[
      'A rolling-update deadlock bit us with required pod-anti-affinity + maxSurge>0 on the deployment; fix was `maxUnavailable: 1, maxSurge: 0` so a new pod can\'t starve a still-needed old one.',
      'Localising in four languages (EN/RU/TR/DE) roughly doubled organic downloads in the test markets at the cost of one engineering week — best ROI of the year.',
    ],
    translations: const <String, ProjectTranslation>{
      'de': ProjectTranslation(
        title: 'Durak — Plattformübergreifendes Kartenspiel',
        subtitle: 'Sechs-Plattform Flutter Kartenspiel — iOS · Android · Web · Desktop',
        category: 'SPIEL / MOBIL',
        platform: 'iOS · Android · Web · Desktop',
        technologyUsed:
            'Flutter · Dart · GetX · WebSockets · PostgreSQL · Playwright E2E',
        portfolioDescription:
            'Eine polierte Flutter-Implementierung des klassischen '
            'russischen Kartenspiels Durak, ausgeliefert auf sechs '
            'Plattformen (Android, iOS, Web, Windows, macOS, Linux) aus '
            'einer einzigen Codebasis. Drei KI-Schwierigkeitsstufen '
            'laufen vollständig offline; der Move-Generator bewertet '
            'jedes legale Angriffs-/Verteidigungs-Paar gegen eine '
            'Heuristik, die widerspiegelt, wie starke menschliche '
            'Spieler über Trumpf-Hebel und Handkartenreduktion '
            'nachdenken. Custom-Rendering schiebt 60 FPS auf '
            'Commodity-Hardware, GetX treibt einen reaktiven State-'
            'Graphen, 31 Unit-Tests + Playwright-E2E schützen die '
            'Kernregeln, und der Socket-Layer ist für Online-Multiplayer '
            'vorbereitet. Der OPEN-LIVE-Button unten springt direkt in '
            'den laufenden Build.',
        decisions: <String>[
          'In Phase 13 ein **`GameRules`-Interface + `GameRegistry`** extrahiert, damit die Engine Hearts, Spades, Belote, Preferans und Uno ausliefern kann, ohne die Spiellogik zu forken — vorher war jede neue Variante ein Copy-Paste, das zwangsläufig auseinanderdriften musste.',
          '**Playwright-E2E (32 Tests) + Server-API-Tests (10) + erschöpfende Regel-Unit-Tests (57)** erst nach einem 15-Bug-Spike rund um den Card-Flip-z-Index eingeführt — insgesamt >100 Tests blockieren jetzt jeden Release. Einmal auf E2E zu verzichten kostete eine ganze Woche Regressionen.',
          '**WebSockets + Elo-basiertes Matchmaking mit Guest-Token-Persistenz** verwendet, damit Leute ohne Registrierung spielen können. Eine Pflicht-Registrierung in einer Karten-App zerstört Retention; die Kosten, Gäste zu unterstützen, sind Rundungsfehler.',
          '**GetX gegenüber Bloc/Riverpod** für State gewählt — zu der Zeit hatte es den niedrigsten Boilerplate-pro-Feature für ein kleines Team, und die reaktiven Bindings passten sauber zu einem rundenbasierten Spiel.',
        ],
        learnings: <String>[
          'Ein Rolling-Update-Deadlock biss uns mit erforderter Pod-Anti-Affinity + maxSurge>0 am Deployment; Fix war `maxUnavailable: 1, maxSurge: 0`, damit ein neuer Pod keinen noch benötigten alten aushungern kann.',
          'Lokalisierung in vier Sprachen (EN/RU/TR/DE) verdoppelte die organischen Downloads in den Testmärkten ungefähr, zum Preis einer Engineering-Woche — bester ROI des Jahres.',
        ],
      ),
    },
  ),

  // 12 ----------------------------------------------------------------------
  ProjectItemData(title: 'Sovereign Smart Home',
    subtitle: 'Edge-only Proxmox + HAOS + MQTT stack',
    category: 'EDGE / SELF-HOSTED',
    platform: 'Proxmox · HAOS',
    primaryColor: const Color(0xFF18BCF2),
    image: '$_d/home-assistant/cover.webp',
    coverUrl: '$_d/home-assistant/cover.webp',
    coverColorUrl: '$_d/home-assistant/cover-color.webp',
    technologyUsed:
        'Proxmox VE · OpenWRT · openSUSE · Home Assistant OS · MQTT · InfluxDB · Grafana',
    portfolioDescription:
        'A self-hosted edge hub that keeps every physical-world signal '
        'inside the LAN — no cloud middleman, no telemetry leak. '
        'Proxmox virtualises Home Assistant OS, an MQTT broker, '
        'InfluxDB and Grafana in lightweight VMs; OpenWRT handles '
        'segmented VLANs for IoT vs. trusted devices; openSUSE runs '
        'background workloads. Forty-plus room-level automations tie '
        'climate, lighting, presence and security together through '
        'sensor-fusion rules.',
    isPublic: false,
    isLive: false,
    mockupType: 'laptop',
    screenshots: <String>[],
    decisions: <String>[
      'Virtualised every component on **Proxmox in lightweight VMs** instead of running them on one bare-metal install, because a single bad upgrade on the smart-home host shouldn\'t take the broker and the database down with it. Isolation is the whole point.',
      'Put **OpenWRT in front for segmented VLANs** — every camera, light and presence sensor sits behind its own network policy. Retrofitting that segmentation after a CVE is much more expensive than starting with it.',
      'Wrote **room-owned automations** rather than chained-trigger global scenes — each room\'s rules compose with the next without inheriting global side-effects, and a misbehaving rule blast-radius stays in that room.',
      'Refused **every cloud middleman** — privacy was the entire reason for the project; trading it for convenience would have defeated the point.',
    ],
    learnings: <String>[
      'Energy monitoring across 12+ devices in Grafana found two always-on appliances eating ~€200/year between them — the dashboard paid for the hardware in under a year.',
      'IoT segmentation on its own VLAN from day one is dramatically cheaper than adding it after a smart bulb gets a CVE.',
    ],
    translations: const <String, ProjectTranslation>{
      'de': ProjectTranslation(
        title: 'Souveränes Smart Home',
        subtitle: 'Edge-only Proxmox + HAOS + MQTT Stack',
        category: 'EDGE / SELF-HOSTED',
        platform: 'Proxmox · HAOS',
        technologyUsed:
            'Proxmox VE · OpenWRT · openSUSE · Home Assistant OS · MQTT · InfluxDB · Grafana',
        portfolioDescription:
            'Ein selbst gehosteter Edge-Hub, der jedes physische Signal '
            'im LAN behält — kein Cloud-Mittelsmann, kein Telemetrie-'
            'Leck. Proxmox virtualisiert Home Assistant OS, einen '
            'MQTT-Broker, InfluxDB und Grafana in leichtgewichtigen VMs; '
            'OpenWRT übernimmt segmentierte VLANs für IoT vs. '
            'vertrauenswürdige Geräte; openSUSE betreibt Hintergrund-'
            'Workloads. Über 40 raumweise Automationen verbinden Klima, '
            'Licht, Anwesenheit und Sicherheit über Sensor-Fusion-Regeln.',
        decisions: <String>[
          'Jede Komponente in **leichtgewichtigen VMs auf Proxmox** virtualisiert statt sie auf einer Bare-Metal-Installation zu betreiben, denn ein schlechtes Upgrade auf dem Smart-Home-Host soll nicht den Broker und die Datenbank mitreißen. Isolation ist der ganze Punkt.',
          '**OpenWRT für segmentierte VLANs** vorgelagert — jede Kamera, Lampe und jeder Anwesenheitssensor sitzt hinter seiner eigenen Netzwerk-Policy. Diese Segmentierung nach einem CVE nachzurüsten ist viel teurer, als sie von Anfang an mitzudenken.',
          '**Raum-eigene Automationen** geschrieben statt verkettete globale Szenen — die Regeln eines Raumes komponieren mit dem nächsten, ohne globale Nebenwirkungen zu erben, und der Blast-Radius einer fehlerhaften Regel bleibt in diesem Raum.',
          '**Jeden Cloud-Mittelsmann** abgelehnt — Privatsphäre war der gesamte Grund für das Projekt; sie gegen Komfort einzutauschen hätte den Zweck zunichtegemacht.',
        ],
        learnings: <String>[
          'Energie-Monitoring über 12+ Geräte in Grafana fand zwei dauerhaft eingeschaltete Geräte, die zusammen rund 200 €/Jahr fraßen — das Dashboard hatte die Hardware in unter einem Jahr abbezahlt.',
          'IoT-Segmentierung von Tag eins an auf einem eigenen VLAN ist dramatisch billiger, als sie nach einem CVE an einer Smart-Glühbirne nachzurüsten.',
        ],
      ),
    },
  ),

  // 13 ----------------------------------------------------------------------
  ProjectItemData(title: 'Legal Evidence Organization',
    subtitle: 'Forensic evidence rooms, chronologies and source-bound citations',
    category: 'LEGAL TECH / KNOWLEDGE GRAPH',
    primaryColor: const Color(0xFF3F3F46),
    image: '$_d/legal-evidence/cover.webp',
    coverUrl: '$_d/legal-evidence/cover.webp',
    coverColorUrl: '$_d/legal-evidence/cover-color.webp',
    platform: 'Backend · Knowledge Base',
    technologyUsed:
        'PostgreSQL · pgvector · FastAPI · forensic catalog schema · chronology builder · hash-on-ingest',
    portfolioDescription:
        'A private engagement around what to do when a case escalates and '
        'the underlying data is everywhere: emails, WhatsApp threads, '
        'PDFs, server logs, audio recordings, contracts. The system '
        'normalises those sources into a forensic evidence room — '
        'append-only, hash-on-ingest, role-scoped — and rebuilds a '
        'chronological timeline where every claim is bound to its source '
        'file, date and medium. Email and WhatsApp catalogs sit '
        'alongside server-forensics reports; a separate redacted export '
        'view exists for counsel-facing handover. Designed as data '
        'infrastructure for legal work, never as legal advice.',
    isPublic: false,
    isLive: false,
    mockupType: 'terminal',
    screenshots: <String>[],
    decisions: <String>[
      'Built the store as **append-only with hash-on-ingest** — every artefact gets a SHA-256 fingerprint at the moment it enters the room, so chain-of-custody questions later have a deterministic answer; edit-history "fixes" would have destroyed the entire forensic value.',
      'Separated **original vs. redacted views as a hard role boundary** rather than a soft UI toggle — counsel sees the redacted bundle, the data owner sees originals; a single role with "be careful" is exactly how privileged material gets leaked.',
      'Reconstructed the timeline as a **structured chronology of typed events** (email / chat / file / log / call) instead of a free-text narrative — every entry carries source + date + medium, which is the format prosecutors and auditors actually want.',
      'Refused **demo-on-real-data even internally**: every screenshot, every walkthrough uses an anonymised dummy room. Working with the real artefacts directly would have created a second copy outside the chain of custody.',
    ],
    learnings: <String>[
      'In legal contexts **citation completeness matters more than retrieval recall** — finding 100 relevant documents is worthless if any single quote can\'t be pinned to its source PDF, page and timestamp. The ceiling of the system is "every claim points back to a file".',
      'The hardest part isn\'t the search layer; it\'s upstream — turning a folder of WhatsApp exports, signed PDFs and FB Messenger ZIPs into a catalog with consistent fields took longer than the entire backend.',
    ],
    translations: const <String, ProjectTranslation>{
      'de': ProjectTranslation(
        title: 'Beweismittel-Organisation',
        subtitle: 'Forensische Beweisräume, Chronologien und quellengebundene Zitate',
        category: 'LEGAL TECH / WISSENSGRAPH',
        platform: 'Backend · Wissensbasis',
        technologyUsed:
            'PostgreSQL · pgvector · FastAPI · forensisches Katalog-Schema · Chronologie-Builder · Hash-on-Ingest',
        portfolioDescription:
            'Ein privates Engagement rund um die Frage, was zu tun ist, '
            'wenn ein Fall eskaliert und die zugrundeliegenden Daten '
            'überall sind: E-Mails, WhatsApp-Threads, PDFs, Server-Logs, '
            'Audioaufnahmen, Verträge. Das System normalisiert diese '
            'Quellen in einen forensischen Beweisraum — append-only, '
            'Hash-on-Ingest, rollenbasiert — und rekonstruiert eine '
            'chronologische Timeline, in der jede Aussage an ihre '
            'Quelldatei, ihr Datum und ihr Medium gebunden ist. E-Mail- '
            'und WhatsApp-Kataloge stehen neben Server-Forensik-Berichten; '
            'eine separate redigierte Export-Sicht existiert für die '
            'anwaltliche Übergabe. Konzipiert als Daten-Infrastruktur '
            'für juristische Arbeit, nie als Rechtsberatung.',
        decisions: <String>[
          'Den Speicher als **append-only mit Hash-on-Ingest** gebaut — jedes Artefakt bekommt im Moment des Eintritts in den Raum einen SHA-256-Fingerprint, damit Chain-of-Custody-Fragen später eine deterministische Antwort haben; Edit-History-"Korrekturen" hätten den gesamten forensischen Wert zerstört.',
          '**Original- vs. redigierte Sicht als harte Rollengrenze** statt als weichen UI-Toggle getrennt — der Anwalt sieht das redigierte Bundle, der Datenherr sieht die Originale; eine einzelne Rolle mit "sei vorsichtig" ist genau, wie privilegiertes Material durchsickert.',
          'Die Timeline als **strukturierte Chronologie typisierter Events** rekonstruiert (E-Mail / Chat / Datei / Log / Anruf) statt als Freitext-Narrativ — jeder Eintrag trägt Quelle + Datum + Medium, das ist das Format, das Staatsanwälte und Prüfer tatsächlich wollen.',
          '**Demo-on-real-data sogar intern verweigert**: jeder Screenshot, jeder Walkthrough nutzt einen anonymisierten Dummy-Raum. Mit den echten Artefakten direkt zu arbeiten hätte eine zweite Kopie außerhalb der Chain-of-Custody erzeugt.',
        ],
        learnings: <String>[
          'In juristischen Kontexten **zählt Zitations-Vollständigkeit mehr als Retrieval-Recall** — 100 relevante Dokumente zu finden ist wertlos, wenn ein einzelnes Zitat nicht auf seine Quell-PDF, Seite und Zeitstempel zurückgeführt werden kann. Die Decke des Systems ist "jede Aussage zeigt zurück auf eine Datei".',
          'Das Schwerste ist nicht die Suchschicht; es ist Upstream — einen Ordner aus WhatsApp-Exports, signierten PDFs und FB-Messenger-ZIPs in einen Katalog mit konsistenten Feldern zu verwandeln hat länger gedauert als das gesamte Backend.',
        ],
      ),
    },
  ),

  // 14 ----------------------------------------------------------------------
  ProjectItemData(title: 'Local AI Voice Assistant',
    subtitle: 'On-device wake-word + Whisper STT + local LLM + Piper TTS',
    category: 'AI / EDGE',
    platform: 'Linux',
    primaryColor: const Color(0xFF14B8A6),
    image: '$_d/voice-assistant/cover.webp',
    coverUrl: '$_d/voice-assistant/cover.webp',
    coverColorUrl: '$_d/voice-assistant/cover-color.webp',
    technologyUsed:
        'faster-whisper · Piper TTS · openWakeWord · local LLM · Flask · MQTT',
    portfolioDescription:
        'A privacy-first voice assistant that runs end-to-end on '
        'commodity hardware. A custom wake-word from openWakeWord '
        'triggers a self-hosted faster-whisper service (Flask on '
        ':10300, int8 quantised) for speech-to-text; a local LLM '
        'resolves intent; Piper TTS speaks the reply. The whole '
        'pipeline returns under a second on a single GPU, no audio '
        'ever leaves the LAN, and commands route through MQTT into '
        'the same Home Assistant automation graph as every other '
        'event in the house.',
    isPublic: false,
    isLive: false,
    mockupType: 'terminal',
    screenshots: <String>[],
    decisions: <String>[
      'Used **faster-whisper (int8 quantised) instead of cloud Whisper** because the project\'s entire premise was that no audio leaves the LAN — same model accuracy, ~3× smaller memory footprint, runs on a CPU box.',
      'Picked a **custom openWakeWord model** rather than a generic "hey-XYZ" wake phrase — full control over which sound wakes the mic, and no licence on the trigger word.',
      'Chose **Piper TTS over a cloud voice API** — at headphone quality it\'s indistinguishable, free, and offline. The cloud version was a worse trade on every axis except setup time.',
      'Speaks **MQTT into Home Assistant** rather than calling the HA REST API — keeps the assistant in the same automation graph as any door sensor or doorbell. REST would have created a second event bus.',
      'Wrapped Whisper as a **generic OpenAI-compatible sidecar on :10300** rather than embedding it inside the assistant binary — any other LAN service that needs transcription can call it without spinning up its own model, and the assistant itself stays focused on the wake-word → intent → speak loop.',
    ],
    learnings: <String>[
      'Sub-second round-trip is what makes the assistant feel real versus "a smart speaker that works when it works" — every component (wake-word, STT, LLM, TTS) had to live inside its own latency budget.',
      'Context persistence across utterances makes commands like "turn that off" or "and the other one" feel natural — without it, every utterance has to be self-contained, and adoption falls off a cliff.',
      'Int8 quantisation cuts memory ~3× with no audible accuracy loss on short utterances — CPU inference is genuinely practical once the latency budget is respected.',
    ],
    translations: const <String, ProjectTranslation>{
      'de': ProjectTranslation(
        title: 'Lokaler KI-Sprachassistent',
        subtitle: 'On-device Wake-Word + Whisper STT + lokales LLM + Piper TTS',
        category: 'KI / EDGE',
        platform: 'Linux',
        technologyUsed:
            'faster-whisper · Piper TTS · openWakeWord · lokales LLM · Flask · MQTT',
        portfolioDescription:
            'Ein Privacy-first-Sprachassistent, der end-to-end auf '
            'Commodity-Hardware läuft. Ein Custom-Wake-Word aus '
            'openWakeWord triggert einen selbst gehosteten faster-whisper-'
            'Service (Flask auf :10300, int8-quantisiert) für Speech-to-'
            'Text; ein lokales LLM löst den Intent auf; Piper TTS spricht '
            'die Antwort. Die ganze Pipeline kommt unter einer Sekunde '
            'auf einer einzigen GPU zurück, kein Audio verlässt je das '
            'LAN, und Befehle laufen über MQTT in denselben Home-'
            'Assistant-Automation-Graphen wie jedes andere Event im '
            'Haus.',
        decisions: <String>[
          '**faster-whisper (int8-quantisiert) statt Cloud-Whisper** verwendet, weil die ganze Prämisse des Projekts war, dass kein Audio das LAN verlässt — gleiche Modellgenauigkeit, ~3× kleinerer Memory-Footprint, läuft auf einer CPU-Box.',
          'Ein **Custom-openWakeWord-Modell** statt einer generischen "hey-XYZ"-Wake-Phrase gewählt — volle Kontrolle darüber, welcher Ton das Mikrofon weckt, und keine Lizenz auf dem Trigger-Wort.',
          '**Piper TTS gegenüber einer Cloud-Voice-API** gewählt — bei Kopfhörer-Qualität nicht unterscheidbar, kostenlos und offline. Die Cloud-Version war auf jeder Achse außer Setup-Zeit der schlechtere Trade.',
          'Spricht **MQTT in Home Assistant** statt die HA-REST-API aufzurufen — das hält den Assistenten in demselben Automation-Graphen wie jeden Türsensor oder Klingelknopf. REST hätte einen zweiten Event-Bus erzeugt.',
          'Whisper als **generisches OpenAI-kompatibles Sidecar auf :10300** gekapselt statt es in die Assistent-Binary einzubetten — jeder andere LAN-Service, der Transkription braucht, kann ihn aufrufen, ohne ein eigenes Modell hochzuziehen, und der Assistent selbst bleibt auf den Wake-Word- → Intent- → Speak-Loop fokussiert.',
        ],
        learnings: <String>[
          'Sub-Sekunden-Round-Trip ist, was den Assistenten echt anfühlen lässt, im Gegensatz zu "einem Smart Speaker, der funktioniert, wenn er funktioniert" — jede Komponente (Wake-Word, STT, LLM, TTS) musste in ihrem eigenen Latenz-Budget leben.',
          'Kontext-Persistenz über Äußerungen hinweg macht Befehle wie "schalt das aus" oder "und das andere" natürlich — ohne sie muss jede Äußerung selbsterklärend sein, und die Akzeptanz bricht ein.',
          'Int8-Quantisierung schneidet den Speicher ~3× ohne hörbaren Genauigkeitsverlust bei kurzen Äußerungen — CPU-Inferenz ist tatsächlich praktikabel, sobald das Latenz-Budget respektiert wird.',
        ],
      ),
    },
  ),

  // 15 ----------------------------------------------------------------------
  ProjectItemData(title: 'AI-Driven Print-on-Demand Shop',
    subtitle: 'shop.burakbasci.de — generative pipeline, upscaler, bulk uploader',
    category: 'AUTOMATION / E-COMMERCE',
    platform: 'Web',
    primaryColor: const Color(0xFFF59E0B),
    image: '$_d/shop-automation/cover.webp',
    coverUrl: '$_d/shop-automation/cover.webp',
    coverColorUrl: '$_d/shop-automation/cover-color.webp',
    technologyUsed:
        'Python · ComfyUI · FLUX.1 · Real-ESRGAN · Selenium · Printify API · Shopify API · Pinterest API · WooCommerce · Pandas',
    portfolioDescription:
        'An end-to-end content and product pipeline: FLUX.1 (via a '
        'self-hosted ComfyUI graph) generates designs on a cron '
        'schedule; a Real-ESRGAN upscaler with face-aware denoise '
        'pushes each design to 4× resolution over SFTP; a Selenium '
        'uploader pushes the resulting product to the Adobe Stock + '
        'ImmoWare side-listings; the Printify API places designs on '
        'print-on-demand products and ships them to the WooCommerce '
        'storefront. A Pandas reconciliation step matches every order '
        'back to the original prompt + seed, so every product on the '
        'shop is traceable to the latent that made it.',
    isPublic: true,
    isLive: true,
    webUrl: 'https://shop.burakbasci.de',
    mockupType: 'laptop',
    screenshots: <String>[],
    decisions: <String>[
      'Picked **self-hosted ComfyUI + FLUX.1 on local GPU** over a SaaS image API — predictable per-image cost, no rate limit, full control over the latent and the brand-kit prompt graph; SaaS would have priced the whole funnel out of viability.',
      'Built the **Real-ESRGAN upscaler as an SFTP-watcher sidecar** with `realesr-general-x4v3` (VGG-style) instead of the heavier RRDB models — configurable denoise control mattered more for print quality than peak benchmark numbers.',
      'Used **Selenium with the Chromium remote-debugging protocol** for the Adobe Stock + ImmoWare uploads because neither has a workable API for batch posting — automation against the actual web UI was the only viable path.',
      'Made **suffix-based output dedup** (`OUTPUT_SUFFIX`) with a remote-existence check so the watcher never re-upscales the same image after a restart — without it, the queue would spin on already-done work.',
      'Built **Pandas-based reconciliation** so every SKU is traceable back to the prompt + seed that generated it — once it works, the next bug becomes "do the generated images sell?", which is the right next problem.',
    ],
    learnings: <String>[
      'Once the pipeline is fully automated, the design constraint shifts from "does it ship" to "does the art sell" — a totally different problem.',
      'Brand kits in ComfyUI (consistent typography, palette, composition rules) were the unlock for avoiding the generic "AI-slop" look that kills conversion.',
      'Face-aware denoise was worth the latency cost for portrait-style designs and dead weight for everything else — making it environment-optional, not always-on, let the operator tune per batch.',
    ],
    translations: const <String, ProjectTranslation>{
      'de': ProjectTranslation(
        title: 'KI-getriebener Print-on-Demand-Shop',
        subtitle: 'shop.burakbasci.de — generative Pipeline, Upscaler, Bulk-Uploader',
        category: 'AUTOMATION / E-COMMERCE',
        platform: 'Web',
        technologyUsed:
            'Python · ComfyUI · FLUX.1 · Real-ESRGAN · Selenium · Printify API · Shopify API · Pinterest API · WooCommerce · Pandas',
        portfolioDescription:
            'Eine End-to-End-Content- und Produkt-Pipeline: FLUX.1 (über '
            'einen selbst gehosteten ComfyUI-Graphen) generiert Designs '
            'auf einem Cron-Plan; ein Real-ESRGAN-Upscaler mit face-aware '
            'Denoise hebt jedes Design über SFTP auf 4×-Auflösung; ein '
            'Selenium-Uploader pusht das resultierende Produkt in die '
            'Adobe-Stock- + ImmoWare-Nebenlistings; die Printify-API '
            'platziert Designs auf Print-on-Demand-Produkten und liefert '
            'sie an den WooCommerce-Shop. Ein Pandas-Reconciliation-'
            'Schritt matched jede Bestellung zurück auf den Original-'
            'Prompt + Seed, sodass jedes Produkt im Shop bis zum Latent '
            'rückverfolgbar ist, das es erzeugt hat.',
        decisions: <String>[
          '**Selbst gehostetes ComfyUI + FLUX.1 auf lokaler GPU** gegenüber einer SaaS-Image-API gewählt — vorhersehbare Kosten pro Bild, kein Rate-Limit, volle Kontrolle über Latent und Brand-Kit-Prompt-Graph; SaaS hätte den gesamten Funnel preislich unrentabel gemacht.',
          'Den **Real-ESRGAN-Upscaler als SFTP-Watcher-Sidecar** mit `realesr-general-x4v3` (VGG-Style) gebaut statt der schwereren RRDB-Modelle — konfigurierbare Denoise-Kontrolle war für Print-Qualität wichtiger als Spitzen-Benchmark-Zahlen.',
          '**Selenium mit dem Chromium-Remote-Debugging-Protokoll** für die Adobe-Stock- + ImmoWare-Uploads verwendet, weil keiner von beiden eine brauchbare API für Batch-Postings hat — Automatisierung gegen das tatsächliche Web-UI war der einzige gangbare Weg.',
          '**Suffix-basierte Output-Dedup** (`OUTPUT_SUFFIX`) mit Remote-Existence-Check gebaut, sodass der Watcher dasselbe Bild nach einem Restart nicht erneut upscaled — ohne sie hätte die Queue an bereits erledigter Arbeit gedreht.',
          '**Pandas-basierte Reconciliation** gebaut, damit jeder SKU rückverfolgbar ist auf den Prompt + Seed, der ihn generiert hat — sobald das funktioniert, wird der nächste Bug "verkaufen sich die generierten Bilder?", was das richtige nächste Problem ist.',
        ],
        learnings: <String>[
          'Sobald die Pipeline vollautomatisch ist, verschiebt sich die Design-Constraint von "shipped sie?" zu "verkauft sich die Kunst?" — ein völlig anderes Problem.',
          'Brand-Kits in ComfyUI (konsistente Typografie, Palette, Kompositions-Regeln) waren der Schlüssel, um den generischen "AI-Slop"-Look zu vermeiden, der Conversion tötet.',
          'Face-aware Denoise war die Latenzkosten wert bei Porträt-artigen Designs und totes Gewicht bei allem anderen — sie umgebungsoptional zu machen statt immer-an erlaubte es dem Operator, pro Batch zu tunen.',
        ],
      ),
    },
  ),

  // 16 ----------------------------------------------------------------------
  ProjectItemData(title: 'ImmoPilot — Real-Estate SaaS',
    subtitle: 'Multi-tenant CRM-and-mail automation for German brokers',
    category: 'B2B / SAAS',
    platform: 'Web · iOS · Android',
    primaryColor: const Color(0xFF334155),
    image: '$_d/immopilot/cover.webp',
    coverUrl: '$_d/immopilot/cover.webp',
    coverColorUrl: '$_d/immopilot/cover-color.webp',
    technologyUsed:
        'FastAPI · PostgreSQL 18 + RLS · Redis · ARQ · n8n · NocoDB · Mistral / OpenAI / Anthropic · Podman Compose · Prometheus + Grafana',
    portfolioDescription:
        'A multi-tenant SaaS for German real-estate brokerages that '
        'plugs into onOffice, onPreo and Outlook and automates the '
        'busy-work between lead and contract. PostgreSQL 18 with '
        'row-level security keeps every tenant\'s data isolated; ARQ '
        'workers poll onOffice for new leads while LLM classifiers '
        'draft replies and match leads against the broker\'s active '
        'portfolio. The "qualified-suitors" matcher converts free-form '
        'lead text into a 0-100% match score; n8n then formats the '
        'result as a DIN-5008 compliant DOCX/PDF "Angebot". Runs on '
        'the sovereign k3s platform with full Prometheus + Grafana '
        'observability.',
    isPublic: false,
    isLive: true,
    mockupType: 'laptop',
    screenshots: <String>[],
    decisions: <String>[
      'Enforced multi-tenancy with **row-level security on PostgreSQL 18 as defence-in-depth** — SQLAlchemy filters are the primary check, RLS exists to catch the bugs in the primary check before they ship customer data the wrong way.',
      'Made email default to **"Draft in Outlook", not direct-send** — every broker sees the AI draft before it goes out. The trust win has been larger than any feature; an early auto-send experiment surfaced exactly the bias problems you\'d expect.',
      'Put **client-facing settings in a NocoDB view** rather than building a custom admin panel — brokers tune tonality, follow-up cadence and routing rules without a developer in the loop. Building the admin panel ourselves would have eaten a quarter.',
      'Chose **ARQ-scheduled polling against the onOffice API** over a webhook queue — onOffice doesn\'t emit webhooks, and faking events out of polling is always wrong. Architecture has to fit the upstream\'s actual shape.',
      'Made **Mistral primary, OpenAI/Anthropic fallbacks behind a feature flag** so EU-residency clients can switch in a config change instead of a refactor.',
    ],
    learnings: <String>[
      'onOffice\'s `qualifiedsuitors` endpoint converts free-form lead text into a 0-100% match score against the active portfolio — once shipped, no broker wanted to go back to manual matching.',
      'DSGVO + AVV documentation produced before sales (DIN-5008-formatted, 50+ pages) shortens enterprise contract negotiation considerably; clients read it as a maturity signal.',
      'onPreo has no public API in 2026; architecting onOffice as the single source of truth made the platform survive vendor uncertainty.',
    ],
    translations: const <String, ProjectTranslation>{
      'de': ProjectTranslation(
        title: 'ImmoPilot — Immobilien-SaaS',
        subtitle: 'Mandantenfähige CRM- und Mail-Automation für deutsche Makler',
        category: 'B2B / SAAS',
        platform: 'Web · iOS · Android',
        technologyUsed:
            'FastAPI · PostgreSQL 18 + RLS · Redis · ARQ · n8n · NocoDB · Mistral / OpenAI / Anthropic · Podman Compose · Prometheus + Grafana',
        portfolioDescription:
            'Eine mandantenfähige SaaS für deutsche Maklerunternehmen, '
            'die sich in onOffice, onPreo und Outlook einklinkt und die '
            'Fleißarbeit zwischen Lead und Vertrag automatisiert. '
            'PostgreSQL 18 mit Row-Level-Security isoliert die Daten '
            'jedes Mandanten; ARQ-Worker pollen onOffice nach neuen '
            'Leads, während LLM-Klassifikatoren Antworten entwerfen und '
            'Leads gegen das aktive Portfolio des Maklers matchen. Der '
            '"qualified-suitors"-Matcher wandelt freitextlichen Lead-'
            'Text in einen 0–100-%-Match-Score um; n8n formatiert das '
            'Ergebnis dann als DIN-5008-konformes DOCX/PDF-"Angebot". '
            'Läuft auf der souveränen k3s-Plattform mit voller '
            'Prometheus- + Grafana-Observability.',
        decisions: <String>[
          'Mandantenfähigkeit mit **Row-Level-Security auf PostgreSQL 18 als Defence-in-Depth** durchgesetzt — SQLAlchemy-Filter sind der primäre Check, RLS existiert, um die Bugs im primären Check abzufangen, bevor sie Kundendaten falsch ausliefern.',
          'E-Mail standardmäßig auf **"Entwurf in Outlook" gestellt, nicht auf Direktversand** — jeder Makler sieht den KI-Entwurf, bevor er rausgeht. Der Vertrauensgewinn war größer als jedes Feature; ein frühes Auto-Send-Experiment legte genau die Bias-Probleme offen, die man erwartet.',
          '**Kunden-Einstellungen in einer NocoDB-Sicht** untergebracht statt ein Custom-Admin-Panel zu bauen — Makler tunen Tonalität, Follow-up-Kadenz und Routing-Regeln ohne Entwickler im Loop. Das Admin-Panel selbst zu bauen hätte ein Quartal gefressen.',
          '**ARQ-gescheduletes Polling gegen die onOffice-API** gegenüber einer Webhook-Queue gewählt — onOffice emittiert keine Webhooks, und Events aus Polling zu faken ist immer falsch. Die Architektur muss zur tatsächlichen Form des Upstreams passen.',
          '**Mistral primär gemacht, OpenAI/Anthropic-Fallbacks hinter einem Feature-Flag**, damit EU-Residency-Kunden in einem Config-Change wechseln können statt eines Refactors.',
        ],
        learnings: <String>[
          'onOffices `qualifiedsuitors`-Endpunkt wandelt freitextlichen Lead-Text in einen 0–100-%-Match-Score gegen das aktive Portfolio um — nach dem Ausliefern wollte kein Makler zum manuellen Matchen zurück.',
          'DSGVO- + AVV-Dokumentation, die vor dem Sales-Gespräch fertig liegt (DIN-5008-formatiert, 50+ Seiten), verkürzt Enterprise-Vertragsverhandlungen erheblich; Kunden lesen sie als Reifezeichen.',
          'onPreo hat 2026 keine öffentliche API; onOffice als Single Source of Truth zu architektieren ließ die Plattform Vendor-Unsicherheit überleben.',
        ],
      ),
    },
  ),

  // 17 ----------------------------------------------------------------------
  ProjectItemData(title: 'Formal Document Automation',
    subtitle: 'DOCX/PDF generator for invoices, reminders and legal letters',
    category: 'AUTOMATION / DOCUMENTS',
    primaryColor: const Color(0xFFA16207),
    image: '$_d/formal-docs/cover.webp',
    coverUrl: '$_d/formal-docs/cover.webp',
    coverColorUrl: '$_d/formal-docs/cover-color.webp',
    platform: 'Backend · CLI',
    technologyUsed:
        'Python · python-docx · PyMuPDF · qrcode (EPC/GiroCode) · Jinja2 · PostgreSQL',
    portfolioDescription:
        'A backoffice document generator built around the parts of formal '
        'German correspondence that have to be exactly right: invoices, '
        'payment reminders ("Mahnungen"), legal letters in DIN-5008 '
        'shape, and CV-from-PDF re-rendering. Python templates write '
        'DOCX/PDF deterministically from structured input; EPC/GiroCode '
        'QRs are baked into every invoice so the payer never retypes an '
        'IBAN; a "draft → review → send" state machine keeps a human '
        'in the loop on anything legal. Built as a backoffice layer '
        'that already feeds several client tools rather than as a '
        'standalone product.',
    isPublic: false,
    isLive: false,
    mockupType: 'laptop',
    screenshots: <String>[],
    decisions: <String>[
      'Built the renderer on **python-docx + raw XML edits** instead of wkhtmltopdf or LibreOffice-headless — formal German letters (Anrede, Betreff, signature block) need pixel-stable, deterministic layout, and HTML-to-PDF still drifts across versions in ways that show up in legal documents.',
      'Embedded **EPC/GiroCode payment QRs directly in the invoice template** rather than as an afterthought — German SEPA banking apps scan them and prefill IBAN + reference + amount, so the customer can never mistype the amount or Verwendungszweck.',
      'Made the workflow a **"draft → review → send" state machine** rather than fire-and-forget — for invoices and Mahnungen the human approval is the legal gate; automating *through* approval would have been a regulatory mistake.',
      'Versioned **every generated document with its source data alongside it** in Postgres — when a customer disputes an invoice eight months later, the exact template + inputs that produced the PDF are still recoverable.',
    ],
    learnings: <String>[
      'German legal-formality (Anrede, Bezug, footer with Steuernummer, signature blocks) is overwhelmingly template work, not LLM work — large language models add unpredictability where a Jinja template already gives correctness.',
      'Treating payment reminders as a **cadence with explicit Mahnstufen** (M1 / M2 / M3 / Inkassoübergabe) instead of one-shot events cut bad-debt write-offs noticeably for the small operators using this — the win was the schedule, not the wording.',
    ],
    translations: const <String, ProjectTranslation>{
      'de': ProjectTranslation(
        title: 'Formal-Dokumenten-Automation',
        subtitle: 'DOCX/PDF-Generator für Rechnungen, Mahnungen und juristische Schreiben',
        category: 'AUTOMATION / DOKUMENTE',
        platform: 'Backend · CLI',
        technologyUsed:
            'Python · python-docx · PyMuPDF · qrcode (EPC/GiroCode) · Jinja2 · PostgreSQL',
        portfolioDescription:
            'Ein Backoffice-Dokumentengenerator, gebaut um die Teile '
            'formaler deutscher Korrespondenz, die exakt stimmen müssen: '
            'Rechnungen, Mahnungen, juristische Schreiben in DIN-5008-'
            'Form und CV-aus-PDF-Re-Rendering. Python-Templates schreiben '
            'DOCX/PDF deterministisch aus strukturiertem Input; EPC-/'
            'GiroCode-QRs sind in jede Rechnung eingebacken, damit der '
            'Zahler nie eine IBAN abtippen muss; eine "Draft → Review → '
            'Send"-State-Machine hält bei allem Juristischen einen '
            'Menschen im Loop. Gebaut als Backoffice-Schicht, die '
            'bereits mehrere Kunden-Tools speist — nicht als Standalone-'
            'Produkt.',
        decisions: <String>[
          'Den Renderer auf **python-docx + rohen XML-Edits** gebaut statt auf wkhtmltopdf oder LibreOffice-Headless — formale deutsche Briefe (Anrede, Betreff, Signaturblock) brauchen pixelstabiles, deterministisches Layout, und HTML-zu-PDF driftet über Versionen weiterhin auf Arten, die sich in juristischen Dokumenten zeigen.',
          '**EPC-/GiroCode-Zahlungs-QRs direkt ins Rechnungs-Template eingebettet** statt als Nachgedanken — deutsche SEPA-Banking-Apps scannen sie und prefillen IBAN + Verwendungszweck + Betrag, sodass der Kunde Betrag oder Verwendungszweck nie vertippen kann.',
          'Den Workflow als **"Draft → Review → Send"-State-Machine** gestaltet statt Fire-and-Forget — bei Rechnungen und Mahnungen ist die menschliche Freigabe das rechtliche Gate; *durch* die Freigabe zu automatisieren wäre ein regulatorischer Fehler gewesen.',
          'Jedes generierte Dokument **mit seinen Quelldaten daneben** in Postgres versioniert — wenn ein Kunde acht Monate später eine Rechnung bestreitet, sind das exakte Template + die Inputs, die das PDF erzeugten, weiterhin wiederherstellbar.',
        ],
        learnings: <String>[
          'Deutsche Rechtsformalitäten (Anrede, Bezug, Footer mit Steuernummer, Signaturblöcke) sind überwiegend Template-Arbeit, keine LLM-Arbeit — Large Language Models fügen Unvorhersehbarkeit dort hinzu, wo ein Jinja-Template bereits Korrektheit liefert.',
          'Zahlungserinnerungen als **Kadenz mit expliziten Mahnstufen** zu behandeln (M1 / M2 / M3 / Inkassoübergabe) statt als einmalige Events senkte die Forderungsausfälle bei den kleinen Operatoren, die das nutzen, merklich — der Gewinn lag im Zeitplan, nicht in der Formulierung.',
        ],
      ),
    },
  ),

  // 18 ----------------------------------------------------------------------
  ProjectItemData(title: 'CaterSmart — Catering Ops + AI Core',
    subtitle: 'FastAPI backend + pluggable-LLM inquiry triage',
    category: 'B2B / OPERATIONS',
    platform: 'Web · API',
    primaryColor: const Color(0xFF65A30D),
    image: '$_d/catersmart/cover.webp',
    coverUrl: '$_d/catersmart/cover.webp',
    coverColorUrl: '$_d/catersmart/cover-color.webp',
    technologyUsed:
        'FastAPI · SQLAlchemy 2 async · Alembic · PostgreSQL · Redis · Mistral / Claude / OpenAI · Supabase pgvector · FLUX / ComfyUI · Real-ESRGAN · WebP',
    portfolioDescription:
        'A full-stack catering operations platform with two paired '
        'product surfaces. The first is an async FastAPI + SQLAlchemy 2 '
        'backend on PostgreSQL and Redis, plus a stateless "AI core" '
        'microservice that turns inbound inquiry mails into structured '
        'tickets — eleven catering categories, strict JSON-schema '
        'enforcement on the LLM reply, pluggable provider (Mistral / '
        'Claude / OpenAI / OpenWebUI), RAG over a Supabase pgvector '
        'store for prior decisions, mock mode for tests, JSONL audit '
        'logs, and 88 unit tests in CI. The second surface is a '
        'bulk-image-generation pipeline with its own admin UI: catering '
        'product data + reference images + a brand style-profile feed '
        'an in-house FLUX / ComfyUI graph, the output is upscaled with '
        'Real-ESRGAN and exported as Shop-ready WebP back through the '
        'CaterSmart API — caterers (and any KMU with hundreds of '
        'products and no photographer) get consistent product imagery '
        'in batches instead of one-at-a-time. Both surfaces ship at '
        'catersmart.de.',
    isPublic: false,
    isLive: true,
    webUrl: 'https://catersmart.de',
    mockupType: 'laptop',
    screenshots: <String>[],
    decisions: <String>[
      'Built the AI core **stateless** with on-demand context fetch from the CaterSmart REST API rather than mirroring state — single source of truth, no cache invalidation problem, zero risk of stale-context drift.',
      'Enforced **tenant isolation on every API call** with strict per-tenant RAG embedding scoping — cross-tenant feedback leak in a multi-tenant LLM system is a catastrophic failure mode, RLS-style isolation is the only acceptable answer.',
      'Made the LLM provider swappable behind **one env var** (Mistral primary, Claude / OpenAI / local OpenWebUI as fallbacks) so an EU-residency client gets a config change, not a deployment.',
      'Defaulted to **mock mode when API keys are absent** so contributors and CI can run the full stack without consuming tokens — this also makes the contract testable in isolation.',
      'Set Phase-1 success at **"60% perfect, 30% light-edit, 10% manual"** — naming acceptable failure modes up front kept the team from over-engineering for the long tail and shipped a useful product months earlier.',
      'Built the **bulk-image generator as its own admin UI** rather than tacking it onto the CaterSmart shop console — caterers run image batches in long, focused sessions (50–500 products at a time), the workflow has different review patterns than ticket triage, and bolting it onto the shop would have rotted both screens.',
    ],
    learnings: <String>[
      'Eleven email categories (NEW_INQUIRY / CHANGE_REQUEST / COMPLAINT / SPAM_NEWSLETTER / ...) took three rounds of refinement; the first taxonomy missed three real-world cases that only surfaced in the long tail.',
      'First-pass benchmarks on the 55-email gold set put Mistral at ~72.7% vs. ~36.4% for a locally-hosted OpenWebUI model — useful as a floor for choosing the provider, not a shipping target. After **two rounds of prompt engineering, schema tightening and few-shot examples on a tenant\'s real history**, the production classifier sits at ~97% accuracy; the small local model never closed the gap and stayed an "edge / offline" option only.',
      'For the bulk-image pipeline, the brand-style profile carries far more weight than prompt cleverness — feeding three reference images + two negative prompts produced **>60% accepted-as-is** brand-consistent output, while heavy prompt engineering without a style profile capped out around 30%.',
      'Deferring pgvector + RAG storage out of Phase 1 was the right call — basic mock mode unblocked the API contract months before the embeddings layer was needed.',
    ],
    translations: const <String, ProjectTranslation>{
      'de': ProjectTranslation(
        title: 'CaterSmart — Catering Ops + KI-Core',
        subtitle: 'FastAPI-Backend + austauschbare LLM für Anfragen-Triage',
        category: 'B2B / OPERATIONS',
        platform: 'Web · API',
        technologyUsed:
            'FastAPI · SQLAlchemy 2 async · Alembic · PostgreSQL · Redis · Mistral / Claude / OpenAI · Supabase pgvector · FLUX / ComfyUI · Real-ESRGAN · WebP',
        portfolioDescription:
            'Eine Full-Stack-Catering-Operations-Plattform mit zwei '
            'gekoppelten Produkt-Surfaces. Die erste ist ein asynchrones '
            'FastAPI- + SQLAlchemy-2-Backend auf PostgreSQL und Redis, '
            'plus ein zustandsloser "KI-Core"-Microservice, der '
            'eingehende Anfrage-Mails in strukturierte Tickets verwandelt '
            '— elf Catering-Kategorien, strikte JSON-Schema-Erzwingung '
            'beim LLM-Reply, austauschbarer Provider (Mistral / Claude '
            '/ OpenAI / OpenWebUI), RAG über einen Supabase-pgvector-'
            'Store für frühere Entscheidungen, Mock-Mode für Tests, '
            'JSONL-Audit-Logs und 88 Unit-Tests im CI. Die zweite '
            'Surface ist eine Bulk-Bildgenerierungs-Pipeline mit '
            'eigenem Admin-UI: Catering-Produktdaten + Referenzbilder + '
            'ein Brand-Style-Profil speisen einen hauseigenen FLUX-/'
            'ComfyUI-Graphen, der Output wird mit Real-ESRGAN upscaled '
            'und als Shop-fertiges WebP zurück durch die CaterSmart-API '
            'exportiert — Caterer (und jedes KMU mit Hunderten von '
            'Produkten ohne Fotografen) bekommen konsistente '
            'Produktbilder in Batches statt eines nach dem anderen. '
            'Beide Surfaces laufen auf catersmart.de.',
        decisions: <String>[
          'Den KI-Core **zustandslos** gebaut mit On-Demand-Kontext-Fetch aus der CaterSmart-REST-API statt State zu spiegeln — Single Source of Truth, kein Cache-Invalidation-Problem, null Risiko von Stale-Context-Drift.',
          '**Tenant-Isolation auf jedem API-Call** mit strikt mandantenbasiertem RAG-Embedding-Scoping erzwungen — Cross-Tenant-Feedback-Leak in einem mandantenfähigen LLM-System ist ein katastrophaler Failure-Mode, RLS-artige Isolation ist die einzige akzeptable Antwort.',
          'Den LLM-Provider hinter **einer Env-Variable** austauschbar gemacht (Mistral primär, Claude / OpenAI / lokales OpenWebUI als Fallbacks), sodass ein EU-Residency-Kunde einen Config-Change bekommt statt eines Deployments.',
          '**Mock-Mode als Default, wenn API-Keys fehlen** — Contributors und CI können den ganzen Stack laufen, ohne Tokens zu verbrauchen; das macht den Vertrag auch isoliert testbar.',
          'Den Phase-1-Erfolg auf **"60 % perfekt, 30 % leichte Korrektur, 10 % manuell"** festgelegt — akzeptable Failure-Modes vorab zu benennen hielt das Team davon ab, für den Long-Tail überzuengineeren, und brachte Monate früher ein nutzbares Produkt.',
          'Den **Bulk-Image-Generator als eigenes Admin-UI** gebaut statt ihn an die CaterSmart-Shop-Konsole anzuflanschen — Caterer fahren Bild-Batches in langen, fokussierten Sessions (50–500 Produkte am Stück), der Workflow hat andere Review-Muster als Ticket-Triage, und ihn an den Shop zu schrauben hätte beide Screens verkommen lassen.',
        ],
        learnings: <String>[
          'Elf Mail-Kategorien (NEW_INQUIRY / CHANGE_REQUEST / COMPLAINT / SPAM_NEWSLETTER / …) brauchten drei Verfeinerungsrunden; die erste Taxonomie verfehlte drei reale Fälle, die erst im Long-Tail auftauchten.',
          'First-Pass-Benchmarks auf dem 55-Mail-Gold-Set setzten Mistral auf ~72,7 % vs. ~36,4 % bei einem lokal gehosteten OpenWebUI-Modell — als Floor für die Provider-Wahl nützlich, nicht als Auslieferungs-Ziel. Nach **zwei Runden Prompt-Engineering, Schema-Tightening und Few-Shot-Examples auf der echten Historie eines Mandanten** sitzt der Produktions-Klassifikator bei ~97 % Genauigkeit; das kleine lokale Modell holte den Gap nie auf und blieb eine reine "Edge / Offline"-Option.',
          'Für die Bulk-Image-Pipeline trägt das Brand-Style-Profil weit mehr Gewicht als Prompt-Cleverness — drei Referenzbilder + zwei Negative-Prompts produzierten **>60 % als-ist akzeptierten** markenkonsistenten Output, während heavy Prompt-Engineering ohne Style-Profil bei rund 30 % deckelte.',
          'pgvector + RAG-Storage aus Phase 1 herauszuhalten war die richtige Entscheidung — der einfache Mock-Mode entsperrte den API-Vertrag Monate, bevor die Embeddings-Schicht gebraucht wurde.',
        ],
      ),
    },
  ),

  // 19 ----------------------------------------------------------------------
  ProjectItemData(title: 'Dynamic Property 3D Tours',
    subtitle: 'Browser-based walkable 3D building models for real-estate',
    category: 'CLIENT / 3D',
    platform: 'Web · Cloud',
    primaryColor: const Color(0xFF475569),
    image: '$_d/freelance/cover.webp',
    coverUrl: '$_d/freelance/cover.webp',
    coverColorUrl: '$_d/freelance/cover-color.webp',
    technologyUsed:
        'Three.js · FastAPI · Node + TypeScript · PostgreSQL · MinIO/S3 · glTF Transform · Meshoptimizer · FFmpeg · Sharp · n8n · Docker · Kubernetes',
    portfolioDescription:
        'A platform for dynamic, walkable 3D building models that '
        'prospective buyers explore in the browser — no plugin, no '
        'app install. Each listing is composed by a per-concern '
        'microservice mesh: a 3D floor-plan generator builds the '
        'geometry, a video processor cuts walkthrough footage, an AI '
        'staging service drops furniture into empty rooms, a geometry '
        'optimiser collapses the asset count for browser delivery, and '
        'an image pipeline (Sharp) compresses textures. The Node + '
        'TypeScript orchestrator streams every asset to and from '
        'object storage so memory pressure stays constant regardless '
        'of input size, and the sandboxed Three.js viewer lets brokers '
        'preview the processed asset live before publishing.',
    isPublic: false,
    isLive: false,
    mockupType: 'laptop',
    screenshots: <String>[],
    decisions: <String>[
      'Split the platform into **per-concern microservices** (geometry, video, AI staging, optimisation, compression) instead of a monolith — each service has its own GPU/CPU profile, scales independently, and can fail without taking the rest of the pipeline down.',
      'Streamed every asset **directly to/from object storage** — memory pressure stays constant regardless of input size, so a 4 GB walkthrough doesn\'t OOM the box that processes a 200 MB one.',
      'Picked a **sandboxed Three.js viewer** for the broker preview rather than a fat client — works in any browser, no plugin install, no app distribution headache.',
      'Built around **WSL2 + Podman + Makefile** orchestration with one explicit rule the README enforces: the project must not live on OneDrive — sync mid-build causes I/O locks that crash `make`.',
      'Used **MinIO presigned uploads** so the browser pushes 4 GB walkthrough footage straight into object storage — the app server never sees the bytes and never becomes the bottleneck.',
      'Routed every GLB through **glTF Transform + Meshoptimizer** for geometry/texture compression before publish; raw 3D scans stayed under the streaming budget without manual cleanup in Blender.',
    ],
    learnings: <String>[
      'A `make` entry point (`health-check`, `up`, `logs`, `db-check`, `seed`) cuts cognitive load much more than raw docker-compose for a service mesh of this size.',
      'Health + disk-space checks before every start catch stale dependencies or low-disk conditions before they crash mid-run. Cheap habit, big save.',
    ],
    translations: const <String, ProjectTranslation>{
      'de': ProjectTranslation(
        title: 'Dynamische 3D-Immobilientouren',
        subtitle: 'Browser-basierte begehbare 3D-Gebäudemodelle für Immobilien',
        category: 'KLIENT / 3D',
        platform: 'Web · Cloud',
        technologyUsed:
            'Three.js · FastAPI · Node + TypeScript · PostgreSQL · MinIO/S3 · glTF Transform · Meshoptimizer · FFmpeg · Sharp · n8n · Docker · Kubernetes',
        portfolioDescription:
            'Eine Plattform für dynamische, begehbare 3D-Gebäudemodelle, '
            'die potenzielle Käufer im Browser erkunden — kein Plugin, '
            'keine App-Installation. Jedes Listing wird von einem '
            'Microservice-Mesh nach Concerns komponiert: ein 3D-Floor-'
            'Plan-Generator baut die Geometrie, ein Video-Processor '
            'schneidet Walkthrough-Material, ein KI-Staging-Service '
            'stellt Möbel in leere Räume, ein Geometrie-Optimierer '
            'kollabiert die Asset-Anzahl für die Browser-Auslieferung, '
            'und eine Bild-Pipeline (Sharp) komprimiert Texturen. Der '
            'Node-+-TypeScript-Orchestrator streamt jedes Asset von und '
            'nach Object-Storage, damit der Memory-Druck unabhängig von '
            'der Input-Größe konstant bleibt, und der sandboxed-Three.js-'
            'Viewer lässt Makler das verarbeitete Asset vor dem '
            'Veröffentlichen live prüfen.',
        decisions: <String>[
          'Die Plattform in **Microservices nach Concerns** aufgeteilt (Geometrie, Video, KI-Staging, Optimierung, Kompression) statt in einen Monolithen — jeder Service hat sein eigenes GPU-/CPU-Profil, skaliert unabhängig und kann ausfallen, ohne den Rest der Pipeline mitzunehmen.',
          'Jedes Asset **direkt von/nach Object-Storage gestreamt** — der Memory-Druck bleibt unabhängig von der Input-Größe konstant, sodass ein 4-GB-Walkthrough die Box nicht OOMt, die ein 200-MB-Walkthrough verarbeitet.',
          'Einen **sandboxed Three.js-Viewer** für die Makler-Vorschau gewählt statt eines Fat-Client — funktioniert in jedem Browser, kein Plugin-Install, kein App-Verteilungs-Kopfschmerz.',
          'Rund um **WSL2 + Podman + Makefile**-Orchestrierung gebaut mit einer expliziten Regel, die das README erzwingt: das Projekt darf nicht auf OneDrive liegen — Sync mitten im Build erzeugt I/O-Locks, die `make` crashen.',
          '**MinIO-Presigned-Uploads** verwendet, damit der Browser 4-GB-Walkthrough-Material direkt in den Object-Storage schiebt — der App-Server sieht die Bytes nie und wird nie zum Bottleneck.',
          'Jedes GLB durch **glTF Transform + Meshoptimizer** für Geometrie-/Textur-Kompression vor dem Publish geroutet; rohe 3D-Scans blieben ohne manuelles Cleanup in Blender unter dem Streaming-Budget.',
        ],
        learnings: <String>[
          'Ein `make`-Einstieg (`health-check`, `up`, `logs`, `db-check`, `seed`) senkt die kognitive Last deutlich mehr als rohes docker-compose für ein Service-Mesh dieser Größe.',
          'Health- + Disk-Space-Checks vor jedem Start fangen stale Dependencies oder Low-Disk-Zustände ab, bevor sie mitten im Lauf crashen. Billige Gewohnheit, großer Save.',
        ],
      ),
    },
  ),

  // 20 ----------------------------------------------------------------------
  ProjectItemData(title: 'PSCoat — Industrial Coatings Ops',
    subtitle: 'Playwright lead discovery + LLM inquiry triage',
    category: 'CLIENT / AUTOMATION',
    platform: 'Web · Python',
    primaryColor: const Color(0xFF0F172A),
    image: '$_d/pscoat/cover.webp',
    coverUrl: '$_d/pscoat/cover.webp',
    coverColorUrl: '$_d/pscoat/cover-color.webp',
    technologyUsed: 'Python 3.12 · Playwright · async/await · Mistral · WordPress',
    portfolioDescription:
        'Operations and lead-automation toolkit for an industrial '
        'coatings business. A Playwright-driven job-board crawler (with '
        'TOS-aware throttling and authenticated sessions) pulls '
        'qualified projects from vertical boards; a small LLM '
        'classifier sorts inbound inquiries into pricing / technical / '
        'callback buckets and drafts tone-matched responses in the '
        'company\'s voice. The same stack feeds the marketing-asset '
        'pipeline behind the public site.',
    isPublic: false,
    isLive: false,
    mockupType: 'laptop',
    screenshots: <String>[],
    decisions: <String>[
      'Used **Playwright over plain scraping** because Upwork ships Cloudflare Turnstile + browser fingerprinting + fraud detection (Incognia, Forter); only an authenticated, fingerprint-matched session bypasses the challenges. Naive `requests`-based scraping was blocked within minutes.',
      'Did a **manual login on first run, then reused the session jar** (`upwork_session.json`) — automated login would have been a continuous arms race against the bot-detection vendor, manual reauth-as-needed cost nothing extra.',
      'Made the **classifier output tone-matched drafts** in the company\'s voice via a small Mistral prompt — saved the operator from rewriting every reply from scratch while keeping the final send in human hands.',
      'Documented **explicit TOS guardrails**: educational + personal use only; nothing in the system supports commercial scraping. Drew the line up front instead of discovering it through a take-down.',
    ],
    learnings: <String>[
      'Selector fragility against modern marketplaces is permanent — instrument the scraper so breakage is visible the day it happens, not the day a deal is lost.',
      'Session expiration cadence is undocumented; building re-auth retry in from day one is much cheaper than discovering its absence at 11pm.',
    ],
    translations: const <String, ProjectTranslation>{
      'de': ProjectTranslation(
        title: 'PSCoat — Industrielle Beschichtungs-Ops',
        subtitle: 'Playwright-Lead-Discovery + LLM-Anfragen-Triage',
        category: 'KLIENT / AUTOMATION',
        platform: 'Web · Python',
        technologyUsed: 'Python 3.12 · Playwright · async/await · Mistral · WordPress',
        portfolioDescription:
            'Operations- und Lead-Automation-Toolkit für einen '
            'Industrie-Beschichtungs-Betrieb. Ein Playwright-getriebener '
            'Job-Board-Crawler (mit TOS-bewusstem Throttling und '
            'authentifizierten Sessions) zieht qualifizierte Projekte aus '
            'vertikalen Boards; ein kleiner LLM-Klassifikator sortiert '
            'eingehende Anfragen in Pricing-/Technical-/Callback-Buckets '
            'und entwirft tonlich passende Antworten in der Stimme des '
            'Unternehmens. Derselbe Stack speist die Marketing-Asset-'
            'Pipeline hinter der öffentlichen Seite.',
        decisions: <String>[
          '**Playwright statt simples Scraping** verwendet, weil Upwork Cloudflare Turnstile + Browser-Fingerprinting + Fraud-Detection (Incognia, Forter) ausliefert; nur eine authentifizierte, fingerprint-passende Session umgeht die Challenges. Naives `requests`-basiertes Scraping wurde innerhalb von Minuten geblockt.',
          'Beim **ersten Lauf manuell eingeloggt, dann den Session-Jar wiederverwendet** (`upwork_session.json`) — automatisches Login wäre ein dauerhaftes Wettrüsten gegen den Bot-Detection-Vendor gewesen; manuelles Reauth-wenn-nötig kostet zusätzlich nichts.',
          'Den Klassifikator-Output zu **tonlich passenden Entwürfen** in der Unternehmensstimme via kleinen Mistral-Prompt gemacht — erspart dem Operator das Neuschreiben jeder Antwort und hält den finalen Versand in menschlicher Hand.',
          '**Explizite TOS-Guardrails** dokumentiert: nur Bildungs- und Privatnutzung; nichts im System unterstützt kommerzielles Scraping. Die Linie vorab gezogen statt sie durch ein Take-down zu entdecken.',
        ],
        learnings: <String>[
          'Selector-Fragilität gegen moderne Marketplaces ist dauerhaft — den Scraper so instrumentieren, dass ein Bruch am Tag sichtbar wird, an dem er passiert, nicht am Tag, an dem ein Deal verloren geht.',
          'Die Session-Expiration-Kadenz ist undokumentiert; Re-Auth-Retry von Tag eins an einzubauen ist viel billiger, als ihr Fehlen um 23 Uhr zu entdecken.',
        ],
      ),
    },
  ),

  // 21 ----------------------------------------------------------------------
  ProjectItemData(title: 'Theater Website — Ruhrbühne Witten',
    subtitle: 'Programme + season-pass site for a German regional theater',
    category: 'CLIENT / WEB',
    platform: 'Web',
    primaryColor: const Color(0xFF7E22CE),
    image: '$_d/theater/cover.webp',
    coverUrl: '$_d/theater/cover.webp',
    coverColorUrl: '$_d/theater/cover-color.webp',
    technologyUsed: 'WordPress · Elementor Pro · PHP · MySQL',
    portfolioDescription:
        'Public-facing site for a German regional theater (Ruhrbühne '
        'Witten e.V.): programme listings, season-pass information, '
        'accessibility-first styling and a low-friction Elementor-based '
        'CMS so the artistic team can update copy without the developer '
        'being in the loop. Hosted with GDPR-compliant audience data '
        'handling and role-scoped admin.',
    isPublic: false,
    isLive: false,
    mockupType: 'laptop',
    screenshots: <String>[],
    decisions: <String>[
      'Picked **WordPress + Elementor Pro** instead of bespoke or JAMstack because the artistic team needed a CMS they could touch — not a Git repo. Wrong tool for engineers, right tool for actors.',
      'Versioned the site through **timestamped backup archives** (~2.8 GB of DB + uploads + plugins + themes) — Git would have been heavier and more brittle for an editorial workflow.',
      'Kept the site focused on **programme + season-pass information** rather than building an in-house ticket shop — payments, refunds and tax handling for a regional theater belong with a vendor that knows that domain, not in custom code.',
    ],
    learnings: <String>[
      'Backup-archive versioning works for editorial sites with one or two editors; drift risk grows the moment a third hand touches the admin.',
    ],
    translations: const <String, ProjectTranslation>{
      'de': ProjectTranslation(
        title: 'Theater-Website — Ruhrbühne Witten',
        subtitle: 'Programm- und Abo-Seite für ein deutsches Regionaltheater',
        category: 'KLIENT / WEB',
        platform: 'Web',
        technologyUsed: 'WordPress · Elementor Pro · PHP · MySQL',
        portfolioDescription:
            'Öffentliche Seite für ein deutsches Regionaltheater '
            '(Ruhrbühne Witten e.V.): Programm-Listings, '
            'Saisonkarten-Informationen, barrierefreies Styling und ein '
            'reibungsarmes Elementor-CMS, damit das künstlerische Team '
            'Texte ohne Entwickler im Loop aktualisieren kann. Gehostet '
            'mit DSGVO-konformer Besucherdaten-Verarbeitung und '
            'rollenbasiertem Admin.',
        decisions: <String>[
          '**WordPress + Elementor Pro** statt Custom oder JAMstack gewählt, weil das künstlerische Team ein CMS brauchte, das es anfassen kann — kein Git-Repo. Falsches Werkzeug für Engineers, richtiges Werkzeug für Schauspieler.',
          'Die Seite über **zeitgestempelte Backup-Archive** versioniert (~2,8 GB DB + Uploads + Plugins + Themes) — Git wäre für einen redaktionellen Workflow schwerer und spröder gewesen.',
          'Die Seite auf **Programm + Saisonkarten-Informationen** fokussiert gehalten statt einen eigenen Ticket-Shop zu bauen — Zahlungen, Erstattungen und Steuerthemen für ein Regionaltheater gehören zu einem Vendor, der diese Domäne kennt, nicht in Custom-Code.',
        ],
        learnings: <String>[
          'Backup-Archiv-Versionierung funktioniert für redaktionelle Seiten mit ein, zwei Redakteuren; das Drift-Risiko wächst in dem Moment, in dem eine dritte Hand das Admin anfasst.',
        ],
      ),
    },
  ),

  // 22 ----------------------------------------------------------------------
  ProjectItemData(title: 'NestNode — Smart-Home Concept',
    subtitle: 'Archived mobile concept rolled into Sovereign Smart Home',
    category: 'IOT / MOBILE',
    platform: 'iOS · Android',
    primaryColor: const Color(0xFF0891B2),
    image: '$_d/nestnode/cover.webp',
    coverUrl: '$_d/nestnode/cover.webp',
    coverColorUrl: '$_d/nestnode/cover-color.webp',
    technologyUsed: 'Flutter · MQTT · Home Assistant',
    portfolioDescription:
        'A mobile concept for a self-hosted Home Assistant deployment: '
        'lights, climate, energy and security in a tactile, '
        'fast-responding UI that talks MQTT directly from the device '
        'rather than through a cloud bridge. Archived at concept '
        'stage — the design language was rolled into the Sovereign '
        'Smart Home stack.',
    isPublic: false,
    isLive: false,
    mockupType: 'phone',
    screenshots: <String>[],
    decisions: <String>[
      'Archived as **concept-stage** — only a Word doc, logos and a moodboard exist; no codebase. The Home Assistant Edge stack absorbed the design language, so building a separate app would have been duplicate effort.',
    ],
    learnings: <String>[
      'Some projects are most useful as design exercises — the gesture-first nav and tactile energy view were rolled into the Sovereign Smart Home UX instead of shipped standalone.',
    ],
    translations: const <String, ProjectTranslation>{
      'de': ProjectTranslation(
        title: 'NestNode — Smart-Home-Konzept',
        subtitle: 'Archiviertes Mobile-Konzept, ins Souveräne Smart Home eingeflossen',
        category: 'IOT / MOBIL',
        platform: 'iOS · Android',
        technologyUsed: 'Flutter · MQTT · Home Assistant',
        portfolioDescription:
            'Ein Mobile-Konzept für ein selbst gehostetes Home-Assistant-'
            'Deployment: Licht, Klima, Energie und Sicherheit in einem '
            'taktilen, schnell reagierenden UI, das MQTT direkt vom Gerät '
            'spricht statt über eine Cloud-Bridge. Im Konzeptstatus '
            'archiviert — die Design-Sprache wurde in den Souveränen-'
            'Smart-Home-Stack überführt.',
        decisions: <String>[
          'Im **Konzeptstadium** archiviert — nur ein Word-Dokument, Logos und ein Moodboard existieren; keine Codebasis. Der Home-Assistant-Edge-Stack absorbierte die Design-Sprache, sodass eine separate App doppelte Arbeit gewesen wäre.',
        ],
        learnings: <String>[
          'Manche Projekte sind als Design-Übungen am wertvollsten — die gestenorientierte Navigation und die taktile Energie-Sicht wurden in die UX des Souveränen Smart Home überführt statt als Standalone ausgeliefert.',
        ],
      ),
    },
  ),

  // 23 ----------------------------------------------------------------------
  ProjectItemData(title: 'burakbasci_widgets',
    subtitle: 'Reusable Flutter widget library on pub.dev',
    category: 'OPEN SOURCE / PACKAGE',
    platform: 'Flutter',
    primaryColor: const Color(0xFF02569B),
    image: '$_d/widgets-pkg/cover.webp',
    coverUrl: '$_d/widgets-pkg/cover.webp',
    coverColorUrl: '$_d/widgets-pkg/cover-color.webp',
    technologyUsed: 'Dart · Flutter · null-safety · pub.dev',
    portfolioDescription:
        'A reusable Flutter widget library on pub.dev: animation '
        'primitives, layout helpers and UI components extracted from '
        'real production projects. Each widget ships with its own '
        'tests and dartdoc; the package is null-safety-first and '
        'tracks the current stable Flutter SDK. Used as the baseline '
        'kit for new Flutter apps.',
    isPublic: true,
    isLive: true,
    webUrl: 'https://pub.dev/packages/burakbasci_widgets',
    mockupType: 'terminal',
    screenshots: <String>[],
    decisions: <String>[
      'Maintained as a **standalone pub.dev package** rather than vendored per-project because every new Flutter app starts by adding it as a dep — the moment a widget is copy-pasted twice, it belongs in a library.',
      'Made the package **null-safety-first** and SDK-tracking — bumping the Flutter SDK never breaks the consumers because the package moves in lockstep.',
      'Required **widget tests + dartdoc on every widget** before merging — "it boots on my server" is not a release criterion for shared code.',
    ],
    learnings: <String>[
      'The "copy-paste twice → extract" discipline keeps the package honest; without it the package fills with one-off widgets and stops being a kit.',
    ],
    translations: const <String, ProjectTranslation>{
      'de': ProjectTranslation(
        title: 'burakbasci_widgets',
        subtitle: 'Wiederverwendbare Flutter-Widget-Bibliothek auf pub.dev',
        category: 'OPEN SOURCE / PACKAGE',
        platform: 'Flutter',
        technologyUsed: 'Dart · Flutter · Null-Safety · pub.dev',
        portfolioDescription:
            'Eine wiederverwendbare Flutter-Widget-Bibliothek auf '
            'pub.dev: Animations-Primitiven, Layout-Helfer und '
            'UI-Komponenten, extrahiert aus echten Produktivprojekten. '
            'Jedes Widget liefert mit eigenen Tests und Dartdoc; das '
            'Package ist null-safety-first und folgt dem aktuellen '
            'stable Flutter-SDK. Wird als Baseline-Kit für neue '
            'Flutter-Apps verwendet.',
        decisions: <String>[
          'Als **eigenständiges pub.dev-Package** gepflegt statt pro Projekt einzukopieren, weil jede neue Flutter-App damit anfängt, es als Dependency hinzuzufügen — sobald ein Widget zweimal copy-paste-d wird, gehört es in eine Library.',
          'Das Package **null-safety-first** und SDK-tracking gehalten — ein Flutter-SDK-Bump bricht die Consumer nie, weil das Package im Gleichschritt mitzieht.',
          '**Widget-Tests + Dartdoc auf jedem Widget** vor dem Merge verlangt — "es bootet auf meinem Server" ist kein Release-Kriterium für gemeinsamen Code.',
        ],
        learnings: <String>[
          'Die "Copy-Paste-Twice → Extract"-Disziplin hält das Package ehrlich; ohne sie füllt es sich mit Einmal-Widgets und hört auf, ein Kit zu sein.',
        ],
      ),
    },
  ),

  // 24 ----------------------------------------------------------------------
  ProjectItemData(title: 'AI Screenshot Recall',
    subtitle: 'Wayland-native evdev daemon racing Gemini vs Copilot',
    category: 'AI / TOOL',
    platform: 'Linux · Desktop',
    primaryColor: const Color(0xFF1D4ED8),
    image: '$_d/python-recall/cover.webp',
    coverUrl: '$_d/python-recall/cover.webp',
    coverColorUrl: '$_d/python-recall/cover-color.webp',
    technologyUsed:
        'Python · Google Gemini · GitHub Copilot · OpenCV · aiohttp · Server-Sent Events',
    portfolioDescription:
        'A "recall"-style desktop helper that captures the current '
        'screen, then races Gemini and Copilot against each other on '
        'parallel threads and streams whichever responds first to a '
        'local SSE overlay. Mouse-triggered with configurable '
        'shortcuts, per-provider timeouts and a small Wayland-native '
        'input layer that reads evdev directly. Sub-second insight '
        'into what\'s on screen without alt-tabbing into a chatbot.',
    isPublic: false,
    isLive: false,
    mockupType: 'terminal',
    screenshots: <String>[],
    decisions: <String>[
      'Read `/dev/input/eventN` via **evdev directly** instead of going through `input-remapper` + the Wayland inhibitor — the inhibitor blocks compositor shortcuts in FreeRDP fullscreen VMs, and evdev simply doesn\'t care. The triple-bind of input-remapper + inhibitor + compositor refused to cooperate; evdev was the escape hatch.',
      'Ran the daemon as a **user systemd service** rather than a global one — no root, no setuid binary, no per-machine sysadmin overhead.',
      'Raced **Gemini vs Copilot on parallel threads with SSE-stream-of-first-winner** because either provider can stall by 2–4 seconds on a bad day — never letting one block the other gave a hard p95 floor.',
      'Used **cosmic-screenshot for the frame capture on Wayland + Nvidia** — mss returns all-black frames there. Empirical finding; no other capture method worked.',
    ],
    learnings: <String>[
      '`EVIOCGRAB` prevents *grabbing* the device by others but not *reading* it — that single insight unlocked the entire daemon approach. Could have saved a weekend if I\'d read the kernel docs sooner.',
      'Systemd user services do **not** inherit group changes from `newgrp` or `usermod -aG` — a full re-login is required. Discovered the hard way; documented in README so the next person doesn\'t.',
      'input-remapper v2 JSON expects arrays + `Super_L+F5` syntax, not `key(super+F5)`. Broken JSON fails silently — instrument the loader.',
    ],
    translations: const <String, ProjectTranslation>{
      'de': ProjectTranslation(
        title: 'KI-Screenshot-Recall',
        subtitle: 'Wayland-nativer evdev-Daemon mit Gemini-vs-Copilot-Wettrennen',
        category: 'KI / TOOL',
        platform: 'Linux · Desktop',
        technologyUsed:
            'Python · Google Gemini · GitHub Copilot · OpenCV · aiohttp · Server-Sent Events',
        portfolioDescription:
            'Ein "Recall"-artiger Desktop-Helfer, der den aktuellen '
            'Bildschirm erfasst und dann Gemini und Copilot auf '
            'parallelen Threads gegeneinander rennen lässt und das, was '
            'zuerst antwortet, in ein lokales SSE-Overlay streamt. '
            'Mausgetriggert mit konfigurierbaren Shortcuts, '
            'Timeouts pro Provider und einer kleinen Wayland-nativen '
            'Input-Schicht, die evdev direkt liest. Sub-Sekunden-Einblick '
            'in das, was am Bildschirm ist, ohne in einen Chatbot zu '
            'alt-tabben.',
        decisions: <String>[
          '`/dev/input/eventN` direkt über **evdev** gelesen statt über `input-remapper` + den Wayland-Inhibitor zu gehen — der Inhibitor blockiert Compositor-Shortcuts in FreeRDP-Fullscreen-VMs, und evdev kümmert es schlicht nicht. Das Dreigespann input-remapper + Inhibitor + Compositor verweigerte die Kooperation; evdev war der Notausgang.',
          'Den Daemon als **User-systemd-Service** betrieben statt als globalen — kein Root, kein Setuid-Binary, kein per-Maschine-Sysadmin-Overhead.',
          '**Gemini gegen Copilot auf parallelen Threads gerast mit SSE-Stream-of-First-Winner**, weil jeder Provider an einem schlechten Tag um 2–4 Sekunden stallen kann — einem niemals erlauben, den anderen zu blockieren, ergab einen harten p95-Floor.',
          '**cosmic-screenshot für die Frame-Capture auf Wayland + Nvidia** verwendet — mss liefert dort komplett schwarze Frames. Empirisch festgestellt; keine andere Capture-Methode funktionierte.',
        ],
        learnings: <String>[
          '`EVIOCGRAB` verhindert das *Grabben* des Geräts durch andere, aber nicht das *Lesen* — diese einzelne Erkenntnis schaltete den gesamten Daemon-Ansatz frei. Hätte ein Wochenende gespart, wenn ich die Kernel-Docs früher gelesen hätte.',
          'systemd-User-Services übernehmen **keine** Group-Changes von `newgrp` oder `usermod -aG` — ein voller Re-Login ist nötig. Auf die harte Tour entdeckt; im README dokumentiert, damit der Nächste das nicht tut.',
          'input-remapper v2 JSON erwartet Arrays + `Super_L+F5`-Syntax, nicht `key(super+F5)`. Kaputtes JSON schlägt still fehl — den Loader instrumentieren.',
        ],
      ),
    },
  ),

  // 25 ----------------------------------------------------------------------
  ProjectItemData(title: 'BoxHead — Unreal FPS',
    subtitle: 'Wave-based first-person shooter built in UE5 + C++',
    category: 'GAME / UNREAL',
    platform: 'Windows · Linux',
    primaryColor: const Color(0xFF1F2937),
    image: '$_d/boxhead/cover.webp',
    coverUrl: '$_d/boxhead/cover.webp',
    coverColorUrl: '$_d/boxhead/cover-color.webp',
    technologyUsed: 'Unreal Engine 5 · C++ · Blueprints',
    portfolioDescription:
        'A fast-paced 3D shooter built in Unreal Engine 5 — '
        'claustrophobic maze-like arenas, wave-based AI, ranged and '
        'melee weapons with their own feel. C++ handles the weapon '
        'systems (spread, ricochet, projectile pooling), particle '
        'effects sell the impacts, and the same project builds editor '
        'and shipping targets for both Linux and Windows with high-res '
        'screenshot tooling for level-design iteration.',
    isPublic: false,
    isLive: false,
    // 'laptop' frames render an actual MacBook-style bezel around the
    // image — without that the unreal-still mockupType only letterboxes
    // the shot, which makes gameplay screens read like a static crop.
    mockupType: 'laptop',
    screenshots: <String>[
      '$_d/boxhead/shot-01.png',
      '$_d/boxhead/shot-04.png',
    ],
    decisions: <String>[
      'Wrote the **weapon systems in C++**, not Blueprints, because the per-shot feel has to be tunable to single-frame accuracy — Blueprints add latency and the spread/ricochet math is fiddly enough that a typed compiler is worth it.',
      'Baked **high-res screenshot tooling into the build** so every level-design iteration auto-generates a marketing-grade still — work product is also documentation.',
      'Built **editor + shipping targets for both Linux and Windows from one project tree** — parallel platform branches always drift, single-tree builds force the platform diffs to live in code review.',
    ],
    learnings: <String>[
      'Maze-like claustrophobic arenas drive the wave-shooter feel more than enemy variety does; one tight corridor + one mood carries the game further than a roster of monster types.',
    ],
    translations: const <String, ProjectTranslation>{
      'de': ProjectTranslation(
        title: 'BoxHead — Unreal FPS',
        subtitle: 'Wellenbasierter Ego-Shooter mit UE5 + C++',
        category: 'SPIEL / UNREAL',
        platform: 'Windows · Linux',
        technologyUsed: 'Unreal Engine 5 · C++ · Blueprints',
        portfolioDescription:
            'Ein schneller 3D-Shooter, gebaut in Unreal Engine 5 — '
            'klaustrophobische, labyrinthartige Arenen, wellenbasierte '
            'KI, Fern- und Nahkampfwaffen mit eigenem Feel. C++ '
            'übernimmt die Waffensysteme (Spread, Ricochet, Projectile-'
            'Pooling), Partikeleffekte verkaufen die Treffer, und '
            'dasselbe Projekt baut Editor- und Shipping-Targets für '
            'Linux und Windows mit High-Res-Screenshot-Tooling für die '
            'Level-Design-Iteration.',
        decisions: <String>[
          'Die **Waffensysteme in C++** geschrieben, nicht in Blueprints, weil das Per-Shot-Feel auf einen Frame genau tunebar sein muss — Blueprints bringen Latenz, und die Spread-/Ricochet-Mathematik ist fummelig genug, dass ein typisierter Compiler den Aufwand wert ist.',
          '**High-Res-Screenshot-Tooling in den Build eingebacken**, sodass jede Level-Design-Iteration automatisch ein marketingtaugliches Still erzeugt — das Arbeitsprodukt ist auch Dokumentation.',
          '**Editor- + Shipping-Targets für Linux und Windows aus einem Projektbaum** gebaut — parallele Plattform-Branches driften immer; Single-Tree-Builds zwingen die Plattform-Diffs in den Code-Review.',
        ],
        learnings: <String>[
          'Labyrinthartige, klaustrophobische Arenen treiben das Wave-Shooter-Feel stärker als Gegnervielfalt; ein enger Korridor + eine Stimmung trägt das Spiel weiter als ein Roster an Monster-Typen.',
        ],
      ),
    },
  ),

  // 26 ----------------------------------------------------------------------
  ProjectItemData(title: 'Flappy Griffon',
    subtitle: 'Ray-traced indie game on itch.io',
    category: 'GAME / UNREAL',
    platform: 'Windows · Android',
    primaryColor: const Color(0xFFF59E0B),
    image: '$_d/flappy-griffon/cover.webp',
    coverUrl: '$_d/flappy-griffon/cover.webp',
    coverColorUrl: '$_d/flappy-griffon/cover-color.webp',
    technologyUsed: 'Unreal Engine 5 · C++ · Blueprints · Water plugin',
    portfolioDescription:
        'A 3D, ray-traced reimagining of Flappy Bird. A griffon '
        'navigates a continuously generated obstacle course; the '
        'Water plugin handles the cinematic lake reflections, '
        'ray-tracing carries the lighting, and the same project builds '
        'across Windows, Linux, Android and Mac. Shipped on itch.io.',
    isPublic: true,
    isLive: true,
    webUrl: 'https://burakbasci.itch.io/flappygriffon',
    mockupType: 'unreal-still',
    screenshots: <String>[],
    decisions: <String>[
      'Picked **ray-tracing for water + global illumination** because it\'s the visual hook in a genre that\'s usually 2D pixel art — the surprise is the entire selling point.',
      'Built **one cross-platform project (Windows / Linux / Android / Mac)** instead of parallel ports — same reason as BoxHead, parallel trees always drift.',
      'Shipped on **itch.io** rather than a gatekeeping storefront — same-day publishing, no review queue, no platform tax on indie experiments.',
    ],
    learnings: <String>[
      'Reskinning a known mechanic (Flappy Bird) is a learning-vehicle accelerator; nobody has to figure out how to play, so the surprise is purely visual.',
    ],
    translations: const <String, ProjectTranslation>{
      'de': ProjectTranslation(
        title: 'Flappy Griffon',
        subtitle: 'Raytraced Indie-Spiel auf itch.io',
        category: 'SPIEL / UNREAL',
        platform: 'Windows · Web',
        technologyUsed: 'Unreal Engine 5 · C++ · Blueprints · Water-Plugin',
        portfolioDescription:
            'Eine 3D-Raytraced-Neuinterpretation von Flappy Bird. Ein '
            'Greif navigiert durch einen kontinuierlich generierten '
            'Hindernisparcours; das Water-Plugin liefert die '
            'cineastischen See-Reflexionen, Raytracing trägt die '
            'Beleuchtung, und dasselbe Projekt baut für Windows, Linux, '
            'Android und Mac. Auf itch.io veröffentlicht.',
        decisions: <String>[
          '**Raytracing für Wasser + Global Illumination** gewählt, weil das der visuelle Hook in einem Genre ist, das sonst meist 2D-Pixel-Art ist — die Überraschung ist das gesamte Verkaufsargument.',
          '**Ein plattformübergreifendes Projekt (Windows / Linux / Android / Mac)** statt paralleler Ports gebaut — gleicher Grund wie bei BoxHead: parallele Bäume driften immer.',
          'Auf **itch.io** veröffentlicht statt auf einem Gatekeeping-Storefront — Same-Day-Publishing, keine Review-Queue, keine Plattform-Steuer auf Indie-Experimente.',
        ],
        learnings: <String>[
          'Eine bekannte Mechanik neu zu skinnen (Flappy Bird) ist ein Learning-Vehicle-Beschleuniger; niemand muss erst herausfinden, wie man spielt — die Überraschung ist rein visuell.',
        ],
      ),
    },
  ),

  // 27 ----------------------------------------------------------------------
  ProjectItemData(title: 'MyJumpNRun',
    subtitle: 'Iterative UE5 platformer series',
    category: 'GAME / UNREAL',
    platform: 'Windows',
    primaryColor: const Color(0xFF65A30D),
    image: '$_d/jumpnrun/cover.webp',
    coverUrl: '$_d/jumpnrun/cover.webp',
    coverColorUrl: '$_d/jumpnrun/cover-color.webp',
    technologyUsed: 'Unreal Engine 5 · C++ · Blueprints',
    portfolioDescription:
        'A personal Unreal Engine platformer rebuilt across multiple '
        'iterations (5.2, 5.2-variant, ...) to keep pushing on level '
        'design, character physics and Blueprint scripting. Tight '
        'movement (jump buffering, coyote time, wall-slide detection), '
        'checkpoints and a small replay system make the core mechanics '
        'feel responsive enough that the levels stand on their own.',
    isPublic: false,
    isLive: false,
    mockupType: 'unreal-still',
    screenshots: <String>[],
    decisions: <String>[
      'Tuned **jump buffering + coyote time + wall-slide detection up front** before designing any level — feel-tuning early means the levels exist for movement that already works, not the other way around.',
      'Tracked **multiple project iterations as separate folders** (5.2, variant, ...) so old level files stayed playable as the engine updated — destructive in-place upgrades would have lost the early-iteration content.',
    ],
    learnings: <String>[
      'Iterating on platformer feel is mostly about input latency and the curve of the jump arc; everything else (art, music, levels) is decoration on top.',
    ],
    translations: const <String, ProjectTranslation>{
      'de': ProjectTranslation(
        title: 'MyJumpNRun',
        subtitle: 'Iterative UE5-Plattformer-Serie',
        category: 'SPIEL / UNREAL',
        platform: 'Windows',
        technologyUsed: 'Unreal Engine 5 · C++ · Blueprints',
        portfolioDescription:
            'Ein persönlicher Unreal-Engine-Plattformer, über mehrere '
            'Iterationen (5.2, 5.2-Variante, …) neu aufgebaut, um Level-'
            'Design, Character-Physics und Blueprint-Scripting weiter zu '
            'treiben. Tight gehaltene Bewegung (Jump-Buffering, Coyote '
            'Time, Wall-Slide-Detection), Checkpoints und ein kleines '
            'Replay-System lassen die Kernmechanik responsiv genug '
            'wirken, dass die Levels für sich stehen.',
        decisions: <String>[
          '**Jump-Buffering + Coyote Time + Wall-Slide-Detection vorab getunt**, bevor ein einziges Level designt wurde — Feel-Tuning früh bedeutet, dass die Levels für eine Bewegung existieren, die bereits funktioniert, nicht andersherum.',
          '**Mehrere Projekt-Iterationen als getrennte Ordner** verfolgt (5.2, Variante, …), damit alte Level-Files spielbar blieben, während die Engine geupdated wurde — destruktive In-Place-Upgrades hätten die frühen Iterationen verloren.',
        ],
        learnings: <String>[
          'Plattformer-Feel zu iterieren geht meist um Input-Latenz und die Kurve des Sprungs; alles andere (Art, Musik, Levels) ist Deko obendrauf.',
        ],
      ),
    },
  ),

  // 28 ----------------------------------------------------------------------
  ProjectItemData(title: 'ALSignal — ASL Hackathon',
    subtitle: 'Real-time American Sign Language in Unity',
    category: 'HACKATHON / CV',
    platform: 'Windows · Unity',
    primaryColor: const Color(0xFF1F2937),
    image: '$_d/unity-hackathon/cover.webp',
    coverUrl: '$_d/unity-hackathon/cover.webp',
    coverColorUrl: '$_d/unity-hackathon/cover-color.webp',
    technologyUsed: 'Unity · C# · MediaPipe · LSTM · Webcam',
    portfolioDescription:
        'A weekend hackathon build: real-time American Sign Language '
        'detection inside Unity. MediaPipe estimates the hand pose at '
        '30 FPS; a small LSTM trained on a captured gesture set '
        'classifies each window of frames into the right sign. The '
        'demo overlays the recognised label and a confidence bar live '
        'on the camera feed.',
    isPublic: false,
    isLive: false,
    mockupType: 'fullbleed',
    screenshots: <String>[],
    decisions: <String>[
      'Picked **MediaPipe + a small custom LSTM** over a one-shot vision model — off-the-shelf hand-tracking plus a tiny trainable classifier beats a single big model for niche gesture sets at this scale, and trains in minutes instead of hours.',
      'Built the demo in **Unity** instead of a web frontend so the captured gesture set could stay on-device — privacy was a hackathon talking point as much as a real constraint.',
      'Overlaid the **confidence bar + label live on the webcam feed** because visible decisions are easier to debug at a hackathon than logs are — judges see the model thinking.',
    ],
    learnings: <String>[
      'Computer-vision UX at a hackathon stands or falls on a working live demo; the LSTM won purely because it was demoable.',
    ],
    translations: const <String, ProjectTranslation>{
      'de': ProjectTranslation(
        title: 'ALSignal — ASL Hackathon',
        subtitle: 'Echtzeit American Sign Language in Unity',
        category: 'HACKATHON / VISION',
        platform: 'Unity',
        technologyUsed: 'Unity · C# · MediaPipe · LSTM · Webcam',
        portfolioDescription:
            'Ein Wochenend-Hackathon-Build: Echtzeit-Erkennung von '
            'American Sign Language innerhalb von Unity. MediaPipe '
            'schätzt die Handpose bei 30 FPS; ein kleines, auf einem '
            'aufgenommenen Gesten-Set trainiertes LSTM klassifiziert '
            'jedes Frame-Fenster in das richtige Zeichen. Die Demo '
            'überlagert das erkannte Label und einen Confidence-Bar '
            'live auf dem Kamera-Feed.',
        decisions: <String>[
          '**MediaPipe + ein kleines Custom-LSTM** gegenüber einem One-Shot-Vision-Modell gewählt — Off-the-Shelf-Hand-Tracking plus ein winziger trainierbarer Klassifikator schlägt ein einzelnes großes Modell für Nischen-Gesten-Sets in dieser Größenordnung und trainiert in Minuten statt Stunden.',
          'Die Demo in **Unity** statt in einem Web-Frontend gebaut, damit das aufgenommene Gesten-Set on-device bleiben konnte — Privacy war beim Hackathon Talking Point genauso wie reale Anforderung.',
          'Den **Confidence-Bar + das Label live auf den Webcam-Feed** gelegt, weil sichtbare Entscheidungen bei einem Hackathon leichter zu debuggen sind als Logs — Jurys sehen das Modell denken.',
        ],
        learnings: <String>[
          'Computer-Vision-UX bei einem Hackathon steht und fällt mit einer funktionierenden Live-Demo; das LSTM gewann rein deshalb, weil es demobar war.',
        ],
      ),
    },
  ),

  // 29 ----------------------------------------------------------------------
  ProjectItemData(title: 'Steam Market Arbitrage Bot',
    subtitle: 'Trading-card economy analyser with risk scoring',
    category: 'AUTOMATION / FINANCE',
    platform: 'Linux',
    primaryColor: const Color(0xFF1B2838),
    image: '$_d/steam-market/cover.webp',
    coverUrl: '$_d/steam-market/cover.webp',
    coverColorUrl: '$_d/steam-market/cover-color.webp',
    technologyUsed: 'Python · BeautifulSoup · Requests · SQLite',
    portfolioDescription:
        'A research toolkit for the Steam Community Market: scans '
        'thousands of listings a day and detects arbitrage loops — '
        'gem → booster pack crafting spreads, card → gem conversions, '
        'foil-card price gaps, and badge → component economics. '
        'Cookie-based authenticated session respects Steam\'s rate '
        'limits, every simulated trade factors in Steam\'s 15% market '
        'fee, and a local SQLite stores opportunities with a risk '
        'score so the obviously-stale ones get filtered before a human '
        'sees them.',
    isPublic: false,
    isLive: false,
    mockupType: 'terminal',
    screenshots: <String>[],
    decisions: <String>[
      'Used a **cookie-based authenticated session** that respects rate limits because anonymous scraping of the market gets blocked within minutes — being a guest on Valve\'s API isn\'t viable for this kind of scan.',
      'Baked **Steam\'s 15% market fee into every simulated trade** because opportunities that ignore the fee look 10× bigger than they are; ranking by raw spread is a fast way to lose money.',
      'Ranked opportunities by **risk score** (depth-of-book + listing age + spread volatility) rather than raw margin — most "arbitrage" on inefficient marketplaces is actually a liquidity trap.',
    ],
    learnings: <String>[
      'Ranking by risk-of-execution beats ranking by margin every time on a thin marketplace; the right top-1 is the listing you can actually clear, not the listing that looks biggest.',
    ],
    translations: const <String, ProjectTranslation>{
      'de': ProjectTranslation(
        title: 'Steam Market Arbitrage Bot',
        subtitle: 'Sammelkarten-Wirtschaftsanalyse mit Risk-Scoring',
        category: 'AUTOMATION / SCRAPING',
        platform: 'Python',
        technologyUsed: 'Python · BeautifulSoup · Requests · SQLite',
        portfolioDescription:
            'Ein Research-Toolkit für den Steam Community Market: '
            'scannt täglich tausende Listings und entdeckt Arbitrage-'
            'Loops — Gem-→-Booster-Pack-Crafting-Spreads, Card-→-Gem-'
            'Konversionen, Foil-Karten-Preisunterschiede und Badge-→-'
            'Komponenten-Ökonomie. Eine cookie-basierte authentifizierte '
            'Session respektiert Steams Rate-Limits, jeder simulierte '
            'Trade rechnet Steams 15-%-Marktgebühr ein, und ein lokales '
            'SQLite speichert Opportunities mit einem Risiko-Score, '
            'damit die offensichtlich veralteten herausgefiltert werden, '
            'bevor ein Mensch sie sieht.',
        decisions: <String>[
          'Eine **cookie-basierte authentifizierte Session**, die Rate-Limits respektiert, verwendet, weil anonymes Scraping des Markets innerhalb von Minuten geblockt wird — Gast auf Valves API zu sein ist für diese Art von Scan nicht tragfähig.',
          'Steams **15-%-Marktgebühr in jeden simulierten Trade eingebacken**, weil Opportunities, die die Gebühr ignorieren, 10× größer aussehen als sie sind; nach rohem Spread zu sortieren ist ein schneller Weg, Geld zu verlieren.',
          'Opportunities nach **Risiko-Score** sortiert (Depth-of-Book + Listing-Alter + Spread-Volatilität) statt nach roher Marge — die meiste "Arbitrage" auf ineffizienten Marketplaces ist in Wahrheit eine Liquiditätsfalle.',
        ],
        learnings: <String>[
          'Nach Risk-of-Execution zu sortieren schlägt jedes Mal das Sortieren nach Marge auf einem dünnen Marketplace; das richtige Top-1 ist das Listing, das man wirklich abräumen kann, nicht das, das am größten aussieht.',
        ],
      ),
    },
  ),

  // 30 ----------------------------------------------------------------------
  ProjectItemData(title: 'CSFloat Sniper',
    subtitle: 'CS:GO marketplace scanner with API integration',
    category: 'AUTOMATION / RESEARCH',
    platform: 'Linux',
    primaryColor: const Color(0xFFEAB308),
    image: '$_d/csfloat/cover.webp',
    coverUrl: '$_d/csfloat/cover.webp',
    coverColorUrl: '$_d/csfloat/cover-color.webp',
    technologyUsed: 'Python · aiohttp · CSFloat API · asyncio',
    portfolioDescription:
        'A scanner that watches CSFloat marketplace listings (Bayonet '
        'Vanilla, covert tier) for price + condition mismatches and '
        'notifies a private channel. Built to learn browser-automation '
        'and event-driven Python; configurable dry-run mode skips '
        'order placement during testing.',
    isPublic: false,
    isLive: false,
    mockupType: 'terminal',
    screenshots: <String>[],
    decisions: <String>[
      'Cached **listings + buy orders into a single immutable `MarketDataCache` dataclass** rather than fetching per function — collapsed 3 API calls per item into 2 and stopped a class of "is this data still fresh?" bugs at the type level.',
      'Loaded API tokens **from environment via a gitignored `.env`** — never check the credential surface into git, even for personal tooling.',
    ],
    learnings: <String>[
      'Redundant API calls show up easily in multi-function workflows; one systematic audit of call sites before optimisation prevents regression and is faster than chasing them one at a time.',
      'Caching by whole-value-object (entire market snapshot) instead of per-field simplified downstream signatures and removed a lot of state-passing noise.',
    ],
    translations: const <String, ProjectTranslation>{
      'de': ProjectTranslation(
        title: 'CSFloat Sniper',
        subtitle: 'CS:GO Marktplatz-Scanner mit API-Integration',
        category: 'AUTOMATION / SCRAPING',
        platform: 'Python',
        technologyUsed: 'Python · aiohttp · CSFloat API · asyncio',
        portfolioDescription:
            'Ein Scanner, der CSFloat-Marktplatz-Listings (Bayonet '
            'Vanilla, Covert-Tier) auf Preis- und Zustands-Mismatches '
            'beobachtet und einen privaten Channel benachrichtigt. '
            'Gebaut, um Browser-Automation und event-driven Python zu '
            'lernen; konfigurierbarer Dry-Run-Mode überspringt die '
            'Order-Platzierung während Tests.',
        decisions: <String>[
          '**Listings + Buy-Orders in eine einzige unveränderliche `MarketDataCache`-Dataclass** gecached, statt pro Funktion zu fetchen — hat 3 API-Calls pro Item auf 2 kollabiert und eine Klasse von "ist diese Daten noch frisch?"-Bugs auf Typ-Ebene gestoppt.',
          'API-Tokens **aus dem Environment via einer gitignored `.env`** geladen — die Credential-Surface nie in Git einchecken, auch nicht für persönliches Tooling.',
        ],
        learnings: <String>[
          'Redundante API-Calls tauchen in Multi-Funktions-Workflows leicht auf; ein systematisches Audit der Call-Sites vor der Optimierung verhindert Regressionen und ist schneller, als ihnen einzeln nachzujagen.',
          'Caching nach ganzem Value-Objekt (gesamter Markt-Snapshot) statt pro Feld vereinfachte Downstream-Signaturen und entfernte viel State-Passing-Rauschen.',
        ],
      ),
    },
  ),

  // 31 ----------------------------------------------------------------------
  ProjectItemData(title: 'Binance → German Tax PDF',
    subtitle: 'CSV-to-Steuerbericht generator',
    category: 'TOOL / UTILITY',
    platform: 'Linux',
    primaryColor: const Color(0xFFB45309),
    image: '$_d/binance-tax/cover.webp',
    coverUrl: '$_d/binance-tax/cover.webp',
    coverColorUrl: '$_d/binance-tax/cover-color.webp',
    technologyUsed: 'Python · WeasyPrint · pango · cairo',
    portfolioDescription:
        'A CLI tool that turns a Binance transaction-history export '
        'into a formal `DEUTSCHER STEUERBERICHT` PDF: parses every '
        'trade, computes the FIFO cost basis per asset, walks the '
        'realised gains and losses by year, and renders it through '
        'WeasyPrint with the typography the German tax office expects.',
    isPublic: false,
    isLive: false,
    mockupType: 'terminal',
    screenshots: <String>[],
    decisions: <String>[
      'Used **WeasyPrint over Pdfkit / ReportLab** because pango + cairo handle German typography (umlauts, hyphenation, kerning) without typesetting drama; ReportLab would have required hand-tuning every column.',
      'Picked the **FIFO cost basis** because that\'s what the Finanzbehörde wants — no opinion required. Implementing LIFO/HIFO would have been a tax-audit conversation nobody wants.',
      'Shipped as a **CLI, not a UI** — the tool is used once a year per portfolio; headless fits cron / CI / one-off runs cleanly and there\'s no demand for a chrome around it.',
    ],
    learnings: <String>[
      'Compliance documents look dramatically more credible when they use the right typography — DIN-style margins and faces did more for trust than feature work would have.',
    ],
    translations: const <String, ProjectTranslation>{
      'de': ProjectTranslation(
        title: 'Binance Steuerbericht (DE)',
        subtitle: 'CSV-zu-Steuerbericht-Generator',
        category: 'AUTOMATION / FINANZEN',
        platform: 'Python · CLI',
        technologyUsed: 'Python · WeasyPrint · pango · cairo',
        portfolioDescription:
            'Ein CLI-Tool, das einen Binance-Transaktionsverlauf-Export '
            'in ein formales `DEUTSCHER STEUERBERICHT`-PDF überführt: '
            'parst jeden Trade, berechnet die FIFO-Anschaffungskosten '
            'pro Asset, läuft die realisierten Gewinne und Verluste pro '
            'Jahr durch und rendert das Ganze mit WeasyPrint in der '
            'Typografie, die das Finanzamt erwartet.',
        decisions: <String>[
          '**WeasyPrint gegenüber Pdfkit / ReportLab** verwendet, weil pango + cairo deutsche Typografie (Umlaute, Silbentrennung, Kerning) ohne Satz-Drama beherrschen; ReportLab hätte das Handtuning jeder Spalte verlangt.',
          'Den **FIFO-Cost-Basis** gewählt, weil die Finanzbehörde das so will — keine Meinung erforderlich. LIFO/HIFO zu implementieren wäre ein Steuerprüfungs-Gespräch geworden, das niemand führen möchte.',
          'Als **CLI ausgeliefert, nicht als UI** — das Tool wird einmal pro Jahr pro Portfolio verwendet; headless passt sauber zu cron / CI / einmaligen Läufen, und es gibt keine Nachfrage nach Chrome drumherum.',
        ],
        learnings: <String>[
          'Compliance-Dokumente wirken dramatisch glaubwürdiger, wenn sie die richtige Typografie nutzen — DIN-konforme Ränder und Schriften haben mehr für das Vertrauen getan, als Feature-Arbeit es hätte.',
        ],
      ),
    },
  ),

  // 32 ----------------------------------------------------------------------
  ProjectItemData(title: 'WordPress Plugins for an Agency',
    subtitle: 'In-house plugins that replaced paid third-party tools',
    category: 'PHP / IN-HOUSE TOOLS',
    platform: 'WordPress',
    primaryColor: const Color(0xFF21759B),
    image: '$_d/wp-plugins/cover.webp',
    coverUrl: '$_d/wp-plugins/cover.webp',
    coverColorUrl: '$_d/wp-plugins/cover-color.webp',
    technologyUsed: 'PHP · WordPress · MySQL · PHPUnit',
    portfolioDescription:
        'A small library of proprietary WordPress plugins I wrote for a '
        'WordPress website agency to cut their recurring licence bill. '
        'Each plugin replaced a paid third-party tool the agency was '
        'paying for across every client site — ImmoWare-style listing '
        'embeds, custom taxonomy management, SEO helpers, a few '
        'workflow utilities. Plugins ship with PHPUnit tests, track '
        'the WordPress LTS line for long-term compatibility, and stay '
        'inside the agency — they are not open-source.',
    isPublic: false,
    isLive: false,
    mockupType: 'laptop',
    screenshots: <String>[],
    decisions: <String>[
      'Wrote **in-house replacements for paid third-party plugins** rather than renewing licences across every client site — at the agency\'s site count the per-seat fees were paying for one of my work-days a month, so the build-once-and-own-it economics flipped almost immediately.',
      'Required **PHPUnit tests + inline docblocks** before merging — these plugins run on dozens of paying client sites, so "it boots on my server" is not a release criterion. The test suite is what lets the agency upgrade WP cores without paging me back in.',
      'Tracked the **WordPress LTS line** for long-term compatibility — every plugin survives at least three WP major versions, so client sites don\'t break on routine WP updates and the agency isn\'t stuck rotating plugins every release.',
    ],
    learnings: <String>[
      'The interesting cost of a third-party plugin isn\'t the licence — it\'s the lock-in to that vendor\'s release cadence. Owning the code means the agency upgrades on its own schedule and can deprecate features they never used.',
    ],
    translations: const <String, ProjectTranslation>{
      'de': ProjectTranslation(
        title: 'WordPress-Plugins für eine Agentur',
        subtitle: 'Eigenentwicklungen, die bezahlte Drittanbieter-Plugins ersetzten',
        category: 'PHP / INTERNE TOOLS',
        platform: 'WordPress',
        technologyUsed: 'PHP · WordPress · MySQL · PHPUnit',
        portfolioDescription:
            'Eine kleine Bibliothek proprietärer WordPress-Plugins, die '
            'ich für eine WordPress-Webagentur geschrieben habe, um '
            'ihre laufenden Lizenzkosten zu senken. Jedes Plugin '
            'ersetzte ein bezahltes Drittanbieter-Tool, das die Agentur '
            'über jede Kundenseite hinweg bezahlte — ImmoWare-artige '
            'Listing-Einbindungen, Custom-Taxonomie-Verwaltung, SEO-'
            'Helfer, ein paar Workflow-Utilities. Die Plugins liefern '
            'mit PHPUnit-Tests, folgen der WordPress-LTS-Linie für '
            'Langzeitkompatibilität und bleiben innerhalb der Agentur — '
            'sie sind nicht Open Source.',
        decisions: <String>[
          '**In-house-Ersatz für bezahlte Drittanbieter-Plugins** geschrieben statt Lizenzen über jede Kundenseite zu verlängern — bei der Anzahl der Sites der Agentur bezahlten die Per-Seat-Gebühren etwa einen Arbeitstag im Monat von mir, sodass die "einmal bauen und besitzen"-Ökonomie fast sofort kippte.',
          '**PHPUnit-Tests + Inline-Docblocks** vor dem Merge verlangt — diese Plugins laufen auf dutzenden zahlenden Kundenseiten, also ist "es bootet auf meinem Server" kein Release-Kriterium. Die Test-Suite ist das, was es der Agentur erlaubt, WP-Cores zu upgraden, ohne mich zurückzuholen.',
          'Die **WordPress-LTS-Linie** für Langzeitkompatibilität verfolgt — jedes Plugin überlebt mindestens drei WP-Major-Versionen, sodass Kundenseiten bei Routine-WP-Updates nicht brechen und die Agentur nicht jede Release-Runde Plugins rotieren muss.',
        ],
        learnings: <String>[
          'Die interessanten Kosten eines Drittanbieter-Plugins sind nicht die Lizenz — es ist das Lock-in an die Release-Kadenz dieses Vendors. Den Code zu besitzen heißt, die Agentur upgradet nach eigenem Zeitplan und kann Features deprecaten, die sie nie genutzt hat.',
        ],
      ),
    },
  ),

  // 33 ----------------------------------------------------------------------
  ProjectItemData(title: 'burakbasci.de',
    subtitle: 'This portfolio site — Flutter Web, Material 2, content-driven',
    category: 'WEB / PERSONAL',
    platform: 'Flutter Web',
    primaryColor: const Color(0xFF363636),
    image: '$_d/this-site/cover.webp',
    coverUrl: '$_d/this-site/cover.webp',
    coverColorUrl: '$_d/this-site/cover-color.webp',
    technologyUsed: 'Flutter Web · CanvasKit · GitHub Pages · Podman',
    portfolioDescription:
        'The site you are reading. Flutter Web on the CanvasKit renderer, '
        'deployed to GitHub Pages with a custom domain. A complete '
        'rewrite of the source code — only loosely inspired by David '
        'Cobbina\'s open-source portfolio template — into a new widget '
        'tree (header / footer / page-wrapper / animation primitives), '
        'built against current stable Flutter, with a centralised '
        '`PageTransition` overlay, scroll-driven device-frame mockups, '
        'a dual cover system (typographic main + cinematic hover), an '
        'AI-prompt + WebP install pipeline for project covers, and an '
        'architecture-illustration section. Every animation, font, '
        'route, prompt and project page is content-driven by '
        '`lib/data/projects.dart`.',
    isPublic: true,
    isLive: true,
    webUrl: 'https://www.burakbasci.de',
    gitHubUrl: 'https://github.com/burak-basci/burak_basci_website',
    mockupType: 'laptop',
    screenshots: <String>[],
    decisions: <String>[
      'Treated David Cobbina\'s upstream as **inspiration only**, then rewrote the entire widget tree — header / footer / page-wrapper / animation primitives / transition system / mockup gallery / data layer — against a current stable Flutter SDK. Cherry-picking from upstream was abandoned once the new shape stopped resembling the original.',
      'Centralised every navigation through a single **PageTransition overlay** with a left-anchored scaleX cover and a right-anchored uncover (the original wipe direction, but driven by one global controller). A reentrancy guard kills the stuck-black-panel bug that per-page listeners produced.',
      'Enforced **`useMaterial3: false`** to retain Material 2 ink ripples and elevation — M3 introduced visual drift in the top nav and footer that wasn\'t worth fighting and that nobody asked for.',
      'Picked **URW Gothic + Carlito + Inter** for the brand fonts (all OFL) because Microsoft\'s DSIG-signed Century Gothic and Calibri break CanvasKit — discovered the hard way.',
      'Built **Flutter 3.41.9 strictly inside `ghcr.io/cirruslabs/flutter:stable` Podman** with no host install — every build reproduces on any machine, and CI is just "same command, somewhere else".',
      'Switched to **`usePathUrlStrategy()`** so each project URL is its own indexable page in Google. Hash fragments are ignored by the index since 2015; without this the whole portfolio is one entry.',
      'Built a **dual-cover system** per project — typographic infographic baked procedurally (`tools/gen_covers.py`) as the rest-state cover, cinematic AI image (`tools/install_hover_covers.py`) as the wipe-in hover. Both ship as 1600×900 WebP @ 90% with XMP + EXIF SEO metadata.',
      'Used a **two-repo pattern**: source repo `burak_basci_website` for code, `burak-basci.github.io` for the deployed static site — independent release cycle, no live-site risk during dev.',
    ],
    learnings: <String>[
      'Microsoft\'s DSIG-signed fonts break CanvasKit; OFL metric-compatible alternatives are non-negotiable for Flutter Web.',
      'A complete rewrite became cleaner than incremental refactor after the third upstream-tracking conflict — copying the structural ideas and discarding the original code was faster than untangling them.',
      'A **single global PageTransition overlay** is the only honest way to get consistent cover/uncover transitions across push, pop, replace and intro-redirect. Per-page controllers stack listeners and silently break.',
      'AI image-generation quality is unreliable for **letters** but reliable for **abstract layouts**. Splitting the cover pipeline into "AI renders the atmosphere, Python overlays the typography" gave perfect text on every cover and still let the artwork carry the project.',
      'Per-section animation controllers gated by `VisibilityDetector` lift the perceived premium of the site more than any individual font or layout decision — the scroll-revealed staggers do more work than the prettiest hero image.',
      'A **TechnicalImage** model + a generator-script recipe file made the architecture-diagram section scale to 33 projects without any per-page code. Content stays in one file, the layout reads from it.',
    ],
    translations: const <String, ProjectTranslation>{
      'de': ProjectTranslation(
        title: 'burakbasci.de',
        subtitle: 'Diese Portfolio-Seite — Flutter Web, Material 2, content-driven',
        category: 'WEB / PERSÖNLICH',
        platform: 'Flutter Web',
        technologyUsed: 'Flutter Web · CanvasKit · GitHub Pages · Podman',
        portfolioDescription:
            'Die Seite, die du gerade liest. Flutter Web auf dem '
            'CanvasKit-Renderer, deployed auf GitHub Pages mit Custom-'
            'Domain. Ein kompletter Source-Rewrite — nur lose '
            'inspiriert von David Cobbinas Open-Source-Portfolio-'
            'Template — in einen neuen Widget-Baum (Header / Footer / '
            'Page-Wrapper / Animations-Primitiven), gebaut gegen das '
            'aktuelle stable Flutter, mit einem zentralen '
            '`PageTransition`-Overlay, scroll-getriebenen Device-Frame-'
            'Mockups, einem Dual-Cover-System (typografisch als Main + '
            'cineastisch als Hover), einer KI-Prompt-+-WebP-Install-'
            'Pipeline für Projekt-Cover und einer Architektur-'
            'Illustrations-Sektion. Jede Animation, Schrift, Route, '
            'jeder Prompt und jede Projektseite ist content-driven über '
            '`lib/data/projects.dart`.',
        decisions: <String>[
          'David Cobbinas Upstream als **reine Inspiration** behandelt und dann den gesamten Widget-Baum neu geschrieben — Header / Footer / Page-Wrapper / Animations-Primitiven / Transition-System / Mockup-Gallery / Daten-Layer — gegen ein aktuelles stable Flutter-SDK. Cherry-Picking aus Upstream wurde aufgegeben, sobald die neue Form dem Original nicht mehr ähnelte.',
          'Jede Navigation zentral durch ein einziges **PageTransition-Overlay** gezogen mit einem linksverankerten scaleX-Cover und einem rechtsverankerten Uncover (Original-Wipe-Richtung, aber von einem globalen Controller getrieben). Ein Reentrancy-Guard tötet den Stuck-Black-Panel-Bug, den Per-Page-Listener erzeugten.',
          '**`useMaterial3: false`** durchgesetzt, um Material-2-Ink-Ripples und Elevation zu behalten — M3 brachte visuellen Drift in Top-Nav und Footer, der den Kampf nicht wert war und nach dem niemand gefragt hatte.',
          '**URW Gothic + Carlito + Inter** als Brand-Fonts gewählt (alle OFL), weil Microsofts DSIG-signierte Century Gothic und Calibri CanvasKit brechen — auf die harte Tour entdeckt.',
          '**Flutter 3.41.9 strikt innerhalb von `ghcr.io/cirruslabs/flutter:stable` Podman** ohne Host-Installation gebaut — jeder Build reproduziert auf jeder Maschine, und CI ist nur "derselbe Befehl, woanders".',
          'Auf **`usePathUrlStrategy()`** umgestellt, sodass jede Projekt-URL ihre eigene indexierbare Seite bei Google ist. Hash-Fragmente werden seit 2015 vom Index ignoriert; ohne das wäre das ganze Portfolio ein einziger Eintrag.',
          'Ein **Dual-Cover-System** pro Projekt gebaut — typografische Infografik prozedural gebaken (`tools/gen_covers.py`) als Rest-State-Cover, cineastisches KI-Bild (`tools/install_hover_covers.py`) als Wipe-in-Hover. Beide liefern als 1600×900 WebP @ 90 % mit XMP- + EXIF-SEO-Metadaten.',
          'Ein **Zwei-Repo-Muster** verwendet: Source-Repo `burak_basci_website` für den Code, `burak-basci.github.io` für die deployte statische Seite — unabhängiger Release-Cycle, kein Live-Site-Risiko während der Entwicklung.',
        ],
        learnings: <String>[
          'Microsofts DSIG-signierte Schriften brechen CanvasKit; OFL-metrik-kompatible Alternativen sind für Flutter Web nicht verhandelbar.',
          'Ein kompletter Rewrite wurde nach dem dritten Upstream-Tracking-Konflikt sauberer als ein inkrementelles Refactor — die strukturellen Ideen zu kopieren und den Originalcode zu verwerfen war schneller als sie zu entwirren.',
          'Ein **einziges globales PageTransition-Overlay** ist der einzige ehrliche Weg, konsistente Cover-/Uncover-Transitions über Push, Pop, Replace und Intro-Redirect zu bekommen. Per-Page-Controller stacken Listener und brechen still.',
          'KI-Bildgenerations-Qualität ist bei **Buchstaben** unzuverlässig, aber bei **abstrakten Layouts** zuverlässig. Die Cover-Pipeline in "KI rendert die Atmosphäre, Python überlagert die Typografie" zu splitten ergab perfekten Text auf jedem Cover und ließ die Artwork trotzdem das Projekt tragen.',
          'Per-Sektion-Animations-Controller, gegated durch `VisibilityDetector`, heben das wahrgenommene Premium der Seite stärker als jede einzelne Schrift- oder Layout-Entscheidung — die scroll-revealten Stagger leisten mehr Arbeit als das schönste Hero-Bild.',
          'Ein **TechnicalImage**-Model + eine Generator-Skript-Rezeptdatei machten die Architektur-Diagramm-Sektion auf 33 Projekte skalierbar, ohne irgendeinen Per-Page-Code. Inhalt bleibt in einer Datei, das Layout liest daraus.',
        ],
      ),
    },
  ),
];

/// Subset shown on the home page "selection of recent work" — the top picks.
final List<ProjectItemData> recentWorksHighlights = <ProjectItemData>[
  recentWorks[0], // Volkswagen AI Patent Search
  recentWorks[1], // Hetzner k3s Infrastructure
  recentWorks[2], // PostPilot
  recentWorks[6], // Night-Drive Object Detection
  recentWorks[7], // VR Anxiety Trainer
  recentWorks[8], // Durak Multiplayer
];
