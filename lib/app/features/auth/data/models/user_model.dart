import '../../domain/entities/user_entity.dart';

class UserModel {
  final String id;
  final bool isAdmin;
  final bool isSubAdmin;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  UserModel({
    required this.id,
    required this.isAdmin,
    required this.isSubAdmin,
    this.email,
    this.displayName,
    this.photoUrl,
  });

  UserEntity toEntity() => UserEntity(
    id: id,
    isAdmin: isAdmin,
    isSubAdmin: isSubAdmin,
    displayName: displayName,
    email: email,
    photoUrl: photoUrl,
  );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      isAdmin: json['isAdmin'] ?? false,
      isSubAdmin: json['isSubAdmin'] ?? false,
      photoUrl: json['photoUrl'] ?? '',
      displayName: json['displayName'] ?? '',
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isAdmin': isAdmin,
      'isSubAdmin': isSubAdmin,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
    };
  }
}