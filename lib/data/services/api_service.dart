import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import 'storage_service.dart';

class ApiService {
  final Dio _dio;
  final StorageService _storageService;

  ApiService({required StorageService storageService})
      : _storageService = storageService,
        _dio = Dio(
          BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          // Wrap error message from backend if available
          String errorMessage = 'An unexpected error occurred.';
          if (error.response?.data != null && error.response?.data is Map) {
            final data = error.response?.data as Map;
            if (data.containsKey('error')) {
              errorMessage = data['error'].toString();
            }
          } else if (error.type == DioExceptionType.connectionTimeout) {
            errorMessage = 'Connection timeout. Please check your internet connection.';
          } else if (error.type == DioExceptionType.connectionError) {
            errorMessage = 'Unable to connect to the server. Is the backend running?';
          }

          final customException = Exception(errorMessage);
          return handler.next(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              type: error.type,
              error: customException,
              message: errorMessage,
            ),
          );
        },
      ),
    );
  }

  Dio get client => _dio;

  // HTTP Helper Methods

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.post(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.put(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<Response> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.delete(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw Exception(e.message);
    }
  }
}
