import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Personal, Creative Talent Profile card for Creative Professionals.
class ProfessionalCard extends StatelessWidget {
  final String name;
  final String role;
  final String? rating;
  final String? imagePath;
  final String? location;
  final String? yearsOfExperience;
  final String? specialization;
  final List<String>? specializationChips;
  final List<String>? portfolioThumbnails;
  final bool isVerified;
  final bool isHomeVariant;
  final double? width;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  const ProfessionalCard({
    super.key,
    required this.name,
    required this.role,
    this.rating,
    this.imagePath,
    this.location,
    this.yearsOfExperience,
    this.specialization,
    this.specializationChips,
    this.portfolioThumbnails,
    this.isVerified = false,
    this.isHomeVariant = false,
    this.width,
    this.isFavorite = false,
    this.onTap,
    this.onFavoriteTap,
  });

  Widget _buildAvatar({required double size}) {
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        shape: BoxShape.circle,
        // Gold accent ring around artist avatar to emphasize creative profile identity
        border: Border.all(
          color: AppColors.primary,
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 10.0,
            spreadRadius: 1.0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: (imagePath != null && imagePath!.isNotEmpty)
            ? (imagePath!.startsWith('http://') || imagePath!.startsWith('https://')
                ? Image.network(
                    imagePath!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildFallbackLetter(size),
                  )
                : Image.asset(
                    imagePath!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildFallbackLetter(size),
                  ))
            : _buildFallbackLetter(size),
      ),
    );
  }

  Widget _buildFallbackLetter(double size) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'P',
        style: AppTypography.heading.copyWith(
          color: AppColors.primary,
          fontSize: size * 0.42,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildFavoriteButton() {
    if (onFavoriteTap == null) return const SizedBox.shrink();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onFavoriteTap,
      child: Container(
        width: 30.0,
        height: 30.0,
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.65),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: isFavorite ? AppColors.error : AppColors.textPrimary,
          size: 16.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayLocation = (location != null && location!.isNotEmpty)
        ? location!
        : 'Cairo';

    if (isHomeVariant) {
      return _buildHomeVariant(context, displayLocation);
    } else {
      return _buildPageVariant(context, displayLocation);
    }
  }

  /// Talent Profile Carousel Card for Home page matching media_1789474443432.png
  Widget _buildHomeVariant(BuildContext context, String displayLocation) {
    final cardWidth = width ?? 270.0;
    final chips = specializationChips ??
        (specialization != null ? [specialization!] : ['Cinematography', 'Directing']);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm + 2,
          vertical: AppSpacing.xs + 4,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          gradient: RadialGradient(
            center: const Alignment(-0.85, -0.6),
            radius: 1.25,
            colors: [
              AppColors.primary.withValues(alpha: 0.14),
              AppColors.surfaceSecondary.withValues(alpha: 0.0),
            ],
            stops: const [0.0, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildAvatar(size: 58.0),
                const SizedBox(width: AppSpacing.sm + 2),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(end: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Artist Name + Verification Badge
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.title.copyWith(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (isVerified) ...[
                              const SizedBox(width: 4.0),
                              const Icon(
                                Icons.verified_rounded,
                                color: AppColors.primary,
                                size: 14.5,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 1.5),

                        // Professional Title in Gold Accent
                        Text(
                          role.isNotEmpty ? role : 'Creative Professional',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.primary,
                            fontSize: 11.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2.0),

                        // Location Row
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: AppColors.textMuted,
                              size: 11.5,
                            ),
                            const SizedBox(width: 2.0),
                            Expanded(
                              child: Text(
                                displayLocation,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textMuted,
                                  fontSize: 10.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4.0),

                        // Specialization Chips Row
                        if (chips.isNotEmpty)
                          Wrap(
                            spacing: 4.0,
                            runSpacing: 4.0,
                            children: chips.take(2).map((chipText) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7.0,
                                  vertical: 2.0,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF24242A),
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.05),
                                  ),
                                ),
                                child: Text(
                                  chipText,
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Top Right Favorite Button
            PositionedDirectional(
              top: 0,
              end: 0,
              child: _buildFavoriteButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortraitAvatar({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: (imagePath != null && imagePath!.isNotEmpty)
          ? (imagePath!.startsWith('http://') || imagePath!.startsWith('https://')
              ? Image.network(
                  imagePath!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildFallbackLetter(width),
                )
              : Image.asset(
                  imagePath!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildFallbackLetter(width),
                ))
          : _buildFallbackLetter(width),
    );
  }

  /// Full-Width Talent Profile Card for Professionals Page matching middle screen of media_1789478544101.jpg
  Widget _buildPageVariant(BuildContext context, String displayLocation) {
    final chips = specializationChips ?? (specialization != null ? [specialization!] : ['Commercials', 'Music Videos']);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? double.infinity,
        padding: const EdgeInsets.all(AppSpacing.sm + 2),
        decoration: BoxDecoration(
          color: AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPortraitAvatar(width: 104.0, height: 136.0),
                const SizedBox(width: AppSpacing.sm + 4),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(end: 28.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Name + Verification Badge
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.title.copyWith(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (isVerified) ...[
                              const SizedBox(width: 4.0),
                              const Icon(
                                Icons.verified_rounded,
                                color: AppColors.primary,
                                size: 14.5,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 1.5),

                        // Professional Title
                        Text(
                          role.isNotEmpty ? role : 'Creative Professional',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2.0),

                        // Location Row
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: AppColors.textMuted,
                              size: 12.0,
                            ),
                            const SizedBox(width: 2.0),
                            Expanded(
                              child: Text(
                                displayLocation,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textMuted,
                                  fontSize: 10.5,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Years of Experience Text
                        if (yearsOfExperience != null && yearsOfExperience!.isNotEmpty) ...[
                          const SizedBox(height: 2.0),
                          Text(
                            yearsOfExperience!.contains('experience') || yearsOfExperience!.contains('exp')
                                ? yearsOfExperience!
                                : '$yearsOfExperience experience',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textMuted,
                              fontSize: 10.5,
                            ),
                          ),
                        ],

                        // Specialization Chips
                        if (chips.isNotEmpty) ...[
                          const SizedBox(height: 4.0),
                          Wrap(
                            spacing: 4.0,
                            runSpacing: 4.0,
                            children: chips.take(2).map((chipText) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7.0,
                                  vertical: 2.0,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF24242A),
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.05),
                                  ),
                                ),
                                child: Text(
                                  chipText,
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],

                        // Portfolio Thumbnails Row
                        if (portfolioThumbnails != null && portfolioThumbnails!.isNotEmpty) ...[
                          const SizedBox(height: 6.0),
                          Row(
                            children: portfolioThumbnails!.take(2).map((thumbPath) {
                              return Padding(
                                padding: const EdgeInsetsDirectional.only(end: 6.0),
                                child: Container(
                                  width: 56.0,
                                  height: 36.0,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF24242A),
                                    borderRadius: BorderRadius.circular(6.0),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.08),
                                    ),
                                  ),
                                  child: (thumbPath.startsWith('http://') || thumbPath.startsWith('https://'))
                                      ? Image.network(
                                          thumbPath,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                                        )
                                      : Image.asset(
                                          thumbPath,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                                        ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Top Right Favorite Button
            PositionedDirectional(
              top: 0,
              end: 0,
              child: _buildFavoriteButton(),
            ),
          ],
        ),
      ),
    );
  }
}
