class UserModel {
  final int id;
  final String phone;
  final String name;
  final String? dateOfBirth;
  final String? gender;
  final String? bloodGroup;
  final String? allergies;
  final String? chronicConditions;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? profileImageUrl;

  UserModel({
    required this.id,
    required this.phone,
    required this.name,
    this.dateOfBirth,
    this.gender,
    this.bloodGroup,
    this.allergies,
    this.chronicConditions,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.profileImageUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      phone: json['phone'] ?? '',
      name: json['name'] ?? '',
      dateOfBirth: json['date_of_birth'],
      gender: json['gender'],
      bloodGroup: json['blood_group'],
      allergies: json['allergies'],
      chronicConditions: json['chronic_conditions'],
      emergencyContactName: json['emergency_contact_name'],
      emergencyContactPhone: json['emergency_contact_phone'],
      profileImageUrl: json['profile_image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'name': name,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'blood_group': bloodGroup,
      'allergies': allergies,
      'chronic_conditions': chronicConditions,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
      'profile_image_url': profileImageUrl,
    };
  }
}
