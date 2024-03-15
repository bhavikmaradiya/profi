part of 'firebase_fetch_projects_bloc.dart';

abstract class FirebaseFetchProjectsEvent {}

class FirebaseFetchProjectsDetailsEvent extends FirebaseFetchProjectsEvent {}

class FirebaseMilestoneInfoChangedEvent extends FirebaseFetchProjectsEvent {}

class FilterChangedEvent extends FirebaseFetchProjectsEvent {
  final AppliedFilterInfo? appliedFilterInfo;

  FilterChangedEvent(this.appliedFilterInfo);
}

class FetchCurrentDateTimeEvent extends FirebaseFetchProjectsEvent {}
