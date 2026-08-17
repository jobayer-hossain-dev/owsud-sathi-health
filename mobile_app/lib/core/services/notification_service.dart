import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FlutterTts _flutterTts = FlutterTts();

  Future<void> init() async {
    // 1. Request notification permissions for Android 13+
    await Permission.notification.request();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null && details.payload!.isNotEmpty) {
          speakMedicineReminder(details.payload!);
        }
      },
    );

    // 2. Initialize TTS with Bengali voice support and fallback
    try {
      await _flutterTts.setLanguage("bn-BD");
      await _flutterTts.setSpeechRate(0.45);
      await _flutterTts.setPitch(1.0);
    } catch (_) {
      try {
        await _flutterTts.setLanguage("en-US");
      } catch (_) {}
    }
  }

  Future<void> scheduleMedicineReminder({
    required int id,
    required String medicineName,
    required String scheduledTimeStr, // e.g. "08:00" or "08:00 AM"
  }) async {
    try {
      final parts = scheduledTimeStr.split(' ')[0].split(':');
      if (parts.length < 2) return;

      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      if (scheduledTimeStr.contains('PM') && hour < 12) hour += 12;
      if (scheduledTimeStr.contains('AM') && hour == 12) hour = 0;

      final now = DateTime.now();
      var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final delay = scheduledDate.difference(now);

      // Trigger immediate confirmation TTS test & local notification setup
      await showMedicineNotification(
        id: id,
        title: '⏰ মেডিসিন অ্যালার্ম সেট করা হয়েছে',
        body: '$medicineName খাওয়ার সময়: $scheduledTimeStr',
        payload: medicineName,
      );

      // Timer background trigger
      Future.delayed(delay, () {
        showMedicineNotification(
          id: id + 1000,
          title: '💊 ওষুধ খাওয়ার সময় হয়েছে!',
          body: 'এখন আপনার $medicineName খাওয়ার সময়। দয়া করে ওষুধটি খেয়ে নিন।',
          payload: medicineName,
        );
      });
    } catch (_) {}
  }

  Future<void> showMedicineNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'medicine_reminder_channel',
      'মেডিসিন রিমাইন্ডার',
      channelDescription: 'ওষুধ খাওয়ার সময় অনুস্মারক',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      details,
      payload: payload ?? title,
    );

    if (payload != null && payload.isNotEmpty) {
      speakMedicineReminder(payload);
    }
  }

  Future<void> speakMedicineReminder(String medicineName) async {
    try {
      await _flutterTts.stop();
      await _flutterTts.speak("আসসালামু আলাইকুম। এখন আপনার $medicineName খাওয়ার সময় হয়েছে। দয়া করে ওষুধ খেয়ে নিন।");
    } catch (_) {}
  }
}