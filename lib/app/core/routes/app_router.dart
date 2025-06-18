import 'package:firebase_admin/app/config/widgets/loading_screen.dart';
import 'package:firebase_admin/app/features/customer/presentation/customers_page.dart';
import 'package:firebase_admin/app/features/notifications/presentation/notifications_page.dart';
import 'package:firebase_admin/app/features/order/presentation/pages/orders_page.dart';
import 'package:firebase_admin/app/features/products/presentation/pages/add_product_page.dart';
import 'package:firebase_admin/app/features/settings/presentation/pages/settings_page.dart';
import 'package:firebase_admin/app/features/user_profile/presentation/pages/edit_profile_page.dart';
import 'package:firebase_admin/app/features/user_profile/presentation/pages/user_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/registration_page.dart';
import '../../features/auth/presentation/providers/auth_notifier_provider.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/checkout/presentation/pages/checkout_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/home_page/presentation/pages/home_page.dart';
import '../../features/image_gallery/presentation/pages/image_gallery_page.dart';
import '../../features/initialization/presentation/pages/splash_screen.dart';
import '../../features/landing/presentation/landing.dart';
import '../../features/order/presentation/pages/order_details_page.dart';
import '../../features/order/presentation/pages/order_success_page.dart';
import '../../features/products/presentation/pages/product_detail_page.dart';
import '../../features/products/presentation/pages/product_table.dart';
import '../../features/promotions/domain/entities/promotion_entity.dart';
import '../../features/promotions/presentation/pages/create_promotion_page.dart';
import '../../features/promotions/presentation/pages/promotions_management_page.dart';
import '../../features/shared/domain/entities/product_entity.dart';
import '../../features/user_profile/domain/entities/user_profile_entity.dart';
import '../../features/user_profile/presentation/pages/add_edit_address.dart';
import '../../features/user_profile/presentation/providers/user_profile_notifier_provider.dart';
import '../../features/wishlist/presentation/pages/wishlist_page.dart';
import 'app_transitions.dart';

class AppRoutes {
  // --- Route Names (for type-safe navigation) ---
  static const splash = 'splash';
  static const loading = 'loading';
  static const login = 'login';
  static const register = 'register';
  static const landing = 'landing';
  static const dashboard = 'dashboard';
  static const home = 'homePage';
  static const product = 'product';
  static const addProduct = 'addProduct';
  static const order = 'order';
  static const orderSuccess = 'orderSuccess';
  static const orderDetails = 'orderDetails';
  static const addGalleryImage="addGalleryImage";

  static const customer = 'customer';
  static const notifications = 'notifications';
  static const settings = 'settings';
  static const profile = 'profile';
  static const editProfile = 'editProfile';
  static const productDetail = 'productDetail';
  static const cart = 'cart';
  static const addAddress = 'addAddress';
  static const editAddress = 'editAddress';
  static const checkout = 'checkout';
  static const wishlist = 'wishlist';
  static const managePromotions = 'managePromotions';
  static const createPromotion = 'createPromotion';



  // --- Route Paths ---
  // Top-level paths
  static const splashPath = '/splash';
  static const loadingPath = '/loading';
  static const loginPath = '/login';
  static const registerPath = '/register';
  static const landingPath = '/landing';
  static const dashboardPath = '/dashboard';
  static const homePath = '/homePage';
  static const productPath = '/product';
  static const addProductPath = '/addProduct';
  static const orderPath = '/order';
  static const customerPath = '/customer';
  static const notificationsPath = '/notifications';
  static const settingsPath = '/settings';
  static const profilePath = '/profile';
  static const productDetailPath = '/product-detail';
  static const cartPath = '/cart';
  static const checkoutPath = '/checkoutPath';
  static const addGalleryImagePath = '/addGalleryImagePath';
  static const orderSuccessPath = '/order-success/:orderId';
  static const orderDetailsPath = '/order-details/:orderId';


