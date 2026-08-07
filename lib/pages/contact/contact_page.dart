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
    // pre-baked sketch-path trajectory (see [_PaperPlaneFlyOff]); its
    // t∈[0,1] samples the recorded frames so motion replays
    // deterministically every flight. 3000 ms: ~900 ms runway roll,
    // ~1140 ms for the loop, ~960 ms flat accelerating exit. Under
    // the probe harness the clock runs at half speed so timed
    // screenshots can catch every phase of the path.
    _planeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _kAnimProbe ? 6000 : 3000),
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
      Timer(const Duration(seconds: 2), () {
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
/// SKETCH-PATH CHOREOGRAPHY — round 6. Rounds 4/5 (Bezier stitching,
/// then a gravity+thrust physics simulation) never produced the shape
/// the user actually wanted, so they drew it: a short glide off the
/// button, a tight loop that spirals outward into one big loop, then
/// a straight tangential exit toward the upper right, with the plane
/// growing exponentially the whole way out. The trajectory is now an
/// explicit parametric curve of that drawing — lead-in glide →
/// exponential spiral (one loop-the-loop) → linear exit — baked
/// into frames once at launch (see [_buildTrajectory]).
///
/// ROTATION: tracks the velocity vector recorded per frame
/// (rotation = atan2(vy, vx), low-pass filtered). The spiral gives
/// the nose its two full barrel rolls "for free" — no scripted
/// rotation override needed.
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

  // -------------------- Sketch-path constants ------------------------
  // Round 6. The user drew the exact trajectory they want: a short
  // glide off the button, a tight loop that spirals OUTWARD into one
  // big loop (~2 full turns), then a tangential straight exit toward
  // the upper right, growing the whole way. The physics simulation of
  // round 5 could not produce a loop (gravity + thrust arcs, no
  // sustained centripetal turn), so the trajectory is now an explicit
  // parametric curve: lead-in glide → exponential spiral → linear
  // exit. Positions are still pre-baked into frames so the existing
  // sampling / velocity-rotation machinery is untouched.

  // Phase boundaries as fractions of the whole flight.
  static const double _leadEndT = 0.30; // runway roll
  static const double _spiralEndT = 0.68; // the growing loop
  // exit phase: _spiralEndT → 1.0

  // RUNWAY (round 8): a long rightward take-off roll. Rightward
  // because Icons.send's nose points right — the round-7 leftward
  // glide made the glyph flip 180° the instant it detached (owner:
  // "es flipt einfach instant"). easeInCubic + a sag makes it read
  // as heavy: barely moving at release, drooping, then gathering
  // real speed before pulling up into the loop.
  static const double _runwayLength = 220.0; // px rightward, clamped
  static const double _leadDip = 12.0; // px sag mid-roll

  // Loop: pulls up from the runway's end into a counterclockwise
  // loop-the-loop (right → up → left → down) whose radius grows
  // exponentially. The loop is BOTTOM-ANCHORED (round 9): its center
  // rides upward as the radius grows, so every pass returns to the
  // runway's altitude at the bottom — exactly the owner's sketch,
  // where the small and the big circle touch at their lowest point.
  // Round 8's fixed-center spiral let the bottom sag by rEnd−r0
  // (~130px), which read as the plane falling below the button and
  // exiting underneath it.
  static const double _spiralStartRadius = 22.0;
  static const double _spiralEndRadius = 150.0;
  static const double _spiralTurns = 1.0;

  // Exit climb angle above the horizon. Owner spec (round 8): a
  // nearly flat 5-10° departure to the right — not the round-7
  // corner shot that left at ~45°+.
  static const double _exitClimbAngle = 0.14; // ≈8°

  // Scale is a pure exponential in normalized time, so growth is
  // barely-there through the lead-in, gentle through the loops, and
  // explosive on the exit — "exponentially larger towards the end".
  // 12× of the 16px glyph ≈ 192px as it leaves the viewport.
  static const double _endScale = 12.0;
  static const double _scaleSharpness = 2.2;

  // Pre-baked frame rate. 240 samples/flight keeps the finite-
  // difference velocities (used for nose rotation) smooth.
  static const int _frameCount = 240;

  /// Pre-computed trajectory frames. Built once in [initState].
  late final List<_PlaneFrame> _trajectory;

  @override
  void initState() {
    super.initState();
    _trajectory = _buildTrajectory();
  }

  /// Position on the sketch path at normalized time tn ∈ [0, 1].
  ///
  /// The three phases are C0-continuous by construction (each phase
  /// starts exactly where the previous ended) and close enough to C1
  /// that the low-pass rotation filter absorbs the boundaries.
  Offset _pathPosition(double tn, double geometryScale) {
    final Offset origin = widget.origin;
    final double r0 = _spiralStartRadius * geometryScale;
    final double rEnd = _spiralEndRadius * geometryScale;
    // Runway length, clamped so the loop that follows it still fits
    // inside the right edge (the spiral extends only ~0.25·rEnd to
    // the right of its center — see the sweep geometry below).
    final double runway = (_runwayLength * geometryScale).clamp(
      40.0 * geometryScale,
      math.max(40.0 * geometryScale,
          widget.viewportSize.width - origin.dx - 120.0 * geometryScale),
    );

    // Loop geometry. Entry at the bottom of the circle heading
    // right; polar angle φ DECREASES from π/2 so the loop runs
    // counterclockwise on screen (right → up → left → down) — the
    // natural continuation of the rightward runway pull-up. The
    // center is recomputed per sample at (entry.x, entry.y − r) so
    // the circle GROWS UPWARD from a fixed bottom tangent point:
    // the plane returns to runway altitude every pass and never
    // sinks below the button.
    final Offset spiralEntry = origin + Offset(runway, 0);
    // Exit when the tangent (sin φ, −cos φ) points _exitClimbAngle
    // above the horizon toward the right: φ_exit = π/2 − angle.
    const double sweepTotal =
        _exitClimbAngle + 2 * math.pi * _spiralTurns;
    final double radiusGrowth = math.log(rEnd / r0) / sweepTotal;

    if (tn <= _leadEndT) {
      // RUNWAY: easeInCubic — the plane barely creeps at release,
      // sags under its own weight, then gathers real speed down the
      // strip. No rotation flip: the glyph's nose already points
      // along the roll direction.
      final double s = (tn / _leadEndT).clamp(0.0, 1.0);
      return origin +
          Offset(
            runway * s * s * s,
            _leadDip * geometryScale * math.sin(math.pi * s),
          );
    }

    if (tn <= _spiralEndT) {
      // LOOP: constant angular rate. Linear speed rises with the
      // radius, so the tight pull-up is leisurely and the big loop
      // is fast — the plane visibly gains energy. Bottom-anchored:
      // the center sits r above the entry for the CURRENT radius.
      final double u =
          ((tn - _leadEndT) / (_spiralEndT - _leadEndT)).clamp(0.0, 1.0);
      final double swept = sweepTotal * u;
      final double phi = math.pi / 2 - swept;
      final double r = r0 * math.exp(radiusGrowth * swept);
      final Offset center = spiralEntry + Offset(0, -r);
      return center + Offset(r * math.cos(phi), r * math.sin(phi));
    }

    // EXIT: straight line along the spiral's final tangent — a nearly
    // flat departure to the right. The travel is speed-driven, NOT
    // distance-driven: it starts at exactly the spiral's end speed
    // (no visible brake at the hand-off) and triples by the end, so
    // the fly-off reads identically on any viewport width. The far
    // end always overshoots every screen edge, and the overlay is
    // torn down when the clock completes.
    final double w =
        ((tn - _spiralEndT) / (1.0 - _spiralEndT)).clamp(0.0, 1.0);
    const double phiExit = math.pi / 2 - sweepTotal;
    // Bottom-anchored center at the final radius: the exit point
    // lands back at (almost exactly) runway altitude.
    final Offset exitCenter = spiralEntry + Offset(0, -rEnd);
    final Offset exitPoint = exitCenter +
        Offset(rEnd * math.cos(phiExit), rEnd * math.sin(phiExit));
    final Offset exitDir = Offset(
      math.cos(_exitClimbAngle),
      -math.sin(_exitClimbAngle),
    );
    // Spiral end speed in px per normalized-time unit; the exit
    // integrates v(w) = v0·(1 + 2w²) → dist = v0·ΔT·(w + ⅔w³)·…
    // folded into the simple polynomial below.
    final double spiralEndSpeed =
        rEnd * sweepTotal / (_spiralEndT - _leadEndT);
    const double exitWindow = 1.0 - _spiralEndT;
    final double dist =
        spiralEndSpeed * exitWindow * (w + 0.667 * w * w * w);
    return exitPoint + exitDir * dist;
  }

  /// Bake the parametric path into evenly spaced frames. Velocity is
  /// central-differenced so the nose-rotation lookup stays smooth.
  List<_PlaneFrame> _buildTrajectory() {
    // On narrow (phone) viewports the full-size spiral would swing
    // past the right edge; shrink the geometry, never the scale-up.
    final double geometryScale =
        widget.viewportSize.width < 700 ? 0.55 : 1.0;
    final List<_PlaneFrame> frames = <_PlaneFrame>[];
    const double dt = 1.0 / _frameCount;
    for (int i = 0; i <= _frameCount; i++) {
      final double tn = i / _frameCount;
      final Offset before =
          _pathPosition((tn - dt).clamp(0.0, 1.0), geometryScale);
      final Offset after =
          _pathPosition((tn + dt).clamp(0.0, 1.0), geometryScale);
      frames.add(_PlaneFrame(
        t: tn,
        pos: _pathPosition(tn, geometryScale),
        vel: (after - before) / (2 * dt),
        scale: _sampleScale(tn),
      ));
    }
    return frames;
  }

  /// Exponential scale schedule over normalized time:
  /// e^(ln(_endScale) · tn^_scaleSharpness). Equals 1 at launch and
  /// _endScale at the last frame; the sharpness exponent keeps growth
  /// subtle through the loops and explosive on the exit.
  double _sampleScale(double tn) {
    return math.exp(
      math.log(_endScale) *
          math.pow(tn.clamp(0.0, 1.0), _scaleSharpness),
    );
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
  // changes read instantly, large enough that any tiny stray velocity
  // wobble near zero-crossings is filtered. Raised to 0.45 for the
  // spiral path: at ~7.5 rad/s through the loops a heavier filter made
  // the nose visibly trail its own flight direction.
  static const double _rotationLerpAlpha = 0.45;
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
