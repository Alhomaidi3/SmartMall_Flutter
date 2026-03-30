// lib/models/store.dart

class Store {
  final int id;
  final String nameAr;
  final String nameEn;
  final String descriptionAr;
  final String descriptionEn;
  final int floor;
  final String openHours;
  final String phone;
  final String? website;
  final String imageUrl;
  final int categoryId;
  final String categoryNameAr;
  final String categoryNameEn;
  final double x;
  final double y;
  final bool isFavorite;
  final double averageRating;
  final int ratingsCount;
  final int? userRating;
  
  Store({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.floor,
    required this.openHours,
    required this.phone,
    this.website,
    required this.imageUrl,
    required this.categoryId,
    required this.categoryNameAr,
    required this.categoryNameEn,
    required this.x,
    required this.y,
    required this.isFavorite,
    required this.averageRating,
    required this.ratingsCount,
    this.userRating,
  });
  
  // 🔹 تحويل من JSON إلى كائن Store
  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'],
      nameAr: json['nameAr'] ?? '',
      nameEn: json['nameEn'] ?? '',
      descriptionAr: json['descriptionAr'] ?? '',
      descriptionEn: json['descriptionEn'] ?? '',
      floor: json['floor'] ?? 0,
      openHours: json['openHours'] ?? '',
      phone: json['phone'] ?? '',
      website: json['website'],
      imageUrl: json['imageUrl'] ?? '',
      categoryId: json['categoryId'] ?? 0,
      categoryNameAr: json['categoryNameAr'] ?? '',
      categoryNameEn: json['categoryNameEn'] ?? '',
      x: (json['x'] ?? 0).toDouble(),
      y: (json['y'] ?? 0).toDouble(),
      isFavorite: json['isFavorite'] ?? false,
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      ratingsCount: json['ratingsCount'] ?? 0,
      userRating: json['userRating'],
    );
  }
  
  // 🔹 دالة مساعدة: جلب الاسم حسب اللغة
  String getName(String languageCode) {
    return languageCode == 'ar' ? nameAr : nameEn;
  }
  
  // 🔹 دالة مساعدة: جلب الوصف حسب اللغة
  String getDescription(String languageCode) {
    return languageCode == 'ar' ? descriptionAr : descriptionEn;
  }
  
  // 🔹 دالة مساعدة: جلب اسم الفئة حسب اللغة
  String getCategoryName(String languageCode) {
    return languageCode == 'ar' ? categoryNameAr : categoryNameEn;
  }
}