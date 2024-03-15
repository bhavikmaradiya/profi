import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import './widget/history_item.dart';
import '../add_project/model/milestone_info.dart';
import '../add_project/model/project_info.dart';
import '../app_widgets/app_empty_view.dart';
import '../const/dimens.dart';
import '../const/strings.dart';
import '../enums/color_enums.dart';
import '../logs/bloc/logs_bloc.dart';
import '../logs/model/log_info.dart';
import '../project_list/utils/milestone_utils.dart';
import '../shimmer_view/history_item_shimmer.dart';
import '../utils/color_utils.dart';

class HistoryDialog extends StatelessWidget {
  final ProjectInfo projectInfo;
  final MilestoneInfo? milestoneInfo;
  final String? currentUserId;
  final double? height;

  const HistoryDialog({
    Key? key,
    required this.projectInfo,
    required this.milestoneInfo,
    required this.currentUserId,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final milestoneId = milestoneInfo?.milestoneId;
    LogsBloc? logsBlocProvider;
    if (milestoneId != null) {
      logsBlocProvider = BlocProvider.of<LogsBloc>(context, listen: false);
      logsBlocProvider.add(FetchLogsEvent(milestoneId));
    }
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: height,
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
              _headerView(
                context,
                appLocalizations,
                milestoneInfo,
              ),
              Flexible(
                child: _historyWidget(
                  context,
                  appLocalizations,
                  logsBlocProvider,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Material(
            color: ColorUtils.getColor(
              context,
              ColorEnums.transparentColor,
            ),
            child: InkWell(
              onTap: () {
                Navigator.pop(context, false);
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
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          child: Material(
            color: ColorUtils.getColor(
              context,
              ColorEnums.transparentColor,
            ),
            child: InkWell(
              onTap: () {
                Navigator.pop(context, true);
              },
              borderRadius: BorderRadius.circular(
                (Dimens.drawerCloseIconSize * 3).w,
              ),
              child: SizedBox(
                width: (Dimens.drawerCloseIconSize * 3).w,
                height: (Dimens.drawerCloseIconSize * 3).w,
                child: Padding(
                  padding: EdgeInsets.all(
                    Dimens.drawerBackIconSize.w,
                  ),
                  child: SvgPicture.asset(
                    Strings.backButton,
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
          ),
        ),
      ],
    );
  }

  Widget _headerView(
    BuildContext context,
    AppLocalizations appLocalizations,
    MilestoneInfo? milestoneInfo,
  ) {
    String projectName = projectInfo.projectName ?? '';
    if (projectName.isNotEmpty) {
      projectName = '$projectName - ${appLocalizations.history}';
    }
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(
            Dimens.dialogRadius.r,
          ),
          topRight: Radius.circular(
            Dimens.dialogRadius.r,
          ),
        ),
        color: ColorUtils.getColor(
          context,
          MilestoneUtils.getMilestoneBlockColor(
            milestoneInfo,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: (Dimens.dialogHorizontalPadding * 2).w,
        vertical: Dimens.dialogVerticalPadding.w,
      ),
      alignment: Alignment.center,
      child: Text(
        projectName,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: Dimens.dialogTitleTextSize.sp,
          fontWeight: FontWeight.w500,
          color: ColorUtils.getColor(
            context,
            ColorEnums.black33Color,
          ),
        ),
      ),
    );
  }

  Widget _historyWidget(
    BuildContext context,
    AppLocalizations appLocalizations,
    LogsBloc? logsBlocProvider,
  ) {
    return BlocBuilder<LogsBloc, LogsState>(
      buildWhen: (previous, current) =>
          previous != current &&
          (current is LogsFetchedState || current is FetchingLogsLoadingState),
      builder: (context, state) {
        if (state is FetchingLogsLoadingState) {
          return const HistoryItemShimmer();
        } else {
          List<LogInfo> list = [];
          if (state is LogsFetchedState) {
            list = state.logs;
          } else {
            list = logsBlocProvider?.getMilestoneTransactionsLogs() ?? [];
          }
          if (list.isEmpty) {
            return SizedBox(
              height: Dimens.emptyHistoryHeight.h,
              child: AppEmptyView(
                message: appLocalizations.emptyHistory,
              ),
            );
          }
          return ListView.separated(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            separatorBuilder: (BuildContext context, int index) {
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimens.historyContentHorizontalPadding.w,
                ),
                child: Divider(
                  height: 0,
                  color: ColorUtils.getColor(
                    context,
                    ColorEnums.grayD9Color,
                  ),
                ),
              );
            },
            itemBuilder: (context, index) {
              final log = list[index];
              return HistoryItem(
                log: log,
                currentUserId: currentUserId,
              );
            },
            itemCount: list.length,
          );
        }
      },
    );
  }
}
