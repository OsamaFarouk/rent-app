import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';
import '../domain/business_profile_model.dart';
import '../domain/portfolio_item_model.dart';
import '../domain/professional_profile_model.dart';
import '../domain/profile_model.dart';

/// Repository managing database operations for public.profiles, public.professional_profiles, and public.business_profiles tables.
class ProfileRepository {
  final SupabaseClient _client;

  ProfileRepository({SupabaseClient? client})
      : _client = client ?? SupabaseService.client;

  /// Fetches a single user profile by [userId] directly from Supabase.
  Future<ProfileModel?> getProfile(String userId) async {
    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data == null) return null;
      return ProfileModel.fromJson(data);
    } catch (e, stackTrace) {
      debugPrint('[ProfileRepository] getProfile error: $e\n$stackTrace');
      rethrow;
    }
  }

  /// Fetches business profile for a user from public.business_profiles.
  Future<BusinessProfileModel?> getBusinessProfile(String userId) async {
    try {
      final data = await _client
          .from('business_profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (data == null) return null;
      return BusinessProfileModel.fromJson(data);
    } catch (e, stackTrace) {
      debugPrint('[ProfileRepository] getBusinessProfile error: $e\n$stackTrace');
      return null;
    }
  }

  /// Fetches professional profile for a user from public.professional_profiles including portfolio items.
  Future<ProfessionalProfileModel?> getProfessionalProfile(String userId) async {
    try {
      final data = await _client
          .from('professional_profiles')
          .select('*, portfolio_items(*)')
          .eq('profile_id', userId)
          .maybeSingle();

      if (data == null) return null;
      return ProfessionalProfileModel.fromJson(data);
    } catch (e, stackTrace) {
      debugPrint('[ProfileRepository] getProfessionalProfile error: $e\n$stackTrace');
      return null;
    }
  }

  /// Updates common editable profile fields for [profile] in public.profiles.
  /// Does NOT modify public business/professional profile approval statuses.
  Future<ProfileModel> updateProfile(ProfileModel profile) async {
    try {
      final dbAccountType = (profile.accountType == 'personal' || profile.accountType == 'individual')
          ? 'user'
          : (profile.accountType ?? 'user');

      final updateData = <String, dynamic>{
        'full_name': profile.fullName,
        'profile_photo': profile.profilePhoto,
        'phone': profile.phone,
        'whatsapp': profile.whatsapp,
        'city': profile.city,
        'area': profile.area,
        'account_type': dbAccountType,
      };

      final data = await _client
          .from('profiles')
          .update(updateData)
          .eq('id', profile.id)
          .select()
          .single();

      return ProfileModel.fromJson(data);
    } catch (e, stackTrace) {
      debugPrint('[ProfileRepository] updateProfile error: $e\n$stackTrace');
      rethrow;
    }
  }

  /// Upserts a professional profile in public.professional_profiles.
  Future<ProfessionalProfileModel> upsertProfessionalProfile(ProfessionalProfileModel proProfile) async {
    try {
      final payload = <String, dynamic>{
        'profile_id': proProfile.profileId,
        'professional_title': proProfile.professionalTitle,
        'bio': proProfile.bio,
        'years_of_experience': proProfile.yearsOfExperience,
        'experience_level': proProfile.experienceLevel,
        'starting_price': proProfile.startingPrice,
        'pricing_type': proProfile.pricingType,
        'willing_to_travel': proProfile.willingToTravel,
        'linkedin_url': proProfile.linkedinUrl,
        'instagram_url': proProfile.instagramUrl,
        'behance_url': proProfile.behanceUrl,
        'vimeo_url': proProfile.vimeoUrl,
        'youtube_url': proProfile.youtubeUrl,
        'website_url': proProfile.websiteUrl,
        'approval_status': proProfile.approvalStatus,
        'last_updated': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (proProfile.categoryId != null) {
        payload['category_id'] = proProfile.categoryId;
      }

      final data = await _client
          .from('professional_profiles')
          .upsert(payload, onConflict: 'profile_id')
          .select('*, portfolio_items(*)')
          .single();

      return ProfessionalProfileModel.fromJson(data);
    } catch (e, stackTrace) {
      debugPrint('[ProfileRepository] upsertProfessionalProfile error: $e\n$stackTrace');
      rethrow;
    }
  }

  /// Adds a new portfolio item to public.portfolio_items.
  /// Adds a new portfolio item to public.portfolio_items.
  Future<PortfolioItemModel> addPortfolioItem({
    required String professionalProfileId,
    required String title,
    String? description,
    String? mediaUrl,
    String mediaType = 'image',
    String? externalUrl,
    int displayOrder = 0,
  }) async {
    try {
      final payload = <String, dynamic>{
        'professional_profile_id': professionalProfileId,
        'title': title,
        'description': description,
        'media_url': mediaUrl,
        'media_type': mediaType,
        'external_url': externalUrl,
        'display_order': displayOrder,
      };

      final data = await _client
          .from('portfolio_items')
          .insert(payload)
          .select()
          .single();

      return PortfolioItemModel.fromJson(data);
    } catch (e, stackTrace) {
      debugPrint('[ProfileRepository] addPortfolioItem error: $e\n$stackTrace');
      rethrow;
    }
  }

  /// Updates an existing portfolio item in public.portfolio_items.
  Future<PortfolioItemModel> updatePortfolioItem(PortfolioItemModel item) async {
    try {
      final payload = <String, dynamic>{
        'title': item.title,
        'description': item.description,
        'media_url': item.mediaUrl,
        'media_type': item.mediaType,
        'external_url': item.externalUrl,
        'display_order': item.displayOrder,
      };

      final data = await _client
          .from('portfolio_items')
          .update(payload)
          .eq('id', item.id)
          .select()
          .single();

      return PortfolioItemModel.fromJson(data);
    } catch (e, stackTrace) {
      debugPrint('[ProfileRepository] updatePortfolioItem error: $e\n$stackTrace');
      rethrow;
    }
  }

  /// Batch updates display_order for portfolio items.
  Future<void> reorderPortfolioItems(List<PortfolioItemModel> items) async {
    try {
      for (int i = 0; i < items.length; i++) {
        await _client
            .from('portfolio_items')
            .update({'display_order': i})
            .eq('id', items[i].id);
      }
    } catch (e, stackTrace) {
      debugPrint('[ProfileRepository] reorderPortfolioItems error: $e\n$stackTrace');
      rethrow;
    }
  }

  /// Deletes a portfolio item from public.portfolio_items.
  Future<void> deletePortfolioItem(String itemId) async {
    try {
      await _client
          .from('portfolio_items')
          .delete()
          .eq('id', itemId);
    } catch (e, stackTrace) {
      debugPrint('[ProfileRepository] deletePortfolioItem error: $e\n$stackTrace');
      rethrow;
    }
  }

  /// Completes initial profile setup by saving [accountType] to Supabase.
  Future<ProfileModel> completeProfileSetup({
    required String userId,
    required String accountType,
    String? businessName,
  }) async {
    try {
      final dbAccountType = (accountType == 'personal' || accountType == 'individual') ? 'user' : accountType;

      final updateData = <String, dynamic>{
        'account_type': dbAccountType,
      };

      if (dbAccountType == 'business' && businessName != null && businessName.trim().isNotEmpty) {
        updateData['business_name'] = businessName.trim();
      }

      final data = await _client
          .from('profiles')
          .update(updateData)
          .eq('id', userId)
          .select()
          .single();

      final profile = ProfileModel.fromJson(data);

      if (dbAccountType == 'business' && businessName != null && businessName.trim().isNotEmpty) {
        await upsertBusinessProfile(
          userId: userId,
          businessName: businessName.trim(),
          phone: profile.phone,
          whatsapp: profile.whatsapp,
          email: profile.email,
          city: profile.city,
          area: profile.area,
        );
      } else if (dbAccountType == 'professional') {
        await upsertProfessionalProfile(
          ProfessionalProfileModel(
            id: '',
            profileId: userId,
            professionalTitle: 'Professional',
            approvalStatus: 'approved',
          ),
        );
      }

      return profile;
    } catch (e, stackTrace) {
      debugPrint('[ProfileRepository] completeProfileSetup error: $e\n$stackTrace');
      rethrow;
    }
  }

  /// Upserts a record in public.business_profiles for a business account.
  Future<void> upsertBusinessProfile({
    required String userId,
    required String businessName,
    String? businessAddress,
    String? businessDescription,
    String? logoUrl,
    String? phone,
    String? whatsapp,
    String? email,
    String city = 'Cairo',
    String? area,
    String? websiteUrl,
    String? workingHours,
  }) async {
    try {
      final payload = <String, dynamic>{
        'user_id': userId,
        'business_name': businessName,
        'city': city,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (businessAddress != null) payload['business_address'] = businessAddress;
      if (businessDescription != null) payload['business_description'] = businessDescription;
      if (logoUrl != null) payload['logo_url'] = logoUrl;
      if (phone != null) payload['phone'] = phone;
      if (whatsapp != null) payload['whatsapp'] = whatsapp;
      if (email != null) payload['email'] = email;
      if (area != null) payload['area'] = area;
      if (websiteUrl != null) payload['website_url'] = websiteUrl;
      if (workingHours != null) payload['working_hours'] = workingHours;

      await _client
          .from('business_profiles')
          .upsert(payload, onConflict: 'user_id');
    } catch (e, stackTrace) {
      debugPrint('[ProfileRepository] upsertBusinessProfile error: $e\n$stackTrace');
    }
  }

  /// Fetches public approved professional profiles from public.profiles table.
  Future<List<ProfileModel>> getPublicApprovedProfessionals({
    String? city,
    String? category,
    String? searchQuery,
  }) async {
    try {
      var query = _client
          .from('profiles')
          .select()
          .or('account_type.eq.professional,profile_type.eq.professional')
          .eq('is_active', true);

      if (city != null && city.trim().isNotEmpty && city != 'All' && city != 'All Locations' && city != 'جميع المدن') {
        query = query.ilike('city', '%${city.trim()}%');
      }

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final term = '%${searchQuery.trim()}%';
        query = query.or('full_name.ilike.$term,business_name.ilike.$term,business_description.ilike.$term,area.ilike.$term,city.ilike.$term');
      }

      final data = await query.order('created_at', ascending: false);

      List<ProfileModel> list = (data as List).map((json) => ProfileModel.fromJson(json)).toList();

      if (category != null &&
          category.trim().isNotEmpty &&
          category.trim().toLowerCase() != 'all' &&
          category.trim() != 'الكل' &&
          category.trim() != 'All Categories') {
        final catLower = category.trim().toLowerCase();
        list = list.where((pro) {
          final fullName = pro.fullName.toLowerCase();
          final bName = (pro.businessName ?? '').toLowerCase();
          final bDesc = (pro.businessDescription ?? '').toLowerCase();
          final accType = (pro.accountType ?? '').toLowerCase();
          return fullName.contains(catLower) ||
              bName.contains(catLower) ||
              bDesc.contains(catLower) ||
              accType.contains(catLower);
        }).toList();
      }

      return list;
    } catch (e, stackTrace) {
      debugPrint('[ProfileRepository] getPublicApprovedProfessionals error: $e\n$stackTrace');
      return [];
    }
  }
}
