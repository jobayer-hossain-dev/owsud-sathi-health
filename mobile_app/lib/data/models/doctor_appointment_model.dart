class DoctorAppointmentModel {
  final int id;
  final int userId;
  final String doctorName;
  final String? hospitalName;
  final String? phone;
  final String appointmentDate;
  final int reminderDays;
  final String? notes;

  DoctorAppointmentModel({
    required this.id,
    required this.userId,
    required this.doctorName,
    this.hospitalName,
    this.phone,
    required this.appointmentDate,
    required this.reminderDays,
    this.notes,
  });

  factory DoctorAppointmentModel.fromJson(Map<String, dynamic> json) {
    return DoctorAppointmentModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      doctorName: json['doctor_name'] ?? '',
      hospitalName: json['hospital_name'],
      phone: json['phone'],
      appointmentDate: json['appointment_date'] ?? '',
      reminderDays: json['reminder_days'] ?? 7,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'doctor_name': doctorName,
      'hospital_name': hospitalName,
      'phone': phone,
      'appointment_date': appointmentDate,
      'reminder_days': reminderDays,
      'notes': notes,
    };
  }
}
