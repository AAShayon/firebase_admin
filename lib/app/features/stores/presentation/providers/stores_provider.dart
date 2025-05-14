// lib/features/stores/presentation/providers/stores_provider.dart
import 'package:flutter/foundation.dart';

import '../../domain/entities/store_entity.dart';
import '../../domain/usecases/get_stores_usecase.dart';

class StoresProvider with ChangeNotifier {
  final GetStoresUseCase getStoresUseCase;

  StoresProvider({required this.getStoresUseCase});

  List<StoreEntity> _stores = [];
  List<StoreEntity> get stores => _stores;

  Future<void> loadStores() async {
    _stores = await getStoresUseCase();
    notifyListeners();
  }
}