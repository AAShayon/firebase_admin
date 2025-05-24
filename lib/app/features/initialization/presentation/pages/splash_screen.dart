import 'package:animated_splash_plus/animated_splash_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/widgets/loading_screen.dart';
import '../../../auth/presentation/providers/auth_notifier_provider.dart';
import '../../../auth/presentation/providers/auth_state.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger auth check immediately
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    final authNotifier = ref.read(authNotifierProvider.notifier);
    await authNotifier.checkCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    // Watch auth state changes
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      next.whenOrNull(
        authenticated: (_) => context.goNamed('homepage'),
        unauthenticated: () => context.goNamed('login'),
        error: (_) => context.goNamed('login'),
      );
    });

    return Scaffold(
      body: AnimatedSplashPlus(
        config:  SplashConfig(
          appName: 'Admin Dashboard',
          appNamePart1: 'Admin',
          appNamePart2: 'Dashboard',
          subtitle: 'Management Console',
          welcomeText: 'Loading...',
          sunsetDuration: Duration(seconds: 2),
          textAnimationDuration: Duration(seconds: 1),
          sunStartColor: Colors.blueAccent,
          sunEndColor: Colors.blue.shade900,
          skyEndBottomColor: Colors.blue,
          skyEndMiddleColor: Colors.lightBlue,
          skyEndTopColor: Colors.blue.shade800,
        ),
        // Let the router handle the navigation after splash
        onAnimationComplete: () {},
      ),
    );
  }
}

//  final splashAsync = ref.watch(splashProvider);
//     return splashAsync.when(
//       data: (user) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if (user != null ) {
//             context.goNamed('dashboard'); // Uses GoRouter
//           } else {
//             context.goNamed('login'); // Uses GoRouter
//           }
//         });
//
//         // This fallback will only show briefly
//         return const CustomLoadingScreen();
//       },
//     loading: () =>