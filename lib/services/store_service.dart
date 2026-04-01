// lib/services/store_service.dart
import '../services/api_service.dart';
import '../models/store.dart';

class StoreService {
  final ApiService _apiService = ApiService();

  // 🔹 جلب جميع المتاجر (مقسمة)
  Future<PagedResponse<StoreDto>> getStores({
    int page = 1,
    int pageSize = 20,
    String? category,
    int? floor,
    String language = 'ar',
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'pageSize': pageSize.toString(),
        'language': language,
        if (category != null && category.isNotEmpty) 'category': category,
        if (floor != null) 'floor': floor.toString(),
      };

      final response = await _apiService.get(
        '/stores',
        queryParams: queryParams,
        requiresAuth: false,
      );

      if (response['success'] == true) {
        return PagedResponse.fromJson(
          response['data'],
          (json) => StoreDto.fromJson(json),
        );
      } else {
        throw Exception(response['message'] ?? 'فشل في تحميل المتاجر');
      }
    } catch (e) {
      throw Exception('فشل في تحميل المتاجر: $e');
    }
  }
Future<PagedResponse<StoreDto>> getAllStoresForAdmin({
  int page = 1,
  int pageSize = 20,
  String? category,
  int? floor,
  String language = 'ar',
}) async {
  try {
    final queryParams = {
      'page': page.toString(),
      'pageSize': pageSize.toString(),
      'language': language,
      if (category != null && category.isNotEmpty) 'category': category,
      if (floor != null) 'floor': floor.toString(),
    };

    final response = await _apiService.get(
      '/stores/all',  // ✅ هذا الـ endpoint الجديد للمشرف
      queryParams: queryParams,
      requiresAuth: true,  // ✅ يتطلب توكن المشرف
    );

    if (response['success'] == true) {
      return PagedResponse.fromJson(
        response['data'],
        (json) => StoreDto.fromJson(json),
      );
    } else {
      throw Exception(response['message'] ?? 'فشل في تحميل المتاجر');
    }
  } catch (e) {
    throw Exception('فشل في تحميل المتاجر: $e');
  }
}

  // 🔹 جلب تفاصيل متجر واحد
  Future<StoreDetailsDto> getStoreById(int id, {String language = 'ar'}) async {
    try {
      final response = await _apiService.get(
        '/stores/$id',
        queryParams: {'language': language},
        requiresAuth: false,
      );

      if (response['success'] == true) {
        return StoreDetailsDto.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'المتجر غير موجود');
      }
    } catch (e) {
      throw Exception('فشل في تحميل تفاصيل المتجر: $e');
    }
  }

  // 🔹 البحث في المتاجر
