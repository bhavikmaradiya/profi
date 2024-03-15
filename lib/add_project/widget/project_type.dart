import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app_widgets/field_border_decoration.dart';
import '../../app_widgets/field_title.dart';
import '../../const/dimens.dart';
import '../../const/strings.dart';
import '../../enums/color_enums.dart';
import '../../enums/project_type_enum.dart';
import '../../utils/color_utils.dart';
import '../add_project_field_bloc/add_project_field_bloc.dart';

class ProjectType extends StatelessWidget {
  final String title;
  final AppLocalizations appLocalizations;
  final AddProjectFieldBloc addProjectFieldBloc;

  const ProjectType({
    Key? key,
    required this.title,
    required this.appLocalizations,
    required this.addProjectFieldBloc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        FieldTitle(title: title),
        SizedBox(
          height: Dimens.titleFieldVerticalPadding.h,
        ),
        SizedBox(
          height: Dimens.fieldHeight.h,
          child: BlocBuilder<AddProjectFieldBloc, AddProjectFieldState>(
            buildWhen: (previous, current) =>
                previous != current && (current is ProjectTypeChangeState),
            builder: (context, state) {
              final isFixedTypeSelected = state is ProjectTypeChangeState &&
                  state.projectTypeEnum == ProjectTypeEnum.fixed;
              final isTMTypeSelected = state is ProjectTypeChangeState &&
                  state.projectTypeEnum == ProjectTypeEnum.timeAndMaterial;
              final isRetainerTypeSelected = state is ProjectTypeChangeState &&
                  state.projectTypeEnum == ProjectTypeEnum.retainer;
              return Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        // FocusManager.instance.primaryFocus?.unfocus();
                        // FocusScope.of(context).unfocus();
                        _changeProjectType(
                          ProjectTypeEnum.fixed,
                        );
                      },
                      child: InputDecorator(
                        decoration: FieldBorderDecoration.fieldBorderDecoration(
                          context,
                          fillColor: isFixedTypeSelected
                              ? ColorEnums.blackColor5Opacity
                              : ColorEnums.whiteColor,
                          borderColor: isFixedTypeSelected
                              ? ColorEnums.black33Color
                              : ColorEnums.grayE0Color,
                        ),
                        child: projectTypeItem(
                          context,
                          Strings.dollar,
                          appLocalizations.fixed,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: Dimens.addProjectTypePadding.w,
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        _changeProjectType(
                          ProjectTypeEnum.timeAndMaterial,
                        );
                      },
                      child: InputDecorator(
                        decoration: FieldBorderDecoration.fieldBorderDecoration(
                          context,
                          fillColor: isTMTypeSelected
                              ? ColorEnums.blackColor5Opacity
                              : ColorEnums.whiteColor,
                          borderColor: isTMTypeSelected
                              ? ColorEnums.black33Color
                              : ColorEnums.grayE0Color,
                        ),
                        child: projectTypeItem(
                          context,
                          Strings.clock,
                          appLocalizations.timeAndMaterial,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: Dimens.addProjectTypePadding.w,
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        _changeProjectType(
                          ProjectTypeEnum.retainer,
                        );
                      },
                      child: InputDecorator(
                        decoration: FieldBorderDecoration.fieldBorderDecoration(
                          context,
                          fillColor: isRetainerTypeSelected
                              ? ColorEnums.blackColor5Opacity
                              : ColorEnums.whiteColor,
                          borderColor: isRetainerTypeSelected
                              ? ColorEnums.black33Color
                              : ColorEnums.grayE0Color,
                        ),
                        child: projectTypeItem(
                          context,
                          Strings.refresh,
                          appLocalizations.retainer,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  _changeProjectType(ProjectTypeEnum projectTypeToSelect) {
    if (addProjectFieldBloc.selectedProjectType != projectTypeToSelect) {
      addProjectFieldBloc.add(
        ProjectTypeChangeEvent(
          projectTypeToSelect,
        ),
      );
    } else {
      addProjectFieldBloc.add(
        ProjectTypeChangeEvent(
          ProjectTypeEnum.nonBillable,
        ),
      );
    }
  }

  Widget projectTypeItem(BuildContext context, String icon, String type) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundColor: ColorUtils.getColor(
            context,
            ColorEnums.black33Color,
          ),
          radius: Dimens.addProjectTypeCircleSize.r,
          child: Padding(
            padding: EdgeInsets.all(
              Dimens.addProjectTypeCirclePadding.r,
            ),
            child: SvgPicture.asset(
              icon,
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
        SizedBox(
          width: Dimens.addProjectTypeIconTextPadding.w,
        ),
        Text(
          type,
          style: TextStyle(
            color: ColorUtils.getColor(
              context,
              ColorEnums.black33Color,
            ),
            fontSize: Dimens.addProjectTypeTextSize.sp,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
