import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../add_project/model/project_info.dart';
import '../../const/dimens.dart';
import '../../const/strings.dart';
import '../../enums/color_enums.dart';
import '../../routes.dart';
import '../../utils/color_utils.dart';
import '../project_operations_bloc/project_operations_bloc.dart';

class ProjectOperations extends StatelessWidget {
  final ProjectInfo projectInfo;
  final VoidCallback onDeleteProjectClick;

  const ProjectOperations({
    Key? key,
    required this.projectInfo,
    required this.onDeleteProjectClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        color: ColorUtils.getColor(
          context,
          ColorEnums.black00Color,
        ).withOpacity(0.6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _operationItem(
              context,
              Strings.inward,
            ),
            SizedBox(
              width: Dimens.projectListOperationContentPadding.w,
            ),
            _operationItem(
              context,
              Strings.edit,
            ),
            SizedBox(
              width: Dimens.projectListOperationContentPadding.w,
            ),
            _operationItem(
              context,
              Strings.delete,
            ),
            SizedBox(
              width: Dimens.projectListOperationContentPadding.w,
            ),
            _operationItem(
              context,
              Strings.close,
            ),
          ],
        ),
      ),
    );
  }

  Widget _operationItem(
    BuildContext context,
    String icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: ColorUtils.getColor(
            context,
            ColorEnums.grayE0Color,
          ),
        ),
      ),
      child: InkWell(
        onTap: () {
          BlocProvider.of<ProjectOperationsBloc>(
            context,
            listen: false,
          ).add(ProjectOperationCompleteEvent());
          if (icon == Strings.inward) {
            Navigator.pushNamed(
              context,
              Routes.inwardTransactions,
              arguments: projectInfo.projectId,
            );
          } else if (icon == Strings.edit) {
            Navigator.pushNamed(
              context,
              Routes.addEditProject,
              arguments: projectInfo.projectId,
            );
          } else if (icon == Strings.delete) {
            onDeleteProjectClick();
          }
        },
        borderRadius: BorderRadius.circular(
          Dimens.projectListOperationInnerCircleSize.r,
        ),
        child: CircleAvatar(
          backgroundColor: ColorUtils.getColor(
            context,
            ColorEnums.black33Color,
          ).withOpacity(0.3),
          radius: Dimens.projectListOperationInnerCircleSize.r,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Dimens.projectListOperationCirclePadding.w,
              vertical: Dimens.projectListOperationCirclePadding.w,
            ),
            child: SvgPicture.asset(
              icon,
              width: double.infinity,
              height: double.infinity,
              colorFilter: ColorFilter.mode(
                ColorUtils.getColor(
                  context,
                  ColorEnums.whiteColor,
                ),
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
