import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user_profile_entity.dart';

part 'user_profile_state.freezed.dart';

@freezed
class UserProfileState with _$UserProfileState {
  const factory UserProfileState.initial() = _Initial;
  const factory UserProfileState.loading() = _Loading;
  const factory UserProfileState.loaded(UserProfileEntity user) = _Loaded;
  const factory UserProfileState.error(String message) = _Error;
  const factory UserProfileState.addressUpdated() = _AddressUpdated;
  const factory UserProfileState.contactUpdated() = _ContactUpdated;
}