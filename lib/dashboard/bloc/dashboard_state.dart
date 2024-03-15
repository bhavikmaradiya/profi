part of 'dashboard_bloc.dart';

abstract class DashboardState {}

class DashboardInitialState extends DashboardState {}

class ProfileAndMenuInfoGeneratedState extends DashboardState {
  final List<DashboardDrawerMenu> menus;
  final ProfileInfo profileInfo;

  ProfileAndMenuInfoGeneratedState(this.menus, this.profileInfo);
}

class LogoutSuccessState extends DashboardState {}

class LogoutFailedState extends DashboardState {}
