import 'lang.dart';
import 'values/values.dart';

/// Legal texts (Impressum / Datenschutzerklärung) in German and English.
///
/// Plain data, no translation-table indirection: each section is a
/// title + body pair rendered by the same section builder as before.
/// Keep both languages in sync when editing — they state the same facts.
class LegalTexts {
  LegalTexts._();

  static const String _phone = '+49 1590 2640684';
  static const String _email = 'burakbascidev@gmail.com';

  static List<PrivacyPolicyData> impressum(AppLang lang) {
    if (lang == AppLang.de) {
      return <PrivacyPolicyData>[
        PrivacyPolicyData(
          title: 'Angaben gemäß § 5 DDG',
          content: 'Burak Basci\nWitte-Wie 18\n44892 Bochum\nDeutschland',
        ),
        PrivacyPolicyData(
          title: 'Kontakt',
          content: 'Telefon: $_phone\nE-Mail: $_email',
        ),
        PrivacyPolicyData(
          title: 'Umsatzsteuer-ID',
          content: 'Umsatzsteuer-Identifikationsnummer gemäß § 27 a Umsatzsteuergesetz:\nDE370011034',
        ),
        PrivacyPolicyData(
          title: 'Verantwortlich für den Inhalt nach § 18 Abs. 2 MStV',
          content: 'Burak Basci, Anschrift wie oben.',
        ),
      ];
    }
    return <PrivacyPolicyData>[
      PrivacyPolicyData(
        title: 'Information pursuant to § 5 DDG (German Digital Services Act)',
        content: 'Burak Basci\nWitte-Wie 18\n44892 Bochum\nGermany',
      ),
      PrivacyPolicyData(
        title: 'Contact',
        content: 'Phone: $_phone\nEmail: $_email',
      ),
      PrivacyPolicyData(
        title: 'VAT ID',
        content: 'VAT identification number pursuant to § 27 a of the German VAT Act:\nDE370011034',
      ),
      PrivacyPolicyData(
        title: 'Responsible for content pursuant to § 18 (2) MStV',
        content: 'Burak Basci, address as above.',
      ),
    ];
  }

