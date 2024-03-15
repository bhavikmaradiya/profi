part of 'wallet_bloc.dart';

abstract class WalletState {}

class WalletInitialState extends WalletState {}

class WalletInfoChangedState extends WalletState {
  final WalletInfo? walletInfo;

  WalletInfoChangedState(this.walletInfo);
}
