import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:burak_basci_website/widgets/text/self_positioning_widget.dart';
import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../utils/adaptive_layout.dart';
import '../../../utils/i18n_strings.dart';
import '../../../utils/values/values.dart';
import '../../utils/values/spaces.dart';
import '../../widgets/buttons/animated_button.dart';
import '../../widgets/helper/custom_spacer.dart';
import '../../widgets/scaffolding/footer/bottom_part_footer.dart';
import '../../widgets/scaffolding/page_wrapper.dart';
import '../../widgets/text/form_field/custom_form_field.dart';
import '../../widgets/text/slide_box_transitioning_text.dart';

/// Send status used to drive the submit button visual state.
enum _SendStatus { idle, sending, success, error }

class ContactPage extends StatefulWidget {
  static const String contactPageRoute = StringConst.CONTACT_PAGE;
  const ContactPage({
    super.key,
  });

  @override
  ContactPageState createState() => ContactPageState();
}

class ContactPageState extends State<ContactPage> with TickerProviderStateMixin {
  // ---------------------------------------------------------------------------
  // Web3Forms (server-side SMTP relay).
  //
  // The site is a static GitHub-Pages-hosted Flutter web bundle, so there is
  // no backend to hold SMTP creds. We POST the form to Web3Forms; SMTP is
  // configured in the Web3Forms dashboard and delivers to the destination
  // email set there. The access_key below is a public per-form identifier
  // (NOT a secret — it only authorizes POSTing to the configured destination
  // mailbox).
  //
  // TODO(user): paste your Web3Forms access_key from
  // https://web3forms.com/ -> "Create Access Key" (uses your destination
  // email, no signup). The destination mailbox is set in the Web3Forms
  // dashboard against that key — keep SMTP creds out of this repo.
  static const String _web3formsAccessKey = 'ffa4e132-56c6-4016-a094-276f4602645b';
  // Animation-probe harness, compiled in ONLY with
  // `--dart-define=ANIM_PROBE=true` (local test builds). It reroutes
  // the form POST to a same-origin stub (no real email is sent),
  // auto-fills + auto-submits the form shortly after load, and runs
  // the plane clock at half speed — so a headless browser can verify
  // the fly-off frame by frame. Deploy builds never set the define,
  // so all of this folds away to the production constants.
  static const bool _kAnimProbe = bool.fromEnvironment('ANIM_PROBE');

  /// How long the celebration fly-off lasts.
  ///
  /// Sized so the plane is off the right edge as the clock runs out.
  /// The previous 3000 ms was tuned against a path that cleared the
  /// viewport at ~78% — the remaining 660 ms were spent animating an
  /// invisible plane while the "Danke." reveal, which waits for the
  /// flight to complete, sat there doing nothing.
  static const int _kPlaneFlightMs = 2400;
  // Probe-only flight duration. Stretching the clock (e.g. 30000 for a
  // 10x slow-motion flight) lets a screenshot loop land on an exact
  // normalized t with negligible timing error, so every phase of the
  // path can be inspected frame by frame.
  static const int _kAnimProbeFlightMs =
      int.fromEnvironment('ANIM_PROBE_MS', defaultValue: 6000);
  // Probe-only delay before the auto-submit fires, so the verifier has
  // time to scroll the submit button to a realistic on-screen position
  // first (unscrolled, it sits below the fold at 1080p — nothing like
  // what a visitor who just filled the form is looking at).
  static const int _kAnimProbeDelayMs =
      int.fromEnvironment('ANIM_PROBE_DELAY_MS', defaultValue: 2000);

  /// Stretches every choreography beat by the same factor the probe
  /// stretches the plane clock, so a slow-motion capture shows the
  /// real relative timing between the fly-off, the form's cascade
  /// exit and the success-card swap — not a 10x-slow plane over a
  /// form that vanished in the first instant.
  static Duration _beat(int ms) => Duration(
        milliseconds: _kAnimProbe
            ? (ms * _kAnimProbeFlightMs / _kPlaneFlightMs).round()
            : ms,
      );
  static const String _web3formsEndpoint = _kAnimProbe
      ? '/__anim_probe_submit'
      : 'https://api.web3forms.com/submit';
  // ---------------------------------------------------------------------------

