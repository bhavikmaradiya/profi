import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:profi/profile/model/profile_info.dart';

import './bloc/add_user_bloc.dart';
import '../app_models/drop_down_model.dart';
import '../app_widgets/app_drop_down_field.dart';
import '../app_widgets/app_filled_button.dart';
import '../app_widgets/app_text_field.dart';
import '../app_widgets/app_tool_bar.dart';
import '../app_widgets/loading_progress.dart';
import '../app_widgets/snack_bar_view.dart';
import '../const/dimens.dart';
import '../enums/color_enums.dart';
import '../enums/user_role_enums.dart';
import '../utils/app_utils.dart';
import '../utils/color_utils.dart';

class AddUser extends StatefulWidget {
  AddUser({super.key});

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  AddUserBloc? _addUserBlocProvider;
  AppLocalizations? appLocalizations;
  bool isEdit = false;
  final _nameTextEditingController = TextEditingController();
  final _emailTextEditingController = TextEditingController();
  final _passwordTextEditingController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    appLocalizations ??= AppLocalizations.of(context)!;
    if (_addUserBlocProvider == null) {
      final arguments =
          ModalRoute.of(context)?.settings.arguments as ProfileInfo?;
      _addUserBlocProvider = BlocProvider.of<AddUserBloc>(
        context,
        listen: false,
      );

      if (arguments != null) {
        _initEditData(arguments);
      }
    }
  }

  _initEditData(ProfileInfo profileInfo) {
    isEdit = true;
    _nameTextEditingController.text = profileInfo.name ?? '';
    _emailTextEditingController.text = profileInfo.email ?? '';
    _addUserBlocProvider?.add(EditUserInitEvent(profileInfo));
  }

  @override
  Widget build(BuildContext context) {
    final userRoleList = UserRoleEnum.values
        .mapIndexed(
          (i, e) => DropDownModel(
            id: i,
            value: AppUtils.getUserRoleString(appLocalizations!, e.name),
            uniqueId: e.name,
          ),
        )
        .toList();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ToolBar(
          title:
              isEdit ? appLocalizations!.editUser : appLocalizations!.addUser,
        ),
      ),
      body: SafeArea(
        child: BlocListener<AddUserBloc, AddUserState>(
          listenWhen: (previous, current) =>
              previous != current && current is! AddUserInitial,
          listener: (context, state) {
            _listenAddUserStates(context, state, appLocalizations!);
          },
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Dimens.screenHorizontalMargin.w,
                vertical: Dimens.appBarContentVerticalPadding.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    title: '${appLocalizations!.name}*',
                    textEditingController: _nameTextEditingController,
                    keyboardType: TextInputType.text,
                    keyboardAction: TextInputAction.next,
                    onTextChange: (name) {},
                  ),
                  SizedBox(
                    height: Dimens.addUserFieldVerticalPadding.h,
                  ),
                  if (userRoleList.isNotEmpty)
                    BlocBuilder<AddUserBloc, AddUserState>(
                      buildWhen: (prev, current) =>
                          current is UserRoleSelectedState,
                      builder: (_, state) {
                        DropDownModel? selected;
                        if (state is UserRoleSelectedState) {
                          final userRole = userRoleList.firstWhereOrNull(
                              (element) =>
                                  (element.uniqueId ?? '') ==
                                  state.selected.name);
                          selected = userRole;
                        }
                        return AppDropDownField(
                          title: '${appLocalizations!.userRole}*',
                          dropDownItems: userRoleList,
                          selectedItem: selected,
                          onDropDownChanged: (selected) {
                            final userRole = UserRoleEnum.values
                                .firstWhereOrNull((element) =>
                                    element.name == (selected.uniqueId ?? ''));
                            if (userRole != null) {
                              _addUserBlocProvider?.add(
                                UserRoleSelectionEvent(userRole),
                              );
                            }
                          },
                        );
                      },
                    ),
                  if (userRoleList.isNotEmpty)
                    SizedBox(
                      height: Dimens.addUserFieldVerticalPadding.h,
                    ),
                  AppTextField(
                    title: '${appLocalizations!.email}*',
                    textEditingController: _emailTextEditingController,
                    keyboardType: TextInputType.emailAddress,
                    keyboardAction: TextInputAction.next,
                    isReadOnly: isEdit,
                    isEnabled: !isEdit,
                    onTextChange: (email) {},
                  ),
                  SizedBox(
                    height: Dimens.addUserFieldVerticalPadding.h,
                  ),
                  BlocBuilder<AddUserBloc, AddUserState>(
                    buildWhen: (previous, current) =>
                        previous != current &&
                        current is VisibleInvisiblePasswordFieldState,
                    builder: (context, state) {
                      final passwordVisibleState =
                          state is VisibleInvisiblePasswordFieldState &&
                              state.isVisible;
                      return AppTextField(
                        title: '${appLocalizations!.password}*',
                        textEditingController: _passwordTextEditingController,
                        keyboardType: TextInputType.visiblePassword,
                        isReadOnly: isEdit,
                        isEnabled: !isEdit,
                        isPassword: !passwordVisibleState,
                        suffixIcon: IconButton(
                          icon: Icon(
                            passwordVisibleState
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          color: ColorUtils.getColor(
                            context,
                            ColorEnums.gray99Color,
                          ),
                          onPressed: () {
                            _addUserBlocProvider?.add(
                              VisibleInvisiblePasswordFieldEvent(
                                !passwordVisibleState,
                              ),
                            );
                          },
                        ),
                        onTextChange: (password) {},
                      );
                    },
                  ),
                  if (!isEdit)
                    SizedBox(
                      height: Dimens.addUserPasswordAndHintBetweenSpacing.h,
                    ),
                  if (!isEdit)
                    Text(
                      appLocalizations!.passwordHint,
                      style: TextStyle(
                        color: ColorUtils.getColor(
                          context,
                          ColorEnums.black00Color,
                        ),
                        fontSize: Dimens.addUserPasswordHintTextSize.sp,
                      ),
                    ),
                  SizedBox(
                    height: Dimens.addUserFieldVerticalPadding.h * 2,
                  ),
                  AppFilledButton(
                    title: isEdit
                        ? appLocalizations!.updateUserBtn
                        : appLocalizations!.addUserBtn,
                    onButtonPressed: () {
                      _onSubmit(_addUserBlocProvider);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _onSubmit(AddUserBloc? addUserBlocProvider) {
    final name = _nameTextEditingController.text.toString().trim();
    final email = _emailTextEditingController.text.toString().trim();
    final password = _passwordTextEditingController.text.toString().trim();
    addUserBlocProvider?.add(
      CreateUserEvent(
        email: email,
        password: password,
        name: name,
      ),
    );
  }

  _listenAddUserStates(
    BuildContext context,
    AddUserState state,
    AppLocalizations appLocalizations,
  ) {
    LoadingProgress.showHideProgress(
      context,
      state is CreateUserLoadingState,
    );
    if (state is CreateUserFailedState) {
      String message = state.message;
      if (message == 'email-already-in-use') {
        message = appLocalizations.emailAlreadyInUse;
      }
      SnackBarView.showSnackBar(
        context,
        message,
        backgroundColor: ColorUtils.getColor(
          context,
          ColorEnums.redColor,
        ),
      );
    } else if (state is InvalidEmailFieldErrorState) {
      final isEmpty = _emailTextEditingController.text.trim().isEmpty;
      SnackBarView.showSnackBar(
        context,
        isEmpty ? appLocalizations.enterEmail : appLocalizations.invalidEmail,
        backgroundColor: ColorUtils.getColor(
          context,
          ColorEnums.redColor,
        ),
      );
    } else if (state is InvalidPasswordFieldErrorState) {
      final isEmpty = _passwordTextEditingController.text.trim().isEmpty;
      SnackBarView.showSnackBar(
        context,
        isEmpty
            ? appLocalizations.enterPassword
            : appLocalizations.invalidPassword,
        backgroundColor: ColorUtils.getColor(
          context,
          ColorEnums.redColor,
        ),
      );
    } else if (state is InvalidNameFieldErrorState) {
      SnackBarView.showSnackBar(
        context,
        appLocalizations.enterName,
        backgroundColor: ColorUtils.getColor(
          context,
          ColorEnums.redColor,
        ),
      );
    } else if (state is InvalidRoleFieldErrorState) {
      SnackBarView.showSnackBar(
        context,
        appLocalizations.invalidRole,
        backgroundColor: ColorUtils.getColor(
          context,
          ColorEnums.redColor,
        ),
      );
    } else if (state is CreateUserSuccessState) {
      SnackBarView.showSnackBar(
        context,
        state.isEdit
            ? appLocalizations.userUpdatedSuccess
            : appLocalizations.userCreatedSuccess,
        backgroundColor: ColorUtils.getColor(
          context,
          ColorEnums.greenColor,
        ),
      );
      Navigator.pop(context);
    }
  }
}
