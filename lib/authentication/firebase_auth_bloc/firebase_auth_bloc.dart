import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/app_config.dart';
import '../../config/firestore_config.dart';
import '../../config/preference_config.dart';
import '../../profile/model/profile_info.dart';

part 'firebase_auth_event.dart';

part 'firebase_auth_state.dart';

class FirebaseAuthBloc extends Bloc<FirebaseAuthEvent, FirebaseAuthState> {
  final _firebaseAuthInstance = FirebaseAuth.instance;

  FirebaseAuthBloc() : super(FirebaseAuthInitialState()) {
    on<VerifyFirebaseAuthEvent>(_signInWithEmailPassword);
  }

  _signInWithEmailPassword(
    VerifyFirebaseAuthEvent event,
    Emitter<FirebaseAuthState> emit,
  ) async {
    emit(FirebaseAuthLoadingState());
    try {
      final email = event.email;
      final UserCredential userCredentials =
          await _firebaseAuthInstance.signInWithEmailAndPassword(
        email: email,
        password: event.password,
      );
      await _fetchFirebaseProfileInfo(event, emit, userCredentials);
    } on FirebaseAuthException catch (ex) {
      if (ex.code == 'user-not-found') {
        if (AppConfig.autoRegisterWithLogin) {
          await _createUserWithEmailPassword(event, emit);
        }
        emit(FirebaseLoginInvalidUserState());
      } else if (ex.code == 'wrong-password') {
        emit(FirebaseLoginInvalidPasswordState());
      } else {
        emit(FirebaseLoginFailedState(ex.message));
      }
    }
  }

  _fetchFirebaseProfileInfo(
    VerifyFirebaseAuthEvent event,
    Emitter<FirebaseAuthState> emit,
    UserCredential userCredentials,
  ) async {
    if (userCredentials.user != null) {
      final firebaseUserId = userCredentials.user!.uid;
      final email = userCredentials.user!.email;
      final profileInfo = await _fetchProfileInfoFromFirebase(firebaseUserId);
      if (profileInfo != null) {
        await _saveProfileInfo(profileInfo);
        emit(FirebaseLoginSuccessHomeState());
      } else {
        await _saveProfileInfo(ProfileInfo(userId: firebaseUserId, email: email));
        emit(FirebaseLoginSuccessProfileState());
      }
    } else {
      emit(FirebaseLoginFailedState(null));
    }
  }

  Future<ProfileInfo?> _fetchProfileInfoFromFirebase(
    String firebaseUserId,
  ) async {
    final user = await FirebaseFirestore.instance
        .collection(FireStoreConfig.userCollection)
        .doc(firebaseUserId)
        .get();
    ProfileInfo? profileInfo;
    try {
      profileInfo = ProfileInfo.fromSnapshot(user);
    } on Exception catch (_) {}
    return profileInfo;
  }

  _createUserWithEmailPassword(
    VerifyFirebaseAuthEvent event,
    Emitter<FirebaseAuthState> emit,
  ) async {
    emit(FirebaseAuthLoadingState());
    try {
      final userCredentials =
          await _firebaseAuthInstance.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      emit(FirebaseRegisterSuccessState());
      await _fetchFirebaseProfileInfo(event, emit, userCredentials);
    } on FirebaseAuthException catch (ex) {
      if (ex.code == 'email-already-in-use') {
        emit(FirebaseRegisterEmailAlreadyInUseState());
      } else {
        emit(FirebaseRegisterFailedState(ex.message));
      }
    }
  }

  _saveProfileInfo(ProfileInfo profileInfo) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(PreferenceConfig.userIdPref, profileInfo.userId ?? '');
    prefs.setString(PreferenceConfig.userNamePref, profileInfo.name ?? '');
    prefs.setString(PreferenceConfig.userEmailPref, profileInfo.email ?? '');
    prefs.setString(PreferenceConfig.userRolePref, profileInfo.role ?? '');
  }
}
