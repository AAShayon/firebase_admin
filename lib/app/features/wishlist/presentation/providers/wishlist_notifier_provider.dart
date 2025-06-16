import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'wishlist_notifier.dart';
import 'wishlist_state.dart';

final wishlistNotifierProvider =
StateNotifierProvider.autoDispose<WishlistNotifier, WishlistState>((ref) {
  return WishlistNotifier(ref);
});