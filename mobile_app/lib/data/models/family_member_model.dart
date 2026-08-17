class FamilyMemberModel {
  final int linkId;
  final int userId;
  final String name;
  final String phone;
  final String? relationship;
  final String status;
  final List<dynamic>? todayLogs;

  FamilyMemberModel({
    required this.linkId,
    required this.userId,
    required this.name,
    required this.phone,
    this.relationship,
    required this.status,
    this.todayLogs,
  });

  factory FamilyMemberModel.fromJson(Map<String, dynamic> json) {
    return FamilyMemberModel(
      linkId: json['link_id'] ?? json['id'] ?? 0,
      userId: json['user_id'] ?? json['owner_id'] ?? 0,
      name: json['name'] ?? 'সদস্য',
      phone: json['phone'] ?? '',
      relationship: json['relationship'],
      status: json['status'] ?? 'pending',
      todayLogs: json['today_logs'],
    );
  }
}
