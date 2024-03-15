part of 'auth_field_validation_bloc.dart';

abstract class AuthFieldValidationEvent {}

class EmailIdFieldTextChangeEvent extends AuthFieldValidationEvent {
  final String emailId;

  EmailIdFieldTextChangeEvent(this.emailId);
}

class PasswordFieldTextChangeEvent extends AuthFieldValidationEvent {
  final String password;

  PasswordFieldTextChangeEvent(this.password);
}

class VisiblePasswordFieldEvent extends AuthFieldValidationEvent {}

class InVisiblePasswordFieldEvent extends AuthFieldValidationEvent {}
