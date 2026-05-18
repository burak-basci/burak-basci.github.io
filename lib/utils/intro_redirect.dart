import 'intro_redirect_stub.dart'
    if (dart.library.html) 'intro_redirect_web.dart' as platform;

/// One-shot session state for the cold-load intro animation.
///
/// Two things live here:
///   * the stashed deep-link route (if the user arrived on `/projects/foo`,
///     we rewrite the URL to `/` so the intro can play, then forward them
///     the rest of the way once it's done)
///   * a static flag that flips to `true` the first time the intro
///     finishes, so any later return to the home page (logo click,
///     browser back, top-nav home click, etc.) skips the intro entirely.
///
/// Both pieces of state live for the lifetime of the page — a hard
/// refresh resets them, which is exactly the "intro plays again on
/// refresh" behaviour we want.
class IntroRedirect {
  IntroRedirect._();

  static String? _deferredRoute;
  static bool _hasPlayedIntro = false;

  /// Read the current URL once at app start. If it points at a non-root
  /// route, remember it and rewrite the URL to the home page so the intro
  /// can play. Safe to call on any platform; the stub is a no-op off web.
  static void captureDeepLink() {
    platform.captureDeepLinkInto((String? route) {
      _deferredRoute = route;
    });
  }

  /// Take and clear the stashed route. Returns null if no deep link was
  /// captured at startup or if it has already been consumed.
  static String? consumeDeferred() {
    final String? r = _deferredRoute;
    _deferredRoute = null;
    return r;
  }

  /// `true` once the intro animation has completed in this page session.
  /// The home page reads this in its build to decide between the cinematic
  /// intro and the standard cross-page unveil.
  static bool get hasPlayedIntro => _hasPlayedIntro;

  /// Called by the intro animation's `onLoadingDone` callback the first
  /// (and only) time it finishes.
  static void markIntroPlayed() {
    _hasPlayedIntro = true;
  }
}
