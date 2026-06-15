import '../../core/constants/api_constants.dart';
import '../models/pet_model.dart';
import '../models/category_model.dart';
import '../services/api_service.dart';

class PetRepository {
  final ApiService _apiService;

  PetRepository({required ApiService apiService}) : _apiService = apiService;

  Future<List<CategoryModel>> getCategories() async {
    final response = await _apiService.get(ApiConstants.categories);
    final list = response.data as List;
    return list.map((item) => CategoryModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<List<PetModel>> getPets({
    int? categoryId,
    String? gender,
    String? size,
    String? search,
  }) async {
    final queryParameters = <String, dynamic>{
      if (categoryId != null) 'category_id': categoryId.toString(),
      if (gender != null) 'gender': gender,
      if (size != null) 'size': size,
      if (search != null && search.isNotEmpty) 'search': search,
    };

    final response = await _apiService.get(
      ApiConstants.pets,
      queryParameters: queryParameters,
    );

    final list = response.data as List;
    return list.map((item) => PetModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<PetModel> getPetDetails(int id) async {
    final response = await _apiService.get('${ApiConstants.pets}/$id');
    return PetModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<PetModel>> getMyPets() async {
    final response = await _apiService.get(ApiConstants.myPets);
    final list = response.data as List;
    return list.map((item) => PetModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<PetModel> createPet({
    required String name,
    required String breed,
    required int age, // in months
    required String gender,
    required String size,
    String? description,
    String? imageUrl,
    required String location,
    required int categoryId,
  }) async {
    final response = await _apiService.post(
      ApiConstants.pets,
      data: {
        'name': name,
        'breed': breed,
        'age': age,
        'gender': gender,
        'size': size,
        if (description != null) 'description': description,
        if (imageUrl != null) 'image_url': imageUrl,
        'location': location,
        'category_id': categoryId,
      },
    );

    return PetModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<PetModel> updatePet(
    int id, {
    String? name,
    String? breed,
    int? age,
    String? gender,
    String? size,
    String? description,
    String? imageUrl,
    String? location,
    int? categoryId,
    bool? isAdopted,
  }) async {
    final response = await _apiService.put(
      '${ApiConstants.pets}/$id',
      data: {
        if (name != null) 'name': name,
        if (breed != null) 'breed': breed,
        if (age != null) 'age': age,
        if (gender != null) 'gender': gender,
        if (size != null) 'size': size,
        if (description != null) 'description': description,
        if (imageUrl != null) 'image_url': imageUrl,
        if (location != null) 'location': location,
        if (categoryId != null) 'category_id': categoryId,
        if (isAdopted != null) 'is_adopted': isAdopted,
      },
    );

    return PetModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deletePet(int id) async {
    await _apiService.delete('${ApiConstants.pets}/$id');
  }
}
