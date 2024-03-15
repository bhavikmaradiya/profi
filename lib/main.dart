import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import './authentication/field_validation_bloc/auth_field_validation_bloc.dart';
import './authentication/firebase_auth_bloc/firebase_auth_bloc.dart';
import './config/app_config.dart';
import './config/theme_config.dart';
import './const/strings.dart';
import './env.dart';
import './inward_transactions/bloc/transaction_bloc.dart';
import './profile/profile_bloc/profile_bloc.dart';
import './project_list/fetch_projects_bloc/firebase_fetch_projects_bloc.dart';
import './routes.dart';
import './settings/bloc/settings_bloc.dart';
import './splash/bloc/splash_bloc.dart';
import './splash/splash.dart';

late NotificationAppLaunchDetails notificationLaunch;
final FlutterLocalNotificationsPlugin notificationPlugin =
    FlutterLocalNotificationsPlugin();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SplashBloc()),
        BlocProvider(create: (_) => AuthFieldValidationBloc()),
        BlocProvider(create: (_) => FirebaseAuthBloc()),
        BlocProvider(create: (_) => ProfileBloc()),
        BlocProvider(create: (_) => FirebaseFetchProjectsBloc()),
        BlocProvider(create: (_) => TransactionBloc()),
        BlocProvider(create: (_) => SettingsBloc())
      ],
      child: ScreenUtilInit(
        designSize: const Size(
          AppConfig.figmaScreenWidth,
          AppConfig.figmaScreenHeight,
        ),
        minTextAdapt: true,
        splitScreenMode: true,
        child: MaterialApp(
          debugShowCheckedModeBanner:
              AppEnvironment.environment == Environment.dev,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale(Strings.englishLocale, ''),
          ],
          routes: Routes.routeList,
          navigatorKey: navigatorKey,
          themeMode: ThemeMode.light,
          theme: ThemeConfig.lightTheme,
          darkTheme: ThemeConfig.darkTheme,
          home: const Splash(),
        ),
      ),
    );
  }
}
