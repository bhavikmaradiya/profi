part of 'transaction_bloc.dart';

abstract class TransactionState {}

class TransactionInitialState extends TransactionState {}

class TransactionLoadingState extends TransactionState {
  final bool isPagination;

  TransactionLoadingState(this.isPagination);
}

class TransactionDataState extends TransactionState {
  final List<TransactionInfo> transactions;
  final bool hasMoreTransaction;

  TransactionDataState(this.transactions, this.hasMoreTransaction);
}

class TransactionEmptyState extends TransactionState {}

class SearchInitializedState extends TransactionState {}

class SearchDataState extends TransactionState {
  final List<TransactionInfo> transactions;

  SearchDataState(this.transactions);
}

class SearchCompletedState extends TransactionState {
  final List<TransactionInfo> transactions;
  final bool hasMoreTransaction;

  SearchCompletedState(this.transactions, this.hasMoreTransaction);
}
