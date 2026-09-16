import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Business-oriented & Structured presentation card for Rental Houses / Business Profiles.
class RentalHouseCard extends StatelessWidget {
  final String businessName;
  final String city;
  final String? area;
  final String? description;
  final String? logoUrl;
  final String? businessType;
  final int? activeListingsCount;
  final String? coverImageUrl;
  final List<String>? categoryChips;
  final VoidCallback? onViewEquipmentTap;
  final bool isVerified;
  final bool isFavorite;
  final bool isHomeVariant;
  final double? width;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteTap;

  const RentalHouseCard({
    super.key,
    required this.businessName,
    required this.city,
    this.area,
    this.description,
    this.logoUrl,
    this.coverImageUrl,
    this.categoryChips,
    this.onViewEquipmentTap,
    this.businessType = 'Equipment Rental House',
    this.activeListingsCount,
    this.isVerified = true,
    this.isFavorite = false,
    this.isHomeVariant = false,
    this.width,
    required this.onTap,
    this.onFavoriteTap,
  });

  Widget _buildLogo(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF121216),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13.0),
        child: (logoUrl != null && logoUrl!.isNotEmpty)
            ? (logoUrl!.startsWith('http://') || logoUrl!.startsWith('https://')
                ? Image.network(
                    logoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => _buildFallbackLogo(size),
                  )
                : Image.asset(
                    logoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => _buildFallbackLogo(size),
                  ))
            : _buildFallbackLogo(size),
      ),
    );
  }

  Widget _buildFallbackLogo(double size) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_camera_back_outlined,
            color: AppColors.primary,
            size: size * 0.38,
          ),
          const SizedBox(height: 2.0),
          Text(
            'FINCAM',
            style: AppTypography.caption.copyWith(
              color: AppColors.textPrimary,
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteButton() {
    if (onFavoriteTap == null) return const SizedBox.shrink();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onFavoriteTap,
      child: Container(
        width: 32.0,
        height: 32.0,
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
    final locationText = '$city${area != null && area!.isNotEmpty ? ', $area' : ''}';
    final typeText = (businessType != null && businessType!.isNotEmpty)
        ? businessType!
        : 'Equipment Rental House';

    if (isHomeVariant) {
      return _buildHomeVariant(context, locationText, typeText);
    } else {
      return _buildPageVariant(context, locationText, typeText);
    }
  }

  /// Wide Business Storefront Card for Home page matching media_1789474443432.png
  Widget _buildHomeVariant(BuildContext context, String locationText, String typeText) {
    final cardWidth = width ?? 340.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        height: 128.0,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Stack(
          children: [
            // Background Studio Photo on the Right Side
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              width: 155.0,
              child: ShaderMask(
                shaderCallback: (bounds) {
                  return const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFF16161A),
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.45],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.srcOver,
                child: Image.asset(
                  'assets/images/sony_fx3.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => const SizedBox.shrink(),
                ),
              ),
            ),

            // Left Side Info
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm + 4),
              child: Row(
                children: [
                  _buildLogo(62.0),
                  const SizedBox(width: AppSpacing.sm + 2),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(end: 44.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Business Name + Verification Badge
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  businessName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.title.copyWith(
                                    fontSize: 15.5,
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
                                  size: 15.5,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2.0),

                          // Business Type Subtitle
                          Text(
                            typeText.isNotEmpty ? typeText : 'Equipment Rental House',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textMuted,
                              fontSize: 11.5,
                            ),
                          ),
                          const SizedBox(height: 5.0),

                          // Location Row
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 12.0,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(width: 2.0),
                              Expanded(
                                child: Text(
                                  locationText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.textMuted,
                                    fontSize: 11.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Top Right Favorite Button
            PositionedDirectional(
              top: 8,
              end: 8,
              child: _buildFavoriteButton(),
            ),

            // Middle/Bottom Right Circular Chevron Action Button
            PositionedDirectional(
              bottom: 12,
              end: 12,
              child: Container(
                width: 36.0,
                height: 36.0,
                decoration: BoxDecoration(
                  color: const Color(0xFF24242A).withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white,
                  size: 20.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Full-Width Corporate Rental House Profile Card matching right screen of media_1789478544101.jpg
  Widget _buildPageVariant(BuildContext context, String locationText, String typeText) {
    final chips = categoryChips ?? const ['Cameras', 'Lighting', 'Audio'];
    final inventoryCount = activeListingsCount ?? 24;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Cover Photo Banner
            SizedBox(
              height: 110.0,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: (coverImageUrl != null && coverImageUrl!.isNotEmpty)
                        ? (coverImageUrl!.startsWith('http://') || coverImageUrl!.startsWith('https://')
                            ? Image.network(
                                coverImageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _buildFallbackCover(),
                              )
                            : Image.asset(
                                coverImageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _buildFallbackCover(),
                              ))
                        : _buildFallbackCover(),
                  ),
                  // Top Right Favorite Button
                  PositionedDirectional(
                    top: 8.0,
                    end: 8.0,
                    child: _buildFavoriteButton(),
                  ),
                ],
              ),
            ),

            // Info Block with Overlapping Logo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 4, vertical: AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Overlapping Logo Box
                      Transform.translate(
                        offset: const Offset(0, -22.0),
                        child: _buildLogo(56.0),
                      ),
                      const SizedBox(width: AppSpacing.sm + 2),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    businessName,
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
                            const SizedBox(height: 2.0),

                            // Location Row
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 12.0,
                                  color: AppColors.textMuted,
                                ),
                                const SizedBox(width: 2.0),
                                Expanded(
                                  child: Text(
                                    locationText,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.textMuted,
                                      fontSize: 11.0,
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

                  // Business Description (when available)
                  if (description != null && description!.trim().isNotEmpty) ...[
                    Transform.translate(
                      offset: const Offset(0, -10.0),
                      child: Text(
                        description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11.5,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4.0),
                  ],

                  // Category Chips Row
                  if (chips.isNotEmpty) ...[
                    Transform.translate(
                      offset: const Offset(0, -8.0),
                      child: Wrap(
                        spacing: 6.0,
                        runSpacing: 4.0,
                        children: chips.take(3).map((chipText) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 3.0,
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
                                fontSize: 10.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],

                  // Footer Row: Equipment Count + View equipment >
                  Transform.translate(
                    offset: const Offset(0, -4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.inventory_2_outlined,
                              size: 13.0,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              '$inventoryCount equipment items',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textMuted,
                                fontSize: 11.0,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: onViewEquipmentTap ?? onTap,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View equipment',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 2.0),
                              const Icon(
                                Icons.chevron_right_rounded,
                                size: 15.0,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackCover() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF222228),
            Color(0xFF16161A),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.camera_indoor_outlined,
          color: Colors.white.withValues(alpha: 0.08),
          size: 44.0,
        ),
      ),
    );
  }
}
