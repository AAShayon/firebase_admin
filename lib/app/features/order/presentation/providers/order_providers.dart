// lib/app/features/order/presentation/providers/order_providers.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injector.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/usecases/create_order_use_case.dart';
import '../../domain/usecases/get_all_orders_use_case.dart';
import '../../domain/usecases/get_last_order_id_use_case.dart';
import '../../domain/usecases/get_order_by_id_use_case.dart';
import '../../domain/usecases/get_user_orders_use_case.dart';
import '../../domain/usecases/update_order_status_use_case.dart';
import '../../domain/usecases/watch_order_by_id_use_case.dart';

// Use Case Providers
final createOrderUseCaseProvider = Provider<CreateOrderUseCase>((ref) {
  return locator<CreateOrderUseCase>();
});

final getUserOrdersUseCaseProvider = Provider<GetUserOrdersUseCase>((ref) {
  return locator<GetUserOrdersUseCase>();
});

final getAllOrdersUseCaseProvider = Provider<GetAllOrdersUseCase>((ref) {
  return locator<GetAllOrdersUseCase>();
});

final updateOrderStatusUseCaseProvider = Provider<UpdateOrderStatusUseCase>((ref) {
  return locator<UpdateOrderStatusUseCase>();
});
final getOrderByIdUseCaseProvider = Provider<GetOrderByIdUseCase>((ref) {
  return locator<GetOrderByIdUseCase>();
});
final getLastOrderIdUseCaseProvider = Provider<GetLastOrderIdUseCase>((ref) {
  return locator<GetLastOrderIdUseCase>();
});
final watchOrderByIdUseCaseProvider = Provider<WatchOrderByIdUseCase>((ref) {
  return locator<WatchOrderByIdUseCase>();
});

final userOrdersStreamProvider = StreamProvider.family<List<OrderEntity>, String>((ref, userId) {
  final useCase = ref.watch(getUserOrdersUseCaseProvider);
  return useCase.call(userId).map((orders) {
    // This will print the list every time it updates
    if (kDebugMode) {
      print('--- DEBUG: User Orders Updated ---');
      print('User ID: $userId');
      print('Number of orders: ${orders.length}');
      // You can even print the details of each order
      // for (var order in orders) {
      //   print('Order ID: ${order.id}, Status: ${order.status}');
      // }
    }
    return orders;
  });
});

final allOrdersStreamProvider = StreamProvider<List<OrderEntity>>((ref) {
  final useCase = ref.watch(getAllOrdersUseCaseProvider);
  return useCase.call().map((orders) {
    // This will print the list every time it updates
    if (kDebugMode) {
      print('--- DEBUG: All Orders Updated ---');
      print('Total orders: ${orders.length}');
    }
    return orders;
  });
});
final orderDetailsProvider =
StreamProvider.autoDispose.family<OrderEntity, String>((ref, orderId) {
  final watchOrderById = ref.watch(watchOrderByIdUseCaseProvider);
  return watchOrderById(orderId);
});