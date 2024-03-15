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

class FirebaseBDMInfoChangedState extends FirebaseFetchProjectsState {
  final List<ProfileInfo> bdmList;

  FirebaseBDMInfoChangedState(this.bdmList);
}

class FirebasePMInfoChangedState extends FirebaseFetchProjectsState {
  final List<ProfileInfo> pmList;

  FirebasePMInfoChangedState(this.pmList);
}

class FilterChangedState extends FirebaseFetchProjectsState {}

class ProjectSearchTextChangeState extends FirebaseFetchProjectsState {
  final String searchBy;

  ProjectSearchTextChangeState(this.searchBy);
}

class ProjectSearchInitializedState extends FirebaseFetchProjectsState {}

class ProjectSearchClosedState extends FirebaseFetchProjectsState {}
