import 'package:firebase_admin/app/features/auth/domain/entities/user_entity.dart';

import '../repositories/auth_repository.dart';

class SignInWithEmailAndPassword {
  final AuthRepository repository;

  SignInWithEmailAndPassword(this.repository);

  Future<UserEntity> call(String email, String password) {
    return repository.signInWithEmailAndPassword(email, password);
  }
}
