import 'package:flutter/foundation.dart';

class ApiConstants {
  // Physical Device Testing on Same Wi-Fi (Use your PC's IP):
  static const String lanUrl = 'http://192.168.31.106:3001/api/v1';
  
  // Android Emulator:
  static const String emulatorUrl = 'http://10.0.2.2:3001/api/v1';

  // Web Browser / Localhost:
  static const String localhostUrl = 'http://localhost:3001/api/v1';

  // Live Production Server (cPanel):
  static const String liveUrl = 'https://oshudhsathi.com/api/v1';

  // Active Base URL (Dynamically switches for Web browser / LAN):
  static String get baseUrl {
    if (kIsWeb) {
      return localhostUrl;
    }
    return lanUrl;
  }

  // Auth
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String updateProfile = '/auth/profile';

  // Medicines
  static const String medicines = '/medicines';
  static const String userMedicines = '/user-medicines';
  static const String doseLogs = '/dose-logs';

  // Health
  static const String healthLogs = '/health-logs';

  // Prescriptions
  static const String prescriptions = '/prescriptions';

  // Family & Appointments
  static const String family = '/family';
  static const String appointments = '/appointments';
}
