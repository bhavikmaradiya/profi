import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import './field_border_decoration.dart';
import './field_title.dart';
import '../app_models/drop_down_model.dart';
import '../config/theme_config.dart';
import '../const/dimens.dart';
import '../const/strings.dart';
import '../enums/color_enums.dart';
import '../utils/color_utils.dart';

class AppDropDownField extends StatefulWidget {
  final String title;
  final List<DropDownModel> dropDownItems;
  final Function(DropDownModel) onDropDownChanged;
  final DropDownModel? selectedItem;
  final bool isDisable;

  const AppDropDownField({
    Key? key,
    required this.title,
    required this.dropDownItems,
    required this.onDropDownChanged,
    this.selectedItem,
    this.isDisable = false,
  }) : super(key: key);

  @override
  State<AppDropDownField> createState() => _AppDropDownFieldState();
}

class _AppDropDownFieldState extends State<AppDropDownField> {
  DropDownModel? _selectedItem;

  @override
  void initState() {
    _selectedItem = widget.selectedItem;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant AppDropDownField oldWidget) {
    if (widget.selectedItem != oldWidget.selectedItem) {
      _selectedItem = widget.selectedItem;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final dropDownTextStyle = TextStyle(
      color: ColorUtils.getColor(
        context,
        ColorEnums.black33Color,
      ),
      fontSize: Dimens.dropDownFieldTextSize.sp,
      fontFamily: ThemeConfig.appFonts,
      overflow: TextOverflow.clip,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        FieldTitle(title: widget.title),
        SizedBox(
          height: Dimens.titleFieldVerticalPadding.h,
        ),
        SizedBox(
          height: Dimens.fieldHeight.h,
          child: InputDecorator(
            decoration: FieldBorderDecoration.fieldBorderDecoration(
              context,
              contentPadding: Dimens.fieldContentPadding.w,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<DropDownModel>(
                icon: SvgPicture.asset(
                  Strings.dropDownButton,
                ),
                isExpanded: true,
                value: _selectedItem,
                style: dropDownTextStyle,
                items: List.generate(
                  widget.dropDownItems.length,
                  (index) => DropdownMenuItem(
                    value: widget.dropDownItems[index],
                    child: Text(
                      widget.dropDownItems[index].value,
                      style: dropDownTextStyle,
                      maxLines: 1,
                    ),
                  ),
                ),
                onChanged: widget.isDisable
                    ? null
                    : (DropDownModel? selected) {
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
        ),
      ],
    );
  }

  OutlineInputBorder fieldBorder(BuildContext context) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(
          Dimens.fieldBorderRadius.r,
        ),
      ),
      borderSide: BorderSide(
        color: ColorUtils.getColor(
          context,
          ColorEnums.grayE0Color,
        ),
        width: Dimens.fieldBorderSize.w,
      ),
    );
  }
}
