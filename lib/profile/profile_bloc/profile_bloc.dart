import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/firestore_config.dart';
import '../../config/preference_config.dart';
import '../model/profile_info.dart';

part 'profile_event.dart';

part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final _fireStoreInstance = FirebaseFirestore.instance;

  ProfileBloc() : super(ProfileInitialState()) {
    on<ProfileInitialEvent>(_onInitProfile);
    on<ProfileUpdatedEvent>(_onProfileUpdate);
    on<ProfileSaveEvent>(_onUploadProfileInfoEvent);
    add(ProfileInitialEvent());
  }

  _onInitProfile(ProfileInitialEvent event, Emitter<ProfileState> emit) async {
    final profileInfo = await _getProfileInfo();
    add(ProfileUpdatedEvent(profileInfo));
  }

  _onProfileUpdate(ProfileUpdatedEvent event, Emitter<ProfileState> emit) {
    emit(ProfileInfoUpdatedState(event.profileInfo));
  }

  _onUploadProfileInfoEvent(
    ProfileSaveEvent event,
    Emitter<ProfileState> emit,
  ) async {
    await _uploadProfileInfoToFirebase(event.profileInfo);
    _saveProfileInfo(event.profileInfo);
    emit(ProfileSuccessState());
  }

  _uploadProfileInfoToFirebase(ProfileInfo profileInfo) async {
    await _fireStoreInstance
        .collection(FireStoreConfig.userCollection)
        .doc(profileInfo.userId)
        .set(profileInfo.toMap());
  }

  _saveProfileInfo(ProfileInfo profileInfo) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(PreferenceConfig.userIdPref, profileInfo.userId ?? '');
    prefs.setString(PreferenceConfig.userNamePref, profileInfo.name ?? '');
    prefs.setString(PreferenceConfig.userEmailPref, profileInfo.email ?? '');
    prefs.setString(PreferenceConfig.userRolePref, profileInfo.role ?? '');
  }

  Future<ProfileInfo> _getProfileInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(PreferenceConfig.userIdPref);
    final name = prefs.getString(PreferenceConfig.userNamePref);
    final email = prefs.getString(PreferenceConfig.userEmailPref);
    final role = prefs.getString(PreferenceConfig.userRolePref);
    return ProfileInfo(
      userId: userId,
      name: name,
      email: email,
      role: role,
    );
  }

  Future<String?> getFirebaseUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(PreferenceConfig.userIdPref);
  }
}
