import 'package:firebase_admin/app/features/auth/domain/repositories/auth_repository.dart';

import '../entities/user_entity.dart';

class CurrentUserUseCase{
  final AuthRepository repository;
  CurrentUserUseCase(this.repository);
  Future<UserEntity> call() => repository.getCurrentUser();
}