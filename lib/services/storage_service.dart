// lib/services/storage_service.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class StorageService {
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // 🔹 تخزين التوكن
  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }
  
  // 🔹 جلب التوكن
  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
  
  // 🔹 حذف التوكن (تسجيل خروج)
  static Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }
  
  // 🔹 تخزين بيانات المستخدم
  static Future<void> saveUser(Map<String, dynamic> user) async {
    await _storage.write(key: 'user_data', value: jsonEncode(user));
  }
  
  // 🔹 جلب بيانات المستخدم
  static Future<Map<String, dynamic>?> getUser() async {
    final data = await _storage.read(key: 'user_data');
    if (data != null) {
      return jsonDecode(data);
    }
    return null;
  }
  
  // 🔹 حذف بيانات المستخدم
  static Future<void> deleteUser() async {
    await _storage.delete(key: 'user_data');
  }
  
  // 🔹 مسح كل شيء (تسجيل خروج كامل)
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}