import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:firebase_admin/app/config/widgets/custom_button.dart';
import 'package:firebase_admin/app/config/widgets/divider_with_text.dart';
import 'package:firebase_admin/app/core/utils/custom_size_space.dart';
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

    // Navigate after frame completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authState.maybeWhen(
        authenticated: (_) => context.goNamed('dashboard'),
        orElse: () {},
      );
    });

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

                  // ✅ Login Button using CustomButton
                  CustomButton(
                    text: 'Login',
                    icon: authState.maybeMap(
                      loading: (_) => const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                      orElse: () => null,
                    ),
                    onPressed: authState.maybeWhen(
                      orElse: () => () {
                        if (_formKey.currentState!.validate()) {
                          ref.read(authNotifierProvider.notifier).signInWithEmail(
                            _emailController.text.trim(),
                            _passwordController.text.trim(),
                          );
                        }
                      },
                      loading: () => () {}, // Disabled when loading
                    ),
                  ),

                  CustomSizeSpace.vMedium16,
                  const DividerWithText(text: 'Or'),
                  CustomSizeSpace.vSmall8,

                  CustomButton(
                    text: 'Sign in with Google',
                    icon: Image.asset('assets/images/google.png', height: 20),
                    onPressed: authState.maybeWhen(
                      orElse: () => () {
                        ref.read(authNotifierProvider.notifier).signInWithGoogle();
                      },
                      loading: () => () {}, // Disabled when loading
                    ),
                  ),

                  TextButton(
                    onPressed: authState.maybeWhen(
                      orElse: () => () => context.goNamed('register'),
                      loading: () => null,
                    ),
                    child: const Text('Create an account'),
                  ),

                  authState.maybeMap(
                    loading: (_) => const Center(child: CircularProgressIndicator()),
                    error: (e) => Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        e.message,
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    orElse: () => const SizedBox(),
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