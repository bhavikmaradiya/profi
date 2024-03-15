import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app_widgets/min_width_container.dart';
import '../../const/dimens.dart';
import '../../const/strings.dart';
import '../../enums/color_enums.dart';
import '../../profile/model/profile_info.dart';
import '../../routes.dart';
import '../../utils/app_utils.dart';
import '../../utils/color_utils.dart';

class UserListItem extends StatelessWidget {
  final ProfileInfo profileInfo;

  const UserListItem({
    Key? key,
    required this.profileInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.screenHorizontalMargin.w,
        vertical: Dimens.userListItemVerticalSpace.h,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _userAvtarWidget(context),
          SizedBox(
            width: Dimens.projectListItemContentSpacing.w,
          ),
          Expanded(
            child: _userNameAndRoleWidget(
              context,
              appLocalizations,
            ),
          ),
          SizedBox(
            width: Dimens.projectListItemContentSpacing.w,
          ),
          _userActionWidget(
            context,
            appLocalizations,
          ),
        ],
      ),
    );
  }

  Widget _userAvtarWidget(BuildContext context) {
    return CircleAvatar(
      backgroundColor: ColorUtils.getColor(
        context,
        ColorEnums.black33Color,
      ),
      radius: Dimens.projectListProjectTypeCircleRadius.r,
      child: Text(
        AppUtils.getInitials(profileInfo.name ?? '').toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: ColorUtils.getColor(
            context,
            ColorEnums.whiteColor,
          ),
          fontWeight: FontWeight.w700,
          fontSize: Dimens.userListAvtarTextSize.sp,
        ),
      ),
    );
  }

  Widget _userNameAndRoleWidget(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          profileInfo.name ?? '',
          style: TextStyle(
            fontSize: Dimens.projectListProjectNameTextSize.sp,
            color: ColorUtils.getColor(
              context,
              ColorEnums.black33Color,
            ),
            overflow: TextOverflow.clip,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
        ),
        SizedBox(
          height: Dimens.projectListProjectStartDateTopSpacing.h,
        ),
        RichText(
          text: TextSpan(
            text: '${appLocalizations.userRole}: ',
            style: TextStyle(
              color: ColorUtils.getColor(
                context,
                ColorEnums.gray6CColor,
              ),
              fontSize: Dimens.projectListProjectStartDateTextSize.sp,
            ),
            children: [
              TextSpan(
                text: AppUtils.getUserRoleString(
                  appLocalizations,
                  profileInfo.role ?? '',
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  _buildActionButton(
    BuildContext context, {
    required String icon,
    required String title,
    bool isLeftCornerRounded = true,
    required Function onTap,
    ColorEnums backgroundColor = ColorEnums.whiteColor,
    ColorEnums iconColor = ColorEnums.gray6CColor,
  }) {
    return MinWidthContainer(
      minWidth: Dimens.userListActionBlockMinWidth.w,
      child: Container(
        decoration: BoxDecoration(
          color: ColorUtils.getColor(context, backgroundColor),
          border: Border(
            left: BorderSide(
              color: ColorUtils.getColor(
                context,
                ColorEnums.grayE0Color,
              ),
              width: isLeftCornerRounded
                  ? Dimens.userListActionBorderSize.w
                  : (Dimens.userListActionBorderSize / 2).w,
            ),
            right: BorderSide(
              color: ColorUtils.getColor(
                context,
                ColorEnums.grayE0Color,
              ),
              width: !isLeftCornerRounded
                  ? Dimens.userListActionBorderSize.w
                  : (Dimens.userListActionBorderSize / 2).w,
            ),
            top: BorderSide(
              color: ColorUtils.getColor(
                context,
                ColorEnums.grayE0Color,
              ),
              width: Dimens.userListActionBorderSize.w,
            ),
            bottom: BorderSide(
              color: ColorUtils.getColor(
                context,
                ColorEnums.grayE0Color,
              ),
              width: Dimens.userListActionBorderSize.w,
            ),
          ),
          borderRadius: isLeftCornerRounded
              ? BorderRadius.only(
                  topLeft: Radius.circular(
                    Dimens.userListActionBorderRadius.r,
                  ),
                  bottomLeft: Radius.circular(
                    Dimens.userListActionBorderRadius.r,
                  ),
                )
              : BorderRadius.only(
                  topRight: Radius.circular(
                    Dimens.userListActionBorderRadius.r,
                  ),
                  bottomRight: Radius.circular(
                    Dimens.userListActionBorderRadius.r,
                  ),
                ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onTap(),
            borderRadius: isLeftCornerRounded
                ? BorderRadius.only(
                    topLeft: Radius.circular(
                      Dimens.userListActionBorderRadius.r,
                    ),
                    bottomLeft: Radius.circular(
                      Dimens.userListActionBorderRadius.r,
                    ),
                  )
                : BorderRadius.only(
                    topRight: Radius.circular(
                      Dimens.userListActionBorderRadius.r,
                    ),
                    bottomRight: Radius.circular(
                      Dimens.userListActionBorderRadius.r,
                    ),
                  ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Dimens.userListActionBlockHorizontalPadding.w,
                vertical: Dimens.userListActionBlockVerticalPadding.h,
              ),
              child: Column(
                children: [
                  SvgPicture.asset(
                    icon,
                    width: Dimens.userListActionIconSize.w,
                    height: Dimens.userListActionIconSize.w,
                    colorFilter: ColorFilter.mode(
                      ColorUtils.getColor(
                        context,
                        iconColor,
                      ),
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(
                    height: Dimens.userListActionTextTopSpacing.h,
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      color: ColorUtils.getColor(
                        context,
                        ColorEnums.black33Color,
                      ),
                      fontSize: Dimens.userListActionTextSize.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _userActionWidget(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return Row(
      children: [
        _buildActionButton(
          context,
          icon: Strings.edit,
          title: appLocalizations.edit,
          onTap: () {
            Navigator.pushNamed(
              context,
              Routes.addUser,
              arguments: profileInfo,
            );
          },
          isLeftCornerRounded: true,
          iconColor: ColorEnums.gray6CColor,
        ),
        _buildActionButton(
          context,
          icon: Strings.delete,
          title: appLocalizations.delete,
          onTap: () {},
          isLeftCornerRounded: false,
          backgroundColor: ColorEnums.redFDF3F3Color,
          iconColor: ColorEnums.redColor,
        ),
      ],
    );
  }
}
