/// Domain data model representing an equipment photo in public.equipment_images table.
class EquipmentImageModel {
  final String id;
  final String equipmentId;
  final String imageUrl;
  final int displayOrder;
  final bool isPrimary;
  final DateTime? createdAt;

  const EquipmentImageModel({
    required this.id,
    required this.equipmentId,
    required this.imageUrl,
    this.displayOrder = 0,
    this.isPrimary = false,
    this.createdAt,
  });

  factory EquipmentImageModel.fromJson(Map<String, dynamic> json) {
    return EquipmentImageModel(
      id: json['id'] as String,
      equipmentId: json['equipment_id'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      displayOrder: json['display_order'] as int? ?? 0,
      isPrimary: json['is_primary'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'equipment_id': equipmentId,
      'image_url': imageUrl,
      'display_order': displayOrder,
      'is_primary': isPrimary,
    };
  }
}
