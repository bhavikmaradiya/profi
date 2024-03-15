import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import './project_milestone_item.dart';
import '../../add_project/model/project_info.dart';
import '../../config/app_config.dart';
import '../../const/dimens.dart';
import '../../dialog/show_dialog_utils.dart';
import '../../enums/color_enums.dart';
import '../../utils/app_utils.dart';
import '../../utils/color_utils.dart';
import '../fetch_projects_bloc/firebase_fetch_projects_bloc.dart';
import '../utils/milestone_utils.dart';

class ProjectMilestoneList extends StatefulWidget {
  final ProjectInfo projectInfo;

  const ProjectMilestoneList({
    Key? key,
    required this.projectInfo,
  }) : super(key: key);

  @override
  State<ProjectMilestoneList> createState() => _ProjectMilestoneListState();
}

class _ProjectMilestoneListState extends State<ProjectMilestoneList> {
  final ScrollController _scrollController = ScrollController();
  int scrollToMilestoneItemIndex = 0;
  final GlobalKey _itemKey = GlobalKey();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _scrollToIndex(scrollToMilestoneItemIndex);
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  _scrollToIndex(int index) {
    if (index >= 0) {
      // Find the RenderBox of the target item
      final RenderBox? renderBox =
          _itemKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        double desiredOffset = renderBox.localToGlobal(Offset.zero).dx;
        // Get the maximum scrollable extent
        double maxScrollExtent = _scrollController.position.maxScrollExtent;
        // Adjust the desiredOffset if it exceeds the maximum scrollable extent
        if (desiredOffset > maxScrollExtent) {
          desiredOffset = maxScrollExtent;
        } else {
          desiredOffset = desiredOffset > Dimens.screenHorizontalMargin.w
              ? desiredOffset - Dimens.screenHorizontalMargin.w
              : desiredOffset;
        }
        // Scroll to the desiredOffset
        _scrollController.animateTo(
          desiredOffset,
          duration: const Duration(
            milliseconds: 500,
          ),
          curve: Curves.ease,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    return BlocBuilder<FirebaseFetchProjectsBloc, FirebaseFetchProjectsState>(
      buildWhen: (previous, current) =>
          previous != current && current is FirebaseMilestoneInfoChangedState,
      builder: (context, state) {
        if (state is FirebaseMilestoneInfoChangedState) {
          final projectMilestones = state.milestones
              .where(
                (element) => element.projectId == widget.projectInfo.projectId,
              )
              .toList();
          if (projectMilestones.isEmpty) {
            return const SizedBox();
          }
          final nearestIndex = MilestoneUtils.getNearestWhiteMilestoneIndex(
            projectMilestones,
          );
          scrollToMilestoneItemIndex = nearestIndex;
          return Container(
            width: double.infinity,
            color: ColorUtils.getColor(
              context,
              ColorEnums.grayF5Color,
            ),
            padding: EdgeInsets.symmetric(
              vertical: Dimens.milestonesVerticalContentPadding.h,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              controller: _scrollController,
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    ...projectMilestones.mapIndexed(
                      (milestoneIndex, milestoneInfo) {
                        return ProjectMilestoneItem(
                          key: milestoneIndex == scrollToMilestoneItemIndex
                              ? _itemKey
                              : null,
                          isLeftCornerRounded:
                              milestoneIndex == 0 ? true : false,
                          isLeftSpacingRequired:
                              milestoneIndex == 0 ? true : false,
                          darkText: AppUtils.removeTrailingZero(
                            milestoneInfo.milestoneAmount,
                          ),
                          lightText: milestoneInfo.dateTime != null
                              ? DateFormat(
                                  AppConfig.milestoneInfoDateFormat,
                                ).format(
                                  milestoneInfo.dateTime!,
                                )
                              : '',
                          isMilestoneUpdated: milestoneInfo.isUpdated ?? false,
                          isMilestoneInvoiced:
                              MilestoneUtils.isMilestoneWithinPaymentCycle(
                                      milestoneInfo) &&
                                  (milestoneInfo.isInvoiced ?? false),
                          blockBgColor: MilestoneUtils.getMilestoneBlockColor(
                            milestoneInfo,
                            isApplicableForGrayColor: nearestIndex != (-1) &&
                                milestoneIndex > nearestIndex,
                          ),
                          onMilestoneClick: () {
                            ShowDialogUtils.showMilestoneDialog(
                              context: context,
                              appLocalizations: appLocalizations,
                              projectInfo: widget.projectInfo,
                              milestoneInfo: milestoneInfo,
                            );
                          },
                        );
                      },
                    ).toList(),
                    ProjectMilestoneItem(
                      customWidth:
                          Dimens.projectListNewMilestoneBlockMinWidth.h,
                      isRightCornerRounded: true,
                      isRightSpacingRequired: true,
                      darkText: '',
                      lightText: '',
                      isNeedToAddMilestone: true,
                      onMilestoneClick: () {
                        // show add new milestone dialog
                        ShowDialogUtils.showUpdateMilestoneDialog(
                          context: context,
                          appLocalizations: appLocalizations,
                          projectInfo: widget.projectInfo,
                          milestoneInfo: null,
                          isNewMilestoneToAdd: true,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}
