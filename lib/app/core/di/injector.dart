// lib/core/di/injector.dart
import 'package:dio/dio.dart';
import 'package:firebase_admin/app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:firebase_admin/app/features/auth/domain/repositories/auth_repository.dart';
import 'package:firebase_admin/app/features/auth/domain/usecases/admin_use_case.dart';
import 'package:firebase_admin/app/features/auth/domain/usecases/sign_in_with_email_passWord_useCase.dart';
import 'package:firebase_admin/app/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:firebase_admin/app/features/auth/domain/usecases/sign_out.dart';
import 'package:firebase_admin/app/features/auth/domain/usecases/update_password_use_case.dart';
import 'package:firebase_admin/app/features/dashboard/domain/usecases/create_public_notification_use_case.dart';
import 'package:firebase_admin/app/features/payment/domain/usecases/process_sslcommerz_payment_use_case.dart';
import 'package:firebase_admin/app/features/user_profile/domain/usecases/watch_user_profile_use_case.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/domain/usecases/get_current_user_use_case.dart';
import '../../features/auth/domain/usecases/save_admin_token_use_case.dart';
import '../../features/auth/domain/usecases/sign_up_with_email_password_use_case.dart';
import '../../features/auth/domain/usecases/sub_admin_use_case.dart';
import '../../features/cart/data/datasources/cart_remote_data_sources.dart';
import '../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../features/cart/domain/repositories/cart_repositories.dart';
import '../../features/cart/domain/usecases/add_to_cart_use_case.dart';
import '../../features/cart/domain/usecases/clear_cart_use_case.dart';
import '../../features/cart/domain/usecases/get_cart_items_use_case.dart';
import '../../features/cart/domain/usecases/remove_from_cart_use_cse.dart';
import '../../features/cart/domain/usecases/update_cart_item_use_case.dart';
import '../../features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/domain/usecases/get_dashboard_stats_use_case.dart';
import '../../features/dashboard/domain/usecases/get_recent_sales_use_case.dart';
import '../../features/image_gallery/data/datasources/image_gallery_remote_data_source.dart';
import '../../features/image_gallery/data/repositories/image_gallery_repository_impl.dart';
import '../../features/image_gallery/domain/repositories/image_gallery_repository.dart';
import '../../features/image_gallery/domain/usecase/add_image_url_use_case.dart';
import '../../features/image_gallery/domain/usecase/delete_image_use_case.dart';
import '../../features/image_gallery/domain/usecase/fetch_api_images_use_case.dart';
import '../../features/image_gallery/domain/usecase/get_gallery_images_use_case.dart';
import '../../features/notifications/data/datasources/notification_remote_data_source.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/domain/usecases/create_notification_use_case.dart';
import '../../features/notifications/domain/usecases/get_notifications_use_case.dart';
import '../../features/notifications/domain/usecases/get_public_notifications_use_case.dart';
import '../../features/notifications/domain/usecases/get_targeted_notifications_use_case.dart';
import '../../features/notifications/domain/usecases/get_user_private_notifications_use_case.dart';
import '../../features/notifications/domain/usecases/mark_as_read_use_case.dart';
import '../../features/notifications/domain/usecases/mark_notification_as_read_use_case.dart';
import '../../features/order/data/datasources/order_remote_data_source.dart';
import '../../features/order/data/repositories/order_repository_impl.dart';
import '../../features/order/domain/repositories/order_repository.dart';
import '../../features/order/domain/usecases/create_order_use_case.dart';
import '../../features/order/domain/usecases/get_all_orders_use_case.dart';
import '../../features/order/domain/usecases/get_last_order_id_use_case.dart';
import '../../features/order/domain/usecases/get_order_by_id_use_case.dart';
import '../../features/order/domain/usecases/get_user_orders_use_case.dart';
import '../../features/order/domain/usecases/update_order_status_use_case.dart';
import '../../features/order/domain/usecases/watch_order_by_id_use_case.dart';
import '../../features/payment/data/datasources/payment_remote_data_source.dart';
import '../../features/payment/data/repositories/payment_repository_impl.dart';
import '../../features/payment/domain/repositories/payment_repository.dart';
import '../../features/settings/data/datasources/settings_local_data_source.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/domain/usecases/get_settings.dart';
import '../../features/settings/domain/usecases/update_theme_mode.dart';
import '../../features/shared/data/datasources/product_remote_data_source.dart';
import '../../features/shared/data/repositories/product_repository_impl.dart';
import '../../features/shared/domain/repositories/product_repository.dart';
import '../../features/shared/domain/usecases/add_product_use_case.dart';
import '../../features/shared/domain/usecases/delete_product_use_case.dart';
import '../../features/shared/domain/usecases/get_products_usecase.dart';
import '../../features/shared/domain/usecases/search_product_use_case.dart';
import '../../features/shared/domain/usecases/update_product_use_case.dart';
import '../../features/user_profile/data/datasources/user_profile_remote_data_source.dart';
import '../../features/user_profile/data/repositories/user_profile_repository_impl.dart';
import '../../features/user_profile/domain/repositories/user_profile_repository.dart';
import '../../features/user_profile/domain/usecases/get_all_users_use_case.dart';
import '../../features/user_profile/domain/usecases/get_user_profile_usecase.dart';
import '../../features/user_profile/domain/usecases/manage_user_address_usecase.dart';
import '../../features/user_profile/domain/usecases/update_user_contact_use_case.dart';
import '../../features/user_profile/domain/usecases/update_user_profile_usecase.dart';
import '../../features/wishlist/data/datasources/wishlist_remote_data_source.dart';
import '../../features/wishlist/data/repositories/wishlist_repository_impl.dart';
import '../../features/wishlist/domain/repositories/wishlist_repository.dart';
import '../../features/wishlist/domain/usecase/add_to_wishlist_use_case.dart';
import '../../features/wishlist/domain/usecase/get_wishlist_ids_use_case.dart';
import '../../features/wishlist/domain/usecase/get_wishlist_items_use_case.dart';
import '../../features/wishlist/domain/usecase/remove_from_wishlist_use_case.dart';
import '../network/dio_factory.dart';
import '../network/firebase_provider.dart';

