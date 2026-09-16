import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../equipment/presentation/providers/equipment_providers.dart';
import '../../data/profile_repository.dart';
import '../../domain/business_profile_model.dart';
import '../../domain/portfolio_item_model.dart';
import '../../domain/professional_profile_model.dart';
import '../../domain/profile_model.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

final currentProfileProvider = FutureProvider<ProfileModel?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final repository = ref.watch(profileRepositoryProvider);
  return await repository.getProfile(user.id);
});

final currentBusinessProfileProvider = FutureProvider<BusinessProfileModel?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final repository = ref.watch(profileRepositoryProvider);
  return await repository.getBusinessProfile(user.id);
});

final currentProfessionalProfileProvider = FutureProvider<ProfessionalProfileModel?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final repository = ref.watch(profileRepositoryProvider);
  return await repository.getProfessionalProfile(user.id);
});

class ProfileNotifierState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const ProfileNotifierState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  ProfileNotifierState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return ProfileNotifierState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileNotifierState> {
  final ProfileRepository _repository;
  final Ref _ref;

  ProfileNotifier(this._repository, this._ref)
      : super(const ProfileNotifierState());

  Future<bool> updateProfile(ProfileModel profile) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    try {
      await _repository.updateProfile(profile);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'profileUpdatedSuccess',
      );
      // Invalidate profile providers
      _ref.invalidate(currentProfileProvider);
      _ref.invalidate(myEquipmentProvider);
      _ref.invalidate(publicApprovedEquipmentProvider);
      _ref.invalidate(equipmentDetailProvider);
      await _ref.read(currentProfileProvider.future);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'networkError',
      );
      return false;
    }
  }

  Future<bool> updateProfessionalProfile(ProfessionalProfileModel proProfile) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    try {
      await _repository.upsertProfessionalProfile(proProfile);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'profileUpdatedSuccess',
      );
      _ref.invalidate(currentProfessionalProfileProvider);
      _ref.invalidate(publicApprovedProfessionalsProvider);
      await _ref.read(currentProfessionalProfileProvider.future);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'networkError',
      );
      return false;
    }
  }

  Future<bool> addPortfolioItem({
    required String professionalProfileId,
    required String title,
    String? description,
    String? mediaUrl,
    String mediaType = 'image',
    String? externalUrl,
    int displayOrder = 0,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    try {
      await _repository.addPortfolioItem(
        professionalProfileId: professionalProfileId,
        title: title,
        description: description,
        mediaUrl: mediaUrl,
        mediaType: mediaType,
        externalUrl: externalUrl,
        displayOrder: displayOrder,
      );
      state = state.copyWith(isLoading: false);
      _ref.invalidate(currentProfessionalProfileProvider);
      await _ref.read(currentProfessionalProfileProvider.future);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'networkError',
      );
      return false;
    }
  }

  Future<bool> updatePortfolioItem(PortfolioItemModel item) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    try {
      await _repository.updatePortfolioItem(item);
      state = state.copyWith(isLoading: false);
      _ref.invalidate(currentProfessionalProfileProvider);
      await _ref.read(currentProfessionalProfileProvider.future);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'networkError',
      );
      return false;
    }
  }

  Future<bool> reorderPortfolioItems(List<PortfolioItemModel> items) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    try {
      await _repository.reorderPortfolioItems(items);
      state = state.copyWith(isLoading: false);
      _ref.invalidate(currentProfessionalProfileProvider);
      await _ref.read(currentProfessionalProfileProvider.future);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'networkError',
      );
      return false;
    }
  }

  Future<bool> deletePortfolioItem(String itemId) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    try {
      await _repository.deletePortfolioItem(itemId);
      state = state.copyWith(isLoading: false);
      _ref.invalidate(currentProfessionalProfileProvider);
      await _ref.read(currentProfessionalProfileProvider.future);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'networkError',
      );
      return false;
    }
  }

  Future<bool> completeProfileSetup({
    required String userId,
    required String profileType,
    String? businessName,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    try {
      await _repository.completeProfileSetup(
        userId: userId,
        accountType: profileType,
        businessName: businessName,
      );
      state = state.copyWith(isLoading: false);
      _ref.invalidate(currentProfileProvider);
      _ref.invalidate(currentBusinessProfileProvider);
      _ref.invalidate(currentProfessionalProfileProvider);
      await _ref.read(currentProfileProvider.future);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'networkError',
      );
      return false;
    }
  }
}

final profileNotifierProvider =
    StateNotifierProvider<ProfileNotifier, ProfileNotifierState>((ref) {
  return ProfileNotifier(
    ref.watch(profileRepositoryProvider),
    ref,
  );
});

class ProfessionalFilterParams {
  final String? category;
  final String? searchQuery;
  final String? city;

  const ProfessionalFilterParams({
    this.category,
    this.searchQuery,
    this.city,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfessionalFilterParams &&
          runtimeType == other.runtimeType &&
          category == other.category &&
          searchQuery == other.searchQuery &&
          city == other.city;

  @override
  int get hashCode => Object.hash(category, searchQuery, city);
}

final publicApprovedProfessionalsFilterProvider =
    FutureProvider.family<List<ProfileModel>, ProfessionalFilterParams>(
        (ref, params) async {
  final repository = ref.watch(profileRepositoryProvider);
  return await repository.getPublicApprovedProfessionals(
    city: params.city,
    category: params.category,
    searchQuery: params.searchQuery,
  );
});

final publicApprovedProfessionalsProvider =
    FutureProvider.family<List<ProfileModel>, String?>((ref, city) async {
  final repository = ref.watch(profileRepositoryProvider);
  return await repository.getPublicApprovedProfessionals(city: city);
});

final professionalDetailProvider =
    FutureProvider.family<ProfileModel?, String>((ref, id) async {
  final repository = ref.watch(profileRepositoryProvider);
  return await repository.getProfile(id);
});

final professionalProfileByIdProvider =
    FutureProvider.family<ProfessionalProfileModel?, String>((ref, id) async {
  final repository = ref.watch(profileRepositoryProvider);
  return await repository.getProfessionalProfile(id);
});
