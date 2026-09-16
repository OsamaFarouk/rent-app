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
import '../../../profile/presentation/providers/business_providers.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../domain/equipment_image_model.dart';
import '../../domain/equipment_model.dart';
import '../providers/equipment_providers.dart';

/// Detail screen displaying full equipment specs, images, location, and owner contact actions.
class EquipmentDetailPage extends ConsumerWidget {
  final String equipmentId;

  const EquipmentDetailPage({
    super.key,
    required this.equipmentId,
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
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp.')),
        );
      }
    } catch (e) {
      debugPrint('[WhatsApp] Launch error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp.')),
        );
      }
    }
  }

  Future<void> _shareEquipment(BuildContext context, EquipmentModel? equipment) async {
    if (equipment == null) return;
    try {
      final buffer = StringBuffer();
      buffer.writeln(equipment.name);
      buffer.writeln('Daily Rate: ${equipment.dailyPrice.toStringAsFixed(0)} EGP / day');

      if (equipment.weeklyPrice != null && equipment.weeklyPrice! > 0) {
        buffer.writeln('Weekly Rate: ${equipment.weeklyPrice!.toStringAsFixed(0)} EGP / week');
      }

      final loc = equipment.formattedLocation;
      if (loc.isNotEmpty) {
        buffer.writeln('Location: $loc');
      }

      if (equipment.ownerProfile?.fullName != null && equipment.ownerProfile!.fullName.isNotEmpty) {
        buffer.writeln('Owner: ${equipment.ownerProfile!.fullName}');
      }

      if (equipment.brand != null && equipment.brand!.isNotEmpty) {
        buffer.writeln('Brand: ${equipment.brand}');
      }

      if (equipment.model != null && equipment.model!.isNotEmpty) {
        buffer.writeln('Model: ${equipment.model}');
      }

      if (equipment.description != null && equipment.description!.isNotEmpty) {
        buffer.writeln('\n${equipment.description}');
      }

      final box = context.findRenderObject() as RenderBox?;
      final Rect? sharePositionOrigin = box != null && box.hasSize
          ? box.localToGlobal(Offset.zero) & box.size
          : null;

      final text = buffer.toString().trim();
      if (text.isNotEmpty) {
        await Share.share(
          text,
          subject: equipment.name,
          sharePositionOrigin: sharePositionOrigin,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('[Share] error: $e\n$stackTrace');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open share options. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final equipmentAsync = ref.watch(equipmentDetailProvider(equipmentId));
    final isFavorite = ref.watch(isEquipmentFavoriteProvider(equipmentId));
    final equipment = equipmentAsync.asData?.value;

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
          if (ref.watch(currentUserProvider) != null &&
              equipment != null &&
              ref.watch(currentUserProvider)!.id == equipment.ownerId)
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
              onPressed: () {
                context.push('/edit-equipment/${equipment.id}', extra: equipment);
              },
            ),
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
                    .read(userFavoritesNotifierProvider(user.id).notifier)
                    .toggleFavorite(
                      userId: user.id,
                      equipmentId: equipmentId,
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
            onPressed: () => _shareEquipment(context, equipment),
          ),
        ],
      ),
      body: equipmentAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, stack) => Center(
          child: Text(
            l10n.networkError,
            style: AppTypography.body.copyWith(color: AppColors.error),
          ),
        ),
        data: (equipment) {
          if (equipment == null) {
            return const Center(
              child: Text('Equipment listing not found.'),
            );
          }

          final currentProfile = ref.watch(currentProfileProvider).value;
          final owner = (currentProfile != null && currentProfile.id == equipment.ownerId)
              ? currentProfile
              : equipment.ownerProfile;

          final ownerName = owner?.fullName ?? 'Equipment Owner';
          final phone = (owner?.phone != null && owner!.phone!.trim().isNotEmpty) ? owner.phone!.trim() : '';
          final whatsapp = (owner?.whatsapp != null && owner!.whatsapp!.trim().isNotEmpty) ? owner.whatsapp!.trim() : '';

          final hasPhone = phone.isNotEmpty;
          final hasWhatsapp = whatsapp.isNotEmpty;

          // Fetch owner's business profile if business user
          final businessProfileAsync = owner?.isBusiness == true
              ? ref.watch(businessProfileByUserIdProvider(equipment.ownerId))
              : null;
          final businessProfile = businessProfileAsync?.asData?.value;

          String providerTitle = ownerName;
          String providerSubtitle = l10n.individualOwner;
          VoidCallback? onProviderTap;

          if (owner?.isBusiness == true) {
            providerTitle = businessProfile?.businessName ?? owner?.businessName ?? ownerName;
            providerSubtitle = l10n.rentalHouseOwner;
            if (businessProfile != null) {
              onProviderTap = () => context.push('/rental-houses/${businessProfile.id}');
            }
          } else if (owner?.isProfessional == true) {
            providerSubtitle = l10n.creativeProfessional;
            onProviderTap = () => context.go('/professionals');
          }

          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Main Image Display / Gallery
                        EquipmentImageGallery(
                          images: equipment.images,
                          fallbackPrimaryUrl: equipment.primaryImageUrl,
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Title & Category Badge
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                equipment.name,
                                style: AppTypography.heading.copyWith(
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (equipment.category != null) ...[
                              const SizedBox(width: AppSpacing.xs),
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs + 3, vertical: 4.0),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceSecondary,
                                    borderRadius: BorderRadius.circular(8.0),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Text(
                                    equipment.category!.nameEn,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.primary,
                                      fontSize: 11.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),

                        // Price & Location
                        Row(
                          children: [
                            Text(
                              '${l10n.fromPrice(equipment.dailyPrice.toStringAsFixed(0))} ${l10n.perDay}',
                              style: AppTypography.title.copyWith(
                                color: AppColors.accentGold,
                                fontSize: 17.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 15.0, color: AppColors.textMuted),
                                  const SizedBox(width: 3.0),
                                  Flexible(
                                    child: Text(
                                      equipment.formattedLocation,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.textMuted,
                                        fontSize: 13.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        if (equipment.weeklyPrice != null && equipment.weeklyPrice! > 0) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Weekly Rate: ${equipment.weeklyPrice!.toStringAsFixed(0)} EGP / week',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 12.5,
                            ),
                          ),
                        ],

                        const SizedBox(height: AppSpacing.xl),

                        // Specifications Card Grid
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14.0),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            children: [
                              _buildSpecRow('Brand', equipment.brand ?? 'N/A'),
                              const Divider(color: AppColors.border, height: AppSpacing.md),
                              _buildSpecRow('Model', equipment.model ?? 'N/A'),
                              const Divider(color: AppColors.border, height: AppSpacing.md),
                              _buildSpecRow('Condition', equipment.condition ?? 'Excellent'),
                              if (equipment.accessories != null && equipment.accessories!.isNotEmpty) ...[
                                const Divider(color: AppColors.border, height: AppSpacing.md),
                                _buildSpecRow('Accessories', equipment.accessories!),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // Description Section
                        if (equipment.description != null && equipment.description!.isNotEmpty) ...[
                          const Text('Description', style: AppTypography.sectionTitle),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            equipment.description!,
                            style: AppTypography.body.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 13.5,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                        ],

                        // Owner Profile Card
                        GestureDetector(
                          onTap: onProviderTap,
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14.0),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24.0,
                                  backgroundColor: AppColors.surfaceElevated,
                                  backgroundImage: (businessProfile?.logoUrl != null && businessProfile!.logoUrl!.isNotEmpty)
                                      ? NetworkImage(businessProfile.logoUrl!)
                                      : (owner?.profilePhoto != null && owner!.profilePhoto!.isNotEmpty)
                                          ? NetworkImage(owner.profilePhoto!)
                                          : null,
                                  child: ((businessProfile?.logoUrl == null || businessProfile!.logoUrl!.isEmpty) &&
                                          (owner?.profilePhoto == null || owner!.profilePhoto!.isEmpty))
                                      ? Text(
                                          providerTitle.isNotEmpty ? providerTitle[0].toUpperCase() : 'O',
                                          style: AppTypography.title.copyWith(color: AppColors.primary),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        providerTitle,
                                        style: AppTypography.title.copyWith(fontSize: 14.5, fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(height: 2.0),
                                      Text(
                                        providerSubtitle,
                                        style: AppTypography.caption.copyWith(color: AppColors.primary, fontSize: 11.5, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                                if (onProviderTap != null)
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 14.0,
                                    color: AppColors.textMuted,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Contact CTA Bar
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
                                label: const Text('Call'),
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

  Widget _buildSpecRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textMuted,
            fontSize: 12.5,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
            ),
          ),
        ),
      ],
    );
  }
}

/// Interactive gallery widget for viewing equipment photos with swipe PageView and thumbnail bar.
class EquipmentImageGallery extends StatefulWidget {
  final List<EquipmentImageModel> images;
  final String? fallbackPrimaryUrl;

  const EquipmentImageGallery({
    super.key,
    required this.images,
    this.fallbackPrimaryUrl,
  });

  @override
  State<EquipmentImageGallery> createState() => _EquipmentImageGalleryState();
}

class _EquipmentImageGalleryState extends State<EquipmentImageGallery> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<String> get _urls {
    if (widget.images.isNotEmpty) {
      final sorted = List<EquipmentImageModel>.from(widget.images)
        ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
      final urls = sorted.map((e) => e.imageUrl).where((url) => url.isNotEmpty).toList();
      if (urls.isNotEmpty) return urls;
    }
    if (widget.fallbackPrimaryUrl != null && widget.fallbackPrimaryUrl!.isNotEmpty) {
      return [widget.fallbackPrimaryUrl!];
    }
    return [];
  }

  Widget _buildSingleImage(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return Image.network(
        url,
        fit: BoxFit.contain,
        alignment: Alignment.center,
        errorBuilder: (ctx, err, stack) => const Center(
          child: Icon(Icons.camera_alt_outlined, color: AppColors.textMuted, size: 48.0),
        ),
      );
    } else {
      return Image.asset(
        url,
        fit: BoxFit.contain,
        alignment: Alignment.center,
        errorBuilder: (ctx, err, stack) => const Center(
          child: Icon(Icons.camera_alt_outlined, color: AppColors.textMuted, size: 48.0),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final urls = _urls;

    if (urls.isEmpty) {
      return AspectRatio(
        aspectRatio: 16 / 10,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: AppColors.border),
          ),
          child: const Center(
            child: Icon(Icons.camera_alt_outlined, color: AppColors.textMuted, size: 48.0),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Main Image PageView Banner
        AspectRatio(
          aspectRatio: 16 / 10,
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: AppColors.border),
            ),
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: urls.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return _buildSingleImage(urls[index]);
                  },
                ),
                if (urls.length > 1)
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.photo_library_outlined, color: Colors.white, size: 12.0),
                          const SizedBox(width: 4.0),
                          Text(
                            '${_currentIndex + 1} / ${urls.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Thumbnail Row if more than 1 image
        if (urls.length > 1) ...[
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 60.0,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: urls.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs + 2),
              itemBuilder: (context, index) {
                final isSelected = index == _currentIndex;
                final url = urls[index];
                return GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    width: 60.0,
                    height: 60.0,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: isSelected ? 2.0 : 1.0,
                      ),
                    ),
                    child: (url.startsWith('http://') || url.startsWith('https://'))
                        ? Image.network(url, fit: BoxFit.cover)
                        : Image.asset(url, fit: BoxFit.cover),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
