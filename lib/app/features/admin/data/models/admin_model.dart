
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminModel {
  final String userId;
  final DateTime assignedAt;
  final bool isSuperAdmin;

  AdminModel({
    required this.userId,
    required this.assignedAt,
    required this.isSuperAdmin,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      userId: json['userId'],
      assignedAt: (json['assignedAt'] as Timestamp).toDate(),
      isSuperAdmin: json['isSuperAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'assignedAt': assignedAt,
      'isSuperAdmin': isSuperAdmin,
    };
  }
}