  static List<PrivacyPolicyData> privacy(AppLang lang) {
    if (lang == AppLang.de) {
      return <PrivacyPolicyData>[
        PrivacyPolicyData(
          title: 'Verantwortlicher',
          content: 'Verantwortlich für die Datenverarbeitung auf dieser Website im Sinne der '
              'Datenschutz-Grundverordnung (DSGVO) ist:\n\n'
              'Burak Basci\nWitte-Wie 18\n44892 Bochum\nDeutschland\n'
              'Telefon: $_phone\nE-Mail: $_email',
        ),
        PrivacyPolicyData(
          title: 'Hosting über GitHub Pages',
          content: 'Diese Website wird über GitHub Pages ausgeliefert (GitHub, Inc., USA, ein '
              'Unternehmen der Microsoft-Gruppe). Beim Aufruf der Seite verarbeitet GitHub technisch '
              'notwendige Verbindungsdaten in Server-Logs, insbesondere deine IP-Adresse, Datum und '
              'Uhrzeit, die angeforderte Datei sowie Browser- und Betriebssystemangaben. Ich selbst '
              'habe auf diese Logs keinen Zugriff und erhebe keine eigenen Zugriffsstatistiken.\n\n'
              'Rechtsgrundlage ist Art. 6 Abs. 1 lit. f DSGVO (mein berechtigtes Interesse an einer '
              'sicheren und effizienten Bereitstellung der Website). Dabei kann eine Übermittlung '
              'in die USA stattfinden; GitHub stützt sich dafür nach eigenen Angaben auf das '
              'EU-U.S. Data Privacy Framework bzw. Standardvertragsklauseln.',
        ),
        PrivacyPolicyData(
          title: 'Kontaktformular',
          content: 'Wenn du das Kontaktformular nutzt, werden dein Name, deine E-Mail-Adresse, der '
              'Betreff und deine Nachricht an den Dienst Web3Forms (api.web3forms.com) übertragen, '
              'der die Nachricht per E-Mail an mich weiterleitet. Dabei verarbeitet Web3Forms '
              'technisch bedingt auch deine IP-Adresse; eine Übermittlung in Drittländer kann nicht '
              'ausgeschlossen werden.\n\n'
              'Ich verwende die Angaben ausschließlich, um deine Anfrage zu beantworten. '
              'Rechtsgrundlage ist Art. 6 Abs. 1 lit. b DSGVO (Anbahnung eines Vertrags) bzw. '
              'lit. f DSGVO (Beantwortung allgemeiner Anfragen). Ich lösche die Daten, sobald die '
              'Anfrage erledigt ist und keine gesetzlichen Aufbewahrungspflichten entgegenstehen. '
              'Die Nutzung des Formulars ist freiwillig; du kannst mir auch direkt per E-Mail '
              'schreiben ($_email).',
        ),
        PrivacyPolicyData(
          title: 'Schriften und externe Ressourcen',
          content: 'Alle Schriftarten, Bilder und Skripte dieser Website werden von der Website '
              'selbst ausgeliefert. Es werden keine Google Fonts und keine sonstigen Inhalte von '
              'Drittservern nachgeladen. Die Links zu GitHub, LinkedIn und Pinterest sind einfache '
              'Verweise; Daten werden erst an diese Anbieter übertragen, wenn du einen Link anklickst.',
        ),
        PrivacyPolicyData(
          title: 'Keine Cookies, keine Werbung, keine Konten',
          content: 'Diese Website setzt keine Cookies und verwendet keine Tracking-, Analyse- oder '
              'Werbedienste. Es gibt keine Nutzerkonten und keine Newsletter-Anmeldung. Dein Browser '
              'kann technisch notwendige Zwischenspeicher (Cache) für die Auslieferung der Seite '
              'anlegen.',
        ),
        PrivacyPolicyData(
          title: 'Google-API-Anwendung „OpenClaw“',
          content: '„OpenClaw“ ist eine private Anwendung, mit der ich ausschließlich meine eigenen '
              'Google-Konten (Gmail, Kalender, Drive) für persönliche Automatisierung nutze. Über diese '
              'Anwendung werden keine Daten anderer Personen abgefragt. Über Google-APIs erhaltene Daten '
              'werden nur lokal auf meinen eigenen Rechnern verarbeitet, nicht verkauft, nicht an Dritte '
              'weitergegeben und nicht für Werbung verwendet. Die Nutzung entspricht der Google API '
              'Services User Data Policy einschließlich der Anforderungen zur eingeschränkten Nutzung '
              '(Limited Use). Eine erteilte Berechtigung kann jederzeit unter '
              'myaccount.google.com/permissions widerrufen werden.',
        ),
        PrivacyPolicyData(
          title: 'Deine Rechte',
          content: 'Du hast nach der DSGVO das Recht auf Auskunft (Art. 15), Berichtigung (Art. 16), '
              'Löschung (Art. 17), Einschränkung der Verarbeitung (Art. 18) und Datenübertragbarkeit '
              '(Art. 20) sowie das Recht, der Verarbeitung auf Grundlage berechtigter Interessen zu '
              'widersprechen (Art. 21). Eine erteilte Einwilligung kannst du jederzeit mit Wirkung für '
              'die Zukunft widerrufen. Wende dich dazu an die oben genannte E-Mail-Adresse.',
        ),
        PrivacyPolicyData(
          title: 'Beschwerderecht',
          content: 'Du kannst dich bei einer Datenschutz-Aufsichtsbehörde beschweren. Für mich zuständig '
              'ist die Landesbeauftragte für Datenschutz und Informationsfreiheit '
              'Nordrhein-Westfalen (LDI NRW), Kavalleriestraße 2–4, 40213 Düsseldorf, '
              'www.ldi.nrw.de.',
        ),
        PrivacyPolicyData(
          title: 'Stand',
          content: 'Oktober 2026',
        ),
      ];
    }
    return <PrivacyPolicyData>[
      PrivacyPolicyData(
        title: 'Controller',
        content: 'The controller responsible for data processing on this website under the General '
            'Data Protection Regulation (GDPR) is:\n\n'
            'Burak Basci\nWitte-Wie 18\n44892 Bochum\nGermany\n'
            'Phone: $_phone\nEmail: $_email',
      ),
      PrivacyPolicyData(
        title: 'Hosting via GitHub Pages',
        content: 'This website is served via GitHub Pages (GitHub, Inc., USA, a Microsoft company). '
            'When you open the site, GitHub processes technically necessary connection data in server '
            'logs, in particular your IP address, date and time, the requested file and browser and '
            'operating-system details. I have no access to these logs myself and do not collect any '
            'visitor statistics of my own.\n\n'
            'The legal basis is Art. 6(1)(f) GDPR (my legitimate interest in providing the website '
            'securely and efficiently). A transfer to the USA may take place; according to its own '
            'statements, GitHub relies on the EU-U.S. Data Privacy Framework and standard contractual '
            'clauses for this.',
      ),
      PrivacyPolicyData(
        title: 'Contact form',
        content: 'If you use the contact form, your name, email address, subject and message are '
            'transmitted to the service Web3Forms (api.web3forms.com), which forwards the message to me '
            'by email. For technical reasons Web3Forms also processes your IP address; a transfer to '
            'third countries cannot be ruled out.\n\n'
            'I use the information solely to answer your enquiry. The legal basis is Art. 6(1)(b) GDPR '
            '(steps prior to entering into a contract) or Art. 6(1)(f) GDPR (answering general '
            'enquiries). I delete the data once your enquiry has been dealt with and no statutory '
            'retention duties apply. Using the form is voluntary; you can also write to me directly '
            '($_email).',
      ),
      PrivacyPolicyData(
        title: 'Fonts and external resources',
        content: 'All fonts, images and scripts of this website are delivered by the website itself. '
            'No Google Fonts or other content is loaded from third-party servers. The links to GitHub, '
            'LinkedIn and Pinterest are plain links; data is only sent to these providers once you '
            'click a link.',
      ),
      PrivacyPolicyData(
        title: 'No cookies, no advertising, no accounts',
        content: 'This website sets no cookies and uses no tracking, analytics or advertising services. '
            'There are no user accounts and no newsletter sign-up. Your browser may keep technically '
            'necessary caches to deliver the site.',
      ),
      PrivacyPolicyData(
        title: 'Google API application "OpenClaw"',
        content: '"OpenClaw" is a private application I use exclusively with my own Google accounts '
            '(Gmail, Calendar, Drive) for personal automation. It does not request any data of other '
            'people. Data obtained via Google APIs is processed only locally on my own machines, is not '
            'sold, not shared with third parties and not used for advertising. Its use complies with the '
            'Google API Services User Data Policy, including the Limited Use requirements. Any granted '
            'permission can be revoked at any time at myaccount.google.com/permissions.',
      ),
      PrivacyPolicyData(
        title: 'Your rights',
        content: 'Under the GDPR you have the right of access (Art. 15), rectification (Art. 16), '
            'erasure (Art. 17), restriction of processing (Art. 18) and data portability (Art. 20), as '
            'well as the right to object to processing based on legitimate interests (Art. 21). You '
            'can withdraw any consent at any time with effect for the future. Please contact me at the '
            'email address above.',
      ),
      PrivacyPolicyData(
        title: 'Right to lodge a complaint',
        content: 'You may lodge a complaint with a data protection supervisory authority. The authority '
            'responsible for me is the State Commissioner for Data Protection and Freedom of '
            'Information of North Rhine-Westphalia (LDI NRW), Kavalleriestraße 2–4, 40213 Düsseldorf, '
            'Germany, www.ldi.nrw.de.',
      ),
      PrivacyPolicyData(
        title: 'Last updated',
        content: 'October 2026',
      ),
    ];
  }
}
