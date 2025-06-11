import 'package:firebase_admin/app/core/di/injector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/domain/usecases/search_product_use_case.dart';

final searchProductUseCaseProvider = Provider.autoDispose<SearchProductUseCase>((ref) {
  return locator<SearchProductUseCase>();
});