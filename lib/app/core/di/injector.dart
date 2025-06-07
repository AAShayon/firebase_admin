// lib/core/di/injector.dart
import 'package:firebase_admin/app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:firebase_admin/app/features/auth/domain/repositories/auth_repository.dart';
import 'package:firebase_admin/app/features/auth/domain/usecases/admin_use_case.dart';
import 'package:firebase_admin/app/features/auth/domain/usecases/sign_in_with_email_passWord_useCase.dart';
import 'package:firebase_admin/app/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:firebase_admin/app/features/auth/domain/usecases/sign_out.dart';
import 'package:firebase_admin/app/features/auth/domain/usecases/update_password_use_case.dart';
import 'package:firebase_admin/app/features/products/data/datasources/product_remote_data_source.dart';
import 'package:firebase_admin/app/features/products/domain/repositories/product_repository.dart';
import 'package:firebase_admin/app/features/products/domain/usecases/add_product_use_case.dart';
import 'package:firebase_admin/app/features/products/domain/usecases/get_products_usecase.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/domain/usecases/get_current_user_use_case.dart';
import '../../features/auth/domain/usecases/sign_up_with_email_password_use_case.dart';
import '../../features/auth/domain/usecases/sub_admin_use_case.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/settings/data/datasources/settings_local_data_source.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/domain/usecases/get_settings.dart';
import '../../features/settings/domain/usecases/update_theme_mode.dart';
import '../../features/user_profile/data/datasources/user_profile_remote_data_source.dart';
import '../../features/user_profile/data/repositories/user_profile_repository_impl.dart';
import '../../features/user_profile/domain/repositories/user_profile_repository.dart';
import '../../features/user_profile/domain/usecases/get_user_profile_usecase.dart';
import '../../features/user_profile/domain/usecases/manage_user_address_usecase.dart';
import '../../features/user_profile/domain/usecases/update_user_contact_use_case.dart';
import '../../features/user_profile/domain/usecases/update_user_profile_usecase.dart';
import '../network/api_provider.dart';
import '../network/firebase_provider.dart';

final locator = GetIt.instance;
GetStorage get appData => locator<GetStorage>();

Future<void> initDependencies() async {
  await GetStorage.init();
  locator.registerSingleton<GetStorage>(GetStorage());
  //theme
  locator.registerLazySingleton<SettingsLocalDataSource>(
          () => SettingsLocalDataSourceImpl(locator<GetStorage>()));
  locator.registerLazySingleton<SettingsRepository>(
          () => SettingsRepositoryImpl(locator<SettingsLocalDataSource>()));
  locator.registerLazySingleton(() => GetSettings(locator<SettingsRepository>()));
  locator.registerLazySingleton(() => UpdateThemeMode(locator<SettingsRepository>()));

  // Firebase
  await FirebaseProvider.initialize();
  locator.registerLazySingleton(() => FirebaseProvider());

  // Network
  locator.registerLazySingleton(() => ApiProvider());

  // Auth
  locator.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(auth: FirebaseProvider.auth, googleSignIn: FirebaseProvider.googleSignIn, firestore: FirebaseProvider.firestore),);
  locator.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: locator<AuthRemoteDataSource>()),);
  locator.registerLazySingleton<SignInWithEmailAndPassword>(()=>SignInWithEmailAndPassword(locator<AuthRepository>()));
  locator.registerLazySingleton<SignInWithGoogle>(()=>SignInWithGoogle(locator<AuthRepository>()));
  locator.registerLazySingleton<SignOut>(()=>SignOut(locator<AuthRepository>()));
  locator.registerLazySingleton<IsAdmin>(()=>IsAdmin(locator<AuthRepository>()));
  locator.registerLazySingleton<SignUpWithEmailPasswordUseCase>(()=>SignUpWithEmailPasswordUseCase(locator<AuthRepository>()));
  locator.registerLazySingleton<UpdatePasswordUseCase>(()=>UpdatePasswordUseCase(locator<AuthRepository>()));
  locator.registerLazySingleton<IsSubAdminUseCase>(()=>IsSubAdminUseCase(locator<AuthRepository>()));
  locator.registerLazySingleton<CurrentUserUseCase>(()=>CurrentUserUseCase(locator<AuthRepository>()));
  //userProfile
  locator.registerLazySingleton<UserProfileRemoteDataSource>(()=>UserProfileRemoteDataSourceImpl(firestore: FirebaseProvider.firestore));
  locator.registerLazySingleton<UserProfileRepository>(()=>UserProfileRepositoryImpl(remoteDataSource: locator<UserProfileRemoteDataSource>()));
  locator.registerLazySingleton<GetUserProfileUseCase>(()=>GetUserProfileUseCase(locator<UserProfileRepository>()));
  locator.registerLazySingleton<UpdateUserProfileUseCase>(()=>UpdateUserProfileUseCase(locator<UserProfileRepository>()));
  locator.registerLazySingleton<ManageUserAddressUseCase>(()=>ManageUserAddressUseCase(locator<UserProfileRepository>()));
  locator.registerLazySingleton<UpdateUserContactNoUseCase>(()=>UpdateUserContactNoUseCase(locator<UserProfileRepository>()));



  //Product
  locator.registerLazySingleton<ProductRemoteDataSource>(()=>ProductRemoteDataSourceImpl(firestore: FirebaseProvider.firestore, storage:FirebaseProvider.storage));
  locator.registerLazySingleton<ProductRepository>(()=>ProductRepositoryImpl(remoteDataSource: locator<ProductRemoteDataSource>()));
  locator.registerLazySingleton<AddProductUseCase>(()=>AddProductUseCase(locator<ProductRepository>()));
  locator.registerLazySingleton<GetProductUseCase>(()=>GetProductUseCase(locator<ProductRepository>()));
}
