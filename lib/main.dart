import 'package:firebase_admin/app/features/initialization/app_initializer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/core/di/injector.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(ProviderScope(child: const AdminDashboardAppInitializer()));
}
