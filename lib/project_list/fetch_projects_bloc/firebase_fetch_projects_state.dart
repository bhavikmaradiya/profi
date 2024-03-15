part of 'firebase_fetch_projects_bloc.dart';

abstract class FirebaseFetchProjectsState {}

class FirebaseFetchProjectsInitialState extends FirebaseFetchProjectsState {}

class FirebaseFetchProjectsLoadingState extends FirebaseFetchProjectsState {}

class FirebaseFetchProjectsEmptyState extends FirebaseFetchProjectsState {}

class FirebaseFetchProjectsDataState extends FirebaseFetchProjectsState {
  final List<ProjectInfo> allProjects;

  FirebaseFetchProjectsDataState(this.allProjects);
}

class FirebaseMilestoneInfoChangedState extends FirebaseFetchProjectsState {
  final List<MilestoneInfo> milestones;

  FirebaseMilestoneInfoChangedState(this.milestones);
}

class FilterChangedState extends FirebaseFetchProjectsState {}
