part of 'add_user_bloc.dart';

abstract class AddUserEvent {}

class UserRoleSelectionEvent extends AddUserEvent {
  final UserRoleEnum userRole;

  UserRoleSelectionEvent(this.userRole);
}

class EditUserInitEvent extends AddUserEvent {
  final ProfileInfo userInfo;

  EditUserInitEvent(this.userInfo);
}

class CreateUserEvent extends AddUserEvent {
  final String email;
  final String name;
  final String password;

  CreateUserEvent({
    required this.email,
    required this.name,
    required this.password,
  });
}

class VisibleInvisiblePasswordFieldEvent extends AddUserEvent {
  final bool isVisible;

  VisibleInvisiblePasswordFieldEvent(this.isVisible);
}
