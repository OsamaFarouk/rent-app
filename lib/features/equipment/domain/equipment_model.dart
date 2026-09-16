import '../../profile/domain/profile_model.dart';
import 'category_model.dart';
import 'equipment_image_model.dart';

/// Domain model representing an equipment listing in public.equipment table.
class EquipmentModel {
  final String id;
  final String ownerId;
  final String? categoryId;
  final String name;
  final String? brand;
  final String? model;
  final String? description;
  final double dailyPrice;
  final double? weeklyPrice;
  final String pricingType; // 'per_day'
  final String? condition; // e.g. 'Like New', 'Excellent', 'Good'
  final String? accessories;
  final String city;
  final String? area;
  final String availabilityStatus; // 'available_now', 'available_tomorrow', 'busy', 'unavailable'
  final String approvalStatus; // 'pending', 'approved', 'rejected', 'suspended'
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Joined relational data
  final List<EquipmentImageModel> images;
  final CategoryModel? category;
  final ProfileModel? ownerProfile;

  const EquipmentModel({
    required this.id,
    required this.ownerId,
    this.categoryId,
    required this.name,
    this.brand,
    this.model,
    this.description,
    required this.dailyPrice,
    this.weeklyPrice,
    this.pricingType = 'per_day',
    this.condition,
    this.accessories,
    this.city = 'Cairo',
    this.area,
    this.availabilityStatus = 'available_now',
    this.approvalStatus = 'pending',
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.images = const [],
    this.category,
    this.ownerProfile,
  });

  bool get isApproved => approvalStatus == 'approved';
  bool get isPending => approvalStatus == 'pending';
  bool get isRejected => approvalStatus == 'rejected';
  bool get isSuspended => approvalStatus == 'suspended';

  String? get primaryImageUrl {
    if (images.isEmpty) return null;
    final primary = images.firstWhere(
      (img) => img.isPrimary,
      orElse: () => images.first,
    );
    return primary.imageUrl;
  }

  String get formattedLocation {
    if (area != null && area!.isNotEmpty) {
      return '$city, $area';
    }
    return city;
  }

  factory EquipmentModel.fromJson(Map<String, dynamic> json) {
    List<EquipmentImageModel> loadedImages = [];
    if (json['equipment_images'] != null) {
      final imgList = json['equipment_images'] as List;
      loadedImages = imgList
          .map((item) => EquipmentImageModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    CategoryModel? loadedCategory;
    if (json['categories'] != null) {
      loadedCategory = CategoryModel.fromJson(json['categories'] as Map<String, dynamic>);
    }

    ProfileModel? loadedOwner;
    if (json['profiles'] != null) {
      loadedOwner = ProfileModel.fromJson(json['profiles'] as Map<String, dynamic>);
    }

    return EquipmentModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String? ?? '',
      categoryId: json['category_id'] as String?,
      name: json['name'] as String? ?? 'Equipment',
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      description: json['description'] as String?,
      dailyPrice: (json['daily_price'] as num?)?.toDouble() ?? 0.0,
      weeklyPrice: (json['weekly_price'] as num?)?.toDouble(),
      pricingType: json['pricing_type'] as String? ?? 'per_day',
      condition: json['condition'] as String?,
      accessories: json['accessories'] as String?,
      city: json['city'] as String? ?? 'Cairo',
      area: json['area'] as String?,
      availabilityStatus: json['availability_status'] as String? ?? 'available_now',
      approvalStatus: json['approval_status'] as String? ?? 'pending',
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      images: loadedImages,
      category: loadedCategory,
      ownerProfile: loadedOwner,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'category_id': categoryId,
      'name': name,
      'brand': brand,
      'model': model,
      'description': description,
      'daily_price': dailyPrice,
      'weekly_price': weeklyPrice,
      'pricing_type': pricingType,
      'condition': condition,
      'accessories': accessories,
      'city': city,
      'area': area,
      'availability_status': availabilityStatus,
      'approval_status': approvalStatus,
    };
  }
}
