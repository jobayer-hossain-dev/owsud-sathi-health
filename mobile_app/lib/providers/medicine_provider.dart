import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';
import '../core/constants/api_constants.dart';
import '../data/models/user_medicine_model.dart';
import '../data/models/dose_log_model.dart';
import '../data/models/medicine_model.dart';
import '../data/seeds/offline_medicine_dataset.dart';
import '../core/services/sync_queue_service.dart';
import '../core/services/notification_service.dart';
import 'auth_provider.dart';

class MedicineState {
  final bool isLoading;
  final List<UserMedicineModel> userMedicines;
  final List<DoseLogModel> todayDoseLogs;
  final List<MedicineModel> searchResults;
  final String? errorMessage;

  MedicineState({
    this.isLoading = false,
    this.userMedicines = const [],
    this.todayDoseLogs = const [],
    this.searchResults = const [],
    this.errorMessage,
  });

  MedicineState copyWith({
    bool? isLoading,
    List<UserMedicineModel>? userMedicines,
    List<DoseLogModel>? todayDoseLogs,
    List<MedicineModel>? searchResults,
    String? errorMessage,
  }) {
    return MedicineState(
      isLoading: isLoading ?? this.isLoading,
      userMedicines: userMedicines ?? this.userMedicines,
      todayDoseLogs: todayDoseLogs ?? this.todayDoseLogs,
      searchResults: searchResults ?? this.searchResults,
      errorMessage: errorMessage,
    );
  }
}

class MedicineNotifier extends StateNotifier<MedicineState> {
  final ApiService _apiService;

  MedicineNotifier(this._apiService) : super(MedicineState()) {
    _loadLocalInitialData();
  }

  Future<void> _loadLocalInitialData() async {
    final localMeds = await StorageService.getUserMedicines();
    final localDoses = await StorageService.getTodayDoseLogs();

    // Default seed medicines for fresh install if completely empty
    if (localMeds.isEmpty) {
      final defaultSeedMeds = [
        UserMedicineModel(
          id: 1,
          userId: 2,
          customName: 'Napa 500mg',
          dosage: '১টি ট্যাবলেট',
          frequency: 'twice_daily',
          times: ['08:00', '22:00'],
          mealInstruction: 'after_meal',
          startDate: DateTime.now().toIso8601String().split('T')[0],
          totalQuantity: 30,
          remainingQuantity: 28,
          refillAlertDays: 3,
          isActive: true,
          brandName: 'Napa 500mg',
          genericName: 'Paracetamol',
        ),
        UserMedicineModel(
          id: 2,
          userId: 2,
          customName: 'Seclo 20mg',
          dosage: '১টি ক্যাপসুল',
          frequency: 'twice_daily',
          times: ['07:30', '21:30'],
          mealInstruction: 'before_meal',
          startDate: DateTime.now().toIso8601String().split('T')[0],
          totalQuantity: 30,
          remainingQuantity: 5, // Low stock alert demo
          refillAlertDays: 3,
          isActive: true,
          brandName: 'Seclo 20mg',
          genericName: 'Omeprazole',
        ),
      ];
      await StorageService.saveUserMedicines(defaultSeedMeds);

      final defaultSeedDoses = [
        DoseLogModel(
          id: 1,
          userMedicineId: 1,
          userId: 2,
          scheduledTime: '08:00 AM',
          status: 'taken',
          brandName: 'Napa 500mg',
          dosage: '১টি ট্যাবলেট',
          mealInstruction: 'after_meal',
        ),
        DoseLogModel(
          id: 2,
          userMedicineId: 2,
          userId: 2,
          scheduledTime: '07:30 AM',
          status: 'taken',
          brandName: 'Seclo 20mg',
          dosage: '১টি ক্যাপসুল',
          mealInstruction: 'before_meal',
        ),
        DoseLogModel(
          id: 3,
          userMedicineId: 1,
          userId: 2,
          scheduledTime: '10:00 PM',
          status: 'pending',
          brandName: 'Napa 500mg',
          dosage: '১টি ট্যাবলেট',
          mealInstruction: 'after_meal',
        ),
      ];
      await StorageService.saveTodayDoseLogs(defaultSeedDoses);
      state = state.copyWith(userMedicines: defaultSeedMeds, todayDoseLogs: defaultSeedDoses);
    } else {
      state = state.copyWith(userMedicines: localMeds, todayDoseLogs: localDoses);
    }
  }

  Future<void> fetchUserMedicines() async {
    final localMeds = await StorageService.getUserMedicines();
    state = state.copyWith(
      isLoading: false,
      userMedicines: localMeds,
      errorMessage: null,
    );

    try {
      final res = await _apiService.client.get(ApiConstants.userMedicines);
      if (res.data['success'] == true) {
        final list = (res.data['data'] as List)
            .map((m) => UserMedicineModel.fromJson(m))
            .toList();
        state = state.copyWith(isLoading: false, userMedicines: list);
        await StorageService.saveUserMedicines(list);
      }
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> fetchTodayDoseLogs() async {
    final localDoses = await StorageService.getTodayDoseLogs();
    if (localDoses.isNotEmpty) {
      state = state.copyWith(todayDoseLogs: localDoses);
    }

    final dateStr = DateTime.now().toIso8601String().split('T')[0];
    try {
      final res = await _apiService.client.get('${ApiConstants.doseLogs}?date=$dateStr');
      if (res.data['success'] == true) {
        final list = (res.data['data'] as List)
            .map((d) => DoseLogModel.fromJson(d))
            .toList();
        state = state.copyWith(todayDoseLogs: list);
        await StorageService.saveTodayDoseLogs(list);
      }
    } catch (_) {}
  }

  Future<void> searchMedicines(String query) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(searchResults: []);
      return;
    }

    // Immediate offline search from bundled dataset
    final offlineResults = OfflineMedicineDataset.search(query);
    state = state.copyWith(searchResults: offlineResults);

    try {
      final res = await _apiService.client.get('${ApiConstants.medicines}?q=$query&limit=15');
      if (res.data['success'] == true) {
        final apiList = (res.data['data'] as List)
            .map((m) => MedicineModel.fromJson(m))
            .toList();
        if (apiList.isNotEmpty) {
          state = state.copyWith(searchResults: apiList);
        }
      }
    } catch (_) {}
  }

