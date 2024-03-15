part of 'logs_bloc.dart';

abstract class LogsState {}

class LogsInitialState extends LogsState {}

class LogsHistoryCountState extends LogsState {
  final int historyCount;

  LogsHistoryCountState(this.historyCount);
}

class FetchingLogsLoadingState extends LogsState {}

class LogsFetchedState extends LogsState {
  final List<LogInfo> logs;

  LogsFetchedState(this.logs);
}
