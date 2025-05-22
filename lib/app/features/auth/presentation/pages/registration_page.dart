import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/widgets/custom_button.dart';
import '../providers/auth_notifier_provider.dart';

class RegistrationPage extends ConsumerStatefulWidget {
  const RegistrationPage({super.key});

  @override
  ConsumerState<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends ConsumerState<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.maybeMap(
      loading: (_) => true,
      orElse: () => false,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: Navigator.of(context).pop,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),

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

                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                isLoading
                    ? Center(child: Text('Creating Account...'))
                    : CustomButton(
                      text: 'Create Account',
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ref
                              .read(authNotifierProvider.notifier)
                              .signUpWithEmail(
                                _emailController.text.trim(),
                                _passwordController.text.trim(),
                              )
                              .then((_) {
                                final authState = ref.read(
                                  authNotifierProvider,
                                );
                                if (context.mounted) {
                                  if (authState.maybeMap(
                                    authenticated: (_) => true,
                                    orElse: () => false,
                                  )) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Registration successful!',
                                        ),
                                      ),
                                    );
                                   context.go('/login');
                                  } else if (authState.maybeMap(
                                    error: (error) => true,
                                    orElse: () => false,
                                  )) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          authState.maybeMap(
                                            error: (error) => error.message,
                                            orElse: () => 'Registration failed',
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                }
                              });
                        }
                      },
                    ),

                // ✅ Show loading or error UI conditionally
                authState.map(
                  loading:
                      (_) => const Center(child: CircularProgressIndicator()),
                  error:
                      (e) => Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          e.message,
                          style: TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  authenticated: (_) => const SizedBox(),
                  unauthenticated: (_) => const SizedBox(),
                  initial: (_) => const SizedBox(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
