import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants/api_endpoints.dart';

class ApiService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  String _addLanguage(String url, String languageParam) {
    if (url.contains('?')) {
      return "$url&$languageParam";
    } else {
      return "$url?$languageParam";
    }
  }

  Future<Map<String, String>> _getHeaders({bool requiresAuth = true}) async {
    final headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
    };
    
    if (requiresAuth) {
      final token = await _getToken();
      if (token != null) {
        headers["Authorization"] = "Bearer $token";
      }
    }
    
    return headers;
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    bool requiresAuth = true,
    String language = 'ar',
  }) async {
    try {
      var url = "${ApiEndpoints.baseUrl}$endpoint";
      
      if (queryParams != null && queryParams.isNotEmpty) {
        final queryString = queryParams.entries
            .map((e) => "${e.key}=${e.value}")
            .join('&');
        url = "$url?$queryString";
      }
      
      url = _addLanguage(url, 'language=$language');
      
      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(requiresAuth: requiresAuth),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw ApiException(message: "Network error: $e", statusCode: 0);
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data, {
    bool requiresAuth = true,
    String language = 'ar',
  }) async {
    try {
      var url = "${ApiEndpoints.baseUrl}$endpoint";
      url = _addLanguage(url, 'language=$language');
      
      final response = await http.post(
        Uri.parse(url),
        headers: await _getHeaders(requiresAuth: requiresAuth),
        body: jsonEncode(data),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw ApiException(message: "Network error: $e", statusCode: 0);
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data, {
    bool requiresAuth = true,
    String language = 'ar',
  }) async {
    try {
      var url = "${ApiEndpoints.baseUrl}$endpoint";
      url = _addLanguage(url, 'language=$language');
      
      final response = await http.put(
        Uri.parse(url),
        headers: await _getHeaders(requiresAuth: requiresAuth),
        body: jsonEncode(data),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw ApiException(message: "Network error: $e", statusCode: 0);
    }
  }

  Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool requiresAuth = true,
    String language = 'ar',
  }) async {
    try {
      var url = "${ApiEndpoints.baseUrl}$endpoint";
      url = _addLanguage(url, 'language=$language');
      
      final response = await http.delete(
        Uri.parse(url),
        headers: await _getHeaders(requiresAuth: requiresAuth),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw ApiException(message: "Network error: $e", statusCode: 0);
    }
  }

  Future<Map<String, dynamic>> patch(
    String endpoint,
    dynamic data, {
    bool requiresAuth = true,
    String language = 'ar',
  }) async {
    try {
      var url = "${ApiEndpoints.baseUrl}$endpoint";
      url = _addLanguage(url, 'language=$language');

      final response = await http.patch(
        Uri.parse(url),
        headers: await _getHeaders(requiresAuth: requiresAuth),
        body: data is String ? data : jsonEncode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      throw ApiException(message: "Network error: $e", statusCode: 0);
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final Map<String, dynamic> data = jsonDecode(response.body);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }
    
    if (response.statusCode == 400) {
      final message = data['message'] ?? 'بيانات غير صحيحة';
      throw ApiException(
        message: message,
        statusCode: 400,
        type: ApiErrorType.badRequest,
      );
    }
    
    if (response.statusCode == 401) {
      final message = data['message'] ?? 'غير مصرح';
      _handleUnauthorized();
      throw ApiException(
        message: message,
        statusCode: 401,
        type: ApiErrorType.unauthorized,
      );
    }
    
    if (response.statusCode == 403) {
      final message = data['message'] ?? 'غير مسموح بالوصول';
      throw ApiException(
        message: message,
        statusCode: 403,
        type: ApiErrorType.forbidden,
      );
    }
    
    if (response.statusCode == 404) {
      final message = data['message'] ?? 'لم يتم العثور على المورد';
      throw ApiException(
        message: message,
        statusCode: 404,
        type: ApiErrorType.notFound,
      );
    }
    
    if (response.statusCode >= 500) {
      final message = data['message'] ?? 'حدث خطأ في الخادم';
      throw ApiException(
        message: message,
        statusCode: response.statusCode,
        type: ApiErrorType.serverError,
      );
    }
    
    final message = data['message'] ?? 'حدث خطأ غير متوقع';
    throw ApiException(
      message: message,
      statusCode: response.statusCode,
      type: ApiErrorType.unknown,
    );
  }

  Future<void> _handleUnauthorized() async {
    await _storage.deleteAll();
  }
}

enum ApiErrorType {
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  serverError,
  unknown,
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final ApiErrorType type;
  
  ApiException({
    required this.message,
    required this.statusCode,
    this.type = ApiErrorType.unknown,
  });
  
  @override
  String toString() => message;
}