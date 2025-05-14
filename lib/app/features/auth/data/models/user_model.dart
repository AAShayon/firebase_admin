import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({required super.id, required super.isAdmin});

  factory UserModel.fromFirebase(User user) {
    return UserModel(id: user.uid, isAdmin: false);
  }
}
