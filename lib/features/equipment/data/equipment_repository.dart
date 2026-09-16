import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../domain/category_model.dart';
import '../domain/equipment_model.dart';

/// Repository managing database operations for public.equipment, equipment_images, and categories.
class EquipmentRepository {
  final SupabaseClient _client;
  final StorageService _storageService;

  EquipmentRepository({
    SupabaseClient? client,
    StorageService? storageService,
  })  : _client = client ?? SupabaseService.client,
        _storageService = storageService ?? StorageService();

  /// Fetches equipment categories from public.categories table.
  Future<List<CategoryModel>> getCategories() async {
    try {
      final data = await _client
          .from('categories')
          .select()
          .eq('category_type', 'equipment')
          .eq('is_active', true)
          .order('display_order', ascending: true);

      return (data as List)
          .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      debugPrint('[EquipmentRepository] getCategories error: $e\n$stackTrace');
      return [];
    }
  }

  /// Inserts a new equipment listing with approval_status = 'pending' (Pending Review).
  Future<EquipmentModel> createEquipment({
    required String ownerId,
    required String name,
    required double dailyPrice,
    String? categoryId,
    String? brand,
    String? model,
    String? description,
    double? weeklyPrice,
    String? condition,
    String? accessories,
    String city = 'Cairo',
    String? area,
    List<XFile> imageFiles = const [],
  }) async {
    try {
      final insertData = <String, dynamic>{
        'owner_id': ownerId,
        'name': name.trim(),
        'daily_price': dailyPrice,
        'city': city,
        'approval_status': 'pending', // Requires admin approval to become public
        'availability_status': 'available_now',
      };

      if (categoryId != null && categoryId.isNotEmpty) insertData['category_id'] = categoryId;
      if (brand != null && brand.trim().isNotEmpty) insertData['brand'] = brand.trim();
      if (model != null && model.trim().isNotEmpty) insertData['model'] = model.trim();
      if (description != null && description.trim().isNotEmpty) insertData['description'] = description.trim();
      if (weeklyPrice != null && weeklyPrice > 0) insertData['weekly_price'] = weeklyPrice;
      if (condition != null && condition.trim().isNotEmpty) insertData['condition'] = condition.trim();
      if (accessories != null && accessories.trim().isNotEmpty) insertData['accessories'] = accessories.trim();
      if (area != null && area.trim().isNotEmpty) insertData['area'] = area.trim();

      // Insert equipment row
      final equipmentData = await _client
          .from('equipment')
          .insert(insertData)
          .select()
          .single();

      final createdEquipmentId = equipmentData['id'] as String;

      // Upload photos and insert image rows
      if (imageFiles.isNotEmpty) {
        for (int i = 0; i < imageFiles.length; i++) {
          try {
            final imageUrl = await _storageService.uploadEquipmentPhoto(
              userId: ownerId,
              equipmentId: createdEquipmentId,
              file: imageFiles[i],
              index: i,
            );

            await _client.from('equipment_images').insert({
              'equipment_id': createdEquipmentId,
              'image_url': imageUrl,
              'display_order': i,
              'is_primary': i == 0,
            });
          } catch (imgErr) {
            debugPrint('[EquipmentRepository] Image upload error for image $i: $imgErr');
          }
        }
      }

      // Re-fetch created equipment with images and relations
      final fullData = await getEquipmentById(createdEquipmentId);
      return fullData ?? EquipmentModel.fromJson(equipmentData);
    } catch (e, stackTrace) {
      debugPrint('[EquipmentRepository] createEquipment error: $e\n$stackTrace');
      rethrow;
    }
  }

  /// Fetches all equipment belonging to [ownerId] regardless of approval status.
  Future<List<EquipmentModel>> getMyEquipment(String ownerId) async {
    try {
      final data = await _client
          .from('equipment')
          .select('*, equipment_images(*), categories(*)')
          .eq('owner_id', ownerId)
          .order('created_at', ascending: false);

      return (data as List)
          .map((item) => EquipmentModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      debugPrint('[EquipmentRepository] getMyEquipment error: $e\n$stackTrace');
      return [];
    }
  }

  /// Fetches public approved equipment only (approval_status = 'approved').
  Future<List<EquipmentModel>> getPublicApprovedEquipment({
    String? categoryId,
    String? categoryName,
    String? searchQuery,
    String? city,
  }) async {
    try {
      var query = _client
          .from('equipment')
          .select('*, equipment_images(*), categories(*), profiles(*)')
          .eq('approval_status', 'approved');

      if (categoryId != null && categoryId.isNotEmpty) {
        query = query.eq('category_id', categoryId);
      }

      if (city != null && city.trim().isNotEmpty && city != 'All' && city != 'All Locations' && city != 'جميع المدن') {
        final cityTerm = city.trim();
        query = query.ilike('city', '%$cityTerm%');
      }

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final term = '%${searchQuery.trim()}%';
        query = query.or('name.ilike.$term,brand.ilike.$term,model.ilike.$term,description.ilike.$term');
      }

      final data = await query.order('created_at', ascending: false);

      List<EquipmentModel> list = (data as List)
          .map((item) => EquipmentModel.fromJson(item as Map<String, dynamic>))
          .toList();

      // Filter by categoryName if localized category string passed from UI
      if (categoryName != null &&
          categoryName.isNotEmpty &&
          categoryName.toLowerCase() != 'all' &&
          categoryName != 'الكل') {
        list = list.where((item) {
          if (item.category == null) return false;
          return item.category!.nameEn.toLowerCase() == categoryName.toLowerCase() ||
              item.category!.nameAr == categoryName;
        }).toList();
      }

      return list;
    } catch (e, stackTrace) {
      debugPrint('[EquipmentRepository] getPublicApprovedEquipment error: $e\n$stackTrace');
      return [];
    }
  }

