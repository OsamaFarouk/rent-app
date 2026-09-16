import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_search_field.dart';
import '../../../../shared/widgets/category_chip.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../providers/equipment_providers.dart';
import '../widgets/equipment_card.dart';

/// Public Equipment discovery screen connecting directly to Supabase approved equipment listings.
class EquipmentPage extends ConsumerStatefulWidget {
  final String? initialCategory;

  const EquipmentPage({
    super.key,
    this.initialCategory,
  });

  @override
  ConsumerState<EquipmentPage> createState() => _EquipmentPageState();
}

class _EquipmentPageState extends ConsumerState<EquipmentPage> {
  int _selectedCategoryIndex = 0;
  String _activeSearchQuery = '';
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _applyInitialCategory();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant EquipmentPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCategory != oldWidget.initialCategory) {
      _applyInitialCategory();
    }
  }

  void _applyInitialCategory() {
    if (widget.initialCategory == null || widget.initialCategory!.isEmpty) {
      _selectedCategoryIndex = 0;
      return;
    }
  }

  void _syncCategoryWithL10n(List<String> categories) {
    if (widget.initialCategory != null && widget.initialCategory!.isNotEmpty) {
      final index = categories.indexWhere(
        (cat) => cat.toLowerCase() == widget.initialCategory!.toLowerCase(),
      );
      if (index != -1) {
        _selectedCategoryIndex = index;
      }
    }
  }

  void _onSearchInputChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      final trimmed = query.trim();
      final newQuery = trimmed.length >= 2 ? trimmed : '';
      if (_activeSearchQuery != newQuery) {
        setState(() {
          _activeSearchQuery = newQuery;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeCode = Localizations.localeOf(context).languageCode;
    final categoriesAsync = ref.watch(equipmentCategoriesProvider);

    final defaultCategoryNames = [
      l10n.catAll,
      l10n.catCameras,
      l10n.catLenses,
      l10n.catLighting,
      l10n.catAudio,
    ];

    List<String> categoryLabels = defaultCategoryNames;
    if (categoriesAsync.hasValue && categoriesAsync.value!.isNotEmpty) {
      categoryLabels = [l10n.catAll, ...categoriesAsync.value!.map((c) => c.getLocalizedName(localeCode))];
    }

    _syncCategoryWithL10n(categoryLabels);

    final selectedCategoryLabel = categoryLabels[_selectedCategoryIndex];

    final filterParams = EquipmentFilterParams(
      categoryName: selectedCategoryLabel,
      searchQuery: _activeSearchQuery,
    );

    final publicEquipmentAsync = ref.watch(publicApprovedEquipmentProvider(filterParams));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: l10n.navEquipment,
        subtitle: l10n.equipmentSubtitle,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: AppSearchField(
                hintText: l10n.searchEquipmentHint,
                onChanged: _onSearchInputChanged,
                onFilterTap: () {},
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Horizontal Category Chips
            SizedBox(
              height: 38.0,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                itemCount: categoryLabels.length,
                separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, index) {
                  return CategoryChip(
                    label: categoryLabels[index],
                    isSelected: _selectedCategoryIndex == index,
                    onTap: () {
                      setState(() {
                        _selectedCategoryIndex = index;
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Equipment Grid loaded from Supabase
            Expanded(
              child: publicEquipmentAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (err, stack) => Center(
                  child: Text(
                    l10n.networkError,
                    style: AppTypography.body.copyWith(color: AppColors.error),
                  ),
                ),
                data: (items) {
                  if (items.isEmpty) {
                    return EmptyState(
                      icon: Icons.camera_alt_outlined,
                      title: l10n.noEquipmentTitle,
                      description: 'No approved equipment available under this filter yet.',
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(publicApprovedEquipmentProvider);
                      await ref.read(publicApprovedEquipmentProvider(filterParams).future);
                    },
                    color: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    child: GridView.builder(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: items.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: AppSpacing.md,
                        crossAxisSpacing: AppSpacing.md,
                        childAspectRatio: 0.72,
                      ),
                      itemBuilder: (context, index) {
                        final equipment = items[index];
                        final isFav = ref.watch(isEquipmentFavoriteProvider(equipment.id));
                        return EquipmentCard(
                          title: equipment.name,
                          price: '${l10n.fromPrice(equipment.dailyPrice.toStringAsFixed(0))} ${l10n.perDay}',
                          location: equipment.formattedLocation,
                          rating: '5.0',
                          reviewsCount: '0',
                          imagePath: equipment.primaryImageUrl,
                          isFavorite: isFav,
                          onFavoriteTap: () async {
                            final user = ref.read(currentUserProvider);
                            if (user == null) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please sign in to save favorites.'),
                                    backgroundColor: AppColors.surfaceElevated,
                                  ),
                                );
                                context.push('/login');
                              }
                              return;
                            }
                            try {
                              await ref
                                  .read(userFavoritesNotifierProvider(user.id).notifier)
                                  .toggleFavorite(
                                    userId: user.id,
                                    equipmentId: equipment.id,
                                  );
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to update favorites: ${e.toString()}'),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                              }
                            }
                          },
                          onTap: () => context.push('/equipment/${equipment.id}'),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
