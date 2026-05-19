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
  // Timeline: 0.00 = at-rest on the button (wind-up start),
  // 1.00 = well past the viewport's right edge.
  // Total flight: 2200 ms (was 1400 ms — amplified so each phase is
  // unmistakably readable; the user reported the old timing read as
  // "looks just like before").
  // Phases inside [_PaperPlaneFlyOff] (on 0→1 timeline):
  //   0.00 → 0.227 wind-up (drift right ~30 px + scale-down 1.0→0.95)
  //   0.227 → 0.500 release (curl UP-LEFT to (-150,-180), scale to 1.4×)
  //   0.500 → 1.000 fly-off rightward, scale 1.4 → 3.0×,
  //                 past viewportWidth + 400 px, easeInExpo accel
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
    // Plane-flight duration: 2200 ms broken into three theatrical
    // phases (amplified from the prior 1400 ms — user reported the
    // earlier choreography read as "looks just like before"):
    //   0.000 → 0.227 (500 ms): wind-up — plane drifts ~30 px RIGHT
    //     and scales down 1.0 → 0.95. Reads as the plane being
    //     "loaded" / "drawn back" before launch.
    //   0.227 → 0.500 (600 ms): release — curls UP-LEFT to
    //     (-150 px, -180 px) along a quadratic Bezier, scales
    //     1.0 → 1.4×. Wide leftward arc so the choreography reads
    //     as a deliberate slingshot.
    //   0.500 → 1.000 (1100 ms): fly-off — curves back rightward,
    //     accelerates with easeInExpo, scales 1.4 → 3.0×, climbs as
    //     it exits, lands past viewportWidth + 400 px. The
    //     "flying toward the viewer" depth cue dominates.
    // Geometry inside [_PaperPlaneFlyOff].
    _planeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
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
        // Theatrical paper-plane choreography (amplified from earlier
        // pass — every phase is now distinctly readable on a 1440 px
        // viewport, with the user-reported "looks like before"
        // perception explicitly addressed by 2× durations / displacements):
        //   t=0     POST returned success. Button transitions from
        //           spinner BACK to the paper-plane icon (Icons.send).
        //           NO check / "GESENDET" morph — the glyph stays as
        //           a paper plane through the wind-up.
        //   t=300   Plane wind-up begins: OverlayEntry inserted above
        //           the app, button's iconOpacity flips to 0, plane
        //           controller starts. Phase A drifts the plane ~30 px
        //           to the right AND scales 1.0 → 0.95 ("loaded into
        //           slingshot") over ~500 ms.
        //   t=400   Form cascade-exit starts (staggered fade + slide).
        //   t=800   Phase B: plane curls UP-LEFT to (-150 px, -180 px)
        //           over ~600 ms, scale 1.0 → 1.4×. Wide leftward arc.
        //   t=1400  Phase C: plane curves back rightward, accelerates
        //           with easeInExpo, climbs altitude, scales 1.4 →
        //           3.0×, exits past viewportWidth + 400 px (~1100 ms).
        //   t=1080  Cascade exit done. Flip _showSuccessCard so the
        //           form swaps for the success card — but the
        //           letter-by-letter "Danke." reveal stays paused.
        //   t≈2500  Plane controller completes:
        //           - OverlayEntry removed,
        //           - _planeInFlight flips false,
        //           - _successCardController.forward() finally fires.
        //   t≈2620  "Danke." headline letters start revealing.
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
/// THEATRICAL TIMING (amplified). The earlier choreography
/// (250 + 336 + 812 ms = 1398 ms total, 15 px wind-up, -60/-90 curl,
/// scale → 2.0×) read to users as "looks just like before" — too
/// quick and too tight to register as a distinct multi-phase
/// sequence. This pass DOUBLES every readable quantity so each phase
/// is unmistakable:
///
/// - Phase A (wind-up), t = 0.000 → 0.227 (≈500 ms on 2200 ms total):
///   plane sits at [origin], drifts ~30 px to the RIGHT (was 15 px)
///   AND shrinks 1.0 → 0.95 (new — telegraphs "being loaded into
///   the slingshot"). Soft easeInOut for the drift, mirrored for
///   the shrink. Tiny rotational nudge.
///
/// - Phase B (release / leftward curl), t = 0.227 → 0.500 (≈600 ms):
///   plane curves UP-LEFT to (origin + (-150, -180)) — 2.5× the
///   prior leftward extent, doubled vertical climb. Quadratic
///   Bezier with control point pulled hard left and up so the arc
///   bows OUTWARD (leftward) instead of just sweeping a gentle
///   diagonal. Scale eases 0.95 → 1.4× (was 1.0 → 1.15×). Rotation
///   tilts left to track the tangent.
///
/// - Phase C (fly-off rightward + scale up), t = 0.500 → 1.000
///   (≈1100 ms): plane curves rightward off the page along a
///   quadratic Bezier whose end point sits past viewportWidth + 400
///   (was +200). Scale grows 1.4 → 3.0× (was 1.15 → 2.0×). Control
///   point pulled higher so the plane CLIMBS as it leaves — reading
///   as "departing skyward" rather than skimming horizontally.
///   EaseInExpo (was easeInQuad) for a clearer, more dramatic
///   acceleration in the final 300 ms.
class _PaperPlaneFlyOff extends StatelessWidget {
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

