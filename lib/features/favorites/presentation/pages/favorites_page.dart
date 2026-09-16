import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../equipment/presentation/widgets/equipment_card.dart';
import '../../../professionals/presentation/widgets/professional_card.dart';
import '../../../profile/presentation/widgets/rental_house_card.dart';
import '../providers/favorites_provider.dart';

/// 3-Tab Favorites screen displaying saved Equipment, Professionals, and Rental Houses.
class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentUser = ref.watch(currentUserProvider);

    if (currentUser == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: l10n.navFavorites,
          showBackButton: Navigator.of(context).canPop(),
        ),
        body: SafeArea(
          child: EmptyState(
            icon: Icons.favorite_border_rounded,
            title: l10n.noFavoritesTitle,
            description: l10n.noFavoritesDesc,
            actionLabel: l10n.signIn,
            onActionTap: () => context.push('/login'),
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: l10n.navFavorites,
          showBackButton: Navigator.of(context).canPop(),
        ),
        body: SafeArea(
          child: Column(
            children: [
              TabBar(
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                indicatorWeight: 2.5,
                labelStyle: AppTypography.label.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.0,
                ),
                unselectedLabelStyle: AppTypography.label.copyWith(
                  fontSize: 13.0,
                ),
                tabs: [
                  Tab(text: l10n.navEquipment),
                  Tab(text: l10n.navProfessionals),
                  Tab(text: l10n.navRentalHouses),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _EquipmentFavoritesTab(userId: currentUser.id),
                    _ProfessionalsFavoritesTab(userId: currentUser.id),
                    _RentalHousesFavoritesTab(userId: currentUser.id),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EquipmentFavoritesTab extends ConsumerWidget {
  final String userId;

  const _EquipmentFavoritesTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final favoritesAsync = ref.watch(userFavoriteEquipmentListProvider);

    return favoritesAsync.when(
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
            icon: Icons.favorite_border_rounded,
            title: l10n.noFavoritesTitle,
            description: l10n.noFavoritesDesc,
            actionLabel: l10n.explore,
            onActionTap: () => context.go('/equipment'),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(userFavoriteEquipmentListProvider);
            await ref.read(userFavoriteEquipmentListProvider.future);
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
              childAspectRatio: 0.94,
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
                  await ref
                      .read(userFavoritesNotifierProvider(userId).notifier)
                      .toggleFavorite(userId: userId, equipmentId: equipment.id);
                },
                onTap: () => context.push('/equipment/${equipment.id}'),
              );
            },
          ),
        );
      },
    );
  }
}

class _ProfessionalsFavoritesTab extends ConsumerWidget {
  final String userId;

  const _ProfessionalsFavoritesTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final favoritesAsync = ref.watch(userFavoriteProfessionalsListProvider);

    return favoritesAsync.when(
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
            icon: Icons.favorite_border_rounded,
            title: l10n.noFavoritesTitle,
            description: l10n.noFavoritesDesc,
            actionLabel: l10n.explore,
            onActionTap: () => context.go('/professionals'),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(userFavoriteProfessionalsListProvider);
            await ref.read(userFavoriteProfessionalsListProvider.future);
          },
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final pro = items[index];
              final isFav = ref.watch(isProfessionalFavoriteProvider(pro.id));
              final locationText = '${pro.city}${pro.area != null && pro.area!.isNotEmpty ? ', ${pro.area}' : ''}';

              return ProfessionalCard(
                isHomeVariant: false,
                name: pro.fullName,
                role: pro.profileType ?? l10n.creativeProfessional,
                imagePath: pro.profilePhoto,
                location: locationText,
                isVerified: true,
                isFavorite: isFav,
                onFavoriteTap: () async {
                  await ref
                      .read(userFavoritesTargetNotifierProvider(
                        UserFavoritesTargetKey(userId: userId, targetType: 'professional'),
                      ).notifier)
                      .toggleFavorite(userId: userId, targetId: pro.id);
                },
                onTap: () => context.push('/professionals/${pro.id}'),
              );
            },
          ),
        );
      },
    );
  }
}

class _RentalHousesFavoritesTab extends ConsumerWidget {
  final String userId;

  const _RentalHousesFavoritesTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final favoritesAsync = ref.watch(userFavoriteBusinessesListProvider);

    return favoritesAsync.when(
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
            icon: Icons.favorite_border_rounded,
            title: l10n.noFavoritesTitle,
            description: l10n.noFavoritesDesc,
            actionLabel: l10n.explore,
            onActionTap: () => context.go('/rental-houses'),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(userFavoriteBusinessesListProvider);
            await ref.read(userFavoriteBusinessesListProvider.future);
          },
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final business = items[index];
              final isFav = ref.watch(isBusinessFavoriteProvider(business.id));

              return RentalHouseCard(
                businessName: business.businessName,
                city: business.city,
                area: business.area,
                description: business.businessDescription,
                logoUrl: business.logoUrl,
                isVerified: business.isActive,
                isFavorite: isFav,
                onFavoriteTap: () async {
                  await ref
                      .read(userFavoritesTargetNotifierProvider(
                        UserFavoritesTargetKey(userId: userId, targetType: 'business'),
                      ).notifier)
                      .toggleFavorite(userId: userId, targetId: business.id);
                },
                onTap: () => context.push('/rental-houses/${business.id}'),
              );
            },
          ),
        );
      },
    );
  }
}

