import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';
import '../core/constants/api_constants.dart';
import '../data/models/doctor_appointment_model.dart';
import 'auth_provider.dart';

class AppointmentState {
  final bool isLoading;
  final List<DoctorAppointmentModel> appointments;

  AppointmentState({
    this.isLoading = false,
    this.appointments = const [],
  });

  AppointmentState copyWith({
    bool? isLoading,
    List<DoctorAppointmentModel>? appointments,
  }) {
    return AppointmentState(
      isLoading: isLoading ?? this.isLoading,
      appointments: appointments ?? this.appointments,
    );
  }
}

class AppointmentNotifier extends StateNotifier<AppointmentState> {
  final ApiService _apiService;

  AppointmentNotifier(this._apiService) : super(AppointmentState()) {
    _loadLocalInitialData();
  }

  Future<void> _loadLocalInitialData() async {
    final localList = await StorageService.getAppointments();
    if (localList.isNotEmpty) {
      state = state.copyWith(appointments: localList);
    } else {
      final defaultSeed = [
        DoctorAppointmentModel(
          id: 1,
          userId: 2,
          doctorName: 'ডাঃ তৌহিদ হোসাইন',
          hospitalName: 'স্কয়ার হাসপাতাল, ঢাকা',
          phone: '01711-223344',
          appointmentDate: '2026-08-25',
          reminderDays: 3,
          notes: 'নিয়মিত ফলোআপ ভিজিট ও ব্লাড টেস্ট রিপোটিং',
        ),
      ];
      await StorageService.saveAppointments(defaultSeed);
      state = state.copyWith(appointments: defaultSeed);
    }
  }

  Future<void> fetchAppointments() async {
    final localList = await StorageService.getAppointments();
    state = state.copyWith(isLoading: false, appointments: localList);

    try {
      final res = await _apiService.client.get(ApiConstants.appointments);
      if (res.data['success'] == true) {
        final list = (res.data['data'] as List)
            .map((a) => DoctorAppointmentModel.fromJson(a))
            .toList();
        state = state.copyWith(isLoading: false, appointments: list);
        await StorageService.saveAppointments(list);
      }
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> addAppointment({
    required String doctorName,
    String? hospitalName,
    String? phone,
    required String appointmentDate,
    int reminderDays = 7,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true);

    final newId = DateTime.now().millisecondsSinceEpoch % 100000;
    final newAppt = DoctorAppointmentModel(
      id: newId,
      userId: 2,
      doctorName: doctorName,
      hospitalName: hospitalName,
      phone: phone,
      appointmentDate: appointmentDate,
      reminderDays: reminderDays,
      notes: notes,
    );

    final updatedList = [...state.appointments, newAppt];
    state = state.copyWith(isLoading: false, appointments: updatedList);
    await StorageService.saveAppointments(updatedList);

    // Try API in background
    try {
      await _apiService.client.post(ApiConstants.appointments, data: {
        'doctor_name': doctorName,
        'hospital_name': hospitalName,
        'phone': phone,
        'appointment_date': appointmentDate,
        'reminder_days': reminderDays,
        'notes': notes,
      });
    } catch (_) {}

    return true;
  }
}

final appointmentProvider =
    StateNotifierProvider<AppointmentNotifier, AppointmentState>((ref) {
  return AppointmentNotifier(ref.watch(apiServiceProvider));
});
