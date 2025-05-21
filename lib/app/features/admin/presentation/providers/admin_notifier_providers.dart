import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'admin_notifier.dart';
import 'admin_state.dart';

final adminNotifierProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref)=>AdminNotifier(ref));