  // Match the submit button's icon size exactly (Sizes.ICON_SIZE_16,
  // 16px) so the entity that lifts off reads as the same glyph the
  // visitor just clicked.
  static const double _glyphSize = Sizes.ICON_SIZE_16;

  // Phase boundaries on the controller's 0→1 timeline. With the
  // 2200 ms total they correspond to 500 ms wind-up, 600 ms curl-up-
  // left, 1100 ms fly-off.
  static const double _windUpEnd = 0.227; // ≈500 ms
  static const double _leftReleaseEnd = 0.500; // +600 ms → 1100 ms

  // Phase-A displacement: how far to drift right during the wind-up.
  // 30 px (doubled from 15 px) reads as a clear "pull-back" gesture
  // rather than a sub-perceptual nudge.
  static const double _windUpDx = 30.0;
  // Phase-A scale at the end of wind-up. Mild shrink (0.95) suggests
  // the plane is being "loaded" into the slingshot before launch.
  static const double _windUpScaleEnd = 0.95;

  // Phase-B end point relative to [origin]: 150 px LEFT, 180 px UP.
  // (Was -60/-90 — the prior extent stayed inside the form column
  // and the leftward motion barely registered. 150 px LEFT clears
  // the entire form/button stack and reads as a deliberate slingshot
  // backswing.)
  static const Offset _leftReleaseEndOffset = Offset(-150, -180);
  // Scale at the end of Phase B (peak of the curl-up-left). The
  // plane is at maximum altitude here, scaled 1.4× — bigger than
  // the previous pass's 1.15× so the leftward arc reads in the
  // peripheral vision.
  static const double _leftReleaseScale = 1.4;

  // Final scale at exit. 3.0× (was 2.0×) lands at 48 px — the plane
  // genuinely looms toward the viewer in the final third of the
  // flight, making the "flying TOWARD the camera" depth cue
  // dominate. Combined with the leftward curl, the choreography now
  // reads as a deliberate three-act loop.
  static const double _exitScale = 3.0;

  // How far PAST the right edge the plane should travel. 400 px of
  // overshoot (was 200 px) guarantees it's fully gone even with the
  // larger 3.0× exit scale, on every reasonable viewport width.
  static const double _exitOvershoot = 400.0;

  // How far ABOVE the origin the exit point sits — controls the
  // "climb out" cue. Doubled from -200 to -350 so the plane reads
  // as ascending dramatically out of the top-right rather than
  // skimming horizontally toward the edge.
  static const double _exitClimb = -350.0;

  /// EaseInOutCubic for the wind-up + left-release phases.
  double _easeInOutCubic(double t) {
    return t < 0.5
        ? 4 * t * t * t
        : 1 - math.pow(-2 * t + 2, 3).toDouble() / 2;
  }

  /// EaseInExpo for Phase C — much steeper than easeInQuad, so the
  /// plane sits relatively still through the early part of the
  /// fly-off and then EXPLODES toward the viewport edge in the last
  /// ~300 ms. Reads as the slingshot RELEASING. Standard CSS form:
  ///   t == 0 ? 0 : pow(2, 10*t - 10)
  double _easeInExpo(double t) {
    if (t <= 0.0) return 0.0;
    if (t >= 1.0) return 1.0;
    return math.pow(2.0, 10.0 * t - 10.0).toDouble();
  }

  /// Quadratic Bezier between three points at parameter [t].
  Offset _quadBezier(Offset p0, Offset p1, Offset p2, double t) {
    final double oneMinusT = 1.0 - t;
    return p0 * (oneMinusT * oneMinusT) +
        p1 * (2 * oneMinusT * t) +
        p2 * (t * t);
  }

