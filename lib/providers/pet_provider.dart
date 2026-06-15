import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/pet_model.dart';
import '../data/models/category_model.dart';
import 'service_providers.dart';

// Categories
final categoryListProvider = FutureProvider<List<CategoryModel>>((ref) async {
  return await ref.read(petRepositoryProvider).getCategories();
});

// Selected Category ID Filter (null means "All")
final selectedCategoryIdProvider = StateProvider<int?>((ref) => null);

// Search Query Filter
final searchQueryProvider = StateProvider<String>((ref) => '');

// Gender Filter (null means "All")
final selectedGenderProvider = StateProvider<String?>((ref) => null);

// Size Filter (null means "All")
final selectedSizeProvider = StateProvider<String?>((ref) => null);

// Pet List
final petListProvider = FutureProvider<List<PetModel>>((ref) async {
  final categoryId = ref.watch(selectedCategoryIdProvider);
  final search = ref.watch(searchQueryProvider);
  final gender = ref.watch(selectedGenderProvider);
  final size = ref.watch(selectedSizeProvider);

  return await ref.read(petRepositoryProvider).getPets(
        categoryId: categoryId,
        gender: gender,
        size: size,
        search: search,
      );
});

// Pet Details
final petDetailsProvider = FutureProvider.family<PetModel, int>((ref, id) async {
  return await ref.read(petRepositoryProvider).getPetDetails(id);
});

// My Listings (pets owned by the current user)
final myPetsProvider = FutureProvider<List<PetModel>>((ref) async {
  return await ref.read(petRepositoryProvider).getMyPets();
});
