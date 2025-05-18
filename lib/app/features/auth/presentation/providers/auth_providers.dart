import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injector.dart';
import '../../domain/usecases/admin_useCase.dart';
import '../../domain/usecases/sign_in_with_email_passWord_useCase.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up_with_email_password_use_case.dart';
import '../../domain/usecases/update_password_use_case.dart';

final signInWithEmailProvider = Provider<SignInWithEmailAndPassword>((ref) {
  return locator<SignInWithEmailAndPassword>();
});

final signUpWithEmailPasswordProvider =
    Provider<SignUpWithEmailPasswordUseCase>((ref) {
      return locator<SignUpWithEmailPasswordUseCase>();
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
final updatePasswordProvider = Provider<UpdatePasswordUseCase>((ref) {
  return locator<UpdatePasswordUseCase>();
});
