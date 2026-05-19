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
  // separately so we can fire it the moment the success card mounts
  // (the page-level [_controller] has already finished its entry
  // animation by then).
  late AnimationController _successCardController;
  // Drives the cascade exit animation of the form fields — each
  // _FormField slot reads its own slice of this controller (staggered
  // by index) to fade + slide upward as it leaves. Starts at 0
  // (everything visible), animates to 1 (everything gone).
  late AnimationController _formExitController;
  // Drives the celebration paper-plane that lifts off the submit
  // button's send-icon position and arcs upward into the success-card
  // headline area. Held on its own controller so it can SPAN the
  // boundary between "form still cascading out" and "success card
  // appearing" — the plane needs to be in flight while both
  // transitions overlap, so a separate timeline keeps each phase
  // honest. 0 = at rest at button icon, 1 = arrived at success card
  // headline.
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
  // GlobalKey on the _ContactSwapArea — the parent coordinate space
  // we translate the button-icon's global position INTO so the plane
  // can be Positioned in the swap area's local frame.
  final GlobalKey _swapAreaKey = GlobalKey();
  // Resolved on the frame the plane launches: the icon's center in
  // the swap area's local coordinates. Null while the plane is not
  // in flight.
  Offset? _planeOrigin;
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
      // (~40ms per char + tail), the underline draw, the body fade
      // and the paper-plane arc.
      duration: const Duration(milliseconds: 2600),
    );
    _formExitController = AnimationController(
      vsync: this,
      // 5 staggered slots × 80ms stagger + 280ms per slot ≈ 680ms total.
      duration: const Duration(milliseconds: 680),
    );
    // Plane-flight duration. 1100ms feels right: long enough to read
    // as a deliberate arc (the user's eye follows it), short enough
    // that it lands close to when the success-card headline begins
    // resolving. Curve + arc geometry are inside [_PaperPlaneArc].
    _planeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _planeController.addStatusListener((status) {
      // Once the plane has landed, drop the in-flight flag. We do NOT
      // restore [iconOpacity] on the button — by this point the
      // form's cascade has long since hidden the whole button anyway
      // (its slot has opacity 0 + IgnorePointer), and the success
      // card is on-stage. Flipping the flag back lets the next idle
      // send (e.g. if the user navigates back and submits again)
      // start with a visible icon.
      if (status == AnimationStatus.completed && mounted) {
        setState(() {
          _planeInFlight = false;
        });
      }
    });
    super.initState();
  }

  /// Resolves the submit button's send-icon position in the
  /// [_swapAreaKey] widget's local coordinate space. Returns null if
  /// either render box isn't ready yet (defensive — by the time this
  /// runs the layout has long since settled). Reading the position
  /// via [RenderBox.localToGlobal] + [RenderBox.globalToLocal] is the
  /// only way to be precise about WHERE the icon sits inside the
  /// centered text+icon Row, which depends on the rendered text
  /// width (button-title length, font metrics, breakpoint).
  Offset? _resolveButtonIconOrigin() {
    final RenderObject? iconRO =
        _buttonIconKey.currentContext?.findRenderObject();
    final RenderObject? swapRO =
        _swapAreaKey.currentContext?.findRenderObject();
    if (iconRO is! RenderBox || swapRO is! RenderBox) return null;
    if (!iconRO.hasSize || !swapRO.hasSize) return null;
    // Icon's center in global (screen) coords, then translated back
    // into the swap area's local frame.
    final Offset iconCenterGlobal =
        iconRO.localToGlobal(iconRO.size.center(Offset.zero));
    return swapRO.globalToLocal(iconCenterGlobal);
  }

  @override
  void dispose() {
    _statusResetTimer?.cancel();
    _successCardSwapTimer?.cancel();
    _formExitTimer?.cancel();
    _planeLaunchTimer?.cancel();
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
      // visible (in case a previous celebration left state behind)
      // and clears any stale plane origin so an aborted run can't
      // resurrect a ghost plane on the next send.
      _planeInFlight = false;
      _planeOrigin = null;
    });

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
          // drop the banner here so the button morph + page reward
          // are the only "you did it" cues during the swap.
          _bannerMessage = null;
          _bannerColor = CustomColors.lightGreen;
          _successPulseKey++;
        });
        // Reward choreography:
        //   t=0     button morphs spinner→check and pulses
        //   t=600   cascade exit starts: each field fades + slides up
        //           in a wave, ~80ms stagger over 280ms each (≈680ms
        //           total)
        //   t=920   paper plane LAUNCHES from the submit button's
        //           send-icon position. The button is at cascade slot
        //           index 4 (name/email/subject/message/button on the
        //           success path — no banner), so its 80ms-stagger
        //           window opens at 600 + 4*80 = 920ms. The button's
        //           own icon is hidden the instant the plane launches
        //           (iconOpacity → 0) so the plane reads as the
        //           detached send-glyph rather than a second one.
        //   t=1280  form is gone — flip _showSuccessCard so the form
        //           is offstage and the success card takes its slot
        //           in the Stack. _formExitController is reset.
        //   t=1280  success card controller starts: headline reveals
        //           letter-by-letter, underline draws, body fades in.
        //   t≈2020  plane arrives at the success-card headline area
        //           (920 + 1100ms plane span) — right as the headline
        //           is mid-reveal, so the arrival is the visual cue
        //           "your message is delivered, here's the receipt".
        _successCardSwapTimer?.cancel();
        _formExitTimer?.cancel();
        _planeLaunchTimer?.cancel();
        _successCardSwapTimer = Timer(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          _formExitController.forward(from: 0);
        });
        _planeLaunchTimer = Timer(const Duration(milliseconds: 920), () {
          if (!mounted) return;
          // Resolve the button-icon's position in swap-area-local
          // coordinates RIGHT before launch (positions are stable
          // here — the button has only just started fading; layout
          // hasn't shifted). If either render box is gone (shouldn't
          // happen, but belt-and-braces), bail without launching
          // rather than spawn the plane at (0,0).
          final Offset? origin = _resolveButtonIconOrigin();
          if (origin == null) return;
          setState(() {
            _planeOrigin = origin;
            _planeInFlight = true;
          });
          _planeController.forward(from: 0);
        });
        _formExitTimer = Timer(const Duration(milliseconds: 1280), () {
          if (!mounted) return;
          setState(() {
            _showSuccessCard = true;
          });
          // Fire the success-card reveal once the card is on-stage.
          // The post-frame callback waits for the Stack to actually
          // build the success-card subtree. Calling forward(from: 0)
          // before the first build leaves the embedded
          // flutter_animate chains paused at value=0 (no effect).
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _successCardController.forward(from: 0);
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
      case _SendStatus.success:
        return Tr.of('contact.button.sent').toUpperCase();
      case _SendStatus.error:
        return Tr.of('contact.button.retry').toUpperCase();
      case _SendStatus.sending:
      case _SendStatus.idle:
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
                      child: _ContactSwapArea(
                        key: _swapAreaKey,
                        showSuccessCard: _showSuccessCard,
                        planeController: _planeController,
                        planeOrigin: _planeOrigin,
                        planeInFlight: _planeInFlight,
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
                          // plane is in flight — the plane IS the
                          // button's icon detaching.
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
        // 1.06 → 1.0 over 260ms — pairs with the spinner→check
        // morph inside the button to give a "Sent!" micro-reward.
        // Keyed off [successPulseKey] so each successful send
        // re-fires it; the pulse is otherwise a no-op (idle/
        // sending/error never bump the key).
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
            icon: isSuccess
                ? Icons.check
                : status == _SendStatus.error
                    ? Icons.refresh
                    : Icons.send,
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
class _ContactSwapArea extends StatelessWidget {
  const _ContactSwapArea({
    super.key,
    required this.showSuccessCard,
    required this.formFields,
    required this.successCard,
    required this.planeController,
    required this.planeOrigin,
    required this.planeInFlight,
  });

  final bool showSuccessCard;
  final Widget formFields;
  final Widget successCard;

  /// Drives the celebration paper-plane that lifts off the submit
  /// button and arcs into the success-card headline area. Owned by
  /// [ContactPageState].
  final AnimationController planeController;

  /// The plane's origin point in this Stack's local coordinate space.
  /// Resolved by the parent the moment the plane launches (reads the
  /// submit button's icon RenderBox via GlobalKey, translates through
  /// this Stack's RenderBox). Null while no plane is in flight.
  final Offset? planeOrigin;

  /// True while the plane is mid-flight. Used to mount the plane only
  /// for the duration of the animation — the widget is otherwise not
  /// in the tree, so it can't render at a stale origin between sends.
  final bool planeInFlight;

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
        // [successCardController] (chained delays inside _SuccessCard),
        // so we don't need an outer opacity transition here.
        if (showSuccessCard) successCard,
        // Paper-plane — lives at the OUTER stack so its origin
        // (button icon, near the bottom of the form area) and target
        // (success-card headline area, near the top) span the full
        // swap area. Only mounted while [planeInFlight] is true so
        // it can't peek through at idle. The plane reads its origin
        // from [planeOrigin] (the button-icon's center in this
        // Stack's local frame, resolved at launch time via
        // RenderBox + GlobalKey by the parent).
        if (planeInFlight && planeOrigin != null)
          _PaperPlaneArc(
            controller: planeController,
            origin: planeOrigin!,
          ),
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
/// The celebration paper-plane (see [_PaperPlaneArc]) is NOT mounted
/// inside this card — it lives at the outer [_ContactSwapArea] Stack
/// so its origin (the submit button at the BOTTOM of the form) and
/// its destination (the headline at the TOP of this card) can span
/// the full swap-area height. Mounting it here would have constrained
/// it to the card's own bounds and made the launch look like it
/// "spawned in empty space" near the headline.
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
    // content (MainAxisSize.min). The plane composite that used to
    // overlay the headline has moved up to [_ContactSwapArea] so its
    // origin can be anchored on the button (which lives in the form
    // column, NOT in this card).
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

/// The celebration paper-plane.
///
/// Lifts off the submit button's send-icon (at [origin], in the parent
/// [_ContactSwapArea] Stack's local coordinate space) and arcs UP-AND-
/// LEFT into the success-card headline area. Driven by a dedicated
/// 0→1 controller in [ContactPageState] that fires the instant the
/// button's cascade-exit slot begins fading — so the plane visibly
/// detaches from the icon the user just clicked rather than spawning
/// somewhere in empty space.
///
/// Visual identity: same [Icons.send] glyph the submit button renders,
/// at the same [Sizes.ICON_SIZE_16] size. Only the color differs
/// (black here vs. white on the dark button) because the plane is
/// now over the page background.
class _PaperPlaneArc extends StatelessWidget {
  const _PaperPlaneArc({
    required this.controller,
    required this.origin,
  });

  final AnimationController controller;

  /// Pixel-perfect launch point: the submit button's send-icon
  /// center, expressed in the parent Stack's local coordinate frame.
  /// Resolved at launch time via [RenderBox.localToGlobal] +
  /// [RenderBox.globalToLocal] (see
  /// [ContactPageState._resolveButtonIconOrigin]).
  final Offset origin;

  // Match the submit button's icon size exactly (Sizes.ICON_SIZE_16,
  // 16px) so the entity that lifts off reads as the same glyph the
  // visitor just clicked.
  static const double _glyphSize = Sizes.ICON_SIZE_16;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        // Need the swap area's bounds to know where to LAND. Inner
        // LayoutBuilder reads the Stack's loose constraints (set by
        // the form's natural size — the Stack's size-determining
        // child), giving us the swap area's current dimensions.
        return LayoutBuilder(
          builder: (context, constraints) {
            // `constraints.biggest` is the swap area's bounds — the
            // parent Stack passes the form's natural size down to
            // its non-positioned children. If the constraints aren't
            // bounded (defensive — shouldn't happen here), fall back
            // to a conservative size so the plane still flies
            // somewhere reasonable rather than NaN-ing.
            final Size swapSize = constraints.biggest.isFinite
                ? constraints.biggest
                : const Size(600, 400);
            // Landing point: just inside the headline's leading edge,
            // a touch below its baseline so the "delivery receipt"
            // arrival reads as the plane settling onto the headline.
            // 18% from the left works at both breakpoints since the
            // headline is left-aligned and roughly the same fraction
            // of the column width either way. 70 logical px puts the
            // glyph inside the headline's vertical band (font 56-96).
            final Offset target = Offset(swapSize.width * 0.18, 70);

            final double progress = controller.value.clamp(0.0, 1.0);
            // easeInOutCubic — gentle lift-off, accelerates mid-arc,
            // settles softly. Reads as a paper plane catching air.
            final double eased = progress < 0.5
                ? 4 * progress * progress * progress
                : 1 -
                    math.pow(-2 * progress + 2, 3).toDouble() / 2;

            // Parabola bow ABOVE the straight line between origin
            // and target — so the plane lifts UP (above either
            // endpoint) before descending into the headline. Without
            // the bow, the path would be a straight diagonal which
            // reads as "icon teleported" rather than "icon flew".
            final double parabola =
                4 * eased * (1 - eased); // 0 → 1 → 0 across the flight
            final double flightDistance =
                (target - origin).distance.clamp(120.0, 600.0);
            // Bow scales with flight distance so a long arc looks
            // arched and a short arc still curls — never flattens.
            final double bow = flightDistance * 0.18;

            final double x = origin.dx + (target.dx - origin.dx) * eased;
            final double y =
                origin.dy + (target.dy - origin.dy) * eased - bow * parabola;

            // Rotation: align the plane with its instantaneous
            // direction of travel. Material's `Icons.send` glyph
            // already noses up-and-right at rest, so we offset by
            // -π/4 (the glyph's intrinsic 45° tilt) and add the
            // straight-line travel angle so the visible nose tracks
            // the trajectory. Small sine wobble adds life.
            final double travelAngle = math.atan2(
              target.dy - origin.dy,
              target.dx - origin.dx,
            );
            final double rotation =
                travelAngle - math.pi / 4 + 0.08 * math.sin(eased * math.pi);

            // Fade in over first 12% — long enough to mask the
            // instant the button-icon's opacity flips to 0, but
            // short enough that the plane is visible while still
            // near the button (the launch reads as continuous).
            // Hold opaque through the body of the flight, fade out
            // over the last 20% so the plane melts into the
            // headline area rather than clunking to a stop.
            double opacity;
            if (eased < 0.12) {
              opacity = eased / 0.12;
            } else if (eased > 0.80) {
              opacity = ((1 - eased) / 0.20).clamp(0.0, 1.0);
            } else {
              opacity = 1.0;
            }

            // Position via Transform.translate — the plane is a
            // direct child of the swap-area Stack, so an unbounded
            // Positioned would conflict with the Stack's loose
            // sizing. Center the glyph on (x, y).
            return Transform.translate(
              offset: Offset(x - _glyphSize / 2, y - _glyphSize / 2),
              child: Opacity(
                opacity: opacity,
                child: Transform.rotate(
                  angle: rotation,
                  child: const IgnorePointer(
                    child: Icon(
                      // Same glyph the submit button renders
                      // (Material `Icons.send` — a paper-plane
                      // silhouette), so the entity that arcs off
                      // reads as the button's own icon detaching.
                      // See [AnimatedButton] in
                      // lib/widgets/buttons/animated_button.dart.
                      Icons.send,
                      size: _glyphSize,
                      color: CustomColors.black,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
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
