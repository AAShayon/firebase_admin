import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Core and Feature imports
import '../../../../core/routes/app_router.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
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
    final userId = currentUser?.id ?? '';

    // --- LISTENERS for async operations ---
    // Listens for the final order creation result to navigate on success
    ref.listen<OrderState>(orderNotifierProvider, (_, next) {
      next.whenOrNull(
        success: (orderId) {
          // Reset states to ensure the page is fresh if the user comes back
          ref.invalidate(checkoutNotifierProvider);
          ref.invalidate(paymentNotifierProvider);
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

    // Listens for the payment result to trigger order placement
    ref.listen<PaymentState>(paymentNotifierProvider, (_, next) {
      if (userId.isEmpty) return; // Don't do anything if there's no user

      next.maybeWhen(
        success: (transactionId) {
          // When payment succeeds, get the items to order (either from "Buy Now" or the cart)
          final itemsToOrder = ref.read(checkoutNotifierProvider).buyNowItems ?? ref.read(cartItemsStreamProvider(userId)).value;

          if (itemsToOrder != null && itemsToOrder.isNotEmpty) {
            ref.read(checkoutNotifierProvider.notifier).placeOrder(
              itemsToOrder,
              transactionId: transactionId,
            );
          }
        },
        failure: (message) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        ),
        orElse: () {},
      );
    });

    // --- UI STATE ---
    if (currentUser == null) {
      return Scaffold(appBar: AppBar(title: const Text('Checkout')), body: const Center(child: Text('Please log in')));
    }

    final cartItemsAsync = ref.watch(cartItemsStreamProvider(userId));
    final userProfileAsync = ref.watch(userProfileStreamProvider(userId));
    final checkoutState = ref.watch(checkoutNotifierProvider);

    // Combine all loading states into one flag for the UI
    final isPlacingOrder = checkoutState.isLoading || ref.watch(orderNotifierProvider).maybeWhen(loading: () => true, orElse: () => false);
    final isPaymentProcessing = ref.watch(paymentNotifierProvider).maybeWhen(loading: () => true, orElse: () => false);
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
          onPressed: isOverallLoading ||
              checkoutState.shippingAddress == null ||
              ((checkoutState.buyNowItems ?? cartItemsAsync.valueOrNull)?.isEmpty ?? true)
              ? null
              : () {
            final paymentNotifier = ref.read(paymentNotifierProvider.notifier);
            final checkoutNotifier = ref.read(checkoutNotifierProvider.notifier);
            final itemsToOrder = checkoutState.buyNowItems ?? ref.read(cartItemsStreamProvider(userId)).value;

            if (itemsToOrder == null || itemsToOrder.isEmpty) return;

            if (checkoutState.selectedPaymentMethod == 'online') {
              // Fire-and-forget: The listener will handle the success case.
              paymentNotifier.processPayment(amount: checkoutState.grandTotal);
            } else {
              // For COD, place the order directly.
              checkoutNotifier.placeOrder(itemsToOrder, transactionId: 'N/A');
            }
          },
          child: _buildButtonChild(isPlacingOrder, isPaymentProcessing, checkoutState.selectedPaymentMethod),
        ),
      ),
      // The body now correctly handles displaying the form for EITHER cart items or "Buy Now" items.
      body: userProfileAsync.when(
        data: (user) {
          final itemsForDisplay = checkoutState.buyNowItems ?? cartItemsAsync.valueOrNull;

          // Initialize state if needed. This is the key logic.
          if (!checkoutState.isInitialized && user.addresses.isNotEmpty) {
            // Only initialize from the cart IF it's not a "Buy Now" flow.
            if (checkoutState.buyNowItems == null && (cartItemsAsync.valueOrNull?.isNotEmpty ?? false)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  final cartItems = cartItemsAsync.value!;
                  final subtotal = cartItems.fold<double>(0, (sum, item) => sum + (item.variantPrice * item.quantity));
                  final defaultAddress = user.addresses.firstWhere((a) => a.isDefault, orElse: () => user.addresses.first);
                  ref.read(checkoutNotifierProvider.notifier).initializeFromCart(subtotal, defaultAddress);
                }
              });
            }
          }

          if (itemsForDisplay == null || itemsForDisplay.isEmpty) {
            return const Center(child: Text("Your cart is empty."));
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AddressSelectionSection(
                  title: 'Shipping Address', addresses: user.addresses,
                  selectedAddress: checkoutState.shippingAddress,
                  onAddressSelected: ref.read(checkoutNotifierProvider.notifier).selectShippingAddress,
                ),
                const SizedBox(height: 24),
                CheckboxListTile(
                  title: const Text("Billing address is same as shipping"),
                  value: checkoutState.isBillingSameAsShipping,
                  onChanged: (value) => ref.read(checkoutNotifierProvider.notifier).toggleBillingAddress(value ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                if (!checkoutState.isBillingSameAsShipping) ...[
                  const SizedBox(height: 16),
                  AddressSelectionSection(
                    title: 'Billing Address', addresses: user.addresses,
                    selectedAddress: checkoutState.billingAddress,
                    onAddressSelected: ref.read(checkoutNotifierProvider.notifier).selectBillingAddress,
                  ),
                ],
                const SizedBox(height: 24),
                Text('Payment Method', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                RadioListTile<String>(
                  title: const Text('Cash on Delivery'), value: 'cod',
                  groupValue: checkoutState.selectedPaymentMethod,
                  onChanged: (val) => ref.read(checkoutNotifierProvider.notifier).selectPaymentMethod(val!),
                ),
                RadioListTile<String>(
                  title: const Text('Online Payment'), value: 'online',
                  groupValue: checkoutState.selectedPaymentMethod,
                  onChanged: (val) => ref.read(checkoutNotifierProvider.notifier).selectPaymentMethod(val!),
                ),
                const SizedBox(height: 24),
                CheckoutSummaryCard(
                  subtotal: checkoutState.subtotal, deliveryFee: checkoutState.deliveryFee,
                  discount: checkoutState.discount, total: checkoutState.grandTotal,
                  couponController: checkoutState.couponController,
                  isCouponApplied: checkoutState.isCouponApplied,
                  onApplyCoupon: ref.read(checkoutNotifierProvider.notifier).applyCoupon,
                  onRemoveCoupon: ref.read(checkoutNotifierProvider.notifier).removeCoupon,
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error loading profile: $e')),
      ),
    );
  }

  Widget _buildButtonChild(bool isPlacingOrder, bool isPaymentProcessing, String selectedMethod) {
    if (isPaymentProcessing) {
      return const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)),
        SizedBox(width: 16),
        Text('PROCESSING PAYMENT...'),
      ]);
    }
    if (isPlacingOrder) {
      return const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)),
        SizedBox(width: 16),
        Text('PLACING ORDER...'),
      ]);
    }
    return Text(selectedMethod == 'online' ? 'Proceed to Pay' : 'Place Order');
  }
}