import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/firestore_config.dart';
import '../../config/preference_config.dart';
import '../../enums/user_role_enums.dart';
import '../model/transaction_info.dart';

part 'transaction_event.dart';

part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final _fireStoreInstance = FirebaseFirestore.instance;
  final List<TransactionInfo> _transactions = [];
  StreamSubscription? _transactionListSubscription;

  TransactionBloc() : super(TransactionInitialState()) {
    on<FetchTransactionEvent>(_onFetchTransactions);
    on<SearchInitializeEvent>(_onSearchInitialized);
    on<SearchTextChangedEvent>(_onSearchTextChanged);
    on<SearchCloseEvent>(_onCloseSearch);
    add(FetchTransactionEvent());
  }

  _onFetchTransactions(
    FetchTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoadingState());
    final userRole = await _getCurrentUserRole();
    Stream<QuerySnapshot<Map<String, dynamic>>> snapshotStream;
    if (userRole == UserRoleEnum.admin.name) {
      snapshotStream = _createTransactionsQueryForAdminRole();
    } else {
      snapshotStream = await _createTransactionQueryBasedOnUser();
    }
    _transactionListSubscription = snapshotStream.listen(
      (snapshot) async {
        await _updateTransactionInfo(snapshot);
        if (_transactions.isEmpty) {
          emit(TransactionEmptyState());
        } else {
          emit(TransactionDataState(_transactions));
        }
      },
    );
    // Await the subscription to ensure proper cleanup
    await _transactionListSubscription?.asFuture();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>
      _createTransactionsQueryForAdminRole() {
    // get all entries for admin role
    return _fireStoreInstance
        .collection(FireStoreConfig.transactionsCollection)
        .orderBy(
          FireStoreConfig.updatedAtField,
          descending: true,
        )
        .snapshots();
  }

  Future<Stream<QuerySnapshot<Map<String, dynamic>>>>
      _createTransactionQueryBasedOnUser() async {
    // get only entries which available for current user
    final userId = await _getCurrentUserId();
    return _fireStoreInstance
        .collection(FireStoreConfig.transactionsCollection)
        .where(
          FireStoreConfig.transactionAvailableForField,
          arrayContains: userId,
        )
        .orderBy(
          FireStoreConfig.updatedAtField,
          descending: true,
        )
        .snapshots();
  }

  Future<String?> _getCurrentUserRole() async {
    final preference = await SharedPreferences.getInstance();
    return preference.getString(PreferenceConfig.userRolePref);
  }

  Future<String?> _getCurrentUserId() async {
    final preference = await SharedPreferences.getInstance();
    return preference.getString(PreferenceConfig.userIdPref);
  }

  _updateTransactionInfo(QuerySnapshot<Map<String, dynamic>> snapshot) {
    if (snapshot.docChanges.isNotEmpty) {
      for (var element in snapshot.docChanges) {
        final document = element.doc;
        if (element.type == DocumentChangeType.added) {
          _addTransaction(document);
        } else if (element.type == DocumentChangeType.modified) {
          _modifyTransactionDetails(document);
        } else if (element.type == DocumentChangeType.removed) {
          _removeTransaction(document);
        }
      }
    }
  }

  _addTransaction(DocumentSnapshot document) {
    try {
      final transactionInfo = TransactionInfo.fromSnapshot(document);
      _transactions.add(transactionInfo);
      _transactions.sort(
        (a, b) {
          if (a.updatedAt != null && b.updatedAt != null) {
            return b.updatedAt!.compareTo(a.updatedAt!);
          }
          return -1;
        },
      );
    } on Exception catch (_) {}
  }

  _modifyTransactionDetails(DocumentSnapshot document) {
    final index = _transactions.indexWhere(
      (transactionInfo) => transactionInfo.transactionId == document.id,
    );
    if (index != (-1)) {
      try {
        final transactionInfo = TransactionInfo.fromSnapshot(document);
        _transactions[index] = transactionInfo;
      } on Exception catch (_) {}
    }
  }

  _removeTransaction(DocumentSnapshot document) {
    _transactions.removeWhere(
      (transactionInfo) => transactionInfo.transactionId == document.id,
    );
  }

  _onSearchInitialized(
    SearchInitializeEvent event,
    Emitter<TransactionState> emit,
  ) {
    emit(SearchInitializedState());
  }

  _onSearchTextChanged(
    SearchTextChangedEvent event,
    Emitter<TransactionState> emit,
  ) {
    final searchBy = event.searchBy.toString().trim().toLowerCase();
    final projectId = event.projectId;
    final List<TransactionInfo> transactionForSearch = [];
    if (projectId != null) {
      transactionForSearch.addAll(
        _transactions.where(
          (element) => element.projectId == projectId,
        ),
      );
    } else {
      transactionForSearch.addAll(_transactions);
    }
    final filterList = transactionForSearch
        .where((element) =>
            (element.projectCode != null &&
                element.projectCode!.trim().toLowerCase().contains(searchBy)) ||
            (element.projectName != null &&
                element.projectName!.trim().toLowerCase().contains(searchBy)) ||
            (element.transactionByName != null &&
                element.transactionByName!
                    .trim()
                    .toLowerCase()
                    .contains(searchBy)))
        .toList();
    emit(SearchDataState(filterList));
  }

  _onCloseSearch(
    SearchCloseEvent event,
    Emitter<TransactionState> emit,
  ) {
    emit(SearchCompletedState(_transactions));
  }

  List<TransactionInfo> getAllTransactions() {
    return _transactions;
  }

  onLogout() async {
    _dispose();
    _transactions.clear();
  }

  _dispose() async {
    await _transactionListSubscription?.cancel();
  }

  @override
  Future<void> close() {
    _dispose();
    return super.close();
  }
}
