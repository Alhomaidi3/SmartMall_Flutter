// lib/core/api_endpoints.dart
class ApiEndpoints {
  static const String baseUrl = "http://localhost:5252/api";
  
  static const String login = "/users/login";
  static const String register = "/users/register";
  static const String stores = "/stores";
  static const String categories = "/categories";
  static const String favorites = "/favorites";
  static const String ratings = "/ratings";
  
  static const String adminUsers = "/admin/users";
  static const String adminStores = "/admin/stores";
  static const String adminCategories = "/admin/categories";
  static const String analytics = "/admin/analytics";
}