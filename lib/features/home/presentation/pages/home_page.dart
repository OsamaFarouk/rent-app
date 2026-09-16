import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_search_field.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../equipment/presentation/providers/equipment_providers.dart';
import '../../../equipment/presentation/widgets/equipment_card.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../../professionals/presentation/widgets/professional_card.dart';
import '../../../profile/presentation/providers/business_providers.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../profile/presentation/widgets/rental_house_card.dart';
import '../../../search/presentation/pages/search_results_page.dart';

/// Home Screen with interactive location selector, functional search bar, and discovery sections.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  String _liveSearchQuery = '';
  bool _isCategoriesExpanded = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchInputChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchInputChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchInputChanged() {
    _debounceTimer?.cancel();
    final trimmed = _searchController.text.trim();
    if (trimmed.length < 2) {
      if (_liveSearchQuery.isNotEmpty) {
        setState(() {
          _liveSearchQuery = '';
        });
      }
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        setState(() {
          _liveSearchQuery = trimmed;
        });
      }
    });
  }

  void _onSearchSubmitted(String query) {
    final trimmed = query.trim();
    if (trimmed.isNotEmpty) {
      context.push('/search?q=${Uri.encodeComponent(trimmed)}');
    }
  }

  Widget _buildHeroHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'GOOD TO SEE YOU',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 11.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4.0),
                RichText(
                  text: TextSpan(
                    style: AppTypography.heading.copyWith(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      color: AppColors.textPrimary,
                    ),
                    children: const [
                      TextSpan(text: 'Find the right gear for your '),
                      TextSpan(
                        text: 'next story',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.movie_creation_outlined,
                      color: AppColors.primary,
                      size: 15.0,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      'STUDIO',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primary,
                        fontSize: 10.0,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3.0),
                Container(
                  height: 2.0,
                  width: 32.0,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(1.0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> cat) {
    final catName = cat['name'] as String;
    final catType = cat['type'] as String;

    return GestureDetector(
      onTap: () {
        final targetRoute = catType == 'equipment'
            ? '/equipment?category=${Uri.encodeComponent(catName)}'
            : '/professionals?category=${Uri.encodeComponent(catName)}';
        context.go(targetRoute);
      },
      child: Container(
        width: 78.0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xs + 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                cat['icon'] as IconData,
                color: AppColors.primary,
                size: 18.0,
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              catName,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final mainCategories = [
      {
        'name': l10n.catCameras,
        'icon': Icons.camera_alt_outlined,
        'type': 'equipment',
      },
      {
        'name': l10n.catLenses,
        'icon': Icons.center_focus_strong_outlined,
        'type': 'equipment',
      },
      {
        'name': l10n.catLighting,
        'icon': Icons.lightbulb_outline_rounded,
        'type': 'equipment',
      },
      {
        'name': l10n.catAudio,
        'icon': Icons.mic_none_rounded,
        'type': 'equipment',
      },
      {
        'name': l10n.catEditors,
        'icon': Icons.video_settings_outlined,
        'type': 'professional',
      },
      {
        'name': l10n.catPhotographers,
        'icon': Icons.photo_camera_outlined,
        'type': 'professional',
      },
      {
        'name': l10n.catColorists,
        'icon': Icons.color_lens_outlined,
        'type': 'professional',
      },
      {
        'name': l10n.catStylists,
        'icon': Icons.content_cut_outlined,
        'type': 'professional',
      },
    ];

    final extraCategories = [
      {
        'name': l10n.catGripSupport,
        'icon': Icons.build_outlined,
        'type': 'equipment',
      },
      {
        'name': l10n.catDrones,
        'icon': Icons.flight_outlined,
        'type': 'equipment',
      },
      {
        'name': l10n.catDirectors,
        'icon': Icons.movie_creation_outlined,
        'type': 'professional',
      },
      {
        'name': l10n.catCinematographers,
        'icon': Icons.videocam_outlined,
        'type': 'professional',
      },
      {
        'name': l10n.catSoundEngineers,
        'icon': Icons.graphic_eq_rounded,
        'type': 'professional',
      },
    ];

    final categories = _isCategoriesExpanded
        ? [...mainCategories, ...extraCategories]
        : mainCategories;

    final isSearching = _liveSearchQuery.length >= 2;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),

              // Top Hero / Header Header Section
              _buildHeroHeader(context),

              const SizedBox(height: AppSpacing.md),

              // Search Bar Header
              AppSearchField(
                hintText: 'Search equipment, professionals, brands...',
                controller: _searchController,
                onSubmitted: _onSearchSubmitted,
                onFilterTap: () => context.push('/search'),
              ),

              const SizedBox(height: AppSpacing.lg),

              if (isSearching)
                _buildLiveSearchResults(context, ref, l10n, _liveSearchQuery)
              else ...[
                // Browse Categories Section Header with Show all / Show less toggle
                SectionHeader(
                  title: l10n.browseCategories,
                  actionTitle: _isCategoriesExpanded ? l10n.showLess : l10n.showAll,
                  onActionTap: () {
                    setState(() {
                      _isCategoriesExpanded = !_isCategoriesExpanded;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.sm),

                // Compact Horizontal List or Expanded Grid
                if (!_isCategoriesExpanded)
                  SizedBox(
                    height: 78.0,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: AppSpacing.xs + 2),
                      itemBuilder: (context, index) {
                        return _buildCategoryCard(categories[index]);
                      },
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: AppSpacing.xs + 2,
                      crossAxisSpacing: AppSpacing.xs + 2,
                      childAspectRatio: 0.95,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      return _buildCategoryCard(categories[index]);
                    },
                  ),

                const SizedBox(height: AppSpacing.xl),

                // Featured Equipment Section
                SectionHeader(
                  title: l10n.featuredEquipment,
                  actionTitle: l10n.seeAll,
                  onActionTap: () => context.go('/equipment'),
                ),
                const SizedBox(height: AppSpacing.sm),

                SizedBox(
                  height: 205.0,
                  child: Consumer(
                    builder: (context, ref, child) {
                      const filterParams = EquipmentFilterParams();
                      final equipmentAsync =
                          ref.watch(publicApprovedEquipmentProvider(filterParams));
                      return equipmentAsync.when(
                        loading: () => const Center(
                          child: CircularProgressIndicator(color: AppColors.primary),
                        ),
                        error: (err, stack) => Center(
                          child: Text(
                            l10n.networkError,
                            style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                          ),
                        ),
                        data: (items) {
                          if (items.isEmpty) {
                            return Center(
                              child: Text(
                                l10n.noEquipmentTitle,
                                style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                              ),
                            );
                          }
                          return ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: items.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: AppSpacing.md),
                            itemBuilder: (context, index) {
                              final item = items[index];
                              final isFav = ref.watch(isEquipmentFavoriteProvider(item.id));
                              final firstImage = item.primaryImageUrl;
                              final priceText =
                                  l10n.fromPrice(item.dailyPrice.toStringAsFixed(0)) + l10n.perDay;
                              final locationText = item.formattedLocation;

                              return EquipmentCard(
                                isHomeVariant: true,
                                width: 210.0,
                                imagePath: firstImage ?? 'assets/images/sony_fx3.jpg',
                                title: item.name,
                                price: priceText,
                                location:
                                    locationText.isNotEmpty ? locationText : l10n.locationMaadi,
                                availability: 'Available',
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
                                        .read(userFavoritesNotifierProvider(user.id).notifier)
                                        .toggleFavorite(
                                          userId: user.id,
                                          equipmentId: item.id,
                                        );
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content:
                                              Text('Failed to update favorites: ${e.toString()}'),
                                          backgroundColor: AppColors.error,
                                        ),
                                      );
                                    }
                                  }
                                },
                                onTap: () => context.push('/equipment/${item.id}'),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Featured Professionals Section
                SectionHeader(
                  title: l10n.featuredProfessionals,
                  actionTitle: l10n.seeAll,
                  onActionTap: () => context.go('/professionals'),
                ),
                const SizedBox(height: AppSpacing.sm),

                SizedBox(
                  height: 128.0,
                  child: Consumer(
                    builder: (context, ref, child) {
                      final professionalsAsync =
                          ref.watch(publicApprovedProfessionalsProvider(null));
                      return professionalsAsync.when(
                        loading: () => const Center(
                          child: CircularProgressIndicator(color: AppColors.primary),
                        ),
                        error: (err, stack) => Center(
                          child: Text(
                            l10n.networkError,
                            style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                          ),
                        ),
                        data: (items) {
                          if (items.isEmpty) {
                            return ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                ProfessionalCard(
                                  isHomeVariant: true,
                                  width: 270.0,
                                  imagePath: 'assets/images/profile_ahmed.jpg',
                                  name: 'alex2',
                                  role: 'Creative Professional',
                                  location: 'Cairo',
                                  isVerified: true,
                                  specializationChips: const ['Cinematography', 'Directing'],
                                  onTap: () => context.go('/professionals'),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                ProfessionalCard(
                                  isHomeVariant: true,
                                  width: 270.0,
                                  imagePath: 'assets/images/profile_mona.jpg',
                                  name: 'ola',
                                  role: 'Creative Professional',
                                  location: 'Cairo Governorate',
                                  isVerified: true,
                                  specializationChips: const ['Photography', 'Editing'],
                                  onTap: () => context.go('/professionals'),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                ProfessionalCard(
                                  isHomeVariant: true,
                                  width: 270.0,
                                  imagePath: 'assets/images/profile_karim.jpg',
                                  name: 'Karim Salah',
                                  role: 'Creative Professional',
                                  location: 'Giza, Cairo',
                                  isVerified: true,
                                  specializationChips: const ['DOP', 'Colorist'],
                                  onTap: () => context.go('/professionals'),
                                ),
                              ],
                            );
                          }

                          return ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: items.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: AppSpacing.md),
                            itemBuilder: (context, index) {
                              final pro = items[index];
                              final locationStr = pro.area != null && pro.area!.isNotEmpty
                                  ? '${pro.city}, ${pro.area}'
                                  : pro.city;
                              final isFav = ref.watch(isProfessionalFavoriteProvider(pro.id));
                              final chipsList = index % 2 == 0
                                  ? const ['Cinematography', 'Directing']
                                  : const ['Photography', 'Editing'];

                              return ProfessionalCard(
                                isHomeVariant: true,
                                width: 270.0,
                                name: pro.fullName,
                                role: 'Creative Professional',
                                location: locationStr.isNotEmpty ? locationStr : 'Cairo',
                                isVerified: true,
                                imagePath: pro.profilePhoto,
                                isFavorite: isFav,
                                specializationChips: chipsList,
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
                                      .toggleFavorite(userId: user.id, targetId: pro.id);
                                },
                                onTap: () => context.push('/professionals/${pro.id}'),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Featured Rental Houses Section
                SectionHeader(
                  title: l10n.featuredRentalHouses,
                  actionTitle: l10n.seeAll,
                  onActionTap: () => context.go('/rental-houses'),
                ),
                const SizedBox(height: AppSpacing.sm),

                SizedBox(
                  height: 130.0,
                  child: Consumer(
                    builder: (context, ref, child) {
                      final businessProfilesAsync =
                          ref.watch(publicApprovedBusinessProfilesProvider(null));
                      return businessProfilesAsync.when(
                        loading: () => const Center(
                          child: CircularProgressIndicator(color: AppColors.primary),
                        ),
                        error: (err, stack) => Center(
                          child: Text(
                            l10n.networkError,
                            style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                          ),
                        ),
                        data: (items) {
                          if (items.isEmpty) {
                            return ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                RentalHouseCard(
                                  isHomeVariant: true,
                                  width: 340.0,
                                  businessName: 'FinCam',
                                  businessType: 'Equipment Rental House',
                                  city: 'Cairo Governorate',
                                  area: 'Masr El Kobba',
                                  isVerified: true,
                                  onTap: () => context.go('/rental-houses'),
                                ),
                              ],
                            );
                          }
                          return ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: items.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: AppSpacing.md),
                            itemBuilder: (context, index) {
                              final item = items[index];
                              final isFav = ref.watch(isBusinessFavoriteProvider(item.id));
                              return RentalHouseCard(
                                isHomeVariant: true,
                                width: 340.0,
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
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveSearchResults(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    String query,
  ) {
    final searchAsync = ref.watch(searchResultsProvider((query: query, city: null)));

    return searchAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (err, stack) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Center(
          child: Text(
            l10n.networkError,
            style: AppTypography.body.copyWith(color: AppColors.error),
          ),
        ),
      ),
      data: (results) {
        final eq = results.equipment;
        final pro = results.professionals;
        final rh = results.rentalHouses;

        if (eq.isEmpty && pro.isEmpty && rh.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
            child: Center(
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
                    'No results for "$query"',
                    style: AppTypography.title.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Try checking spelling or search another keyword.',
                    textAlign: TextAlign.center,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),

            // Live Search Equipment Section
            if (eq.isNotEmpty) ...[
              SectionHeader(
                title: '${l10n.navEquipment} (${eq.length})',
                actionTitle: l10n.seeAll,
                onActionTap: () => context.go('/equipment'),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: 205.0,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: eq.length,
                  separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final item = eq[index];
                    final isFav = ref.watch(isEquipmentFavoriteProvider(item.id));
                    final firstImage = item.primaryImageUrl;
                    final priceText =
                        l10n.fromPrice(item.dailyPrice.toStringAsFixed(0)) + l10n.perDay;
                    final locationText = item.formattedLocation;

                    return EquipmentCard(
                      isHomeVariant: true,
                      width: 210.0,
                      imagePath: firstImage ?? 'assets/images/sony_fx3.jpg',
                      title: item.name,
                      price: priceText,
                      location: locationText.isNotEmpty ? locationText : l10n.locationMaadi,
                      availability: 'Available',
                      isVerified: true,
                      isFavorite: isFav,
                      onFavoriteTap: () async {
                        final user = ref.read(currentUserProvider);
                        if (user == null) {
                          context.push('/login');
                          return;
                        }
                        await ref
                            .read(userFavoritesNotifierProvider(user.id).notifier)
                            .toggleFavorite(userId: user.id, equipmentId: item.id);
                      },
                      onTap: () => context.push('/equipment/${item.id}'),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],

            // Live Search Professionals Section
            if (pro.isNotEmpty) ...[
              SectionHeader(
                title: '${l10n.navProfessionals} (${pro.length})',
                actionTitle: l10n.seeAll,
                onActionTap: () => context.go('/professionals'),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: 84.0,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: pro.length,
                  separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final item = pro[index];
                    final locationStr = item.area != null && item.area!.isNotEmpty
                        ? '${item.city}, ${item.area}'
                        : item.city;
                    final isFav = ref.watch(isProfessionalFavoriteProvider(item.id));
                    return ProfessionalCard(
                      isHomeVariant: true,
                      width: 250.0,
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
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],

            // Live Search Rental Houses Section
            if (rh.isNotEmpty) ...[
              SectionHeader(
                title: '${l10n.navRentalHouses} (${rh.length})',
                actionTitle: l10n.seeAll,
                onActionTap: () => context.go('/rental-houses'),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: 84.0,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: rh.length,
                  separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final item = rh[index];
                    final isFav = ref.watch(isBusinessFavoriteProvider(item.id));
                    return RentalHouseCard(
                      isHomeVariant: true,
                      width: 260.0,
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
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ],
        );
      },
    );
  }
}
