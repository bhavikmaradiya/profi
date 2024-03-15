part of 'manage_user_bloc.dart';

abstract class ManageUserState {}

class ManageUserInitial extends ManageUserState {}

class UsersLoadingState extends ManageUserState {}

class UsersLoadedState extends ManageUserState {
  final List<ProfileInfo> usersList;

  UsersLoadedState(this.usersList);
}

class NoUsersFoundState extends ManageUserState {}

