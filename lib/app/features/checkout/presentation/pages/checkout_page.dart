import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Core and Feature imports
import '../../../../core/routes/app_router.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../../order/presentation/providers/order_notifier_provider.dart';
import '../../../order/presentation/providers/order_state.dart';
import '../../../payment/presentation/providers/payment_notifier_provider.dart';
import '../../../payment/presentation/providers/payment_state.dart';
import '../../../user_profile/presentation/providers/user_profile_providers.dart';

// Widget imports
import '../providers/checkout_notifier_provider.dart';
import '../widgets/address_selection_section.dart';
import '../widgets/checkout_summary_card.dart';

class CheckoutPage extends ConsumerWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    // Get userId early for use in listeners and builders
    final userId = currentUser?.id;

    // --- LISTENERS for async operations ---
    ref.listen<OrderState>(orderNotifierProvider, (_, next) {
      next.whenOrNull(
        success: (orderId) {
          // On successful order creation, go to the success page
          context.goNamed(
            AppRoutes.orderSuccess,
            pathParameters: {'orderId': orderId},
          );
        },
        error: (message) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error placing order: $message'), backgroundColor: Colors.red),
        ),
      );
    });

    // --- THIS LISTENER IS NOW THE KEY TO CONNECTING PAYMENT AND ORDER CREATION ---
    ref.listen<PaymentState>(paymentNotifierProvider, (_, next) {
      // We only care about user actions, so if userId is null, do nothing.
      if (userId == null) return;

      next.maybeWhen(
        // SUCCESS: This is where the magic happens!
        success: (transactionId) {
          // When payment succeeds, we get the transactionId here.
          // Now, we can place the order with the transaction ID.
          final cartItems = ref.read(cartItemsStreamProvider(userId)).value;
          if (cartItems != null && cartItems.isNotEmpty) {
            ref.read(checkoutNotifierProvider.notifier).placeOrder(
              cartItems,transactionId,// Pass the ID here!
            );
          }
        },
        // FAILURE: Show an error message.
        failure: (message) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        ),
        // orElse: We don't need to do anything for .initial() or .loading() states here.
        orElse: () {},
      );
    });

    // --- UI STATE ---
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: const Center(child: Text('Please log in to checkout')),
      );
    }
    // userId is already defined above

    final cartItemsAsync = ref.watch(cartItemsStreamProvider(userId!));
    final userProfileAsync = ref.watch(userProfileStreamProvider(userId));

    final checkoutState = ref.watch(checkoutNotifierProvider);
    final orderState = ref.watch(orderNotifierProvider);
    final paymentState = ref.watch(paymentNotifierProvider);

    // --- LOADING STATE CHECKS (This logic remains correct) ---
    final isPlacingOrder = checkoutState.isLoading || orderState.maybeWhen(loading: () => true, orElse: () => false);
    final isPaymentProcessing = paymentState.maybeWhen(loading: () => true, orElse: () => false);
    final isOverallLoading = isPlacingOrder || isPaymentProcessing;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.invalidate(checkoutNotifierProvider);
            ref.invalidate(paymentNotifierProvider);
            context.pop();
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          // --- THE ONPRESSED LOGIC IS NOW CLEAN AND SEPARATED ---
          onPressed: isOverallLoading ||
              checkoutState.shippingAddress == null ||
              (cartItemsAsync.valueOrNull?.isEmpty ?? true)
              ? null
              : () { // No longer needs to be async!
            final checkoutNotifier = ref.read(checkoutNotifierProvider.notifier);
            final currentCheckoutState = ref.read(checkoutNotifierProvider);
            final cartItems = ref.read(cartItemsStreamProvider(userId)).value;

            if (cartItems == null || cartItems.isEmpty) return;

            // SCENARIO 1: Online Payment
            if (currentCheckoutState.selectedPaymentMethod == 'online') {
              // Just trigger the payment process.
              // The `ref.listen` block above will handle what to do on success.
              ref.read(paymentNotifierProvider.notifier).processPayment(amount: currentCheckoutState.grandTotal);
            }
            // SCENARIO 2: Cash on Delivery
            else {
              // Place the order directly. The transactionId will be null by default.
              checkoutNotifier.placeOrder(cartItems,"N/A");
            }
          },
          child: _buildButtonChild(isPlacingOrder, isPaymentProcessing, checkoutState.selectedPaymentMethod),
        ),
      ),
      body: cartItemsAsync.when(
        data: (cartItems) {
          if (cartItems.isEmpty) {
            return const Center(child: Text("Your cart is empty."));
          }
          return userProfileAsync.when(
            data: (user) {
              final checkoutNotifier = ref.read(checkoutNotifierProvider.notifier);

              if (!checkoutState.isInitialized && user.addresses.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) {
                    final subtotal = cartItems.fold<double>(0, (sum, item) => sum + (item.variantPrice * item.quantity));
                    final defaultAddress = user.addresses.firstWhere((a) => a.isDefault, orElse: () => user.addresses.first);
                    checkoutNotifier.initialize(subtotal, defaultAddress);
                  }
                });
              }

              if (user.addresses.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Please add a shipping address to your profile first.", textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.pushNamed(AppRoutes.addAddress),
                        child: const Text('Add Address'),
                      ),
                    ],
                  ),
                );
              }

              // The rest of your UI remains the same
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AddressSelectionSection(
                      title: 'Shipping Address',
                      addresses: user.addresses,
                      selectedAddress: checkoutState.shippingAddress,
                      onAddressSelected: checkoutNotifier.selectShippingAddress,
                    ),
                    const SizedBox(height: 24),
                    CheckboxListTile(
                      title: const Text("Billing address is same as shipping"),
                      value: checkoutState.isBillingSameAsShipping,
                      onChanged: (value) => checkoutNotifier.toggleBillingAddress(value ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (!checkoutState.isBillingSameAsShipping) ...[
                      const SizedBox(height: 16),
                      AddressSelectionSection(
                        title: 'Billing Address',
                        addresses: user.addresses,
                        selectedAddress: checkoutState.billingAddress,
                        onAddressSelected: checkoutNotifier.selectBillingAddress,
                      ),
                    ],
                    const SizedBox(height: 24),
                    Text('Payment Method', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    RadioListTile<String>(
                      title: const Text('Cash on Delivery'),
                      value: 'cod',
                      groupValue: checkoutState.selectedPaymentMethod,
                      onChanged: (val) => checkoutNotifier.selectPaymentMethod(val!),
                    ),
                    RadioListTile<String>(
                      title: const Text('Online Payment'),
                      value: 'online',
                      groupValue: checkoutState.selectedPaymentMethod,
                      onChanged: (val) => checkoutNotifier.selectPaymentMethod(val!),
                    ),
                    const SizedBox(height: 24),
                    CheckoutSummaryCard(
                      subtotal: checkoutState.subtotal,
                      deliveryFee: checkoutState.deliveryFee,
                      discount: checkoutState.discount,
                      total: checkoutState.grandTotal,
                      couponController: checkoutState.couponController,
                      isCouponApplied: checkoutState.isCouponApplied,
                      onApplyCoupon: checkoutNotifier.applyCoupon,
                      onRemoveCoupon: checkoutNotifier.removeCoupon,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error loading profile: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error loading cart: $e')),
      ),
    );
  }

  Widget _buildButtonChild(bool isPlacingOrder, bool isPaymentProcessing, String selectedMethod) {
    if (isPaymentProcessing) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)),
          SizedBox(width: 16),
          Text('PROCESSING PAYMENT...'),
        ],
      );
    }
    if (isPlacingOrder) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)),
          SizedBox(width: 16),
          Text('PLACING ORDER...'),
        ],
      );
    }
    return Text(selectedMethod == 'online' ? 'Proceed to Pay' : 'Place Order');
  }
}