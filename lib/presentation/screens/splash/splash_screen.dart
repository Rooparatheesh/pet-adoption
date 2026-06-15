import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/constants/app_colors.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkRedirect();
  }

  void _checkRedirect() async {
    // Wait for the animation to play slightly
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authState = ref.read(authProvider);

    if (authState.status == AuthStatus.authenticated) {
      context.go('/home');
    } else if (authState.status == AuthStatus.unauthenticated) {
      context.go('/login');
    } else {
      // If still loading or uninitialized, listen to status changes
      ref.listenManual<AuthState>(authProvider, (previous, next) {
        if (!mounted) return;
        if (next.status == AuthStatus.authenticated) {
          context.go('/home');
        } else if (next.status == AuthStatus.unauthenticated) {
          context.go('/login');
        }
      });
    }
  }

  @override
  Widget build(BuildContext WidgetContext) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Beautiful animated branding
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.pets,
                  size: 80,
                  color: Colors.white,
                ),
              )
                  .animate()
                  .fade(duration: 600.ms)
                  .scale(duration: 600.ms, curve: Curves.bounceOut),
              const SizedBox(height: 24),
              const Text(
                'Pawfect',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Outfit',
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ).animate().fade(delay: 300.ms, duration: 600.ms).slideY(begin: 0.3, end: 0),
              const SizedBox(height: 8),
              const Text(
                'Find your new best friend today',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ).animate().fade(delay: 500.ms, duration: 600.ms),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
