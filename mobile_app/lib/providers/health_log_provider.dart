import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';
import '../core/constants/api_constants.dart';
import '../data/models/health_log_model.dart';
import '../core/services/sync_queue_service.dart';
import 'auth_provider.dart';

class HealthLogState {
  final bool isLoading;
  final List<HealthLogModel> bpLogs;
  final List<HealthLogModel> sugarLogs;
  final List<HealthLogModel> weightLogs;
  final List<HealthLogModel> pulseLogs;

  HealthLogState({
    this.isLoading = false,
    this.bpLogs = const [],
    this.sugarLogs = const [],
    this.weightLogs = const [],
    this.pulseLogs = const [],
  });

  HealthLogState copyWith({
    bool? isLoading,
    List<HealthLogModel>? bpLogs,
    List<HealthLogModel>? sugarLogs,
    List<HealthLogModel>? weightLogs,
    List<HealthLogModel>? pulseLogs,
  }) {
    return HealthLogState(
      isLoading: isLoading ?? this.isLoading,
      bpLogs: bpLogs ?? this.bpLogs,
      sugarLogs: sugarLogs ?? this.sugarLogs,
      weightLogs: weightLogs ?? this.weightLogs,
      pulseLogs: pulseLogs ?? this.pulseLogs,
    );
  }
}

class HealthLogNotifier extends StateNotifier<HealthLogState> {
  final ApiService _apiService;

  HealthLogNotifier(this._apiService) : super(HealthLogState()) {
    _loadLocalInitialData();
  }

  Future<void> _loadLocalInitialData() async {
    final bp = await StorageService.getHealthLogs('blood_pressure');
    final sugar = await StorageService.getHealthLogs('blood_sugar');
    final weight = await StorageService.getHealthLogs('weight');
    final pulse = await StorageService.getHealthLogs('pulse');

    state = state.copyWith(
      bpLogs: bp,
      sugarLogs: sugar,
      weightLogs: weight,
      pulseLogs: pulse,
    );
  }

  Future<void> fetchLogs(String type) async {
    final localLogs = await StorageService.getHealthLogs(type);
    if (localLogs.isNotEmpty) {
      _updateStateForType(type, localLogs);
    }
    state = state.copyWith(isLoading: false);

    try {
      final res = await _apiService.client.get('${ApiConstants.healthLogs}?type=$type&days=30');
      if (res.data['success'] == true) {
        final list = (res.data['data'] as List)
            .map((h) => HealthLogModel.fromJson(h))
            .toList();
        _updateStateForType(type, list);
        await StorageService.saveHealthLogs(type, list);
      }
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  void _updateStateForType(String type, List<HealthLogModel> list) {
    if (type == 'blood_pressure') {
      state = state.copyWith(bpLogs: list);
    } else if (type == 'blood_sugar') {
      state = state.copyWith(sugarLogs: list);
    } else if (type == 'weight') {
      state = state.copyWith(weightLogs: list);
    } else if (type == 'pulse') {
      state = state.copyWith(pulseLogs: list);
    }
  }

  Future<bool> addLog({
    required String type,
    required double value1,
    double? value2,
    String? unit,
    String? mealContext,
    String? notes,
  }) async {
    final newId = DateTime.now().millisecondsSinceEpoch % 100000;
    final newLog = HealthLogModel(
      id: newId,
      userId: 2,
      type: type,
      value1: value1,
      value2: value2,
      unit: unit,
      mealContext: mealContext,
      notes: notes,
      recordedAt: DateTime.now().toIso8601String(),
    );

    List<HealthLogModel> currentList = [];
    if (type == 'blood_pressure') currentList = [...state.bpLogs, newLog];
    if (type == 'blood_sugar') currentList = [...state.sugarLogs, newLog];
    if (type == 'weight') currentList = [...state.weightLogs, newLog];
    if (type == 'pulse') currentList = [...state.pulseLogs, newLog];

    _updateStateForType(type, currentList);
    await StorageService.saveHealthLogs(type, currentList);

    // Try API in background, enqueue if offline
    final payload = {
      'type': type,
      'value_1': value1,
      'value_2': value2,
      'unit': unit,
      'meal_context': mealContext,
      'notes': notes,
    };
    try {
      await _apiService.client.post(ApiConstants.healthLogs, data: payload);
    } catch (_) {
      await SyncQueueService.enqueue('POST', ApiConstants.healthLogs, payload);
    }

    return true;
  }
}

final healthLogProvider =
    StateNotifierProvider<HealthLogNotifier, HealthLogState>((ref) {
  return HealthLogNotifier(ref.watch(apiServiceProvider));
});
