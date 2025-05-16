import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injector.dart';
import '../../domain/usecases/admin_useCase.dart';
import '../../domain/usecases/sign_in_with_email_passWord_useCase.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';

final signInWithEmailProvider = Provider<SignInWithEmailAndPassword>((ref) {
  return locator<SignInWithEmailAndPassword>();
});

final signInWithGoogleProvider = Provider<SignInWithGoogle>((ref) {
  return locator<SignInWithGoogle>();
});

final signOutProvider = Provider<SignOut>((ref) {
  return locator<SignOut>();
});

final isAdminProvider = Provider<IsAdmin>((ref) {
  return locator<IsAdmin>();
});