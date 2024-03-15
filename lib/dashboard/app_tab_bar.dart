import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../config/app_config.dart';
import '../config/theme_config.dart';
import '../const/dimens.dart';
import '../const/strings.dart';
import '../enums/color_enums.dart';
import '../project_list/fetch_projects_bloc/firebase_fetch_projects_bloc.dart';
import '../utils/color_utils.dart';

class AppTabBar extends StatelessWidget {
  final TabController? tabController;
  final int tabLength;
  final int selectedTabIndex;
  final AppLocalizations appLocalizations;

  const AppTabBar({
    Key? key,
    required this.tabController,
    required this.selectedTabIndex,
    required this.tabLength,
    required this.appLocalizations,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fetchProjectsBlocProvider =
        BlocProvider.of<FirebaseFetchProjectsBloc>(
      context,
      listen: false,
    );

    final appTabs = [
      appLocalizations.tabHome,
      appLocalizations.tabAll,
      appLocalizations.tabAmber,
      appLocalizations.tabRed,
      if (AppConfig.isTempTabEnabled) appLocalizations.tabTemp,
    ];

    const homeTabWidthPercentage = 0.1;
    final otherTabsWidthPercentage = (1 - 0.1) / (appTabs.length - 1);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: ColorUtils.getColor(
                context,
                ColorEnums.black33Color,
              ).withOpacity(0.15),
              offset: Offset(
                0,
                Dimens.containerShadowYCoordinates.h,
              ),
              blurRadius: Dimens.containerShadowRadius.r,
            ),
          ],
          color: Colors.white,
        ),
        child: TabBar(
          isScrollable: true,
          controller: tabController,
          unselectedLabelColor: ColorUtils.getColor(
            context,
            ColorEnums.gray6CColor,
          ),
          labelColor: ColorUtils.getColor(
            context,
            ColorEnums.black33Color,
          ),
          labelStyle: TextStyle(
            fontSize: Dimens.tabTextSize.sp,
            fontWeight: FontWeight.w500,
            fontFamily: ThemeConfig.appFonts,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: Dimens.tabTextSize.sp,
            fontWeight: FontWeight.w500,
            fontFamily: ThemeConfig.appFonts,
          ),
          indicatorWeight: Dimens.tabIndicatorHeight.h,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorColor: ColorUtils.getColor(
            context,
            ColorEnums.black33Color,
          ),
          labelPadding: EdgeInsets.zero,
          tabs: List.generate(
            tabLength,
            (index) {
              if (appTabs[index] == appLocalizations.tabHome) {
                return SizedBox(
                  width: homeTabWidthPercentage *
                      MediaQuery.of(context).size.width,
                  child: Tab(
                    iconMargin: EdgeInsets.zero,
                    child: SvgPicture.asset(
                      Strings.home,
                      width: Dimens.tabHomeIconSize.w,
                      height: Dimens.tabHomeIconSize.w,
                      colorFilter: ColorFilter.mode(
                        selectedTabIndex != 0
                            ? ColorUtils.getColor(
                                context, ColorEnums.gray99Color)
                            : ColorUtils.getColor(
                                context, ColorEnums.black33Color),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                );
              } else if (appTabs[index] == appLocalizations.tabAll) {
                return BlocBuilder<FirebaseFetchProjectsBloc,
                    FirebaseFetchProjectsState>(
                  buildWhen: (previous, current) =>
                      previous != current &&
                          current is FirebaseFetchProjectsEmptyState ||
                      current is FirebaseFetchProjectsDataState ||
                      current is FilterChangedState,
                  builder: (context, state) {
                    int count =
                        fetchProjectsBlocProvider.getAllProjects().length;
                    return SizedBox(
                      width: otherTabsWidthPercentage *
                          MediaQuery.of(context).size.width,
                      child: Tab(
                        iconMargin: EdgeInsets.zero,
                        text: count <= 0
                            ? appTabs[index]
                            : '${appTabs[index]} ($count)',
                      ),
                    );
                  },
                );
              } else if (appTabs[index] == appLocalizations.tabTemp) {
                return SizedBox(
                  width: otherTabsWidthPercentage *
                      MediaQuery.of(context).size.width,
                  child: Tab(
                    iconMargin: EdgeInsets.zero,
                    text: appTabs[index],
                  ),
                );
              } else {
                return BlocBuilder<FirebaseFetchProjectsBloc,
                    FirebaseFetchProjectsState>(
                  buildWhen: (previous, current) =>
                      previous != current &&
                          current is FirebaseFetchProjectsEmptyState ||
                      current is FirebaseFetchProjectsDataState ||
                      current is FirebaseMilestoneInfoChangedState ||
                      current is FilterChangedState,
                  builder: (context, state) {
                    int count = 0;
                    if (appTabs[index] == appLocalizations.tabRed) {
                      count = fetchProjectsBlocProvider.getRedProjects().length;
                    } else if (appTabs[index] == appLocalizations.tabAmber) {
                      count =
                          fetchProjectsBlocProvider.getOrangeProjects(shouldExcludeInvoiced: true).length;
                    }
                    return SizedBox(
                      width: otherTabsWidthPercentage *
                          MediaQuery.of(context).size.width,
                      child: Tab(
                        iconMargin: EdgeInsets.zero,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(appTabs[index]),
                            if (count > 0)
                              SizedBox(
                                width: Dimens.tabTextCountSpacing.w,
                              ),
                            if (count > 0)
                              CircleAvatar(
                                radius: Dimens.tabCountCircleSize.r,
                                backgroundColor: ColorUtils.getColor(
                                  context,
                                  appTabs[index] == appLocalizations.tabRed
                                      ? ColorEnums.redColor
                                      : ColorEnums.amberF59032Color,
                                ),
                                child: Text(
                                  '$count',
                                  style: TextStyle(
                                    color: ColorUtils.getColor(
                                      context,
                                      ColorEnums.whiteColor,
                                    ),
                                    fontWeight: FontWeight.w700,
                                    fontSize: Dimens.tabCountTextSize.sp,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
