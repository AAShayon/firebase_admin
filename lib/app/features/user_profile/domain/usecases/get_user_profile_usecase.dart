import '../repositories/user_profile_repository.dart';
import '../entities/user_profile_entity.dart';

class GetUserProfileUseCase {
  final UserProfileRepository repository;

  GetUserProfileUseCase(this.repository);

  Future<UserProfileEntity> call(String userId) async {
    return await repository.getUserProfile(userId);
  }
}
