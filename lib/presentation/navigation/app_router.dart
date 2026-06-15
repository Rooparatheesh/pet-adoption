import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/main_scaffold.dart';
import '../screens/pet_detail/pet_detail_screen.dart';
import '../screens/pet_add/pet_add_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Watch auth state to trigger redirect check automatically when it changes
  final auth = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final status = auth.status;
      final path = state.uri.path;

      // While initializing auth, stay on splash screen
      if (status == AuthStatus.uninitialized) return null;

      final isAuthScreen = path == '/login' || path == '/register';

      if (status == AuthStatus.unauthenticated) {
        // Allow access to auth screens, otherwise redirect to login
        return isAuthScreen || path == '/' ? null : '/login';
      }

      if (status == AuthStatus.authenticated) {
        // If logged in, block auth screens and redirect to home
        return isAuthScreen || path == '/' ? '/home' : null;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainScaffold(initialIndex: 0),
      ),
      GoRoute(
        path: '/pet/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return PetDetailScreen(petId: id);
        },
      ),
      GoRoute(
        path: '/add-pet',
        builder: (context, state) => const PetAddScreen(),
      ),
    ],
  );
});
