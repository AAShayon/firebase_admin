import '../repositories/user_profile_repository.dart';

class UpdateUserContactNoUseCase {
  final UserProfileRepository repository;
  UpdateUserContactNoUseCase(this.repository);
  Future<void> call(String userId, String addressId,  String contactNo) async {
    return await repository.updateContactNo(userId,addressId, contactNo);
  }
}