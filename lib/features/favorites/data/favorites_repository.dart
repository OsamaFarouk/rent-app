import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';
import '../../equipment/domain/equipment_model.dart';
import '../../profile/domain/business_profile_model.dart';
import '../../profile/domain/profile_model.dart';

/// Repository managing database operations for public.favorites table.
class FavoritesRepository {
  final SupabaseClient _client;

  FavoritesRepository({SupabaseClient? client})
      : _client = client ?? SupabaseService.client;

  /// Checks if a specific target is favorited by [userId].
  Future<bool> isFavorite({
    required String userId,
    required String targetId,
    String targetType = 'equipment',
  }) async {
    try {
      final data = await _client
          .from('favorites')
          .select('id')
          .eq('user_id', userId)
          .eq('target_type', targetType)
          .eq('target_id', targetId)
          .maybeSingle();

      return data != null;
    } catch (e, stackTrace) {
      debugPrint('[FavoritesRepository] isFavorite error: $e\n$stackTrace');
      return false;
    }
  }

  /// Fetches set of favorited target IDs for [userId] and [targetType].
  Future<Set<String>> getFavoriteTargetIds({
    required String userId,
    String targetType = 'equipment',
  }) async {
    try {
      final data = await _client
          .from('favorites')
          .select('target_id')
          .eq('user_id', userId)
          .eq('target_type', targetType);

      return (data as List)
          .map((row) => row['target_id'] as String)
          .toSet();
    } catch (e, stackTrace) {
      debugPrint('[FavoritesRepository] getFavoriteTargetIds error: $e\n$stackTrace');
      return {};
    }
  }

  /// Fetches full EquipmentModel details for all favorited equipment of [userId].
  Future<List<EquipmentModel>> getFavoriteEquipment({
    required String userId,
  }) async {
    try {
      final favData = await _client
          .from('favorites')
          .select('target_id')
          .eq('user_id', userId)
          .eq('target_type', 'equipment')
          .order('created_at', ascending: false);

      final ids = (favData as List)
          .map((row) => row['target_id'] as String)
          .toList();

      if (ids.isEmpty) return [];

      final equipData = await _client
          .from('equipment')
          .select('*, equipment_images(*), categories(*), profiles(*)')
          .inFilter('id', ids);

      final items = (equipData as List)
          .map((item) => EquipmentModel.fromJson(item as Map<String, dynamic>))
          .toList();

      // Sort items matching favorited order (newest favorite first)
      items.sort((a, b) {
        final indexA = ids.indexOf(a.id);
        final indexB = ids.indexOf(b.id);
        if (indexA == -1) return 1;
        if (indexB == -1) return -1;
        return indexA.compareTo(indexB);
      });

      return items;
    } catch (e, stackTrace) {
      debugPrint('[FavoritesRepository] getFavoriteEquipment error: $e\n$stackTrace');
      return [];
    }
  }

  /// Fetches full ProfileModel details for all favorited professionals of [userId].
  Future<List<ProfileModel>> getFavoriteProfessionals({
    required String userId,
  }) async {
    try {
      final favData = await _client
          .from('favorites')
          .select('target_id')
          .eq('user_id', userId)
          .eq('target_type', 'professional')
          .order('created_at', ascending: false);

      final ids = (favData as List)
          .map((row) => row['target_id'] as String)
          .toList();

      if (ids.isEmpty) return [];

      final profileData = await _client
          .from('profiles')
          .select('*')
          .inFilter('id', ids);

      final items = (profileData as List)
          .map((item) => ProfileModel.fromJson(item as Map<String, dynamic>))
          .toList();

      items.sort((a, b) {
        final indexA = ids.indexOf(a.id);
        final indexB = ids.indexOf(b.id);
        if (indexA == -1) return 1;
        if (indexB == -1) return -1;
        return indexA.compareTo(indexB);
      });

      return items;
    } catch (e, stackTrace) {
      debugPrint('[FavoritesRepository] getFavoriteProfessionals error: $e\n$stackTrace');
      return [];
    }
  }

  /// Fetches full BusinessProfileModel details for all favorited businesses/rental houses of [userId].
  Future<List<BusinessProfileModel>> getFavoriteBusinesses({
    required String userId,
  }) async {
    try {
      final favData = await _client
          .from('favorites')
          .select('target_id')
          .eq('user_id', userId)
          .eq('target_type', 'business')
          .order('created_at', ascending: false);

      final ids = (favData as List)
          .map((row) => row['target_id'] as String)
          .toList();

      if (ids.isEmpty) return [];

      final businessData = await _client
          .from('business_profiles')
          .select('*')
          .inFilter('id', ids);

      final items = (businessData as List)
          .map((item) => BusinessProfileModel.fromJson(item as Map<String, dynamic>))
          .toList();

      items.sort((a, b) {
        final indexA = ids.indexOf(a.id);
        final indexB = ids.indexOf(b.id);
        if (indexA == -1) return 1;
        if (indexB == -1) return -1;
        return indexA.compareTo(indexB);
      });

      return items;
    } catch (e, stackTrace) {
      debugPrint('[FavoritesRepository] getFavoriteBusinesses error: $e\n$stackTrace');
      return [];
    }
  }

  /// Adds target item to user's favorites.
  Future<void> addFavorite({
    required String userId,
    required String targetId,
    String targetType = 'equipment',
  }) async {
    try {
      await _client.from('favorites').insert({
        'user_id': userId,
        'target_type': targetType,
        'target_id': targetId,
      });
    } on PostgrestException catch (e) {
      // Ignore duplicate record errors (PostgreSQL 23505 unique constraint)
      if (e.code == '23505') {
        debugPrint('[FavoritesRepository] Unique constraint duplicate favorite ignored: ${e.message}');
        return;
      }
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('[FavoritesRepository] addFavorite error: $e\n$stackTrace');
      rethrow;
    }
  }

  /// Removes target item from user's favorites.
  Future<void> removeFavorite({
    required String userId,
    required String targetId,
    String targetType = 'equipment',
  }) async {
    try {
      await _client
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('target_type', targetType)
          .eq('target_id', targetId);
    } catch (e, stackTrace) {
      debugPrint('[FavoritesRepository] removeFavorite error: $e\n$stackTrace');
      rethrow;
    }
  }
}

