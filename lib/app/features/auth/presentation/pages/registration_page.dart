import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

                CustomButton(
                  text: 'Create Account',
                  icon: authState.maybeMap(
                    loading: (_) => SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                    ),
                    orElse: () => null,
                  ),
                  onPressed: authState.maybeWhen(
                    orElse: () => () async {
                      if (_formKey.currentState!.validate()) {
                        await ref.read(authNotifierProvider.notifier).signUpWithEmail(
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                        );

                        if (context.mounted &&
                            authState.maybeMap(
                              authenticated: (_) => true,
                              orElse: () => false,
                            )) {
                          Navigator.pop(context);
                        }
                      }
                    },
                    loading: () => () {}, // Disabled when loading
                  ),
                ),

                // ✅ Show loading or error UI conditionally
                authState.map(
                  loading: (_) => const Center(child: CircularProgressIndicator()),
                  error: (e) => Padding(
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