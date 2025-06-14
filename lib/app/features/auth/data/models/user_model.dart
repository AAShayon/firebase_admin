// lib/app/features/auth/data/models/user_model.dart

import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.id,
    required super.isAdmin,
    required super.isSubAdmin,
    super.email,
    super.displayName,
    super.photoUrl,
  });

  // This factory is the key. It takes the map from Firestore and builds our object.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      displayName: json['displayName'],
      photoUrl: json['photoUrl'],
      // Safely parse the boolean fields. Default to `false` if they don't exist.
      isAdmin: json['isAdmin'] ?? false,
      isSubAdmin: json['isSubAdmin'] ?? false,
    );
  }

  // Helper method to convert the model back to an entity for the repository.
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      isAdmin: isAdmin,
      isSubAdmin: isSubAdmin,
    );
  }
}