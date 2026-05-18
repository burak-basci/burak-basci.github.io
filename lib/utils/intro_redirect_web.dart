// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'lang.dart';

/// URLs that all mean "the home page". Visiting any of these is *not* a
/// deep link — the user is already where they want to be, so no deferred
/// navigation should be queued after the intro. They're still rewritten
/// to the canonical `/` (or `/de` for German) so the browser bar tells
/// the same story.
const Set<String> _homeAliases = <String>{
  '/',
  '/home',
  '/index',
  '/index.html',
};

bool _isHomeLogicalPath(String logical) => _homeAliases.contains(logical);

/// On a cold web load, if the URL points at a deep route — either path-style
/// (`/projects/foo`, with `PathUrlStrategy`) or legacy hash-style
/// (`/#/projects/foo`) — stash that route and rewrite the URL to `/` so the
/// home page can play its intro before the user lands on the originally
/// requested page. A home-alias URL like `/home` is normalised to `/` but
/// *not* stashed, so the intro plays and stays put.
///
/// Language handling: the `/en` prefix is detected here and applied to
/// [LangController] so the intro and the deferred navigation both render
/// in the right language. German is the default; the URL is rewritten to
/// `/` for German / `/en` for English.
void captureDeepLinkInto(void Function(String?) setter) {
  final String rawPath = html.window.location.pathname ?? '';
  final String rawHash = html.window.location.hash;

  // Pick whichever signal carries a real path. Path comes first because
  // it's the canonical PathUrlStrategy format; the hash fallback is only
  // used when an older hash-style link is being shared.
  String? signal;
  if (rawPath.isNotEmpty) {
    signal = rawPath;
  } else if (rawHash.startsWith('#/') && rawHash.length > 2) {
    signal = rawHash.substring(1);
  }

  // Detect + apply the language, then strip the prefix so the rest of
  // the logic only sees the logical path. No URL signal at all → default
  // to German.
  final AppLang detected =
      signal == null ? AppLang.de : LangController.detect(signal);
  LangController.to.setLang(detected);
  final String? logical =
      signal == null ? null : LangController.stripLangPrefix(signal);

  final String canonicalHome = detected == AppLang.en ? '/en' : '/';

  // Pure home or no signal at all — make sure the URL is the canonical
  // home for the chosen language and bail.
  if (logical == null || _isHomeLogicalPath(logical)) {
    if (rawPath != canonicalHome) {
      html.window.history.replaceState(null, '', canonicalHome);
    }
    return;
  }

  // Deep link — stash the logical route, normalise the URL to the
  // canonical home so the intro plays first. The home page will pick
  // the stashed route back up and navigate to it (the language is
  // already applied, so PageTransition.goTo will re-localise the URL).
  setter(logical);
  html.window.history.replaceState(null, '', canonicalHome);
}
