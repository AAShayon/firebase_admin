// lib/features/admin/presentation/providers/admin_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../auth/domain/entities/user_entity.dart';


part 'admin_state.freezed.dart';

@freezed
class AdminState with _$AdminState {
  const factory AdminState.initial() = Initial;
  const factory AdminState.loading() = Loading;
  const factory AdminState.loaded(List<UserEntity> users) = Loaded;
  const factory AdminState.error(String message) = Error;
  const factory AdminState.roleUpdated(UserEntity user) = RoleUpdated;
}