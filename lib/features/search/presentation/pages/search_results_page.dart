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
import '../../../equipment/domain/equipment_model.dart';
import '../../../equipment/presentation/widgets/equipment_card.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../../professionals/presentation/widgets/professional_card.dart';
import '../../../profile/domain/business_profile_model.dart';
import '../../../profile/domain/profile_model.dart';
import '../../../profile/presentation/widgets/rental_house_card.dart';

import '../../data/search_repository.dart';

enum SearchResultType { all, equipment, professionals, rentalHouses }

final searchRepositoryProvider = Provider<SearchRepository>((ref) => SearchRepository());

/// Provider executing multi-type search across approved/public entities
final searchResultsProvider = FutureProvider.family<
    ({
      List<EquipmentModel> equipment,
      List<ProfileModel> professionals,
      List<BusinessProfileModel> rentalHouses,
    }),
    ({String query, String? city})>((ref, params) async {
  final repo = ref.watch(searchRepositoryProvider);
  return repo.searchPublic(query: params.query, city: params.city);
});

class SearchResultsPage extends ConsumerStatefulWidget {
  final String initialQuery;

  const SearchResultsPage({
    super.key,
    this.initialQuery = '',
  });

  @override
  ConsumerState<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends ConsumerState<SearchResultsPage> {
  late TextEditingController _searchController;
  late String _currentQuery;
  SearchResultType _selectedType = SearchResultType.all;
  String _selectedCity = 'All Locations';

  static const List<String> _mainCities = [
    'All Locations',
    'Cairo',
    'Giza',
    'Alexandria',
    'Mansoura',
    'Tanta',
    'Zagazig',
    'Ismailia',
    'Port Said',
    'Suez',
    'Hurghada',
    'Sharm El Sheikh',
    'Luxor',
    'Aswan',
  ];

  @override
  void initState() {
    super.initState();
    _currentQuery = widget.initialQuery;
    _searchController = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch(String query) {
    setState(() {
      _currentQuery = query.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final searchAsync = ref.watch(
      searchResultsProvider((
        query: _currentQuery,
        city: _selectedCity,
      )),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Search Results',
        showBackButton: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.sm),

            // Top Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: AppSearchField(
                hintText: l10n.searchHomeHint,
                controller: _searchController,
                onSubmitted: _submitSearch,
                showFilterButton: false,
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Filters Bar: Location Selector & Result Type Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  // Location Dropdown Filter
                  Container(
                    height: 36.0,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(18.0),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _mainCities.contains(_selectedCity) ? _selectedCity : 'All Locations',
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.primary,
                          size: 18.0,
                        ),
                        dropdownColor: AppColors.surfaceElevated,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        onChanged: (String? newCity) {
                          if (newCity != null) {
                            setState(() {
                              _selectedCity = newCity;
                            });
                          }
                        },
                        items: _mainCities.map<DropdownMenuItem<String>>((String city) {
                          final label = city == 'All Locations' ? 'All Locations' : city;
                          return DropdownMenuItem<String>(
                            value: city,
                            child: Row(
                              children: [
                                const Icon(Icons.location_on, size: 12.0, color: AppColors.primary),
                                const SizedBox(width: 4.0),
                                Text(label),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  const SizedBox(width: AppSpacing.sm),

                  // Result Type Chips
                  CategoryChip(
                    label: 'All Results',
                    isSelected: _selectedType == SearchResultType.all,
                    onTap: () => setState(() => _selectedType = SearchResultType.all),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  CategoryChip(
                    label: l10n.navEquipment,
                    isSelected: _selectedType == SearchResultType.equipment,
                    onTap: () => setState(() => _selectedType = SearchResultType.equipment),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  CategoryChip(
                    label: l10n.navProfessionals,
                    isSelected: _selectedType == SearchResultType.professionals,
                    onTap: () => setState(() => _selectedType = SearchResultType.professionals),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  CategoryChip(
                    label: l10n.navRentalHouses,
                    isSelected: _selectedType == SearchResultType.rentalHouses,
                    onTap: () => setState(() => _selectedType = SearchResultType.rentalHouses),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Results List
            Expanded(
              child: searchAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (err, stack) => Center(
                  child: Text(
                    l10n.networkError,
                    style: AppTypography.body.copyWith(color: AppColors.error),
                  ),
                ),
                data: (results) {
                  final eq = results.equipment;
                  final pro = results.professionals;
                  final rh = results.rentalHouses;

                  final totalCount = (_selectedType == SearchResultType.all
                          ? eq.length + pro.length + rh.length
                          : _selectedType == SearchResultType.equipment
                              ? eq.length
                              : _selectedType == SearchResultType.professionals
                                  ? pro.length
                                  : rh.length);

                  if (totalCount == 0) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search_off_rounded,
                            size: 48.0,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'No matching results found',
                            style: AppTypography.heading.copyWith(fontSize: 18.0),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Try searching with a different term or location filter',
                            textAlign: TextAlign.center,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    children: [
                      // Equipment Section
                      if (_selectedType == SearchResultType.all ||
                          _selectedType == SearchResultType.equipment) ...[
                        if (eq.isNotEmpty) ...[
                          if (_selectedType == SearchResultType.all)
                            Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                              child: Text(
                                '${l10n.navEquipment} (${eq.length})',
                                style: AppTypography.heading.copyWith(fontSize: 16.0),
                              ),
                            ),
                          ...eq.map((item) {
                            final isFav = ref.watch(isEquipmentFavoriteProvider(item.id));
                            final firstImage = item.primaryImageUrl;
                            final priceText =
                                l10n.fromPrice(item.dailyPrice.toStringAsFixed(0)) + l10n.perDay;
                            final locationText = item.formattedLocation;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.md),
                              child: EquipmentCard(
                                isHomeVariant: false,
                                width: double.infinity,
                                imagePath: firstImage ?? 'assets/images/sony_fx3.jpg',
                                title: item.name,
                                price: priceText,
                                location: locationText.isNotEmpty ? locationText : l10n.locationMaadi,
                                isFavorite: isFav,
                                onFavoriteTap: () async {
                                  final user = ref.read(currentUserProvider);
                                  if (user == null) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Please sign in to save favorites.'),
                                        ),
                                      );
                                      context.push('/login');
                                    }
                                    return;
                                  }
                                  await ref
                                      .read(userFavoritesNotifierProvider(user.id).notifier)
                                      .toggleFavorite(userId: user.id, equipmentId: item.id);
                                },
                                onTap: () => context.push('/equipment/${item.id}'),
                              ),
                            );
                          }),
                          const SizedBox(height: AppSpacing.md),
                        ],
                      ],

                      // Professionals Section
                      if (_selectedType == SearchResultType.all ||
                          _selectedType == SearchResultType.professionals) ...[
                        if (pro.isNotEmpty) ...[
                          if (_selectedType == SearchResultType.all)
                            Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                              child: Text(
                                '${l10n.navProfessionals} (${pro.length})',
                                style: AppTypography.heading.copyWith(fontSize: 16.0),
                              ),
                            ),
                          ...pro.map((item) {
                            final locationStr = item.area != null && item.area!.isNotEmpty
                                ? '${item.city}, ${item.area}'
                                : item.city;
                            final isFav = ref.watch(isProfessionalFavoriteProvider(item.id));

                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.md),
                              child: ProfessionalCard(
                                isHomeVariant: false,
                                name: item.fullName,
                                role: l10n.creativeProfessional,
                                location: locationStr.isNotEmpty ? locationStr : 'Cairo',
                                isVerified: true,
                                imagePath: item.profilePhoto,
                                isFavorite: isFav,
                                onFavoriteTap: () async {
                                  final user = ref.read(currentUserProvider);
                                  if (user == null) {
                                    context.push('/login');
                                    return;
                                  }
                                  await ref
                                      .read(userFavoritesTargetNotifierProvider(
                                        UserFavoritesTargetKey(userId: user.id, targetType: 'professional'),
                                      ).notifier)
                                      .toggleFavorite(userId: user.id, targetId: item.id);
                                },
                                onTap: () => context.push('/professionals/${item.id}'),
                              ),
                            );
                          }),
                          const SizedBox(height: AppSpacing.md),
                        ],
                      ],

                      // Rental Houses Section
                      if (_selectedType == SearchResultType.all ||
                          _selectedType == SearchResultType.rentalHouses) ...[
                        if (rh.isNotEmpty) ...[
                          if (_selectedType == SearchResultType.all)
                            Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                              child: Text(
                                '${l10n.navRentalHouses} (${rh.length})',
                                style: AppTypography.heading.copyWith(fontSize: 16.0),
                              ),
                            ),
                          ...rh.map((item) {
                            final isFav = ref.watch(isBusinessFavoriteProvider(item.id));

                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.md),
                              child: RentalHouseCard(
                                isHomeVariant: false,
                                width: double.infinity,
                                businessName: item.businessName,
                                city: item.city,
                                area: item.area,
                                description: item.businessDescription,
                                logoUrl: item.logoUrl,
                                isVerified: true,
                                isFavorite: isFav,
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
                              ),
                            );
                          }),
                        ],
                      ],
                    ],
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
