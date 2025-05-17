import 'dart:developer';

import 'package:animated_splash_plus/animated_splash_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/widgets/loading_screen.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../providers/splash_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final splashAsync = ref.watch(splashProvider);
    return splashAsync.when(
      data: (user) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => user != null ? const DashboardPage() : const LoginPage(),
            ),
          );
        });

        // This fallback will only show briefly
        return const CustomLoadingScreen();
      },
    loading: () => Scaffold(
      body: AnimatedSplashPlus(
        config:  SplashConfig(
          appName: 'Admin Dashboard',
          appNamePart1: 'Admin',
          appNamePart2: 'Dashboard',
          subtitle: 'Management Console',
          welcomeText: 'Loading...',
          sunsetDuration: const Duration(seconds: 2),
          textAnimationDuration: const Duration(seconds: 1),
          sunStartColor: Colors.blueAccent,
          sunEndColor: Colors.blue.shade900,
          skyEndBottomColor: Theme.of(context).primaryColor,
          skyEndMiddleColor: Theme.of(context).primaryColorLight,
          skyEndTopColor: Theme.of(context).primaryColorDark,
        ),
        onAnimationComplete: (){
           log('Complete Splash ');
        },
      ),
    ),
      error: (err, _) => Center(child: Text('Error: $err')),
    );

  }

}