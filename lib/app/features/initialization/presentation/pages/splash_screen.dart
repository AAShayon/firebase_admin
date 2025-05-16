import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/firebase_provider.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CircularProgressIndicator();//do for the animated splash screen
  }

  Widget _getNextScreen() {
    final user = FirebaseProvider.auth.currentUser;
    return user != null ? const DashboardPage() : const LoginPage();
  }
}