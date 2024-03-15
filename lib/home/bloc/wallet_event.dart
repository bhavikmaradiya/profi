part of 'wallet_bloc.dart';

abstract class WalletEvent {}

class ListenWalletInfoChangesEvent extends WalletEvent {}

class ToggleWalletEvent extends WalletEvent {
  final bool shouldToggle;
  final WalletEnums which;
  final double? amountToUpdate;
  final String? note;

  ToggleWalletEvent(
    this.which, {
    this.amountToUpdate,
    this.note,
    this.shouldToggle = true,
  });
}

class OnUnPaidEvent extends WalletEvent {
  final double amountToDeduct;

  OnUnPaidEvent(this.amountToDeduct);
}

class OnPaidEvent extends WalletEvent {
  final double amountToAdd;

  OnPaidEvent(this.amountToAdd);
}
