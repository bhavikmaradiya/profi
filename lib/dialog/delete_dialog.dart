import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:profi/const/strings.dart';

import '../app_widgets/app_outline_button.dart';
import '../const/dimens.dart';
import '../enums/color_enums.dart';
import '../utils/color_utils.dart';

class DeleteDialog extends StatelessWidget {
  final String message;
  final VoidCallback onCancelClick;
  final VoidCallback onDeleteClick;

  const DeleteDialog({
    Key? key,
    required this.message,
    required this.onDeleteClick,
    required this.onCancelClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        Dimens.deleteDialogContentPadding.w,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(
            Dimens.dialogRadius.r,
          ),
        ),
        color: ColorUtils.getColor(
          context,
          ColorEnums.whiteColor,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: Dimens.deleteDialogIconCircleSize.r,
            backgroundColor: ColorUtils.getColor(
              context,
              ColorEnums.redColor,
            ).withOpacity(0.05),
            child: SvgPicture.asset(
              Strings.deleteDialog,
              width: Dimens.deleteDialogIconSize.w,
              height: Dimens.deleteDialogIconSize.w,
            ),
          ),
          SizedBox(
            height: Dimens.deleteDialogContentPadding.h,
          ),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: Dimens.deleteDialogMessageTextSize.sp,
              fontWeight: FontWeight.w500,
              color: ColorUtils.getColor(
                context,
                ColorEnums.black33Color,
              ),
            ),
          ),
          SizedBox(
            height: Dimens.deleteDialogContentPadding.h,
          ),
          Row(
            children: [
              Expanded(
                child: AppOutlineButton(
                  title: appLocalizations.yesSure,
                  bgColor: ColorUtils.getColor(context, ColorEnums.redColor)
                      .withOpacity(0.05),
                  textColorEnum: ColorEnums.redColor,
                  borderColor: ColorEnums.redColor,
                  onButtonPressed: () {
                    onDeleteClick();
                  },
                ),
              ),
              SizedBox(
                width: Dimens.deleteDialogContentPadding.w,
              ),
              Expanded(
                child: AppOutlineButton(
                  title: appLocalizations.cancel,
                  onButtonPressed: () {
                    onCancelClick();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
