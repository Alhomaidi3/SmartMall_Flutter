// lib/models/store.dart
class StoreImageDto {
  final int id;
  final int storeId;
  final String imageUrl;
  final int displayOrder;
  final bool isPrimary;

  StoreImageDto({
    required this.id,
    required this.storeId,
    required this.imageUrl,
    required this.displayOrder,
    required this.isPrimary,
  });

  factory StoreImageDto.fromJson(Map<String, dynamic> json) {
    return StoreImageDto(
      id: json['id'],
      storeId: json['storeId'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      displayOrder: json['displayOrder'] ?? 0,
      isPrimary: json['isPrimary'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storeId': storeId,
      'imageUrl': imageUrl,
      'displayOrder': displayOrder,
      'isPrimary': isPrimary,
    };
  }
}

class StoreDto {
  final int id;
  final String nameAr;
  final String nameEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final int floor;
  final String? openHours;
  final String? phone;
  final String? website;
  final String? imageUrl;
  final bool isActive;
  final int? categoryId;
  final String? categoryNameAr;
  final String? categoryNameEn;
  final int? locationId;
  final double? x;
  final double? y;
  bool isFavorite;
  int? userRating;
  double averageRating;
  int ratingsCount;

  StoreDto({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.descriptionAr,
    this.descriptionEn,
    required this.floor,
    this.openHours,
    this.phone,
    this.website,
    this.imageUrl,
    required this.isActive,
    this.categoryId,
    this.categoryNameAr,
    this.categoryNameEn,
    this.locationId,
    this.x,
    this.y,
    this.isFavorite = false,
    this.userRating,
    this.averageRating = 0.0,
    this.ratingsCount = 0,
  });

  factory StoreDto.fromJson(Map<String, dynamic> json) {
    return StoreDto(
      id: json['id'],
      nameAr: json['nameAr'] ?? '',
      nameEn: json['nameEn'] ?? '',
      descriptionAr: json['descriptionAr'],
      descriptionEn: json['descriptionEn'],
      floor: json['floor'] ?? 0,
      openHours: json['openHours'],
      phone: json['phone'],
      website: json['website'],
      imageUrl: json['imageUrl'],
      isActive: json['isActive'] ?? true,
      categoryId: json['categoryId'],
      categoryNameAr: json['categoryNameAr'],
      categoryNameEn: json['categoryNameEn'],
      locationId: json['locationId'],
      x: json['x']?.toDouble(),
      y: json['y']?.toDouble(),
      isFavorite: json['isFavorite'] ?? false,
      userRating: json['userRating'],
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      ratingsCount: json['ratingsCount'] ?? 0,
    );
  }

  String getName(String languageCode) {
    return languageCode == 'ar' ? nameAr : nameEn;
  }

  String? getDescription(String languageCode) {
    return languageCode == 'ar' ? descriptionAr : descriptionEn;
  }

  String? getCategoryName(String languageCode) {
    if (languageCode == 'ar') {
      return categoryNameAr;
    }
    return categoryNameEn;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'descriptionAr': descriptionAr,
      'descriptionEn': descriptionEn,
      'floor': floor,
      'openHours': openHours,
      'phone': phone,
      'website': website,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'categoryId': categoryId,
      'categoryNameAr': categoryNameAr,
      'categoryNameEn': categoryNameEn,
      'locationId': locationId,
      'x': x,
      'y': y,
      'isFavorite': isFavorite,
      'userRating': userRating,
      'averageRating': averageRating,
      'ratingsCount': ratingsCount,
    };
  }

  StoreDto copyWith({
    int? id,
    String? nameAr,
    String? nameEn,
    String? descriptionAr,
    String? descriptionEn,
    int? floor,
    String? openHours,
    String? phone,
    String? website,
    String? imageUrl,
    bool? isActive,
    int? categoryId,
    String? categoryNameAr,
    String? categoryNameEn,
    int? locationId,
    double? x,
    double? y,
    bool? isFavorite,
    int? userRating,
    double? averageRating,
    int? ratingsCount,
  }) {
    return StoreDto(
      id: id ?? this.id,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      floor: floor ?? this.floor,
      openHours: openHours ?? this.openHours,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      categoryId: categoryId ?? this.categoryId,
      categoryNameAr: categoryNameAr ?? this.categoryNameAr,
      categoryNameEn: categoryNameEn ?? this.categoryNameEn,
      locationId: locationId ?? this.locationId,
      x: x ?? this.x,
      y: y ?? this.y,
      isFavorite: isFavorite ?? this.isFavorite,
      userRating: userRating ?? this.userRating,
      averageRating: averageRating ?? this.averageRating,
      ratingsCount: ratingsCount ?? this.ratingsCount,
    );
  }
}

class StoreDetailsDto extends StoreDto {
  final String fullDescriptionAr;
  final String fullDescriptionEn;
  final List<StoreImageDto> images;

