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
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../providers/equipment_providers.dart';
import '../widgets/equipment_card.dart';

/// Screen listing all equipment owned by the current logged-in user with approval status badges.
class MyEquipmentPage extends ConsumerWidget {
  const MyEquipmentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final myEquipmentAsync = ref.watch(myEquipmentProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: l10n.myEquipment,
        subtitle: l10n.equipmentSubtitle,
        showBackButton: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-equipment'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          l10n.addEquipment,
          style: AppTypography.button.copyWith(
            color: AppColors.background,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: myEquipmentAsync.when(
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
                description: l10n.noEquipmentDesc,
                actionLabel: l10n.addEquipment,
                onActionTap: () => context.push('/add-equipment'),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(myEquipmentProvider);
                await ref.read(myEquipmentProvider.future);
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
                  childAspectRatio: 0.90,
                ),
                itemBuilder: (context, index) {
                  final equipment = items[index];
                  final isFav = ref.watch(isEquipmentFavoriteProvider(equipment.id));
                  return Stack(
                    children: [
                      EquipmentCard(
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
                        onEditTap: () => context.push('/edit-equipment/${equipment.id}', extra: equipment),
                        onTap: () => context.push('/equipment/${equipment.id}'),
                      ),
                      // Approval Status Badge Overlay
                      Positioned(
                        top: AppSpacing.xs + 2,
                        left: AppSpacing.xs + 2,
                        child: _buildStatusBadge(context, l10n, equipment.approvalStatus),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, AppLocalizations l10n, String status) {
    Color badgeBg;
    Color badgeBorder;
    Color badgeText;
    IconData statusIcon;
    String labelText;

    switch (status.toLowerCase()) {
      case 'approved':
        badgeBg = AppColors.success.withValues(alpha: 0.15);
        badgeBorder = AppColors.success.withValues(alpha: 0.4);
        badgeText = AppColors.success;
        statusIcon = Icons.check_circle_outline_rounded;
        labelText = l10n.approved;
        break;
      case 'rejected':
        badgeBg = AppColors.error.withValues(alpha: 0.15);
        badgeBorder = AppColors.error.withValues(alpha: 0.4);
        badgeText = AppColors.error;
        statusIcon = Icons.cancel_outlined;
        labelText = l10n.rejected;
        break;
      case 'suspended':
        badgeBg = AppColors.error.withValues(alpha: 0.15);
        badgeBorder = AppColors.error.withValues(alpha: 0.4);
        badgeText = AppColors.error;
        statusIcon = Icons.pause_circle_outline_rounded;
        labelText = l10n.suspended;
        break;
      case 'pending':
      default:
        badgeBg = AppColors.accentGold.withValues(alpha: 0.15);
        badgeBorder = AppColors.accentGold.withValues(alpha: 0.4);
        badgeText = AppColors.accentGold;
        statusIcon = Icons.schedule_rounded;
        labelText = l10n.pendingReview;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs + 2,
        vertical: AppSpacing.xxs + 1,
      ),
      decoration: BoxDecoration(
        color: badgeBg,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: badgeBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, color: badgeText, size: 12.0),
          const SizedBox(width: 3.0),
          Text(
            labelText,
            style: AppTypography.label.copyWith(
              color: badgeText,
              fontSize: 10.0,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
