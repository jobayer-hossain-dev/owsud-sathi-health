class EmergencyContactModel {
  final String id;
  final String name;
  final String phone;
  final String relation;
  final bool isAutoImported;

  EmergencyContactModel({
    required this.id,
    required this.name,
    required this.phone,
    this.relation = 'স্বজন',
    this.isAutoImported = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'relation': relation,
        'is_auto_imported': isAutoImported,
      };

  factory EmergencyContactModel.fromJson(Map<String, dynamic> json) =>
      EmergencyContactModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        phone: json['phone'] ?? '',
        relation: json['relation'] ?? 'স্বজন',
        isAutoImported: json['is_auto_imported'] ?? false,
      );

  EmergencyContactModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? relation,
    bool? isAutoImported,
  }) {
    return EmergencyContactModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      relation: relation ?? this.relation,
      isAutoImported: isAutoImported ?? this.isAutoImported,
    );
  }
}
