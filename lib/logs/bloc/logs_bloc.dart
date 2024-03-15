import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../config/firestore_config.dart';
import '../model/log_info.dart';

part 'logs_event.dart';

part 'logs_state.dart';

class LogsBloc extends Bloc<LogsEvent, LogsState> {
  final _fireStoreInstance = FirebaseFirestore.instance;
  List<LogInfo>? _logsHistory;

  LogsBloc() : super(LogsInitialState()) {
    on<CheckForLogHistoryEvent>(_checkForLogHistory);
    on<FetchLogsEvent>(_fetchLogs);
  }

  _checkForLogHistory(
    CheckForLogHistoryEvent event,
    Emitter<LogsState> emit,
  ) async {
    final querySnapshot = await _fireStoreInstance
        .collection(FireStoreConfig.logsCollections)
        .where(
          FireStoreConfig.logMilestoneInfoIdField,
          isEqualTo: event.milestoneInfoId,
        )
        .count()
        .get();
    emit(LogsHistoryCountState(querySnapshot.count));
  }

  _fetchLogs(FetchLogsEvent event, Emitter<LogsState> emit) async {
    _logsHistory = [];
    emit(FetchingLogsLoadingState());
    final querySnapshot = await _fireStoreInstance
        .collection(FireStoreConfig.logsCollections)
        .where(
          FireStoreConfig.logMilestoneInfoIdField,
          isEqualTo: event.milestoneInfoId,
        )
        .get();
    final docs = querySnapshot.docs;
    if (docs.isNotEmpty) {
      for (int i = 0; i < docs.length; i++) {
        try {
          final logInfo = LogInfo.fromSnapshot(docs[i]);
          _logsHistory!.add(logInfo);
        } on Exception catch (_) {}
      }
      _logsHistory!.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
    }
    emit(LogsFetchedState(_logsHistory!));
  }

  List<LogInfo> getMilestoneTransactionsLogs() {
    return _logsHistory ?? [];
  }
}
