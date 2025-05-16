import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/theme/app_theme.dart';
import '../dashboard/presentation/pages/dashboard_page.dart';
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
        return MaterialApp(
          title: 'Admin Dashboard',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          debugShowCheckedModeBanner: false,
          home: const SplashScreen(),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error initializing app: $e')),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _goToDashboard();
  }

  Future<void> _goToDashboard() async {
    await Future.delayed(const Duration(seconds: 2)); // simulate splash delay
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Welcome to Admin Dashboard')),
    );
  }
}
