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
import '../../../profile/domain/portfolio_item_model.dart';
import '../../../profile/domain/profile_model.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

/// Dedicated public details screen for a specific Professional profile.
class ProfessionalDetailPage extends ConsumerWidget {
  final String professionalId;

  const ProfessionalDetailPage({
    super.key,
    required this.professionalId,
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

  Future<void> _openWhatsApp(String whatsapp) async {
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

  Future<void> _openUrl(String? urlStr) async {
    if (urlStr == null || urlStr.trim().isEmpty) return;
    var formatted = urlStr.trim();
    if (!formatted.startsWith('http://') && !formatted.startsWith('https://')) {
      formatted = 'https://$formatted';
    }
    final uri = Uri.parse(formatted);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('[UrlLauncher] Launch error: $e');
    }
  }

  Future<void> _shareProfessional(BuildContext context, ProfileModel profile) async {
    try {
      final text = '${profile.fullName} - ${profile.city} Creative Professional on Rent App';
      final box = context.findRenderObject() as RenderBox?;
      final sharePositionOrigin = box != null && box.hasSize
          ? box.localToGlobal(Offset.zero) & box.size
          : null;

      await Share.share(
        text,
        subject: profile.fullName,
        sharePositionOrigin: sharePositionOrigin,
      );
    } catch (e) {
      debugPrint('[Share] error: $e');
    }
  }

  Widget _buildPublicPortfolioCard(BuildContext context, PortfolioItemModel item) {
    final coverUrl = item.mediaUrl;
    final externalUrl = item.externalUrl;
    final hasCover = coverUrl != null && coverUrl.trim().isNotEmpty;
    final hasExternal = externalUrl != null && externalUrl.trim().isNotEmpty;
    final gallery = item.galleryImages;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasCover)
            Stack(
              children: [
                SizedBox(
                  height: 160.0,
                  width: double.infinity,
                  child: coverUrl.startsWith('http')
                      ? Image.network(
                          coverUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPublicPlaceholderCover(item),
                        )
                      : Image.asset(
                          coverUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPublicPlaceholderCover(item),
                        ),
                ),
                Positioned(
                  top: AppSpacing.sm,
                  left: AppSpacing.sm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: AppColors.background.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      item.workType,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 11.0,
                      ),
                    ),
                  ),
                ),
                if (item.year != null)
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: AppColors.background.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Text(
                        item.year!,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 11.0,
                        ),
                      ),
                    ),
                  ),
              ],
            )
          else
            _buildPublicPlaceholderCover(item),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: AppTypography.heading.copyWith(fontSize: 15.5),
                      ),
                    ),
                    if (item.isVideo)
                      const Icon(Icons.play_circle_fill_rounded, color: AppColors.primary, size: 22.0),
                  ],
                ),
                if (item.userRole != null && item.userRole!.isNotEmpty) ...[
                  const SizedBox(height: 3.0),
                  Text(
                    item.userRole!,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.0,
                    ),
                  ),
                ],
                if (item.shortDescription.isNotEmpty) ...[
                  const SizedBox(height: 6.0),
                  Text(
                    item.shortDescription,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                ],
                if (gallery.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    height: 52.0,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: gallery.length,
                      separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
                      itemBuilder: (ctx, gIdx) {
                        final gUrl = gallery[gIdx];
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Container(
                            width: 52.0,
                            color: AppColors.surfaceElevated,
                            child: gUrl.startsWith('http')
                                ? Image.network(gUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image_outlined, size: 20.0, color: AppColors.textMuted))
                                : Image.asset(gUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image_outlined, size: 20.0, color: AppColors.textMuted)),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                if (hasExternal || hasCover) ...[
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    height: 36.0,
                    child: OutlinedButton.icon(
                      onPressed: () => _openUrl(hasExternal ? externalUrl : coverUrl),
                      icon: Icon(
                        item.isVideo ? Icons.play_arrow_rounded : Icons.open_in_new_rounded,
                        size: 16.0,
                      ),
                      label: Text(item.isVideo ? 'Watch Video / Showreel' : 'View Project'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
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
  }

  Widget _buildPublicPlaceholderCover(PortfolioItemModel item) {
    return Container(
      height: 90.0,
      width: double.infinity,
      color: AppColors.surfaceElevated,
      child: Stack(
        children: [
          Center(
            child: Icon(
              item.isVideo ? Icons.movie_outlined : Icons.palette_outlined,
              size: 32.0,
              color: AppColors.textMuted.withValues(alpha: 0.5),
            ),
          ),
          Positioned(
            top: AppSpacing.sm,
            left: AppSpacing.sm,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
              ),
              child: Text(
                item.workType,
                style: AppTypography.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 11.0,
                ),
              ),
            ),
          ),
          if (item.year != null)
            Positioned(
              top: AppSpacing.sm,
              right: AppSpacing.sm,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  item.year!,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 11.0,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final profileAsync = ref.watch(professionalDetailProvider(professionalId));
    final proProfileAsync = ref.watch(professionalProfileByIdProvider(professionalId));
    final proProfile = proProfileAsync.asData?.value;

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
            icon: const Icon(Icons.share_outlined, color: AppColors.textPrimary),
            onPressed: () {
              final pro = profileAsync.asData?.value;
              if (pro != null) _shareProfessional(context, pro);
            },
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, stack) => Center(
          child: Text(
            l10n.networkError,
            style: AppTypography.body.copyWith(color: AppColors.error),
          ),
        ),
        data: (profile) {
          if (profile == null) {
            return const Center(
              child: Text('Professional profile not found.'),
            );
          }

          final phone = profile.phone ?? '';
          final whatsapp = profile.whatsapp ?? '';
          final hasPhone = phone.isNotEmpty;
          final hasWhatsapp = whatsapp.isNotEmpty;
          final isFav = ref.watch(isProfessionalFavoriteProvider(profile.id));

          final locationText = '${profile.city}${profile.area != null && profile.area!.isNotEmpty ? ', ${profile.area}' : ''}';

          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Professional Header Card
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Profile Photo Avatar
                                  Container(
                                    width: 72.0,
                                    height: 72.0,
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceElevated,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.border),
                                    ),
                                    child: ClipOval(
                                      child: (profile.profilePhoto != null && profile.profilePhoto!.isNotEmpty)
                                          ? (profile.profilePhoto!.startsWith('http')
                                              ? Image.network(
                                                  profile.profilePhoto!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (ctx, err, stack) => Center(
                                                    child: Text(
                                                      profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : 'P',
                                                      style: AppTypography.heading.copyWith(
                                                        color: AppColors.primary,
                                                        fontSize: 24.0,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : Image.asset(
                                                  profile.profilePhoto!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (ctx, err, stack) => Center(
                                                    child: Text(
                                                      profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : 'P',
                                                      style: AppTypography.heading.copyWith(
                                                        color: AppColors.primary,
                                                        fontSize: 24.0,
                                                      ),
                                                    ),
                                                  ),
                                                ))
                                          : Center(
                                              child: Text(
                                                profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : 'P',
                                                style: AppTypography.heading.copyWith(
                                                  color: AppColors.primary,
                                                  fontSize: 24.0,
                                                ),
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
                                                profile.fullName,
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
                                          profile.businessName ?? l10n.creativeProfessional,
                                          style: AppTypography.caption.copyWith(
                                            color: AppColors.primary,
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4.0),
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
                                                locationText,
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
                                  IconButton(
                                    icon: Icon(
                                      isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                      color: isFav ? AppColors.error : AppColors.textMuted,
                                      size: 22.0,
                                    ),
                                    onPressed: () async {
                                      final user = ref.read(currentUserProvider);
                                      if (user == null) {
                                        context.push('/login');
                                        return;
                                      }
                                      await ref
                                          .read(userFavoritesTargetNotifierProvider(
                                            UserFavoritesTargetKey(userId: user.id, targetType: 'professional'),
                                          ).notifier)
                                          .toggleFavorite(userId: user.id, targetId: profile.id);
                                    },
                                  ),
                                ],
                              ),

                              if (profile.businessDescription != null &&
                                  profile.businessDescription!.isNotEmpty) ...[
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  profile.businessDescription!,
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

                        // Experience & Overview Info Box
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14.0),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            children: [
                              _buildDetailRow(
                                icon: Icons.badge_outlined,
                                label: 'Account Type',
                                value: profile.accountType?.toUpperCase() ?? 'PROFESSIONAL',
                              ),
                              const Divider(color: AppColors.border, height: AppSpacing.md),
                              _buildDetailRow(
                                icon: Icons.payments_outlined,
                                label: 'Starting Rate',
                                value: proProfile?.formattedPrice ?? 'Contact for Price',
                              ),
                              const Divider(color: AppColors.border, height: AppSpacing.md),
                              _buildDetailRow(
                                icon: Icons.location_city_outlined,
                                label: 'Location',
                                value: locationText,
                              ),
                            ],
                          ),
                        ),

                        if (proProfile != null && proProfile.allSocialLinks.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            'Social & Profile Links',
                            style: AppTypography.heading.copyWith(fontSize: 17.0, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Wrap(
                            spacing: AppSpacing.xs,
                            runSpacing: AppSpacing.xs,
                            children: proProfile.allSocialLinks.map((link) {
                              return ActionChip(
                                avatar: Icon(link.icon, size: 16.0, color: AppColors.primary),
                                label: Text(
                                  link.label,
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                backgroundColor: AppColors.surface,
                                side: const BorderSide(color: AppColors.border),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                onPressed: () => _openUrl(link.url),
                              );
                            }).toList(),
                          ),
                        ],

                        if (proProfile != null && proProfile.portfolioItems.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            'Portfolio & Work',
                            style: AppTypography.heading.copyWith(fontSize: 17.0, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: proProfile.portfolioItems.length,
                            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                            itemBuilder: (ctx, idx) {
                              final item = proProfile.portfolioItems[idx];
                              return _buildPublicPortfolioCard(ctx, item);
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Bottom Contact Action Bar
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
                                label: const Text('Call Professional'),
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
                                onPressed: () => _openWhatsApp(whatsapp),
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
