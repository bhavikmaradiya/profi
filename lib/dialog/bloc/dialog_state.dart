part of 'dialog_bloc.dart';

abstract class DialogState {}

class DialogInitialState extends DialogState {}

class FieldErrorState extends DialogState {
  final ErrorEnum errorEnum;

  FieldErrorState(this.errorEnum);
}

class InvalidMilestoneDateState extends DialogState {}
