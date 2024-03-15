part of 'firebase_fetch_projects_bloc.dart';

abstract class FirebaseFetchProjectsEvent {}

class FirebaseFetchProjectsDetailsEvent extends FirebaseFetchProjectsEvent {}

class FirebaseFetchBdmDetailsEvent extends FirebaseFetchProjectsEvent {}

class FirebaseFetchPMDetailsEvent extends FirebaseFetchProjectsEvent {}

class FirebaseMilestoneInfoChangedEvent extends FirebaseFetchProjectsEvent {}

class FilterChangedEvent extends FirebaseFetchProjectsEvent {
  final AppliedFilterInfo? appliedFilterInfo;

  FilterChangedEvent(this.appliedFilterInfo);
}

class FetchCurrentDateTimeEvent extends FirebaseFetchProjectsEvent {}

class ProjectSearchTextChangedEvent extends FirebaseFetchProjectsEvent {
  final String searchBy;

  ProjectSearchTextChangedEvent(this.searchBy);
}

class ProjectSearchInitializeEvent extends FirebaseFetchProjectsEvent {}

class ProjectSearchClosedEvent extends FirebaseFetchProjectsEvent {}
