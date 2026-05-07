// lib/services/category_service.dart

import '../services/api_service.dart';
import '../models/category.dart';
import 'package:flutter/foundation.dart' hide Category;

class CategoryService {
  final ApiService _apiService = ApiService();

  Future<List<Category>> getCategories({String language = 'ar'}) async {
    try {
      final response = await _apiService.get(
        '/categories',
        requiresAuth: false,
        language: language,
      );

      if (response['success'] == true) {
        final List<dynamic> categoriesData = response['data'];
        return categoriesData.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception(response['message'] ?? 'Failed to load categories');
      }
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  Future<Category?> getCategoryById(int id, {String language = 'ar'}) async {
    try {
      final response = await _apiService.get(
        '/categories/$id',
        requiresAuth: false,
        language: language,
      );

      if (response['success'] == true) {
        return Category.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Category not found');
      }
    } catch (e) {
      throw Exception('Failed to load category: $e');
    }
  }

  Future<List<Category>> searchCategories(String query, {String language = 'ar'}) async {
    if (query.length < 2) {
      throw Exception('أدخل كلمة بحث من حرفين على الأقل');
    }

    try {
      final response = await _apiService.get(
        '/categories/search',
        queryParams: {'q': query},
        requiresAuth: false,
        language: language,
      );

      if (response['success'] == true) {
        final List<dynamic> categoriesData = response['data'];
        return categoriesData.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception(response['message'] ?? 'No categories found');
      }
    } catch (e) {
      throw Exception('Failed to search categories: $e');
    }
  }

  Future<Category> createCategory(CategoryCreateDto dto) async {
    try {
      final response = await _apiService.post(
        '/categories',
        dto.toJson(),
        requiresAuth: true,
      );

      if (response['success'] == true) {
        final allCategories = await getCategories();
        
        final newCategory = allCategories.firstWhere(
          (cat) => cat.nameAr == dto.nameAr && cat.nameEn == dto.nameEn,
          orElse: () => throw Exception('لم يتم العثور على الفئة المضافة'),
        );
        
        return newCategory;
      } else {
        throw Exception(response['message'] ?? 'فشل في إنشاء الفئة');
      }
    } catch (e) {
      debugPrint('Error creating category: $e');
      throw Exception('فشل في إنشاء الفئة: $e');
    }
  }

  Future<void> updateCategory(int id, CategoryUpdateDto dto) async {
    try {
      final response = await _apiService.put(
        '/categories/$id',
        dto.toJson(),
        requiresAuth: true,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to update category');
      }
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      final response = await _apiService.delete(
        '/categories/$id',
        requiresAuth: true,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to delete category');
      }
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  Future<List<Category>> getAllCategoriesForAdmin({String language = 'ar'}) async {
    try {
      final response = await _apiService.get(
        '/categories/all',
        requiresAuth: true,
        language: language,
      );

      if (response['success'] == true) {
        final List<dynamic> categoriesData = response['data'];
        return categoriesData.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception(response['message'] ?? 'Failed to load categories');
      }
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  Future<List<Category>> getActiveCategories({String language = 'ar'}) async {
    try {
      final response = await _apiService.get(
        '/categories',
        requiresAuth: false,
        language: language,
      );

      if (response['success'] == true) {
        final List<dynamic> categoriesData = response['data'];
        return categoriesData.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception(response['message'] ?? 'Failed to load categories');
      }
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }
}