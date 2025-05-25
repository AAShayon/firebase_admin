import '../../domain/entities/user_entity.dart';

class UserModel {
  final String id;
  final bool isAdmin;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  // final bool isSubAdmin;

  UserModel( {required this.id, required this.isAdmin,this.email, this.displayName, this.photoUrl,
    // required this.isSubAdmin,
  });

  UserEntity toEntity() => UserEntity(id: id, isAdmin: isAdmin,displayName: displayName,email: email,
      // isSubAdmin: isSubAdmin,
      photoUrl: photoUrl);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      isAdmin: json['isAdmin'] ?? false,
      // isSubAdmin: json['isSubAdmin'] ?? false,
      photoUrl: json['photoUrl'] ?? '',
      displayName: json['displayName'] ?? '',
      email: json['email'] ,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isAdmin': isAdmin,
    };
  }
}
