import 'dart:convert';

class PrescriptionImageModel {
  final int id;
  final int prescriptionId;
  final String imagePath;

  PrescriptionImageModel({
    required this.id,
    required this.prescriptionId,
    required this.imagePath,
  });

  factory PrescriptionImageModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionImageModel(
      id: json['id'] ?? 0,
      prescriptionId: json['prescription_id'] ?? 0,
      imagePath: json['image_path'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prescription_id': prescriptionId,
      'image_path': imagePath,
    };
  }
}

class PrescriptionModel {
  final int id;
  final int userId;
  final String? doctorName;
  final String? hospitalName;
  final String? diagnosis;
  final String visitDate;
  final String? nextVisitDate;
  final String? notes;
  final List<PrescriptionImageModel> images;

  PrescriptionModel({
    required this.id,
    required this.userId,
    this.doctorName,
    this.hospitalName,
    this.diagnosis,
    required this.visitDate,
    this.nextVisitDate,
    this.notes,
    required this.images,
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    List<PrescriptionImageModel> imgs = [];
    if (json['images'] != null) {
      dynamic rawImages = json['images'];
      if (rawImages is String) {
        try {
          rawImages = jsonDecode(rawImages);
        } catch (_) {}
      }
      if (rawImages is List) {
        imgs = rawImages.map((i) => PrescriptionImageModel.fromJson(i)).toList();
      }
    }
    return PrescriptionModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      doctorName: json['doctor_name'],
      hospitalName: json['hospital_name'],
      diagnosis: json['diagnosis'],
      visitDate: json['visit_date'] ?? '',
      nextVisitDate: json['next_visit_date'],
      notes: json['notes'],
      images: imgs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'doctor_name': doctorName,
      'hospital_name': hospitalName,
      'diagnosis': diagnosis,
      'visit_date': visitDate,
      'next_visit_date': nextVisitDate,
      'notes': notes,
      'images': images.map((i) => i.toJson()).toList(),
    };
  }
}
