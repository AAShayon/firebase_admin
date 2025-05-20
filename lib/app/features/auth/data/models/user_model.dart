
import '../../domain/entities/user_entity.dart';

import '../../domain/entities/user_roles.dart';

class UserModel {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final UserRole role;

  UserModel({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    required this.role,
  });

  UserEntity toEntity() => UserEntity(
    id: id,
    email: email,
    displayName: displayName,
    photoUrl: photoUrl,
    role: role,
  );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      displayName: json['displayName'],
      photoUrl: json['photoUrl'],
      role: UserRole.values.firstWhere(
            (e) => e.toString() == 'UserRole.${json['role']}',
        orElse: () => UserRole.user,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': role.toString().split('.').last,
    };
  }
}