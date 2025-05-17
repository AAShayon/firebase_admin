import 'package:firebase_admin/app/config/widgets/custom_button.dart';
import 'package:firebase_admin/app/config/widgets/divider_with_text.dart';
import 'package:firebase_admin/app/config/widgets/loading_screen.dart';
import 'package:firebase_admin/app/core/utils/custom_size_space.dart';
import 'package:firebase_admin/app/features/auth/presentation/pages/registration_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_notifier_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    // Show full-screen loading if isLoading
    if (authState.isLoading) {
      return const CustomLoadingScreen();
    }

    // Otherwise show normal login UI
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'assets/images/app_icon.png',
                    height: 100,
                    width: 100,
                  ),
                  CustomSizeSpace.vXL32,
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  CustomSizeSpace.vMedium16,
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  CustomSizeSpace.vMedium16,
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ref.read(authNotifierProvider.notifier).signInWithEmail(
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                        );
                      }
                    },
                    child: const Text('Login'),
                  ),
                  CustomSizeSpace.vMedium16,
                  const DividerWithText(text: 'Or'),
                  CustomSizeSpace.vSmall8,
                  CustomButton(
                    text: 'Sign in with Google',
                    icon: Image.asset('assets/images/google.png', height: 20),
                    onPressed: () =>
                        ref.read(authNotifierProvider.notifier).signInWithGoogle(),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegistrationPage(),
                        ),
                      );
                    },
                    child: const Text('Create an account'),
                  ),
                  if (authState.error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        authState.error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}