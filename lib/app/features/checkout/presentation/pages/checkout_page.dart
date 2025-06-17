import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Core and Feature imports
import '../../../../core/routes/app_router.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
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
    // --- SETUP LISTENERS ---
    // These react to the results of actions initiated on this page.
    ref.listen<OrderState>(orderNotifierProvider, (_, next) {
      next.whenOrNull(
        success: (orderId) {
          ref.invalidate(checkoutNotifierProvider);
          ref.invalidate(paymentNotifierProvider);
          context.goNamed(AppRoutes.orderSuccess, pathParameters: {'orderId': orderId});
        },
        error: (message) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error placing order: $message'), backgroundColor: Colors.red),
        ),
      );
    });

    ref.listen<PaymentState>(paymentNotifierProvider, (_, next) {
      next.maybeWhen(
        success: (transactionId) {
          ref.read(checkoutNotifierProvider.notifier).placeOrder(transactionId: transactionId);
        },
        failure: (message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Something error "), backgroundColor: Colors.red)),
        orElse: () {},
      );
    });

    // --- WATCH STATES FOR UI ---
    final checkoutState = ref.watch(checkoutNotifierProvider);
    final userId = ref.watch(currentUserProvider)?.id ?? '';

    // If state hasn't been prepared, it's a sign of a navigation error or delay.
    if (!checkoutState.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Preparing your checkout..."),
              SizedBox(height: 16),
              CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }

    // After initialization, we can safely build the UI.
    final isPlacingOrder = checkoutState.isLoading || ref.watch(orderNotifierProvider).maybeWhen(loading: () => true, orElse: () => false);
    final isPaymentProcessing = ref.watch(paymentNotifierProvider).maybeWhen(loading: () => true, orElse: () => false);
    final isOverallLoading = isPlacingOrder || isPaymentProcessing;

    final userProfileAsync = ref.watch(userProfileStreamProvider(userId));

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
          onPressed: isOverallLoading || checkoutState.shippingAddress == null || checkoutState.itemsToCheckout.isEmpty
              ? null
              : () {
            final paymentNotifier = ref.read(paymentNotifierProvider.notifier);
            if (checkoutState.selectedPaymentMethod == 'online') {
              paymentNotifier.processPayment(amount: checkoutState.grandTotal);
            } else {
              ref.read(checkoutNotifierProvider.notifier).placeOrder(transactionId: 'N/A');
            }
          },
          child: _buildButtonChild(isPlacingOrder, isPaymentProcessing, checkoutState.selectedPaymentMethod),
        ),
      ),
      body: userProfileAsync.when(
        data: (user) {
          if (user.addresses.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text("No Shipping Address", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text("Please add a shipping address to your profile before you can proceed.", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey)),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.pushNamed(AppRoutes.addAddress),
                      child: const Text('Add Address'),
                    ),
                  ],
                ),
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
                  subtotal: checkoutState.subtotal,
                  deliveryFee: checkoutState.deliveryFee,
                  discount: checkoutState.discount,
                  total: checkoutState.grandTotal,
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
        error: (e, s) => Center(child: Text('Error loading user profile: $e')),
      ),
    );
  }

  Widget _buildButtonChild(bool isPlacingOrder, bool isPaymentProcessing, String selectedMethod) {
    if (isPaymentProcessing) return const Row(mainAxisAlignment: MainAxisAlignment.center, children: [SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white)), SizedBox(width: 16), Text('PROCESSING PAYMENT...')]);
    if (isPlacingOrder) return const Row(mainAxisAlignment: MainAxisAlignment.center, children: [SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white)), SizedBox(width: 16), Text('PLACING ORDER...')]);
    return Text(selectedMethod == 'online' ? 'Proceed to Pay' : 'Place Order');
  }
}