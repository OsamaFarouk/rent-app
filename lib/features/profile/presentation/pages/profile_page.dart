import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/profile_model.dart';
import '../providers/profile_provider.dart';

/// Profile screen dynamically rendering Guest State or Authenticated User State.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: l10n.navProfile,
        subtitle: l10n.profileSubtitle,
      ),
      body: SafeArea(
        child: user == null
            ? _GuestProfileView(l10n: l10n)
            : _AuthenticatedProfileView(l10n: l10n, userId: user.id),
      ),
    );
  }
}

class _GuestProfileView extends StatelessWidget {
  final AppLocalizations l10n;

  const _GuestProfileView({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),

          // Guest Header Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Container(
                  width: 64.0,
                  height: 64.0,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceElevated,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person_outline_rounded,
                      color: AppColors.primary,
                      size: 32.0,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.yourProfile,
                  style: AppTypography.heading.copyWith(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.profileDesc,
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13.0,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                // Action CTAs
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44.0,
                        child: ElevatedButton(
                          onPressed: () => context.push('/login'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.background,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            l10n.signIn,
                            style: AppTypography.button.copyWith(
                              color: AppColors.background,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: SizedBox(
                        height: 44.0,
                        child: OutlinedButton(
                          onPressed: () => context.push('/register'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          child: Text(
                            l10n.createAccount,
                            style: AppTypography.button.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Provider Features Overview Preview
          Text(
            l10n.discoveryMarketplace,
            style: AppTypography.sectionTitle,
          ),
          const SizedBox(height: AppSpacing.sm),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            childAspectRatio: 1.6,
            children: [
              _buildFeatureTile(
                icon: Icons.camera_alt_outlined,
                title: l10n.myListings,
                subtitle: l10n.equipmentSubtitle,
              ),
              _buildFeatureTile(
                icon: Icons.movie_creation_outlined,
                title: l10n.portfolio,
                subtitle: l10n.professionalsSubtitle,
              ),
              _buildFeatureTile(
                icon: Icons.favorite_border_rounded,
                title: l10n.savedItems,
                subtitle: l10n.favoritesSubtitle,
              ),
              _buildFeatureTile(
                icon: Icons.contacts_outlined,
                title: l10n.contacts,
                subtitle: l10n.verified,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary, size: 22.0),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: AppTypography.title.copyWith(fontSize: 13.0),
          ),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.label.copyWith(fontSize: 10.0),
          ),
        ],
      ),
    );
  }
}

class _AuthenticatedProfileView extends ConsumerWidget {
  final AppLocalizations l10n;
  final String userId;

  const _AuthenticatedProfileView({
    required this.l10n,
    required this.userId,
  });

  int _calculateCompletionScore(ProfileModel? profile) {
    if (profile == null) return 100;
    int score = 0;
    if (profile.profilePhoto != null && profile.profilePhoto!.isNotEmpty) score += 25;
    if (profile.phone != null && profile.phone!.isNotEmpty) score += 25;
    if (profile.city.isNotEmpty && profile.area != null && profile.area!.isNotEmpty) score += 25;
    if (profile.accountType != null && profile.accountType!.isNotEmpty) score += 25;
    return score;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),

          // User Header Card & Profile Completion
          profileAsync.when(
            loading: () => Container(
              height: 140.0,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
            error: (err, stack) => Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Text(l10n.networkError),
            ),
            data: (profile) {
              if (profile != null && (profile.accountType == null || profile.accountType!.isEmpty)) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) {
                    context.go('/profile-setup');
                  }
                });
              }

              final isBusiness = profile?.isBusiness ?? false;
              final isProfessional = profile?.isProfessional ?? false;
              final displayName = profile?.fullName ?? 'User';
              final email = profile?.email ?? ref.read(currentUserProvider)?.email ?? '';
              final completionScore = _calculateCompletionScore(profile);

              String badgeText = l10n.profileTypePersonal;
              if (isBusiness) {
                badgeText = l10n.profileTypeBusiness;
              } else if (isProfessional) {
                badgeText = l10n.profileTypeProfessional;
              }

              return Column(
                children: [
                  // Top Profile Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 76px Avatar
                            Container(
                              width: 76.0,
                              height: 76.0,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevated,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.border, width: 2.0),
                              ),
                              child: ClipOval(
                                child: (profile?.profilePhoto != null &&
                                        profile!.profilePhoto!.isNotEmpty)
                                    ? Image.network(
                                        profile.profilePhoto!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (ctx, err, stack) => Center(
                                          child: Text(
                                            displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                                            style: AppTypography.heading.copyWith(
                                              color: AppColors.primary,
                                              fontSize: 28.0,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Center(
                                        child: Text(
                                          displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                                          style: AppTypography.heading.copyWith(
                                            color: AppColors.primary,
                                            fontSize: 28.0,
                                            fontWeight: FontWeight.w700,
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
                                  // Name & Type Badge
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          displayName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTypography.heading.copyWith(
                                            fontSize: 19.0,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.xs + 3,
                                          vertical: AppSpacing.xxs,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primarySoft,
                                          borderRadius: BorderRadius.circular(8.0),
                                          border: Border.all(
                                            color: AppColors.primary.withValues(alpha: 0.35),
                                          ),
                                        ),
                                        child: Text(
                                          badgeText,
                                          style: AppTypography.label.copyWith(
                                            color: AppColors.primary,
                                            fontSize: 10.0,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.xs),

                                  // Email
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.mail_outline_rounded,
                                        size: 14.0,
                                        color: AppColors.textMuted,
                                      ),
                                      const SizedBox(width: 4.0),
                                      Expanded(
                                        child: Text(
                                          email,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTypography.caption.copyWith(
                                            color: AppColors.textSecondary,
                                            fontSize: 12.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3.0),

                                  // Location
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on_outlined,
                                        size: 14.0,
                                        color: AppColors.textMuted,
                                      ),
                                      const SizedBox(width: 4.0),
                                      Expanded(
                                        child: Text(
                                          '${profile?.city ?? "Egypt"}${profile?.area != null && profile!.area!.isNotEmpty ? ', ${profile.area}' : ''}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTypography.caption.copyWith(
                                            color: AppColors.textMuted,
                                            fontSize: 11.5,
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

                        const SizedBox(height: AppSpacing.md),

                        // Edit Profile Button
                        SizedBox(
                          width: double.infinity,
                          height: 42.0,
                          child: OutlinedButton.icon(
                            onPressed: () => context.push('/edit-profile'),
                            icon: const Icon(
                              Icons.edit_outlined,
                              size: 16.0,
                              color: AppColors.primary,
                            ),
                            label: Text(
                              l10n.editProfile,
                              style: AppTypography.button.copyWith(
                                color: AppColors.primary,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: AppColors.primary.withValues(alpha: 0.5),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Profile Completion Banner (Only when < 100%)
                  if (completionScore < 100) ...[
                    const SizedBox(height: AppSpacing.md),
                    GestureDetector(
                      onTap: () => context.push('/edit-profile'),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14.0),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 40.0,
                                  height: 40.0,
                                  child: CircularProgressIndicator(
                                    value: completionScore / 100.0,
                                    backgroundColor: AppColors.surfaceElevated,
                                    color: AppColors.primary,
                                    strokeWidth: 3.5,
                                  ),
                                ),
                                Text(
                                  '$completionScore%',
                                  style: AppTypography.label.copyWith(
                                    color: AppColors.primary,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.profileCompletionHeader,
                                    style: AppTypography.title.copyWith(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2.0),
                                  Text(
                                    l10n.completeProfilePrompt,
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.textMuted,
                                      fontSize: 11.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14.0,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),

          const SizedBox(height: AppSpacing.xl),

          // Section 1: MY ACTIVITY
          Text(
            l10n.myActivitySection,
            style: AppTypography.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // Common for all account types: My Equipment
          _buildMenuTile(
            icon: Icons.inventory_2_outlined,
            title: l10n.myEquipment,
            subtitle: l10n.myEquipmentSubtitle,
            onTap: () => context.push('/my-equipment'),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Show Professional Profile menu item ONLY if profile is professional account
          profileAsync.maybeWhen(
            data: (profile) {
              if (profile == null) return const SizedBox.shrink();
              if (profile.isProfessional) {
                return Column(
                  children: [
                    _buildMenuTile(
                      icon: Icons.badge_outlined,
                      title: l10n.myProfessionalProfile,
                      subtitle: l10n.proProfileSubtitle,
                      onTap: () => context.push('/my-professional-profile'),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                );
              } else if (profile.isBusiness) {
                return Column(
                  children: [
                    _buildMenuTile(
                      icon: Icons.business_outlined,
                      title: l10n.myBusinessProfile,
                      subtitle: l10n.businessProfileSubtitle,
                      onTap: () => context.push('/my-business-profile'),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
            orElse: () => const SizedBox.shrink(),
          ),

          // Common for all account types: Favorites
          _buildMenuTile(
            icon: Icons.bookmark_outline_rounded,
            title: l10n.navFavorites,
            subtitle: l10n.favoritesSubtitle,
            onTap: () => context.push('/favorites'),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Section 2: ACCOUNT
          Text(
            l10n.accountSection,
            style: AppTypography.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          _buildMenuTile(
            icon: Icons.settings_outlined,
            title: l10n.settings,
            subtitle: l10n.settingsSubtitle,
            onTap: () {},
          ),

          const SizedBox(height: AppSpacing.xl),

          // Sign Out Button
          SizedBox(
            width: double.infinity,
            height: 48.0,
            child: OutlinedButton.icon(
              onPressed: () => ref.read(authNotifierProvider.notifier).signOut(),
              icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 18.0),
              label: Text(
                l10n.signOut,
                style: AppTypography.button.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailingStatus,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14.0),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          leading: Container(
            padding: const EdgeInsets.all(AppSpacing.xs + 2),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20.0),
          ),
          title: Text(
            title,
            style: AppTypography.title.copyWith(fontSize: 14.0),
          ),
          subtitle: Text(
            subtitle,
            style: AppTypography.caption.copyWith(
              color: AppColors.textMuted,
              fontSize: 11.5,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (trailingStatus != null) ...[
                trailingStatus,
                const SizedBox(width: AppSpacing.xs),
              ],
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
                size: 20.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
