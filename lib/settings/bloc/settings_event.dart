part of 'settings_bloc.dart';

abstract class SettingsEvent {}

class SettingsInitialEvent extends SettingsEvent {}

class OnDollarToInrChangeEvent extends SettingsEvent {
  final String value;

  OnDollarToInrChangeEvent(this.value);
}

class OnCADToInrChangeEvent extends SettingsEvent {
  final String value;

  OnCADToInrChangeEvent(this.value);
}

class OnEuroToInrChangeEvent extends SettingsEvent {
  final String value;

  OnEuroToInrChangeEvent(this.value);
}
