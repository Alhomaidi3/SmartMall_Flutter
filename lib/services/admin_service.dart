// lib/services/admin_service.dart

import '../services/api_service.dart';
import 'package:flutter/material.dart';

class AdminService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> getDashboardStats({required String period}) async {
    try {
      final response = await _apiService.get(
        '/admin/dashboard/stats',
        queryParams: {'period': period},
        requiresAuth: true,
      );

      if (response['success'] == true) {
        return response['data'] ?? {};
      }
      throw Exception(response['message'] ?? 'Failed to load stats');
    } catch (e) {
      throw Exception('Failed to load dashboard stats: $e');
    }
  }

  Future<List<ActivityItem>> getRecentActivities({int limit = 10}) async {
    try {
      final response = await _apiService.get(
        '/admin/activities',
        queryParams: {'limit': limit.toString()},
        requiresAuth: true,
      );

      if (response['success'] == true) {
        final List<dynamic> activities = response['data'] ?? [];
        return activities.map((json) => ActivityItem.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}

// ✅ تعريف ActivityItem
class ActivityItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;

  ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    // تحويل اسم الأيقونة من String إلى IconData
    IconData _getIcon(String iconName) {
      switch (iconName) {
        case 'add_business':
          return Icons.add_business;
        case 'person_add':
          return Icons.person_add;
        case 'rate_review':
          return Icons.rate_review;
        case 'edit':
          return Icons.edit;
        case 'store':
          return Icons.store;
        case 'delete':
          return Icons.delete;
        default:
          return Icons.notifications;
      }
    }

    // تحويل اسم اللون من String إلى Color
    Color _getColor(String colorName) {
      switch (colorName.toLowerCase()) {
        case 'blue':
          return Colors.blue;
        case 'green':
          return Colors.green;
        case 'orange':
          return Colors.orange;
        case 'purple':
          return Colors.purple;
        case 'red':
          return Colors.red;
        case 'yellow':
          return Colors.yellow;
        default:
          return Colors.grey;
      }
    }

    return ActivityItem(
      icon: _getIcon(json['icon'] ?? 'notifications'),
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      time: json['time'] ?? '',
      color: _getColor(json['color'] ?? 'grey'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'icon': icon.toString(),
      'title': title,
      'subtitle': subtitle,
      'time': time,
      'color': color.toString(),
    };
  }
}