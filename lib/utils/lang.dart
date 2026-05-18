import 'package:get/get.dart';

/// Supported display languages. `en` is the default / fallback for every
/// translated string. Add a new value here, register it in
/// [LangController.parse] + [LangController.code], and the rest of the
/// app picks it up automatically.
enum AppLang { en, de }

/// Single source of truth for the current display language.
///
/// German is the default (no URL prefix). English routes are prefixed
/// with `/en`. This was inverted from the original `/de`-prefix scheme
/// because the site's primary audience is German-speaking.
///
/// The value reflects three things at once:
///   1. The URL prefix in the browser address bar
///      (`/en/...` for English, no prefix for German).
///   2. Which translations come back from [Tr.of] and from the
///      `…For(lang)` helpers on [ProjectItemData].
///   3. The text content of every page widget that reads it via
///      `Get.find<LangController>().lang`.
///
/// Persistence is implicit — the URL is the persistence layer. A page
/// refresh, share-link or browser-back all carry the language along.
class LangController extends GetxController {
  static LangController get to => Get.find<LangController>();

  final Rx<AppLang> _lang = AppLang.de.obs;

  AppLang get lang => _lang.value;
  String get code => lang == AppLang.de ? 'de' : 'en';
  bool get isDe => lang == AppLang.de;
  bool get isEn => lang == AppLang.en;

  void setLang(AppLang next) {
    if (_lang.value != next) _lang.value = next;
  }

  /// Convert `'de'` / `'en'` / null into an [AppLang]. Anything other
  /// than English falls back to German (the default).
  static AppLang parse(String? code) =>
      (code == 'en') ? AppLang.en : AppLang.de;

  /// Prepend `/en` to a logical route when in English, leave it as-is in
  /// German. The route argument is a logical path (e.g. `/projects/foo`);
  /// the result is the URL the browser should show.
  String localiseRoute(String logicalRoute) {
    if (lang != AppLang.en) return logicalRoute;
    if (logicalRoute.startsWith('/en')) return logicalRoute;
    return logicalRoute == '/' ? '/en' : '/en$logicalRoute';
  }

  /// Inverse of [localiseRoute] — strip the `/en` prefix from an URL
  /// path so it can be matched against the route table.
  static String stripLangPrefix(String urlPath) {
    if (urlPath == '/en' || urlPath == '/en/') return '/';
    if (urlPath.startsWith('/en/')) return urlPath.substring(3);
    return urlPath;
  }

  /// Detect the language a URL path encodes (without modifying state).
  /// Anything not under `/en` is treated as German.
  static AppLang detect(String urlPath) {
    if (urlPath == '/en' || urlPath == '/en/' || urlPath.startsWith('/en/')) {
      return AppLang.en;
    }
    return AppLang.de;
  }
}
