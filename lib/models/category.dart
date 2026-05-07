// lib/models/category.dart
class Category {
  final int id;
  final String nameAr;
  final String nameEn;
  final bool isActive;
  final int storesCount;

  Category({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.isActive,
    required this.storesCount,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      nameAr: json['nameAr'] ?? '',
      nameEn: json['nameEn'] ?? '',
      isActive: json['isActive'] ?? true,
      storesCount: json['storesCount'] ?? 0,
    );
  }

  String getName(String languageCode) {
    return languageCode == 'ar' ? nameAr : nameEn;
  }

  Map<String, dynamic> toJson() {
    return {
      'nameAr': nameAr,
      'nameEn': nameEn,
    };
  }
}

class CategoryCreateDto {
  final String nameAr;
  final String nameEn;
  final String? iconUrl;

  CategoryCreateDto({
    required this.nameAr,
    required this.nameEn,
    this.iconUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'nameAr': nameAr,
      'nameEn': nameEn,
      'iconUrl': iconUrl,
    };
  }
}

class CategoryUpdateDto {
  final String? nameAr;
  final String? nameEn;
  final String? iconUrl;
  final bool? isActive;

  CategoryUpdateDto({
    this.nameAr,
    this.nameEn,
    this.iconUrl,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      if (nameAr != null) 'nameAr': nameAr,
      if (nameEn != null) 'nameEn': nameEn,
      if (iconUrl != null) 'iconUrl': iconUrl,
      if (isActive != null) 'isActive': isActive,
    };
  }
}