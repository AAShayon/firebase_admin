// lib/app/features/auth/domain/entities/user_entity.dart

// This is the pure Dart object that represents our user in the app's state.
// It includes all the necessary information for authentication and authorization.
class UserEntity {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool isAdmin;
  final bool isSubAdmin;

  UserEntity({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    required this.isAdmin,
    required this.isSubAdmin,
  });

  // A copyWith method is useful for updating the state immutably.
  // This will fix the error you had in your AuthNotifier.
  UserEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? isAdmin,
    bool? isSubAdmin,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isAdmin: isAdmin ?? this.isAdmin,
      isSubAdmin: isSubAdmin ?? this.isSubAdmin,
    );
  }
}