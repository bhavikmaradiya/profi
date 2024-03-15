part of 'logs_bloc.dart';

abstract class LogsEvent {}

class CheckForLogHistoryEvent extends LogsEvent {
  final String milestoneInfoId;

  CheckForLogHistoryEvent(this.milestoneInfoId);
}

class FetchLogsEvent extends LogsEvent {
  final String milestoneInfoId;

  FetchLogsEvent(this.milestoneInfoId);
}
