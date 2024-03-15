part of 'profile_bloc.dart';

abstract class ProfileEvent {}

class ProfileInitialEvent extends ProfileEvent {}

class ProfileUpdatedEvent extends ProfileEvent {
  final ProfileInfo profileInfo;

  ProfileUpdatedEvent(this.profileInfo);
}

class ProfileSaveEvent extends ProfileEvent {
  final ProfileInfo profileInfo;

  ProfileSaveEvent(this.profileInfo);
}
