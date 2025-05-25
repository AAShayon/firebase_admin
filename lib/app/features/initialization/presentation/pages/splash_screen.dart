import 'dart:developer';

import 'package:animated_splash_plus/animated_splash_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/widgets/loading_screen.dart';
import '../../../../core/routes/app_router.dart';
import '../providers/splash_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: AnimatedSplashPlus(
        config: SplashConfig(
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
        onAnimationComplete: () {
          log('Splash animation complete');

          // Delay navigation slightly to avoid context issues
          Future.delayed(const Duration(milliseconds: 300), () async {
            final splashAsync = await ref.read(splashProvider.future);

            if (!context.mounted) return;

            if (splashAsync != null) {
              log('User is authenticated: ${splashAsync.displayName}');
              context.go(AppRoutes.landingPath);
            } else {
              log('No user found, redirecting to login');
              context.go(AppRoutes.loginPath);
            }
          });
        },
      ),
    );
  }
}