final locator = GetIt.instance;
GetStorage get appData => locator<GetStorage>();

Future<void> initDependencies() async {
  await GetStorage.init();
  locator.registerSingleton<GetStorage>(GetStorage());

  //hive for dio cache
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);


  // 2. Register factories for your API services.
  //    Each one gets the DioFactory and creates a Dio instance with a specific base URL.


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

  //dio
  locator.registerLazySingleton(() => DioFactory());
  locator.registerFactory<Dio>(
        () => locator<DioFactory>().create('https://picsum.photos'),
    instanceName: 'PicsumDio', // <-- We will use this name consistently.
  );
  // Network
  // locator.registerLazySingleton(() => ApiProvider());

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
  locator.registerLazySingleton<SaveAdminTokenUseCase>(()=>SaveAdminTokenUseCase(locator<AuthRepository>()));


  //userProfile
  locator.registerLazySingleton<UserProfileRemoteDataSource>(()=>UserProfileRemoteDataSourceImpl(firestore: FirebaseProvider.firestore));
  locator.registerLazySingleton<UserProfileRepository>(()=>UserProfileRepositoryImpl(remoteDataSource: locator<UserProfileRemoteDataSource>()));
  locator.registerLazySingleton<GetUserProfileUseCase>(()=>GetUserProfileUseCase(locator<UserProfileRepository>()));
  locator.registerLazySingleton<UpdateUserProfileUseCase>(()=>UpdateUserProfileUseCase(locator<UserProfileRepository>()));
  locator.registerLazySingleton<ManageUserAddressUseCase>(()=>ManageUserAddressUseCase(locator<UserProfileRepository>()));
  locator.registerLazySingleton<UpdateUserContactNoUseCase>(()=>UpdateUserContactNoUseCase(locator<UserProfileRepository>()));
  locator.registerLazySingleton<WatchUserProfileUseCase>(()=>WatchUserProfileUseCase(locator<UserProfileRepository>()));
  locator.registerLazySingleton<GetAllUsersUseCase>(()=>GetAllUsersUseCase(locator<UserProfileRepository>()));



  //Product
  locator.registerLazySingleton<ProductRemoteDataSource>(()=>ProductRemoteDataSourceImpl(firestore: FirebaseProvider.firestore, storage:FirebaseProvider.storage));
  locator.registerLazySingleton<ProductRepository>(()=>ProductRepositoryImpl(remoteDataSource: locator<ProductRemoteDataSource>()));
  locator.registerLazySingleton<AddProductUseCase>(()=>AddProductUseCase(locator<ProductRepository>()));
  locator.registerLazySingleton<GetProductUseCase>(()=>GetProductUseCase(locator<ProductRepository>()));
  locator.registerLazySingleton<UpdateProductUseCase>(()=>UpdateProductUseCase(locator<ProductRepository>()));
  locator.registerLazySingleton<DeleteProductUseCase>(()=>DeleteProductUseCase(locator<ProductRepository>()));
  locator.registerLazySingleton<SearchProductUseCase>(()=>SearchProductUseCase(locator<ProductRepository>()));

  //cart
  locator.registerLazySingleton<CartRemoteDataSource>(()=>CartRemoteDataSourceImpl(firestore: FirebaseProvider.firestore));
  locator.registerLazySingleton<CartRepository>(()=>CartRepositoryImpl(remoteDataSource: locator<CartRemoteDataSource>()));
  locator.registerLazySingleton<AddToCartUseCase>(()=>AddToCartUseCase(locator<CartRepository>()));
  locator.registerLazySingleton<GetCartItemsUseCase>(()=>GetCartItemsUseCase(locator<CartRepository>()));
  locator.registerLazySingleton<UpdateCartItemQuantityUseCase>(()=>UpdateCartItemQuantityUseCase(locator<CartRepository>()));
  locator.registerLazySingleton<RemoveFromCartUseCase>(()=>RemoveFromCartUseCase(locator<CartRepository>()));
  locator.registerLazySingleton<ClearCartUseCase>(()=>ClearCartUseCase(locator<CartRepository>()));

  //wishlist
  locator.registerLazySingleton<WishlistRemoteDataSource>(() => WishlistRemoteDataSourceImpl(firestore: FirebaseProvider.firestore));
  locator.registerLazySingleton<WishlistRepository>(() => WishlistRepositoryImpl(remoteDataSource: locator<WishlistRemoteDataSource>(),));
  locator.registerLazySingleton<GetWishlistItemsUseCase>(() => GetWishlistItemsUseCase(locator<WishlistRepository>()));
  locator.registerLazySingleton<GetWishlistIdsUseCase>(() => GetWishlistIdsUseCase(locator<WishlistRepository>()));
  locator.registerLazySingleton<AddToWishlistUseCase>(() => AddToWishlistUseCase(locator<WishlistRepository>()));
  locator.registerLazySingleton<RemoveFromWishlistUseCase>(() => RemoveFromWishlistUseCase(locator<WishlistRepository>()));

  //payment

  locator.registerLazySingleton<PaymentRemoteDataSource>(()=>PaymentRemoteDataSourceImpl());
  locator.registerLazySingleton<PaymentRepository>(()=>PaymentRepositoryImpl(remoteDataSource: locator<PaymentRemoteDataSource>()));
  locator.registerLazySingleton<ProcessSslCommerzPaymentUseCase>(()=>ProcessSslCommerzPaymentUseCase(locator<PaymentRepository>()));

  //orders
  locator.registerLazySingleton<OrderRemoteDataSource>(()=>OrderRemoteDataSourceImpl(firestore: FirebaseProvider.firestore));
  locator.registerLazySingleton<OrderRepository>(()=>OrderRepositoryImpl(remoteDataSource: locator<OrderRemoteDataSource>()));
  locator.registerLazySingleton<CreateOrderUseCase>(()=>CreateOrderUseCase(locator<OrderRepository>()));
  locator.registerLazySingleton<GetUserOrdersUseCase>(()=>GetUserOrdersUseCase(locator<OrderRepository>()));
  locator.registerLazySingleton<GetAllOrdersUseCase>(()=>GetAllOrdersUseCase(locator<OrderRepository>()));
  locator.registerLazySingleton<UpdateOrderStatusUseCase>(()=>UpdateOrderStatusUseCase(locator<OrderRepository>()));
  locator.registerLazySingleton<GetOrderByIdUseCase>(()=>GetOrderByIdUseCase(locator<OrderRepository>()));
  locator.registerLazySingleton<WatchOrderByIdUseCase>(() => WatchOrderByIdUseCase(locator<OrderRepository>()));
  locator.registerLazySingleton<GetLastOrderIdUseCase>(() => GetLastOrderIdUseCase(locator<OrderRepository>()));

  // Notifications
  locator.registerLazySingleton<NotificationRemoteDataSource>(() => NotificationRemoteDataSourceImpl(firestore: FirebaseProvider.firestore));
  locator.registerLazySingleton<NotificationRepository>(() => NotificationRepositoryImpl(remoteDataSource: locator<NotificationRemoteDataSource>()));
  locator.registerLazySingleton<GetNotificationsUseCase>(() => GetNotificationsUseCase(locator<NotificationRepository>()));
  locator.registerLazySingleton<MarkAsReadUseCase>(() => MarkAsReadUseCase(locator<NotificationRepository>()));
  locator.registerLazySingleton<CreateNotificationUseCase>(() => CreateNotificationUseCase(locator<NotificationRepository>()));
  locator.registerLazySingleton<GetPublicNotificationsUseCase>(() => GetPublicNotificationsUseCase(locator<NotificationRepository>()));
  locator.registerLazySingleton<GetTargetedNotificationsUseCase>(() => GetTargetedNotificationsUseCase(locator<NotificationRepository>()));
  locator.registerLazySingleton<GetUserPrivateNotificationsUseCase>(() => GetUserPrivateNotificationsUseCase(locator<NotificationRepository>()));
  locator.registerLazySingleton<MarkNotificationAsReadUseCase>(() => MarkNotificationAsReadUseCase(locator<NotificationRepository>()));



  // Dashboard

  locator.registerLazySingleton<DashboardRemoteDataSource>(() => DashboardRemoteDataSourceImpl(firestore: FirebaseProvider.firestore));
  locator.registerLazySingleton<DashboardRepository>(() => DashboardRepositoryImpl(remoteDataSource: locator<DashboardRemoteDataSource>()));
  locator.registerLazySingleton<GetDashboardStatsUseCase>(() => GetDashboardStatsUseCase(locator<DashboardRepository>()));
  locator.registerLazySingleton<SendPromotionUseCase>(() => SendPromotionUseCase(locator<DashboardRepository>()));
  locator.registerLazySingleton<GetRecentSalesUseCase>(() => GetRecentSalesUseCase(locator<DashboardRepository>()));

  // --- ADD THIS NEW BLOCK FOR IMAGE GALLERY ---
  locator.registerLazySingleton<ImageGalleryRemoteDataSource>(() => ImageGalleryRemoteDataSourceImpl(firestore: FirebaseProvider.firestore, dio: locator<Dio>(instanceName: 'PicsumDio'),));
  locator.registerLazySingleton<ImageGalleryRepository>(() => ImageGalleryRepositoryImpl(remoteDataSource: locator<ImageGalleryRemoteDataSource>()));
  locator.registerLazySingleton<GetGalleryImagesUseCase>(() => GetGalleryImagesUseCase(locator<ImageGalleryRepository>()));
  locator.registerLazySingleton<AddImageUrlUseCase>(() => AddImageUrlUseCase(locator<ImageGalleryRepository>()));
  locator.registerLazySingleton<DeleteImageUrlUseCase>(() => DeleteImageUrlUseCase(locator<ImageGalleryRepository>()));
  locator.registerLazySingleton<FetchApiImagesUseCase>(() => FetchApiImagesUseCase(locator<ImageGalleryRepository>()));
}
