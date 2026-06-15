import '../../core/constants/api_constants.dart';
import '../models/pet_model.dart';
import '../services/api_service.dart';

class FavoriteRepository {
  final ApiService _apiService;

  FavoriteRepository({required ApiService apiService}) : _apiService = apiService;

  Future<List<PetModel>> getFavorites() async {
    final response = await _apiService.get(ApiConstants.favorites);
    final list = response.data as List;
    return list.map((item) => PetModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  // Returns true if now favorited, false if now unfavorited
  Future<bool> toggleFavorite(int petId) async {
    final response = await _apiService.post('${ApiConstants.favorites}/$petId');
    return response.data['favorited'] as bool;
  }
}
