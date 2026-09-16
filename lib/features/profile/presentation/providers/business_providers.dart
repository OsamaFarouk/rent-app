import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../equipment/domain/equipment_model.dart';
import '../../data/business_repository.dart';
import '../../domain/business_profile_model.dart';
import 'profile_provider.dart';

final businessRepositoryProvider = Provider<BusinessRepository>((ref) {
  return BusinessRepository();
});

/// Riverpod provider delivering approved public rental houses (business profiles).
final publicApprovedBusinessProfilesProvider =
    FutureProvider.family<List<BusinessProfileModel>, String?>((ref, city) async {
  final repository = ref.watch(businessRepositoryProvider);
  return await repository.getApprovedBusinessProfiles(city: city);
});

/// Riverpod provider delivering single business profile details by business profile ID.
final businessProfileDetailProvider =
    FutureProvider.family<BusinessProfileModel?, String>((ref, id) async {
  final repository = ref.watch(businessRepositoryProvider);
  return await repository.getBusinessProfileById(id);
});

/// Riverpod provider delivering single business profile by owner's user ID.
final businessProfileByUserIdProvider =
    FutureProvider.family<BusinessProfileModel?, String>((ref, userId) async {
  final repository = ref.watch(businessRepositoryProvider);
  return await repository.getBusinessProfileByUserId(userId);
});

/// Riverpod provider delivering public equipment owned by a business user ID.
final businessOwnerEquipmentProvider =
    FutureProvider.family<List<EquipmentModel>, String>((ref, ownerId) async {
  final repository = ref.watch(businessRepositoryProvider);
  return await repository.getEquipmentByOwnerId(ownerId);
});

class BusinessNotifierState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const BusinessNotifierState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  BusinessNotifierState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return BusinessNotifierState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

class BusinessNotifier extends StateNotifier<BusinessNotifierState> {
  final BusinessRepository _repository;
  final Ref _ref;

  BusinessNotifier(this._repository, this._ref)
      : super(const BusinessNotifierState());

  Future<bool> updateBusinessProfile(BusinessProfileModel business) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    try {
      await _repository.upsertBusinessProfile(business);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'profileUpdatedSuccess',
      );
      _ref.invalidate(currentBusinessProfileProvider);
      _ref.invalidate(publicApprovedBusinessProfilesProvider);
      await _ref.read(currentBusinessProfileProvider.future);
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

final businessNotifierProvider =
    StateNotifierProvider<BusinessNotifier, BusinessNotifierState>((ref) {
  return BusinessNotifier(
    ref.watch(businessRepositoryProvider),
    ref,
  );
});
