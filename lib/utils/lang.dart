import 'package:get/get.dart';

/// Supported display languages. `en` is the default / fallback for every
/// translated string. Add a new value here, register it in
/// [LangController.parse] + [LangController.code], and the rest of the
/// app picks it up automatically.
enum AppLang { en, de }

/// Single source of truth for the current display language.
///
/// The value reflects three things at once:
///   1. The URL prefix in the browser address bar
///      (`/de/...` for German, no prefix for English).
///   2. Which translations come back from [Tr.of] and from the
///      `…For(lang)` helpers on [ProjectItemData].
///   3. The text content of every page widget that reads it via
///      `Get.find<LangController>().lang`.
///
/// Persistence is implicit — the URL is the persistence layer. A page
/// refresh, share-link or browser-back all carry the language along.
class LangController extends GetxController {
  static LangController get to => Get.find<LangController>();

  final Rx<AppLang> _lang = AppLang.en.obs;

  AppLang get lang => _lang.value;
  String get code => lang == AppLang.de ? 'de' : 'en';
  bool get isDe => lang == AppLang.de;
  bool get isEn => lang == AppLang.en;

  void setLang(AppLang next) {
    if (_lang.value != next) _lang.value = next;
  }

  /// Convert `'de'` / `'en'` / null into an [AppLang]. Anything other
  /// than German falls back to English.
  static AppLang parse(String? code) =>
      (code == 'de') ? AppLang.de : AppLang.en;

  /// Prepend `/de` to a logical route when in German, leave it as-is in
  /// English. The route argument is a logical path (e.g. `/projects/foo`);
  /// the result is the URL the browser should show.
  String localiseRoute(String logicalRoute) {
    if (lang != AppLang.de) return logicalRoute;
    if (logicalRoute.startsWith('/de')) return logicalRoute;
    return logicalRoute == '/' ? '/de' : '/de$logicalRoute';
  }

  /// Inverse of [localiseRoute] — strip the `/de` prefix from an URL
  /// path so it can be matched against the route table.
  static String stripLangPrefix(String urlPath) {
    if (urlPath == '/de' || urlPath == '/de/') return '/';
    if (urlPath.startsWith('/de/')) return urlPath.substring(3);
    return urlPath;
  }

  /// Detect the language a URL path encodes (without modifying state).
  static AppLang detect(String urlPath) {
    if (urlPath == '/de' || urlPath == '/de/' || urlPath.startsWith('/de/')) {
      return AppLang.de;
    }
    return AppLang.en;
  }
}
