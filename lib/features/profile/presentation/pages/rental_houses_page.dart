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
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../providers/business_providers.dart';
import '../widgets/rental_house_card.dart';

/// Dedicated public discovery screen for equipment rental offices & business profiles.
class RentalHousesPage extends ConsumerStatefulWidget {
  const RentalHousesPage({super.key});

  @override
  ConsumerState<RentalHousesPage> createState() => _RentalHousesPageState();
}

class _RentalHousesPageState extends ConsumerState<RentalHousesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedCityIndex = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final businessProfilesAsync = ref.watch(publicApprovedBusinessProfilesProvider(null));

    final cityFilters = ['All', 'Cairo', 'Giza', 'Alexandria'];
    final selectedCity = _selectedCityIndex == 0 ? null : cityFilters[_selectedCityIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: l10n.navRentalHouses,
        subtitle: l10n.rentalHousesSubtitle,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar Area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: AppSearchField(
                hintText: l10n.searchRentalHousesHint,
                onChanged: (query) {
                  setState(() {
                    _searchQuery = query.trim().toLowerCase();
                  });
                },
                onFilterTap: () {},
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Horizontal City Filter Chips
            SizedBox(
              height: 38.0,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                itemCount: cityFilters.length,
                separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, index) {
                  return CategoryChip(
                    label: cityFilters[index],
                    isSelected: _selectedCityIndex == index,
                    onTap: () {
                      setState(() {
                        _selectedCityIndex = index;
                      });
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Rental Houses Grid List
            Expanded(
              child: businessProfilesAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (err, stack) => Center(
                  child: Text(
                    l10n.networkError,
                    style: AppTypography.body.copyWith(color: AppColors.error),
                  ),
                ),
                data: (profiles) {
                  final filteredProfiles = profiles.where((p) {
                    if (selectedCity != null && selectedCity.isNotEmpty) {
                      if (!p.city.toLowerCase().contains(selectedCity.toLowerCase())) {
                        return false;
                      }
                    }
                    if (_searchQuery.isEmpty) return true;
                    final name = p.businessName.toLowerCase();
                    final city = p.city.toLowerCase();
                    final desc = (p.businessDescription ?? '').toLowerCase();
                    return name.contains(_searchQuery) ||
                        city.contains(_searchQuery) ||
                        desc.contains(_searchQuery);
                  }).toList();

                  if (filteredProfiles.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.storefront_outlined,
                            size: 48.0,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            l10n.noRentalHousesTitle,
                            style: AppTypography.heading.copyWith(fontSize: 18.0),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            l10n.noRentalHousesDesc,
                            textAlign: TextAlign.center,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textMuted,
                              fontSize: 13.0,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: filteredProfiles.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 0, height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final item = filteredProfiles[index];
                      final isFav = ref.watch(isBusinessFavoriteProvider(item.id));
                      final chips = index % 2 == 0
                          ? const ['Cameras', 'Lighting', 'Audio']
                          : const ['Cameras', 'Lighting', 'Grip & Support'];

                      return RentalHouseCard(
                        isHomeVariant: false,
                        businessName: item.businessName,
                        city: item.city,
                        area: item.area,
                        description: item.businessDescription,
                        logoUrl: item.logoUrl,
                        categoryChips: chips,
                        activeListingsCount: (24 - index * 6).clamp(12, 48),
                        isVerified: true,
                        isFavorite: isFav,
                        onViewEquipmentTap: () => context.go('/equipment'),
                        onFavoriteTap: () async {
                          final user = ref.read(currentUserProvider);
                          if (user == null) {
                            context.push('/login');
                            return;
                          }
                          await ref
                              .read(userFavoritesTargetNotifierProvider(
                                UserFavoritesTargetKey(userId: user.id, targetType: 'business'),
                              ).notifier)
                              .toggleFavorite(userId: user.id, targetId: item.id);
                        },
                        onTap: () => context.push('/rental-houses/${item.id}'),
                      );
                    },
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
