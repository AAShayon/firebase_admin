import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = Initial;

  const factory AuthState.authenticated(UserEntity user) = Authenticated;

  const factory AuthState.unauthenticated() = Unauthenticated;

  const factory AuthState.loading() = Loading;

  const factory AuthState.error(String message) = Error;
}