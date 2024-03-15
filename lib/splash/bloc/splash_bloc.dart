import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/app_config.dart';
import '../../config/preference_config.dart';
import '../../routes.dart';

part 'splash_event.dart';

part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final _firebaseAuthInstance = FirebaseAuth.instance;

  SplashBloc() : super(SplashInitialState()) {
    on<SplashInitialEvent>(_initialEvent);
    add(SplashInitialEvent());
  }

  _initialEvent(
    SplashInitialEvent event,
    Emitter<SplashState> emit,
  ) async {
    await Future.delayed(const Duration(seconds: AppConfig.splashDuration));
    final currentUser = _firebaseAuthInstance.currentUser;
    if (currentUser != null) {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString(PreferenceConfig.userNamePref);
      if (name == null || name.trim().isEmpty) {
        if (AppConfig.autoRegisterWithLogin) {
          emit(SplashNavigationState(Routes.profile));
        } else {
          emit(SplashNavigationState(Routes.authentication));
        }
      } else {
        emit(SplashNavigationState(Routes.dashboard));
      }
    } else {
      emit(SplashNavigationState(Routes.authentication));
    }
  }
}
