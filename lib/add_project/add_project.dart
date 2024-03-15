import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './add_project_field_bloc/add_project_field_bloc.dart';
import './firebase_add_project_bloc/firebase_add_project_bloc.dart';
import './milestones.dart';
import './model/milestone_info.dart';
import './model/project_info.dart';
import './widget/project_status.dart';
import './widget/project_type.dart';
import '../app_models/drop_down_model.dart';
import '../app_widgets/app_currency_field.dart';
import '../app_widgets/app_date_picker.dart';
import '../app_widgets/app_drop_down_field.dart';
import '../app_widgets/app_filled_button.dart';
import '../app_widgets/app_text_field.dart';
import '../app_widgets/app_tool_bar.dart';
import '../app_widgets/snack_bar_view.dart';
import '../config/app_config.dart';
import '../config/preference_config.dart';
import '../const/dimens.dart';
import '../const/strings.dart';
import '../enums/color_enums.dart';
import '../enums/project_field_validation_enum.dart';
import '../enums/project_type_enum.dart';
import '../enums/user_role_enums.dart';
import '../project_list/fetch_projects_bloc/firebase_fetch_projects_bloc.dart';
import '../utils/app_utils.dart';
import '../utils/color_utils.dart';
import '../utils/decimal_text_input_formatter.dart';

class AddProject extends StatefulWidget {
  const AddProject({Key? key}) : super(key: key);

  @override
  State<AddProject> createState() => _AddProjectState();
}

