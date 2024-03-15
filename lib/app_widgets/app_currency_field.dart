import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import './app_text_field.dart';
import '../app_models/drop_down_model.dart';
import '../config/app_config.dart';
import '../config/theme_config.dart';
import '../const/dimens.dart';
import '../const/strings.dart';
import '../enums/color_enums.dart';
import '../utils/app_utils.dart';
import '../utils/color_utils.dart';
import '../utils/decimal_text_input_formatter.dart';

class AppCurrencyField extends StatefulWidget {
  final String title;
  final List<DropDownModel> dropDownItems;
  final Function(String) onTextChanged;
  final Function(DropDownModel) onDropDownChanged;
  final DropDownModel? selectedItem;
  final int inputLengthLimit;
  final TextInputAction? keyboardAction;
  final TextEditingController? textEditingController;
  final FocusNode? focusNode;

  const AppCurrencyField({
    Key? key,
    required this.title,
    required this.dropDownItems,
    required this.onDropDownChanged,
    required this.onTextChanged,
    this.selectedItem,
    this.inputLengthLimit = AppConfig.amountInputLengthLimit,
    this.keyboardAction,
    this.textEditingController,
    this.focusNode,
  }) : super(key: key);

  @override
  State<AppCurrencyField> createState() => _AppCurrencyFieldState();
}

class _AppCurrencyFieldState extends State<AppCurrencyField> {
  DropDownModel? _selectedItem;

  @override
  void initState() {
    _selectedItem = widget.selectedItem;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final dropDownTextStyle = TextStyle(
      color: ColorUtils.getColor(
        context,
        ColorEnums.black33Color,
      ),
      fontSize: Dimens.currencyDropDownFieldTextSize.sp,
      overflow: TextOverflow.clip,
      fontWeight: FontWeight.w500,
      fontFamily: ThemeConfig.notoSans,
    );
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        AppTextField(
          title: widget.title,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
          ),
          keyboardAction: widget.keyboardAction,
          focusNode: widget.focusNode,
          inputFormatter: [
            FilteringTextInputFormatter.deny(AppUtils.regexToDenyComma),
            LengthLimitingTextInputFormatter(widget.inputLengthLimit),
            DecimalTextInputFormatter(
              decimalRange: AppConfig.decimalTextFieldInputLength,
            ),
          ],
          textEditingController: widget.textEditingController,
          onTextChange: (totalAmount) {
            widget.onTextChanged(totalAmount);
          },
        ),
        Positioned(
          top: (Dimens.fieldHeight / 1.75).h,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<DropDownModel>(
              icon: SvgPicture.asset(
                Strings.dropDownButton,
              ),
              value: _selectedItem,
              padding: EdgeInsets.only(
                right: Dimens.fieldContentPadding.w,
              ),
              selectedItemBuilder: (context) {
                return widget.dropDownItems.map<Widget>((DropDownModel item) {
                  return Center(
                    child: Text(
                      '${item.value} ',
                      style: dropDownTextStyle.copyWith(
                        color: ColorUtils.getColor(
                          context,
                          ColorEnums.gray99Color,
                        ),
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                    ),
                  );
                }).toList();
              },
              items: List.generate(
                widget.dropDownItems.length,
                (index) => DropdownMenuItem<DropDownModel>(
                  value: widget.dropDownItems[index],
                  child: Text(
                    widget.dropDownItems[index].value,
                    style: dropDownTextStyle,
                    maxLines: 1,
                  ),
                ),
              ),
              onChanged: (DropDownModel? selected) {
                if (selected != null) {
                  widget.onDropDownChanged(selected);
                }
                setState(() {
                  _selectedItem = selected;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
