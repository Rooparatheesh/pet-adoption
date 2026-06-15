import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/constants/app_colors.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController    = TextEditingController(text: 'Test User');
  final _emailController   = TextEditingController(text: 'testuser@pawfect.com');
  final _phoneController   = TextEditingController(text: '+91 9876543210');
  final _passwordController = TextEditingController(text: 'test@123');

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          // No default avatar — user can add one from Profile settings
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Welcome! Registration successful!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/home');  // Auto-login → go straight to home
    } else {
      final error = ref.read(authProvider).errorMessage ?? 'Registration failed.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext WidgetContext) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(WidgetContext);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppLogo(size: 70, fontSize: 26).animate().scale(duration: 400.ms, curve: Curves.easeOut),
              const SizedBox(height: 24),
              Text(
                'Create Account',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ).animate().fade(duration: 400.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: 8),
              Text(
                'Start listing and adopting cute companions!',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ).animate().fade(delay: 100.ms, duration: 400.ms),
              const SizedBox(height: 32),

              // Form fields
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _nameController,
                      labelText: 'Full Name',
                      hintText: 'e.g., Jane Doe',
                      prefixIcon: Icons.person_outline,
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Name is required.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _emailController,
                      labelText: 'Email Address',
                      hintText: 'e.g., jane@example.com',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Email is required.';
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
                          return 'Enter a valid email address.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _phoneController,
                      labelText: 'Phone Number (Optional)',
                      hintText: 'e.g., +1 555-0199',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _passwordController,
                      labelText: 'Password',
                      hintText: 'At least 6 characters',
                      prefixIcon: Icons.lock_outlined,
                      isPassword: true,
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Password is required.';
                        if (val.length < 6) return 'Password must be at least 6 characters.';
                        return null;
                      },
                    ),
                  ],
                ),
              ).animate().fade(delay: 200.ms, duration: 500.ms),

              const SizedBox(height: 32),

              // Register Button
              CustomButton(
                text: 'Sign Up',
                onPressed: _register,
                isLoading: authState.status == AuthStatus.loading,
              ).animate().fade(delay: 300.ms, duration: 500.ms),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
