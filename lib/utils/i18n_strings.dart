import 'lang.dart';

/// Tiny i18n lookup helper. The strings table below holds the EN + DE
/// values for every piece of UI chrome on the site (nav, button labels,
/// section headings, intro animation copy, footer text). Project-level
/// content — titles, subtitles, descriptions, decisions, learnings — is
/// translated via [ProjectItemData]'s `translations` map instead, so the
/// data file and the chrome file stay loosely coupled.
///
/// Use:
///
/// ```dart
/// Tr.of('nav.about')               // → "About" (EN) / "Über" (DE)
/// Tr.tIn(AppLang.de, 'btn.back')   // → "ZURÜCK"
/// ```
class Tr {
  Tr._();

  /// Lookup using the current global language.
  static String of(String key, [String? fallback]) =>
      Tr.tIn(LangController.to.lang, key, fallback);

  /// Lookup against an explicit language.
  static String tIn(AppLang lang, String key, [String? fallback]) {
    final entry = _strings[key];
    if (entry == null) return fallback ?? key;
    final code = lang == AppLang.de ? 'de' : 'en';
    return entry[code] ?? entry['en'] ?? fallback ?? key;
  }

  /// Lookup a translation for a top-nav label by its canonical English
  /// form (`Home`, `About`, `Experience`, `Contact`, `Works` — case
  /// insensitive). Returns the input unchanged if nothing matches.
  /// Used so the call sites in `top_navigation_bar.dart` and
  /// `app_drawer.dart` don't have to know about keys.
  static String navLabel(String englishLabel) {
    switch (englishLabel.toUpperCase()) {
      case 'HOME':       return of('nav.home');
      case 'ABOUT':      return of('nav.about');
      case 'EXPERIENCE': return of('nav.experience');
      case 'CONTACT':    return of('nav.contact');
      case 'WORK':
      case 'WORKS':      return of('nav.works');
      default:           return englishLabel;
    }
  }
}

