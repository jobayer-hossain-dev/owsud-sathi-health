class DoseLogModel {
  final int id;
  final int userMedicineId;
  final int userId;
  final String scheduledTime;
  final String status; // taken, missed, skipped, pending
  final String? takenAt;
  final String? brandName;
  final String? customName;
  final String? dosage;
  final String? mealInstruction;

  DoseLogModel({
    required this.id,
    required this.userMedicineId,
    required this.userId,
    required this.scheduledTime,
    required this.status,
    this.takenAt,
    this.brandName,
    this.customName,
    this.dosage,
    this.mealInstruction,
  });

  String get displayName => brandName ?? customName ?? 'মেডিসিন';

  factory DoseLogModel.fromJson(Map<String, dynamic> json) {
    return DoseLogModel(
      id: json['id'] ?? 0,
      userMedicineId: json['user_medicine_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      scheduledTime: json['scheduled_time'] ?? '',
      status: json['status'] ?? 'pending',
      takenAt: json['taken_at'],
      brandName: json['brand_name'],
      customName: json['custom_name'],
      dosage: json['dosage'],
      mealInstruction: json['meal_instruction'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_medicine_id': userMedicineId,
      'user_id': userId,
      'scheduled_time': scheduledTime,
      'status': status,
      'taken_at': takenAt,
      'brand_name': brandName,
      'custom_name': customName,
      'dosage': dosage,
      'meal_instruction': mealInstruction,
    };
  }
}
