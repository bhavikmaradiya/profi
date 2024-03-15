import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app_widgets/field_border_decoration.dart';
import '../../app_widgets/field_title.dart';
import '../../const/dimens.dart';
import '../../enums/color_enums.dart';
import '../../enums/project_status_enum.dart';
import '../../utils/color_utils.dart';
import '../add_project_field_bloc/add_project_field_bloc.dart';

class ProjectStatus extends StatelessWidget {
  final String title;
  final AppLocalizations appLocalizations;
  final AddProjectFieldBloc addProjectFieldBloc;

  const ProjectStatus({
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
                previous != current && (current is ProjectStatusChangeState),
            builder: (context, state) {
              bool isActive = false;
              bool isOnHold = false;
              bool isClosed = false;
              bool isDropped = false;
              ProjectStatusEnum projectStatusEnum = ProjectStatusEnum.active;
              if (state is ProjectStatusChangeState) {
                projectStatusEnum = state.projectStatusEnum;
              } else {
                final status = addProjectFieldBloc.getProjectStatus();
                if (status != null) {
                  projectStatusEnum = status == ProjectStatusEnum.onHold.name
                      ? ProjectStatusEnum.onHold
                      : status == ProjectStatusEnum.closed.name
                          ? ProjectStatusEnum.closed
                          : status == ProjectStatusEnum.dropped.name
                              ? ProjectStatusEnum.dropped
                              : ProjectStatusEnum.active;
                }
              }
              isActive = projectStatusEnum == ProjectStatusEnum.active;
              isOnHold = projectStatusEnum == ProjectStatusEnum.onHold;
              isClosed = projectStatusEnum == ProjectStatusEnum.closed;
              isDropped = projectStatusEnum == ProjectStatusEnum.dropped;

              return Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        addProjectFieldBloc.add(
                          ProjectStatusChangeEvent(
                            ProjectStatusEnum.active,
                          ),
                        );
                      },
                      child: InputDecorator(
                        decoration: FieldBorderDecoration.fieldBorderDecoration(
                          context,
                          fillColor: isActive
                              ? ColorEnums.blackColor5Opacity
                              : ColorEnums.whiteColor,
                          borderColor: isActive
                              ? ColorEnums.black33Color
                              : ColorEnums.grayE0Color,
                        ),
                        child: _projectStatusItem(
                          context,
                          appLocalizations.active,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: Dimens.addProjectStatusPadding.w,
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        addProjectFieldBloc.add(
                          ProjectStatusChangeEvent(
                            ProjectStatusEnum.onHold,
                          ),
                        );
                      },
                      child: InputDecorator(
                        decoration: FieldBorderDecoration.fieldBorderDecoration(
                          context,
                          fillColor: isOnHold
                              ? ColorEnums.blackColor5Opacity
                              : ColorEnums.whiteColor,
                          borderColor: isOnHold
                              ? ColorEnums.black33Color
                              : ColorEnums.grayE0Color,
                        ),
                        child: _projectStatusItem(
                          context,
                          appLocalizations.onHold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: Dimens.addProjectStatusPadding.w,
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        addProjectFieldBloc.add(
                          ProjectStatusChangeEvent(
                            ProjectStatusEnum.closed,
                          ),
                        );
                      },
                      child: InputDecorator(
                        decoration: FieldBorderDecoration.fieldBorderDecoration(
                          context,
                          fillColor: isClosed
                              ? ColorEnums.blackColor5Opacity
                              : ColorEnums.whiteColor,
                          borderColor: isClosed
                              ? ColorEnums.black33Color
                              : ColorEnums.grayE0Color,
                        ),
                        child: _projectStatusItem(
                          context,
                          appLocalizations.closed,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: Dimens.addProjectStatusPadding.w,
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        addProjectFieldBloc.add(
                          ProjectStatusChangeEvent(
                            ProjectStatusEnum.dropped,
                          ),
                        );
                      },
                      child: InputDecorator(
                        decoration: FieldBorderDecoration.fieldBorderDecoration(
                          context,
                          fillColor: isDropped
                              ? ColorEnums.blackColor5Opacity
                              : ColorEnums.whiteColor,
                          borderColor: isDropped
                              ? ColorEnums.black33Color
                              : ColorEnums.grayE0Color,
                        ),
                        child: _projectStatusItem(
                          context,
                          appLocalizations.dropped,
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

  Widget _projectStatusItem(BuildContext context, String status) {
    return Text(
      status,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: ColorUtils.getColor(
          context,
          ColorEnums.black33Color,
        ),
        fontSize: Dimens.addProjectStatusTextSize.sp,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
