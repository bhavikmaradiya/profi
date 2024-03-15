import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../config/app_config.dart';
import '../../config/firestore_config.dart';
import '../../enums/currency_enum.dart';
import '../../utils/currency_converter_utils.dart';
import '../model/settings_info.dart';

part 'settings_event.dart';

part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final _fireStoreInstance = FirebaseFirestore.instance;
  Timer? _debounceTimer;
  StreamSubscription? _settingsSubscription;

  SettingsBloc() : super(SettingsInitialState()) {
    on<SettingsInitialEvent>(_fetchSettings);
    on<OnDollarToInrChangeEvent>(_onDollarToInrChanges);
  }

  _fetchSettings(
    SettingsInitialEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final settingsStream = _fireStoreInstance
        .collection(FireStoreConfig.settingsCollections)
        .doc(FireStoreConfig.settingsCurrencyDoc)
        .snapshots();
    _settingsSubscription = settingsStream.listen(
      (snapshot) {
        final data = snapshot.data();
        if (data != null && data.isNotEmpty) {
          final settings = SettingsInfo();
          if (data.containsKey(FireStoreConfig.settingsDollarToInrField)) {
            final dollarToInrValue =
                data[FireStoreConfig.settingsDollarToInrField];
            if (dollarToInrValue is double?) {
              settings.dollarToInr = dollarToInrValue;
            }
            _updateCurrencies(settings);
          }
        }
      },
    );
    // Await the subscription to ensure proper cleanup
    await _settingsSubscription?.asFuture();
  }

  _updateCurrencies(SettingsInfo settingsInfo) {
    CurrencyConverterUtils.exchangeRates[CurrencyEnum.dollars.name] =
        settingsInfo.dollarToInr ?? AppConfig.defaultDollarToInr;
  }

  _onDollarToInrChanges(
    OnDollarToInrChangeEvent event,
    Emitter<SettingsState> state,
  ) {
    final dollarToInrValue = event.value;
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
    }
    _debounceTimer = Timer(
      const Duration(seconds: 1),
      () {
        _uploadDollarToInrValueToFirebase(dollarToInrValue);
      },
    );
  }

  _uploadDollarToInrValueToFirebase(String dollarToInrValue) {
    double? dollarToInr = AppConfig.defaultDollarToInr;
    if (dollarToInrValue.trim().isNotEmpty) {
      dollarToInr = double.tryParse(dollarToInrValue.trim());
    }
    Map<String, dynamic> data = {};
    data[FireStoreConfig.settingsDollarToInrField] = dollarToInr;
    _fireStoreInstance
        .collection(FireStoreConfig.settingsCollections)
        .doc(FireStoreConfig.settingsCurrencyDoc)
        .set(data);
  }

  onLogout() async {
    await _dispose();
  }

  _dispose() async {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
    }
    await _settingsSubscription?.cancel();
  }

  @override
  Future<void> close() {
    _dispose();
    return super.close();
  }
}
