import '../repositories/user_profile_repository.dart';
import '../entities/user_profile_entity.dart';

class UpdateUserProfileUseCase {
  final UserProfileRepository repository;

  UpdateUserProfileUseCase(this.repository);

  Future<void> call(UserProfileEntity user) async {
    return await repository.updateUserProfile(user);
  }
}