// lib/app/features/order/presentation/providers/order_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/helpers/enums.dart';
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
      final orderId = await useCase.call(order,namePrefix);


      state = OrderState.success(orderId);
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