  late AnimationController _controller;
  // Drives the success-card headline + line + body reveal. Held
  // separately so we can fire it once the celebration paper-plane has
  // fully exited the viewport — the "Danke." letter reveal must NOT
  // start until the plane is gone (user spec).
  late AnimationController _successCardController;
  // Drives the cascade exit animation of the form fields — each
  // _FormField slot reads its own slice of this controller (staggered
  // by index) to fade + slide upward as it leaves. Starts at 0
  // (everything visible), animates to 1 (everything gone).
  late AnimationController _formExitController;
  // Drives the celebration paper-plane fly-off.
  //
  // The plane lives in an [OverlayEntry] above the entire app, so it
  // can fly past every ancestor clip (Scrollbar, SingleChildScrollView,
  // PageWrapper) and exit the viewport's right edge cleanly. The
  // entry is inserted on launch, removed on completion.
  //
  // Timeline: 0.00 = at-rest on the button, 1.00 = fully off-screen
  // past the top-right corner. The flight itself is the user-drawn
  // sketch path — glide, double loop-the-loop, tangential exit —
  // see [_PaperPlaneFlyOff] for the full choreography.
  late AnimationController _planeController;
  _SendStatus _status = _SendStatus.idle;
  String? _bannerMessage;
  Color? _bannerColor;
  Timer? _statusResetTimer;
  Timer? _successCardSwapTimer;
  Timer? _formExitTimer;
  Timer? _planeLaunchTimer;
  // Tracks whether the celebration paper-plane is currently in
  // flight. While true, the submit button's send-icon is hidden
  // (Opacity 0 on the [AnimatedButton.iconOpacity]) so the entity in
  // flight reads as the button's own icon detaching. Reset on each
  // new send attempt and on dispose.
  bool _planeInFlight = false;
  // GlobalKey on the submit button's inner Icon widget. Used to
  // resolve the icon's pixel-perfect RenderBox position when the
  // celebration plane is about to launch, so its origin sits exactly
  // where the user just clicked (and not on empty space).
  final GlobalKey _buttonIconKey = GlobalKey();
  // The plane's OverlayEntry handle. Inserted at launch time, removed
  // when the flight completes. Tracked here so [dispose] can clean
  // it up if the widget is torn down mid-flight.
  OverlayEntry? _planeOverlayEntry;
  // Flipped to true once the cascade-exit completes. While false, the
  // form column is rendered (and may be playing its exit animation if
  // [_formExitController.value] > 0). While true, the success card is
  // visible — both share the same Stack so the parent's height never
  // changes (zero layout shift on the footer below).
  bool _showSuccessCard = false;
  // Bumped on each successful send so the button's celebratory pulse
  // re-fires (flutter_animate's `target` only re-plays when the key
  // changes).
  int _successPulseKey = 0;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // Auto-validation stays disabled at all times. Validation happens
  // only on explicit submit (`_formKey.currentState.validate()`) and on
  // blur (via the FocusNode listener inside [CustomTextFormField]).
  // Turning it onUserInteraction after the first submit caused the
  // green-valid fill to flicker on/off every keystroke, which read as
  // the field "wiggling" — see _sendEmail comment below.
  static const AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    // flutter_animate adopts an external controller and sets its
    // duration from the longest effect on first build; setting an
    // explicit duration here makes [.forward(from: 0)] safe even on
    // first invocation (the swap can fire before the first frame
    // has measured the chain).
    _successCardController = AnimationController(
      vsync: this,
      // Long enough to cover the letter-by-letter headline reveal
      // (~45ms per char + tail), the underline draw, and the body
      // fade-in.
      duration: const Duration(milliseconds: 2600),
    );
    _formExitController = AnimationController(
      vsync: this,
      // 5 staggered slots × 80ms stagger + 280ms per slot ≈ 680ms total.
      duration: const Duration(milliseconds: 680),
    );
    // Plane controller is just a clock that drives a lookup into the
    // pre-baked trajectory (see [_PaperPlaneFlyOff]); its t∈[0,1]
    // samples the recorded frames so motion replays deterministically
    // every flight. 2400 ms splits roughly 630 ms take-off roll /
    // 1220 ms loop / 550 ms accelerating exit — the split falls out of
    // the path's arc length and the speed schedule, not from hand-cut
    // time slices. Under the probe harness the clock is stretched so
    // timed screenshots can catch every phase of the path.
    _planeController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: _kAnimProbe ? _kAnimProbeFlightMs : _kPlaneFlightMs,
      ),
    );
    _planeController.addStatusListener((status) {
      // Once the plane has fully exited the viewport, remove the
      // OverlayEntry and gate-open the success-card letter reveal.
      // The headline letters wait for the plane to be gone — that's
      // the user-spec'd gating.
      if (status == AnimationStatus.completed && mounted) {
        _planeOverlayEntry?.remove();
        _planeOverlayEntry = null;
        setState(() {
          _planeInFlight = false;
        });
        _successCardController.forward(from: 0);
      }
    });
    if (_kAnimProbe) {
      // Probe builds submit the form on their own so the headless
      // verifier never has to poke text into a canvas-rendered form.
      Timer(const Duration(milliseconds: _kAnimProbeDelayMs), () {
        if (!mounted) return;
        _nameController.text = 'Anim Probe';
        _emailController.text = 'probe@example.com';
        _subjectController.text = 'Paper-plane probe';
        _messageController.text = 'Automated fly-off verification.';
        _sendEmail();
      });
    }
    super.initState();
  }

  /// Resolves the submit button's send-icon center in viewport-global
  /// (screen) coordinates. Returns null if the icon's render box
  /// isn't ready yet (defensive — by the time this runs the layout
  /// has long since settled).
  ///
  /// Global coords are what we need for the OverlayEntry: the Overlay
  /// renders against the root's coordinate space which matches the
  /// viewport, so positioning the plane at globals from
  /// [RenderBox.localToGlobal] places it exactly on top of the
  /// button's icon at the moment of launch.
  Offset? _resolveButtonIconGlobal() {
    final RenderObject? iconRO =
        _buttonIconKey.currentContext?.findRenderObject();
    if (iconRO is! RenderBox) return null;
    if (!iconRO.hasSize) return null;
    return iconRO.localToGlobal(iconRO.size.center(Offset.zero));
  }

  @override
  void dispose() {
    _statusResetTimer?.cancel();
    _successCardSwapTimer?.cancel();
    _formExitTimer?.cancel();
    _planeLaunchTimer?.cancel();
    // Tear down the plane overlay if the page is disposed mid-flight
    // (e.g. user navigates away during the celebration).
    _planeOverlayEntry?.remove();
    _planeOverlayEntry = null;
    _controller.dispose();
    _successCardController.dispose();
    _formExitController.dispose();
    _planeController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '*';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '*';
    }
    if (!GetUtils.isEmail(value.trim())) {
      return Tr.of('contact.email_error');
    }
    return null;
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _emailController.clear();
    _subjectController.clear();
    _messageController.clear();
  }

  Future<void> _sendEmail() async {
    // Trigger every validator once. `validate()` works regardless of
    // [AutovalidateMode] — it returns false if any field is invalid and
    // each field's validator schedules its own error-label setState via
    // the post-frame callback inside [CustomTextFormField]. We do NOT
    // flip on AutovalidateMode here: per-keystroke re-validation caused
    // the green-valid fill to toggle on/off as the user typed (every
    // keystroke briefly cleared _currentError then the validator's
    // post-frame restored it), which read as the whole field wiggling.
    // Blur-driven re-validation in [CustomTextFormField] still gives
    // the user feedback after they finish editing a field.
    final bool isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      _statusResetTimer?.cancel();
      setState(() {
        _status = _SendStatus.error;
        _bannerMessage = Tr.of('contact.banner.empty');
        _bannerColor = CustomColors.errorRed;
      });
      return;
    }

    setState(() {
      _status = _SendStatus.sending;
      _bannerMessage = null;
      // Defensive resets on any re-attempt — keeps the button icon
      // visible (in case a previous celebration left state behind).
      _planeInFlight = false;
    });
    // Belt-and-braces: tear down any lingering overlay from a
    // previous run before starting a new attempt.
    _planeOverlayEntry?.remove();
    _planeOverlayEntry = null;

    try {
      final response = await http.post(
        Uri.parse(_web3formsEndpoint),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'access_key': _web3formsAccessKey,
          // Email subject header. Web3Forms also uses this verbatim so
          // the inbox preview line reads as the visitor wrote it.
          'subject': _subjectController.text.trim(),
          // "From" display name on the delivered mail. Kept generic
          // (the inbox subject + body already identify the form), so
          // every contact-form message lines up under the same "From"
          // in the inbox view.
          'from_name': 'burakbasci.de — Kontaktformular',
          // Each field below becomes its own labeled row in the email
          // body. Keeping the canonical Web3Forms field names (`name`,
          // `email`, `message`) so the labels read cleanly and the
          // `message` row is just the visitor's text — the previous
          // "Name (email) sent you a message…" preamble duplicated info
          // already shown on its own rows.
          //
          // `subject` above is treated specially by Web3Forms — it is
          // only used as the email-header subject line and does NOT
          // show up as a row in the body. To surface the visitor's
          // subject inside the body too, pass it again under an
          // unknown key. Web3Forms renders unknown top-level keys
          // verbatim as labelled rows; `Subject` keeps the body
          // labels uniformly English (Name / Email / Subject / Message)
          // regardless of the UI language the visitor used.
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'Subject': _subjectController.text.trim(),
          'message': _messageController.text.trim(),
          'botcheck': '',
        }),
      );

      bool ok = false;
      String? remoteMessage;
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map) {
          ok = decoded['success'] == true;
          remoteMessage = decoded['message']?.toString();
        }
      } catch (_) {
        // Fall back to status code check.
      }
      ok = ok || response.statusCode == 200;

      if (ok) {
        _resetForm();
        setState(() {
          _status = _SendStatus.success;
          // The card itself surfaces the success message inline; we
          // drop the banner here so the plane fly-off + the "Danke."
          // card are the only "you did it" cues.
          _bannerMessage = null;
          _bannerColor = CustomColors.lightGreen;
          _successPulseKey++;
        });
        // Sketch-path paper-plane choreography (round 6 — the user
        // drew the trajectory: glide, loop spiraling into a bigger
        // loop, tangential exit up-right, exponential growth). The
        // path is pre-baked in _PaperPlaneFlyOff; the controller's
        // t∈[0,1] samples it.
        //   t=0     POST returned success.
        //   t=300   Plane controller starts (2800 ms total).
        //   t=400   Form cascade-exit starts.
        //   t=1080  Cascade exit done.
        //   t≈3100  Plane controller completes → success card reveals.
        _successCardSwapTimer?.cancel();
        _formExitTimer?.cancel();
        _planeLaunchTimer?.cancel();
        // t=400: form cascade exit begins.
        _successCardSwapTimer = Timer(_beat(400), () {
          if (!mounted) return;
          _formExitController.forward(from: 0);
        });
        // t=300: plane launches (wind-up). Slightly EARLIER than the
        // cascade so the wind-up reads clearly while the button is
        // still solid.
        _planeLaunchTimer = Timer(_beat(300), () {
          if (!mounted) return;
          // Resolve the button-icon's global position right before
          // launch — positions are stable here (the button hasn't
          // started fading yet). Bail rather than spawn the plane
          // at (0,0) if the render box is unexpectedly gone.
          final Offset? origin = _resolveButtonIconGlobal();
          if (origin == null) return;
          // Capture viewport size now so the fly-off knows where the
          // right edge is. The geometry is stable for the duration
          // of the flight even if the user resizes mid-animation.
          final Size viewport = MediaQuery.of(context).size;
          final OverlayEntry entry = OverlayEntry(
            builder: (_) => _PaperPlaneFlyOff(
              controller: _planeController,
              origin: origin,
              viewportSize: viewport,
            ),
          );
          _planeOverlayEntry = entry;
          Overlay.of(context).insert(entry);
          setState(() {
            _planeInFlight = true;
          });
          _planeController.forward(from: 0);
        });
        // t=1080: cascade exit done (400 + 680). Swap the form for
        // the success card STRUCTURALLY — but do NOT trigger the
        // letter reveal. That waits until the plane controller's
        // status listener fires on completion.
        _formExitTimer = Timer(_beat(1080), () {
          if (!mounted) return;
          setState(() {
            _showSuccessCard = true;
          });
        });
      } else {
        setState(() {
          _status = _SendStatus.error;
          _bannerMessage = remoteMessage?.isNotEmpty == true
              ? remoteMessage!
              : Tr.of('contact.banner.error');
          _bannerColor = CustomColors.errorRed;
        });
      }
    } catch (error) {
      if (kDebugMode) {
        print('contact form send failed: $error');
      }
      setState(() {
        _status = _SendStatus.error;
        _bannerMessage = Tr.of('contact.banner.error');
        _bannerColor = CustomColors.errorRed;
      });
    }
  }

  String _buttonTitle() {
    switch (_status) {
      case _SendStatus.error:
        return Tr.of('contact.button.retry').toUpperCase();
      case _SendStatus.success:
      case _SendStatus.sending:
      case _SendStatus.idle:
        // Hold the send-message label through `success` too — the
        // celebration is the paper-plane lifting off (via Overlay);
        // we deliberately do NOT morph the button copy to
        // "Gesendet" / "Message sent". The button is fading away
        // behind the cascade-exit and the visible reward is the
        // plane itself + the "Danke." card that follows.
        return Tr.of('contact.send_message').toUpperCase();
    }
  }

  Color _buttonColor() {
    switch (_status) {
      case _SendStatus.success:
        // Reuse the green used elsewhere on the page for "valid" outlines.
        return CustomColors.lightGreen.computeLuminance() > 0.6
            ? CustomColors.black
            : CustomColors.lightGreen;
      case _SendStatus.error:
        return CustomColors.errorRed;
      case _SendStatus.sending:
      case _SendStatus.idle:
        return CustomColors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      selectedRoute: ContactPage.contactPageRoute,
      selectedPageName: StringConst.CONTACT,
      navigationBarAnimationController: _controller,
      onLoadingAnimationDone: () {
        // Cover/uncover transition is the entry animation; snap content
        // controllers straight to their final state.
        _controller.value = 1;
      },
      // SingleChildScrollView keeps maxScrollExtent stable across the
      // whole page — ListView lazily lays out children which made the
      // Scrollbar thumb resize as new sections scrolled into view.
      child: SingleChildScrollView(
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        // Full-bleed content. The scrollbar's right-edge dead zone is
        // handled per-tile (see project_item.dart).
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
          LayoutBuilder(builder: (context, constraints) {
            final double contentAreaWidth = responsiveSize(
              mobile: Get.width * 0.8,
              desktop: Get.width * 0.6,
            ); //takes 60% of screen

            final double buttonWidth = responsiveSize(
              mobile: contentAreaWidth * 0.6,
              desktop: contentAreaWidth * 0.25,
            );
            final EdgeInsetsGeometry padding = EdgeInsets.only(
              left: responsiveSize(
                mobile: Get.width * 0.10,
                desktop: Get.width * 0.15,
              ),
              right: responsiveSize(
                mobile: Get.width * 0.10,
                desktop: Get.width * 0.25,
              ),
              top: responsiveSize(
                mobile: Get.height * 0.24,
                desktop: Get.height * 0.28,
              ),
            );

            return Padding(
              padding: padding,
              child: Form(
                key: _formKey,
                autovalidateMode: _autovalidateMode,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    AnimatedSlideBoxTransitionText(
                      controller: _controller,
                      width: contentAreaWidth,
                      text: Tr.of('contact.get_in_touch'),
                      textStyle: Get.textTheme.displayMedium?.copyWith(
                        fontFamily: StringConst.VISUELT_PRO,
                        color: CustomColors.black,
                        fontSize: responsiveSize(
                          mobile: 40,
                          desktop: 60,
                        ),
                      ),
                    ),
                    const CustomSpacer(heightFactor: 0.05),
                    AnimatedSlideBoxTransitionText(
                      controller: _controller,
                      width: contentAreaWidth,
                      text: Tr.of('contact.message'),
                      textStyle: Get.textTheme.bodyLarge?.copyWith(
                        fontFamily: StringConst.INTER,
                        color: CustomColors.grey700,
                        height: 2.0,
                        fontWeight: FontWeight.w300,
                        fontSize: responsiveSize(
                          mobile: Sizes.TEXT_SIZE_16,
                          desktop: Sizes.TEXT_SIZE_18,
                        ),
                      ),
                    ),
                    const CustomSpacer(heightFactor: 0.06),
                    SelfPositioningWidget(
                      controller: _controller,
                      delay: const Duration(milliseconds: 800),
                      // Stack-based swap area. The form fields are the
                      // ALWAYS-present size-determining child — even
                      // when the success card is visible the form is
                      // still in the tree (offstage + IgnorePointer),
                      // so the Stack's intrinsic height stays pinned
                      // to the form's natural height. Result: the
                      // footer below this widget never moves during
                      // or after the send → swap → celebration
                      // sequence. The success card overlays on top
                      // and is offstage until the cascade exit
                      // completes.
                      //
                      // The celebration paper-plane is NOT a child of
                      // this swap area — it lives in an [OverlayEntry]
                      // above the entire app so it can exit the
                      // viewport's right edge cleanly.
                      child: _ContactSwapArea(
                        showSuccessCard: _showSuccessCard,
                        formFields: _FormFields(
                          key: const ValueKey('contact-form-fields'),
                          status: _status,
                          bannerMessage: _bannerMessage,
                          bannerColor: _bannerColor,
                          successPulseKey: _successPulseKey,
                          buttonWidth: buttonWidth,
                          buttonTitle: _buttonTitle(),
                          buttonColor: _buttonColor(),
                          nameController: _nameController,
                          emailController: _emailController,
                          subjectController: _subjectController,
                          messageController: _messageController,
                          validateRequired: _validateRequired,
                          validateEmail: _validateEmail,
                          onPressed: _sendEmail,
                          exitController: _formExitController,
                          buttonIconKey: _buttonIconKey,
                          // Hide the button's own send-icon while the
                          // plane is in flight — the overlay-plane IS
                          // the button's icon detaching.
                          buttonIconOpacity: _planeInFlight ? 0.0 : 1.0,
                        ),
                        successCard: _SuccessCard(
                          key: const ValueKey('contact-success-card'),
                          controller: _successCardController,
                          width: contentAreaWidth,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const CustomSpacer(heightFactor: 0.22),
          const BottomPartFooter(),
        ],
        ),
      ),
    );
  }
}

/// The original contact-form column, lifted into its own widget so the
/// swap area above can overlay it with the success card. Each field is
/// wrapped in a [_CascadeExitSlot] so the cascade-exit animation (each
/// field fades + slides up with a per-slot stagger) plays before the
/// success card takes over.
class _FormFields extends StatelessWidget {
  const _FormFields({
    super.key,
    required this.status,
    required this.bannerMessage,
    required this.bannerColor,
    required this.successPulseKey,
    required this.buttonWidth,
    required this.buttonTitle,
    required this.buttonColor,
    required this.nameController,
    required this.emailController,
    required this.subjectController,
    required this.messageController,
    required this.validateRequired,
    required this.validateEmail,
    required this.onPressed,
    required this.exitController,
    required this.buttonIconKey,
    required this.buttonIconOpacity,
  });

  final _SendStatus status;
  final String? bannerMessage;
  final Color? bannerColor;
  final int successPulseKey;
  final double buttonWidth;
  final String buttonTitle;
  final Color buttonColor;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController subjectController;
  final TextEditingController messageController;
  final String? Function(String?) validateRequired;
  final String? Function(String?) validateEmail;
  final VoidCallback onPressed;

  /// 0 = all visible, 1 = all gone. Each [_CascadeExitSlot] reads its
  /// own [slotIndex]-staggered slice of this controller.
  final AnimationController exitController;

  /// GlobalKey attached to the submit button's inner [Icon] widget so
  /// the celebration plane can read its on-screen position the moment
  /// it launches.
  final GlobalKey buttonIconKey;

  /// Opacity multiplier applied to the submit button's send-icon.
  /// Driven to 0 by the parent the instant the plane launches so the
  /// detaching icon and the in-flight plane are never both visible.
  final double buttonIconOpacity;

  @override
  Widget build(BuildContext context) {
    final bool isSuccess = status == _SendStatus.success;
    // Banner (when present) takes slot 0. Otherwise slot 0 is the name
    // field. We always pass increasing indices so the cascade reads
    // top-to-bottom as a wave.
    int slot = 0;
    final List<Widget> children = <Widget>[];
    if (bannerMessage != null) {
      children.add(_CascadeExitSlot(
        controller: exitController,
        slotIndex: slot++,
        child: _StatusBanner(
          message: bannerMessage!,
          color: bannerColor ?? CustomColors.black,
          isSuccess: isSuccess,
        ),
      ));
      children.add(const SpaceH20());
    }
    children.add(_CascadeExitSlot(
      controller: exitController,
      slotIndex: slot++,
      child: CustomTextFormField(
        labelText: Tr.of('contact.your_name'),
        controller: nameController,
        errorText: Tr.of('contact.name_error'),
        validator: validateRequired,
      ),
    ));
    children.add(const SpaceH20());
    children.add(_CascadeExitSlot(
      controller: exitController,
      slotIndex: slot++,
      child: CustomTextFormField(
        labelText: Tr.of('contact.email_label'),
        controller: emailController,
        errorText: Tr.of('contact.email_error'),
        validator: validateEmail,
      ),
    ));
    children.add(const SpaceH20());
    children.add(_CascadeExitSlot(
      controller: exitController,
      slotIndex: slot++,
      child: CustomTextFormField(
        labelText: Tr.of('contact.subject'),
        controller: subjectController,
        errorText: Tr.of('contact.subject_error'),
        validator: validateRequired,
      ),
    ));
    children.add(const SpaceH20());
    children.add(_CascadeExitSlot(
      controller: exitController,
      slotIndex: slot++,
      child: CustomTextFormField(
        labelText: Tr.of('contact.message_label'),
        controller: messageController,
        errorText: Tr.of('contact.message_error'),
        textInputType: TextInputType.multiline,
        maxLines: 10,
        validator: validateRequired,
      ),
    ));
    children.add(const SpaceH20());
    children.add(_CascadeExitSlot(
      controller: exitController,
      slotIndex: slot++,
      child: Align(
        alignment: Alignment.topRight,
        // A short scale pulse on the success transition — 1.0 →
        // 1.06 → 1.0 over 260ms — gives a tactile "Sent!" micro-
        // reward as the plane wind-up begins. Keyed off
        // [successPulseKey] so each successful send re-fires it.
        child: Animate(
          key: ValueKey('contact-button-pulse-$successPulseKey'),
          effects: isSuccess
              ? const [
                  ScaleEffect(
                    begin: Offset(1, 1),
                    end: Offset(1.06, 1.06),
                    duration: Duration(milliseconds: 130),
                    curve: Curves.easeOut,
                  ),
                  ScaleEffect(
                    begin: Offset(1.06, 1.06),
                    end: Offset(1, 1),
                    duration: Duration(milliseconds: 130),
                    delay: Duration(milliseconds: 130),
                    curve: Curves.easeIn,
                  ),
                ]
              : const <Effect>[],
          child: AnimatedButton(
            height: Sizes.HEIGHT_56,
            width: buttonWidth,
            isLoading: status == _SendStatus.sending,
            title: buttonTitle,
            backgroundColor: buttonColor,
            // Keep the paper-plane glyph through the success state —
            // the celebration is the plane LIFTING OFF the button
            // via the OverlayEntry, so morphing to a check would
            // either flash the wrong icon for an instant or read as
            // "two different glyphs". The error state still gets the
            // refresh icon since the plane never launches on errors.
            icon: status == _SendStatus.error ? Icons.refresh : Icons.send,
            iconKey: buttonIconKey,
            iconOpacity: buttonIconOpacity,
            onPressed: status == _SendStatus.sending ? null : onPressed,
          ),
        ),
      ),
    ));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

/// Animates a single form-field slot during the cascade-exit phase.
///
/// Maps a global 0-to-1 [controller] value to this slot's own 0-to-1
/// progress using a per-slot delay (80ms × index, normalised against
/// the controller's total duration) and a 280ms-wide window. The slot
/// fades out and slides upward (~16px) over its window with
/// [Curves.easeInCubic]. When idle (controller at 0) the slot is
/// fully opaque at its natural position — no impact on first paint or
/// the error/banner path.
class _CascadeExitSlot extends StatelessWidget {
  const _CascadeExitSlot({
    required this.controller,
    required this.slotIndex,
    required this.child,
  });

  final AnimationController controller;
  final int slotIndex;
  final Widget child;

  // Per-slot stagger and window. Kept on the high side of the 60-90ms
  // range so the wave reads clearly even with 5 slots.
  static const double _staggerMs = 80;
  static const double _windowMs = 280;
  static const double _slideUpPx = 16;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final double totalMs =
            controller.duration?.inMilliseconds.toDouble() ?? 1.0;
        final double startMs = _staggerMs * slotIndex;
        final double endMs = startMs + _windowMs;
        final double t = controller.value * totalMs;
        double progress = ((t - startMs) / (endMs - startMs)).clamp(0.0, 1.0);
        // easeInCubic — accelerates as the field leaves, matching the
        // "this field is gone now" feel rather than a soft drift.
        progress = progress * progress * progress;
        final double opacity = 1.0 - progress;
        final double dy = -_slideUpPx * progress;
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, dy),
            child: IgnorePointer(
              ignoring: progress > 0.01,
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}

/// Stack-based swap container that pins its height to the form's
/// natural height and overlays the success card on top.
///
/// The form is always in the tree (so layout never re-measures), but
/// gets [Opacity(0)] + [IgnorePointer] once the cascade-exit completes
/// and the success card takes over. The success card mirrors that —
/// invisible + non-interactive until [showSuccessCard] flips true.
///
/// Result: the parent column's height is whatever the form needs from
/// first paint onward. The footer below this widget never moves
/// during or after a successful send.
///
/// The celebration paper-plane is NOT a child of this widget anymore
/// — it renders inside an [OverlayEntry] above the entire app (see
/// [_PaperPlaneFlyOff]) so it can fly past every ancestor clip
/// (Scrollbar, ScrollView) and exit the viewport's right edge.
class _ContactSwapArea extends StatelessWidget {
  const _ContactSwapArea({
    required this.showSuccessCard,
    required this.formFields,
    required this.successCard,
  });

  final bool showSuccessCard;
  final Widget formFields;
  final Widget successCard;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topLeft,
      clipBehavior: Clip.none,
      children: <Widget>[
        // Form is the size-determining child. It stays in the tree
        // even after [showSuccessCard] flips so the Stack keeps its
        // form-sized height (zero layout shift).
        IgnorePointer(
          ignoring: showSuccessCard,
          // Once the cascade exit is at 1.0 and the success card is
          // visible, hide the form completely so it can't bleed
          // through (each slot is already at opacity 0, but this also
          // belt-and-braces against any sub-pixel rounding).
          child: Opacity(
            opacity: showSuccessCard ? 0 : 1,
            child: formFields,
          ),
        ),
        // Success card overlays the form, anchored to the same
        // top-left as the form. NOT wrapped in Positioned.fill so
        // it doesn't get forced to expand to the form's full height
        // — the card sizes itself to its own (smaller) content. Only
        // mounted once [showSuccessCard] flips. The card's headline
        // + underline + body each fade/slide in via the
        // [successCardController] (chained delays inside _SuccessCard).
        if (showSuccessCard) successCard,
      ],
    );
  }
}

/// Success state shown in place of the form once Web3Forms has
/// confirmed delivery. Layered celebration composition:
///   - Headline ("Danke." / "Thanks.") reveals letter-by-letter at
///     ~45ms/char — a quietly satisfying typewriter feel that
///     rewards the visitor without going into confetti territory.
///   - Thin horizontal line draws left-to-right under the headline.
///   - Body line fades + slides in just after the line lands.
///
/// The celebration paper-plane (see [_PaperPlaneFlyOff]) is NOT
/// mounted inside this card — it lives in an [OverlayEntry] above
/// the entire app so it can fly past every ancestor clip and exit
/// the viewport's right edge. The plane's flight-completion is what
/// gates this card's headline letter reveal:
/// [_successCardController.forward] is only called once the
/// OverlayEntry has been removed, so the "Danke." letter reveal
/// begins after the plane is fully gone.
class _SuccessCard extends StatelessWidget {
  const _SuccessCard({
    super.key,
    required this.controller,
    required this.width,
  });

  final AnimationController controller;
  final double width;

  @override
  Widget build(BuildContext context) {
    final double headlineFontSize = responsiveSize(
      mobile: 56,
      desktop: 96,
    );
    final double bodyFontSize = responsiveSize(
      mobile: Sizes.TEXT_SIZE_16,
      desktop: Sizes.TEXT_SIZE_18,
    );
    final TextStyle headlineStyle = Get.textTheme.displayLarge!.copyWith(
      fontFamily: StringConst.VISUELT_PRO,
      color: CustomColors.black,
      fontSize: headlineFontSize,
      height: 1.1,
    );
    // Single Column — sizes itself to the headline + underline + body
    // content (MainAxisSize.min).
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _LetterByLetterReveal(
          controller: controller,
          text: Tr.of('contact.success.headline'),
          style: headlineStyle,
          width: width,
          // Stagger per character — fast enough to feel snappy on
          // a 6-letter headline like "Danke." (≈270ms total) but
          // slow enough to read as deliberate.
          perCharMs: 45,
          startDelayMs: 120,
        ),
        const SizedBox(height: 32),
        // Thin underline drawing across — draws from left after the
        // headline finishes.
        Container(
          height: 1.5,
          width: responsiveSize(
            mobile: width * 0.5,
            desktop: width * 0.35,
          ),
          color: CustomColors.black,
        )
            .animate(controller: controller, autoPlay: false)
            .scaleX(
              begin: 0,
              end: 1,
              alignment: Alignment.centerLeft,
              duration: const Duration(milliseconds: 700),
              curve: Curves.fastOutSlowIn,
              delay: const Duration(milliseconds: 700),
            ),
        const SizedBox(height: 24),
        // Body line — fades in after the underline draws.
        Text(
          Tr.of('contact.success.body'),
          style: Get.textTheme.bodyLarge?.copyWith(
            fontFamily: StringConst.INTER,
            color: CustomColors.grey700,
            height: 1.7,
            fontWeight: FontWeight.w300,
            fontSize: bodyFontSize,
          ),
        )
            .animate(controller: controller, autoPlay: false)
            .fadeIn(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 1100),
              curve: Curves.easeOut,
            )
            .slideY(
              begin: 0.15,
              end: 0,
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 1100),
              curve: Curves.fastOutSlowIn,
            ),
      ],
    );
  }
}

