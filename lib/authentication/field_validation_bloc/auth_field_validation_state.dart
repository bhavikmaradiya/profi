part of 'auth_field_validation_bloc.dart';

abstract class AuthFieldValidationState {}

class AuthFieldValidationInitialState extends AuthFieldValidationState {}

class InvalidEmailFieldErrorState extends AuthFieldValidationState {}

class InvalidPasswordFieldErrorState extends AuthFieldValidationState {}

class ValidEmailFieldState extends AuthFieldValidationState {}

class ValidPasswordFieldState extends AuthFieldValidationState {}

class VisiblePasswordFieldState extends AuthFieldValidationState {}

class InVisiblePasswordFieldState extends AuthFieldValidationState {}