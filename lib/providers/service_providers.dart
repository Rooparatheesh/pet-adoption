import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/storage_service.dart';
import '../data/services/api_service.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/pet_repository.dart';
import '../data/repositories/favorite_repository.dart';
import '../data/repositories/adoption_repository.dart';

// Services
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final apiServiceProvider = Provider<ApiService>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return ApiService(storageService: storageService);
});

// Repositories
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  return AuthRepository(apiService: apiService, storageService: storageService);
});

final petRepositoryProvider = Provider<PetRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return PetRepository(apiService: apiService);
});

final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return FavoriteRepository(apiService: apiService);
});

final adoptionRepositoryProvider = Provider<AdoptionRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AdoptionRepository(apiService: apiService);
});
