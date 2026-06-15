import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_model.dart';
import 'service_providers.dart';

enum AuthStatus { uninitialized, loading, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  factory AuthState.initial() => AuthState(status: AuthStatus.uninitialized);
  factory AuthState.loading() => AuthState(status: AuthStatus.loading);
  factory AuthState.authenticated(UserModel user) => AuthState(status: AuthStatus.authenticated, user: user);
  factory AuthState.unauthenticated({String? error}) => AuthState(status: AuthStatus.unauthenticated, errorMessage: error);

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(AuthState.initial()) {
    checkAuth();
  }

  Future<void> checkAuth() async {
    state = AuthState.loading();
    try {
      final storage = _ref.read(storageServiceProvider);
      final hasToken = await storage.hasToken();
      if (!hasToken) {
        state = AuthState.unauthenticated();
        return;
      }
      
      final user = await _ref.read(authRepositoryProvider).getProfile();
      state = AuthState.authenticated(user);
    } catch (e) {
      // If token is invalid or server is down
      state = AuthState.unauthenticated(error: e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<bool> login(String email, String password) async {
    state = AuthState.loading();
    try {
      final user = await _ref.read(authRepositoryProvider).login(email, password);
      state = AuthState.authenticated(user);
      return true;
    } catch (e) {
      state = AuthState.unauthenticated(error: e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? avatarUrl,
  }) async {
    state = AuthState.loading();
    try {
      final user = await _ref.read(authRepositoryProvider).register(
            name: name,
            email: email,
            password: password,
            phone: phone,
            avatarUrl: avatarUrl,
          );
      // Auto-login after registration — token is already saved by the repository
      state = AuthState.authenticated(user);
      return true;
    } catch (e) {
      state = AuthState.unauthenticated(error: e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? avatarUrl,
    String? password,
  }) async {
    if (state.user == null) return false;
    
    // Temporarily set status to loading, but keep the current user data
    final previousUser = state.user!;
    state = state.copyWith(status: AuthStatus.loading);
    
    try {
      final updatedUser = await _ref.read(authRepositoryProvider).updateProfile(
            name: name,
            phone: phone,
            avatarUrl: avatarUrl,
            password: password,
          );
      state = AuthState.authenticated(updatedUser);
      return true;
    } catch (e) {
      // Revert back with error
      state = AuthState(
        status: AuthStatus.authenticated,
        user: previousUser,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = AuthState.loading();
    await _ref.read(authRepositoryProvider).logout();
    state = AuthState.unauthenticated();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
