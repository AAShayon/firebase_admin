
import 'package:firebase_admin/app/features/auth/domain/entities/user_roles.dart';

class UserEntity {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool isAdmin;
  final UserRole role;

  UserEntity({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    this.isAdmin = false,
    this.role = UserRole.user,
  });
}