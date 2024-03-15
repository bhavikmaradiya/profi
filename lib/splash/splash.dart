import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import './bloc/splash_bloc.dart';
import '../const/dimens.dart';
import '../const/strings.dart';
import '../enums/color_enums.dart';
import '../routes.dart';
import '../utils/color_utils.dart';

class Splash extends StatelessWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    return BlocListener<SplashBloc, SplashState>(
      listenWhen: (previous, current) =>
          previous != current && current is! SplashInitialState,
      listener: (context, state) {
        if (state is SplashNavigationState) {
          final route = state.routeName;
          switch (route) {
            case Routes.authentication:
              _navigateToAuthentication(context);
              break;
            case Routes.profile:
              _navigateToProfile(context);
              break;
            case Routes.dashboard:
              _navigateToHome(context);
              break;
            default:
              _navigateToAuthentication(context);
              break;
          }
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: SvgPicture.asset(
                  Strings.splash,
                  fit: BoxFit.fill,
                ),
              ),
              Center(
                child: Container(
                  margin: EdgeInsets.only(
                    bottom: Dimens.splashTextMarginBottom.h,
                  ),
                  child: Text(
                    appLocalizations.appName,
                    style: TextStyle(
                      color: ColorUtils.getColor(
                        context,
                        ColorEnums.black1AColor,
                      ),
                      fontWeight: FontWeight.w700,
                      fontSize: Dimens.splashTextSize.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _navigateToAuthentication(BuildContext context) {
    Navigator.pushReplacementNamed(context, Routes.authentication);
  }

  _navigateToProfile(BuildContext context) {
    Navigator.pushReplacementNamed(context, Routes.profile);
  }

  _navigateToHome(BuildContext context) {
    Navigator.pushReplacementNamed(context, Routes.dashboard);
  }
}
