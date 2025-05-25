import 'package:firebase_admin/app/features/auth/presentation/providers/auth_state_extension.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/firebase_provider.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_notifier_provider.dart';

final splashProvider = FutureProvider<UserEntity?>((ref) async {
  // ✅ Only read — no state changes here
  final authState = ref.watch(authNotifierProvider);

  // Wait for auth state to be ready if it's still loading
  if (authState.isLoading) {
    await Future.delayed(const Duration(seconds: 2)); // optional delay
  }

  return authState.maybeMap(
    authenticated: (state) => state.user,
    orElse: () => null,
  );
});