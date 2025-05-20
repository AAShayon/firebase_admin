// lib/core/di/injector.dart
import 'package:firebase_admin/app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:firebase_admin/app/features/auth/domain/repositories/auth_repository.dart';
import 'package:firebase_admin/app/features/auth/domain/usecases/admin_use_case.dart';
import 'package:firebase_admin/app/features/auth/domain/usecases/sign_in_with_email_passWord_useCase.dart';
import 'package:firebase_admin/app/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:firebase_admin/app/features/auth/domain/usecases/sign_out.dart';
import 'package:firebase_admin/app/features/auth/domain/usecases/update_password_use_case.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';

import '../../features/admin/data/datasources/admin_remote_data_source.dart';
import '../../features/admin/data/repositories/admin_repository_impl.dart';
import '../../features/admin/domain/usecases/get_users_usecase.dart';
import '../../features/admin/domain/usecases/update_user_role_usecase.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/admin/domain/repositories/admin_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_use_case.dart';
import '../../features/auth/domain/usecases/sign_up_with_email_password_use_case.dart';
import '../../features/auth/domain/usecases/sub_admin_use_case.dart';
import '../../features/settings/data/datasources/settings_local_data_source.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/domain/usecases/get_settings.dart';
import '../../features/settings/domain/usecases/update_theme_mode.dart';
import '../network/api_provider.dart';
import '../network/firebase_provider.dart';

final locator = GetIt.instance;

GetStorage get appData => locator<GetStorage>();

Future<void> initDependencies() async {
  await GetStorage.init();
  locator.registerSingleton<GetStorage>(GetStorage());
  //theme
  locator.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSourceImpl(locator<GetStorage>()),
  );
  locator.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(locator<SettingsLocalDataSource>()),
  );
  locator.registerLazySingleton(
    () => GetSettings(locator<SettingsRepository>()),
  );
  locator.registerLazySingleton(
    () => UpdateThemeMode(locator<SettingsRepository>()),
  );

  // Firebase
  await FirebaseProvider.initialize();
  locator.registerLazySingleton(() => FirebaseProvider());

  // Network
  locator.registerLazySingleton(() => ApiProvider());

  // Auth
  locator.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      auth: FirebaseProvider.auth,
      googleSignIn: FirebaseProvider.googleSignIn,
      firestore: FirebaseProvider.firestore,
    ),
  );
  locator.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: locator<AuthRemoteDataSource>()),
  );
  locator.registerLazySingleton<SignInWithEmailAndPassword>(
    () => SignInWithEmailAndPassword(locator<AuthRepository>()),
  );
  locator.registerLazySingleton<SignInWithGoogle>(
    () => SignInWithGoogle(locator<AuthRepository>()),
  );
  locator.registerLazySingleton<SignOut>(
    () => SignOut(locator<AuthRepository>()),
  );
  // locator.registerLazySingleton<IsAdmin>(
  //   () => IsAdmin(locator<AuthRepository>()),
  // );
  locator.registerLazySingleton<SignUpWithEmailPasswordUseCase>(
    () => SignUpWithEmailPasswordUseCase(locator<AuthRepository>()),
  );
  locator.registerLazySingleton<UpdatePasswordUseCase>(
    () => UpdatePasswordUseCase(locator<AuthRepository>()),
  );
  // locator.registerLazySingleton<IsSubAdminUseCase>(
  //   () => IsSubAdminUseCase(locator<AuthRepository>()),
  // );
  locator.registerLazySingleton<CurrentUserUseCase>(
    () => CurrentUserUseCase(locator<AuthRepository>()),
  );
  //Admin
  locator.registerLazySingleton<AdminRemoteDataSource>(
    () => AdminRemoteDataSourceImpl(
      firestore: FirebaseProvider.firestore,
      auth: FirebaseProvider.auth,
    ),
  );

  locator.registerLazySingleton<AdminRepository>(
    () =>
        AdminRepositoryImpl(remoteDataSource: locator<AdminRemoteDataSource>()),
  );

  locator.registerLazySingleton(
    () => GetUsersUseCase(locator<AdminRepository>()),
  );
  locator.registerLazySingleton(
    () => UpdateUserRoleUseCase(locator<AdminRepository>()),
  );
}
