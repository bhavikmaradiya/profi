part of 'dialog_bloc.dart';

abstract class DialogEvent {}

class FieldErrorEvent extends DialogEvent {
  final ErrorEnum errorEnum;

  FieldErrorEvent(this.errorEnum);
}

class InvalidMilestoneDateErrorEvent extends DialogEvent {}
