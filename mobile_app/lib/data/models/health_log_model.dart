class HealthLogModel {
  final int id;
  final int userId;
  final String type; // blood_pressure, blood_sugar, weight
  final double value1;
  final double? value2;
  final String? unit;
  final String? mealContext;
  final String? notes;
  final String recordedAt;

  HealthLogModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.value1,
    this.value2,
    this.unit,
    this.mealContext,
    this.notes,
    required this.recordedAt,
  });

  factory HealthLogModel.fromJson(Map<String, dynamic> json) {
    return HealthLogModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      type: json['type'] ?? 'blood_pressure',
      value1: (json['value_1'] != null) ? double.parse(json['value_1'].toString()) : 0.0,
      value2: (json['value_2'] != null) ? double.parse(json['value_2'].toString()) : null,
      unit: json['unit'],
      mealContext: json['meal_context'],
      notes: json['notes'],
      recordedAt: json['recorded_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'value_1': value1,
      'value_2': value2,
      'unit': unit,
      'meal_context': mealContext,
      'notes': notes,
      'recorded_at': recordedAt,
    };
  }
}
