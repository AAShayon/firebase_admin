import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_profile_notifier.dart';
import 'user_profile_state.dart';

final userProfileNotifierProvider =
StateNotifierProvider<UserProfileNotifier, UserProfileState>((ref) {
  return UserProfileNotifier(ref);
});