// The new notifier provider
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'home_page_notifier.dart';
import 'home_page_state.dart';

final homePageNotifierProvider = StateNotifierProvider<HomePageNotifier, HomePageState>((ref) {
  return HomePageNotifier(ref);
});