/// Reveals a string of text character-by-character driven by a
/// shared [controller]. Each character fades + slides upward over a
/// short window starting at `startDelayMs + perCharMs * index`.
/// While the controller is at 0, every character is invisible
/// (opacity 0) so there's no flash-of-untransformed-text when the
/// success card mounts.
class _LetterByLetterReveal extends StatelessWidget {
  const _LetterByLetterReveal({
    required this.controller,
    required this.text,
    required this.style,
    required this.width,
    required this.perCharMs,
    required this.startDelayMs,
  });

  final AnimationController controller;
  final String text;
  final TextStyle style;
  final double width;
  final double perCharMs;
  final double startDelayMs;

  static const double _windowMs = 380;

  @override
  Widget build(BuildContext context) {
    // RichText so the layout flows naturally (no per-char measuring
    // / positioning needed — each character is its own InlineSpan
    // wrapped in a WidgetSpan with its own opacity).
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final double totalMs =
            controller.duration?.inMilliseconds.toDouble() ?? 1.0;
        final double t = controller.value * totalMs;
        final List<InlineSpan> spans = <InlineSpan>[];
        for (int i = 0; i < text.length; i++) {
          final String ch = text[i];
          final double startMs = startDelayMs + perCharMs * i;
          double progress =
              ((t - startMs) / _windowMs).clamp(0.0, 1.0);
          // easeOutCubic
          progress = 1 - math.pow(1 - progress, 3).toDouble();
          final double opacity = progress;
          final double dy = (1 - progress) * 12;
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: Opacity(
                opacity: opacity,
                child: Transform.translate(
                  offset: Offset(0, dy),
                  child: Text(ch, style: style),
                ),
              ),
            ),
          );
        }
        return SizedBox(
          width: width,
          child: Text.rich(
            TextSpan(children: spans),
            style: style,
          ),
        );
      },
    );
  }
}

