import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../config/theme_config.dart';
import '../const/dimens.dart';
import '../const/strings.dart';
import '../enums/color_enums.dart';
import '../utils/color_utils.dart';

class ToolBar extends StatelessWidget {
  final String title;
  final Function? onFilterClearAll;
  final Function? onInwardSearch;

  const ToolBar({
    Key? key,
    required this.title,
    this.onFilterClearAll,
    this.onInwardSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: ColorUtils.getColor(
              context,
              ColorEnums.black33Color,
            ).withOpacity(0.10),
            offset: Offset(
              0,
              Dimens.containerShadowYCoordinates.h,
            ),
            blurRadius: Dimens.containerShadowRadius.r,
          ),
        ],
        color: ColorUtils.getColor(
          context,
          ColorEnums.whiteColor,
        ),
      ),
      child: AppBar(
        backgroundColor: ColorUtils.getColor(
          context,
          ColorEnums.whiteColor,
        ),
        surfaceTintColor: ColorUtils.getColor(
          context,
          ColorEnums.whiteColor,
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(
            Dimens.hamburgerIconRippleRadius.r,
          ),
          child: UnconstrainedBox(
            child: SvgPicture.asset(
              Strings.backButton,
            ),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: ColorUtils.getColor(
              context,
              ColorEnums.black33Color,
            ),
            fontWeight: FontWeight.w700,
            fontSize: Dimens.homeTitleTextSize.sp,
            fontFamily: ThemeConfig.appFonts,
          ),
        ),
        actions: [
          if (onFilterClearAll != null)
            InkWell(
              onTap: () {
                onFilterClearAll!();
              },
              borderRadius: BorderRadius.circular(
                Dimens.filterClearAllRippleRadius.r,
              ),
              child: _filterClearAllWidget(
                context,
                appLocalizations,
              ),
            ),
          if (onInwardSearch != null)
            InkWell(
              onTap: () {
                onInwardSearch!();
              },
              borderRadius: BorderRadius.circular(
                Dimens.inwardSearchIconRippleRadius.r,
              ),
              child: _inwardSearchWidget(
                appLocalizations,
              ),
            ),
        ],
      ),
    );
  }

  Widget _filterClearAllWidget(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return Padding(
      padding: EdgeInsets.all(
        Dimens.filterClearAllTextPadding.w,
      ),
      child: Text(
        appLocalizations.clearAll,
        style: TextStyle(
          color: ColorUtils.getColor(
            context,
            ColorEnums.black1AColor,
          ),
          fontWeight: FontWeight.w500,
          fontSize: Dimens.filterClearAllTextSize.sp,
        ),
      ),
    );
  }

  Widget _inwardSearchWidget(AppLocalizations appLocalizations) {
    return UnconstrainedBox(
      child: Padding(
        padding: EdgeInsets.all(
          Dimens.inwardSearchIconPadding.w,
        ),
        child: SvgPicture.asset(
          Strings.search,
          width: Dimens.inwardSearchIconSize.w,
          height: Dimens.inwardSearchIconSize.h,
        ),
      ),
    );
  }
}