  Future<bool> addUserMedicine(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true);

    // Create local entry immediately (Local-First 0ms response)
    final newId = DateTime.now().millisecondsSinceEpoch % 100000;
    final name = data['brand_name'] ?? data['custom_name'] ?? 'নতুন ওষুধ';

    final newMed = UserMedicineModel(
      id: newId,
      userId: 2,
      medicineId: data['medicine_id'],
      customName: data['custom_name'],
      brandName: name,
      genericName: data['generic_name'],
      dosage: data['dosage'],
      frequency: data['frequency'] ?? 'once_daily',
      times: List<String>.from(data['times'] ?? ['08:00']),
      mealInstruction: data['meal_instruction'] ?? 'after_meal',
      startDate: data['start_date'] ?? DateTime.now().toIso8601String().split('T')[0],
      totalQuantity: data['total_quantity'] ?? 30,
      remainingQuantity: data['total_quantity'] ?? 30,
      refillAlertDays: data['refill_alert_days'] ?? 3,
      isActive: true,
    );

    final updatedMeds = [...state.userMedicines, newMed];
    await StorageService.saveUserMedicines(updatedMeds);

    // Generate local dose logs for today and trigger notifications
    final newDoseLogs = <DoseLogModel>[...state.todayDoseLogs];
    for (int i = 0; i < newMed.times.length; i++) {
      final doseId = newId * 10 + i;
      final timeStr = newMed.times[i];
      newDoseLogs.add(
        DoseLogModel(
          id: doseId,
          userMedicineId: newId,
          userId: 2,
          scheduledTime: timeStr,
          status: 'pending',
          brandName: name,
          dosage: newMed.dosage,
          mealInstruction: newMed.mealInstruction,
        ),
      );

      // Schedule notification and voice TTS
      try {
        await NotificationService().scheduleMedicineReminder(
          id: doseId,
          medicineName: name,
          scheduledTimeStr: timeStr,
        );
      } catch (_) {}
    }
    await StorageService.saveTodayDoseLogs(newDoseLogs);

    state = state.copyWith(
      isLoading: false,
      userMedicines: updatedMeds,
      todayDoseLogs: newDoseLogs,
    );

    // Try sync with API in background
    try {
      await _apiService.client.post(ApiConstants.userMedicines, data: data);
    } catch (_) {}

    return true;
  }

  Future<bool> markDoseStatus(int doseLogId, String status) async {
    // Update local dose log status immediately
    int? matchedMedId;
    final updatedLogs = state.todayDoseLogs.map((log) {
      if (log.id == doseLogId) {
        matchedMedId = log.userMedicineId;
        return DoseLogModel(
          id: log.id,
          userMedicineId: log.userMedicineId,
          userId: log.userId,
          scheduledTime: log.scheduledTime,
          status: status,
          takenAt: DateTime.now().toIso8601String(),
          brandName: log.brandName,
          customName: log.customName,
          dosage: log.dosage,
          mealInstruction: log.mealInstruction,
        );
      }
      return log;
    }).toList();

    List<UserMedicineModel> updatedMeds = state.userMedicines;
    if (status == 'taken' && matchedMedId != null) {
      updatedMeds = state.userMedicines.map((m) {
        if (m.id == matchedMedId && m.remainingQuantity != null && m.remainingQuantity! > 0) {
          return UserMedicineModel(
            id: m.id,
            userId: m.userId,
            medicineId: m.medicineId,
            customName: m.customName,
            dosage: m.dosage,
            frequency: m.frequency,
            times: m.times,
            mealInstruction: m.mealInstruction,
            startDate: m.startDate,
            endDate: m.endDate,
            totalQuantity: m.totalQuantity,
            remainingQuantity: m.remainingQuantity! - 1,
            refillAlertDays: m.refillAlertDays,
            notes: m.notes,
            isActive: m.isActive,
            brandName: m.brandName,
            genericName: m.genericName,
            dosageForm: m.dosageForm,
          );
        }
        return m;
      }).toList();
      await StorageService.saveUserMedicines(updatedMeds);
    }

    state = state.copyWith(todayDoseLogs: updatedLogs, userMedicines: updatedMeds);
    await StorageService.saveTodayDoseLogs(updatedLogs);

    // Try API in background, enqueue if failed
    try {
      await _apiService.client.post('${ApiConstants.doseLogs}/$doseLogId/$status');
    } catch (_) {
      await SyncQueueService.enqueue(
        'POST',
        '${ApiConstants.doseLogs}/$doseLogId/$status',
        {'status': status},
      );
    }

    return true;
  }
}

final medicineProvider =
    StateNotifierProvider<MedicineNotifier, MedicineState>((ref) {
  return MedicineNotifier(ref.watch(apiServiceProvider));
});
