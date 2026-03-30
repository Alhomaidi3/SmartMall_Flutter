// lib/models/api_response.dart

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int statusCode;
  
  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    required this.statusCode,
  });
  
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJson,
  ) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? fromJson(json['data']) : null,
      statusCode: json['statusCode'] ?? 200,
    );
  }
  
  factory ApiResponse.fromListJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJson,
  ) {
    final List<dynamic> list = json['data']?['data'] ?? [];
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: list.map((e) => fromJson(e)).toList() as T?,
      statusCode: json['statusCode'] ?? 200,
    );
  }
}