import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';
import '../../equipment/domain/equipment_model.dart';
import '../domain/business_profile_model.dart';

/// Repository managing public business profiles and rental house discovery queries.
class BusinessRepository {
  final SupabaseClient _client;

  BusinessRepository({SupabaseClient? client})
      : _client = client ?? SupabaseService.client;

  /// Fetches all public, approved, active business profiles (Rental Houses).
  Future<List<BusinessProfileModel>> getApprovedBusinessProfiles({String? city}) async {
    try {
      var query = _client
          .from('business_profiles')
          .select()
          .eq('approval_status', 'approved')
          .eq('is_active', true);

      if (city != null && city.trim().isNotEmpty && city != 'All' && city != 'All Locations' && city != 'جميع المدن') {
        query = query.ilike('city', '%${city.trim()}%');
      }

      final response = await query.order('created_at', ascending: false);

      final list = response as List<dynamic>;
      return list
          .map((json) => BusinessProfileModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      debugPrint('[BusinessRepository] getApprovedBusinessProfiles error: $e\n$stackTrace');
      return [];
    }
  }

  /// Fetches a single business profile by [id].
  Future<BusinessProfileModel?> getBusinessProfileById(String id) async {
    try {
      final response = await _client
          .from('business_profiles')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return BusinessProfileModel.fromJson(response);
    } catch (e, stackTrace) {
      debugPrint('[BusinessRepository] getBusinessProfileById error: $e\n$stackTrace');
      return null;
    }
  }

  /// Fetches a single business profile by owner's [userId].
  Future<BusinessProfileModel?> getBusinessProfileByUserId(String userId) async {
    try {
      final response = await _client
          .from('business_profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;
      return BusinessProfileModel.fromJson(response);
    } catch (e, stackTrace) {
      debugPrint('[BusinessRepository] getBusinessProfileByUserId error: $e\n$stackTrace');
      return null;
    }
  }

  /// Upserts business profile details in public.business_profiles for a business account owner.
  Future<BusinessProfileModel> upsertBusinessProfile(BusinessProfileModel business) async {
    try {
      final payload = <String, dynamic>{
        'user_id': business.userId,
        'business_name': business.businessName,
        'business_address': business.businessAddress,
        'business_description': business.businessDescription,
        'logo_url': business.logoUrl,
        'phone': business.phone,
        'whatsapp': business.whatsapp,
        'email': business.email,
        'city': business.city,
        'area': business.area,
        'website_url': business.websiteUrl,
        'working_hours': business.workingHours,
        'approval_status': business.approvalStatus,
        'is_active': business.isActive,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .from('business_profiles')
          .upsert(payload, onConflict: 'user_id')
          .select()
          .single();

      return BusinessProfileModel.fromJson(response);
    } catch (e, stackTrace) {
      debugPrint('[BusinessRepository] upsertBusinessProfile error: $e\n$stackTrace');
      rethrow;
    }
  }

  /// Fetches approved equipment owned directly by a specific user [ownerId].
  Future<List<EquipmentModel>> getEquipmentByOwnerId(String ownerId) async {
    try {
      final response = await _client
          .from('equipment')
          .select('''
            *,
            equipment_images(*),
            categories(*),
            profiles:owner_id(*)
          ''')
          .eq('owner_id', ownerId)
          .eq('approval_status', 'approved')
          .order('created_at', ascending: false);

      final list = response as List<dynamic>;
      return list
          .map((json) => EquipmentModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      debugPrint('[BusinessRepository] getEquipmentByOwnerId error: $e\n$stackTrace');
      return [];
    }
  }
}
