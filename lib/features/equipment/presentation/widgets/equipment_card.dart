import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Product-focused Marketplace presentation card for Equipment listings.
class EquipmentCard extends StatelessWidget {
  final String title;
  final String location;
  final String price;
  final String? brandModel;
  final String? rating;
  final String? reviewsCount;
  final String? availability;
  final String? imagePath;
  final String? lastUpdatedText;
  final bool isVerified;
  final bool isHomeVariant;
  final double? width;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onEditTap;

  const EquipmentCard({
    super.key,
    required this.title,
    required this.location,
    required this.price,
    this.brandModel,
    this.rating,
    this.reviewsCount,
    this.availability = 'Available',
    this.imagePath,
    this.lastUpdatedText,
    this.isVerified = false,
    this.isHomeVariant = false,
    this.isFavorite = false,
    this.width,
    this.onTap,
    this.onFavoriteTap,
    this.onEditTap,
  });

  Widget _buildImage(String? path) {
    if (path == null || path.isEmpty) {
      return Container(
        color: AppColors.surfaceElevated,
        child: const Center(
          child: Icon(
            Icons.camera_alt_outlined,
            color: AppColors.textMuted,
            size: 36.0,
          ),
        ),
      );
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => Container(
          color: AppColors.surfaceElevated,
          child: const Center(
            child: Icon(
              Icons.camera_alt_outlined,
              color: AppColors.textMuted,
              size: 36.0,
            ),
          ),
        ),
      );
    } else {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => Container(
          color: AppColors.surfaceElevated,
          child: const Center(
            child: Icon(
              Icons.camera_alt_outlined,
              color: AppColors.textMuted,
              size: 36.0,
            ),
          ),
        ),
      );
    }
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
          size: 15.0,
        ),
      ),
    );
  }

  Widget _buildEditButton() {
    if (onEditTap == null) return const SizedBox.shrink();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onEditTap,
      child: Container(
        width: 30.0,
        height: 30.0,
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.85),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.edit_outlined,
          color: AppColors.primary,
          size: 14.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayLocation = location.isNotEmpty ? location : 'Cairo';
    final displayAvailability = (availability != null && availability!.isNotEmpty)
        ? availability!
        : 'Available';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dominant Product Image Container
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _buildImage(imagePath),
                  ),
                  // Glassmorphism Favorite/Edit Overlay Button (Top-Right)
                  PositionedDirectional(
                    top: 8.0,
                    end: 8.0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (onEditTap != null) ...[
                          _buildEditButton(),
                          const SizedBox(width: AppSpacing.xs),
                        ],
                        if (onFavoriteTap != null) _buildFavoriteButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Product Details Block
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Equipment Title + Verification Badge
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.title.copyWith(
                            fontSize: 13.5,
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
                          size: 13.5,
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 2.0),

                  // Marketplace Price Tag
                  Text(
                    price,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 5.0),

                  // Location & Availability Status Row
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
                      const SizedBox(width: 4.0),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6.0,
                          vertical: 2.0,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4.0),
                          border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          displayAvailability,
                          style: AppTypography.label.copyWith(
                            color: AppColors.success,
                            fontSize: 9.0,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }
}
