import '../entities/user_profile_entity.dart';
import '../repositories/user_profile_repository.dart';

class WatchUserProfileUseCase {
  final UserProfileRepository repository;
  WatchUserProfileUseCase(this.repository);
  Stream<UserProfileEntity> call(String userId) {
    return repository.watchUserProfile(userId);
  }
}