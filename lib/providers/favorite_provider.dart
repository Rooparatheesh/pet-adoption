import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/pet_model.dart';
import 'service_providers.dart';
import 'auth_provider.dart';

class FavoriteNotifier extends StateNotifier<AsyncValue<List<PetModel>>> {
  final Ref _ref;

  FavoriteNotifier(this._ref) : super(const AsyncValue.loading()) {
    // Listen to Auth State changes to load or clear favorites
    _ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        loadFavorites();
      } else if (next.status == AuthStatus.unauthenticated) {
        state = const AsyncValue.data([]);
      }
    });

    // Initial load if already authenticated
    if (_ref.read(authProvider).status == AuthStatus.authenticated) {
      loadFavorites();
    }
  }

  Future<void> loadFavorites() async {
    state = const AsyncValue.loading();
    try {
      final list = await _ref.read(favoriteRepositoryProvider).getFavorites();
      state = AsyncValue.data(list);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> isFavorite(int petId) async {
    final list = state.value ?? [];
    return list.any((pet) => pet.id == petId);
  }

  Future<void> toggleFavorite(PetModel pet) async {
    final currentFavorites = state.value ?? [];
    final isFav = currentFavorites.any((item) => item.id == pet.id);

    // Optimistic UI update for premium instant feel
    if (isFav) {
      state = AsyncValue.data(currentFavorites.where((item) => item.id != pet.id).toList());
    } else {
      state = AsyncValue.data([...currentFavorites, pet]);
    }

    try {
      final favorited = await _ref.read(favoriteRepositoryProvider).toggleFavorite(pet.id);
      
      // Sync state with backend result just in case
      final updatedFavorites = state.value ?? [];
      final existsInState = updatedFavorites.any((item) => item.id == pet.id);

      if (favorited && !existsInState) {
        state = AsyncValue.data([...updatedFavorites, pet]);
      } else if (!favorited && existsInState) {
        state = AsyncValue.data(updatedFavorites.where((item) => item.id != pet.id).toList());
      }
    } catch (e) {
      // Revert on error
      if (isFav) {
        state = AsyncValue.data([...currentFavorites]);
      } else {
        state = AsyncValue.data(currentFavorites.where((item) => item.id != pet.id).toList());
      }
    }
  }
}

final favoriteProvider = StateNotifierProvider<FavoriteNotifier, AsyncValue<List<PetModel>>>((ref) {
  return FavoriteNotifier(ref);
});