/// One sample of the pre-computed paper-plane trajectory.
///
/// Rotation is stored, not derived. It comes from the path's analytic
/// tangent and is UNWRAPPED — it winds past -2pi through the loop
/// rather than jumping at the +pi/-pi seam — so the flight replays
/// identically at any frame rate and the nose can never lag, snap or
/// spin the wrong way round.
class _PlaneFrame {
  const _PlaneFrame({
    required this.t,
    required this.pos,
    required this.rotation,
    required this.scale,
  });
  final double t; // normalized flight time
  final Offset pos; // viewport-global position
  final double rotation; // radians, unwrapped, 0 = nose right
  final double scale;
}

/// The celebration paper-plane fly-off.
///
/// Renders inside an [OverlayEntry] above the entire app so it can fly
/// past every ancestor clip (Scrollbar, SingleChildScrollView,
/// PageWrapper) and exit the viewport's right edge cleanly. The widget
/// paints into a [Positioned.fill] [IgnorePointer] inside the overlay
/// and re-positions a small icon glyph each frame off [controller]'s
/// value.
///
/// CHOREOGRAPHY — the shape is the one the owner drew: a rightward
/// take-off roll off the button, a counterclockwise loop-the-loop that
/// grows as it turns, then a nearly flat exit to the right, the plane
/// growing the whole way out. It is baked into frames once at launch
/// (see [_buildTrajectory]), which is also where the shape is fitted
/// to the room the viewport actually has beside and above the button.
///
/// ROTATION comes from the path's own analytic tangent, baked and
/// unwrapped — not from differencing positions and filtering the
/// result. The loop therefore turns the nose exactly once, in step
/// with the flight, at any frame rate.
///
/// VISIBILITY: nothing is painted in a fixed colour. The glyph is a
/// [ClipPath] over a [BackdropFilter] that inverts whatever is behind
/// it, so it reads white over the black submit button and black over
/// the page — see [_InvertingPaperPlane].
class _PaperPlaneFlyOff extends StatefulWidget {
  const _PaperPlaneFlyOff({
    required this.controller,
    required this.origin,
    required this.viewportSize,
  });

