import '../../core/constants/api_constants.dart';
import '../models/adoption_request_model.dart';
import '../services/api_service.dart';

class AdoptionRepository {
  final ApiService _apiService;

  AdoptionRepository({required ApiService apiService}) : _apiService = apiService;

  Future<List<AdoptionRequestModel>> getAdoptionRequests({required bool isReceived}) async {
    final response = await _apiService.get(
      ApiConstants.adoptions,
      queryParameters: {
        'type': isReceived ? 'received' : 'sent',
      },
    );
    final list = response.data as List;
    return list.map((item) => AdoptionRequestModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<AdoptionRequestModel> submitRequest({required int petId, String? message}) async {
    final response = await _apiService.post(
      ApiConstants.adoptions,
      data: {
        'pet_id': petId,
        if (message != null) 'message': message,
      },
    );
    return AdoptionRequestModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AdoptionRequestModel> updateRequestStatus({required int requestId, required String status}) async {
    final response = await _apiService.put(
      '${ApiConstants.adoptions}/$requestId',
      data: {
        'status': status,
      },
    );
    return AdoptionRequestModel.fromJson(response.data as Map<String, dynamic>);
  }
}
