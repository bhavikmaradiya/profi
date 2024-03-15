import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import './bloc/filter_bloc.dart';
import './model/filter_model.dart';
import '../app_widgets/app_filled_button.dart';
import '../app_widgets/app_outline_button.dart';
import '../app_widgets/app_tool_bar.dart';
import '../const/dimens.dart';
import '../const/strings.dart';
import '../enums/color_enums.dart';
import '../enums/filter_criteria_enum.dart';
import '../project_list/fetch_projects_bloc/firebase_fetch_projects_bloc.dart';
import '../utils/color_utils.dart';

class FilterProjects extends StatelessWidget {
  const FilterProjects({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final filterBlocProvider = BlocProvider.of<FilterBloc>(
      context,
      listen: false,
    );
    final fetchProjectBlocProvider = BlocProvider.of<FirebaseFetchProjectsBloc>(
      context,
      listen: false,
    );
    filterBlocProvider.add(
      FilterCriteriaGenerationEvent(
        appLocalizations,
        fetchProjectBlocProvider.getAppliedFilter(),
      ),
    );
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ToolBar(
          title: appLocalizations.filters,
          onFilterClearAll: () {
            filterBlocProvider.add(FilterClearEvent());
            Navigator.pop(context);
          },
        ),
      ),
      body: BlocListener<FilterBloc, FilterState>(
        listenWhen: (previous, current) =>
            previous != current &&
            (current is FilterAppliedState || current is FilterClearedState),
        listener: (context, state) {
          if (state is FilterAppliedState) {
            fetchProjectBlocProvider.add(
              FilterChangedEvent(
                state.appliedFilterInfo,
              ),
            );
          }
          if (state is FilterClearedState) {
            fetchProjectBlocProvider.add(FilterChangedEvent(null));
          }
        },
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: Dimens.screenHorizontalMargin.w,
                      right: Dimens.screenHorizontalMargin.w,
                      top: Dimens.appBarContentVerticalPadding.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: ColorUtils.getColor(
                                context,
                                ColorEnums.grayE0Color,
                              ),
                            ),
                            borderRadius: BorderRadius.circular(
                              Dimens.filterContainerBorderRadius.r,
                            ),
                          ),
                          padding: EdgeInsets.all(
                            Dimens.filterItemContainerPadding.w,
                          ),
                          child: _sortByWidgets(
                            context,
                            appLocalizations,
                            filterBlocProvider,
                          ),
                        ),
                        SizedBox(
                          height: Dimens.filterItemOuterSpacing.h,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: ColorUtils.getColor(
                                context,
                                ColorEnums.grayE0Color,
                              ),
                            ),
                            borderRadius: BorderRadius.circular(
                              Dimens.filterContainerBorderRadius.r,
                            ),
                          ),
                          padding: EdgeInsets.all(
                            Dimens.filterItemContainerPadding.w,
                          ),
                          child: _statusWidgets(
                            context,
                            appLocalizations,
                            filterBlocProvider,
                          ),
                        ),
                        SizedBox(
                          height: Dimens.filterItemOuterSpacing.h,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: ColorUtils.getColor(
                                context,
                                ColorEnums.grayE0Color,
                              ),
                            ),
                            borderRadius: BorderRadius.circular(
                              Dimens.filterContainerBorderRadius.r,
                            ),
                          ),
                          padding: EdgeInsets.all(
                            Dimens.filterItemContainerPadding.w,
                          ),
                          child: _typeWidgets(
                            context,
                            appLocalizations,
                            filterBlocProvider,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _filterActions(
                context,
                appLocalizations,
                filterBlocProvider,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sortByWidgets(
    BuildContext context,
    AppLocalizations appLocalizations,
    FilterBloc filterBlocProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appLocalizations.sortBy,
          style: _headerTextStyle(context),
          maxLines: 1,
        ),
        SizedBox(
          height: Dimens.filterHeaderItemSpacing.h,
        ),
        BlocBuilder<FilterBloc, FilterState>(
          buildWhen: (previous, current) =>
              previous != current &&
              (current is FilterCriteriaGeneratedState ||
                  current is FilterSortByChangedState),
          builder: (context, state) {
            List<FilterModel> sortByList = [];
            if (state is FilterCriteriaGeneratedState) {
              sortByList.clear();
              sortByList.addAll(state.sortBy);
            } else if (state is FilterSortByChangedState) {
              sortByList.clear();
              sortByList.addAll(state.sortBy);
            }
            if (sortByList.isEmpty) {
              return const SizedBox();
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final info = sortByList[index];
                return GestureDetector(
                  onTap: () {
                    filterBlocProvider.add(
                      FilterCriteriaSelectionChangeEvent(
                        FilterCriteriaEnum.sortBy,
                        index,
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: (index < (sortByList.length - 1))
                          ? Dimens.filterItemSpacing.h
                          : 0,
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          info.isSelected
                              ? Strings.radioSelected
                              : Strings.radioUnselected,
                          width: Dimens.filterRadioCheckBoxIconSize.w,
                          height: Dimens.filterRadioCheckBoxIconSize.w,
                        ),
                        SizedBox(
                          width: Dimens.filterRadioCheckBoxIconTextSpacing.w,
                        ),
                        Expanded(
                          child: Text(
                            info.value,
                            style: _itemTextStyle(context),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              itemCount: sortByList.length,
            );
          },
        ),
      ],
    );
  }

  Widget _statusWidgets(
    BuildContext context,
    AppLocalizations appLocalizations,
    FilterBloc filterBlocProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appLocalizations.status,
          style: _headerTextStyle(context),
          maxLines: 1,
        ),
        SizedBox(
          height: Dimens.filterHeaderItemSpacing.h,
        ),
        BlocBuilder<FilterBloc, FilterState>(
          buildWhen: (previous, current) =>
              previous != current &&
              (current is FilterCriteriaGeneratedState ||
                  current is FilterStatusChangedState),
          builder: (context, state) {
            List<FilterModel> statusList = [];
            if (state is FilterCriteriaGeneratedState) {
              statusList.clear();
              statusList.addAll(state.status);
            } else if (state is FilterStatusChangedState) {
              statusList.clear();
              statusList.addAll(state.status);
            }
            if (statusList.isEmpty) {
              return const SizedBox();
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final info = statusList[index];
                return GestureDetector(
                  onTap: () {
                    filterBlocProvider.add(
                      FilterCriteriaSelectionChangeEvent(
                        FilterCriteriaEnum.status,
                        index,
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: (index < (statusList.length - 1))
                          ? Dimens.filterItemSpacing.h
                          : 0,
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          info.isSelected
                              ? Strings.checkBoxChecked
                              : Strings.checkBoxUnChecked,
                          width: Dimens.filterRadioCheckBoxIconSize.w,
                          height: Dimens.filterRadioCheckBoxIconSize.w,
                        ),
                        SizedBox(
                          width: Dimens.filterRadioCheckBoxIconTextSpacing.w,
                        ),
                        Expanded(
                          child: Text(
                            info.value,
                            style: _itemTextStyle(context),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              itemCount: statusList.length,
            );
          },
        ),
      ],
    );
  }

  Widget _typeWidgets(
    BuildContext context,
    AppLocalizations appLocalizations,
    FilterBloc filterBlocProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appLocalizations.type,
          style: _headerTextStyle(context),
          maxLines: 1,
        ),
        SizedBox(
          height: Dimens.filterHeaderItemSpacing.h,
        ),
        BlocBuilder<FilterBloc, FilterState>(
          buildWhen: (previous, current) =>
              previous != current &&
              (current is FilterCriteriaGeneratedState ||
                  current is FilterTypeChangedState),
          builder: (context, state) {
            List<FilterModel> typeList = [];
            if (state is FilterCriteriaGeneratedState) {
              typeList.clear();
              typeList.addAll(state.type);
            } else if (state is FilterTypeChangedState) {
              typeList.clear();
              typeList.addAll(state.type);
            }
            if (typeList.isEmpty) {
              return const SizedBox();
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final info = typeList[index];
                return GestureDetector(
                  onTap: () {
                    filterBlocProvider.add(
                      FilterCriteriaSelectionChangeEvent(
                        FilterCriteriaEnum.type,
                        index,
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: (index < (typeList.length - 1))
                          ? Dimens.filterItemSpacing.h
                          : 0,
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          info.isSelected
                              ? Strings.checkBoxChecked
                              : Strings.checkBoxUnChecked,
                          width: Dimens.filterRadioCheckBoxIconSize.w,
                          height: Dimens.filterRadioCheckBoxIconSize.w,
                        ),
                        SizedBox(
                          width: Dimens.filterRadioCheckBoxIconTextSpacing.w,
                        ),
                        Expanded(
                          child: Text(
                            info.value,
                            style: _itemTextStyle(context),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              itemCount: typeList.length,
            );
          },
        ),
      ],
    );
  }

  TextStyle _headerTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: Dimens.filterHeaderTextSize.sp,
      fontWeight: FontWeight.w500,
      color: ColorUtils.getColor(
        context,
        ColorEnums.gray6CColor,
      ),
    );
  }

  TextStyle _itemTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: Dimens.filterItemTextSize.sp,
      color: ColorUtils.getColor(
        context,
        ColorEnums.black00Color,
      ),
    );
  }

  Widget _filterActions(
    BuildContext context,
    AppLocalizations appLocalizations,
    FilterBloc filterBlocProvider,
  ) {
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
              -Dimens.containerShadowYCoordinates.h,
            ),
            blurRadius: Dimens.containerShadowRadius.r,
          ),
        ],
        color: ColorUtils.getColor(
          context,
          ColorEnums.whiteColor,
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.screenHorizontalMargin.w,
        vertical: Dimens.screenHorizontalMargin.h,
      ),
      child: Row(
        children: [
          Expanded(
            child: AppOutlineButton(
              title: appLocalizations.cancel,
              onButtonPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          SizedBox(
            width: Dimens.filterSaveCancelButtonSpacing.w,
          ),
          Expanded(
            child: AppFilledButton(
              title: appLocalizations.apply,
              onButtonPressed: () {
                filterBlocProvider.add(FilterApplyEvent());
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
