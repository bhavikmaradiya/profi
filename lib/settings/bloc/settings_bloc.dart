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
  Timer? _dollarDebounceTimer;
  Timer? _cadDebounceTimer;
  Timer? _euroDebounceTimer;
  StreamSubscription? _settingsSubscription;

  SettingsBloc() : super(SettingsInitialState()) {
    on<SettingsInitialEvent>(_fetchSettings);
    on<OnDollarToInrChangeEvent>(_onDollarToInrChanges);
    on<OnCADToInrChangeEvent>(_onCADToInrChanges);
    on<OnEuroToInrChangeEvent>(_onEuroToInrChanges);
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
          bool isDollarAvailable =
              data.containsKey(FireStoreConfig.settingsDollarToInrField);
          bool isCADAvailable =
              data.containsKey(FireStoreConfig.settingsCADToInrField);
          bool isEuroAvailable =
              data.containsKey(FireStoreConfig.settingsEuroToInrField);
          final settings = SettingsInfo();
          if (isDollarAvailable || isEuroAvailable || isCADAvailable) {
            if (isDollarAvailable) {
              final dollarToInrValue =
                  data[FireStoreConfig.settingsDollarToInrField];
              if (dollarToInrValue is double?) {
                settings.dollarToInr = dollarToInrValue;
              }
            }
            if (isCADAvailable) {
              final cadToInrValue = data[FireStoreConfig.settingsCADToInrField];
              if (cadToInrValue is double?) {
                settings.cadToInr = cadToInrValue;
              }
            }
            if (isEuroAvailable) {
              final euroToInrValue =
                  data[FireStoreConfig.settingsEuroToInrField];
              if (euroToInrValue is double?) {
                settings.euroToInr = euroToInrValue;
              }
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
    CurrencyConverterUtils.exchangeRates[CurrencyEnum.euros.name] =
        settingsInfo.euroToInr ?? AppConfig.defaultEuroToInr;
    CurrencyConverterUtils.exchangeRates[CurrencyEnum.CAD.name] =
        settingsInfo.cadToInr ?? AppConfig.defaultCADToInr;
  }

  _onDollarToInrChanges(
    OnDollarToInrChangeEvent event,
    Emitter<SettingsState> state,
  ) {
    final dollarToInrValue = event.value;
    if (_dollarDebounceTimer?.isActive ?? false) {
      _dollarDebounceTimer?.cancel();
    }
    _dollarDebounceTimer = Timer(
      const Duration(seconds: 1),
      () {
        _uploadDollarToInrValueToFirebase(dollarToInrValue);
      },
    );
  }

  _onCADToInrChanges(
    OnCADToInrChangeEvent event,
    Emitter<SettingsState> state,
  ) {
    final cadToInrValue = event.value;
    if (_cadDebounceTimer?.isActive ?? false) {
      _cadDebounceTimer?.cancel();
    }
    _cadDebounceTimer = Timer(
      const Duration(seconds: 1),
      () {
        _uploadCADToInrValueToFirebase(cadToInrValue);
      },
    );
  }

  _onEuroToInrChanges(
    OnEuroToInrChangeEvent event,
    Emitter<SettingsState> state,
  ) {
    final euroToInrValue = event.value;
    if (_euroDebounceTimer?.isActive ?? false) {
      _euroDebounceTimer?.cancel();
    }
    _euroDebounceTimer = Timer(
      const Duration(seconds: 1),
      () {
        _uploadEuroToInrValueToFirebase(euroToInrValue);
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
        .update(data);
  }

  _uploadCADToInrValueToFirebase(String cadToInrValue) {
    double? cadToInr = AppConfig.defaultCADToInr;
    if (cadToInrValue.trim().isNotEmpty) {
      cadToInr = double.tryParse(cadToInrValue.trim());
    }
    Map<String, dynamic> data = {};
    data[FireStoreConfig.settingsCADToInrField] = cadToInr;
    _fireStoreInstance
        .collection(FireStoreConfig.settingsCollections)
        .doc(FireStoreConfig.settingsCurrencyDoc)
        .update(data);
  }

  _uploadEuroToInrValueToFirebase(String euroToInrValue) {
    double? euroToInr = AppConfig.defaultEuroToInr;
    if (euroToInrValue.trim().isNotEmpty) {
      euroToInr = double.tryParse(euroToInrValue.trim());
    }
    Map<String, dynamic> data = {};
    data[FireStoreConfig.settingsEuroToInrField] = euroToInr;
    _fireStoreInstance
        .collection(FireStoreConfig.settingsCollections)
        .doc(FireStoreConfig.settingsCurrencyDoc)
        .update(data);
  }

  onLogout() async {
    await _dispose();
  }

  _dispose() async {
    if (_dollarDebounceTimer?.isActive ?? false) {
      _dollarDebounceTimer?.cancel();
    }
    if (_cadDebounceTimer?.isActive ?? false) {
      _cadDebounceTimer?.cancel();
    }
    if (_euroDebounceTimer?.isActive ?? false) {
      _euroDebounceTimer?.cancel();
    }
    await _settingsSubscription?.cancel();
  }

  @override
  Future<void> close() {
    _dispose();
    return super.close();
  }
}
