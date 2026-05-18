import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/values/values.dart';

/// Inline-validated text input used on the contact form.
///
/// The widget is stateful so it can:
///   * track whether the field has been touched, and only auto-validate
///     after the user has finished editing (no "invalid email" mid-typing);
///   * surface the parent's [errorText] label above the field when the
///     [validator] returns non-null;
///   * keep the lightGreen "valid" fill until the next edit or until the
///     parent calls `FormState.reset()` (which clears the controller and
///     resets the internal touched flag via the controller listener).
class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    this.controller,
    this.labelText,
    this.errorText,
    this.textInputType,
    this.validator,
    this.maxLines = 1,
    super.key,
  });

  final TextEditingController? controller;
  final String? labelText;

  /// Long, user-friendly error label shown above the field when validation
  /// fails (e.g. "* Please enter a valid email"). The field-level red text
  /// inside the [TextFormField] is suppressed via [InputDecoration.errorStyle]
  /// so this label is the only error surface.
  final String? errorText;

  final TextInputType? textInputType;
  final FormFieldValidator<String>? validator;
  final int? maxLines;

  static const UnderlineInputBorder primaryInputBorder = UnderlineInputBorder(
    borderSide: BorderSide(
      color: CustomColors.grey,
      width: Sizes.WIDTH_1,
      style: BorderStyle.solid,
    ),
  );

  static const UnderlineInputBorder enabledBorder = UnderlineInputBorder(
    borderSide: BorderSide(
      color: CustomColors.grey,
      width: Sizes.WIDTH_2,
      style: BorderStyle.solid,
    ),
  );

  static const UnderlineInputBorder focusedBorder = UnderlineInputBorder(
    borderSide: BorderSide(
      color: CustomColors.black,
      width: Sizes.WIDTH_2,
      style: BorderStyle.solid,
    ),
  );

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  final FocusNode _focusNode = FocusNode();
  String? _currentError;
  bool _hasInteracted = false;
  String? _lastSeenText;

  @override
  void initState() {
    super.initState();
    _lastSeenText = widget.controller?.text ?? '';
    _focusNode.addListener(_handleFocusChange);
    widget.controller?.addListener(_handleControllerChange);
  }

  @override
  void didUpdateWidget(covariant CustomTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChange);
      widget.controller?.addListener(_handleControllerChange);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    widget.controller?.removeListener(_handleControllerChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    // Only validate on blur after the user actually interacted with the
    // field. This gives us "validate on unfocus" UX so the email field
    // does not flash "invalid email" while the user is still typing.
    if (!_focusNode.hasFocus && _hasInteracted) {
      setState(() {
        _currentError = widget.validator?.call(widget.controller?.text);
      });
    }
  }

  void _handleControllerChange() {
    final String text = widget.controller?.text ?? '';
    // Detect external reset: when the parent calls FormState.reset() the
    // controller is cleared back to ''. In that case drop our interaction
    // state so the outline returns to neutral (no more lightGreen fill,
    // no error label).
    if (text.isEmpty && (_lastSeenText?.isNotEmpty ?? false)) {
      setState(() {
        _hasInteracted = false;
        _currentError = null;
      });
    }
    _lastSeenText = text;
  }

  bool get _isValid =>
      _hasInteracted &&
      _currentError == null &&
      (widget.controller?.text.trim().isNotEmpty ?? false);

  @override
  Widget build(BuildContext context) {
    final TextStyle? errorLabelStyle = Get.textTheme.bodyLarge?.copyWith(
      color: CustomColors.errorRed,
      fontWeight: FontWeight.w400,
      fontSize: Sizes.TEXT_SIZE_12,
      letterSpacing: 1,
    );
    final bool showErrorLabel = _currentError != null && widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: Sizes.TEXT_SIZE_18,
          child: showErrorLabel
              ? Text(widget.errorText!, style: errorLabelStyle)
              : const SizedBox(),
        ),
        TextFormField(
          style: Get.textTheme.bodyLarge?.copyWith(
            color: CustomColors.black,
            fontWeight: FontWeight.w400,
          ),
          controller: widget.controller,
          focusNode: _focusNode,
          keyboardType: widget.textInputType,
          maxLines: widget.maxLines,
          onChanged: (value) {
            if (!_hasInteracted) {
              _hasInteracted = true;
            }
            // Wipe any stale error as soon as the user types — they will
            // re-validate on blur or on the next submit.
            if (_currentError != null) {
              setState(() {
                _currentError = null;
              });
            }
          },
          validator: (value) {
            final String? message = widget.validator?.call(value);
            // Defer the visible-state update until after this validation
            // frame so we do not call setState during a build pass.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              if (_currentError != message) {
                setState(() {
                  _currentError = message;
                  _hasInteracted = true;
                });
              }
            });
            return message;
          },
          decoration: InputDecoration(
            fillColor: CustomColors.lightGreen,
            filled: _isValid,
            labelText: widget.labelText,
            labelStyle: Get.textTheme.bodyLarge?.copyWith(
              color: CustomColors.black100,
            ),
            border: CustomTextFormField.primaryInputBorder,
            enabledBorder: CustomTextFormField.enabledBorder,
            focusedBorder: CustomTextFormField.focusedBorder,
            // Hide the built-in red error text — the long error label above
            // the field is our only error surface.
            errorStyle: const TextStyle(height: 0, fontSize: 0),
            hintStyle: Get.textTheme.bodyLarge?.copyWith(
              color: CustomColors.black100,
            ),
          ),
        ),
      ],
    );
  }
}