  final AnimationController controller;

  /// Launch point in viewport-global (screen) coordinates — the
  /// submit button's send-icon center at the moment of launch.
  /// Resolved by [ContactPageState._resolveButtonIconGlobal] before
  /// the OverlayEntry is inserted.
  final Offset origin;

  /// The viewport's size at launch time — used to know how far past
  /// the right edge the plane needs to travel to fully exit.
  final Size viewportSize;

  @override
  State<_PaperPlaneFlyOff> createState() => _PaperPlaneFlyOffState();
}

class _PaperPlaneFlyOffState extends State<_PaperPlaneFlyOff> {
  // Match the submit button's icon size exactly (Sizes.ICON_SIZE_16,
  // 16px) so the entity that lifts off reads as the same glyph the
  // visitor just clicked.
  static const double _glyphSize = Sizes.ICON_SIZE_16;

  // ------------------- Flight path (round 10) ------------------------
  //
  // The shape is the owner's sketch, unchanged: a rightward take-off
  // roll, a counterclockwise loop-the-loop that grows as it turns and
  // is BOTTOM-ANCHORED so every pass comes back to the runway's
  // altitude, then a nearly flat departure to the right, growing the
  // whole way.
  //
  // What changed is how the shape is turned into motion. Rounds 6-9
  // gave each phase its own time slice and its own easing, which made
  // the joins lie:
  //
  //   * the roll's sideways travel started at easeInCubic (derivative
  //     zero) while a 12 px sag started at full speed, so the FIRST
  //     thing the plane did was fall — straight down, at 90 deg nose
  //     down, snapping there from the button icon's 0 deg the instant
  //     it detached;
  //   * the roll ended at 734 px/s and the loop began at 124 px/s, a
  //     6x slam-on-the-brakes inside one frame;
  //   * rotation was recovered from finite-difference velocity and run
  //     through a stateful low-pass filter applied per BUILD, so the
  //     nose lagged its own flight path by an amount that depended on
  //     the frame rate.
  //
  // Now there is one curve and one clock. The path is measured in arc
  // length and swept by a single smooth speed schedule, so speed is
  // continuous across every join by construction; rotation is the
  // path's analytic tangent, baked and unwrapped, so it never lags and
  // never snaps. The plane leaves the level runway pointing exactly
  // where the button's icon pointed: 0 deg, dead level, moving right.

