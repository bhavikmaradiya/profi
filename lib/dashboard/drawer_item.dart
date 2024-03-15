import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import './bloc/dashboard_bloc.dart';
import './model/dashboard_drawer_menu.dart';
import '../const/dimens.dart';
import '../const/strings.dart';
import '../enums/color_enums.dart';
import '../enums/user_role_enums.dart';
import '../utils/app_utils.dart';
import '../utils/color_utils.dart';

class DrawerItem extends StatelessWidget {
  final Function onCloseIconClicked;
  final Function(DashboardDrawerMenu) onMenuClicked;

  const DrawerItem({
    Key? key,
    required this.onCloseIconClicked,
    required this.onMenuClicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _headerWidget(context, appLocalizations),
            _dividerWidget(context),
            _profileInfoWidget(
              context,
              appLocalizations,
            ),
            _menuWidget(),
          ],
        ),
      ),
    );
  }

  Widget _headerWidget(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        left: Dimens.screenHorizontalMargin.w,
        right: (Dimens.screenHorizontalMargin / 3).w,
        top: Dimens.drawerContentVerticalPadding.h,
        bottom: Dimens.drawerContentVerticalPadding.h,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            appLocalizations.appName,
            style: TextStyle(
              fontSize: Dimens.drawerHeaderTextSize.sp,
              color: ColorUtils.getColor(
                context,
                ColorEnums.black1AColor,
              ),
              fontWeight: FontWeight.w700,
            ),
          ),
          InkWell(
            onTap: () {
              onCloseIconClicked();
            },
            borderRadius: BorderRadius.circular(
              (Dimens.drawerCloseIconSize * 3).w,
            ),
            child: SizedBox(
              width: (Dimens.drawerCloseIconSize * 3).w,
              height: (Dimens.drawerCloseIconSize * 3).w,
              child: Padding(
                padding: EdgeInsets.all(
                  Dimens.drawerCloseIconSize.w,
                ),
                child: SvgPicture.asset(
                  Strings.close,
                  colorFilter: ColorFilter.mode(
                    ColorUtils.getColor(
                      context,
                      ColorEnums.gray99Color,
                    ),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dividerWidget(BuildContext context) {
    return Divider(
      height: 0,
      color: ColorUtils.getColor(
        context,
        ColorEnums.grayE0Color,
      ),
    );
  }

  Widget _profileInfoWidget(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      buildWhen: (previous, current) =>
          previous != current && current is ProfileAndMenuInfoGeneratedState,
      builder: (context, state) {
        if (state is ProfileAndMenuInfoGeneratedState) {
          final profileInfo = state.profileInfo;
          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: Dimens.screenHorizontalMargin.w,
              vertical: Dimens.drawerContentVerticalPadding.h,
            ),
            color: ColorUtils.getColor(
              context,
              ColorEnums.grayF5Color,
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: ColorUtils.getColor(
                        context,
                        ColorEnums.grayE0Color,
                      ),
                      width: Dimens.drawerProfileContentBorderSize.w,
                    ),
                    borderRadius: BorderRadius.circular(
                      Dimens.drawerProfileContentRadius.r,
                    ),
                    color: ColorUtils.getColor(
                      context,
                      ColorEnums.whiteColor,
                    ),
                  ),
                  padding: EdgeInsets.all(
                    Dimens.drawerProfileInitialsTextPadding.w,
                  ),
                  child: Text(
                    AppUtils.getInitials(profileInfo.name ?? '').toUpperCase(),
                    style: TextStyle(
                      color: ColorUtils.getColor(
                        context,
                        ColorEnums.gray99Color,
                      ),
                      fontWeight: FontWeight.w700,
                      fontSize: Dimens.drawerProfileInitialsTextSize.sp,
                    ),
                  ),
                ),
                SizedBox(
                  width: Dimens.drawerProfileContentPadding.w,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profileInfo.name ?? '',
                        style: TextStyle(
                          color: ColorUtils.getColor(
                            context,
                            ColorEnums.black00Color,
                          ),
                          fontWeight: FontWeight.w700,
                          fontSize: Dimens.drawerProfileNameTextSize.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                      ),
                      SizedBox(
                        height: Dimens.drawerProfileNameRoleSpacing.h,
                      ),
                      Text(
                        profileInfo.role == UserRoleEnum.admin.name
                            ? appLocalizations.admin
                            : profileInfo.role ==
                                    UserRoleEnum.projectManager.name
                                ? appLocalizations.projectManager
                                : profileInfo.role == UserRoleEnum.bdm.name
                                    ? appLocalizations.bdm
                                    : '',
                        style: TextStyle(
                          color: ColorUtils.getColor(
                            context,
                            ColorEnums.gray6CColor,
                          ),
                          fontSize: Dimens.drawerProfileRoleTextSize.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _menuWidget() {
    return BlocBuilder<DashboardBloc, DashboardState>(
      buildWhen: (previous, current) =>
          previous != current && current is ProfileAndMenuInfoGeneratedState,
      builder: (context, state) {
        if (state is ProfileAndMenuInfoGeneratedState) {
          final menus = state.menus;
          return ListView.separated(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            separatorBuilder: (BuildContext context, int index) {
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimens.drawerMenuSeparatorHorizontalPadding.w,
                ),
                child: Divider(
                  height: 0,
                  color: ColorUtils.getColor(
                    context,
                    ColorEnums.grayE0Color,
                  ),
                ),
              );
            },
            itemBuilder: (context, index) {
              final menu = menus[index];
              return InkWell(
                onTap: () {
                  onMenuClicked(menu);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimens.screenHorizontalMargin.w,
                    vertical: Dimens.drawerContentVerticalPadding.h,
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        menu.iconPath,
                        width: Dimens.drawerMenuIconSize.w,
                        height: Dimens.drawerMenuIconSize.w,
                        colorFilter: ColorFilter.mode(
                          ColorUtils.getColor(
                            context,
                            ColorEnums.black33Color,
                          ),
                          BlendMode.srcIn,
                        ),
                      ),
                      SizedBox(
                        width: Dimens.drawerMenuIconTextSpacing.w,
                      ),
                      Text(
                        menu.name,
                        style: TextStyle(
                          color: ColorUtils.getColor(
                            context,
                            ColorEnums.black00Color,
                          ),
                          fontSize: Dimens.drawerMenuTextSize.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                      ),
                    ],
                  ),
                ),
              );
            },
            itemCount: menus.length,
          );
        }
        return const SizedBox();
      },
    );
  }
}
