import 'dart:convert';

class UserMedicineModel {
  final int id;
  final int userId;
  final int? medicineId;
  final String? customName;
  final String? dosage;
  final String frequency;
  final List<String> times;
  final String mealInstruction;
  final String startDate;
  final String? endDate;
  final int? totalQuantity;
  final int? remainingQuantity;
  final int refillAlertDays;
  final String? notes;
  final bool isActive;
  final String? brandName;
  final String? genericName;
  final String? dosageForm;

  UserMedicineModel({
    required this.id,
    required this.userId,
    this.medicineId,
    this.customName,
    this.dosage,
    required this.frequency,
    required this.times,
    required this.mealInstruction,
    required this.startDate,
    this.endDate,
    this.totalQuantity,
    this.remainingQuantity,
    required this.refillAlertDays,
    this.notes,
    required this.isActive,
    this.brandName,
    this.genericName,
    this.dosageForm,
  });

  String get displayName => brandName ?? customName ?? 'ওষুধ';

  factory UserMedicineModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedTimes = [];
    if (json['times'] != null) {
      if (json['times'] is List) {
        parsedTimes = List<String>.from(json['times']);
      } else if (json['times'] is String) {
        try {
          final decoded = jsonDecode(json['times']);
          if (decoded is List) {
            parsedTimes = List<String>.from(decoded);
          } else {
            parsedTimes = [json['times'].toString()];
          }
        } catch (_) {
          parsedTimes = [json['times'].toString()];
        }
      }
    }

    return UserMedicineModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      medicineId: json['medicine_id'],
      customName: json['custom_name'],
      dosage: json['dosage'],
      frequency: json['frequency'] ?? 'once_daily',
      times: parsedTimes,
      mealInstruction: json['meal_instruction'] ?? 'any',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'],
      totalQuantity: json['total_quantity'],
      remainingQuantity: json['remaining_quantity'],
      refillAlertDays: json['refill_alert_days'] ?? 3,
      notes: json['notes'],
      isActive: (json['is_active'] == 1 || json['is_active'] == true),
      brandName: json['brand_name'],
      genericName: json['generic_name'],
      dosageForm: json['dosage_form'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'medicine_id': medicineId,
      'custom_name': customName,
      'dosage': dosage,
      'frequency': frequency,
      'times': times,
      'meal_instruction': mealInstruction,
      'start_date': startDate,
      'end_date': endDate,
      'total_quantity': totalQuantity,
      'remaining_quantity': remainingQuantity,
      'refill_alert_days': refillAlertDays,
      'notes': notes,
      'is_active': isActive ? 1 : 0,
      'brand_name': brandName,
      'generic_name': genericName,
      'dosage_form': dosageForm,
    };
  }
}