  // Take-off roll: dead level. Any vertical component here is what
  // read as "it falls down at the start", and a level roll also means
  // the launch heading is exactly the button icon's heading.
  static const double _runwayLength = 200.0; // px, clamped to fit

  // The loop's radius grows from entry to exit; the centre rides
  // upward with it so the bottom tangent point stays on the runway
  // line and the plane never sinks below the button.
  static const double _loopEntryRadius = 74.0;
  static const double _loopExitRadius = 176.0;

  // Departure angle above the horizon — the owner's "nearly flat"
  // exit to the right, and the amount of sweep past a full turn.
  static const double _exitClimbAngle = 0.14; // ~8 deg
  static const double _loopSweep = 2 * math.pi + _exitClimbAngle;

  // One global speed schedule: v(t) = v0 * e^(ct), the simplest curve
  // that is smooth, strictly increasing and has no seams to mismatch.
  // The ratio is end speed over launch speed; it also sets how the
  // flight time divides between roll, loop and exit (~26/51/23 %).
  static const double _speedRatio = 5.0;

  // Growth: 12x of the 16 px glyph as it leaves the viewport.
  static const double _endScale = 12.0;
  static const double _scaleSharpness = 2.2;

  // Samples per flight. The table is indexed by normalized time and
  // interpolated, so this only has to be fine enough that linear
  // interpolation of a smooth curve is invisible.
  static const int _frameCount = 240;