  @override
  Widget build(BuildContext context) {
    // Phase-C exit point in viewport-global coords: well past the
    // right edge of the screen and high above the origin (plane gains
    // significant altitude as it leaves so the departure reads as a
    // dramatic skyward exit, not a horizontal skim). Captured at
    // build time off [viewportSize] so the exit point is stable
    // through the flight.
    final Offset exitPoint = Offset(
      viewportSize.width + _exitOvershoot,
      origin.dy + _exitClimb,
    );

    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final double t = controller.value.clamp(0.0, 1.0);

            Offset pos;
            double scale;
            double rotation;

            if (t <= _windUpEnd) {
              // Phase A: wind-up. Drift right with a soft ease so
              // the plane "settles" backward rather than jerking.
              // Also scales down 1.0 → 0.95 to suggest the plane is
              // being "loaded into the slingshot" — visually
              // distinct from a static hold.
              final double localT = t / _windUpEnd;
              final double eased = _easeInOutCubic(localT);
              pos = Offset(
                origin.dx + _windUpDx * eased,
                origin.dy,
              );
              scale = 1.0 + (_windUpScaleEnd - 1.0) * eased;
              // Tiny rightward tilt during wind-up — like the plane
              // is being aimed backward. ~5°.
              rotation = 0.08 * eased;
            } else if (t <= _leftReleaseEnd) {
              // Phase B: leftward release. Quadratic Bezier from
              // (origin + windUpDx, origin.dy) up-and-left to
              // (origin + leftReleaseEndOffset). Control point
              // pulled HARD LEFT-AND-UP so the arc bows OUTWARD
              // (more leftward than the chord from p0 to p2) — the
              // plane visibly sweeps left-then-up rather than
              // taking a soft diagonal.
              final double localT =
                  (t - _windUpEnd) / (_leftReleaseEnd - _windUpEnd);
              final double eased = _easeInOutCubic(localT);
              final Offset p0 = Offset(origin.dx + _windUpDx, origin.dy);
              final Offset p2 = origin + _leftReleaseEndOffset;
              // Control point: leftmost extent of the curl. Pulled
              // further left than p2 (origin.dx - 220 vs p2.dx =
              // origin.dx - 150) so the Bezier bows OUTSIDE the
              // chord and the leftward arc reads distinctly.
              final Offset p1 = Offset(
                origin.dx - 220,
                origin.dy - 110,
              );
              pos = _quadBezier(p0, p1, p2, eased);
              // Scale eases windUpScaleEnd (0.95) → leftReleaseScale
              // (1.4) — the plane "unloads" from the slingshot and
              // grows as it arcs.
              scale = _windUpScaleEnd +
                  (_leftReleaseScale - _windUpScaleEnd) * eased;
              // Tilt left as the plane curls up-left.
              // ~-25° (-0.45 rad) at end — more pronounced than the
              // prior -0.35 rad so the tilt matches the bigger arc.
              rotation = -0.45 * eased;
            } else {
              // Phase C: rightward exit + scale up. Quadratic Bezier
              // from (origin + leftReleaseEndOffset) up through a
              // control point ABOVE-AND-RIGHT of origin out to
              // exitPoint past the right edge. EaseInExpo so the
              // plane sits relatively still then EXPLODES away in
              // the last 300 ms — reads as the slingshot releasing.
              final double localT =
                  (t - _leftReleaseEnd) / (1.0 - _leftReleaseEnd);
              final double eased = _easeInExpo(localT);
              final Offset p0 = origin + _leftReleaseEndOffset;
              final Offset p2 = exitPoint;
              // Control point: higher and more forward than the
              // prior pass. Lifting p1 from (-220, +200) →
              // (-380, +280) makes the plane CLIMB more
              // aggressively through the exit, matching the
              // "skyward escape" framing.
              final Offset p1 = Offset(
                origin.dx + 280,
                origin.dy - 380,
              );
              pos = _quadBezier(p0, p1, p2, eased);
              // Scale grows aggressively across Phase C.
              // leftReleaseScale (1.4) → exitScale (3.0). The
              // "flying toward viewer" cue dominates the departure.
              scale = _leftReleaseScale +
                  (_exitScale - _leftReleaseScale) * eased;
              // Rotation swings from leftward-leaning (Phase B end)
              // back through level into a slight rightward-up tilt
              // as the plane commits to the exit vector.
              rotation = -0.45 + 0.70 * eased;
            }

            // Opacity: hold opaque through the whole flight. Fade
            // out gently in the last 5% so off-screen frames don't
            // get a sudden pop if timing is slightly off.
            final double opacity = t > 0.95
                ? ((1.0 - t) / 0.05).clamp(0.0, 1.0)
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
                        child: const Icon(
                          // Same glyph the submit button renders
                          // (Material `Icons.send` — a paper-plane
                          // silhouette), so the entity that lifts
                          // off reads as the button's own icon
                          // detaching.
                          Icons.send,
                          size: _glyphSize,
                          color: CustomColors.black,
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
