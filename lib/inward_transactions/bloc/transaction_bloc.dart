import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/app_config.dart';
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
  bool _disablePullToRefreshLoadMore = false;
  bool _hasMoreData = false;
  bool _isLoading = false;
  DocumentSnapshot? _lastDocument;

  int get transactionCount => _transactions.length;

  bool get isPaginationDisabled => _disablePullToRefreshLoadMore;

  TransactionBloc() : super(TransactionInitialState()) {
    on<FetchTransactionEvent>(_onFetchTransactions);
    on<ListenTransactionChangesEvent>(_listenStreamChanges);
    on<SearchInitializeEvent>(_onSearchInitialized);
    on<SearchTextChangedEvent>(_onSearchTextChanged);
    on<SearchCloseEvent>(_onCloseSearch);
    add(ListenTransactionChangesEvent());
  }

  _listenStreamChanges(
    ListenTransactionChangesEvent event,
    Emitter<TransactionState> emit,
  ) async {
    final userRole = await _getCurrentUserRole();
    Stream<QuerySnapshot<Map<String, dynamic>>> snapshotStream;
    if (userRole == UserRoleEnum.admin.name) {
      snapshotStream =
          await _createTransactionsQueryForAdminRole(shouldListenOnly: true);
    } else {
      snapshotStream =
          await _createTransactionQueryBasedOnUser(shouldListenOnly: true);
    }
    _transactionListSubscription = snapshotStream.listen(
      (snapshot) async {
        add(
          FetchTransactionEvent(
            loadInitial: true,
            limit: _transactions.isEmpty
                ? AppConfig.transactionInitialLoadLimit
                : AppConfig.transactionPaginationLoadLimit,
          ),
        );
      },
    );
    // Await the subscription to ensure proper cleanup
    await _transactionListSubscription?.asFuture();
  }

  _onFetchTransactions(
    FetchTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    if (_isLoading) {
      return;
    }
    final shouldReset = event.loadInitial;
    if (shouldReset || _hasMoreData) {
      _isLoading = true;
      emit(
        TransactionLoadingState(
          !shouldReset && _transactions.isNotEmpty,
        ),
      );
      final userRole = await _getCurrentUserRole();
      if (shouldReset) {
        _lastDocument = null;
        _transactions.clear();
      }
      QuerySnapshot<Map<String, dynamic>> querySnapshot;
      if (userRole == UserRoleEnum.admin.name) {
        querySnapshot = await _createTransactionsQueryForAdminRole(
          limit: event.limit,
        );
      } else {
        querySnapshot = await _createTransactionQueryBasedOnUser(
          limit: event.limit,
        );
      }
      final documents = querySnapshot.docs;
      if (_transactions.isNotEmpty) {
        documents.removeWhere(
          (element) => _transactions.last.transactionId == element.id,
        );
      }
      _hasMoreData = !(documents.length < event.limit);
      if (documents.isNotEmpty) {
        for (int i = 0; i < documents.length; i++) {
          _addTransaction(documents[i]);
        }
        if (_transactions.isNotEmpty) {
          final docForPagination = documents.firstWhereOrNull((e) =>
              e.data().isNotEmpty &&
              e.data()[FireStoreConfig.transactionIdField] ==
                  _transactions.last.transactionId);
          if (docForPagination != null) {
            _lastDocument = docForPagination;
          }
        }
      }
      _isLoading = false;
      if (_transactions.isEmpty) {
        emit(TransactionEmptyState());
      } else {
        emit(
          TransactionDataState(
            _transactions,
            _hasMoreData,
          ),
        );
      }
    }
  }

  Future<dynamic> _createTransactionsQueryForAdminRole({
    bool shouldListenOnly = false,
    int limit = AppConfig.transactionPaginationLoadLimit,
  }) async {
    // get all entries for admin role
    var query = _fireStoreInstance
        .collection(FireStoreConfig.transactionsCollection)
        .orderBy(
          FireStoreConfig.updatedAtField,
          descending: true,
        )
        .orderBy(
          FieldPath.documentId,
        );
    if (!shouldListenOnly) {
      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }
      query = query.limit(limit);
      return await query.get();
    }
    return query.snapshots();
  }

  Future<dynamic> _createTransactionQueryBasedOnUser({
    bool shouldListenOnly = false,
    int limit = AppConfig.transactionPaginationLoadLimit,
  }) async {
    // get only entries which available for current user
    final userId = await _getCurrentUserId();
    var query = _fireStoreInstance
        .collection(FireStoreConfig.transactionsCollection)
        .where(
          FireStoreConfig.transactionAvailableForField,
          arrayContains: userId,
        )
        .orderBy(
          FireStoreConfig.updatedAtField,
          descending: true,
        )
        .orderBy(
          FieldPath.documentId,
        );

    if (!shouldListenOnly) {
      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }
      query = query.limit(limit);
      return await query.get();
    }
    return query.snapshots();
  }

  Future<String?> _getCurrentUserRole() async {
    final preference = await SharedPreferences.getInstance();
    return preference.getString(PreferenceConfig.userRolePref);
  }

  Future<String?> _getCurrentUserId() async {
    final preference = await SharedPreferences.getInstance();
    return preference.getString(PreferenceConfig.userIdPref);
  }

  /*_updateTransactionInfo(QuerySnapshot<Map<String, dynamic>> snapshot) {
    if (snapshot.docChanges.isNotEmpty) {
      for (var element in snapshot.docChanges) {
        final document = element.doc;
        */ /*if (element.type == DocumentChangeType.added) {
          _addTransaction(document);
        } else*/ /*
        if (element.type == DocumentChangeType.modified) {
          _modifyTransactionDetails(document);
        } else if (element.type == DocumentChangeType.removed) {
          _removeTransaction(document);
        }
      }
    }
  }*/

  _addTransaction(DocumentSnapshot document) {
    try {
      final index = _transactions.indexWhere(
        (transactionInfo) => transactionInfo.transactionId == document.id,
      );
      if (index == (-1)) {
        final transactionInfo = TransactionInfo.fromSnapshot(document);
        _transactions.add(transactionInfo);
      }
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
    _disablePullToRefreshLoadMore = true;
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
    _disablePullToRefreshLoadMore = false;
    emit(
      SearchCompletedState(
        _transactions,
        _hasMoreData,
      ),
    );
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
