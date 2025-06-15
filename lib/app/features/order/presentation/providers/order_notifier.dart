// lib/app/features/order/presentation/providers/order_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/helpers/enums.dart';
import '../../../notifications/domain/entities/notification_entity.dart';
import '../../../notifications/presentation/providers/notification_providers.dart';
import '../../domain/entities/order_entity.dart';
import 'order_providers.dart';
import 'order_state.dart';


class OrderNotifier extends StateNotifier<OrderState> {
  final Ref _ref;



  OrderNotifier(
      this._ref,

      ) : super(const OrderState.initial());

  Future<void> createOrder(OrderEntity order, String namePrefix) async {
    state = const OrderState.loading();
    try {
      final useCase = _ref.read(createOrderUseCaseProvider);
      final newOrderId = await useCase.call(order, namePrefix);

      // --- CREATE THE NOTIFICATION HERE! ---
      // This is the perfect place, right after a successful order creation.
      final createNotification = _ref.read(createNotificationUseCaseProvider);
      await createNotification(
        NotificationEntity(
          id: '',
          title: '🎉 New Order Received!',
          // Use the name from the original order entity passed in.
          body: 'From: ${order.userId}. Order ID: $newOrderId',
          createdAt: DateTime.now(),
          data: {'orderId': newOrderId}, // Pass the correct, final ID
          type: NotificationType.newOrder,
        ),
      );

      // Finally, update the state to success with the correct ID.
      state = OrderState.success(newOrderId);
    } catch (e) {
      state = OrderState.error(e.toString());
    }
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required OrderStatus newStatus,
  }) async {
    state = const OrderState.loading();
    try {
      final useCase = _ref.read(updateOrderStatusUseCaseProvider);
      await useCase.call(orderId, newStatus);



      state = const OrderState.success('Order status updated');
    } catch (e) {
      state = OrderState.error(e.toString());
    }
  }

}