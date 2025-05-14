// lib/core/di/injector.dart
import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/products/data/datasources/product_remote_data_source.dart';
import '../../features/stores/data/datasources/store_remote_data_source.dart';
import '../network/api_provider.dart';
import '../network/firebase_provider.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  // Firebase
  await FirebaseProvider.initialize();

  // Network
  getIt.registerLazySingleton(() => ApiProvider());

  // Auth
  getIt.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(),
  );

  // Products
  getIt.registerLazySingleton<ProductRemoteDataSource>(
        () => ProductRemoteDataSourceImpl(),
  );

  // Stores
  getIt.registerLazySingleton<StoreRemoteDataSource>(
        () => StoreRemoteDataSourceImpl(),
  );

  // Register repositories, use cases as needed
}