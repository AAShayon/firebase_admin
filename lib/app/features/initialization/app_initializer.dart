import 'package:firebase_admin/app/features/initialization/presentation/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/theme/app_theme.dart';
import '../../core/routes/app_router.dart';
import '../settings/presentation/helpers/theme_mapper.dart';
import '../settings/presentation/providers/settings_notifier_provider.dart';

class AdminDashboardAppInitializer extends ConsumerWidget {
  const AdminDashboardAppInitializer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsNotifierProvider);

    return settingsAsync.when(
      data: (settings) {
        final themeMode = convertTheme(settings.themeMode);
        return MaterialApp.router(
          routerConfig: appRouter,
          title: 'Admin Dashboard',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          debugShowCheckedModeBanner: false,
        );
      },
      loading: () =>  MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (e, _) => MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Error initializing app: $e')),
        ),
      ),
    );
  }
}
