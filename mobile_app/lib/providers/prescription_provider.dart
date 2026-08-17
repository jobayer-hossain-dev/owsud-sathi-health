import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';
import '../core/constants/api_constants.dart';
import '../data/models/prescription_model.dart';
import 'auth_provider.dart';

class PrescriptionState {
  final bool isLoading;
  final List<PrescriptionModel> prescriptions;

  PrescriptionState({
    this.isLoading = false,
    this.prescriptions = const [],
  });

  PrescriptionState copyWith({
    bool? isLoading,
    List<PrescriptionModel>? prescriptions,
  }) {
    return PrescriptionState(
      isLoading: isLoading ?? this.isLoading,
      prescriptions: prescriptions ?? this.prescriptions,
    );
  }
}

class PrescriptionNotifier extends StateNotifier<PrescriptionState> {
  final ApiService _apiService;

  PrescriptionNotifier(this._apiService) : super(PrescriptionState()) {
    _loadLocalInitialData();
  }

  Future<void> _loadLocalInitialData() async {
    final localList = await StorageService.getPrescriptions();
    if (localList.isNotEmpty) {
      state = state.copyWith(prescriptions: localList);
    }
  }

  Future<void> fetchPrescriptions() async {
    final localList = await StorageService.getPrescriptions();
    state = state.copyWith(isLoading: false, prescriptions: localList);

    try {
      final res = await _apiService.client.get(ApiConstants.prescriptions);
      if (res.data['success'] == true) {
        final list = (res.data['data'] as List)
            .map((p) => PrescriptionModel.fromJson(p))
            .toList();
        state = state.copyWith(isLoading: false, prescriptions: list);
        await StorageService.savePrescriptions(list);
      }
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> addPrescription({
    String? doctorName,
    String? hospitalName,
    String? diagnosis,
    required String visitDate,
    String? nextVisitDate,
    String? notes,
    List<String>? imagePaths,
  }) async {
    state = state.copyWith(isLoading: true);

    final newId = DateTime.now().millisecondsSinceEpoch % 100000;
    final List<PrescriptionImageModel> localImages = (imagePaths ?? [])
        .map((p) => PrescriptionImageModel(id: newId + 1, prescriptionId: newId, imagePath: p))
        .toList();

    final newPrescription = PrescriptionModel(
      id: newId,
      userId: 2,
      doctorName: doctorName ?? 'ডাক্তার নির্দেশিত প্রেসক্রিপশন',
      hospitalName: hospitalName ?? 'হাসপাতাল / চেম্বার',
      diagnosis: diagnosis,
      visitDate: visitDate,
      nextVisitDate: nextVisitDate,
      notes: notes,
      images: localImages,
    );

    final updatedList = [...state.prescriptions, newPrescription];
    state = state.copyWith(isLoading: false, prescriptions: updatedList);
    await StorageService.savePrescriptions(updatedList);

    // Try API in background
    try {
      final formData = FormData();
      if (doctorName != null) formData.fields.add(MapEntry('doctor_name', doctorName));
      if (hospitalName != null) formData.fields.add(MapEntry('hospital_name', hospitalName));
      if (diagnosis != null) formData.fields.add(MapEntry('diagnosis', diagnosis));
      formData.fields.add(MapEntry('visit_date', visitDate));
      if (nextVisitDate != null) formData.fields.add(MapEntry('next_visit_date', nextVisitDate));
      if (notes != null) formData.fields.add(MapEntry('notes', notes));

      if (imagePaths != null) {
        for (var p in imagePaths) {
          formData.files.add(MapEntry(
            'images',
            await MultipartFile.fromFile(p),
          ));
        }
      }

      await _apiService.client.post(ApiConstants.prescriptions, data: formData);
    } catch (_) {}

    return true;
  }
}

final prescriptionProvider =
    StateNotifierProvider<PrescriptionNotifier, PrescriptionState>((ref) {
  return PrescriptionNotifier(ref.watch(apiServiceProvider));
});
