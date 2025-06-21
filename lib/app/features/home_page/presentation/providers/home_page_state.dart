import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_page_state.freezed.dart';

@freezed
class HomePageState with _$HomePageState {
  const factory HomePageState({
    @Default(false) bool isAddingToCart,
    String? cartProductId,
  }) = _HomePageState;
}