import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/constants/app_colors.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController    = TextEditingController(text: 'testuser@pawfect.com');
  final _passwordController = TextEditingController(text: 'test@123');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text,
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/home');
    } else {
      final error = ref.read(authProvider).errorMessage ?? 'Invalid email or password.';
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
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(WidgetContext).size.height,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBackground : AppColors.background,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App Logo & Name
              const AppLogo(size: 80, fontSize: 32).animate().scale(duration: 400.ms, curve: Curves.easeOut),
              const SizedBox(height: 12),
              Text(
                'Welcome Back',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ).animate().fade(delay: 100.ms, duration: 400.ms),
              const SizedBox(height: 8),
              Text(
                'Adopt, don\'t shop. Sign in to continue.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ).animate().fade(delay: 200.ms, duration: 500.ms),
              const SizedBox(height: 40),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _emailController,
                      labelText: 'Email Address',
                      hintText: 'e.g., john@example.com',
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
                      controller: _passwordController,
                      labelText: 'Password',
                      hintText: 'Enter your password',
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
              ).animate().fade(delay: 300.ms, duration: 600.ms),
              
              const SizedBox(height: 32),

              // Login Button
              CustomButton(
                text: 'Sign In',
                onPressed: _login,
                isLoading: authState.status == AuthStatus.loading,
              ).animate().fade(delay: 400.ms, duration: 500.ms),
              
              const SizedBox(height: 24),

              // Sign Up Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'New to Pawfect? ',
                    style: theme.textTheme.bodyMedium,
                  ),
                  GestureDetector(
                    onTap: () => context.push('/register'),
                    child: Text(
                      'Create Account',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ).animate().fade(delay: 500.ms, duration: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
}
