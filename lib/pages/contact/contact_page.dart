import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import 'package:get/get.dart';

import '../../../utils/adaptive_layout.dart';
import '../../../utils/values/values.dart';
import '../../utils/values/spaces.dart';
import '../../widgets/animations/animated_positioned_text.dart';
import '../../widgets/animations/animated_text_slide_box_transition.dart';
import '../../widgets/buttons/animated_button.dart';
import '../../widgets/helper/custom_spacer.dart';
import '../../widgets/scaffolding/page_wrapper.dart';
import '../../widgets/scaffolding/simple_footer.dart';
import '../../widgets/text/custom_text_form_field.dart';

class Email {
  final String to;
  final Map<String, String> message;

  Email({
    required this.to,
    required this.message,
  });

  toJson() {
    return {
      'to': to,
      'message': message,
    };
  }
}

class ContactPage extends StatefulWidget {
  static const String contactPageRoute = StringConst.CONTACT_PAGE;
  const ContactPage({
    Key? key,
  }) : super(key: key);

  @override
  ContactPageState createState() => ContactPageState();
}

class ContactPageState extends State<ContactPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  bool isSendingEmail = false;
  bool isBodyVisible = false;
  bool _nameFilled = false;
  bool _emailFilled = false;
  bool _subjectFilled = false;
  bool _messageFilled = false;
  bool _nameHasError = false;
  bool _emailHasError = false;
  bool _subjectHasError = false;
  bool _messageHasError = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Animations.slideAnimationDurationLong,
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: const Offset(0, 0)).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.fastOutSlowIn),
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool isFormValid() {
    return _nameFilled && _subjectFilled && _messageFilled && _emailFilled;
  }

  bool isTextValid(String value) {
    if (value.isNotEmpty) {
      return true;
    }
    return false;
  }

  void isNameValid(String name) {
    bool isValid = isTextValid(name);
    setState(() {
      _nameFilled = isValid;
      _nameHasError = !isValid;
    });
  }

  void isEmailValid(String email) {
    bool isValid = GetUtils.isEmail(email);
    setState(() {
      _emailFilled = isValid;
      _emailHasError = !isValid;
    });
  }

  void isSubjectValid(String subject) {
    bool isValid = isTextValid(subject);
    setState(() {
      _subjectFilled = isValid;
      _subjectHasError = !isValid;
    });
  }

  void isMessageValid(String message) {
    bool isValid = isTextValid(message);
    setState(() {
      _messageFilled = isValid;
      _messageHasError = !isValid;
    });
  }

  void clearText() {
    _nameController.text = "";
    _emailController.text = "";
    _subjectController.text = "";
    _messageController.text = "";
  }

  Future<void> _handleFirestoreOperation({
    required String operationName,
    String? successMessage,
    String? customErrorMessage,
    required Future<void> Function() projectOperation,
  }) async {
    try {
      await projectOperation();
    } catch (error) {
      Get.snackbar(
        '$operationName failed',
        customErrorMessage == null ? '$error' : '$customErrorMessage: $error',
        snackPosition: SnackPosition.BOTTOM,
        borderRadius: 4,
        margin: const EdgeInsets.all(0),
        backgroundColor: Colors.red,
      );
      if (kDebugMode) {
        String message = customErrorMessage == null ? '$error' : '$customErrorMessage: $error';
        print('Snackbar dialog: $operationName has failed $message');
      }

      return;
    }
  }

  Future<void> sendEmail() async {
    if (isFormValid()) {
      setState(() {
        isSendingEmail = true;
      });

      await _handleFirestoreOperation(
        operationName: 'Sending Email',
        successMessage: 'Your e-Mail has been sent!',
        projectOperation: () async {
          if (kDebugMode) {
            print(
              'sending:\nname: ${_nameController.text}, '
              'email: ${_emailController.text}, '
              'subject: ${_subjectController.text}, '
              'message: ${_messageController.text}',
            );
          }

          // 'subject': "from ${_nameController.text} with this email: ${_emailController.text}, "
          // "${_subjectController.text}",

          await FirebaseFirestore.instance.collection('mail').doc().set({
            'to': 'burakbasci98@gmail.com',
            'message': {
              'html': '',
              'subject': _subjectController.text,
              'text': '${_nameController.text} (${_emailController.text}) '
                  'sent you an e-Mail from your website:\n\n'
                  '${_messageController.text}',
            },
          });
        },
      );

      setState(() {
        isSendingEmail = false;
      });
      clearText();
    } else {
      isNameValid(_nameController.text);
      isEmailValid(_emailController.text);
      isSubjectValid(_subjectController.text);
      isMessageValid(_messageController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final TextStyle? initialErrorStyle = textTheme.bodyText1?.copyWith(
      color: AppColors.white,
      fontSize: Sizes.TEXT_SIZE_12,
    );
    final TextStyle? errorStyle = textTheme.bodyText1?.copyWith(
      color: AppColors.errorRed,
      fontWeight: FontWeight.w400,
      fontSize: Sizes.TEXT_SIZE_12,
      letterSpacing: 1,
    );
    final double contentAreaWidth = responsiveSize(
      context,
      assignWidth(context, 0.8),
      assignWidth(context, 0.6),
    ); //takes 60% of screen

    final double buttonWidth = responsiveSize(
      context,
      contentAreaWidth * 0.6,
      contentAreaWidth * 0.25,
    );
    final EdgeInsetsGeometry padding = EdgeInsets.only(
      left: responsiveSize(
        context,
        assignWidth(context, 0.10),
        assignWidth(context, 0.15),
      ),
      right: responsiveSize(
        context,
        assignWidth(context, 0.10),
        assignWidth(context, 0.25),
      ),
      top: responsiveSize(
        context,
        assignHeight(context, 0.24),
        assignHeight(context, 0.28),
      ),
    );
    final TextStyle? headingStyle = textTheme.headline2?.copyWith(
      color: AppColors.black,
      fontSize: responsiveSize(context, 40, 60),
    );
    return PageWrapper(
      selectedRoute: ContactPage.contactPageRoute,
      selectedPageName: StringConst.CONTACT,
      navigationBarAnimationController: _controller,
      onLoadingAnimationDone: () {
        _controller.forward();
      },
      child: ListView(
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        children: <Widget>[
          Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                AnimatedTextSlideBoxTransition(
                  controller: _controller,
                  text: StringConst.GET_IN_TOUCH,
                  textStyle: headingStyle,
                ),
                const CustomSpacer(heightFactor: 0.05),
                AnimatedPositionedText(
                  width: contentAreaWidth,
                  controller: CurvedAnimation(
                    parent: _controller,
                    curve: const Interval(0.6, 1.0, curve: Curves.fastOutSlowIn),
                  ),
                  text: StringConst.CONTACT_MSG,
                  maxLines: 5,
                  textStyle: textTheme.bodyText1?.copyWith(
                    color: AppColors.grey700,
                    height: 2.0,
                    fontSize: responsiveSize(
                      context,
                      Sizes.TEXT_SIZE_16,
                      Sizes.TEXT_SIZE_18,
                    ),
                  ),
                ),
                const CustomSpacer(heightFactor: 0.06),
                SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: <Widget>[
                      CustomTextFormField(
                        hasTitle: _nameHasError,
                        title: StringConst.NAME_ERROR_MSG,
                        titleStyle: _nameHasError ? errorStyle : initialErrorStyle,
                        labelText: StringConst.YOUR_NAME,
                        controller: _nameController,
                        filled: _nameFilled,
                        onChanged: (value) {
                          isNameValid(value);
                        },
                      ),
                      const SpaceH20(),
                      CustomTextFormField(
                        hasTitle: _emailHasError,
                        title: StringConst.EMAIL_ERROR_MSG,
                        titleStyle: _emailHasError ? errorStyle : initialErrorStyle,
                        labelText: StringConst.EMAIL,
                        controller: _emailController,
                        filled: _emailFilled,
                        onChanged: (value) {
                          isEmailValid(value);
                        },
                      ),
                      const SpaceH20(),
                      CustomTextFormField(
                        hasTitle: _subjectHasError,
                        title: StringConst.SUBJECT_ERROR_MSG,
                        titleStyle: _subjectHasError ? errorStyle : initialErrorStyle,
                        labelText: StringConst.SUBJECT,
                        controller: _subjectController,
                        filled: _subjectFilled,
                        onChanged: (value) {
                          isSubjectValid(value);
                        },
                      ),
                      const SpaceH20(),
                      CustomTextFormField(
                        hasTitle: _messageHasError,
                        title: StringConst.MESSAGE_ERROR_MSG,
                        titleStyle: _messageHasError ? errorStyle : initialErrorStyle,
                        labelText: StringConst.MESSAGE,
                        controller: _messageController,
                        filled: _messageFilled,
                        textInputType: TextInputType.multiline,
                        maxLines: 10,
                        onChanged: (value) {
                          isMessageValid(value);
                        },
                      ),
                      const SpaceH20(),
                      Align(
                        alignment: Alignment.topRight,
                        child: AnimatedButton(
                          height: Sizes.HEIGHT_56,
                          width: buttonWidth,
                          isLoading: isSendingEmail,
                          title: StringConst.SEND_MESSAGE.toUpperCase(),
                          onPressed: sendEmail,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const CustomSpacer(heightFactor: 0.22),
          const SimpleFooter(),
        ],
      ),
    );
  }
}