  // Arc-length resolution of the loop's lookup table.
  static const int _loopSamples = 512;

  /// Pre-computed trajectory frames. Built once in [initState].
  late final List<_PlaneFrame> _trajectory;

  @override
  void initState() {
    super.initState();
    _trajectory = _buildTrajectory();
  }

  /// The loop, in coordinates local to its entry point (which is the
  /// end of the runway), at unit geometry scale.
  ///
  /// Bottom-anchored growing circle: at swept angle theta the radius
  /// is r = r0*e^(k*theta) and the centre sits r directly above the
  /// entry, so the curve leaves the entry horizontally and returns to
  /// the entry's altitude at every full turn.
  static Offset _loopPoint(double theta, double k) {
    final double r = _loopEntryRadius * math.exp(k * theta);
    return Offset(r * math.sin(theta), -r * (1 - math.cos(theta)));
  }

  /// Tangent of [_loopPoint] with respect to theta.
  static Offset _loopTangent(double theta, double k) {
    final double r = _loopEntryRadius * math.exp(k * theta);
    return Offset(
      r * (k * math.sin(theta) + math.cos(theta)),
      -r * (k * (1 - math.cos(theta)) + math.sin(theta)),
    );
  }

  /// Heading of the loop's tangent, unwrapped so it winds continuously
  /// from 0 down through -2pi instead of jumping at the atan2 seam.
  /// Without this the plane would spin a full turn backwards the
  /// moment it passed the top of the loop.
  static double _loopHeading(double theta, double k) {
    final Offset t = _loopTangent(theta, k);
    final double principal = math.atan2(t.dy, t.dx);
    // The true heading tracks -theta closely; snap the principal value
    // onto that branch.
    final double turns = ((principal + theta) / (2 * math.pi)).roundToDouble();
    return principal - 2 * math.pi * turns;
  }

  List<_PlaneFrame> _buildTrajectory() {
    final Offset origin = widget.origin;
    final Size viewport = widget.viewportSize;
    final double k =
        math.log(_loopExitRadius / _loopEntryRadius) / _loopSweep;

    // --- fit the shape to the space that actually exists ------------
    // The loop is the centrepiece, so the available room is spent on it
    // FIRST and the take-off roll gets whatever is left. On a phone the
    // submit button is right-aligned with ~30 px of page beside it: a
    // roll that insists on its full 200 px pushes the plane straight
    // off the edge and the loop happens where nobody can see it, which
    // is what both this round's first attempt and the shipping build
    // did there.
    double loopMaxX = 0.0;
    double loopMaxRise = 0.0;
    for (int i = 0; i <= _loopSamples; i++) {
      final Offset p = _loopPoint(_loopSweep * i / _loopSamples, k);
      if (p.dx > loopMaxX) loopMaxX = p.dx;
      if (-p.dy > loopMaxRise) loopMaxRise = -p.dy;
    }
    const double glyphRoom = 24.0;
    const double headerRoom = 90.0;
    final double roomRight =
        math.max(0.0, viewport.width - origin.dx - glyphRoom);
    final double roomUp = math.max(0.0, origin.dy - headerRoom);
    // A small, absolute overshoot budget — enough that the widest part
    // of the arc may graze an edge rather than collapsing the loop to a
    // dot, but no more. Sized as a fraction of the viewport it is far
    // too generous where it matters: on a 420 px phone an 8% budget let
    // the climb carry the plane wholly past the right edge, and it
    // stayed there for 600 ms of a 2400 ms flight.
    const double slackX = 12.0;
    const double slackY = 20.0;
    final double geometryScale = math
        .min(
          1.0,
          math.min((roomUp + slackY) / loopMaxRise,
              (roomRight + slackX) / loopMaxX),
        )
        .clamp(0.28, 1.0);

    // Whatever right-hand room the loop did not claim becomes runway.
    final double runway = math.min(_runwayLength * geometryScale,
        math.max(0.0, roomRight - loopMaxX * geometryScale));

    // The plane grows with its own choreography: a 12x glyph swooping
    // out of a loop a third that size reads as two unrelated things.
    final double endScale = 1.0 + (_endScale - 1.0) * geometryScale;

    // --- arc length along the loop ----------------------------------
    final List<double> loopArc = List<double>.filled(_loopSamples + 1, 0.0);
    for (int i = 1; i <= _loopSamples; i++) {
      final double a = _loopSweep * (i - 1) / _loopSamples;
      final double b = _loopSweep * i / _loopSamples;
      // trapezoid on |dP/dtheta|
      loopArc[i] = loopArc[i - 1] +
          0.5 *
              (_loopTangent(a, k).distance + _loopTangent(b, k).distance) *
              (b - a) *
              geometryScale;
    }
    final double loopLength = loopArc[_loopSamples];

    // --- the straight exit ------------------------------------------
    final Offset loopEndLocal = _loopPoint(_loopSweep, k) * geometryScale;
    final Offset exitPoint = origin + Offset(runway, 0) + loopEndLocal;
    final Offset exitDir =
        Offset(math.cos(_exitClimbAngle), -math.sin(_exitClimbAngle));
    // Run until the whole glyph — at full growth — is past the right
    // edge, so the flight ends as the plane leaves rather than some
    // way after it (the old path cleared the edge at ~78% of the clock
    // and spent the remaining 660 ms invisible, holding up the
    // "Danke." reveal that waits on it).
    final double clearance = _glyphSize * endScale;
    final double exitLength = math.max(
      120.0,
      (viewport.width + clearance - exitPoint.dx) / exitDir.dx,
    );

    final double total = runway + loopLength + exitLength;

    // --- one speed schedule over the whole path ---------------------
    // Working in normalized time: v(tn) = v0*e^(c*tn) with
    // v0 = total*c/(ratio-1) so the integral over [0,1] is exactly the
    // path length. Distance, not time, decides where each phase falls,
    // which is why the joins cannot disagree about speed.
    final double c = math.log(_speedRatio);
    final double v0 = total * c / (_speedRatio - 1);

    final double exitHeading = _loopHeading(_loopSweep, k);

    final List<_PlaneFrame> frames = <_PlaneFrame>[];
    for (int i = 0; i <= _frameCount; i++) {
      final double tn = i / _frameCount;
      final double s = v0 * (math.exp(c * tn) - 1) / c;

      Offset pos;
      double rotation;
      if (s <= runway) {
        pos = origin + Offset(s, 0);
        rotation = 0.0;
      } else if (s <= runway + loopLength) {
        final double theta = _thetaAtArc(s - runway, loopArc);
        pos = origin + Offset(runway, 0) + _loopPoint(theta, k) * geometryScale;
        rotation = _loopHeading(theta, k);
      } else {
        pos = exitPoint + exitDir * (s - runway - loopLength);
        rotation = exitHeading;
      }

      frames.add(_PlaneFrame(
        t: tn,
        pos: pos,
        rotation: rotation,
        scale: _sampleScale(tn, endScale),
      ));
    }
    return frames;
  }

