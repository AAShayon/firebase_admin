import 'package:firebase_admin/app/features/search/presentation/providers/search_notifier.dart';
import 'package:firebase_admin/app/features/search/presentation/providers/search_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final searchNotifierProvider =
StateNotifierProvider.autoDispose<SearchNotifier, SearchState>(
      (ref) => SearchNotifier(ref),
);