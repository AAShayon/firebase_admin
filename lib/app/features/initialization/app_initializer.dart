import 'package:firebase_admin/app/config/widgets/loading_screen.dart';
import 'package:firebase_admin/app/features/initialization/presentation/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/theme/app_theme.dart';
import '../../core/helpers/keyboard_helper.dart';
import '../../core/routes/app_router.dart';
import '../settings/presentation/helpers/theme_mapper.dart';
import '../settings/presentation/providers/settings_notifier_provider.dart';

class AdminDashboardAppInitializer extends ConsumerWidget {
  const AdminDashboardAppInitializer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsNotifierProvider);

    return settingsAsync.map(
      initial: (_) => MaterialApp(
        home: KeyboardManager(
          child: SplashScreen(),
        ),
      ),
      loading: (_) => MaterialApp(
        home: KeyboardManager(
          child: CustomLoadingScreen(),
        ),
      ),
      loaded: (state) {
        final themeMode = convertTheme(state.themeMode);
        return MaterialApp.router(
          routerConfig: appRouter,
          title: 'Admin Dashboard',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          debugShowCheckedModeBanner: false,
          builder: (context ,child){
            return KeyboardManager(child: child!);
          },
        );
      },
      error: (error) => MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Failed to initialize app: ${error.message}'),
          ),
        ),
      ),
    );
  }
}