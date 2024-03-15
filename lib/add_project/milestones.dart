import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import './add_project_field_bloc/add_project_field_bloc.dart';
import './model/milestone_info.dart';
import './widget/milestone_item.dart';
import '../app_widgets/field_title.dart';
import '../const/dimens.dart';
import '../const/strings.dart';
import '../enums/color_enums.dart';
import '../utils/color_utils.dart';

class Milestones extends StatelessWidget {
  final String title;
  final bool isEdit;
  final VoidCallback onAddMilestone;

  const Milestones({
    Key? key,
    required this.title,
    required this.isEdit,
    required this.onAddMilestone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final addProjectBlocProvider = BlocProvider.of<AddProjectFieldBloc>(
      context,
      listen: false,
    );
    return BlocBuilder<AddProjectFieldBloc, AddProjectFieldState>(
      buildWhen: (previous, current) =>
          previous != current &&
          (current is MilestoneSetupGeneratedState ||
              current is MilestoneRemovedState ||
              current is MilestoneChangedSuccessState ||
              current is NewMilestoneAddedState),
      builder: (context, state) {
        final List<MilestoneInfo> list = state is MilestoneSetupGeneratedState
            ? state.milestones
            : state is MilestoneRemovedState
                ? state.milestones
                : state is MilestoneChangedSuccessState
                    ? state.milestones
                    : state is NewMilestoneAddedState
                        ? state.milestones
                        : addProjectBlocProvider.getMilestones();
        if (list.isEmpty) {
          return const SizedBox();
        }
        return ColoredBox(
          color: ColorUtils.getColor(
            context,
            ColorEnums.grayF5Color,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Dimens.screenHorizontalMargin.w,
              vertical: Dimens.fieldBetweenVerticalPadding.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FieldTitle(title: title),
                SizedBox(
                  height: Dimens.titleFieldVerticalPadding.h,
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: ColorUtils.getColor(
                        context,
                        ColorEnums.grayE0Color,
                      ),
                      width: Dimens.addProjectMilestoneBorderSize.w,
                    ),
                    borderRadius: BorderRadius.circular(
                      Dimens.addProjectMilestoneBorderRadius.r,
                    ),
                    color: ColorUtils.getColor(
                      context,
                      ColorEnums.whiteColor,
                    ),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return MilestoneItem(
                        key: Key(list[index].id.toString()),
                        mileStoneInfo: list[index],
                        appLocalizations: appLocalizations,
                        isTopLeftRounded: index == 0,
                        isBottomLeftRounded: index == (list.length - 1),
                        isEdit: isEdit,
                        isNeedToSetInitialValue:
                            isEdit && state is MilestoneSetupGeneratedState,
                      );
                    },
                    itemCount: list.length,
                    separatorBuilder: (BuildContext context, int index) {
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
                SizedBox(
                  height: Dimens.fieldBetweenVerticalPadding.h,
                ),
                InkWell(
                  onTap: () {
                    BlocProvider.of<AddProjectFieldBloc>(
                      context,
                      listen: false,
                    ).add(
                      AddNewMilestoneEvent(),
                    );
                    Future.delayed(
                      const Duration(
                        milliseconds: 100,
                      ),
                      () {
                        onAddMilestone();
                      },
                    );
                  },
                  child: Container(
                    height: Dimens.fieldHeight.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        Dimens.addProjectMilestoneButtonRadius.r,
                      ),
                      color: ColorUtils.getColor(
                        context,
                        ColorEnums.whiteColor,
                      ),
                    ),
                    child: DottedBorder(
                      color: ColorUtils.getColor(
                        context,
                        ColorEnums.grayE0Color,
                      ),
                      strokeWidth: Dimens.addProjectMilestoneDashButtonWidth.w,
                      radius: Radius.circular(
                        Dimens.addProjectMilestoneButtonRadius.r,
                      ),
                      strokeCap: StrokeCap.round,
                      dashPattern: const [5, 5],
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              Strings.add,
                              width: Dimens
                                  .addProjectMilestoneDashButtonIconSize.w,
                              height: Dimens
                                  .addProjectMilestoneDashButtonIconSize.w,
                            ),
                            SizedBox(
                              width: Dimens
                                  .addProjectMilestoneDashButtonIconSpacing.w,
                            ),
                            Text(
                              appLocalizations.add,
                              style: TextStyle(
                                color: ColorUtils.getColor(
                                  context,
                                  ColorEnums.black33Color,
                                ),
                                fontWeight: FontWeight.w700,
                                fontSize: Dimens.buttonTextSize.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
