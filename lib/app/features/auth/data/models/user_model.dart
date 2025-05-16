import '../../domain/entities/user_entity.dart';

class UserModel {
  final String id;
  final bool isAdmin;

  UserModel({required this.id, required this.isAdmin});

  UserEntity toEntity() => UserEntity(id: id, isAdmin: isAdmin);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      isAdmin: json['isAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isAdmin': isAdmin,
    };
  }
}
