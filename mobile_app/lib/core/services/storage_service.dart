import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_model.dart';
import '../../data/models/user_medicine_model.dart';
import '../../data/models/dose_log_model.dart';
import '../../data/models/health_log_model.dart';
import '../../data/models/prescription_model.dart';
import '../../data/models/doctor_appointment_model.dart';

class StorageService {
  static const String _keyToken = 'jwt_token';
  static const String _keyUser = 'user_data';
  static const String _keyOnboarding = 'onboarding_complete';
  static const String _keyMedicines = 'local_user_medicines';
  static const String _keyDoseLogs = 'local_today_dose_logs';
  static const String _keyHealthLogsPrefix = 'local_health_logs_';
  static const String _keyPrescriptions = 'local_prescriptions';
  static const String _keyAppointments = 'local_appointments';
  static const String _keyEmergencyContacts = 'local_emergency_contacts';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, jsonEncode(user.toJson()));
  }

  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyUser);
    if (jsonStr == null) return null;
    return UserModel.fromJson(jsonDecode(jsonStr));
  }

  static Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUser);
  }

  static Future<void> setOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboarding, true);
  }

  static Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboarding) ?? false;
  }

  // --- Offline Domain Persistence Methods ---

  static Future<void> saveUserMedicines(List<UserMedicineModel> medicines) async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = medicines.map((m) => m.toJson()).toList();
    await prefs.setString(_keyMedicines, jsonEncode(rawList));
  }

  static Future<List<UserMedicineModel>> getUserMedicines() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_keyMedicines);
    if (str == null) return [];
    try {
      final List decoded = jsonDecode(str);
      return decoded.map((m) => UserMedicineModel.fromJson(m)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveTodayDoseLogs(List<DoseLogModel> logs) async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = logs.map((l) => l.toJson()).toList();
    await prefs.setString(_keyDoseLogs, jsonEncode(rawList));
  }

  static Future<List<DoseLogModel>> getTodayDoseLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_keyDoseLogs);
    if (str == null) return [];
    try {
      final List decoded = jsonDecode(str);
      return decoded.map((l) => DoseLogModel.fromJson(l)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveHealthLogs(String type, List<HealthLogModel> logs) async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = logs.map((l) => l.toJson()).toList();
    await prefs.setString('$_keyHealthLogsPrefix$type', jsonEncode(rawList));
  }

  static Future<List<HealthLogModel>> getHealthLogs(String type) async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString('$_keyHealthLogsPrefix$type');
    if (str == null) return [];
    try {
      final List decoded = jsonDecode(str);
      return decoded.map((l) => HealthLogModel.fromJson(l)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> savePrescriptions(List<PrescriptionModel> list) async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = list.map((p) => p.toJson()).toList();
    await prefs.setString(_keyPrescriptions, jsonEncode(rawList));
  }

  static Future<List<PrescriptionModel>> getPrescriptions() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_keyPrescriptions);
    if (str == null) return [];
    try {
      final List decoded = jsonDecode(str);
      return decoded.map((p) => PrescriptionModel.fromJson(p)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveAppointments(List<DoctorAppointmentModel> list) async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = list.map((a) => a.toJson()).toList();
    await prefs.setString(_keyAppointments, jsonEncode(rawList));
  }

  static Future<List<DoctorAppointmentModel>> getAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_keyAppointments);
    if (str == null) return [];
    try {
      final List decoded = jsonDecode(str);
      return decoded.map((a) => DoctorAppointmentModel.fromJson(a)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveEmergencyContacts(List<Map<String, dynamic>> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmergencyContacts, jsonEncode(contacts));
  }

  static Future<List<Map<String, dynamic>>> getEmergencyContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_keyEmergencyContacts);
    if (str == null) return [];
    try {
      final List decoded = jsonDecode(str);
      return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (_) {
      return [];
    }
  }
}
