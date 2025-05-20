// lib/features/auth/domain/entities/user_role.dart
enum UserRole {
  superAdmin,
  admin,
  subAdmin,
  user
}

extension UserRoleExtension on UserRole {
  String get name {
    switch (this) {
      case UserRole.superAdmin: return 'Super Admin';
      case UserRole.admin: return 'Admin';
      case UserRole.subAdmin: return 'Sub Admin';
      case UserRole.user: return 'User';
    }
  }

  int get hierarchyLevel {
    switch (this) {
      case UserRole.superAdmin: return 4;
      case UserRole.admin: return 3;
      case UserRole.subAdmin: return 2;
      case UserRole.user: return 1;
    }
  }
}