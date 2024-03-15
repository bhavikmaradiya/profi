part of 'transaction_bloc.dart';

abstract class TransactionState {}

class TransactionInitialState extends TransactionState {}

class TransactionLoadingState extends TransactionState {}

class TransactionDataState extends TransactionState {
  final List<TransactionInfo> transactions;

  TransactionDataState(this.transactions);
}

class TransactionEmptyState extends TransactionState {}

class SearchInitializedState extends TransactionState {}

class SearchDataState extends TransactionState {
  final List<TransactionInfo> transactions;

  SearchDataState(this.transactions);
}

class SearchCompletedState extends TransactionState {
  final List<TransactionInfo> transactions;

  SearchCompletedState(this.transactions);
}
