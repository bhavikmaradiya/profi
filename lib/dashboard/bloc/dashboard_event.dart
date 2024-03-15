part of 'dashboard_bloc.dart';

abstract class DashboardEvent {}

class GenerateProfileAndMenuEvent extends DashboardEvent {
  final AppLocalizations appLocalizations;

  GenerateProfileAndMenuEvent(this.appLocalizations);
}

class LogoutEvent extends DashboardEvent {}
