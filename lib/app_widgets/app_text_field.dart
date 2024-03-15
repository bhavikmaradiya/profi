import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import './field_border_decoration.dart';
import './field_title.dart';
import '../const/dimens.dart';
import '../enums/color_enums.dart';
import '../keyboard_action/keyboard_actions.dart';
import '../utils/color_utils.dart';

class AppTextField extends StatelessWidget {
  final String? title;
  final TextEditingController? textEditingController;
  final TextInputType? keyboardType;
  final TextInputAction? keyboardAction;
  final Function(String value) onTextChange;
  final bool isPassword;
  final bool autoFocus;
  final Widget? suffixIcon;
  final bool isMultiLine;
  final double maxLine;
  final bool isReadOnly;
  final bool isEnabled;
  final List<TextInputFormatter>? inputFormatter;
  final String? hint;
  final TextStyle? hintStyle;
  final ColorEnums? fieldBgColor;
  final FocusNode? focusNode;

  const AppTextField({
    Key? key,
    required this.title,
    required this.onTextChange,
    this.textEditingController,
    this.keyboardType,
    this.keyboardAction,
    this.autoFocus = false,
    this.isPassword = false,
    this.suffixIcon,
    this.isMultiLine = false,
    this.maxLine = 1,
    this.isReadOnly = false,
    this.inputFormatter,
    this.hint,
    this.hintStyle,
    this.fieldBgColor,
    this.focusNode,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (title != null) FieldTitle(title: title!),
        SizedBox(
          height: Dimens.titleFieldVerticalPadding.h,
        ),
        SizedBox(
          height: isMultiLine
              ? (Dimens.fieldHeight * maxLine).h
              : Dimens.fieldHeight.h,
          child: KeyboardActions(
            tapOutsideBehavior: TapOutsideBehavior.none,
            disableScroll: true,
            enable: keyboardType == TextInputType.number ||
                keyboardType == TextInputType.phone ||
                keyboardType == const TextInputType.numberWithOptions() ||
                keyboardType ==
                    const TextInputType.numberWithOptions(
                      decimal: true,
                    ) ||
                inputFormatter != null &&
                    (inputFormatter!.contains(
                          FilteringTextInputFormatter.allow(
                            RegExp(
                              "[0-9]",
                            ),
                          ),
                        ) ||
                        inputFormatter!.contains(
                          FilteringTextInputFormatter.digitsOnly,
                        )),
            config: KeyboardActionsConfig(
              nextFocus: false,
              keyboardBarElevation: 0,
              keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
              actions: [
                KeyboardActionsItem(
                  focusNode: focusNode ?? FocusNode(canRequestFocus: false),
                  displayArrows: false,
                  displayDoneButton: true,
                ),
              ],
            ),
            child: TextField(
              autofocus: autoFocus,
              obscureText: isPassword,
              maxLines: isMultiLine ? 3 : 1,
              readOnly: isReadOnly,
              enabled: isEnabled,
              enableInteractiveSelection: !isReadOnly,
              inputFormatters: inputFormatter,
              focusNode: focusNode,
              style: TextStyle(
                color: ColorUtils.getColor(
                  context,
                  ColorEnums.black33Color,
                ),
                fontSize: Dimens.fieldsTextSize.sp,
              ),
              cursorColor: ColorUtils.getColor(
                context,
                ColorEnums.black33Color,
              ),
              cursorWidth: 1,
              controller: textEditingController,
              keyboardType: keyboardType ?? TextInputType.text,
              textInputAction: keyboardAction ?? TextInputAction.done,
              decoration: FieldBorderDecoration.fieldBorderDecoration(
                context,
                contentPadding: Dimens.fieldContentPadding.w,
                isMultiLine: isMultiLine,
                suffixIcon: suffixIcon,
                hint: hint,
                hintStyle: hintStyle,
                fillColor: isEnabled
                    ? (fieldBgColor ?? ColorEnums.whiteColor)
                    : ColorEnums.grayF5Color,
              ),
              onChanged: (value) {
                onTextChange(value);
              },
            ),
          ),
        ),
      ],
    );
  }
}