  /// Fetches single equipment listing details by [id].
  Future<EquipmentModel?> getEquipmentById(String id) async {
    try {
      final data = await _client
          .from('equipment')
          .select('*, equipment_images(*), categories(*), profiles(*)')
          .eq('id', id)
          .maybeSingle();

      if (data == null) return null;

      final itemMap = Map<String, dynamic>.from(data);

      if (itemMap['profiles'] == null && itemMap['owner_id'] != null) {
        try {
          final profileData = await _client
              .from('profiles')
              .select()
              .eq('id', itemMap['owner_id'])
              .maybeSingle();
          if (profileData != null) {
            itemMap['profiles'] = profileData;
          }
        } catch (profErr) {
          debugPrint('[EquipmentRepository] Manual profile fetch error: $profErr');
        }
      }

      return EquipmentModel.fromJson(itemMap);
    } catch (e, stackTrace) {
      debugPrint('[EquipmentRepository] getEquipmentById error: $e\n$stackTrace');
      return null;
    }
  }

  /// Updates an existing equipment listing owned by [ownerId].
  /// Sets approval_status = 'pending' automatically for re-approval.
  Future<EquipmentModel> updateEquipment({
    required String equipmentId,
    required String ownerId,
    required String name,
    required double dailyPrice,
    String? categoryId,
    String? brand,
    String? model,
    String? description,
    double? weeklyPrice,
    String? condition,
    String? accessories,
    String city = 'Cairo',
    String? area,
    List<XFile> newImageFiles = const [],
    List<String> existingImageUrls = const [],
  }) async {
    try {
      final updateData = <String, dynamic>{
        'name': name.trim(),
        'daily_price': dailyPrice,
        'city': city,
        'approval_status': 'pending', // Re-approval requirement
        'updated_at': DateTime.now().toIso8601String(),
      };

      updateData['category_id'] = (categoryId != null && categoryId.isNotEmpty) ? categoryId : null;
      updateData['brand'] = (brand != null && brand.trim().isNotEmpty) ? brand.trim() : null;
      updateData['model'] = (model != null && model.trim().isNotEmpty) ? model.trim() : null;
      updateData['description'] = (description != null && description.trim().isNotEmpty) ? description.trim() : null;
      updateData['weekly_price'] = (weeklyPrice != null && weeklyPrice > 0) ? weeklyPrice : null;
      updateData['condition'] = (condition != null && condition.trim().isNotEmpty) ? condition.trim() : null;
      updateData['accessories'] = (accessories != null && accessories.trim().isNotEmpty) ? accessories.trim() : null;
      updateData['area'] = (area != null && area.trim().isNotEmpty) ? area.trim() : null;

      // Update equipment record, matching equipment_id AND owner_id
      await _client
          .from('equipment')
          .update(updateData)
          .eq('id', equipmentId)
          .eq('owner_id', ownerId);

      // Clean up deleted existing photos if any were removed
      try {
        final currentDbImages = await _client
            .from('equipment_images')
            .select('id, image_url')
            .eq('equipment_id', equipmentId);

        for (final img in (currentDbImages as List)) {
          final url = img['image_url'] as String;
          if (!existingImageUrls.contains(url)) {
            await _client.from('equipment_images').delete().eq('id', img['id']);
          }
        }
      } catch (cleanErr) {
        debugPrint('[EquipmentRepository] Error cleaning removed images: $cleanErr');
      }

      // Upload and insert any newly added photos
      if (newImageFiles.isNotEmpty) {
        final startOrder = existingImageUrls.length;
        for (int i = 0; i < newImageFiles.length; i++) {
          try {
            final imageUrl = await _storageService.uploadEquipmentPhoto(
              userId: ownerId,
              equipmentId: equipmentId,
              file: newImageFiles[i],
              index: startOrder + i,
            );

            await _client.from('equipment_images').insert({
              'equipment_id': equipmentId,
              'image_url': imageUrl,
              'display_order': startOrder + i,
              'is_primary': (startOrder == 0 && i == 0),
            });
          } catch (imgErr) {
            debugPrint('[EquipmentRepository] Image upload error for edit image $i: $imgErr');
          }
        }
      }

      // Re-fetch updated equipment record
      final updated = await getEquipmentById(equipmentId);
      if (updated == null) {
        throw Exception('Failed to load updated equipment details');
      }
      return updated;
    } catch (e, stackTrace) {
      debugPrint('[EquipmentRepository] updateEquipment error: $e\n$stackTrace');
      rethrow;
    }
  }
}
