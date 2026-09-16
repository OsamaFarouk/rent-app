import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../../equipment/presentation/widgets/equipment_card.dart';
import '../../domain/business_profile_model.dart';
import '../providers/business_providers.dart';

/// Dedicated public details screen for a specific Rental House / Business Profile.
class RentalHouseDetailPage extends ConsumerWidget {
  final String businessProfileId;

  const RentalHouseDetailPage({
    super.key,
    required this.businessProfileId,
  });

  Future<void> _makeCall(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleaned.isEmpty) return;
    final uri = Uri.parse('tel:$cleaned');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('[Call] Launch error: $e');
    }
  }

  Future<void> _openWhatsApp(String whatsapp, BuildContext context) async {
    final cleaned = whatsapp.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleaned.isEmpty) return;
    final uri = Uri.parse('https://wa.me/$cleaned');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('[WhatsApp] Launch error: $e');
    }
  }

  Future<void> _shareRentalHouse(BuildContext context, BusinessProfileModel business) async {
    try {
      final text = '${business.businessName}\n${business.city} - Rental House on Rent App';
      final box = context.findRenderObject() as RenderBox?;
      final sharePositionOrigin = box != null && box.hasSize
          ? box.localToGlobal(Offset.zero) & box.size
          : null;

      await Share.share(
        text,
        subject: business.businessName,
        sharePositionOrigin: sharePositionOrigin,
      );
    } catch (e) {
      debugPrint('[Share] error: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final businessProfileAsync = ref.watch(businessProfileDetailProvider(businessProfileId));
    final isFavorite = ref.watch(isBusinessFavoriteProvider(businessProfileId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFavorite ? AppColors.error : AppColors.textPrimary,
            ),
            onPressed: () async {
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
                      UserFavoritesTargetKey(userId: user.id, targetType: 'business'),
                    ).notifier)
                    .toggleFavorite(
                      userId: user.id,
                      targetId: businessProfileId,
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
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.textPrimary),
            onPressed: () {
              final biz = businessProfileAsync.asData?.value;
              if (biz != null) _shareRentalHouse(context, biz);
            },
          ),
        ],
      ),
      body: businessProfileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, stack) => Center(
          child: Text(
            l10n.networkError,
            style: AppTypography.body.copyWith(color: AppColors.error),
          ),
        ),
        data: (business) {
          if (business == null) {
            return const Center(
              child: Text('Rental House profile not found.'),
            );
          }

          final phone = business.phone ?? '';
          final whatsapp = business.whatsapp ?? '';
          final hasPhone = phone.isNotEmpty;
          final hasWhatsapp = whatsapp.isNotEmpty;
          final equipmentAsync = ref.watch(businessOwnerEquipmentProvider(business.userId));

          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Business Header Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16.0),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // Logo Avatar
                                  Container(
                                    width: 68.0,
                                    height: 68.0,
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceElevated,
                                      borderRadius: BorderRadius.circular(14.0),
                                      border: Border.all(color: AppColors.border),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(14.0),
                                      child: (business.logoUrl != null && business.logoUrl!.isNotEmpty)
                                          ? Image.network(
                                              business.logoUrl!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (ctx, err, stack) => const Center(
                                                child: Icon(
                                                  Icons.storefront_outlined,
                                                  color: AppColors.primary,
                                                  size: 32.0,
                                                ),
                                              ),
                                            )
                                          : const Center(
                                              child: Icon(
                                                Icons.storefront_outlined,
                                                color: AppColors.primary,
                                                size: 32.0,
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                business.businessName,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: AppTypography.heading.copyWith(
                                                  fontSize: 19.0,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 4.0),
                                            const Icon(
                                              Icons.verified_rounded,
                                              color: AppColors.primary,
                                              size: 18.0,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 3.0),
                                        Text(
                                          l10n.rentalHouseOwner,
                                          style: AppTypography.caption.copyWith(
                                            color: AppColors.primary,
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 3.0),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.location_on_outlined,
                                              size: 13.0,
                                              color: AppColors.textMuted,
                                            ),
                                            const SizedBox(width: 3.0),
                                            Expanded(
                                              child: Text(
                                                '${business.city}${business.area != null && business.area!.isNotEmpty ? ', ${business.area}' : ''}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: AppTypography.caption.copyWith(
                                                  color: AppColors.textMuted,
                                                  fontSize: 12.0,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              if (business.businessDescription != null &&
                                  business.businessDescription!.isNotEmpty) ...[
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  business.businessDescription!,
                                  style: AppTypography.body.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 13.0,
                                    height: 1.45,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // Contact & Hours Info Box
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14.0),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            children: [
                              if (business.businessAddress != null && business.businessAddress!.isNotEmpty) ...[
                                _buildDetailRow(
                                  icon: Icons.location_city_outlined,
                                  label: l10n.fullAddressLabel,
                                  value: business.businessAddress!,
                                ),
                                const Divider(color: AppColors.border, height: AppSpacing.md),
                              ],
                              if (business.workingHours != null && business.workingHours!.isNotEmpty) ...[
                                _buildDetailRow(
                                  icon: Icons.access_time_rounded,
                                  label: l10n.workingHoursLabel,
                                  value: business.workingHours!,
                                ),
                                const Divider(color: AppColors.border, height: AppSpacing.md),
                              ],
                              if (business.websiteUrl != null && business.websiteUrl!.isNotEmpty) ...[
                                _buildDetailRow(
                                  icon: Icons.language_outlined,
                                  label: l10n.websiteUrlLabel,
                                  value: business.websiteUrl!,
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // Equipment from this Rental House Section
                        Text(
                          l10n.equipmentFromThisRentalHouse,
                          style: AppTypography.sectionTitle,
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        equipmentAsync.when(
                          loading: () => const Center(
                            child: CircularProgressIndicator(color: AppColors.primary),
                          ),
                          error: (err, stack) => Text(
                            l10n.networkError,
                            style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                          ),
                          data: (items) {
                            if (items.isEmpty) {
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(AppSpacing.lg),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(14.0),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Text(
                                  l10n.noEquipmentTitle,
                                  textAlign: TextAlign.center,
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.textMuted,
                                    fontSize: 12.5,
                                  ),
                                ),
                              );
                            }

                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: items.length,
                              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                              itemBuilder: (context, index) {
                                final item = items[index];
                                final priceText = l10n.fromPrice(item.dailyPrice.toStringAsFixed(0)) + l10n.perDay;

                                return EquipmentCard(
                                  imagePath: item.primaryImageUrl ?? 'assets/images/sony_fx3.jpg',
                                  title: item.name,
                                  price: priceText,
                                  location: item.formattedLocation,
                                  rating: '5.0',
                                  reviewsCount: '',
                                  onTap: () => context.push('/equipment/${item.id}'),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Contact Bar
                if (hasPhone || hasWhatsapp)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      border: Border(top: BorderSide(color: AppColors.border)),
                    ),
                    child: Row(
                      children: [
                        if (hasPhone) ...[
                          Expanded(
                            child: SizedBox(
                              height: 46.0,
                              child: OutlinedButton.icon(
                                onPressed: () => _makeCall(phone),
                                icon: const Icon(Icons.phone_outlined, size: 18.0),
                                label: const Text('Call Office'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.textPrimary,
                                  side: const BorderSide(color: AppColors.border),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (hasWhatsapp) const SizedBox(width: AppSpacing.sm),
                        ],
                        if (hasWhatsapp) ...[
                          Expanded(
                            child: SizedBox(
                              height: 46.0,
                              child: ElevatedButton.icon(
                                onPressed: () => _openWhatsApp(whatsapp, context),
                                icon: const Icon(Icons.chat_outlined, size: 18.0),
                                label: const Text('WhatsApp'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.background,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16.0, color: AppColors.primary),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 11.0,
                ),
              ),
              const SizedBox(height: 1.0),
              Text(
                value,
                style: AppTypography.body.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 13.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
