import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthRepository {
  final ApiService _apiService;
  final StorageService _storageService;

  AuthRepository({
    required ApiService apiService,
    required StorageService storageService,
  })  : _apiService = apiService,
        _storageService = storageService;

  Future<UserModel> login(String email, String password) async {
    final response = await _apiService.post(
      ApiConstants.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    final token = response.data['token'] as String;
    await _storageService.saveToken(token);

    return UserModel.fromJson(response.data['user'] as Map<String, dynamic>);
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? avatarUrl,
  }) async {
    final response = await _apiService.post(
      ApiConstants.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
        if (phone != null) 'phone': phone,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      },
    );

    final token = response.data['token'] as String;
    await _storageService.saveToken(token);

    return UserModel.fromJson(response.data['user'] as Map<String, dynamic>);
  }

  Future<UserModel> getProfile() async {
    final response = await _apiService.get(ApiConstants.profile);
    return UserModel.fromJson(response.data['user'] as Map<String, dynamic>);
  }

  Future<UserModel> updateProfile({
    String? name,
    String? phone,
    String? avatarUrl,
    String? password,
  }) async {
    final response = await _apiService.put(
      ApiConstants.profile,
      data: {
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        if (password != null) 'password': password,
      },
    );

    return UserModel.fromJson(response.data['user'] as Map<String, dynamic>);
  }

  Future<void> logout() async {
    await _storageService.deleteToken();
  }
}
