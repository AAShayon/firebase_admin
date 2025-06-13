import 'package:firebase_admin/app/features/order/presentation/pages/order_success_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../../order/presentation/providers/order_notifier_provider.dart';
import '../../../order/presentation/providers/order_state.dart';
import '../../../user_profile/presentation/providers/user_profile_providers.dart';
import '../providers/checkout_notifier_provider.dart';
import '../widgets/address_selection_section.dart';
import '../widgets/checkout_summary_card.dart';

class CheckoutPage extends ConsumerWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    // Add listener to handle order creation result
    ref.listen<OrderState>(orderNotifierProvider, (previous, next) {
      next.whenOrNull(
        success: (orderId) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order placed successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OrderSuccessPage(orderId: orderId)),
          );

        },
        error: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $message'),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    });

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: const Center(child: Text('Please log in to checkout')),
      );
    }
    final userId = currentUser.id;

    final cartItemsAsync = ref.watch(cartItemsStreamProvider(userId));
    final userProfileAsync = ref.watch(userProfileStreamProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer(builder: (context, ref, _) {
          final checkoutState = ref.watch(checkoutNotifierProvider);
          final orderState = ref.watch(orderNotifierProvider);
          final bool isLoading = checkoutState.isLoading || orderState is Loading;

          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: isLoading ||
                checkoutState.shippingAddress == null ||
                (cartItemsAsync.valueOrNull?.isEmpty ?? true)
                ? null
                : () {
              final cartItems = ref.read(cartItemsStreamProvider(userId)).value;
              if (cartItems != null) {
                ref.read(checkoutNotifierProvider.notifier).placeOrder(cartItems);
              }
            },
            child: isLoading
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            )
                : const Text('Place Order'),
          );
        }),
      ),
      body: cartItemsAsync.when(
        data: (cartItems) {
          return userProfileAsync.when(
            data: (user) {
              final checkoutNotifier = ref.read(checkoutNotifierProvider.notifier);
              final checkoutState = ref.watch(checkoutNotifierProvider);

              if (!checkoutState.isInitialized &&
                  cartItems.isNotEmpty &&
                  user.addresses.isNotEmpty) {
                final subtotal = cartItems.fold<double>(
                  0,
                      (sum, item) => sum + (item.variantPrice * item.quantity),
                );
                final defaultAddress = user.addresses.firstWhere(
                      (a) => a.isDefault,
                  orElse: () => user.addresses.first,
                );

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) {
                    checkoutNotifier.initialize(subtotal, defaultAddress);
                  }
                });
              }

              if (cartItems.isEmpty) {
                return const Center(child: Text("Your cart is empty."));
              }

              if (user.addresses.isEmpty) {
                return const Center(
                  child: Text("Please add a shipping address to your profile first."),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AddressSelectionSection(
                      title: 'Shipping Address',
                      addresses: user.addresses,
                      selectedAddress: checkoutState.shippingAddress,
                      onAddressSelected: (address) =>
                          checkoutNotifier.selectShippingAddress(address),
                    ),
                    const SizedBox(height: 24),
                    CheckboxListTile(
                      title: const Text("Billing address is same as shipping"),
                      value: checkoutState.isBillingSameAsShipping,
                      onChanged: (value) =>
                          checkoutNotifier.toggleBillingAddress(value ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (!checkoutState.isBillingSameAsShipping) ...[
                      const SizedBox(height: 16),
                      AddressSelectionSection(
                        title: 'Billing Address',
                        addresses: user.addresses,
                        selectedAddress: checkoutState.billingAddress,
                        onAddressSelected: (address) =>
                            checkoutNotifier.selectBillingAddress(address),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Text(
                      'Payment Method',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    RadioListTile<String>(
                      title: const Text('Cash on Delivery'),
                      value: 'cod',
                      groupValue: checkoutState.selectedPaymentMethod,
                      onChanged: (val) => checkoutNotifier.selectPaymentMethod(val!),
                    ),
                    RadioListTile<String>(
                      title: const Text('Online Payment (Not available)'),
                      value: 'online',
                      groupValue: checkoutState.selectedPaymentMethod,
                      onChanged: null,
                    ),
                    const SizedBox(height: 24),
                    CheckoutSummaryCard(
                      subtotal: checkoutState.subtotal,
                      deliveryFee: checkoutState.deliveryFee,
                      discount: checkoutState.discount,
                      total: checkoutState.grandTotal,
                      couponController: checkoutState.couponController,
                      isCouponApplied: checkoutState.isCouponApplied,
                      onApplyCoupon: () => checkoutNotifier.applyCoupon(),
                      onRemoveCoupon: () => checkoutNotifier.removeCoupon(),
                    ),
                    if (checkoutState.shippingAddress?.country.toLowerCase() != 'bangladesh')
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          '+ Additional shipping charges may apply for international orders.',
                          style: TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
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
}