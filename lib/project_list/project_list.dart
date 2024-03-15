import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import './fetch_projects_bloc/firebase_fetch_projects_bloc.dart';
import './milestone_operations_bloc/milestone_operations_bloc.dart';
import './project_operations_bloc/project_operations_bloc.dart';
import './widget/project_list_item.dart';
import '../add_project/model/project_info.dart';
import '../app_widgets/app_empty_view.dart';
import '../app_widgets/custom_expansion_tile.dart';
import '../config/theme_config.dart';
import '../const/dimens.dart';
import '../enums/color_enums.dart';
import '../enums/currency_enum.dart';
import '../enums/payment_status_enum.dart';
import '../project_list/widget/project_milestone_list.dart';
import '../shimmer_view/list_item_shimmer.dart';
import '../utils/color_utils.dart';

class ProjectList extends StatefulWidget {
  final PaymentStatusEnum? statusEnum;

  const ProjectList({
    Key? key,
    this.statusEnum,
  }) : super(key: key);

  @override
  State<ProjectList> createState() => _ProjectListState();
}

class _ProjectListState extends State<ProjectList>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final appLocalizations = AppLocalizations.of(context)!;
    final projectBlocProvider = BlocProvider.of<FirebaseFetchProjectsBloc>(
      context,
      listen: false,
    );
    final milestoneOperationBlocProvider =
        BlocProvider.of<MilestoneOperationsBloc>(
      context,
      listen: false,
    );
    return BlocBuilder<FirebaseFetchProjectsBloc, FirebaseFetchProjectsState>(
      buildWhen: (previous, current) =>
          previous != current && projectBuildWhen(current),
      builder: (context, state) {
        if (state is FirebaseFetchProjectsLoadingState) {
          return _loadingWidget();
        } else if (state is FirebaseFetchProjectsEmptyState) {
          return _emptyWidget(appLocalizations);
        }
        List<ProjectInfo> projects =
            projectBlocProvider.getProjectsByPaymentStatus(
          widget.statusEnum,
        );
        if (projects.isNotEmpty) {
          return _dataWidget(
            context,
            appLocalizations,
            projects,
            projectBlocProvider,
            milestoneOperationBlocProvider,
          );
        }
        return _emptyWidget(appLocalizations);
      },
    );
  }

  Widget _loadingWidget() {
    return const ListItemShimmer(
      shimmerItemCount: 10,
    );
  }

  Widget _dataWidget(
    BuildContext context,
    AppLocalizations appLocalizations,
    List<ProjectInfo> projects,
    FirebaseFetchProjectsBloc projectBlocProvider,
    MilestoneOperationsBloc milestoneOperationBlocProvider,
  ) {
    return Column(
      children: [
        if (widget.statusEnum == PaymentStatusEnum.exceeded ||
            widget.statusEnum == PaymentStatusEnum.aboutToExceed)
          InkWell(
            onTap: () {
              milestoneOperationBlocProvider.add(
                MilestoneCurrencyChangeEvent(),
              );
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: Dimens.screenHorizontalMargin.w,
                vertical: Dimens.appBarContentVerticalPadding.h,
              ),
              color: ColorUtils.getColor(
                context,
                widget.statusEnum == PaymentStatusEnum.exceeded
                    ? ColorEnums.redColor
                    : widget.statusEnum == PaymentStatusEnum.aboutToExceed
                        ? ColorEnums.amberF59032Color
                        : ColorEnums.whiteColor,
              ).withOpacity(0.05),
              alignment: Alignment.center,
              child: BlocBuilder<MilestoneOperationsBloc,
                  MilestoneOperationsState>(
                builder: (context, state) {
                  CurrencyEnum toCurrency =
                      milestoneOperationBlocProvider.getSelectedCurrency();
                  if (state is MilestoneCurrencyChangedState) {
                    toCurrency = state.currencyEnum;
                  }
                  final amountWithCurrency =
                      projectBlocProvider.getPendingAmount(
                    projects: projects,
                    paymentStatusEnum: widget.statusEnum,
                    toCurrency: toCurrency,
                  );
                  final amountCurrency = amountWithCurrency[0];
                  final amount = amountWithCurrency.substring(
                      1, amountWithCurrency.length);
                  final color = ColorUtils.getColor(
                    context,
                    widget.statusEnum == PaymentStatusEnum.exceeded
                        ? ColorEnums.redColor
                        : widget.statusEnum == PaymentStatusEnum.aboutToExceed
                            ? ColorEnums.amberF59032Color
                            : ColorEnums.black33Color,
                  );
                  return RichText(
                    text: TextSpan(
                      text: amountCurrency,
                      style: TextStyle(
                        color: color,
                        fontSize: Dimens.redOrangeCurrencyValueTextSize.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: ThemeConfig.notoSans,
                      ),
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Text(
                            amount,
                            style: TextStyle(
                              color: color,
                              fontSize: Dimens.redOrangeValueTextSize.sp,
                              fontWeight: FontWeight.w700,
                              fontFamily: ThemeConfig.appFonts,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        Expanded(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final projectInfo = projects[index];
              return Column(
                children: [
                  GestureDetector(
                    onLongPress: () {
                      BlocProvider.of<ProjectOperationsBloc>(
                        context,
                        listen: false,
                      ).add(ProjectOperationsStartEvent(projectInfo));
                    },
                    child: ListTileTheme(
                      contentPadding: EdgeInsets.zero,
                      horizontalTitleGap: 0.0,
                      minLeadingWidth: 0,
                      minVerticalPadding: 0,
                      dense: true,
                      // Ref. https://stackoverflow.com/a/64124471/5370550
                      child: CustomExpansionTile(
                        title: BlocBuilder<ProjectOperationsBloc,
                            ProjectOperationsState>(
                          buildWhen: (previous, current) =>
                              previous != current &&
                              (current is ProjectOperationStartedState ||
                                  current is ProjectOperationCompletedState),
                          builder: (context, state) {
                            final isLongPress =
                                state is ProjectOperationStartedState &&
                                    state.projectInfo.projectId ==
                                        projectInfo.projectId;
                            return ProjectListItem(
                              projectInfo: projectInfo,
                              isNeedToShowOperationsView: isLongPress,
                              firebaseFetchProjectsBloc: projectBlocProvider,
                            );
                          },
                        ),
                        tilePadding: EdgeInsets.zero,
                        childrenPadding: EdgeInsets.zero,
                        children: [
                          ProjectMilestoneList(
                            projectInfo: projectInfo,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (index == (projects.length - 1))
                    SizedBox(
                      height: Dimens.addProjectSaveContainerSize.h,
                    ),
                ],
              );
            },
            separatorBuilder: (context, index) {
              return Divider(
                height: 0,
                color: ColorUtils.getColor(
                  context,
                  ColorEnums.grayD9Color,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  bool projectBuildWhen(FirebaseFetchProjectsState current) {
    final commonConditions = current is FirebaseFetchProjectsLoadingState ||
        current is FirebaseFetchProjectsDataState ||
        current is FirebaseFetchProjectsEmptyState ||
        current is FilterChangedState;
    if (widget.statusEnum == PaymentStatusEnum.exceeded ||
        widget.statusEnum == PaymentStatusEnum.aboutToExceed) {
      return commonConditions || current is FirebaseMilestoneInfoChangedState;
    }
    return commonConditions;
  }

  Widget _emptyWidget(AppLocalizations appLocalizations) {
    return AppEmptyView(
      message: widget.statusEnum == PaymentStatusEnum.exceeded
          ? appLocalizations.redProjectsNotFound
          : widget.statusEnum == PaymentStatusEnum.aboutToExceed
              ? appLocalizations.orangeProjectsNotFound
              : appLocalizations.projectsNotFound,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
