import '../services/api_service.dart';
import '../models/user.dart';
import 'dart:convert';

class UserService {
  final ApiService _apiService = ApiService();

  // ==================== جلب المستخدمين (Admin) ====================

  Future<List<User>> getUsers() async {
    try {
      final response = await _apiService.get('/Users', requiresAuth: true);
      
      if (response['success'] == true) {
        final dataObject = response['data'];
        final List<dynamic> usersData = dataObject['data'] ?? [];
        
        return usersData.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception(response['message'] ?? 'Failed to load users');
      }
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }

  Future<List<User>> searchUsers(String query) async {
    try {
      final response = await _apiService.get(
        '/Users',
        queryParams: {'search': query},
        requiresAuth: true,
      );
      
      if (response['success'] == true) {
        final dataObject = response['data'];
        final List<dynamic> usersData = dataObject['data'] ?? [];
        return usersData.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception(response['message'] ?? 'No users found');
      }
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  Future<User?> getUserById(int id) async {
    try {
      final response = await _apiService.get('/Users/$id', requiresAuth: true);
      
      if (response['success'] == true) {
        return User.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'User not found');
      }
    } catch (e) {
      throw Exception('Failed to load user: $e');
    }
  }

  // ==================== الملف الشخصي (Profile) ====================

  /// جلب المستخدم الحالي
  Future<User> getCurrentUser() async {
    try {
      final response = await _apiService.get('/Users/profile', requiresAuth: true);
      
      if (response['success'] == true) {
        return User.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Failed to load profile');
      }
    } catch (e) {
      throw Exception('Failed to load profile: $e');
    }
  }

  /// تحديث الملف الشخصي للمستخدم الحالي
  Future<User> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put('/Users/profile', data, requiresAuth: true);
      
      if (response['success'] == true) {
        return User.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  /// تحديث مستخدم بواسطة Admin
  Future<User> updateUser(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put('/Users/$id', data, requiresAuth: true);
      
      if (response['success'] == true) {
        return User.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Failed to update user');
      }
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  /// تغيير كلمة المرور
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiService.put(
        '/Users/password',
        {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
        requiresAuth: true,
      );
      
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to change password');
      }
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  // ==================== تسجيل الخروج ====================

  /// تسجيل الخروج
  Future<void> logout() async {
    try {
      await _apiService.post('/Users/logout', {}, requiresAuth: true);
    } catch (e) {
      // تجاهل الخطأ أثناء تسجيل الخروج
      print('Logout error (ignored): $e');
    }
  }

  // ==================== إدارة المستخدمين (Admin) ====================

  Future<void> deleteUser(int id) async {
    try {
      final response = await _apiService.delete('/Users/$id', requiresAuth: true);
      
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to delete user');
      }
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  Future<bool> toggleUserStatus(int id, bool isActive) async {
    try {
      final response = await _apiService.patch(
        '/Users/$id/toggle-active',
        {'isActive': isActive},
        requiresAuth: true,
      );

      if (response['success'] == true) {
        final data = response['data'];
        if (data is bool) return data;
        return true;
      } else {
        throw Exception(response['message'] ?? 'Failed to update user status');
      }
    } catch (e) {
      throw Exception('Failed to update user status: $e');
    }
  }

  Future<User> changeUserRole(int id, String role) async {
    try {
      final roleToSend = role.toLowerCase(); 
      
      await _apiService.patch(
        '/Users/$id/change-role',
        roleToSend,
        requiresAuth: true,
      );

      final updatedUser = await getUserById(id);
      if (updatedUser == null) {
        throw Exception('User not found after role update');
      }
      return updatedUser;
    } catch (e) {
      throw Exception('Failed to change user role: $e');
    }
  }

  // ==================== المفضلات والتقييمات والإحصائيات ====================

  Future<List<dynamic>> getFavorites() async {
    try {
      final response = await _apiService.get('/Users/favorites', requiresAuth: true);
      
      if (response['success'] == true) {
        return response['data'] ?? [];
      } else {
        throw Exception(response['message'] ?? 'Failed to load favorites');
      }
    } catch (e) {
      throw Exception('Failed to load favorites: $e');
    }
  }

  Future<List<dynamic>> getUserRatings() async {
    try {
      final response = await _apiService.get('/Users/ratings', requiresAuth: true);
      
      if (response['success'] == true) {
        return response['data'] ?? [];
      } else {
        throw Exception(response['message'] ?? 'Failed to load ratings');
      }
    } catch (e) {
      throw Exception('Failed to load ratings: $e');
    }
  }

  Future<Map<String, dynamic>> getUserStats() async {
    try {
      final response = await _apiService.get('/Users/stats', requiresAuth: true);
      
      if (response['success'] == true) {
        return response['data'] ?? {};
      } else {
        throw Exception(response['message'] ?? 'Failed to load stats');
      }
    } catch (e) {
      throw Exception('Failed to load stats: $e');
    }
  }
}