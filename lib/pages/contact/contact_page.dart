import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

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
  static const String _web3formsEndpoint = 'https://api.web3forms.com/submit';
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
  // Timeline: 0.00 = at-rest on the button (slow takeoff start),
  // 1.00 = well past the viewport's right edge.
  // Total flight: 4000 ms (was 2900 ms — further amplified per user
  // feedback: takeoff "way slower and further to the right", with a
  // physics-feel dive→climb that gains speed downhill and loses
  // speed uphill, ending in a dramatic 8× exit).
  //
  // PHYSICS-FEEL CHOREOGRAPHY (round 4):
  //   0.000 → 0.180 (720 ms)  Slow takeoff: rightward acceleration
  //       (easeInQuad) from origin → (+200, -30). No leftward
  //       motion, no scale change. Plane is just gliding right.
  //   0.180 → 0.350 (680 ms)  Slow leftward arc (high turning
  //       radius): wide curve up-left from (+200, -30) to
  //       (-180, -120). Bezier control at (+260, -140) so the arc
  //       bows OUTWARD (climbing while turning). Speed slows
  //       (banking). Scale 1.0 → 1.2.
  //   0.350 → 0.450 (400 ms)  LOOP: 360° circle of radius 80 at
  //       current position; center lerps forward +40 px. Icon
  //       rotation adds +2π. Scale 1.2 → 1.4.
  //   0.450 → 0.620 (680 ms)  DIVE (gains speed): from loop-end at
  //       (-140, -110) drop diagonally to (-40, +50) with
  //       easeInCubic. Velocity peaks here. Scale 1.4 → 1.8.
  //   0.620 → 0.770 (600 ms)  CLIMB (loses speed): up-right curve
  //       from (-40, +50) to (+200, -120) with easeOutCubic.
  //       Plane decelerates as it rises. Scale 1.8 → 2.4.
  //   0.770 → 1.000 (920 ms)  FINAL exit: accelerate rightward
  //       (easeInExpo) to (viewportWidth + 600, origin.y - 700).
  //       Scale 2.4 → 8.0. The "flying into the camera" cue.
  //
  // Rotation: tracks the velocity vector (atan2(vy, vx)) computed by
  // finite-differencing position(t) ± a small dt. During the loop
  // window the rotation is overridden to add a full +2π so the icon
  // spins through the loop. Phase boundary positions are matched
  // exactly so velocity is continuous (C1) — no rotation snap.
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
    // Plane-flight duration: 4000 ms broken into SIX physics-feel
    // phases (further amplified from the prior 2900 ms — user
    // reported the previous takeoff felt designed-not-flown and
    // wanted dive→climb momentum, plus a much bigger exit):
    //   0.000 → 0.180 (720 ms)  slow takeoff (easeInQuad): glide
    // Plane controller is now just a clock that drives a lookup into a
    // pre-computed physics trajectory (see [_PaperPlaneFlyOff]). The
    // simulation is integrated at 480 Hz in initState of the fly-off
    // widget; the controller's t∈[0,1] simply samples the recorded
    // frames so motion can be replayed deterministically every flight.
    _planeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
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
        // Real-physics paper-plane choreography (round 5 — per user
        // feedback that round 4's Bezier-stitched motion was chaotic
        // and the rotation didn't track the velocity vector).
        // The plane is now a forward physics simulation (gravity +
        // drag + lift + scripted thrust impulses) pre-computed in
        // _PaperPlaneFlyOff; the controller's t∈[0,1] samples that
        // trajectory.
        //   t=0     POST returned success.
        //   t=300   Plane controller starts (4500 ms total).
        //   t=400   Form cascade-exit starts.
        //   t=300 + 0..400ms     takeoff impulse (right + lift).
        //   t=300 + 400..900ms   coast (drag + gravity).
        //   t=300 + 900..1300ms  leftward steering impulse.
        //   t=300 + 1300..1800ms coast (drop phase).
        //   t=300 + 1800..2400ms updraft + slight right impulse.
        //   t=300 + 2400..3200ms big rightward exit impulse.
        //   t=300 + 3200..4500ms coast (huge velocity → off-screen).
        //   t=1080  Cascade exit done.
        //   t≈4800  Plane controller completes → success card reveals.
        _successCardSwapTimer?.cancel();
        _formExitTimer?.cancel();
        _planeLaunchTimer?.cancel();
        // t=400: form cascade exit begins.
        _successCardSwapTimer = Timer(const Duration(milliseconds: 400), () {
          if (!mounted) return;
          _formExitController.forward(from: 0);
        });
        // t=300: plane launches (wind-up). Slightly EARLIER than the
        // cascade so the wind-up reads clearly while the button is
        // still solid.
        _planeLaunchTimer = Timer(const Duration(milliseconds: 300), () {
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
        _formExitTimer = Timer(const Duration(milliseconds: 1080), () {
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

/// The celebration paper-plane fly-off.
///
/// Renders inside an [OverlayEntry] above the entire app so it can
/// fly past every ancestor clip (Scrollbar, SingleChildScrollView,
/// PageWrapper) and exit the viewport's right edge cleanly. The
/// widget paints into a [Positioned.fill] [IgnorePointer] inside the
/// overlay and re-positions a small icon glyph each frame off
/// [controller]'s value.
///
/// PHYSICS-FEEL CHOREOGRAPHY — round 4. Round 3 (2900 ms, wind-up
/// pull-back + leftward Bezier + loop + easeInExpo exit) read as
/// designed-not-flown. User wanted a slow takeoff to the RIGHT
/// (no wind-up pull-back), then a wide gentle leftward turn, then
/// the loop (which they loved), then a clear DIVE that gains speed
/// and CLIMB that loses speed — i.e. gravity-flavoured momentum —
/// followed by a much bigger exit (8×). This pass:
///
///   * Replaces the wind-up with a slow rightward takeoff
///     (easeInQuad, +200 px, lifts -30 px). No scale-down — the
///     plane reads as already gliding.
///   * Slows + widens the leftward turn (680 ms, high turning
///     radius) so the transition out of takeoff is smooth — same
///     velocity vector at the boundary.
///   * Keeps the +2π loop (user loved it). 400 ms, radius 80.
///   * Adds a DIVE phase (easeInCubic) that accelerates downward —
///     the plane gains speed dropping.
///   * Adds a CLIMB phase (easeOutCubic) that decelerates upward —
///     the plane loses speed lifting.
///   * Final exit goes much further (vw + 600, origin.y - 700) and
///     scales 2.4 → 8.0× — looms into the camera.
///
/// ROTATION: tracks the velocity vector. Each frame we compute
/// position(t) and position(t - dt) for a small dt; rotation =
/// atan2(vy, vx). During the loop window we OVERRIDE this with a
/// linear +2π sweep so the plane visibly spins through the loop.
/// Boundary positions are matched exactly between phases (C0
/// continuity); curves are chosen so the velocity directions agree
/// at boundaries (approximate C1 continuity — the visible "snap" is
/// gone).
///
/// VISIBILITY: the plane icon is rendered black-on-the-button at
/// rest, but a white halo (a slightly enlarged white instance of
/// the same glyph drawn behind the black instance) keeps it
/// visible against the black button. The halo also acts as a soft
/// glow over light page areas during flight.
/// One sample of the pre-computed paper-plane trajectory: position,
/// velocity (for rotation tracking), and scale at a given simulation
/// time. Velocity is recorded alongside position so the rotation each
/// frame can be computed without finite-difference noise.
class _PlaneFrame {
  const _PlaneFrame({
    required this.t,
    required this.pos,
    required this.vel,
    required this.scale,
  });
  final double t; // seconds since launch
  final Offset pos; // viewport-global position
  final Offset vel; // px/s, used for rotation = atan2(vy, vx)
  final double scale;
}

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

  // -------------------- Physics simulation constants -----------------
  // All forces are expressed in pixels and seconds. Gravity pulls down
  // (+Y in screen coordinates). Drag opposes velocity proportional to
  // v². Lift acts perpendicular to velocity in the upward sense (so a
  // paper plane gliding rightward gets a small upward component, but
  // a plane diving steeply also receives drag-balanced lift along its
  // wing's normal).
  static const double _gravity = 220.0; // px / s²
  static const double _drag = 0.0018; // dimensionless × v² → px/s²
  // Lowered (was 0.0011) so gravity dominates during coast windows
  // and the plane visibly drops between climb-and-exit phases.
  static const double _lift = 0.0006; // dimensionless × v² → px/s²

  // Total simulated flight in wall-clock seconds. Must equal the
  // controller's duration so t∈[0,1] maps linearly to seconds.
  static const double _flightSeconds = 4.5;

  // High-rate integration step. 0.002s = 500 Hz which gives stable
  // velocity-squared drag/lift even during the boosted launch.
  static const double _dt = 0.002;

  // Scale-vs-time anchors. Linearly interpolated between anchors.
  // The plane grows as it "approaches the camera" — see _sampleScale.
  static const List<MapEntry<double, double>> _scaleAnchors =
      <MapEntry<double, double>>[
    MapEntry(0.0, 1.0),
    MapEntry(0.5, 1.1),
    MapEntry(1.5, 1.3),
    MapEntry(2.5, 1.8),
    MapEntry(3.0, 2.5),
    MapEntry(3.5, 4.0),
    MapEntry(4.0, 7.0),
    MapEntry(4.5, 9.0),
  ];

  /// Pre-computed trajectory frames. Built once in [initState].
  late final List<_PlaneFrame> _trajectory;

  @override
  void initState() {
    super.initState();
    _trajectory = _buildTrajectory();
  }

  /// Scripted thrust schedule. Sparse impulse windows that shape the
  /// user-described 5-phase trajectory. Values tuned via off-line
  /// simulation so the resulting motion tells this story:
  ///   1) takeoff right + strong up — visible climb (~150-200 px)
  ///   2) leftward arc at apex
  ///   3) explicit drop phase — plane visibly falls
  ///   4) strong recovery updraft
  ///   5) big exit right + climbing (~7-9× scale)
  ///
  /// Windows:
  ///   0.00–0.40s  takeoff impulse: strong right + strong up
  ///   0.40–0.85s  coast w/ gentle lift (slows from drag)
  ///   0.85–1.55s  pronounced leftward arc; minimal y-thrust (let
  ///               lift carry it up while x reverses)
  ///   1.55–2.00s  brief left coast, zero y-thrust → gravity takes over
  ///   2.00–2.40s  explicit drop pulse (slight right + DOWN)
  ///   2.40–2.95s  strong recovery updraft
  ///   2.95–3.70s  big rightward exit + climb
  ///   3.70+        coast (huge velocity carries plane off-screen)
  Offset _scriptedThrust(double t) {
    if (t < 0.40) return const Offset(900, -800);
    if (t < 0.85) return const Offset(0, -80);
    if (t < 1.55) return const Offset(-500, -50);
    if (t < 2.00) return const Offset(-60, 0);
    if (t < 2.40) return const Offset(100, 200);
    if (t < 2.95) return const Offset(320, -700);
    if (t < 3.70) return const Offset(1500, -450);
    return Offset.zero;
  }

  /// Run the forward simulation and record (pos, vel, scale) at each
  /// step. The recorded list is later sampled by the controller's
  /// clock in the build method.
  List<_PlaneFrame> _buildTrajectory() {
    final List<_PlaneFrame> frames = <_PlaneFrame>[];
    Offset pos = widget.origin;
    // Start at rest — the launch impulse in _scriptedThrust(0..0.4)
    // is what spawns the initial velocity. This avoids the magic
    // "give it an initial v" tuning that hides the physics.
    Offset vel = Offset.zero;

    double t = 0.0;
    // Record the very first frame so t=0 lookups return the origin
    // even before any integration has happened.
    frames.add(_PlaneFrame(
      t: 0.0,
      pos: pos,
      vel: vel,
      scale: _sampleScale(0.0),
    ));

    while (t < _flightSeconds) {
      // ---- Forces ----
      const Offset gravity = Offset(0, _gravity);

      final double v2 = vel.distanceSquared;
      final double vMag = math.sqrt(v2);
      // Unit velocity (guard against div-by-zero at rest).
      final Offset velNorm = vMag > 1e-6
          ? Offset(vel.dx / vMag, vel.dy / vMag)
          : Offset.zero;

      // Drag: opposes velocity, magnitude proportional to v².
      final Offset drag = velNorm * (-_drag * v2);

      // Lift: perpendicular to velocity, biased so its Y component
      // is negative (i.e. lifts UPWARD against gravity). For a paper
      // plane that's nose-tracking, lift is normal to the wings'
      // (≈ flight) direction.
      double liftMag = _lift * v2;
      Offset liftDir = Offset(-velNorm.dy, velNorm.dx); // perp CCW
      if (liftDir.dy > 0) liftDir = -liftDir; // ensure upward
      final Offset lift = liftDir * liftMag;

      final Offset thrust = _scriptedThrust(t);

      final Offset acc = gravity + drag + lift + thrust;

      // ---- Integrate (semi-implicit Euler — stable for this scale) ----
      vel = vel + acc * _dt;
      pos = pos + vel * _dt;
      t += _dt;

      frames.add(_PlaneFrame(
        t: t,
        pos: pos,
        vel: vel,
        scale: _sampleScale(t),
      ));
    }
    return frames;
  }

  /// Linear interpolation across [_scaleAnchors].
  double _sampleScale(double t) {
    if (t <= _scaleAnchors.first.key) return _scaleAnchors.first.value;
    if (t >= _scaleAnchors.last.key) return _scaleAnchors.last.value;
    for (int i = 0; i < _scaleAnchors.length - 1; i++) {
      final MapEntry<double, double> a = _scaleAnchors[i];
      final MapEntry<double, double> b = _scaleAnchors[i + 1];
      if (t >= a.key && t <= b.key) {
        final double localT = (t - a.key) / (b.key - a.key);
        return a.value + (b.value - a.value) * localT;
      }
    }
    return _scaleAnchors.last.value;
  }

  /// Sample the trajectory at fractional index. Linearly interpolates
  /// position, velocity, and scale between the bracketing recorded
  /// frames so the lookup is smooth at any controller t.
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
      vel: Offset(
        a.vel.dx + (b.vel.dx - a.vel.dx) * f,
        a.vel.dy + (b.vel.dy - a.vel.dy) * f,
      ),
      scale: a.scale + (b.scale - a.scale) * f,
    );
  }

  // -------------------- Rotation helpers -------------------- //
  // The Material `Icons.send` glyph natively points horizontally to
  // the right at rotation=0 (atan2(vy, vx)==0 → nose along +x). No
  // neutral-angle offset is required; the velocity-derived atan2
  // angle directly aligns the nose with the flight direction.
  //
  // History: an earlier version added +π/4 here, assuming the glyph
  // pointed up-right by default; visual testing on a live page showed
  // the plane consistently sat 45° clockwise of its actual flight
  // direction, so the offset was removed.
  static const double _iconNeutralAngle = 0.0;

  // Rotation smoothing time constant. Small enough that real direction
  // changes (turn / drop / climb) read instantly, large enough that
  // any tiny stray velocity wobble near zero-crossings is filtered.
  // Lowered to 0.28 so the dramatic apex flip (when X velocity briefly
  // reverses around the leftward turn) reads as a gentle banking
  // rotation rather than an instant snap.
  static const double _rotationLerpAlpha = 0.28;
  double? _smoothedRotation;


  /// Compute the desired rotation for a velocity vector and apply a
  /// small low-pass filter to suppress tiny stray wobbles near zero-
  /// velocity moments. Returns the smoothed rotation in radians.
  double _rotationForVelocity(Offset vel) {
    final double vMag = vel.distance;
    // Very low velocity → keep previous smoothed rotation (no jitter
    // when launching from rest in the first few simulation steps).
    final double target = vMag < 1.0
        ? (_smoothedRotation ?? _iconNeutralAngle)
        : math.atan2(vel.dy, vel.dx) + _iconNeutralAngle;

    // Angular lerp: shortest-path interpolation so a wrap from +π →
    // −π doesn't spin the plane through a full revolution.
    if (_smoothedRotation == null) {
      _smoothedRotation = target;
      return target;
    }
    double delta = target - _smoothedRotation!;
    while (delta > math.pi) {
      delta -= 2 * math.pi;
    }
    while (delta < -math.pi) {
      delta += 2 * math.pi;
    }
    _smoothedRotation = _smoothedRotation! + delta * _rotationLerpAlpha;
    return _smoothedRotation!;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: widget.controller,
          builder: (context, _) {
            final double t = widget.controller.value.clamp(0.0, 1.0);

            // Sample the pre-computed physics trajectory at the
            // controller's clock. Position, velocity, and scale all
            // come from the simulation — no per-build curve math.
            final _PlaneFrame frame = _sampleTrajectory(t);
            final Offset pos = frame.pos;
            final double scale = frame.scale;

            // Rotation: derived directly from the velocity vector
            // recorded by the simulation. atan2(vy, vx) gives the
            // direction the plane is flying; +π/4 corrects for
            // Icons.send's natural up-right orientation. Smoothed
            // with a low-pass filter to suppress any micro-jitter
            // at very low speeds (e.g. very first frames at rest).
            final double rotation = _rotationForVelocity(frame.vel);

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
                        // VISIBILITY: white halo behind the black
                        // glyph keeps the plane visible against
                        // both the black button (rest) and the
                        // light page (flight). Same glyph rendered
                        // twice: a slightly enlarged white instance
                        // underneath, then the canonical black
                        // instance on top. Reads as a subtle glow,
                        // not a stroke — the white pixels only
                        // peek out around the edges of the black
                        // silhouette.
                        child: Stack(
                          alignment: Alignment.center,
                          children: const <Widget>[
                            Icon(
                              Icons.send,
                              size: _glyphSize + 4,
                              color: Colors.white,
                            ),
                            Icon(
                              Icons.send,
                              size: _glyphSize,
                              color: CustomColors.black,
                            ),
                          ],
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
            ? color.withOpacity(0.18)
            : color.withOpacity(0.10),
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
