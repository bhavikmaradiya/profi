import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/firestore_config.dart';
import '../../config/preference_config.dart';
import '../../enums/wallet_enums.dart';
import '../../home/model/wallet_info.dart';

part 'wallet_event.dart';

part 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final _fireStoreInstance = FirebaseFirestore.instance;
  WalletInfo? _walletInfo;
  StreamSubscription? _walletInfoSubscription;

  WalletBloc() : super(WalletInitialState()) {
    on<ListenWalletInfoChangesEvent>(_listenWalletChanges);
    on<ToggleWalletEvent>(_toggleWallet);
    on<OnUnPaidEvent>(_deductFromWallet);
    on<OnPaidEvent>(_addToWallet);
    add(ListenWalletInfoChangesEvent());
  }

  _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(PreferenceConfig.userIdPref);
  }

  _deductFromWallet(
    OnUnPaidEvent event,
    Emitter<WalletState> emit,
  ) async {
    WalletInfo? walletInfo = _walletInfo;
    final walletDocRef = await _createWalletInfoRef();
    if (walletInfo == null) {
      final document = await walletDocRef.get();
      try {
        if (document.data() != null) {
          _walletInfo = WalletInfo.fromSnapshot(document);
          walletInfo = _walletInfo;
          emit(WalletInfoChangedState(_walletInfo));
        }
      } on Exception catch (_) {}
    }
    final valuesToUpdate = <String, dynamic>{};
    if (walletInfo != null) {
      if (walletInfo.walletAIsStarted) {
        final amount = walletInfo.walletAAmount ?? 0;
        valuesToUpdate[FireStoreConfig.walletAAmountField] =
            amount - event.amountToDeduct;
      }
      if (walletInfo.walletBIsStarted) {
        final amount = walletInfo.walletBAmount ?? 0;
        valuesToUpdate[FireStoreConfig.walletBAmountField] =
            amount - event.amountToDeduct;
      }
    }
    if (valuesToUpdate.isNotEmpty) {
      valuesToUpdate[FireStoreConfig.updatedAtField] =
          DateTime.now().millisecondsSinceEpoch;
      walletDocRef.update(valuesToUpdate);
    }
  }

  _addToWallet(
    OnPaidEvent event,
    Emitter<WalletState> emit,
  ) async {
    WalletInfo? walletInfo = _walletInfo;
    final walletDocRef = await _createWalletInfoRef();
    if (walletInfo == null) {
      final document = await walletDocRef.get();
      try {
        if (document.data() != null) {
          _walletInfo = WalletInfo.fromSnapshot(document);
          walletInfo = _walletInfo;
          emit(WalletInfoChangedState(_walletInfo));
        }
      } on Exception catch (_) {}
    }
    final valuesToUpdate = <String, dynamic>{};
    if (walletInfo != null) {
      if (walletInfo.walletAIsStarted) {
        final amount = walletInfo.walletAAmount ?? 0;
        valuesToUpdate[FireStoreConfig.walletAAmountField] =
            amount + event.amountToAdd;
      }
      if (walletInfo.walletBIsStarted) {
        final amount = walletInfo.walletBAmount ?? 0;
        valuesToUpdate[FireStoreConfig.walletBAmountField] =
            amount + event.amountToAdd;
      }
    }
    if (valuesToUpdate.isNotEmpty) {
      valuesToUpdate[FireStoreConfig.updatedAtField] =
          DateTime.now().millisecondsSinceEpoch;
      walletDocRef.update(valuesToUpdate);
    }
  }

  _listenWalletChanges(
    ListenWalletInfoChangesEvent event,
    Emitter<WalletState> emit,
  ) async {
    final walletInfoStream = await _createWalletInfoQuery();
    _walletInfoSubscription = walletInfoStream.listen((snapshot) {
      try {
        _walletInfo = WalletInfo.fromSnapshot(snapshot);
      } on Exception catch (_) {}
      emit(WalletInfoChangedState(_walletInfo));
    });

    await _walletInfoSubscription?.asFuture();
  }

  _toggleWallet(
    ToggleWalletEvent event,
    Emitter<WalletState> emit,
  ) async {
    final shouldToggle = event.shouldToggle;
    final notes = event.note;
    final walletType = event.which;
    final amountToUpdate = event.amountToUpdate;
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final valuesToUpdate = <String, dynamic>{};

    if (walletType == WalletEnums.walletA) {
      if (shouldToggle) {
        valuesToUpdate[FireStoreConfig.walletAIsStartedField] =
            !(_walletInfo?.walletAIsStarted ?? true);
      }
      if (amountToUpdate != null) {
        valuesToUpdate[FireStoreConfig.walletAAmountField] = amountToUpdate;
      }
    } else if (walletType == WalletEnums.walletB) {
      if (shouldToggle) {
        valuesToUpdate[FireStoreConfig.walletBIsStartedField] =
            !(_walletInfo?.walletBIsStarted ?? true);
      }
      if (amountToUpdate != null) {
        valuesToUpdate[FireStoreConfig.walletBAmountField] = amountToUpdate;
      }
    }
    if (valuesToUpdate.isNotEmpty) {
      valuesToUpdate[FireStoreConfig.updatedAtField] = currentTime;
      if (notes != null && notes.trim().isNotEmpty) {
        valuesToUpdate[FireStoreConfig.walletNoteField] = notes;
      }
      final docRef = await _createWalletInfoRef();
      docRef.update(valuesToUpdate);
    }
  }

  _createWalletInfoQuery() async {
    final docRef = await _createWalletInfoRef();
    return docRef.snapshots();
  }

  Future<DocumentReference<Object?>> _createWalletInfoRef() async {
    final currentUserId = await _getCurrentUserId();
    return _fireStoreInstance
        .collection(FireStoreConfig.walletCollection)
        .doc(currentUserId);
  }

  onLogout() async {
    _dispose();
  }

  _dispose() async {
    await _walletInfoSubscription?.cancel();
  }

  @override
  Future<void> close() {
    _dispose();
    return super.close();
  }
}
