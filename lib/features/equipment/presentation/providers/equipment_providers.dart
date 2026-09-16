import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/equipment_repository.dart';
import '../../domain/category_model.dart';
import '../../domain/equipment_model.dart';

final equipmentRepositoryProvider = Provider<EquipmentRepository>((ref) {
  return EquipmentRepository();
});

/// Parameter class for filtering public equipment
class EquipmentFilterParams {
  final String? categoryId;
  final String? categoryName;
  final String? searchQuery;
  final String? city;

  const EquipmentFilterParams({
    this.categoryId,
    this.categoryName,
    this.searchQuery,
    this.city,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EquipmentFilterParams &&
          runtimeType == other.runtimeType &&
          categoryId == other.categoryId &&
          categoryName == other.categoryName &&
          searchQuery == other.searchQuery &&
          city == other.city;

  @override
  int get hashCode => Object.hash(categoryId, categoryName, searchQuery, city);
}

/// Provider fetching equipment categories from database
final equipmentCategoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final repo = ref.watch(equipmentRepositoryProvider);
  return repo.getCategories();
});

/// Provider fetching the logged-in user's equipment listings
final myEquipmentProvider = FutureProvider<List<EquipmentModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final repo = ref.watch(equipmentRepositoryProvider);
  return repo.getMyEquipment(user.id);
});

/// Provider fetching public approved equipment listings
final publicApprovedEquipmentProvider =
    FutureProvider.family<List<EquipmentModel>, EquipmentFilterParams>(
        (ref, params) async {
  final repo = ref.watch(equipmentRepositoryProvider);
  return repo.getPublicApprovedEquipment(
    categoryId: params.categoryId,
    categoryName: params.categoryName,
    searchQuery: params.searchQuery,
    city: params.city,
  );
});

/// Provider fetching single equipment details
final equipmentDetailProvider =
    FutureProvider.family<EquipmentModel?, String>((ref, id) async {
  final repo = ref.watch(equipmentRepositoryProvider);
  return repo.getEquipmentById(id);
});
