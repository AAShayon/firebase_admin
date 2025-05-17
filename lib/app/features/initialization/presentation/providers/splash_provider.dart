import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/firebase_provider.dart';

final splashProvider = FutureProvider<User?>((ref) async {
  await Future.delayed(const Duration(seconds: 3));
  final user = FirebaseProvider.auth.currentUser;
  return user;
});