const Map<String, Map<String, String>> _strings = <String, Map<String, String>>{
  // --- Top nav ---------------------------------------------------------
  // Mirror the existing case-style ("Home", "About", …) so the EN nav
  // looks unchanged when no language is selected; the DE versions follow
  // the same sentence-case convention.
  'nav.home':        {'en': 'Home',        'de': 'Start'},
  'nav.about':       {'en': 'About',       'de': 'Über mich'},
  'nav.experience':  {'en': 'Experience',  'de': 'Erfahrung'},
  'nav.contact':     {'en': 'Contact',     'de': 'Kontakt'},
  'nav.works':       {'en': 'Works',       'de': 'Projekte'},

  // --- Home hero -------------------------------------------------------
  'home.hi':                 {'en': 'Hi,',                                 'de': 'Hallo,'},
  'home.dev_intro':          {'en': "I'm Burak.",                          'de': 'ich bin Burak.'},
  'home.dev_title':          {'en': 'A Software Developer \n& Problem Solver.', 'de': 'Software-Entwickler\n& Problemlöser.'},
  'home.dev_desc':           {'en': 'Flutter / Unreal Engine / AI / Blockchain', 'de': 'Flutter / Unreal Engine / AI / Blockchain'},
  'home.see_my_work':        {'en': 'See my work',                          'de': 'Projekte ansehen'},
  'home.crafted':            {'en': 'Crafted with love.',                   'de': 'Mit Liebe gebaut.'},
  'home.intro_name':         {'en': 'BURAK BASCI',                          'de': 'BURAK BASCI'},

  // --- Section headers (on project detail page) -----------------------
  // Numbers ('/01', '/02', …) stay literal — only labels + headings are
  // translated. The labels are rendered through .toUpperCase() at the
  // call site, so the value here is the canonical uppercase form.
  'section.about':              {'en': 'ABOUT',           'de': 'ÜBERBLICK'},
  'section.about_heading':      {'en': 'About this project','de': 'Über dieses Projekt'},
  'section.decisions':          {'en': 'DECISIONS',       'de': 'ENTSCHEIDUNGEN'},
  'section.decisions_heading':  {'en': 'What I chose, and why', 'de': 'Was ich gewählt habe und warum'},
  'section.learnings':          {'en': 'LEARNINGS',       'de': 'ERKENNTNISSE'},
  'section.learnings_heading':  {'en': 'What shipping it taught me', 'de': 'Was die Umsetzung mich gelehrt hat'},
  'section.technical':          {'en': 'TECHNICAL',       'de': 'TECHNIK'},
  'section.technical_heading':  {'en': 'Inside the system','de': 'Hinter den Kulissen'},
  'section.shots':              {'en': 'SHOTS',           'de': 'EINBLICKE'},
  'section.shots_heading':      {'en': 'In the wild',     'de': 'In freier Wildbahn'},

  // --- Button / CTA labels --------------------------------------------
  'btn.view_project':       {'en': 'View Project',   'de': 'Projekt ansehen'},
  'btn.open_live':          {'en': 'OPEN LIVE',      'de': 'LIVE ÖFFNEN'},
  'btn.view_source':        {'en': 'VIEW SOURCE',    'de': 'CODE ANSEHEN'},
  'btn.play_store':         {'en': 'PLAY STORE',     'de': 'PLAY STORE'},
  'btn.back':               {'en': 'BACK',           'de': 'ZURÜCK'},
  'btn.next_project':       {'en': 'NEXT PROJECT',   'de': 'NÄCHSTES PROJEKT'},
  'btn.say_hello':          {'en': 'Say Hello',      'de': 'Hallo sagen'},
  'btn.send_message':       {'en': 'SEND MESSAGE',   'de': 'NACHRICHT SENDEN'},

  // --- Meta panel labels ----------------------------------------------
  'meta.platform':          {'en': 'PLATFORM',        'de': 'PLATTFORM'},
  'meta.category':          {'en': 'CATEGORY',        'de': 'KATEGORIE'},
  'meta.technology':        {'en': 'TECHNOLOGY',      'de': 'TECHNOLOGIE'},
  'meta.status':            {'en': 'STATUS',          'de': 'STATUS'},
  'meta.live':              {'en': 'Live',            'de': 'Live'},
  'meta.archived':          {'en': 'Archived / WIP',  'de': 'Archiviert / In Arbeit'},
  'meta.private':           {'en': 'PRIVATE',         'de': 'PRIVAT'},
  'meta.public':            {'en': 'PUBLIC',          'de': 'ÖFFENTLICH'},

  // --- Footer ----------------------------------------------------------
  'footer.lets_work':       {'en': "Let's work together.",            'de': 'Lass uns zusammenarbeiten.'},
  'footer.available':       {'en': "I'm available for Consultancy & Freelancing.",
                              'de': 'Verfügbar für Beratung & Freelancing.'},
  'footer.copyright':       {'en': '©  2023  Built by  Burak Basci,', 'de': '©  2023  Gebaut von  Burak Basci,'},
  'footer.copyright2':      {'en': '©  2023  Built by  Burak Basci',  'de': '©  2023  Gebaut von  Burak Basci'},
  'footer.based_on':        {'en': ' based on the design of ',         'de': ' nach einem Design von '},
  'footer.built_with':      {'en': 'Built using ',                     'de': 'Gebaut mit '},
  'footer.built_with_love': {'en': ' with ',                           'de': ' mit '},
  'footer.privacy_policy':  {'en': 'Privacy Policy',                   'de': 'Datenschutz'},
  'footer.imprint':         {'en': 'Imprint',                          'de': 'Impressum'},

  // --- Language switcher ----------------------------------------------
  'lang.switch_to_de':      {'en': 'Switch to German',  'de': 'Auf Deutsch wechseln'},
  'lang.switch_to_en':      {'en': 'Switch to English', 'de': 'Auf Englisch wechseln'},

  // --- About page header ----------------------------------------------
  'about.catch_line_1': {
    'en': 'I am a curious individual who loves to understand and solve problems.',
    'de': 'Ich bin ein neugieriger Mensch, der gerne Probleme versteht und löst.',
  },
  'about.catch_line_2': {
    'en': 'I also have a passion for music.',
    'de': 'Außerdem habe ich eine Leidenschaft für Musik.',
  },

  // --- About page sections --------------------------------------------
  'about.story.label':   {'en': 'Story',                       'de': 'Werdegang'},
  'about.story.title':   {'en': 'A little bit about myself',   'de': 'Ein wenig über mich'},
  'about.story.content': {
    'en':
        "I'm pursuing a dual degree in Industrial Engineering and Psychology, with a keen interest in "
            "entrepreneurship, information technology, philosophy, and personal growth. I enjoy learning "
            "new skills and applying them to diverse projects, such as developing a website, a VR "
            "application, a driving robot, a side-scroller game or an AI training data generator. "
            "Outside of academics and work, I find fulfillment in playing the piano, calisthenics, "
            "hiking, juggling, and exploring new topics.\n\n"
            "Professionally, I work as a Technical Product Owner and Platform Engineer with more than "
            "three years of experience delivering production-grade DevSecOps environments and AI-driven "
            "automation. I reduced environment provisioning time by 95% on one project and architected "
            "a sovereign cloud infrastructure for a 700+ unit real estate portfolio. I love owning the "
            "full product lifecycle, from Enterprise Architect modeling all the way to GitOps-based "
            "deployment.\n\n"
            "My dual background in Industrial Engineering and Psychology lets me take a human-centric "
            "approach to platform engineering: bridging deep technical execution (Kubernetes, Terraform, "
            "ArgoCD, FastAPI, RAG) and stakeholder alignment through cognitive usability analysis. I "
            "currently lead cross-functional teams and DevSecOps transformations for multiple clients "
            "across Germany, focusing on Architecture-as-Code and scalable AI integration.",
    'de':
        "Ich absolviere ein duales Studium in Wirtschaftsingenieurwesen und Psychologie und interessiere "
            "mich besonders für Entrepreneurship, Informationstechnologie, Philosophie und persönliche "
            "Entwicklung. Ich lerne gerne neue Fähigkeiten und wende sie in unterschiedlichsten Projekten "
            "an – sei es eine Website, eine VR-Anwendung, ein fahrender Roboter, ein Side-Scroller-Spiel "
            "oder ein Generator für KI-Trainingsdaten. Neben Studium und Beruf finde ich Ausgleich beim "
            "Klavierspielen, Calisthenics, Wandern, Jonglieren und beim Erschließen neuer Themen.\n\n"
            "Beruflich arbeite ich als Technical Product Owner und Platform Engineer mit über drei Jahren "
            "Erfahrung im Aufbau produktionsreifer DevSecOps-Umgebungen und KI-gestützter Automatisierung. "
            "In einem Projekt habe ich die Bereitstellungszeit für Umgebungen um 95 % reduziert und für "
            "ein Immobilienportfolio mit mehr als 700 Einheiten eine souveräne Cloud-Infrastruktur "
            "konzipiert. Ich übernehme gerne Verantwortung für den gesamten Produktlebenszyklus – von der "
            "Modellierung im Enterprise Architect bis zum GitOps-basierten Deployment.\n\n"
            "Mein dualer Hintergrund in Wirtschaftsingenieurwesen und Psychologie ermöglicht mir einen "
            "menschzentrierten Ansatz im Platform Engineering: Ich verbinde tiefe technische Umsetzung "
            "(Kubernetes, Terraform, ArgoCD, FastAPI, RAG) mit Stakeholder-Abstimmung durch kognitive "
            "Usability-Analysen. Aktuell leite ich cross-funktionale Teams und DevSecOps-Transformationen "
            "für mehrere Kunden in ganz Deutschland, mit Fokus auf Architecture-as-Code und skalierbare "
            "KI-Integration.",
  },

  'about.technology.label':   {'en': 'Technology', 'de': 'Technologie'},
  'about.technology.title':   {'en': 'What I use',  'de': 'Womit ich arbeite'},
  'about.technology.content': {
    'en':
        "I use a wide range of tools to take ideas from prototype to production. "
            "On the platform side I lean on Kubernetes, Terraform, ArgoCD and GitLab "
            "CI/CD for reproducible, GitOps-driven infrastructure. For product work "
            "I reach for Flutter, Next.js, Django and FastAPI, with PostgreSQL, "
            "ElasticSearch and vector databases sitting behind them. On the AI side, "
            "I orchestrate LLMs and RAG pipelines, train and evaluate computer-"
            "vision models, and build synthetic-data simulations in Unreal Engine "
            "(C++). The full list of languages, frameworks and tools I have shipped "
            "with over the years is below.",
    'de':
        "Ich nutze ein breites Spektrum an Werkzeugen, um Ideen vom Prototyp in die Produktion zu "
            "bringen. Auf der Plattform-Seite setze ich auf Kubernetes, Terraform, ArgoCD und GitLab "
            "CI/CD für reproduzierbare, GitOps-getriebene Infrastruktur. Für die Produktentwicklung "
            "greife ich zu Flutter, Next.js, Django und FastAPI – darunter PostgreSQL, ElasticSearch "
            "und Vektor-Datenbanken. Im KI-Bereich orchestriere ich LLMs und RAG-Pipelines, trainiere "
            "und evaluiere Computer-Vision-Modelle und baue synthetische Datensimulationen in Unreal "
            "Engine (C++). Die vollständige Liste der Sprachen, Frameworks und Tools, mit denen ich "
            "über die Jahre produktiv geliefert habe, findest du unten.",
  },

  'about.tech.programming_languages': {'en': 'Programming Languages',     'de': 'Programmiersprachen'},
  'about.tech.applications':          {'en': 'Applications & Frameworks', 'de': 'Anwendungen & Frameworks'},
  'about.tech.other_software':        {'en': 'Other Software',            'de': 'Weitere Software'},

  'about.contact.label':  {'en': 'Contact',      'de': 'Kontakt'},
  'about.contact.social': {'en': 'Social Media', 'de': 'Soziale Medien'},
  'about.contact.email':  {'en': 'Email',        'de': 'E-Mail'},

  'about.quote.text': {
    'en': '“I have no special talents. I am only passionately curious.”',
    'de': '„Ich habe keine besondere Begabung, sondern bin nur leidenschaftlich neugierig.“',
  },
  'about.quote.author': {'en': 'Albert Einstein', 'de': 'Albert Einstein'},

  // --- Contact page ---------------------------------------------------
  'contact.get_in_touch': {'en': 'Get in touch.', 'de': 'Sag Hallo.'},
  'contact.message': {
    'en': 'Hey there, got a project, job offer or consulting work for me? Feel free to contact me.',
    'de': 'Hallo, hast du ein Projekt, ein Jobangebot oder eine Beratungsanfrage für mich? '
        'Melde dich gerne.',
  },
  'contact.your_name':         {'en': 'Your Name',                                   'de': 'Dein Name'},
  'contact.name_error':        {'en': '* Please enter your name',                    'de': '* Bitte gib deinen Namen ein'},
  'contact.email_label':       {'en': 'Email',                                       'de': 'E-Mail'},
  'contact.email_error':       {'en': '* Please enter a valid email',                'de': '* Bitte gib eine gültige E-Mail-Adresse ein'},
  'contact.subject':           {'en': 'Subject',                                     'de': 'Betreff'},
  'contact.subject_error':     {'en': '* Please tell me what this message is about', 'de': '* Bitte teile mir mit, worum es geht'},
  'contact.message_label':     {'en': 'Message',                                     'de': 'Nachricht'},
  'contact.message_error':     {'en': '* Please enter something to send this form',  'de': '* Bitte schreibe eine Nachricht, um das Formular abzusenden'},
  'contact.send_message':      {'en': 'Send Message',                                'de': 'Nachricht senden'},
  'contact.banner.empty': {
    'en': 'Please fill in the required fields before sending.',
    'de': 'Bitte fülle die erforderlichen Felder aus, bevor du das Formular absendest.',
  },
  'contact.banner.success': {
    'en': "Message sent — I'll get back to you shortly.",
    'de': 'Nachricht gesendet — ich melde mich in Kürze bei dir.',
  },
  'contact.banner.error': {
    'en': "Sorry, the message couldn't be sent. Please try again in a moment.",
    'de': 'Leider konnte die Nachricht nicht gesendet werden. Bitte versuche es gleich erneut.',
  },
  'contact.button.sent':    {'en': 'Message sent',  'de': 'Gesendet'},
  'contact.button.retry':   {'en': 'Try again',     'de': 'Erneut versuchen'},

  // --- Experience page ------------------------------------------------
  'experience.heading':      {'en': 'Experience',          'de': 'Erfahrung'},
  'experience.professional': {'en': 'Professional Career', 'de': 'Berufliche Laufbahn'},
  'experience.academic':     {'en': 'Academic Career',     'de': 'Akademische Laufbahn'},

  // Freelance DevSecOps (workData index 0)
  'experience.5.time':  {'en': 'Oct 2024 - Present',                          'de': 'Okt. 2024 – Heute'},
  'experience.5.title': {'en': 'Freelance DevSecOps & AI Automation Engineer','de': 'Freiberuflicher DevSecOps- & KI-Automatisierungs-Engineer'},
  'experience.5.subtitle': {
    'en': 'Self-Employed, Bochum, Germany. I architect production-grade Kubernetes infrastructure, '
        'GitOps workflows and LLM-powered automation for clients across Germany.',
    'de': 'Selbstständig, Bochum, Deutschland. Ich konzipiere produktionsreife Kubernetes-Infrastruktur, '
        'GitOps-Workflows und LLM-gestützte Automatisierung für Kunden in ganz Deutschland.',
  },
  'experience.5.bullet_1': {
    'en': 'I designed and deployed production-grade Kubernetes clusters (Hetzner Cloud) using Terraform '
        '(IaC) and ArgoCD (GitOps), achieving 100% environment reproducibility and reducing '
        'provisioning lead time from 4 days to 45 minutes (95% improvement).',
    'de': 'Ich habe produktionsreife Kubernetes-Cluster (Hetzner Cloud) mit Terraform (IaC) und ArgoCD '
        '(GitOps) entworfen und ausgerollt – mit 100 % Reproduzierbarkeit der Umgebungen und einer '
        'Reduktion der Bereitstellungszeit von 4 Tagen auf 45 Minuten (95 % Verbesserung).',
  },
  'experience.5.bullet_2': {
    'en': 'I implemented automated GitLab CI/CD pipelines and GitOps workflows; established a full-stack '
        'Prometheus/Grafana monitoring solution that reduced Mean Time to Detection by 40% through '
        'proactive alerting and log aggregation.',
    'de': 'Ich habe automatisierte GitLab-CI/CD-Pipelines und GitOps-Workflows umgesetzt sowie eine '
        'Full-Stack-Monitoring-Lösung mit Prometheus und Grafana etabliert, die die Mean Time to '
        'Detection durch proaktives Alerting und Log-Aggregation um 40 % gesenkt hat.',
  },
  'experience.5.bullet_3': {
    'en': 'I architected a sovereign, Linux-based infrastructure for a 700+ unit real estate portfolio; '
        'migrated 15+ legacy services to self-hosted open-source alternatives, cutting annual OPEX by '
        '20.000 € in licensing fees.',
    'de': 'Ich habe eine souveräne, Linux-basierte Infrastruktur für ein Immobilienportfolio mit über '
        '700 Einheiten konzipiert und mehr als 15 Legacy-Dienste auf selbst gehostete Open-Source-'
        'Alternativen migriert – mit einer jährlichen OPEX-Einsparung von 20.000 € an Lizenzkosten.',
  },
  'experience.5.bullet_4': {
    'en': 'I developed an LLM-powered automation service (FastAPI, RAG) for intent-based email '
        'processing; increased throughput by 80% while maintaining a 95% accuracy rate, saving an '
        'estimated 8 man-hours per week in manual triage.',
    'de': 'Ich habe einen LLM-gestützten Automatisierungsdienst (FastAPI, RAG) für intent-basierte '
        'E-Mail-Verarbeitung entwickelt – mit 80 % höherem Durchsatz bei gleichbleibender Genauigkeit '
        'von 95 % und einer Ersparnis von rund 8 Personenstunden pro Woche im manuellen Triage-Prozess.',
  },
  'experience.5.bullet_5': {
    'en': 'I engineered a Hardened Container Environment using rootless Podman/Docker, implementing '
        'CIS-compliant security policies and automated off-site backup strategies, ensuring 99.6% '
        'uptime and full GDPR compliance for sensitive PII data.',
    'de': 'Ich habe eine gehärtete Container-Umgebung auf Basis von rootless Podman/Docker aufgebaut, '
        'CIS-konforme Security-Policies sowie automatisierte Off-Site-Backups umgesetzt und damit '
        '99,6 % Verfügbarkeit und volle DSGVO-Konformität für sensible personenbezogene Daten sichergestellt.',
  },
  'experience.5.bullet_6': {
    'en': 'I led and mentored a cross-functional team of 9 engineering students through the full SDLC, '
        'implementing Agile (Scrum) methodologies that increased sprint velocity by 25% within the '
        'first two quarters.',
    'de': 'Ich habe ein cross-funktionales Team aus 9 Engineering-Studierenden durch den gesamten SDLC '
        'geführt und gementort und agile Methoden (Scrum) eingeführt, die die Sprint-Velocity '
        'innerhalb der ersten zwei Quartale um 25 % gesteigert haben.',
  },

  // VW AI Patent Search (workData index 1)
  'experience.4.time': {'en': 'Dec 2024 - Aug 2025', 'de': 'Dez. 2024 – Aug. 2025'},
  'experience.4.title': {
    'en': 'Working Student: Full Stack Developer & Solution Architect - AI Patent Search Tool',
    'de': 'Werkstudent: Full-Stack-Entwickler & Solution Architect – KI-Patentrecherche-Tool',
  },
  'experience.4.subtitle': {
    'en': 'Volkswagen Infotainment GmbH, Bochum, Germany. I architected and delivered a production '
        'AI patent search tool now scaled across 3 departments and 50+ internal users.',
    'de': 'Volkswagen Infotainment GmbH, Bochum, Deutschland. Ich habe ein produktives KI-'
        'Patentrecherche-Tool konzipiert und ausgeliefert, das inzwischen über 3 Abteilungen und mehr '
        'als 50 interne Anwender skaliert.',
  },
  'experience.4.bullet_1': {
    'en': 'I architected and independently delivered a production-grade AI patent search tool '
        '(Flutter, Django, ElasticSearch, Docker) currently scaled across 3 departments, serving 50+ '
        'internal employees.',
    'de': 'Ich habe ein produktionsreifes KI-Patentrecherche-Tool (Flutter, Django, ElasticSearch, '
        'Docker) eigenverantwortlich konzipiert und ausgeliefert; es wird aktuell in 3 Abteilungen '
        'eingesetzt und bedient mehr als 50 interne Mitarbeitende.',
  },
  'experience.4.bullet_2': {
    'en': 'I utilized Enterprise Architect to design and document the entire system landscape (UML/SysML), '
        'mapping 100% of infrastructure-to-code dependencies and ensuring seamless DevSecOps handovers '
        'and security audits.',
    'de': 'Mit Enterprise Architect habe ich die gesamte Systemlandschaft (UML/SysML) entworfen und '
        'dokumentiert, sämtliche Abhängigkeiten zwischen Infrastruktur und Code abgebildet und damit '
        'reibungslose DevSecOps-Übergaben sowie Security-Audits ermöglicht.',
  },
  'experience.4.bullet_3': {
    'en': 'I developed a hybrid semantic search engine (Keyword + Vector Embeddings) with A/B-tested '
        'ranking logic, increasing search precision by 25% and reducing researcher time-to-discovery '
        'by 40%.',
    'de': 'Ich habe eine hybride semantische Suchmaschine (Keyword + Vector Embeddings) mit A/B-'
        'getestetem Ranking entwickelt – mit 25 % höherer Suchpräzision und 40 % verkürzter Time-to-'
        'Discovery für die Recherchierenden.',
  },
  'experience.4.bullet_4': {
    'en': 'I conducted comprehensive psychological usability audits and user interviews; authored a '
        'strategic User Pain-Point & UX Roadmap report that identified 4+ critical cognitive load '
        'barriers for future iterations.',
    'de': 'Ich habe umfassende psychologische Usability-Audits und Nutzerinterviews durchgeführt und '
        'einen strategischen Bericht zu User Pain Points und UX-Roadmap verfasst, der mehr als 4 '
        'kritische kognitive Belastungspunkte für künftige Iterationen identifiziert hat.',
  },

  // Web3 Environmental Platform (workData index 2)
  'experience.3.time':  {'en': 'Mar 2023 - Mar 2024', 'de': 'Mär. 2023 – Mär. 2024'},
  'experience.3.title': {
    'en': 'Technical Lead - Web3 Environmental Platform (Utopia-Community GbR)',
    'de': 'Technical Lead – Web3-Plattform für Umweltschutz (Utopia-Community GbR)',
  },
  'experience.3.subtitle': {
    'en': 'I led the creation of the Utopia Community web and app platform, which focuses on environmental '
        'protection and charity.',
    'de': 'Ich habe den Aufbau der Web- und App-Plattform der Utopia Community geleitet, deren Fokus auf '
        'Umweltschutz und gemeinnütziger Arbeit liegt.',
  },
  'experience.3.bullet_1': {
    'en': 'This involved designing a unique crypto token on the Polygon Blockchain.',
    'de': 'Dazu gehörte der Entwurf eines eigenen Krypto-Tokens auf der Polygon-Blockchain.',
  },
  'experience.3.bullet_2': {
    'en': 'I analyzed requirements, designed interfaces, and established an efficient production process.',
    'de': 'Ich habe Anforderungen analysiert, Schnittstellen entworfen und einen effizienten Produktionsprozess etabliert.',
  },
  'experience.3.bullet_3': {
    'en': "Additionally, I crafted the crypto token's smart contract using Solidity and developed the "
        'prototype app platform using Flutter and Dart.',
    'de': 'Zusätzlich habe ich den Smart Contract des Krypto-Tokens in Solidity umgesetzt und die '
        'Prototyp-App-Plattform mit Flutter und Dart entwickelt.',
  },
  'experience.3.bullet_4': {
    'en': 'I showcased the prototype at the KUER.NRW Green Entrepreneurship Fair in Gelsenkirchen. ',
    'de': 'Ich habe den Prototyp auf der KUER.NRW Green-Entrepreneurship-Messe in Gelsenkirchen präsentiert. ',
  },

  // Robotics Research (workData index 3)
  'experience.2.time':  {'en': 'Dec 2022 - Dec 2023', 'de': 'Dez. 2022 – Dez. 2023'},
  'experience.2.title': {
    'en': 'Student Research Assistant - Institute for Robotics Research',
    'de': 'Studentische Hilfskraft – Institut für Roboterforschung',
  },
  'experience.2.subtitle': {
    'en': 'At the Technical University of Dortmund, I supported research at the Institute for Robotics in '
        'the field of glare-free high beams.',
    'de': 'An der Technischen Universität Dortmund habe ich am Institut für Roboterforschung im Bereich '
        'blendfreies Fernlicht mitgewirkt.',
  },
  'experience.2.bullet_1': {
    'en': 'There, I successfully developed a control system for a physics-simulated car to track a spline '
        'path in Unreal Engine using Blueprints.',
    'de': 'Dort habe ich erfolgreich ein Steuerungssystem für ein physikalisch simuliertes Fahrzeug '
        'entwickelt, das in Unreal Engine über Blueprints einer Spline-Bahn folgt.',
  },
  'experience.2.bullet_2': {
    'en': 'I independently created and optimized a C++ script for a simulated car camera, capturing and '
        'calculating 2D bounding boxes for pedestrians and cars and saving them as training data for '
        'artificial intelligences.',
    'de': 'Eigenständig habe ich ein C++-Skript für eine simulierte Fahrzeugkamera erstellt und optimiert, '
        'das 2D-Bounding-Boxes für Fußgänger und Fahrzeuge berechnet und als Trainingsdaten für KIs '
        'abspeichert.',
  },
  'experience.2.bullet_3': {
    'en': 'I also designed a variation of that script which captures segmented data from the simulation and '
        'saves it as training data.',
    'de': 'Außerdem habe ich eine Variante dieses Skripts entwickelt, die segmentierte Daten aus der '
        'Simulation extrahiert und als Trainingsdaten speichert.',
  },

  // Multiplayer Card Game (workData index 4)
  'experience.game.time': {'en': 'Nov 2019 - May 2022', 'de': 'Nov. 2019 – Mai 2022'},
  'experience.game.title': {
    'en': 'Co-Founder & Lead Developer - Multiplayer Card Game',
    'de': 'Mitgründer & Lead Developer – Multiplayer-Kartenspiel',
  },
  'experience.game.subtitle': {
    'en': 'Gaming Startup, Dortmund, Germany. Cross-platform card game with custom rendering engine '
        'and a scalable serverless backend.',
    'de': 'Gaming-Startup, Dortmund, Deutschland. Plattformübergreifendes Kartenspiel mit eigener '
        'Rendering-Engine und skalierbarem Serverless-Backend.',
  },
  'experience.game.bullet_1': {
    'en': 'I engineered a high-performance cross-platform card game engine by extending the Flutter '
        'framework with custom rendering logic, achieving 60 FPS across Android, iOS, Web, Windows, '
        'macOS and Linux.',
    'de': 'Ich habe eine performante, plattformübergreifende Kartenspiel-Engine entwickelt, indem ich '
        'das Flutter-Framework um eigene Rendering-Logik erweitert habe – mit 60 FPS auf Android, iOS, '
        'Web, Windows, macOS und Linux.',
  },
  'experience.game.bullet_2': {
    'en': 'I architected a scalable serverless backend using Firebase Cloud Functions and NoSQL '
        '(Firestore), managing real-time game states and persistent user data for a potential global '
        'player base.',
    'de': 'Ich habe ein skalierbares Serverless-Backend mit Firebase Cloud Functions und NoSQL '
        '(Firestore) konzipiert, das Echtzeit-Spielzustände und persistente Nutzerdaten für eine '
        'potenziell globale Spielerbasis verwaltet.',
  },

  // IMA Schelling internship (workData index 5)
  'experience.1.time':  {'en': 'Sept 2019 - Oct 2019', 'de': 'Sep. 2019 – Okt. 2019'},
  'experience.1.title': {
    'en': 'Intern in Mechanical & Electrical Engineering - IMA Schelling GmbH',
    'de': 'Praktikant in Maschinen- und Elektrotechnik – IMA Schelling GmbH',
  },
  'experience.1.subtitle': {
    'en': 'During my 8-week basic internship at IMA Schelling GmbH '
        'in the fields of mechanical engineering and electrical engineering, I had the opportunity to '
        'work on various tasks.',
    'de': 'Während meines achtwöchigen Grundpraktikums bei der IMA Schelling GmbH in den Bereichen '
        'Maschinenbau und Elektrotechnik hatte ich die Gelegenheit, an verschiedenen Aufgaben zu arbeiten.',
  },
  'experience.1.bullet_1': {
    'en': 'This included the development and optimization of electrical control systems using TwinCAT.',
    'de': 'Dazu gehörte die Entwicklung und Optimierung elektrischer Steuerungen mit TwinCAT.',
  },
  'experience.1.bullet_2': {
    'en': 'I was involved in the assembly, installation, testing, inspection, and maintenance of '
        'pneumatic systems.',
    'de': 'Ich war an Montage, Installation, Prüfung, Inspektion und Wartung pneumatischer Systeme beteiligt.',
  },
  'experience.1.bullet_3': {
    'en': 'Additionally, I gained practical experience in manufacturing various metallic components through '
        'different production methods, utilizing hand tools as well as lathes and milling machines.',
    'de': 'Zusätzlich habe ich praktische Erfahrung in der Fertigung verschiedener metallischer Bauteile '
        'mit unterschiedlichen Produktionsverfahren gesammelt – mit Handwerkzeugen sowie an Dreh- und '
        'Fräsmaschinen.',
  },

  // Academic — IU International University (academicData index 0)
  'academic.2.time':     {'en': 'Since 2020',                  'de': 'Seit 2020'},
  'academic.2.title':    {'en': 'IU International University (Distance Study)',
                          'de': 'IU Internationale Hochschule (Fernstudium)'},
  'academic.2.subtitle': {'en': 'Degree Program: Psychology (B.Sc.)',
                          'de': 'Studiengang: Psychologie (B.Sc.)'},

  // Academic — TU Dortmund (academicData index 1)
  'academic.1.time':  {'en': 'Since Oct 2018', 'de': 'Seit Okt. 2018'},
  'academic.1.title': {'en': 'Technical University in Dortmund',
                       'de': 'Technische Universität Dortmund'},
  'academic.1.subtitle': {
    'en': 'Degree Program: Industrial Engineering (B.Sc.)\n'
        'Profile: Management of Electrical Systems',
    'de': 'Studiengang: Wirtschaftsingenieurwesen (B.Sc.)\n'
        'Profil: Management elektrischer Systeme',
  },
  'academic.1.bullet_1': {'en': '3D-Printing and Laser Woodcutter Workshop',
                          'de': 'Workshop zu 3D-Druck und Laser-Holzschneider'},
  'academic.1.bullet_2': {'en': 'Programming of a Micro Controller ',
                          'de': 'Programmierung eines Mikrocontrollers '},
  'academic.1.bullet_3': {'en': 'Analyzing and Modifying Signals via an Oscilloscope',
                          'de': 'Analyse und Modifikation von Signalen mit einem Oszilloskop'},
  'academic.1.bullet_4': {'en': 'Programming a Turtlebot with ROS in C++',
                          'de': 'Programmierung eines Turtlebots mit ROS in C++'},
  'academic.1.bullet_5': {
    'en': 'I wrote a scientific paper on the application and '
        'optimization of object detection at night using Deep Learning (YOLOv8) in a simulated urban '
        'environment from the perspective of a moving car.',
    'de': 'Ich habe eine wissenschaftliche Arbeit zur Anwendung und Optimierung von Objekterkennung bei '
        'Nacht mittels Deep Learning (YOLOv8) in einer simulierten urbanen Umgebung aus der Perspektive '
        'eines fahrenden Autos verfasst.',
  },
  'academic.1.bullet_6': {
    'en': "Currently I am engaged in my Bachelor's Thesis, "
        'titled:\n'
        '"Evaluation of the Influence of Lighting and Training Parameters on Object Detection by '
        'Artificial Neural Networks in Virtual Night Drives.".',
    'de': 'Aktuell arbeite ich an meiner Bachelorarbeit mit dem Titel:\n'
        '„Evaluation des Einflusses von Beleuchtungs- und Trainingsparametern auf die Objekterkennung '
        'durch künstliche neuronale Netze bei virtuellen Nachtfahrten.".',
  },
};
