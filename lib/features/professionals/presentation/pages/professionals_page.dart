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
import '../../../profile/presentation/providers/profile_provider.dart';
import '../widgets/professional_card.dart';

/// Creative Professionals discovery screen connected dynamically to Supabase database.
class ProfessionalsPage extends ConsumerStatefulWidget {
  final String? initialCategory;

  const ProfessionalsPage({
    super.key,
    this.initialCategory,
  });

  @override
  ConsumerState<ProfessionalsPage> createState() => _ProfessionalsPageState();
}

class _ProfessionalsPageState extends ConsumerState<ProfessionalsPage> {
  int _selectedCategoryIndex = 0;
  String _activeSearchQuery = '';
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _syncCategoryWithL10n(List<String> categories, AppLocalizations l10n) {
    if (widget.initialCategory != null && widget.initialCategory!.isNotEmpty) {
      final query = widget.initialCategory!.toLowerCase();
      
      // Match specific role names or department categories
      if (query.contains('editor') || query == l10n.catEditors.toLowerCase()) {
        final idx = categories.indexWhere((c) => c.toLowerCase() == l10n.catPostProduction.toLowerCase());
        if (idx != -1) _selectedCategoryIndex = idx;
      } else if (query.contains('colorist') || query == l10n.catColorists.toLowerCase()) {
        final idx = categories.indexWhere((c) => c.toLowerCase() == l10n.catPostProduction.toLowerCase());
        if (idx != -1) _selectedCategoryIndex = idx;
      } else if (query.contains('photographer') || query == l10n.catPhotographers.toLowerCase()) {
        final idx = categories.indexWhere((c) => c.toLowerCase() == l10n.catCameras.toLowerCase());
        if (idx != -1) _selectedCategoryIndex = idx;
      } else if (query.contains('stylist') || query == l10n.catStylists.toLowerCase()) {
        final idx = categories.indexWhere((c) => c.toLowerCase() == l10n.catArtStyling.toLowerCase());
        if (idx != -1) _selectedCategoryIndex = idx;
      } else {
        final idx = categories.indexWhere((c) => c.toLowerCase() == query);
        if (idx != -1) _selectedCategoryIndex = idx;
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

    final categories = [
      l10n.catAll,
      l10n.catCameras,
      l10n.catProduction,
      l10n.catPostProduction,
      l10n.catSound,
      l10n.catArtStyling,
    ];

    _syncCategoryWithL10n(categories, l10n);

    final selectedCategory = _selectedCategoryIndex == 0 ? null : categories[_selectedCategoryIndex];

    final filterParams = ProfessionalFilterParams(
      category: selectedCategory,
      searchQuery: _activeSearchQuery.isNotEmpty ? _activeSearchQuery : null,
    );

    final professionalsAsync = ref.watch(publicApprovedProfessionalsFilterProvider(filterParams));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: l10n.navProfessionals,
        subtitle: l10n.professionalsSubtitle,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: AppSearchField(
                hintText: l10n.searchProfessionalsHint,
                onChanged: _onSearchInputChanged,
                onFilterTap: () {},
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Category Chips
            SizedBox(
              height: 38.0,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, index) {
                  return CategoryChip(
                    label: categories[index],
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

            // Professionals Grid loaded dynamically from Supabase
            Expanded(
              child: professionalsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (err, stack) => Center(
                  child: Text(
                    l10n.networkError,
                    style: AppTypography.body.copyWith(color: AppColors.error),
                  ),
                ),
                data: (professionals) {
                  if (professionals.isEmpty) {
                    return const EmptyState(
                      icon: Icons.person_search_outlined,
                      title: 'No Professionals Found',
                      description: 'No approved professionals available under this filter yet.',
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(publicApprovedProfessionalsFilterProvider);
                      await ref.read(publicApprovedProfessionalsFilterProvider(filterParams).future);
                    },
                    color: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: professionals.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final pro = professionals[index];
                        final isFav = ref.watch(isProfessionalFavoriteProvider(pro.id));
                        final locationText = '${pro.city}${pro.area != null && pro.area!.isNotEmpty ? ', ${pro.area}' : ''}';

                        return ProfessionalCard(
                          isHomeVariant: false,
                          name: pro.fullName,
                          role: (pro.businessName != null && pro.businessName!.isNotEmpty)
                              ? pro.businessName!
                              : l10n.creativeProfessional,
                          specializationChips: index % 2 == 0
                              ? const ['Commercials', 'Music Videos']
                              : const ['Film', 'Commercials'],
                          portfolioThumbnails: const [
                            'assets/images/sony_fx3.jpg',
                            'assets/images/sony_fx3.jpg',
                          ],
                          yearsOfExperience: '${(8 - index % 3)} years experience',
                          imagePath: pro.profilePhoto,
                          location: locationText,
                          isVerified: true,
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
                                  .read(userFavoritesTargetNotifierProvider(
                                    UserFavoritesTargetKey(userId: user.id, targetType: 'professional'),
                                  ).notifier)
                                  .toggleFavorite(userId: user.id, targetId: pro.id);
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
                          onTap: () => context.push('/professionals/${pro.id}'),
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