  StoreDetailsDto({
    required super.id,
    required super.nameAr,
    required super.nameEn,
    super.descriptionAr,
    super.descriptionEn,
    required super.floor,
    super.openHours,
    super.phone,
    super.website,
    super.imageUrl,
    required super.isActive,
    super.categoryId,
    super.categoryNameAr,
    super.categoryNameEn,
    super.locationId,
    super.x,
    super.y,
    super.isFavorite = false,
    super.userRating,
    super.averageRating = 0.0,
    super.ratingsCount = 0,
    required this.fullDescriptionAr,
    required this.fullDescriptionEn,
    required this.images,
  });

factory StoreDetailsDto.fromJson(Map<String, dynamic> json) {
  final baseStore = StoreDto.fromJson(json);
  
  return StoreDetailsDto(
    id: baseStore.id,
    nameAr: baseStore.nameAr,
    nameEn: baseStore.nameEn,
    descriptionAr: json['descriptionAr'] ?? baseStore.descriptionAr,
    descriptionEn: json['descriptionEn'] ?? baseStore.descriptionEn,
    floor: baseStore.floor,
    openHours: baseStore.openHours,
    phone: baseStore.phone,
    website: baseStore.website,
    imageUrl: baseStore.imageUrl,
    isActive: baseStore.isActive,
    categoryId: baseStore.categoryId,
    categoryNameAr: baseStore.categoryNameAr,
    categoryNameEn: baseStore.categoryNameEn,
    locationId: baseStore.locationId,
    x: baseStore.x,
    y: baseStore.y,
    isFavorite: baseStore.isFavorite,
    userRating: baseStore.userRating,
    averageRating: baseStore.averageRating,
    ratingsCount: baseStore.ratingsCount,
    fullDescriptionAr: json['fullDescriptionAr'] ?? json['descriptionAr'] ?? '',
    fullDescriptionEn: json['fullDescriptionEn'] ?? json['descriptionEn'] ?? '',
    images: (json['images'] as List?)
        ?.map((img) => StoreImageDto.fromJson(img))
        .toList() ?? [],
  );
}
  String getFullDescription(String languageCode) {
    return languageCode == 'ar' ? fullDescriptionAr : fullDescriptionEn;
  }

  @override
  StoreDetailsDto copyWith({
    int? id,
    String? nameAr,
    String? nameEn,
    String? descriptionAr,
    String? descriptionEn,
    int? floor,
    String? openHours,
    String? phone,
    String? website,
    String? imageUrl,
    bool? isActive,
    int? categoryId,
    String? categoryNameAr,
    String? categoryNameEn,
    int? locationId,
    double? x,
    double? y,
    bool? isFavorite,
    int? userRating,
    double? averageRating,
    int? ratingsCount,
    String? fullDescriptionAr,
    String? fullDescriptionEn,
    List<StoreImageDto>? images,
  }) {
    return StoreDetailsDto(
      id: id ?? this.id,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      floor: floor ?? this.floor,
      openHours: openHours ?? this.openHours,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      categoryId: categoryId ?? this.categoryId,
      categoryNameAr: categoryNameAr ?? this.categoryNameAr,
      categoryNameEn: categoryNameEn ?? this.categoryNameEn,
      locationId: locationId ?? this.locationId,
      x: x ?? this.x,
      y: y ?? this.y,
      isFavorite: isFavorite ?? this.isFavorite,
      userRating: userRating ?? this.userRating,
      averageRating: averageRating ?? this.averageRating,
      ratingsCount: ratingsCount ?? this.ratingsCount,
      fullDescriptionAr: fullDescriptionAr ?? this.fullDescriptionAr,
      fullDescriptionEn: fullDescriptionEn ?? this.fullDescriptionEn,
      images: images ?? this.images,
    );
  }
}

class StoreCreateDto {
  final String nameAr;
  final String nameEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final int floor;
  final String? openHours;
  final String? phone;
  final String? website;
  final String? imageUrl;
  final int? categoryId;
  final double? x;
  final double? y;

  StoreCreateDto({
    required this.nameAr,
    required this.nameEn,
    this.descriptionAr,
    this.descriptionEn,
    required this.floor,
    this.openHours,
    this.phone,
    this.website,
    this.imageUrl,
    this.categoryId,
    this.x,
    this.y,
  });

  Map<String, dynamic> toJson() {
    return {
      'nameAr': nameAr,
      'nameEn': nameEn,
      if (descriptionAr != null) 'descriptionAr': descriptionAr,
      if (descriptionEn != null) 'descriptionEn': descriptionEn,
      'floor': floor,
      if (openHours != null) 'openHours': openHours,
      if (phone != null) 'phone': phone,
      if (website != null) 'website': website,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (categoryId != null) 'categoryId': categoryId,
      if (x != null) 'x': x,
      if (y != null) 'y': y,
    };
  }
}

class StoreUpdateDto {
  final String? nameAr;
  final String? nameEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final int? floor;
  final String? openHours;
  final String? phone;
  final String? website;
  final String? imageUrl;
  final int? categoryId;
  final bool? isActive;

  StoreUpdateDto({
    this.nameAr,
    this.nameEn,
    this.descriptionAr,
    this.descriptionEn,
    this.floor,
    this.openHours,
    this.phone,
    this.website,
    this.imageUrl,
    this.categoryId,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      if (nameAr != null) 'nameAr': nameAr,
      if (nameEn != null) 'nameEn': nameEn,
      if (descriptionAr != null) 'descriptionAr': descriptionAr,
      if (descriptionEn != null) 'descriptionEn': descriptionEn,
      if (floor != null) 'floor': floor,
      if (openHours != null) 'openHours': openHours,
      if (phone != null) 'phone': phone,
      if (website != null) 'website': website,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (categoryId != null) 'categoryId': categoryId,
      if (isActive != null) 'isActive': isActive,
    };
  }
}

class PagedResponse<T> {
  final int page;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final bool hasPrevious;
  final bool hasNext;
  final List<T> data;

  PagedResponse({
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
    required this.hasPrevious,
    required this.hasNext,
    required this.data,
  });

  factory PagedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return PagedResponse(
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? 20,
      totalCount: json['totalCount'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      hasPrevious: json['hasPrevious'] ?? false,
      hasNext: json['hasNext'] ?? false,
      data: (json['data'] as List?)
              ?.map((item) => fromJson(item))
              .toList() ??
          [],
    );
  }
}