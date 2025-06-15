import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/helpers/sequential_id_generator.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../cart/presentation/providers/cart_notifier_provider.dart';
import '../../../notifications/domain/entities/notification_entity.dart';
import '../../../notifications/presentation/providers/notification_providers.dart';
import '../../../order/domain/entities/order_entity.dart';
import '../../../order/presentation/providers/order_notifier_provider.dart';
import '../../../order/presentation/providers/order_providers.dart';
import '../../../user_profile/domain/entities/user_profile_entity.dart';
import '../../../../core/helpers/enums.dart'; // Ensure you have this enum file
import 'checkout_state.dart';

// This is the complete and correct Notifier.
class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final Ref ref;

  CheckoutNotifier(this.ref) : super(
    // Initialize with a coupon controller.
      CheckoutState(couponController: TextEditingController())
  );

  Future<String> _generateNextOrderId(String namePrefix) async {
    try {
      // --- ATTEMPT 1: The preferred Firestore method ---
      final getLastOrderId = ref.read(getLastOrderIdUseCaseProvider);
      final lastOrderId = await getLastOrderId();

      if (lastOrderId != null) {
        // Successfully found a previous order, so we can calculate the next number.
        final RegExp numRegExp = RegExp(r'(\d+)$');
        final match = numRegExp.firstMatch(lastOrderId);
        if (match != null) {
          final lastNumberStr = match.group(0);
          if (lastNumberStr != null) {
            final lastNumber = int.tryParse(lastNumberStr) ?? 0;
            final nextNumber = lastNumber + 1;
            return '${namePrefix}Order${nextNumber.toString().padLeft(7, '0')}';
          }
        }
      }

      // If we reach here, it means lastOrderId was null (the database is empty).
      // We will fall through to the fallback method.
      print("No previous orders found in Firestore. Defaulting to first order number.");
      return '${namePrefix}Order${'1'.padLeft(7, '0')}';

    } catch (e) {
      // --- ATTEMPT 2: The fallback in-memory method ---
      // An error occurred trying to fetch from Firestore (e.g., offline, permissions).
      // We fall back to the simple, non-persistent generator.
      print("Error fetching last order ID, using in-memory fallback: $e");
      final sequentialNumber = SequentialIdGenerator.generate();
      return '${namePrefix}Order$sequentialNumber';
    }
  }



  // Method to initialize the checkout state with data from the cart.
  void initialize(double subtotal, UserAddress defaultAddress) {
    state = state.copyWith(
      subtotal: subtotal,
      shippingAddress: defaultAddress,
      billingAddress: state.isBillingSameAsShipping ? defaultAddress : null,
      isInitialized: true,
      deliveryFee: _calculateDeliveryFee(defaultAddress), // Also calculate initial fee
    );
  }

  // --- Methods to update checkout UI state ---
  void selectShippingAddress(UserAddress address) {
    state = state.copyWith(
      shippingAddress: address,
      deliveryFee: _calculateDeliveryFee(address),
      billingAddress: state.isBillingSameAsShipping ? address : state.billingAddress,
    );
  }

  void selectBillingAddress(UserAddress address) {
    state = state.copyWith(billingAddress: address);
  }

  void toggleBillingAddress(bool isSame) {
    state = state.copyWith(
      isBillingSameAsShipping: isSame,
      billingAddress: isSame ? state.shippingAddress : null,
    );
  }

  void selectPaymentMethod(String method) {
    state = state.copyWith(selectedPaymentMethod: method);
  }

  void applyCoupon() {
    if (state.couponController.text.trim().toLowerCase() == 'firstorder') {
      state = state.copyWith(discount: 5.0, isCouponApplied: true);
    } else {
      state = state.copyWith(discount: 0.0, isCouponApplied: false);
    }
  }

  void removeCoupon() {
    state.couponController.clear();
    state = state.copyWith(discount: 0.0, isCouponApplied: false);
  }

  double _calculateDeliveryFee(UserAddress? address) {
    if (address == null) return 0.0;
    if (address.country.toLowerCase() != 'bangladesh') return 10.0;
    if (address.city.toLowerCase() == 'dhaka') return 1.0;
    return 1.5;
  }
  String? _formatAddress(UserAddress? address) {
    if (address == null) return null;
    // This creates a clean, readable string. Adjust fields as needed.
    return '${address.addressLine1}, ${address.area ?? ''}, ${address.city}, ${address.state}, ${address.postalCode}, ${address.country}';
  }
  // --- The main logic to place the order ---
  Future<void> placeOrder(List<CartItemEntity> cartItems) async {
    final currentUser = ref.read(currentUserProvider);
    final userDisplayName = currentUser?.displayName;
    if (currentUser == null || state.shippingAddress == null || cartItems.isEmpty) {
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      final orderItems = cartItems.map((cartItem) => OrderItemEntity(
        productId: cartItem.productId,
        productTitle: cartItem.productTitle,
        variantSize: cartItem.variantSize,
        variantColorName: cartItem.variantColorName,
        price: cartItem.variantPrice,
        quantity: cartItem.quantity,
        imageUrl: cartItem.variantImageUrl,
      )).toList();
      String namePrefix;
      if (userDisplayName != null && userDisplayName.isNotEmpty) {
        // Take the first 4 letters, handling names shorter than 4.
        final rawPrefix = userDisplayName.substring(0, userDisplayName.length > 4 ? 4 : userDisplayName.length);
        // Capitalize the first letter for a clean "Fabia" look.
        namePrefix = '${rawPrefix[0].toUpperCase()}${rawPrefix.substring(1).toLowerCase()}';
      } else {
        namePrefix = 'GuestUser';
      }


      final newOrder = OrderEntity(
        id:  '',
        userId: currentUser.id,
        items: orderItems,
        totalAmount: state.grandTotal,
        orderDate: DateTime.now(),
        status: OrderStatus.pending,
        shippingAddress: _formatAddress(state.shippingAddress),
        billingAddress: (state.isBillingSameAsShipping)
            ? _formatAddress(state.shippingAddress)
            : _formatAddress(state.billingAddress),
        paymentMethod: state.selectedPaymentMethod,
        transactionId: null,
      );

      // THIS IS THE KEY CONNECTION
      await ref.read(orderNotifierProvider.notifier).createOrder(newOrder,namePrefix);
      ref.read(cartNotifierProvider.notifier).clearCart(currentUser.id);

      // The UI will listen to the orderNotifierProvider for success/error.
      // We only need to reset our own loading state if there's an error on our end.
      // The listener on the page will handle navigation.
      final createNotification = ref.read(createNotificationUseCaseProvider);
      await createNotification(
        NotificationEntity(
          id: '', // Firestore will generate this
          title: '🎉 New Order Received!',
          body: 'From: ${currentUser.displayName ?? 'A Customer'}. Total: \$${newOrder.totalAmount.toStringAsFixed(2)}',
          createdAt: DateTime.now(), // This will be replaced by server timestamp
          data: {'orderId': newOrder.id},
          type: NotificationType.newOrder,
        ),
      );
      // await FcmService.sendNewOrderNotificationToAdmins(
      //   orderId: newOrder.id,
      //   customerName: currentUser.displayName ?? 'A Customer',
      //   totalAmount: newOrder.totalAmount,
      // );
      state = state.copyWith(isLoading: false);

    } catch (e) {
      // If something goes wrong before calling the order notifier
      state = state.copyWith(isLoading: false);
      // You could also set an error state here
    }
  }


  @override
  void dispose() {
    state.couponController.dispose();
    super.dispose();
  }
}