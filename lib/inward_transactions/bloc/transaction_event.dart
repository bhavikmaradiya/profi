part of 'transaction_bloc.dart';

abstract class TransactionEvent {}

class FetchTransactionEvent extends TransactionEvent {
  final bool loadInitial;
  final int limit;

  FetchTransactionEvent({
    this.loadInitial = false,
    this.limit = AppConfig.transactionPaginationLoadLimit,
  });
}

class ListenTransactionChangesEvent extends TransactionEvent {}

class SearchInitializeEvent extends TransactionEvent {}

class SearchTextChangedEvent extends TransactionEvent {
  final String? projectId;
  final String searchBy;

  SearchTextChangedEvent(this.projectId, this.searchBy);
}

class SearchCloseEvent extends TransactionEvent {}
