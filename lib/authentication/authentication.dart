import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import './field_validation_bloc/auth_field_validation_bloc.dart';
import './firebase_auth_bloc/firebase_auth_bloc.dart';
import '../app_widgets/app_filled_button.dart';
import '../app_widgets/app_text_field.dart';
import '../app_widgets/loading_progress.dart';
import '../app_widgets/snack_bar_view.dart';
import '../const/dimens.dart';
import '../const/strings.dart';
import '../enums/color_enums.dart';
import '../routes.dart';
import '../utils/color_utils.dart';

class Authentication extends StatelessWidget {
  final _emailTextEditingController = TextEditingController();
  final _passwordTextEditingController = TextEditingController();

  Authentication({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: BlocListener<FirebaseAuthBloc, FirebaseAuthState>(
          listenWhen: (previous, current) =>
              previous != current && current is! FirebaseAuthInitialState,
          listener: (context, state) {
            _onAuthStateChangeListener(context, state, appLocalizations);
          },
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _welcomeWidget(
                  context,
                  appLocalizations,
                ),
                SizedBox(
                  height: Dimens.loginBannerContentSpacing.h,
                ),
                _loginContentWidget(
                  context,
                  appLocalizations,
                ),
                SizedBox(
                  height: Dimens.loginForgotPassInfoPadding.h,
                ),
                _otherContent(context, appLocalizations),
                SizedBox(
                  height: Dimens.loginCopyrightTopPadding.h,
                ),
                _copyrightWidget(
                  context,
                  appLocalizations,
                ),
                SizedBox(
                  height: Dimens.loginCopyrightBottomPadding.h,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _welcomeWidget(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return Container(
      width: double.infinity,
      height: Dimens.authWelcomeMenuHeight.h,
      color: ColorUtils.getColor(
        context,
        ColorEnums.grayF5Color,
      ),
      child: Column(
        children: [
          SizedBox(
            height: Dimens.loginBannerVerticalPadding.h,
          ),
          Image.asset(
            Strings.loginBanner,
            width: Dimens.loginBannerSize.w,
            height: Dimens.loginBannerSize.h,
          ),
          SizedBox(
            height: Dimens.loginBannerWelcomeTextPadding.h,
          ),
          Text(
            appLocalizations.welcome,
            style: TextStyle(
              fontSize: Dimens.loginWelcomeTextSize.sp,
              fontWeight: FontWeight.w700,
              color: ColorUtils.getColor(
                context,
                ColorEnums.black1AColor,
              ),
            ),
          ),
          Text(
            appLocalizations.gladToSeeYou,
            style: TextStyle(
              fontSize: Dimens.loginGladToSeeYouTextSize.sp,
              fontWeight: FontWeight.w500,
              color: ColorUtils.getColor(
                context,
                ColorEnums.gray6CColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loginContentWidget(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    final authFieldBlocProvider = BlocProvider.of<AuthFieldValidationBloc>(
      context,
      listen: false,
    );
    final firebaseAuthBlocProvider = BlocProvider.of<FirebaseAuthBloc>(
      context,
      listen: false,
    );
    final errorTextStyle = TextStyle(
      color: ColorUtils.getColor(
        context,
        ColorEnums.redColor,
      ),
      fontSize: Dimens.loginErrorTextSize.sp,
    );
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.screenHorizontalMargin.w,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            appLocalizations.login,
            style: TextStyle(
              fontSize: Dimens.loginTitleTextSize.sp,
              color: ColorUtils.getColor(
                context,
                ColorEnums.black33Color,
              ),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(
            width: Dimens.loginUnderLineWidth.w,
            child: Divider(
              color: ColorUtils.getColor(
                context,
                ColorEnums.grayE0Color,
              ),
              thickness: Dimens.loginUnderLineHeight.h,
            ),
          ),
          SizedBox(
            height: Dimens.loginFieldVerticalPadding.h,
          ),
          AppTextField(
            title: appLocalizations.email,
            textEditingController: _emailTextEditingController,
            keyboardType: TextInputType.emailAddress,
            keyboardAction: TextInputAction.next,
            onTextChange: (email) {
              authFieldBlocProvider.add(
                EmailIdFieldTextChangeEvent(
                  email,
                ),
              );
            },
          ),
          BlocBuilder<AuthFieldValidationBloc, AuthFieldValidationState>(
            buildWhen: (previous, current) =>
                previous != current &&
                (current is InvalidEmailFieldErrorState ||
                    current is ValidEmailFieldState),
            builder: (context, state) {
              if (state is InvalidEmailFieldErrorState) {
                return Text(
                  appLocalizations.invalidEmail,
                  style: errorTextStyle,
                );
              }
              return const SizedBox();
            },
          ),
          SizedBox(
            height: Dimens.loginFieldVerticalPadding.h,
          ),
          BlocBuilder<AuthFieldValidationBloc, AuthFieldValidationState>(
            buildWhen: (previous, current) =>
                previous != current &&
                (current is VisiblePasswordFieldState ||
                    current is InVisiblePasswordFieldState),
            builder: (context, state) {
              final passwordVisibleState = state is VisiblePasswordFieldState;
              return AppTextField(
                title: appLocalizations.password,
                textEditingController: _passwordTextEditingController,
                keyboardType: TextInputType.visiblePassword,
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
                    authFieldBlocProvider.add(passwordVisibleState
                        ? InVisiblePasswordFieldEvent()
                        : VisiblePasswordFieldEvent());
                  },
                ),
                onTextChange: (password) {
                  /*authFieldBlocProvider.add(
                    PasswordFieldTextChangeEvent(
                      password,
                    ),
                  );*/
                },
              );
            },
          ),
          BlocBuilder<AuthFieldValidationBloc, AuthFieldValidationState>(
            buildWhen: (previous, current) =>
                previous != current &&
                (current is InvalidPasswordFieldErrorState ||
                    current is ValidPasswordFieldState),
            builder: (context, state) {
              if (state is InvalidPasswordFieldErrorState) {
                return Text(
                  appLocalizations.invalidPasswordLength,
                  style: errorTextStyle,
                );
              }
              return const SizedBox();
            },
          ),
          SizedBox(
            height: Dimens.loginFieldVerticalPadding.h,
          ),
          AppFilledButton(
            title: appLocalizations.loginBtn,
            onButtonPressed: () {
              _onLoginButtonClicked(
                authFieldBlocProvider,
                firebaseAuthBlocProvider,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _otherContent(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return Column(
      children: [
        Text(
          appLocalizations.inCaseForgotPass,
          style: TextStyle(
            fontSize: Dimens.loginForgotPasswordTextSize.sp,
            color: ColorUtils.getColor(
              context,
              ColorEnums.gray6CColor,
            ),
          ),
        ),
        Text(
          appLocalizations.contactToAdmin,
          style: TextStyle(
            fontSize: Dimens.loginForgotPasswordTextSize.sp,
            color: ColorUtils.getColor(
              context,
              ColorEnums.black33Color,
            ),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _copyrightWidget(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return Text(
      appLocalizations.copyRight,
      style: TextStyle(
        fontSize: Dimens.loginCopyrightTextSize.sp,
        color: ColorUtils.getColor(
          context,
          ColorEnums.black1AColor,
        ),
      ),
    );
  }

  _onLoginButtonClicked(
    AuthFieldValidationBloc authFieldBlocProvider,
    FirebaseAuthBloc firebaseAuthBlocProvider,
  ) {
    final email = _emailTextEditingController.text.toString().trim();
    final password = _passwordTextEditingController.text.toString();
    if (email.isEmpty && password.isEmpty) {
      authFieldBlocProvider.add(
        EmailIdFieldTextChangeEvent(
          email,
        ),
      );
      authFieldBlocProvider.add(
        PasswordFieldTextChangeEvent(
          password,
        ),
      );
      return;
    }
    else if (email.isEmpty) {
      authFieldBlocProvider.add(
        EmailIdFieldTextChangeEvent(
          email,
        ),
      );
      return;
    }
    else if (password.isEmpty) {
      authFieldBlocProvider.add(
        PasswordFieldTextChangeEvent(
          password,
        ),
      );
      return;
    } else {
      authFieldBlocProvider.add(
        EmailIdFieldTextChangeEvent(
          email,
        ),
      );
      authFieldBlocProvider.add(
        PasswordFieldTextChangeEvent(
          password,
        ),
      );
    }
    firebaseAuthBlocProvider.add(
      VerifyFirebaseAuthEvent(
        email,
        password,
      ),
    );
  }

  _onAuthStateChangeListener(
    BuildContext context,
    FirebaseAuthState state,
    AppLocalizations appLocalizations,
  ) {
    LoadingProgress.showHideProgress(
      context,
      state is FirebaseAuthLoadingState,
    );
    if (state is FirebaseLoginInvalidUserState) {
      // invalid user
      SnackBarView.showSnackBar(context, appLocalizations.userNotFound);
    } else if (state is FirebaseLoginInvalidPasswordState) {
      // invalid password
      SnackBarView.showSnackBar(
        context,
        appLocalizations.invalidFirebasePassword,
      );
    } else if (state is FirebaseLoginFailedState) {
      // failed with firebase message
      SnackBarView.showSnackBar(
        context,
        state.errorMessage ?? appLocalizations.somethingWentWrong,
      );
    } else if (state is FirebaseLoginSuccessProfileState) {
      // success
      SnackBarView.showSnackBar(context, appLocalizations.loginSuccess);
      Navigator.pushReplacementNamed(context, Routes.profile);
    } else if (state is FirebaseLoginSuccessHomeState) {
      SnackBarView.showSnackBar(context, appLocalizations.loginSuccess);
      Navigator.pushReplacementNamed(context, Routes.dashboard);
    }
  }
}