class _AddProjectState extends State<AddProject> {
  final _projectCodeFocusNode = FocusNode(canRequestFocus: false);
  final _projectStartDateTextEditingController = TextEditingController();
  final _projectCodeTextEditingController = TextEditingController();
  final _projectNameTextEditingController = TextEditingController();
  final _totalFixedAmountTextEditingController = TextEditingController();
  final _hourlyRateTextEditingController = TextEditingController();
  final _weeklyHoursTextEditingController = TextEditingController();
  final _totalHoursTextEditingController = TextEditingController();
  final _monthlyAmountTextEditingController = TextEditingController();
  final _specialNotesTextEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final _totalAmountFocusNode = Platform.isIOS ? FocusNode() : null;
  final _hourlyRateFocusNode = Platform.isIOS ? FocusNode() : null;
  final _weeklyHoursFocusNode = Platform.isIOS ? FocusNode() : null;
  final _totalHoursFocusNode = Platform.isIOS ? FocusNode() : null;
  final _monthlyAmountFocusNode = Platform.isIOS ? FocusNode() : null;
  AddProjectFieldBloc? addProjectFieldBloc;
  FirebaseFetchProjectsBloc? firebaseProjectsBlocProvider;
  bool isEdit = false;
  AppLocalizations? appLocalizations;
  Object? arguments;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (addProjectFieldBloc == null) {
      appLocalizations = AppLocalizations.of(context)!;
      arguments = ModalRoute.of(context)!.settings.arguments;
      isEdit = arguments != null && arguments is String?;
      addProjectFieldBloc = BlocProvider.of<AddProjectFieldBloc>(
        context,
        listen: false,
      );

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (firebaseProjectsBlocProvider == null) {
          if (isEdit) {
            firebaseProjectsBlocProvider =
                BlocProvider.of<FirebaseFetchProjectsBloc>(
              context,
              listen: false,
            );
            final projectInfo =
                firebaseProjectsBlocProvider!.getProjectInfoFromProjectId(
              arguments as String?,
            );
            if (projectInfo != null) {
              final milestones =
                  firebaseProjectsBlocProvider!.getMilestoneInfoFromProjectId(
                projectInfo.projectId,
              );
              _updateFieldsOnEditProject(
                projectInfo,
                milestones,
                addProjectFieldBloc!,
              );
            }
          } else {
            FocusScope.of(context).requestFocus(_projectCodeFocusNode);
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AddProjectFieldBloc, AddProjectFieldState>(
          listenWhen: (previous, current) =>
              previous != current &&
              (current is SaveProjectState ||
                  current is FieldRequiredErrorState ||
                  current is InvalidMilestoneDateErrorState),
          listener: (context, state) {
            if (state is FieldRequiredErrorState) {
              _showFieldValidation(
                context,
                appLocalizations!,
                state.validationEnum,
              );
            } else if (state is InvalidMilestoneDateErrorState) {
              SnackBarView.showSnackBar(
                context,
                appLocalizations!.invalidMilestoneDate,
                backgroundColor: ColorUtils.getColor(
                  context,
                  ColorEnums.redColor,
                ),
              );
            } else if (state is SaveProjectState) {
              final blocProvider = BlocProvider.of<FirebaseAddProjectBloc>(
                context,
                listen: false,
              );
              if (state.isEdited) {
                final firebaseProjectsBlocProvider =
                    BlocProvider.of<FirebaseFetchProjectsBloc>(
                  context,
                  listen: false,
                );
                final originalMilestones =
                    firebaseProjectsBlocProvider.getMilestoneInfoFromProjectId(
                  state.projectInfo.projectId,
                );
                blocProvider.add(
                  FirebaseEditProjectSaveEvent(
                    state.projectInfo,
                    state.milestoneInfo,
                    originalMilestones,
                  ),
                );
              } else {
                blocProvider.add(
                  FirebaseAddProjectSaveEvent(
                    state.projectInfo,
                    state.milestoneInfo,
                  ),
                );
              }
            }
          },
        ),
        BlocListener<FirebaseAddProjectBloc, FirebaseAddProjectState>(
          listenWhen: (previous, current) =>
              previous != current && current is ProjectCodeAlreadyTakenState,
          listener: (context, state) {
            if (state is ProjectCodeAlreadyTakenState) {
              SnackBarView.showSnackBar(
                context,
                appLocalizations!.projectCodeAlreadyTaken,
                backgroundColor: ColorUtils.getColor(
                  context,
                  ColorEnums.redColor,
                ),
              );
            }
          },
        ),
      ],
      child: BlocBuilder<AddProjectFieldBloc, AddProjectFieldState>(
        buildWhen: (previous, current) =>
            previous != current && current is LoadOtherFieldsState,
        builder: (context, state) {
          bool isLoadMoreField = false;
          isLoadMoreField = !isEdit;
          if (state is LoadOtherFieldsState) {
            isLoadMoreField = true;
          }
          return Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: ToolBar(
                title: isEdit
                    ? appLocalizations!.editProject
                    : appLocalizations!.addProject,
              ),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      controller: _scrollController,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: Dimens.screenHorizontalMargin.w,
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: Dimens.appBarContentVerticalPadding.h,
                                ),
                                _projectCodeField(
                                  appLocalizations!,
                                  addProjectFieldBloc!,
                                ),
                                _fieldBetweenSpacing(),
                                _projectNameField(
                                  appLocalizations!,
                                  addProjectFieldBloc!,
                                ),
                                _fieldBetweenSpacing(),
                                if (isEdit && !isLoadMoreField)
                                  _loadMoreFieldsWidget(
                                    context,
                                    appLocalizations!,
                                    addProjectFieldBloc!,
                                  ),
                                if (isEdit && !isLoadMoreField)
                                  _fieldBetweenSpacing(),
                                if (isLoadMoreField)
                                  _otherFields(
                                    context,
                                    appLocalizations!,
                                    addProjectFieldBloc!,
                                  ),
                              ],
                            ),
                          ),
                          BlocBuilder<AddProjectFieldBloc,
                              AddProjectFieldState>(
                            buildWhen: (previous, current) =>
                                previous != current &&
                                current is ProjectTypeChangeState,
                            builder: (context, state) {
                              return Divider(
                                height: 0,
                                color: ColorUtils.getColor(
                                  context,
                                  ColorEnums.grayD9Color,
                                ),
                              );
                            },
                          ),
                          BlocBuilder<AddProjectFieldBloc,
                              AddProjectFieldState>(
                            buildWhen: (previous, current) =>
                                previous != current &&
                                current is ProjectTypeChangeState,
                            builder: (context, state) {
                              return Milestones(
                                title: appLocalizations!.milestone,
                                isEdit: isEdit,
                                onAddMilestone: () {
                                  _scrollToBottom();
                                },
                              );
                            },
                          ),
                          if (isEdit)
                            _projectCreatedByWidget(
                              context,
                              appLocalizations!,
                              arguments,
                            ),
                        ],
                      ),
                    ),
                  ),
                  BlocListener<FirebaseAddProjectBloc, FirebaseAddProjectState>(
                    listenWhen: (previous, current) =>
                        previous != current &&
                        (current is FirebaseAddEditProjectSuccessState ||
                            current is FirebaseAddEditProjectFailedState),
                    listener: (context, state) {
                      if (state is FirebaseAddEditProjectSuccessState) {
                        SnackBarView.showSnackBar(
                          context,
                          state.isAddedNewProject
                              ? appLocalizations!.projectCreatedSuccessfully
                              : appLocalizations!.projectUpdatedSuccessfully,
                          backgroundColor: ColorUtils.getColor(
                            context,
                            ColorEnums.greenColor,
                          ),
                        );
                        Navigator.pop(context);
                      } else if (state is FirebaseAddEditProjectFailedState) {
                        SnackBarView.showSnackBar(
                          context,
                          appLocalizations!.failedToSaveProject,
                          backgroundColor: ColorUtils.getColor(
                            context,
                            ColorEnums.redColor,
                          ),
                        );
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimens.screenHorizontalMargin.w,
                        vertical: Dimens.screenHorizontalMargin.h,
                      ),
                      child: AppFilledButton(
                        title: appLocalizations!.save,
                        onButtonPressed: () {
                          if (isEdit) {
                            addProjectFieldBloc!.add(
                              EditProjectEvent(),
                            );
                          } else {
                            addProjectFieldBloc!.add(
                              AddProjectEvent(),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  _updateFieldsOnEditProject(
    ProjectInfo projectInfo,
    List<MilestoneInfo> milestones,
    AddProjectFieldBloc addProjectFieldBloc,
  ) {
    _projectCodeTextEditingController.text = projectInfo.projectCode ?? '';
    _projectNameTextEditingController.text = projectInfo.projectName ?? '';

    if (projectInfo.totalFixedAmount != null) {
      _totalFixedAmountTextEditingController.text = AppUtils.removeTrailingZero(
        projectInfo.totalFixedAmount,
      );
    } else {
      _totalFixedAmountTextEditingController.text = '';
    }

    if (projectInfo.hourlyRate != null) {
      _hourlyRateTextEditingController.text = AppUtils.removeTrailingZero(
        projectInfo.hourlyRate,
      );
    } else {
      _hourlyRateTextEditingController.text = '';
    }

    if (projectInfo.weeklyHours != null) {
      _weeklyHoursTextEditingController.text = AppUtils.removeTrailingZero(
        projectInfo.weeklyHours,
      );
    } else {
      _weeklyHoursTextEditingController.text = '';
    }

    if (projectInfo.totalHours != null) {
      _totalHoursTextEditingController.text = AppUtils.removeTrailingZero(
        projectInfo.totalHours,
      );
    } else {
      _totalHoursTextEditingController.text = '';
    }

    if (projectInfo.monthlyAmount != null) {
      _monthlyAmountTextEditingController.text = AppUtils.removeTrailingZero(
        projectInfo.monthlyAmount,
      );
    } else {
      _monthlyAmountTextEditingController.text = '';
    }

    _specialNotesTextEditingController.text = projectInfo.specialNotes ?? '';
    addProjectFieldBloc.add(
      EditProjectInitEvent(
        projectInfo,
        milestones,
      ),
    );
  }

  Widget _fieldBetweenSpacing() {
    return SizedBox(
      height: Dimens.fieldBetweenVerticalPadding.h,
    );
  }

  Widget _projectCodeField(
    AppLocalizations appLocalizations,
    AddProjectFieldBloc addProjectFieldBloc,
  ) {
    return AppTextField(
      title: '${appLocalizations.projectNo}*',
      keyboardAction: TextInputAction.next,
      keyboardType: TextInputType.number,
      inputFormatter: [
        FilteringTextInputFormatter.deny(AppUtils.regexToDenyNotADigit),
      ],
      textEditingController: _projectCodeTextEditingController,
      focusNode: _projectCodeFocusNode,
      onTextChange: (projectCode) {
        addProjectFieldBloc.add(
          ProjectCodeTextChangeEvent(projectCode),
        );
      },
    );
  }

  Widget _projectNameField(
    AppLocalizations appLocalizations,
    AddProjectFieldBloc addProjectFieldBloc,
  ) {
    return AppTextField(
      title: '${appLocalizations.projectName}*',
      textEditingController: _projectNameTextEditingController,
      onTextChange: (projectName) {
        addProjectFieldBloc.add(
          ProjectNameTextChangeEvent(projectName),
        );
      },
    );
  }

  Widget _loadMoreFieldsWidget(
    BuildContext context,
    AppLocalizations appLocalizations,
    AddProjectFieldBloc addProjectFieldBloc,
  ) {
    return InkWell(
      onTap: () {
        addProjectFieldBloc.add(LoadOtherFieldsEvent());
      },
      child: Container(
        width: double.infinity,
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
            child: Text(
              appLocalizations.loadOtherFields,
              style: TextStyle(
                color: ColorUtils.getColor(
                  context,
                  ColorEnums.black33Color,
                ),
                fontWeight: FontWeight.w700,
                fontSize: Dimens.buttonTextSize.sp,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _otherFields(
    BuildContext context,
    AppLocalizations appLocalizations,
    AddProjectFieldBloc addProjectFieldBloc,
  ) {
    return Column(
      children: [
        _bdmProjectManagerFields(
          appLocalizations,
          addProjectFieldBloc,
        ),
        _fieldBetweenSpacing(),
        ProjectType(
          title: appLocalizations.projectType,
          appLocalizations: appLocalizations,
          addProjectFieldBloc: addProjectFieldBloc,
        ),
        _fieldSpacingBasedOnProjectType(),
        _totalAmountField(
          appLocalizations,
          addProjectFieldBloc,
        ),
        _timeAndMaterialRateFields(
          appLocalizations,
          addProjectFieldBloc,
        ),
        _monthlyAmount(appLocalizations, addProjectFieldBloc),
        _fieldBetweenSpacing(),
        _otherTimeAndStatusFields(
          context,
          appLocalizations,
          addProjectFieldBloc,
        ),
      ],
    );
  }

  _otherTimeAndStatusFields(
    BuildContext context,
    AppLocalizations appLocalizations,
    AddProjectFieldBloc addProjectFieldBloc,
  ) {
    return Column(
      children: [
        _startDateAndCycleFields(
          context,
          appLocalizations,
          addProjectFieldBloc,
        ),
        _fieldBetweenSpacing(),
        _projectStatusField(appLocalizations, addProjectFieldBloc),
        _fieldBetweenSpacing(),
        _specialNotesField(
          appLocalizations,
          addProjectFieldBloc,
        ),
        _fieldBetweenSpacing(),
      ],
    );
  }

  Widget _fieldSpacingBasedOnProjectType() {
    return BlocBuilder<AddProjectFieldBloc, AddProjectFieldState>(
      buildWhen: (previous, current) =>
          previous != current &&
          (current is ProjectTypeChangeState ||
              current is LoadOtherFieldsState),
      builder: (context, state) {
        if ((state is ProjectTypeChangeState &&
                state.projectTypeEnum != ProjectTypeEnum.nonBillable) ||
            state is LoadOtherFieldsState) {
          return _fieldBetweenSpacing();
        }
        return const SizedBox();
      },
    );
  }

  Widget _bdmProjectManagerFields(
    AppLocalizations appLocalizations,
    AddProjectFieldBloc addProjectFieldBloc,
  ) {
    return Row(
      children: [
        Expanded(
          child: BlocBuilder<AddProjectFieldBloc, AddProjectFieldState>(
            buildWhen: (previous, current) =>
                previous != current && current is BDMListGeneratedState,
            builder: (context, state) {
              List<DropDownModel> list = [];
              DropDownModel? selected;
              if (state is BDMListGeneratedState) {
                list.addAll(state.bdmList);
                selected = state.defaultSelected;
              } else {
                list.addAll(addProjectFieldBloc.getBdmList());
                selected = addProjectFieldBloc.getSelectedBDM();
              }
              final profileInfo = addProjectFieldBloc.getCurrentUserRole();
              final isDisableDropDown = profileInfo != null &&
                  profileInfo.role == UserRoleEnum.bdm.name;
              return AppDropDownField(
                title: appLocalizations.bdm,
                dropDownItems: list,
                selectedItem: selected,
                isDisable: isDisableDropDown,
                onDropDownChanged: (selected) {
                  addProjectFieldBloc.add(
                    BdmInfoSelectionChangeEvent(selected),
                  );
                },
              );
            },
          ),
        ),
        SizedBox(
          width: Dimens.addProjectBDPMPadding.w,
        ),
        Expanded(
          child: BlocBuilder<AddProjectFieldBloc, AddProjectFieldState>(
            buildWhen: (previous, current) =>
                previous != current && current is PMListGeneratedState,
            builder: (context, state) {
              List<DropDownModel> list = [];
              DropDownModel? selected;
              if (state is PMListGeneratedState) {
                list.addAll(state.pmList);
                selected = state.defaultSelected;
              } else {
                list.addAll(addProjectFieldBloc.getPmList());
                selected = addProjectFieldBloc.getSelectedPM();
              }
              final profileInfo = addProjectFieldBloc.getCurrentUserRole();
              final isDisableDropDown = profileInfo != null &&
                  profileInfo.role == UserRoleEnum.projectManager.name;
              return AppDropDownField(
                title: appLocalizations.projectManager,
                dropDownItems: list,
                selectedItem: selected,
                isDisable: isDisableDropDown,
                onDropDownChanged: (selected) {
                  addProjectFieldBloc.add(
                    ProjectManagerInfoSelectionChangeEvent(
                      selected,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _totalAmountField(
    AppLocalizations appLocalizations,
    AddProjectFieldBloc addProjectFieldBloc,
  ) {
    return BlocBuilder<AddProjectFieldBloc, AddProjectFieldState>(
      buildWhen: (previous, current) =>
          previous != current && current is ProjectTypeChangeState,
      builder: (context, state) {
        if (state is ProjectTypeChangeState &&
            state.projectTypeEnum == ProjectTypeEnum.fixed) {
          final List<DropDownModel> list =
              addProjectFieldBloc.getCurrencySymbols();
          return AppCurrencyField(
            title: appLocalizations.totalAmount,
            focusNode: _totalAmountFocusNode,
            dropDownItems: list,
            selectedItem: _getSelectedCurrencyItem(list),
            textEditingController: _totalFixedAmountTextEditingController,
            onDropDownChanged: (selected) {
              addProjectFieldBloc.add(CurrencyChangeEvent(selected.id));
            },
            onTextChanged: (totalAmount) {
              addProjectFieldBloc.add(TotalFixedAmountChangeEvent(totalAmount));
            },
          );
        }
        return const SizedBox();
      },
    );
  }

  DropDownModel? _getSelectedCurrencyItem(List<DropDownModel> list) {
    DropDownModel? selectedItem;
    if (list.isNotEmpty) {
      final index = list.indexWhere((element) => element.isSelected);
      if (index != -1) {
        selectedItem = list[index];
      } else {
        selectedItem = list[0];
      }
    }
    return selectedItem;
  }

  Widget _timeAndMaterialRateFields(
    AppLocalizations appLocalizations,
    AddProjectFieldBloc addProjectFieldBloc,
  ) {
    return BlocBuilder<AddProjectFieldBloc, AddProjectFieldState>(
      buildWhen: (previous, current) =>
          previous != current && current is ProjectTypeChangeState,
      builder: (context, state) {
        if (state is ProjectTypeChangeState &&
            state.projectTypeEnum == ProjectTypeEnum.timeAndMaterial) {
          final List<DropDownModel> list =
              addProjectFieldBloc.getCurrencySymbols();
          return Row(
            children: [
              Expanded(
                child: AppCurrencyField(
                  title: appLocalizations.hourlyRate,
                  focusNode: _hourlyRateFocusNode,
                  dropDownItems: list,
                  selectedItem: _getSelectedCurrencyItem(list),
                  textEditingController: _hourlyRateTextEditingController,
                  onDropDownChanged: (selected) {
                    addProjectFieldBloc.add(CurrencyChangeEvent(selected.id));
                  },
                  onTextChanged: (hourlyRate) {
                    addProjectFieldBloc.add(
                      HourlyRateChangeEvent(hourlyRate),
                    );
                  },
                  inputLengthLimit: AppConfig.hourlyRateInputLengthLimit,
                ),
              ),
              SizedBox(
                width: Dimens.addProjectTimeMaterialPadding.w,
              ),
              Expanded(
                child: AppTextField(
                  title: appLocalizations.weeklyHours,
                  focusNode: _weeklyHoursFocusNode,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  keyboardAction: TextInputAction.next,
                  textEditingController: _weeklyHoursTextEditingController,
                  inputFormatter: [
                    FilteringTextInputFormatter.deny(
                      AppUtils.regexToDenyComma,
                    ),
                    DecimalTextInputFormatter(
                      decimalRange: AppConfig.decimalTextFieldInputLength,
                    ),
                  ],
                  onTextChange: (weeklyHours) {
                    addProjectFieldBloc.add(
                      WeeklyHoursChangeEvent(weeklyHours),
                    );
                  },
                ),
              ),
              SizedBox(
                width: Dimens.addProjectTimeMaterialPadding.w,
              ),
              Expanded(
                child: AppTextField(
                  title: appLocalizations.totalHours,
                  focusNode: _totalHoursFocusNode,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  keyboardAction: TextInputAction.done,
                  textEditingController: _totalHoursTextEditingController,
                  inputFormatter: [
                    FilteringTextInputFormatter.deny(
                      AppUtils.regexToDenyComma,
                    ),
                    DecimalTextInputFormatter(
                      decimalRange: AppConfig.decimalTextFieldInputLength,
                    ),
                    LengthLimitingTextInputFormatter(
                      AppConfig.monthlyAmountMaxLength,
                    ),
                  ],
                  onTextChange: (totalHours) {
                    addProjectFieldBloc.add(
                      TotalHoursChangeEvent(totalHours),
                    );
                  },
                ),
              ),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _monthlyAmount(
    AppLocalizations appLocalizations,
    AddProjectFieldBloc addProjectFieldBloc,
  ) {
    return BlocBuilder<AddProjectFieldBloc, AddProjectFieldState>(
      buildWhen: (previous, current) =>
          previous != current && current is ProjectTypeChangeState,
      builder: (context, state) {
        if (state is ProjectTypeChangeState &&
            state.projectTypeEnum == ProjectTypeEnum.retainer) {
          final List<DropDownModel> list =
              addProjectFieldBloc.getCurrencySymbols();
          return AppCurrencyField(
            title: appLocalizations.monthlyAmount,
            focusNode: _monthlyAmountFocusNode,
            dropDownItems: list,
            selectedItem: _getSelectedCurrencyItem(list),
            textEditingController: _monthlyAmountTextEditingController,
            onDropDownChanged: (selected) {
              addProjectFieldBloc.add(CurrencyChangeEvent(selected.id));
            },
            onTextChanged: (monthlyAmount) {
              addProjectFieldBloc.add(
                MonthlyRetainerAmountChangeEvent(monthlyAmount),
              );
            },
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _startDateAndCycleFields(
    BuildContext context,
    AppLocalizations appLocalizations,
    AddProjectFieldBloc addProjectFieldBloc,
  ) {
    return BlocBuilder<AddProjectFieldBloc, AddProjectFieldState>(
      buildWhen: (previous, current) =>
          previous != current && current is ProjectTypeChangeState,
      builder: (context, state) {
        final paymentCycle = addProjectFieldBloc.getPaymentCycle();
        final index = paymentCycle.indexWhere((element) => element.isSelected);
        return Row(
          children: [
            Expanded(
              child: BlocBuilder<AddProjectFieldBloc, AddProjectFieldState>(
                buildWhen: (previous, current) =>
                    previous != current &&
                    current is ProjectStartDateChangeState,
                builder: (context, state) {
                  DateTime startDate;
                  if (state is ProjectStartDateChangeState) {
                    startDate = state.selectedDate;
                  } else {
                    startDate = addProjectFieldBloc.getProjectStartDate() ??
                        DateTime.now();
                  }
                  _projectStartDateTextEditingController.text =
                      DateFormat(AppConfig.projectStartDateFormat)
                          .format(startDate);
                  return GestureDetector(
                    onTap: () async {
                      final currentDate = DateTime.now();
                      final firstDate = currentDate.subtract(
                        const Duration(
                          days: AppConfig.projectStartDatePastDays,
                        ),
                      );
                      final lastDate = currentDate.add(
                        const Duration(
                          days: AppConfig.datePickerFutureDays,
                        ),
                      );
                      final changedDate = await AppDatePicker.selectDate(
                        context: context,
                        selectedDate: startDate,
                        calendarFirstDate: firstDate,
                        calendarLastDate: lastDate,
                      );
                      if (changedDate != null) {
                        addProjectFieldBloc.add(
                          ProjectStartDateChangeEvent(changedDate),
                        );
                      }
                    },
                    child: AbsorbPointer(
                      child: AppTextField(
                        title: appLocalizations.startDate,
                        suffixIcon: SvgPicture.asset(
                          Strings.date,
                          fit: BoxFit.scaleDown,
                        ),
                        isReadOnly: true,
                        textEditingController:
                            _projectStartDateTextEditingController,
                        onTextChange: (startDate) {},
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: Dimens.addProjectBDPMPadding.w,
            ),
            Expanded(
              child: AppDropDownField(
                title: appLocalizations.paymentCycles,
                dropDownItems: paymentCycle,
                selectedItem: index != -1 ? paymentCycle[index] : null,
                onDropDownChanged: (selected) {
                  addProjectFieldBloc.add(
                    PaymentCycleDaysChangeEvent(selected),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _projectStatusField(
    AppLocalizations appLocalizations,
    AddProjectFieldBloc addProjectFieldBloc,
  ) {
    return BlocBuilder<AddProjectFieldBloc, AddProjectFieldState>(
      buildWhen: (previous, current) =>
          previous != current && current is ProjectTypeChangeState,
      builder: (context, state) {
        return ProjectStatus(
          title: appLocalizations.projectStatus,
          appLocalizations: appLocalizations,
          addProjectFieldBloc: addProjectFieldBloc,
        );
      },
    );
  }

  Widget _specialNotesField(
    AppLocalizations appLocalizations,
    AddProjectFieldBloc addProjectFieldBloc,
  ) {
    return BlocBuilder<AddProjectFieldBloc, AddProjectFieldState>(
      buildWhen: (previous, current) =>
          previous != current && current is ProjectTypeChangeState,
      builder: (context, state) {
        return AppTextField(
          title: appLocalizations.specialNotes,
          keyboardAction: TextInputAction.next,
          isMultiLine: true,
          textEditingController: _specialNotesTextEditingController,
          maxLine: 2,
          onTextChange: (specialNotes) {
            addProjectFieldBloc.add(SpecialNotesTextChangeEvent(specialNotes));
          },
        );
      },
    );
  }

  Widget _projectCreatedByWidget(
    BuildContext context,
    AppLocalizations appLocalizations,
    Object? data,
  ) {
    final firebaseProjectsBlocProvider =
        BlocProvider.of<FirebaseFetchProjectsBloc>(
      context,
      listen: false,
    );
    final projectInfo =
        firebaseProjectsBlocProvider.getProjectInfoFromProjectId(
      data as String?,
    );
    return FutureBuilder(
        future: _getCurrentUserId(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            String createdBy = appLocalizations.unknown;
            if (projectInfo?.createdByName != null) {
              if (projectInfo?.createdBy == snapshot.data) {
                createdBy = appLocalizations.you;
              } else {
                createdBy = projectInfo!.createdByName!;
              }
            }
            return Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: Dimens.screenHorizontalMargin.w,
                vertical: Dimens.editProjectCreatedByTextVerticalPadding.h,
              ),
              alignment: Alignment.centerLeft,
              child: Text(
                appLocalizations.createdBy(
                  createdBy,
                  DateFormat(AppConfig.projectStartDateFormat).format(
                    DateTime.fromMillisecondsSinceEpoch(
                      projectInfo?.createdAt ?? 0,
                    ),
                  ),
                ),
                style: TextStyle(
                  color: ColorUtils.getColor(
                    context,
                    ColorEnums.black33Color,
                  ),
                  fontStyle: FontStyle.italic,
                  fontSize: Dimens.editProjectCreatedByTextSize.sp,
                ),
              ),
            );
          }
          return const SizedBox();
        });
  }

  Future<String?> _getCurrentUserId() async {
    final preference = await SharedPreferences.getInstance();
    return preference.getString(PreferenceConfig.userIdPref);
  }

  _showFieldValidation(
    BuildContext context,
    AppLocalizations appLocalizations,
    ProjectFieldValidationEnum validationEnum,
  ) {
    String errorMessage = '';
    if (validationEnum == ProjectFieldValidationEnum.projectNo) {
      errorMessage = appLocalizations.enterProjectNo;
    } else if (validationEnum == ProjectFieldValidationEnum.projectName) {
      errorMessage = appLocalizations.enterProjectName;
    }
    SnackBarView.showSnackBar(
      context,
      errorMessage,
      backgroundColor: ColorUtils.getColor(
        context,
        ColorEnums.redColor,
      ),
    );
  }

  _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(
        milliseconds: 300,
      ),
      curve: Curves.easeOut,
    );
  }
}
