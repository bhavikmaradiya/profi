import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../const/dimens.dart';
import '../const/strings.dart';
import '../enums/color_enums.dart';
import '../utils/color_utils.dart';

class AppSearchView extends StatelessWidget {
  final VoidCallback onCloseSearch;
  final Function(String) onTextChange;

  const AppSearchView({
    Key? key,
    required this.onCloseSearch,
    required this.onTextChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    return ColoredBox(
      color: ColorUtils.getColor(
        context,
        ColorEnums.whiteColor,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              autofocus: true,
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
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: appLocalizations.search,
                hintStyle: TextStyle(
                  fontSize: Dimens.dialogNoteHintTextSize.sp,
                  color: ColorUtils.getColor(
                    context,
                    ColorEnums.grayA8Color,
                  ),
                ),
                fillColor: ColorUtils.getColor(
                  context,
                  ColorEnums.whiteColor,
                ),
                border: InputBorder.none,
              ),
              onChanged: (value) {
                onTextChange(value);
              },
            ),
          ),
          Material(
            color: ColorUtils.getColor(
              context,
              ColorEnums.transparentColor,
            ),
            child: InkWell(
              onTap: () {
                onCloseSearch();
              },
              borderRadius: BorderRadius.circular(
                Dimens.filterClearAllRippleRadius.r,
              ),
              child: _closeSearchWidget(
                context,
                appLocalizations,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _closeSearchWidget(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return UnconstrainedBox(
      child: Padding(
        padding: EdgeInsets.all(
          Dimens.inwardSearchIconPadding.w,
        ),
        child: SvgPicture.asset(
          Strings.close,
          width: Dimens.inwardSearchIconSize.w,
          height: Dimens.inwardSearchIconSize.h,
          colorFilter: ColorFilter.mode(
            ColorUtils.getColor(
              context,
              ColorEnums.black33Color,
            ),
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
