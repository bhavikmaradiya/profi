part of 'profile_bloc.dart';

abstract class ProfileState {}

class ProfileInitialState extends ProfileState {}

class ProfileInfoUpdatedState extends ProfileState {
  final ProfileInfo profileInfo;

  ProfileInfoUpdatedState(this.profileInfo);
}

class ProfileSuccessState extends ProfileState {}

class ProfileFailedState extends ProfileState {
  final String errorMessage;

  ProfileFailedState(this.errorMessage);
}
