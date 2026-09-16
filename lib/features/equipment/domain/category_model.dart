/// Domain data model representing a category in public.categories table.
class CategoryModel {
  final String id;
  final String nameEn;
  final String nameAr;
  final String categoryType; // 'equipment' or 'professional'
  final String? iconName;
  final String? imageUrl;
  final int displayOrder;
  final bool isActive;

  const CategoryModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.categoryType,
    this.iconName,
    this.imageUrl,
    this.displayOrder = 0,
    this.isActive = true,
  });

  String getLocalizedName(String languageCode) {
    return languageCode == 'ar' ? nameAr : nameEn;
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      nameEn: json['name_en'] as String? ?? '',
      nameAr: json['name_ar'] as String? ?? '',
      categoryType: json['category_type'] as String? ?? 'equipment',
      iconName: json['icon_name'] as String?,
      imageUrl: json['image_url'] as String?,
      displayOrder: json['display_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_en': nameEn,
      'name_ar': nameAr,
      'category_type': categoryType,
      'icon_name': iconName,
      'image_url': imageUrl,
      'display_order': displayOrder,
      'is_active': isActive,
    };
  }
}
