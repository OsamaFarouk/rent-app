import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../../equipment/domain/equipment_model.dart';
import '../../profile/domain/business_profile_model.dart';
import '../../profile/domain/profile_model.dart';

/// Repository managing multi-type public search queries across Equipment, Professionals, and Rental Houses.
class SearchRepository {
  final SupabaseClient _client;

  SearchRepository({SupabaseClient? client})
      : _client = client ?? SupabaseService.client;

  Future<
      ({
        List<EquipmentModel> equipment,
        List<ProfileModel> professionals,
        List<BusinessProfileModel> rentalHouses,
      })> searchPublic({
    required String query,
    String? city,
  }) async {
    try {
      final q = query.trim();
      final cityFilter = city;

      final isCityAll = cityFilter == null ||
          cityFilter.isEmpty ||
          cityFilter == 'All Locations' ||
          cityFilter == 'All' ||
          cityFilter == 'جميع المدن';

      // 1. Fetch matching public approved equipment
      var eqQuery = _client
          .from('equipment')
          .select('*, equipment_images(*), categories(*), profiles(*)')
          .eq('approval_status', 'approved');

      if (!isCityAll) {
        eqQuery = eqQuery.ilike('city', '%$cityFilter%');
      }

      if (q.isNotEmpty) {
        final term = '%$q%';
        eqQuery = eqQuery.or('name.ilike.$term,brand.ilike.$term,model.ilike.$term,description.ilike.$term');
      }

      final eqData = await eqQuery.order('created_at', ascending: false);
      final equipmentList = (eqData as List)
          .map((item) => EquipmentModel.fromJson(item as Map<String, dynamic>))
          .toList();

      // 2. Fetch matching public active professionals
      var proQuery = _client
          .from('profiles')
          .select()
          .or('account_type.eq.professional,profile_type.eq.professional')
          .eq('is_active', true);

      if (!isCityAll) {
        proQuery = proQuery.ilike('city', '%$cityFilter%');
      }

      if (q.isNotEmpty) {
        final term = '%$q%';
        proQuery = proQuery.or('full_name.ilike.$term,business_name.ilike.$term,business_description.ilike.$term');
      }

      final proData = await proQuery.order('created_at', ascending: false);
      final proList = (proData as List)
          .map((item) => ProfileModel.fromJson(item as Map<String, dynamic>))
          .toList();

      // 3. Fetch matching public approved rental houses
      var rhQuery = _client
          .from('business_profiles')
          .select()
          .eq('approval_status', 'approved')
          .eq('is_active', true);

      if (!isCityAll) {
        rhQuery = rhQuery.ilike('city', '%$cityFilter%');
      }

      if (q.isNotEmpty) {
        final term = '%$q%';
        rhQuery = rhQuery.or('business_name.ilike.$term,business_description.ilike.$term');
      }

      final rhData = await rhQuery.order('created_at', ascending: false);
      final rhList = (rhData as List)
          .map((item) => BusinessProfileModel.fromJson(item as Map<String, dynamic>))
          .toList();

      return (
        equipment: equipmentList,
        professionals: proList,
        rentalHouses: rhList,
      );
    } catch (e, stackTrace) {
      debugPrint('[SearchRepository] searchPublic error: $e\n$stackTrace');
      return (
        equipment: <EquipmentModel>[],
        professionals: <ProfileModel>[],
        rentalHouses: <BusinessProfileModel>[],
      );
    }
  }
}