  /// Invert the loop's arc-length table: distance along the loop to
  /// swept angle.
  double _thetaAtArc(double arc, List<double> table) {
    if (arc <= 0) return 0.0;
    if (arc >= table.last) return _loopSweep;
    int lo = 0;
    int hi = table.length - 1;
    while (lo < hi) {
      final int mid = (lo + hi) >> 1;
      if (table[mid] < arc) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    final int i = math.max(1, lo);
    final double a = table[i - 1];
    final double b = table[i];
    final double f = b == a ? 0.0 : (arc - a) / (b - a);
    return _loopSweep * (i - 1 + f) / _loopSamples;
  }

  /// Exponential scale schedule over normalized time:
  /// e^(ln(endScale) · tn^_scaleSharpness). Equals 1 at launch and
  /// [endScale] at the last frame; the sharpness exponent keeps growth
  /// subtle through the roll and the loop and explosive on the exit.
  double _sampleScale(double tn, double endScale) {
    return math.exp(
      math.log(endScale) * math.pow(tn.clamp(0.0, 1.0), _scaleSharpness),
    );
  }

  /// Sample the trajectory at fractional index, interpolating position,
  /// rotation and scale between the bracketing baked frames.
  _PlaneFrame _sampleTrajectory(double controllerT) {
    final double clamped = controllerT.clamp(0.0, 1.0);
    final double idx = clamped * (_trajectory.length - 1);
    final int i0 = idx.floor();
    final int i1 = math.min(i0 + 1, _trajectory.length - 1);
    final double f = idx - i0;
    final _PlaneFrame a = _trajectory[i0];
    final _PlaneFrame b = _trajectory[i1];
    return _PlaneFrame(
      t: a.t + (b.t - a.t) * f,
      pos: Offset(
        a.pos.dx + (b.pos.dx - a.pos.dx) * f,
        a.pos.dy + (b.pos.dy - a.pos.dy) * f,
      ),
      // Both endpoints come off the same unwrapped branch, so a plain
      // lerp is correct here — no shortest-arc handling needed.
      rotation: a.rotation + (b.rotation - a.rotation) * f,
      scale: a.scale + (b.scale - a.scale) * f,
    );
  }

  // The Material `Icons.send` glyph points horizontally right at
  // rotation 0, which is why a level runway means the plane lifts off
  // at exactly the angle the button's own icon was drawn at. An
  // earlier round added +pi/4 here on the assumption that the glyph
  // pointed up-right; it does not, and the plane sat 45 deg clockwise
  // of its flight direction until that was removed.

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: widget.controller,
          builder: (context, _) {
            final double t = widget.controller.value.clamp(0.0, 1.0);

            // Everything the frame needs was baked from the path
            // itself — position, the analytic tangent as an unwrapped
            // rotation, and the scale. Nothing here is stateful, so
            // the same controller value always draws the same frame
            // regardless of frame rate or how many builds ran before.
            final _PlaneFrame frame = _sampleTrajectory(t);
            final Offset pos = frame.pos;
            final double scale = frame.scale;
            final double rotation = frame.rotation;

            // Opacity: hold opaque through the whole flight. Fade
            // out gently in the last 3% so off-screen frames don't
            // get a sudden pop if timing is slightly off.
            final double opacity = t > 0.97
                ? ((1.0 - t) / 0.03).clamp(0.0, 1.0)
                : 1.0;

            return Stack(
              children: <Widget>[
                Positioned(
                  left: pos.dx - _glyphSize / 2,
                  top: pos.dy - _glyphSize / 2,
                  width: _glyphSize,
                  height: _glyphSize,
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: scale,
                      child: Transform.rotate(
                        angle: rotation,
                        // DYNAMIC-INVERSION paper plane. A ClipPath
                        // restricts the visible region to a paper-
                        // plane silhouette (Material `Icons.send`
                        // outline). Inside that clip a BackdropFilter
                        // runs a colour-matrix that inverts the
                        // backdrop pixels (negate RGB, add 255), so
                        // the plane always reads as the inverse of
                        // whatever sits behind it — white over a
                        // black submit button, black over a white
                        // success card, anything-vs-anything as it
                        // flies across the page. The empty SizedBox
                        // child only exists to give the BackdropFilter
                        // a layout box; nothing is painted ON TOP of
                        // the backdrop — the inversion IS the visual.
                        child: const _InvertingPaperPlane(
                          size: _glyphSize,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Paper-plane silhouette that paints whatever sits behind it in
/// inverted colour. Achieves the user-spec'd "plane is always the
/// inverse of what's behind it" by composing a [ClipPath] (the
/// paper-plane outline) with a [BackdropFilter] running a colour-
/// matrix invert (negate RGB, add 255). The child SizedBox supplies
/// layout; nothing is painted on top of the inverted backdrop —
/// the inversion IS the visible plane.
class _InvertingPaperPlane extends StatelessWidget {
  const _InvertingPaperPlane({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: const _PaperPlaneClipper(),
      child: BackdropFilter(
        filter: const ui.ColorFilter.matrix(<double>[
          -1, 0, 0, 0, 255,
          0, -1, 0, 0, 255,
          0, 0, -1, 0, 255,
          0, 0, 0, 1, 0,
        ]),
        child: SizedBox(width: size, height: size),
      ),
    );
  }
}

/// Material `Icons.send` outline transcribed into a [Path] so it can
/// be used as a [ClipPath]. Coordinates are the canonical 24×24
/// Material viewport, scaled to the actual clip size.
class _PaperPlaneClipper extends CustomClipper<Path> {
  const _PaperPlaneClipper();

  @override
  Path getClip(Size size) {
    final double s = size.width / 24.0;
    final Path path = Path();
    path.moveTo(2 * s, 21 * s);
    path.lineTo(23 * s, 12 * s);
    path.lineTo(2 * s, 3 * s);
    path.lineTo(2 * s, 10 * s);
    path.lineTo(17 * s, 12 * s);
    path.lineTo(2 * s, 14 * s);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _PaperPlaneClipper oldClipper) => false;
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.message,
    required this.color,
    required this.isSuccess,
  });

  final String message;
  final Color color;
  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSuccess
            ? color.withValues(alpha: 0.18)
            : color.withValues(alpha: 0.10),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            isSuccess ? Icons.check_circle_outline : Icons.error_outline,
            color: color,
            size: Sizes.ICON_SIZE_20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Get.textTheme.bodyLarge?.copyWith(
                color: CustomColors.black,
                fontWeight: FontWeight.w400,
                fontSize: Sizes.TEXT_SIZE_14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
