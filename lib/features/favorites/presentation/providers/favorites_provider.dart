import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/favorites_repository.dart';
import '../../../equipment/domain/equipment_model.dart';
import '../../../profile/domain/business_profile_model.dart';
import '../../../profile/domain/profile_model.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepository();
});

class UserFavoritesTargetKey {
  final String userId;
  final String targetType;

  const UserFavoritesTargetKey({
    required this.userId,
    this.targetType = 'equipment',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserFavoritesTargetKey &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          targetType == other.targetType;

  @override
  int get hashCode => userId.hashCode ^ targetType.hashCode;
}

class UserFavoritesNotifier extends StateNotifier<AsyncValue<Set<String>>> {
  final FavoritesRepository _repository;
  final Ref _ref;
  final String _userId;
  final String _targetType;
  final Set<String> _inFlightTargetIds = {};

  UserFavoritesNotifier(this._repository, this._ref, this._userId, [this._targetType = 'equipment'])
      : super(const AsyncValue.loading()) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final set = await _repository.getFavoriteTargetIds(
        userId: _userId,
        targetType: _targetType,
      );
      if (mounted) {
        state = AsyncValue.data(set);
      }
    } catch (e, st) {
      if (mounted) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  Future<bool> toggleFavorite({
    required String userId,
    String? equipmentId,
    String? targetId,
  }) async {
    final resolvedId = targetId ?? equipmentId;
    if (resolvedId == null) return false;

    if (_inFlightTargetIds.contains(resolvedId)) {
      return state.value?.contains(resolvedId) ?? false;
    }
    _inFlightTargetIds.add(resolvedId);

    final previousSet = state.value ?? {};
    final isFav = previousSet.contains(resolvedId);
    final newSet = Set<String>.from(previousSet);

    if (isFav) {
      newSet.remove(resolvedId);
    } else {
      newSet.add(resolvedId);
    }

    // Optimistic UI state update
    state = AsyncValue.data(newSet);

    try {
      if (isFav) {
        await _repository.removeFavorite(
          userId: userId,
          targetId: resolvedId,
          targetType: _targetType,
        );
      } else {
        await _repository.addFavorite(
          userId: userId,
          targetId: resolvedId,
          targetType: _targetType,
        );
      }

      // Refresh list provider matching this target type
      if (_targetType == 'equipment') {
        _ref.invalidate(userFavoriteEquipmentListProvider);
      } else if (_targetType == 'professional') {
        _ref.invalidate(userFavoriteProfessionalsListProvider);
      } else if (_targetType == 'business') {
        _ref.invalidate(userFavoriteBusinessesListProvider);
      }

      return !isFav;
    } catch (e) {
      // Revert state on failure
      if (mounted) {
        state = AsyncValue.data(previousSet);
      }
      rethrow;
    } finally {
      _inFlightTargetIds.remove(resolvedId);
    }
  }
}

/// Backward compatible equipment favorites notifier family by userId
final userFavoritesNotifierProvider = StateNotifierProvider.family<
    UserFavoritesNotifier, AsyncValue<Set<String>>, String>((ref, userId) {
  final repository = ref.watch(favoritesRepositoryProvider);
  return UserFavoritesNotifier(repository, ref, userId, 'equipment');
});

/// Multi-target favorites notifier family by UserFavoritesTargetKey
final userFavoritesTargetNotifierProvider = StateNotifierProvider.family<
    UserFavoritesNotifier, AsyncValue<Set<String>>, UserFavoritesTargetKey>((ref, key) {
  final repository = ref.watch(favoritesRepositoryProvider);
  return UserFavoritesNotifier(repository, ref, key.userId, key.targetType);
});

final isEquipmentFavoriteProvider = Provider.family<bool, String>((ref, equipmentId) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;

  final favState = ref.watch(userFavoritesNotifierProvider(user.id));
  return favState.value?.contains(equipmentId) ?? false;
});

final isProfessionalFavoriteProvider = Provider.family<bool, String>((ref, proId) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;

  final favState = ref.watch(userFavoritesTargetNotifierProvider(
    UserFavoritesTargetKey(userId: user.id, targetType: 'professional'),
  ));
  return favState.value?.contains(proId) ?? false;
});

final isBusinessFavoriteProvider = Provider.family<bool, String>((ref, businessId) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;

  final favState = ref.watch(userFavoritesTargetNotifierProvider(
    UserFavoritesTargetKey(userId: user.id, targetType: 'business'),
  ));
  return favState.value?.contains(businessId) ?? false;
});

final userFavoriteEquipmentListProvider =
    FutureProvider<List<EquipmentModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final repository = ref.watch(favoritesRepositoryProvider);
  return repository.getFavoriteEquipment(userId: user.id);
});

final userFavoriteProfessionalsListProvider =
    FutureProvider<List<ProfileModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final repository = ref.watch(favoritesRepositoryProvider);
  return repository.getFavoriteProfessionals(userId: user.id);
});

final userFavoriteBusinessesListProvider =
    FutureProvider<List<BusinessProfileModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final repository = ref.watch(favoritesRepositoryProvider);
  return repository.getFavoriteBusinesses(userId: user.id);
});


