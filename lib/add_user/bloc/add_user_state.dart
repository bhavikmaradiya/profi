part of 'add_user_bloc.dart';

abstract class AddUserState {}

class AddUserInitial extends AddUserState {}

class CreateUserState extends AddUserState {}

class CreateUserFailedState extends AddUserState {
  final String message;

  CreateUserFailedState(this.message);
}

class UserRoleSelectedState extends AddUserState {
  final UserRoleEnum selected;

  UserRoleSelectedState(this.selected);
}

class CreateUserSuccessState extends AddUserState {
  final bool isEdit;

  CreateUserSuccessState({this.isEdit = false});
}

class CreateUserLoadingState extends AddUserState {
  final bool isLoading;

  CreateUserLoadingState(this.isLoading);
}

class InvalidEmailFieldErrorState extends AddUserState {}

class InvalidRoleFieldErrorState extends AddUserState {}

class InvalidNameFieldErrorState extends AddUserState {}

class InvalidPasswordFieldErrorState extends AddUserState {}

class VisibleInvisiblePasswordFieldState extends AddUserState {
  final bool isVisible;

  VisibleInvisiblePasswordFieldState(this.isVisible);
}
