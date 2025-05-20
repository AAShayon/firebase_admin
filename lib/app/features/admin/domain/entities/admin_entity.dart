class AdminEntity {
  final String userId;
  final DateTime assignedAt;
  final bool isSuperAdmin;

  AdminEntity({
    required this.userId,
    required this.assignedAt,
    required this.isSuperAdmin,
  });
}