Future<List<StoreDto>> searchStores(
  String query, {
  String language = 'ar',
}) async {
  if (query.length < 2) {
    throw Exception('أدخل كلمة بحث من حرفين على الأقل');
  }

  try {
    final response = await _apiService.get(
      '/stores/search',
      queryParams: {
        'q': query,
        'language': language,
      },
      requiresAuth: false,
    );

    if (response['success'] == true) {
      // ✅ التصحيح: response['data'] هي List وليس Map
      final List<dynamic> storesData = response['data'];
      return storesData.map((json) => StoreDto.fromJson(json)).toList();
    } else {
      throw Exception(response['message'] ?? 'لا توجد نتائج');
    }
  } catch (e) {
    throw Exception('فشل في البحث: $e');
  }
}

  // 🔹 جلب المتاجر حسب الطابق
  Future<List<StoreDto>> getStoresByFloor(int floor, {String language = 'ar'}) async {
    try {
      final response = await _apiService.get(
        '/stores/floor/$floor',
        queryParams: {'language': language},
        requiresAuth: false,
      );

      if (response['success'] == true) {
        final List<dynamic> storesData = response['data'];
        return storesData.map((json) => StoreDto.fromJson(json)).toList();
      } else {
        throw Exception(response['message'] ?? 'فشل في تحميل المتاجر');
      }
    } catch (e) {
      throw Exception('فشل في تحميل المتاجر حسب الطابق: $e');
    }
  }

  // 🔹 جلب المتاجر المميزة
  Future<List<StoreDto>> getFeaturedStores({
    int limit = 10,
    String language = 'ar',
  }) async {
    try {
      final response = await _apiService.get(
        '/stores/featured',
        queryParams: {
          'limit': limit.toString(),
          'language': language,
        },
        requiresAuth: false,
      );

      if (response['success'] == true) {
        final List<dynamic> storesData = response['data'];
        return storesData.map((json) => StoreDto.fromJson(json)).toList();
      } else {
        throw Exception(response['message'] ?? 'فشل في تحميل المتاجر المميزة');
      }
    } catch (e) {
      throw Exception('فشل في تحميل المتاجر المميزة: $e');
    }
  }

  // 🔹 جلب المتاجر حسب التصنيف
  Future<PagedResponse<StoreDto>> getStoresByCategory(
    int categoryId, {
    int page = 1,
    int pageSize = 20,
    String language = 'ar',
  }) async {
    try {
      final response = await _apiService.get(
        '/stores/category/$categoryId',
        queryParams: {
          'page': page.toString(),
          'pageSize': pageSize.toString(),
          'language': language,
        },
        requiresAuth: false,
      );

      if (response['success'] == true) {
        return PagedResponse.fromJson(
          response['data'],
          (json) => StoreDto.fromJson(json),
        );
      } else {
        throw Exception(response['message'] ?? 'فشل في تحميل المتاجر');
      }
    } catch (e) {
      throw Exception('فشل في تحميل المتاجر حسب التصنيف: $e');
    }
  }

  // 🔹 إنشاء متجر جديد (للمشرف فقط)
  Future<StoreDetailsDto> createStore(StoreCreateDto dto) async {
    try {
      final response = await _apiService.post(
        '/stores',
        dto.toJson(),
        requiresAuth: true,
      );

      if (response['success'] == true) {
        // بعد الإنشاء، نجلب تفاصيل المتجر
        final storeId = response['data']['id'] ?? response['data']['storeId'];
        return await getStoreById(storeId);
      } else {
        throw Exception(response['message'] ?? 'فشل في إنشاء المتجر');
      }
    } catch (e) {
      throw Exception('فشل في إنشاء المتجر: $e');
    }
  }

  // 🔹 تحديث متجر (للمشرف فقط)
  Future<void> updateStore(int id, StoreUpdateDto dto) async {
    try {
      final response = await _apiService.put(
        '/stores/$id',
        dto.toJson(),
        requiresAuth: true,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'فشل في تحديث المتجر');
      }
    } catch (e) {
      throw Exception('فشل في تحديث المتجر: $e');
    }
  }

  // 🔹 حذف متجر (للمشرف فقط) - Soft Delete
  Future<void> deleteStore(int id) async {
    try {
      final response = await _apiService.delete(
        '/stores/$id',
        requiresAuth: true,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'فشل في حذف المتجر');
      }
    } catch (e) {
      throw Exception('فشل في حذف المتجر: $e');
    }
  }

  // 🔹 إضافة متجر إلى المفضلة
  Future<void> addToFavorites(int storeId) async {
    try {
      final response = await _apiService.post(
        '/stores/$storeId/favorite',
        {},
        requiresAuth: true,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'فشل في إضافة إلى المفضلة');
      }
    } catch (e) {
      throw Exception('فشل في إضافة إلى المفضلة: $e');
    }
  }

  // 🔹 إزالة متجر من المفضلة
  Future<void> removeFromFavorites(int storeId) async {
    try {
      final response = await _apiService.delete(
        '/stores/$storeId/favorite',
        requiresAuth: true,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'فشل في إزالة من المفضلة');
      }
    } catch (e) {
      throw Exception('فشل في إزالة من المفضلة: $e');
    }
  }

  // 🔹 جلب المتاجر المفضلة للمستخدم
  Future<List<StoreDto>> getFavoriteStores({String language = 'ar'}) async {
    try {
      final response = await _apiService.get(
        '/stores/favorites',
        queryParams: {'language': language},
        requiresAuth: true,
      );

      if (response['success'] == true) {
        final List<dynamic> storesData = response['data'];
        return storesData.map((json) => StoreDto.fromJson(json)).toList();
      } else {
        throw Exception(response['message'] ?? 'فشل في تحميل المتاجر المفضلة');
      }
    } catch (e) {
      throw Exception('فشل في تحميل المتاجر المفضلة: $e');
    }
  }

  // 🔹 إضافة تقييم لمتجر
  Future<void> rateStore(int storeId, int rating, {String? comment}) async {
    if (rating < 1 || rating > 5) {
      throw Exception('التقييم يجب أن يكون بين 1 و 5');
    }

    try {
      final response = await _apiService.post(
        '/stores/$storeId/rating',
        {
          'rating': rating,
          if (comment != null) 'comment': comment,
        },
        requiresAuth: true,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'فشل في إضافة التقييم');
      }
    } catch (e) {
      throw Exception('فشل في إضافة التقييم: $e');
    }
  }

  // 🔹 جلب المتاجر القريبة (حسب الموقع)
  Future<List<StoreDto>> getNearbyStores({
    required double x,
    required double y,
    double radius = 100.0, // متر
    int limit = 20,
    String language = 'ar',
  }) async {
    try {
      final response = await _apiService.get(
        '/stores/nearby',
        queryParams: {
          'x': x.toString(),
          'y': y.toString(),
          'radius': radius.toString(),
          'limit': limit.toString(),
          'language': language,
        },
        requiresAuth: false,
      );

      if (response['success'] == true) {
        final List<dynamic> storesData = response['data'];
        return storesData.map((json) => StoreDto.fromJson(json)).toList();
      } else {
        throw Exception(response['message'] ?? 'فشل في تحميل المتاجر القريبة');
      }
    } catch (e) {
      throw Exception('فشل في تحميل المتاجر القريبة: $e');
    }
  }
}