  // CORRECTED: Define nested paths clearly and uniquely to avoid conflicts.
  // These are relative paths used within a GoRoute's `routes` list.
  static const editProfilePath = 'details/edit'; // Full path will be: /profile/details/edit
  static const addAddressPath = 'address/add'; // Full path will be: /profile/address/add
  static const editAddressPath = 'address/edit/:addressId'; // Full path: /profile/address/edit/some-id
  static const wishlistPath = '/wishlist';
  static const managePromotionsPath = '/manage-promotions';
  static const createPromotionPath = '/create-promotion';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splashPath,
  routes: [
    // --- Top-level Redirector ---
    GoRoute(
      path: '/',
      redirect: (context, state) {
        final authState = ProviderScope.containerOf(context).read(authNotifierProvider);
        return authState.maybeMap(
          authenticated: (_) => AppRoutes.homePath,
          orElse: () => AppRoutes.loginPath,
        );
      },
    ),

    // --- Standard App Routes ---
    GoRoute(
      name: AppRoutes.splash,
      path: AppRoutes.splashPath,
      pageBuilder: (context, state) => buildPageRoute(
        context: context,
        state: state,
        child: const SplashScreen(),
        transitionType: AppRouteTransitionType.fade,
      ),
    ),
    GoRoute(
      name: AppRoutes.loading,
      path: AppRoutes.loadingPath,
      pageBuilder: (context, state) => buildPageRoute(
        context: context,
        state: state,
        child: const CustomLoadingScreen(),
        transitionType: AppRouteTransitionType.fade,
      ),
    ),
    GoRoute(
      name: AppRoutes.landing,
      path: AppRoutes.landingPath,
      pageBuilder: (context, state) {
        // 1. Safely access the extra data
        final extra = state.extra as Map<String, dynamic>?;

        // 2. Extract the index, defaulting to 0 if it's not present
        final index = extra?['index'] as int? ?? 0;

        return buildPageRoute(
          context: context,
          state: state,
          // 3. Pass the extracted index to the LandingPage constructor
          child: LandingPage(initialIndex: index),
          transitionType: AppRouteTransitionType.fade,
        );
      },
    ),

    GoRoute(
      name: AppRoutes.login,
      path: AppRoutes.loginPath,
      pageBuilder: (context, state) => buildPageRoute(
        context: context,
        state: state,
        child: const LoginPage(),
        transitionType: AppRouteTransitionType.slideFromRight,
      ),
    ),
    GoRoute(
      name: AppRoutes.register,
      path: AppRoutes.registerPath,
      pageBuilder: (context, state) => buildPageRoute(
        context: context,
        state: state,
        child: const RegistrationPage(),
        transitionType: AppRouteTransitionType.slideFromLeft,
      ),
    ),
    GoRoute(
      name: AppRoutes.dashboard,
      path: AppRoutes.dashboardPath,
      pageBuilder: (context, state) => buildPageRoute(
        context: context,
        state: state,
        child: const DashboardPage(),
        transitionType: AppRouteTransitionType.scale,
      ),
    ),
    GoRoute(
      name: AppRoutes.home,
      path: AppRoutes.homePath,
      pageBuilder: (context, state) => buildPageRoute(
        context: context,
        state: state,
        child: const HomePage(),
        transitionType: AppRouteTransitionType.scale,
      ),
    ),
    GoRoute(
      name: AppRoutes.product,
      path: AppRoutes.productPath,
      pageBuilder: (context, state) => buildPageRoute(
        context: context,
        state: state,
        child: const ProductsTable(),
        transitionType: AppRouteTransitionType.scale,
      ),
    ),
    GoRoute(
      name: AppRoutes.addGalleryImage,
      path: AppRoutes.addGalleryImagePath,
      pageBuilder: (context, state) => buildPageRoute(
        context: context,
        state: state,
        child:  ImageGalleryPage(),
        transitionType: AppRouteTransitionType.scale,
      ),
    ),
    GoRoute(
      name: AppRoutes.addProduct,
      path: AppRoutes.addProductPath,
      pageBuilder: (context, state) {
        final product = state.extra as ProductEntity?;
        return buildPageRoute(
          context: context,
          state: state,
          child: AddProductPage(productToEdit: product),
          transitionType: AppRouteTransitionType.slideFromRight,
        );
      },
    ),
    GoRoute(
      name: AppRoutes.productDetail,
      path: AppRoutes.productDetailPath,
      pageBuilder: (context, state) {
        final product = state.extra as ProductEntity;
        return buildPageRoute(
          context: context,
          state: state,
          child: ProductDetailPage(product: product),
          transitionType: AppRouteTransitionType.slideFromLeft,
        );
      },
    ),

    // --- User Profile Route and its Nested Routes ---
    GoRoute(
      name: AppRoutes.profile,
      path: AppRoutes.profilePath,
      pageBuilder: (context, state) {
        final authState = ProviderScope.containerOf(context).read(authNotifierProvider);
        final userId = authState.maybeWhen(authenticated: (user) => user.id, orElse: () => '');
        if (userId.isEmpty) return buildPageRoute(context: context, state: state, child: const CustomLoadingScreen(),  transitionType: AppRouteTransitionType.scale);
        return buildPageRoute(
          context: context,
          state: state,
          child: UserProfilePage(userId: userId),
          transitionType: AppRouteTransitionType.scale,
        );
      },
      routes: [
        // NESTED ROUTE FOR EDITING THE MAIN PROFILE
        GoRoute(
          name: AppRoutes.editProfile,
          path: AppRoutes.editProfilePath, // Uses 'details/edit'
          pageBuilder: (context, state) {
            final profileState = ProviderScope.containerOf(context).read(userProfileNotifierProvider);
            return profileState.maybeWhen(
              loaded: (user) => buildPageRoute(
                context: context,
                state: state,
                child: EditProfilePage(user: user),
                transitionType: AppRouteTransitionType.scale,
              ),
              orElse: () => buildPageRoute(
                context: context,
                state: state,
                child: const CustomLoadingScreen(), // Fallback to a loading screen
                transitionType: AppRouteTransitionType.scale,
              ),
            );
          },
        ),
        // NESTED ROUTE FOR ADDING AN ADDRESS
        GoRoute(
          name: AppRoutes.addAddress,
          path: AppRoutes.addAddressPath, // Uses 'address/add'
          pageBuilder: (context, state) {
            final authState = ProviderScope.containerOf(context).read(authNotifierProvider);
            final userId = authState.maybeWhen(authenticated: (user) => user.id, orElse: () => '');
            if (userId.isEmpty) return buildPageRoute(context: context, state: state, child: const CustomLoadingScreen(),transitionType: AppRouteTransitionType.scale);
            return buildPageRoute(
              context: context,
              state: state,
              child: AddEditAddressPage(userId: userId),
              transitionType: AppRouteTransitionType.slideFromRight,
            );
          },
        ),
        // NESTED ROUTE FOR EDITING AN ADDRESS
        GoRoute(
          name: AppRoutes.editAddress,
          path: AppRoutes.editAddressPath, // Uses 'address/edit/:addressId'
          pageBuilder: (context, state) {
            final authState = ProviderScope.containerOf(context).read(authNotifierProvider);
            final userId = authState.maybeWhen(authenticated: (user) => user.id, orElse: () => '');
            final address = state.extra as UserAddress?;

            if (userId.isEmpty || address == null) {
              return buildPageRoute(
                context: context,
                state: state,
                child: const Scaffold(body: Center(child: Text("Error: Address not found"))),transitionType: AppRouteTransitionType.scale
              );
            }
            return buildPageRoute(
              context: context,
              state: state,
              child: AddEditAddressPage(userId: userId, address: address),
              transitionType: AppRouteTransitionType.slideFromRight,
            );
          },
        ),
      ],
    ),
    GoRoute(
      name: AppRoutes.orderDetails,
      path: AppRoutes.orderDetailsPath,
      pageBuilder: (context, state) {
        final orderId = state.pathParameters['orderId'] ?? 'unknown';
        return buildPageRoute(
          context: context,
          state: state,
          child: OrderDetailsPage(orderId: orderId),
          transitionType: AppRouteTransitionType.slideFromRight,
        );
      },
    ),
    // --- Other Top-level App Routes ---
    GoRoute(
      name: AppRoutes.checkout,
      path: AppRoutes.checkoutPath,
      pageBuilder: (context, state) => buildPageRoute(
        context: context,
        state: state,
        child: const CheckoutPage(),
        transitionType: AppRouteTransitionType.slideFromRight,
      ),
    ),
    GoRoute(
      name: AppRoutes.order,
      path: AppRoutes.orderPath,
      pageBuilder: (context, state) => buildPageRoute(
        context: context,
        state: state,
        child: const OrderPage(),
        transitionType: AppRouteTransitionType.scale,
      ),
    ),
    GoRoute(
      name: AppRoutes.orderSuccess,
      path: AppRoutes.orderSuccessPath,
      pageBuilder: (context, state) {
        // Safely extract the orderId from the path parameters
        final orderId = state.pathParameters['orderId'] ?? 'unknown_order';
        return buildPageRoute(
          context: context,
          state: state,
          child: OrderSuccessPage(orderId: orderId),
          transitionType: AppRouteTransitionType.fade,
        );
      },
    ),

    GoRoute(
      name: AppRoutes.customer,
      path: AppRoutes.customerPath,
      pageBuilder: (context, state) => buildPageRoute(
        context: context,
        state: state,
        child: const CustomersPage(),
        transitionType: AppRouteTransitionType.scale,
      ),
    ),
    GoRoute(
      name: AppRoutes.notifications,
      path: AppRoutes.notificationsPath,
      pageBuilder: (context, state) => buildPageRoute(
        context: context,
        state: state,
        child: const NotificationsPage(),
        transitionType: AppRouteTransitionType.scale,
      ),
    ),
    GoRoute(
      name: AppRoutes.cart,
      path: AppRoutes.cartPath,
      pageBuilder: (context, state) {
        return buildPageRoute(
          context: context,
          state: state,
          child: const CartPage(),
          transitionType: AppRouteTransitionType.slideFromRight,
        );
      },
    ),
    GoRoute(
      name: AppRoutes.settings,
      path: AppRoutes.settingsPath,
      pageBuilder: (context, state) => buildPageRoute(
        context: context,
        state: state,
        child: const SettingsPage(),
        transitionType: AppRouteTransitionType.scale,
      ),
    ),
    GoRoute(
      name: AppRoutes.wishlist,
      path: AppRoutes.wishlistPath,
      pageBuilder: (context, state) => buildPageRoute(
        context: context,
        state: state,
        child: const WishlistPage(),
        transitionType: AppRouteTransitionType.slideFromRight,
      ),
    ),
    GoRoute(
      name: AppRoutes.managePromotions,
      path: AppRoutes.managePromotionsPath,
      pageBuilder: (context, state) => buildPageRoute(
        context: context, state: state, child: const PromotionsManagementPage(),   transitionType: AppRouteTransitionType.slideFromRight,
      ),
    ),
    GoRoute(
      name: AppRoutes.createPromotion,
      path: AppRoutes.createPromotionPath,
      pageBuilder: (context, state) {
        // This handles both create (extra is null) and edit (extra is a PromotionEntity)
        final promotion = state.extra as PromotionEntity?;
        return buildPageRoute(
          context: context,
          state: state,
          child: CreatePromotionPage(promotionToEdit: promotion),
          transitionType: AppRouteTransitionType.slideFromRight,
        );
      },
    ),
  ],
);