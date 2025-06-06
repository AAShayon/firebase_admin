import 'dart:developer';

import 'package:animated_splash_plus/animated_splash_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_router.dart';
import '../../../auth/presentation/providers/auth_notifier_provider.dart';

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

            Future.delayed(const Duration(milliseconds: 300), () async {
              try {
                final authNotifier = ref.read(authNotifierProvider.notifier);
                await authNotifier.checkCurrentUser();

                // final authState = ref.watch(authNotifierProvider);

                if (!context.mounted) return;
                final authState=ref.watch(authNotifierProvider);
                //
                // if (authState.isAuthenticated) {
                //   context.go(AppRoutes.landingPath);
                // } else {
                //   context.go(AppRoutes.loginPath);
                // }
                authState.whenOrNull(
                  authenticated: (_)=>context.go(AppRoutes.landingPath),
                    loading: () => context.go(AppRoutes.loadingPath),
                  unauthenticated: ()=>context.go(AppRoutes.loginPath),
                  error: (e){
                    context.go(AppRoutes.loginPath);
                  }
                );
              } catch (e) {
                log('Error during splash check: $e');
                if(context.mounted)context.go(AppRoutes.loginPath);
              }
            });
          }
      ),
    );
  }
}