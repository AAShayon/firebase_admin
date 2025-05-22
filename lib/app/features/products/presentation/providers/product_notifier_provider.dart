
import 'package:firebase_admin/app/features/products/presentation/providers/product_notifier.dart';
import 'package:firebase_admin/app/features/products/presentation/providers/product_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final productNotifierProvider = StateNotifierProvider<ProductNotifier, ProductState>(
      (ref) => ProductNotifier(ref),
);
