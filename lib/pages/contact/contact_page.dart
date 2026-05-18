import 'package:burak_basci_website/widgets/text/self_positioning_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import 'package:get/get.dart';

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
    super.key,
  });

  @override
  ContactPageState createState() => ContactPageState();
}

class ContactPageState extends State<ContactPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
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
    _controller = AnimationController(vsync: this);
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
    return PageWrapper(
      selectedRoute: ContactPage.contactPageRoute,
      selectedPageName: StringConst.CONTACT,
      navigationBarAnimationController: _controller,
      onLoadingAnimationDone: () {
        // Cover/uncover transition is the entry animation; snap content
        // controllers straight to their final state.
        _controller.value = 1;
      },
      child: ListView(
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        children: <Widget>[
          LayoutBuilder(builder: (context, constraints) {
            final TextStyle? initialErrorStyle = Get.textTheme.bodyLarge?.copyWith(
              color: CustomColors.white,
              fontSize: Sizes.TEXT_SIZE_12,
            );
            final TextStyle? errorStyle = Get.textTheme.bodyLarge?.copyWith(
              color: CustomColors.errorRed,
              fontWeight: FontWeight.w400,
              fontSize: Sizes.TEXT_SIZE_12,
              letterSpacing: 1,
            );
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
                    child: Column(
                      children: <Widget>[
                        CustomTextFormField(
                          hasTitle: _nameHasError,
                          title: Tr.of('contact.name_error'),
                          titleStyle: _nameHasError ? errorStyle : initialErrorStyle,
                          labelText: Tr.of('contact.your_name'),
                          controller: _nameController,
                          filled: _nameFilled,
                          onChanged: (value) {
                            isNameValid(value);
                          },
                        ),
                        const SpaceH20(),
                        CustomTextFormField(
                          hasTitle: _emailHasError,
                          title: Tr.of('contact.email_error'),
                          titleStyle: _emailHasError ? errorStyle : initialErrorStyle,
                          labelText: Tr.of('contact.email_label'),
                          controller: _emailController,
                          filled: _emailFilled,
                          onChanged: (value) {
                            isEmailValid(value);
                          },
                        ),
                        const SpaceH20(),
                        CustomTextFormField(
                          hasTitle: _subjectHasError,
                          title: Tr.of('contact.subject_error'),
                          titleStyle: _subjectHasError ? errorStyle : initialErrorStyle,
                          labelText: Tr.of('contact.subject'),
                          controller: _subjectController,
                          filled: _subjectFilled,
                          onChanged: (value) {
                            isSubjectValid(value);
                          },
                        ),
                        const SpaceH20(),
                        CustomTextFormField(
                          hasTitle: _messageHasError,
                          title: Tr.of('contact.message_error'),
                          titleStyle: _messageHasError ? errorStyle : initialErrorStyle,
                          labelText: Tr.of('contact.message_label'),
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
                            title: Tr.of('contact.send_message').toUpperCase(),
                            onPressed: sendEmail,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          const CustomSpacer(heightFactor: 0.22),
          const BottomPartFooter(),
        ],
      ),
    );
  }
}
