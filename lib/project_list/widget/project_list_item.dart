import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import './project_milestone_item.dart';
import './project_operations.dart';
import '../../add_project/model/milestone_info.dart';
import '../../add_project/model/project_info.dart';
import '../../config/app_config.dart';
import '../../const/dimens.dart';
import '../../const/strings.dart';
import '../../dialog/delete_dialog.dart';
import '../../dialog/show_dialog_utils.dart';
import '../../enums/color_enums.dart';
import '../../enums/payment_status_enum.dart';
import '../../enums/project_status_enum.dart';
import '../../enums/project_type_enum.dart';
import '../../utils/app_utils.dart';
import '../../utils/color_utils.dart';
import '../fetch_projects_bloc/firebase_fetch_projects_bloc.dart';
import '../project_operations_bloc/project_operations_bloc.dart';
import '../utils/milestone_utils.dart';

class ProjectListItem extends StatelessWidget {
  final ProjectInfo projectInfo;
  final bool isNeedToShowOperationsView;
  final PaymentStatusEnum? showRemainingDaysFor;
  final FirebaseFetchProjectsBloc firebaseFetchProjectsBloc;

  const ProjectListItem({
    Key? key,
    required this.projectInfo,
    required this.isNeedToShowOperationsView,
    this.showRemainingDaysFor,
    required this.firebaseFetchProjectsBloc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Dimens.screenHorizontalMargin.w,
            vertical: Dimens.projectListItemVerticalSpace.h,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _projectTypeAndCodeWidget(context),
              SizedBox(
                width: Dimens.projectListItemContentSpacing.w,
              ),
              Expanded(
                child: _projectNameAndStartDateWidget(
                  context,
                  appLocalizations,
                ),
              ),
              SizedBox(
                width: Dimens.projectListItemContentSpacing.w,
              ),
              _projectMilestoneOverview(
                context,
                appLocalizations,
              ),
            ],
          ),
        ),
        if (isNeedToShowOperationsView)
          Positioned.fill(
            child: Material(
              color: ColorUtils.getColor(
                context,
                ColorEnums.transparentColor,
              ),
              child: ProjectOperations(
                projectInfo: projectInfo,
                onDeleteProjectClick: () {
                  _deleteProjectConfirmationDialog(
                    context,
                    appLocalizations.sureToDeleteProject,
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _projectTypeAndCodeWidget(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: ColorUtils.getColor(
            context,
            ColorEnums.black33Color,
          ),
          radius: Dimens.projectListProjectTypeCircleRadius.r,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Dimens.projectListProjectTypeIconHorizontalSpace.w,
              vertical: Dimens.projectListProjectTypeIconVerticalSpace.h,
            ),
            child: SvgPicture.asset(
              getProjectTypeIcon(),
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
        if (projectInfo.projectCode != null)
          SizedBox(
            height: Dimens.projectListProjectCodeTopSpacing.h,
          ),
        if (projectInfo.projectCode != null)
          Text(
            '#${(projectInfo.projectCode!.length > AppConfig.projectCodeMaxLength) ? projectInfo.projectCode!.substring(0, AppConfig.projectCodeMaxLength) : projectInfo.projectCode}',
            style: TextStyle(
              color: ColorUtils.getColor(
                context,
                ColorEnums.gray6CColor,
              ),
              fontWeight: FontWeight.w700,
              fontSize: Dimens.projectListProjectCodeTextSize.sp,
              overflow: TextOverflow.clip,
            ),
          ),
      ],
    );
  }

  Widget _projectNameAndStartDateWidget(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          projectInfo.projectName ?? '',
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
            text: '${appLocalizations.started}: ',
            style: TextStyle(
              color: ColorUtils.getColor(
                context,
                ColorEnums.gray6CColor,
              ),
              fontSize: Dimens.projectListProjectStartDateTextSize.sp,
            ),
            children: [
              TextSpan(
                text: projectInfo.projectStartDate != null
                    ? DateFormat(AppConfig.projectStartDateFormat).format(
                        DateTime.fromMillisecondsSinceEpoch(
                          projectInfo.projectStartDate!,
                        ),
                      )
                    : '-',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: Dimens.projectListProjectStartDateTopSpacing.h,
        ),
        BlocBuilder<FirebaseFetchProjectsBloc, FirebaseFetchProjectsState>(
          buildWhen: (prev, current) =>
              prev != current && current is FirebaseBDMInfoChangedState,
          builder: (context, state) {
            final bdmName = firebaseFetchProjectsBloc
                    .getBdmInfoById(projectInfo.bdmUserId)
                    ?.name ??
                '-';
            return RichText(
              text: TextSpan(
                text: '${appLocalizations.projectListBd} ',
                style: TextStyle(
                  color: ColorUtils.getColor(
                    context,
                    ColorEnums.gray6CColor,
                  ),
                  fontSize: Dimens.projectListProjectStartDateTextSize.sp,
                ),
                children: [
                  TextSpan(
                    text: bdmName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        if (projectInfo.projectStatus != ProjectStatusEnum.active.name)
          SizedBox(
            height: Dimens.projectListProjectStartDateTopSpacing.h,
          ),
        if (projectInfo.projectStatus != ProjectStatusEnum.active.name)
          Text(
            projectInfo.projectStatus == ProjectStatusEnum.onHold.name
                ? appLocalizations.onHold
                : projectInfo.projectStatus == ProjectStatusEnum.closed.name
                    ? appLocalizations.closed
                    : projectInfo.projectStatus ==
                            ProjectStatusEnum.dropped.name
                        ? appLocalizations.dropped
                        : '',
            style: TextStyle(
              fontSize: Dimens.projectListProjectStatusTextSize.sp,
              color: ColorUtils.getColor(
                context,
                projectInfo.projectStatus == ProjectStatusEnum.onHold.name
                    ? ColorEnums.projectOnHoldColor
                    : projectInfo.projectStatus == ProjectStatusEnum.closed.name
                        ? ColorEnums.projectClosedColor
                        : projectInfo.projectStatus ==
                                ProjectStatusEnum.dropped.name
                            ? ColorEnums.projectDroppedColor
                            : ColorEnums.gray6CColor,
              ),
              fontWeight: FontWeight.w600,
              overflow: TextOverflow.clip,
            ),
            maxLines: 1,
          ),
      ],
    );
  }

  Widget _projectMilestoneOverview(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return BlocBuilder<FirebaseFetchProjectsBloc, FirebaseFetchProjectsState>(
      buildWhen: (previous, current) =>
          previous != current && current is FirebaseMilestoneInfoChangedState,
      builder: (context, state) {
        if (state is FirebaseMilestoneInfoChangedState) {
          final projectMilestones = state.milestones
              .where(
                (element) => element.projectId == projectInfo.projectId,
              )
              .toList();
          if (projectMilestones.isEmpty) {
            return IntrinsicHeight(
              child: Row(
                children: [
                  ProjectMilestoneItem(
                    isLeftCornerRounded: true,
                    darkText: '',
                    lightText: '',
                    isNeedToAddMilestone: true,
                    onMilestoneClick: () {
                      // show add new milestone dialog
                      ShowDialogUtils.showUpdateMilestoneDialog(
                        context: context,
                        appLocalizations: appLocalizations,
                        projectInfo: projectInfo,
                        milestoneInfo: null,
                        isNewMilestoneToAdd: true,
                      );
                    },
                  ),
                  ProjectMilestoneItem(
                    isRightCornerRounded: true,
                    darkText: AppUtils.removeTrailingZero(
                      projectInfo.receivedAmount,
                    ),
                    lightText:
                        firebaseFetchProjectsBloc.getTotalMilestoneAmount(
                      projectInfo,
                    ),
                    blockBgColor: getProjectColorEnum(),
                    onMilestoneClick: () {
                      if (_isProjectHasMilestones(projectInfo)) {
                        ShowDialogUtils.showPaidUnPaidDialog(
                          context: context,
                          appLocalizations: appLocalizations,
                          projectInfo: projectInfo,
                          milestoneInfo: null,
                          isOnlyPaidOperation: true,
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          }
          MilestoneInfo milestoneInfo = projectMilestones.first;
          final nearestIndex = MilestoneUtils.getFocusedMilestoneIndex(
            projectMilestones,
          );
          if (nearestIndex != (-1)) {
            milestoneInfo = projectMilestones[nearestIndex];
          }
          final isNeedToAddMilestone = isAllMilestoneCompleted(
            projectMilestones,
          );
          final isMultipleAmountPending =
              MilestoneUtils.isMultipleMilestonesPaymentPending(
            projectMilestones,
          );
          bool isAboutToExceed =
              MilestoneUtils.isMilestoneWithinPaymentCycle(milestoneInfo);
          bool isExceed =
              MilestoneUtils.isMilestonePaymentCycleExceed(milestoneInfo);
          final isNeedToShowRemainingDays =
              showRemainingDaysFor?.name == milestoneInfo.paymentStatus;
          var currentDate = DateTime.now();
          currentDate = DateTime(
            currentDate.year,
            currentDate.month,
            currentDate.day,
          );
          var milestoneDate = milestoneInfo.dateTime!;
          milestoneDate = DateTime(
            milestoneDate.year,
            milestoneDate.month,
            milestoneDate.day,
          );
          final paymentCycle = projectInfo.paymentCycle ?? 0;
          int dateDiffWithCurrentDate =
              milestoneDate.difference(currentDate).inDays;
          if (isAboutToExceed) {
            if (paymentCycle > 0) {
              final maxMilestoneDate = milestoneDate.add(
                Duration(
                  days: paymentCycle,
                ),
              );
              dateDiffWithCurrentDate =
                  maxMilestoneDate.difference(currentDate).inDays;
            } else if (paymentCycle < 0) {
              dateDiffWithCurrentDate =
                  milestoneDate.difference(currentDate).inDays;
            }
          } else if (isExceed) {
            if (paymentCycle <= 0) {
              dateDiffWithCurrentDate =
                  currentDate.difference(milestoneDate).inDays;
            } else if (paymentCycle > 0) {
              final maxMilestoneDate = milestoneDate.add(
                Duration(
                  days: paymentCycle,
                ),
              );
              dateDiffWithCurrentDate =
                  currentDate.difference(maxMilestoneDate).inDays;
            }
          }
          return IntrinsicHeight(
            child: Row(
              children: [
                ProjectMilestoneItem(
                  isLeftCornerRounded: true,
                  darkText: AppUtils.removeTrailingZero(
                    milestoneInfo.milestoneAmount,
                  ),
                  lightText: isNeedToShowRemainingDays
                      ? '$dateDiffWithCurrentDate'
                      : milestoneInfo.dateTime != null
                          ? DateFormat(AppConfig.milestoneInfoDateFormat)
                              .format(
                              milestoneInfo.dateTime!,
                            )
                          : '',
                  blockBgColor: isMultipleAmountPending
                      ? ColorEnums.multipleMilestoneExceededColor
                      : MilestoneUtils.getMilestoneBlockColor(
                          milestoneInfo,
                        ),
                  isNeedToAddMilestone: isNeedToAddMilestone,
                  onMilestoneClick: () {
                    if (isNeedToAddMilestone) {
                      // show add new milestone dialog
                      ShowDialogUtils.showUpdateMilestoneDialog(
                        context: context,
                        appLocalizations: appLocalizations,
                        projectInfo: projectInfo,
                        milestoneInfo: null,
                        isNewMilestoneToAdd: true,
                      );
                    } else {
                      ShowDialogUtils.showMilestoneDialog(
                        context: context,
                        appLocalizations: appLocalizations,
                        projectInfo: projectInfo,
                        milestoneInfo: milestoneInfo,
                      );
                    }
                  },
                ),
                ProjectMilestoneItem(
                  isRightCornerRounded: true,
                  darkText: AppUtils.removeTrailingZero(
                    projectInfo.receivedAmount,
                  ),
                  lightText: firebaseFetchProjectsBloc.getTotalMilestoneAmount(
                    projectInfo,
                  ),
                  blockBgColor: getProjectColorEnum(),
                  onMilestoneClick: () {
                    if (_isProjectHasMilestones(projectInfo)) {
                      ShowDialogUtils.showPaidUnPaidDialog(
                        context: context,
                        appLocalizations: appLocalizations,
                        projectInfo: projectInfo,
                        milestoneInfo: null,
                        isOnlyPaidOperation: true,
                      );
                    }
                  },
                ),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  String getProjectTypeIcon() {
    return (projectInfo.projectType == ProjectTypeEnum.fixed.name)
        ? Strings.dollar
        : (projectInfo.projectType == ProjectTypeEnum.timeAndMaterial.name)
            ? Strings.clock
            : (projectInfo.projectType == ProjectTypeEnum.retainer.name)
                ? Strings.refresh
                : Strings.bulb;
  }

  bool isAllMilestoneCompleted(List<MilestoneInfo> info) {
    return info.length ==
        info
            .where((element) =>
                element.paymentStatus == PaymentStatusEnum.fullyPaid.name)
            .length;
  }

  ColorEnums getProjectColorEnum() {
    final totalEstimation = double.tryParse(
          firebaseFetchProjectsBloc.getTotalMilestoneAmount(
            projectInfo,
          ),
        ) ??
        0;
    final totalReceived = projectInfo.receivedAmount ?? 0;
    if (totalEstimation != 0 &&
        totalReceived != 0 &&
        totalReceived >= totalEstimation) {
      return ColorEnums.projectFullyPaidColor;
    }
    return ColorEnums.whiteColor;
  }

  _deleteProjectConfirmationDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          child: DeleteDialog(
            message: message,
            onDeleteClick: () {
              BlocProvider.of<ProjectOperationsBloc>(
                context,
                listen: false,
              ).add(
                DeleteProjectEvent(
                  projectInfo,
                ),
              );
              Navigator.pop(dialogContext);
            },
            onCancelClick: () {
              Navigator.pop(dialogContext);
            },
          ),
        );
      },
    );
  }

  bool _isProjectHasMilestones(ProjectInfo projectInfo) {
    final totalMilestoneAmount = firebaseFetchProjectsBloc
        .getTotalMilestoneAmount(
          projectInfo,
        )
        .trim();
    if (totalMilestoneAmount.isNotEmpty) {
      final value = double.tryParse(totalMilestoneAmount);
      if (value != null && value > 0) {
        return true;
      }
    }
    return false;
  }
}
