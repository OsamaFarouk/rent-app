import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../profile/domain/portfolio_item_model.dart';
import '../../../profile/domain/professional_profile_model.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

/// Dedicated screen allowing professional accounts to manage their public professional identity,
/// portfolio items, social links, and review approval status.
class MyProfessionalProfilePage extends ConsumerStatefulWidget {
  const MyProfessionalProfilePage({super.key});

  @override
  ConsumerState<MyProfessionalProfilePage> createState() => _MyProfessionalProfilePageState();
}

class _MyProfessionalProfilePageState extends ConsumerState<MyProfessionalProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _yearsController = TextEditingController();
  final TextEditingController _startingPriceController = TextEditingController();

  final TextEditingController _linkedinController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _behanceController = TextEditingController();
  final TextEditingController _vimeoController = TextEditingController();
  final TextEditingController _youtubeController = TextEditingController();
  final TextEditingController _imdbController = TextEditingController();
  final TextEditingController _artstationController = TextEditingController();
  final TextEditingController _dribbbleController = TextEditingController();
  final TextEditingController _tiktokController = TextEditingController();
  final TextEditingController _soundcloudController = TextEditingController();
  final TextEditingController _spotifyController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _otherPortfolioController = TextEditingController();

  List<CustomSocialLink> _customLinks = [];

  String _experienceLevel = 'Intermediate';
  String _pricingType = 'per_day';
  bool _contactForPrice = false;
  bool _willingToTravel = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _bioController.dispose();
    _yearsController.dispose();
    _startingPriceController.dispose();
    _linkedinController.dispose();
    _instagramController.dispose();
    _behanceController.dispose();
    _vimeoController.dispose();
    _youtubeController.dispose();
    _imdbController.dispose();
    _artstationController.dispose();
    _dribbbleController.dispose();
    _tiktokController.dispose();
    _soundcloudController.dispose();
    _spotifyController.dispose();
    _websiteController.dispose();
    _otherPortfolioController.dispose();
    super.dispose();
  }

  void _prefillData(ProfessionalProfileModel? pro, String defaultTitle) {
    if (!_initialized) {
      _titleController.text = pro?.professionalTitle ?? defaultTitle;
      _bioController.text = pro?.bio ?? '';
      _yearsController.text = (pro?.yearsOfExperience ?? 0).toString();
      _startingPriceController.text = pro?.startingPrice != null ? pro!.startingPrice!.toStringAsFixed(0) : '';
      _experienceLevel = pro?.experienceLevel ?? 'Intermediate';
      if (pro?.pricingType == 'contact_for_price') {
        _contactForPrice = true;
        _pricingType = 'per_day';
      } else {
        _contactForPrice = false;
        _pricingType = (pro?.pricingType == 'per_project') ? 'per_project' : 'per_day';
      }
      _willingToTravel = pro?.willingToTravel ?? false;

      _linkedinController.text = pro?.linkedinUrl ?? '';
      _instagramController.text = pro?.instagramUrl ?? '';
      _behanceController.text = pro?.behanceUrl ?? '';
      _vimeoController.text = pro?.vimeoUrl ?? '';
      _youtubeController.text = pro?.youtubeUrl ?? '';
      _imdbController.text = pro?.imdbUrl ?? '';
      _artstationController.text = pro?.artstationUrl ?? '';
      _dribbbleController.text = pro?.dribbbleUrl ?? '';
      _tiktokController.text = pro?.tiktokUrl ?? '';
      _soundcloudController.text = pro?.soundcloudUrl ?? '';
      _spotifyController.text = pro?.spotifyUrl ?? '';
      _websiteController.text = pro?.actualWebsiteUrl ?? '';
      _otherPortfolioController.text = pro?.otherPortfolioUrl ?? '';
      _customLinks = pro?.customSocialLinks ?? [];

      _initialized = true;
    }
  }

  String? _formatSocialUrl(String platform, String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (platform == 'instagram') {
      final handle = trimmed.startsWith('@') ? trimmed.substring(1) : trimmed;
      if (handle.contains('instagram.com/')) {
        return 'https://$handle';
      }
      return 'https://instagram.com/$handle';
    }
    if (platform == 'linkedin') {
      if (trimmed.contains('linkedin.com/')) {
        return 'https://$trimmed';
      }
      return 'https://linkedin.com/in/$trimmed';
    }
    return 'https://$trimmed';
  }

  Future<void> _handleSave(String userId, ProfessionalProfileModel? existing) async {
    if (!_formKey.currentState!.validate()) return;

    final years = int.tryParse(_yearsController.text.trim()) ?? 0;
    final price = double.tryParse(_startingPriceController.text.trim());
    final effectivePricingType = _contactForPrice ? 'contact_for_price' : _pricingType;

    final encodedWebsite = ProfessionalProfileModel.encodeWebsiteData(
      website: _formatSocialUrl('website', _websiteController.text),
      imdb: _formatSocialUrl('imdb', _imdbController.text),
      artstation: _formatSocialUrl('artstation', _artstationController.text),
      dribbble: _formatSocialUrl('dribbble', _dribbbleController.text),
      tiktok: _formatSocialUrl('tiktok', _tiktokController.text),
      soundcloud: _formatSocialUrl('soundcloud', _soundcloudController.text),
      spotify: _formatSocialUrl('spotify', _spotifyController.text),
      otherPortfolio: _formatSocialUrl('other_portfolio', _otherPortfolioController.text),
      customLinks: _customLinks,
    );

    final updated = ProfessionalProfileModel(
      id: existing?.id ?? '',
      profileId: userId,
      professionalTitle: _titleController.text.trim(),
      bio: _bioController.text.trim().isNotEmpty ? _bioController.text.trim() : null,
      yearsOfExperience: years,
      experienceLevel: _experienceLevel,
      startingPrice: price,
      pricingType: effectivePricingType,
      willingToTravel: _willingToTravel,
      linkedinUrl: _formatSocialUrl('linkedin', _linkedinController.text),
      instagramUrl: _formatSocialUrl('instagram', _instagramController.text),
      behanceUrl: _formatSocialUrl('behance', _behanceController.text),
      vimeoUrl: _formatSocialUrl('vimeo', _vimeoController.text),
      youtubeUrl: _formatSocialUrl('youtube', _youtubeController.text),
      websiteUrl: encodedWebsite.isNotEmpty ? encodedWebsite : null,
      approvalStatus: existing?.approvalStatus ?? 'approved',
    );

    final success = await ref
        .read(profileNotifierProvider.notifier)
        .updateProfessionalProfile(updated);

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.profileUpdatedSuccess),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _showAddOrEditCustomLinkDialog(BuildContext context, {CustomSocialLink? existingLink, int? index}) {
    final titleCtrl = TextEditingController(text: existingLink?.title ?? '');
    final urlCtrl = TextEditingController(text: existingLink?.url ?? '');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: Text(
            existingLink == null ? 'Add Custom Link' : 'Edit Custom Link',
            style: AppTypography.heading.copyWith(fontSize: 16.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Platform / Link Name *',
                  hintText: 'e.g. IMDb Pro / Production Blog',
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: urlCtrl,
                decoration: const InputDecoration(
                  labelText: 'URL *',
                  hintText: 'https://...',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleCtrl.text.trim();
                final rawUrl = urlCtrl.text.trim();
                if (title.isEmpty || rawUrl.isEmpty) return;
                var formattedUrl = rawUrl;
                if (!formattedUrl.startsWith('http://') && !formattedUrl.startsWith('https://')) {
                  formattedUrl = 'https://$formattedUrl';
                }

                setState(() {
                  if (existingLink == null) {
                    _customLinks.add(CustomSocialLink(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: title,
                      url: formattedUrl,
                    ));
                  } else if (index != null) {
                    _customLinks[index] = existingLink.copyWith(
                      title: title,
                      url: formattedUrl,
                    );
                  }
                });
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
              ),
              child: Text(existingLink == null ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    );
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
      debugPrint('[UrlLauncher] Error launching $urlStr: $e');
    }
  }

  void _showAddOrEditPortfolioDialog(
    BuildContext context, {
    required String proProfileId,
    PortfolioItemModel? existingItem,
  }) {
    final titleCtrl = TextEditingController(text: existingItem?.title ?? '');
    final roleCtrl = TextEditingController(text: existingItem?.userRole ?? '');
    final yearCtrl = TextEditingController(text: existingItem?.year ?? '');
    final descCtrl = TextEditingController(text: existingItem?.shortDescription ?? '');
    final coverUrlCtrl = TextEditingController(text: existingItem?.mediaUrl ?? '');
    final galleryCtrl = TextEditingController(text: existingItem?.galleryImages.join(', ') ?? '');
    final videoUrlCtrl = TextEditingController(text: existingItem?.externalUrl ?? '');

    String selectedWorkType = existingItem?.workType ?? 'Project';
    final workTypeOptions = [
      'Project',
      'Showreel',
      'Commercial',
      'Film / Short Film',
      'Photo Gallery',
      'Video',
    ];
    if (!workTypeOptions.contains(selectedWorkType)) {
      selectedWorkType = 'Project';
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
              title: Text(
                existingItem == null ? 'Add Portfolio Work' : 'Edit Portfolio Work',
                style: AppTypography.heading.copyWith(fontSize: 16.0),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(labelText: 'Project Title *'),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownButtonFormField<String>(
                      initialValue: selectedWorkType,
                      decoration: const InputDecoration(labelText: 'Work Type *'),
                      items: workTypeOptions
                          .map((wt) => DropdownMenuItem(value: wt, child: Text(wt)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedWorkType = val);
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: roleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Your Role',
                        hintText: 'e.g. Director of Photography / Editor',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: yearCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Year',
                        hintText: 'e.g. 2025',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: descCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Short Description',
                        hintText: 'Brief summary of the work...',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: coverUrlCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Cover Image URL',
                        hintText: 'https://...',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: galleryCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Gallery Images (optional)',
                        hintText: 'Comma-separated URLs: https://a.jpg, https://b.jpg',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: videoUrlCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Video / Project URL (optional)',
                        hintText: 'YouTube or Vimeo link e.g. https://youtu.be/...',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (titleCtrl.text.trim().isEmpty) return;
                    Navigator.pop(ctx);

                    final rawGallery = galleryCtrl.text
                        .split(',')
                        .map((s) => s.trim())
                        .where((s) => s.isNotEmpty)
                        .toList();

                    final encodedDesc = PortfolioItemModel.encodeDescription(
                      summary: descCtrl.text.trim(),
                      workType: selectedWorkType,
                      userRole: roleCtrl.text.trim(),
                      year: yearCtrl.text.trim(),
                      gallery: rawGallery,
                    );

                    final coverUrl = coverUrlCtrl.text.trim().isNotEmpty ? coverUrlCtrl.text.trim() : null;
                    final videoUrl = videoUrlCtrl.text.trim().isNotEmpty ? videoUrlCtrl.text.trim() : null;
                    final mediaType = (selectedWorkType == 'Video' ||
                            selectedWorkType == 'Showreel' ||
                            (videoUrl != null && (videoUrl.contains('youtube') || videoUrl.contains('vimeo') || videoUrl.contains('youtu.be'))))
                        ? 'video'
                        : 'image';

                    if (existingItem == null) {
                      await ref.read(profileNotifierProvider.notifier).addPortfolioItem(
                            professionalProfileId: proProfileId,
                            title: titleCtrl.text.trim(),
                            description: encodedDesc,
                            mediaUrl: coverUrl,
                            mediaType: mediaType,
                            externalUrl: videoUrl,
                          );
                    } else {
                      final updatedItem = existingItem.copyWith(
                        title: titleCtrl.text.trim(),
                        description: encodedDesc,
                        mediaUrl: coverUrl,
                        mediaType: mediaType,
                        externalUrl: videoUrl,
                      );
                      await ref.read(profileNotifierProvider.notifier).updatePortfolioItem(updatedItem);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.background,
                  ),
                  child: Text(existingItem == null ? 'Add' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _movePortfolioItem(List<PortfolioItemModel> items, int oldIndex, int newIndex) async {
    if (newIndex < 0 || newIndex >= items.length) return;
    final newList = List<PortfolioItemModel>.from(items);
    final movedItem = newList.removeAt(oldIndex);
    newList.insert(newIndex, movedItem);
    await ref.read(profileNotifierProvider.notifier).reorderPortfolioItems(newList);
  }

  Widget _buildPlaceholderCover(PortfolioItemModel item) {
    return Container(
      height: 100.0,
      width: double.infinity,
      color: AppColors.surfaceElevated,
      child: Stack(
        children: [
          Center(
            child: Icon(
              item.isVideo ? Icons.movie_outlined : Icons.palette_outlined,
              size: 36.0,
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

  Widget _buildPortfolioCard(
    BuildContext context,
    PortfolioItemModel item,
    int index,
    int totalCount,
    String proProfileId,
  ) {
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
                  height: 150.0,
                  width: double.infinity,
                  child: coverUrl.startsWith('http')
                      ? Image.network(
                          coverUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => _buildPlaceholderCover(item),
                        )
                      : Image.asset(
                          coverUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => _buildPlaceholderCover(item),
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
            _buildPlaceholderCover(item),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: AppTypography.heading.copyWith(fontSize: 15.0),
                      ),
                    ),
                    if (item.isVideo)
                      const Padding(
                        padding: EdgeInsets.only(left: AppSpacing.xs),
                        child: Icon(Icons.play_circle_fill_rounded, color: AppColors.primary, size: 20.0),
                      ),
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
                    maxLines: 3,
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
                    height: 48.0,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: gallery.length,
                      separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
                      itemBuilder: (ctx, gIdx) {
                        final gUrl = gallery[gIdx];
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Container(
                            width: 48.0,
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
                const SizedBox(height: AppSpacing.sm),
                const Divider(color: AppColors.border, height: 1.0),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    if (hasExternal || hasCover)
                      OutlinedButton.icon(
                        onPressed: () => _openUrl(hasExternal ? externalUrl : coverUrl),
                        icon: Icon(
                          item.isVideo ? Icons.play_arrow_rounded : Icons.open_in_new_rounded,
                          size: 16.0,
                        ),
                        label: const Text('View Project'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                          minimumSize: const Size(0, 32.0),
                        ),
                      ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.arrow_upward_rounded, size: 18.0),
                      tooltip: 'Move Up',
                      color: index > 0 ? AppColors.textPrimary : AppColors.textMuted.withValues(alpha: 0.3),
                      onPressed: index > 0
                          ? () => _movePortfolioItem(
                                ref.read(currentProfessionalProfileProvider).value?.portfolioItems ?? [],
                                index,
                                index - 1,
                              )
                          : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_downward_rounded, size: 18.0),
                      tooltip: 'Move Down',
                      color: index < totalCount - 1 ? AppColors.textPrimary : AppColors.textMuted.withValues(alpha: 0.3),
                      onPressed: index < totalCount - 1
                          ? () => _movePortfolioItem(
                                ref.read(currentProfessionalProfileProvider).value?.portfolioItems ?? [],
                                index,
                                index + 1,
                              )
                          : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary, size: 18.0),
                      tooltip: 'Edit',
                      onPressed: () => _showAddOrEditPortfolioDialog(
                        context,
                        proProfileId: proProfileId,
                        existingItem: item,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 18.0),
                      tooltip: 'Delete',
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (c) => AlertDialog(
                            backgroundColor: AppColors.surface,
                            title: const Text('Delete Project?'),
                            content: Text('Are you sure you want to delete "${item.title}"?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                              TextButton(
                                onPressed: () => Navigator.pop(c, true),
                                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await ref.read(profileNotifierProvider.notifier).deletePortfolioItem(item.id);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profileAsync = ref.watch(currentProfileProvider);
    final proProfileAsync = ref.watch(currentProfessionalProfileProvider);
    final notifierState = ref.watch(profileNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: l10n.myProfessionalProfile,
        subtitle: l10n.proProfileSubtitle,
        showBackButton: true,
      ),
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (err, stack) => Center(
            child: Text(l10n.networkError),
          ),
          data: (profile) {
            // Security Access Guard: Strictly block non-professional accounts
            if (profile == null || !profile.isProfessional) {
              return _AccessDeniedView(
                l10n: l10n,
                message: l10n.accessDeniedProOnly,
              );
            }

            return proProfileAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (err, stack) => Center(
                child: Text(l10n.networkError),
              ),
              data: (proProfile) {
                _prefillData(proProfile, 'Director of Photography');

                final isApproved = proProfile?.isApproved ?? true;
                final portfolio = proProfile?.portfolioItems ?? [];

                return Column(
                  children: [
                    const SizedBox(height: AppSpacing.sm),

                    // Approval Banner Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.xs + 2),
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: const Icon(
                                Icons.badge_outlined,
                                color: AppColors.primary,
                                size: 24.0,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile.fullName,
                                    style: AppTypography.heading.copyWith(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2.0),
                                  Text(
                                    _titleController.text.isNotEmpty
                                        ? _titleController.text
                                        : l10n.profileTypeProfessional,
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.primary,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xxs + 1,
                              ),
                              decoration: BoxDecoration(
                                color: (isApproved ? AppColors.success : AppColors.warning)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20.0),
                                border: Border.all(
                                  color: (isApproved ? AppColors.success : AppColors.warning)
                                      .withValues(alpha: 0.4),
                                ),
                              ),
                              child: Text(
                                isApproved ? l10n.approvedStatus : l10n.pendingApproval,
                                style: AppTypography.label.copyWith(
                                  color: isApproved ? AppColors.success : AppColors.warning,
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // Logically Separated 3 Tabs
                    TabBar(
                      controller: _tabController,
                      indicatorColor: AppColors.primary,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textMuted,
                      labelStyle: AppTypography.caption.copyWith(fontWeight: FontWeight.w700, fontSize: 12.0),
                      tabs: const [
                        Tab(text: 'Professional Info'),
                        Tab(text: 'Portfolio & Work'),
                        Tab(text: 'Social Links'),
                      ],
                    ),

                    Expanded(
                      child: Form(
                        key: _formKey,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // TAB 1: Professional Information
                            SingleChildScrollView(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Professional Title / Specialization', style: AppTypography.title.copyWith(fontSize: 13.5)),
                                  const SizedBox(height: AppSpacing.xs),
                                  TextFormField(
                                    controller: _titleController,
                                    decoration: const InputDecoration(
                                      hintText: 'e.g. Director of Photography / Camera Operator',
                                      prefixIcon: Icon(Icons.work_outline, color: AppColors.textSecondary, size: 20.0),
                                    ),
                                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                                  ),
                                  const SizedBox(height: AppSpacing.lg),

                                  Text('Professional Bio & Summary', style: AppTypography.title.copyWith(fontSize: 13.5)),
                                  const SizedBox(height: AppSpacing.xs),
                                  TextFormField(
                                    controller: _bioController,
                                    maxLines: 4,
                                    decoration: const InputDecoration(
                                      hintText: 'Describe your creative background, equipment operated, and filming experience...',
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.lg),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Years of Experience', style: AppTypography.title.copyWith(fontSize: 13.5)),
                                            const SizedBox(height: AppSpacing.xs),
                                            TextFormField(
                                              controller: _yearsController,
                                              keyboardType: TextInputType.number,
                                              decoration: const InputDecoration(hintText: 'e.g. 5'),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Experience Level', style: AppTypography.title.copyWith(fontSize: 13.5)),
                                            const SizedBox(height: AppSpacing.xs),
                                            DropdownButtonFormField<String>(
                                              isExpanded: true,
                                              initialValue: _experienceLevel,
                                              decoration: const InputDecoration(),
                                              items: const [
                                                DropdownMenuItem(value: 'Junior', child: Text('Junior')),
                                                DropdownMenuItem(value: 'Intermediate', child: Text('Intermediate')),
                                                DropdownMenuItem(value: 'Senior / Expert', child: Text('Senior / Expert')),
                                              ],
                                              onChanged: (v) {
                                                if (v != null) setState(() => _experienceLevel = v);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.lg),

                                  if (!_contactForPrice) ...[
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Starting Rate (EGP)', style: AppTypography.title.copyWith(fontSize: 13.5)),
                                              const SizedBox(height: AppSpacing.xs),
                                              TextFormField(
                                                controller: _startingPriceController,
                                                keyboardType: TextInputType.number,
                                                decoration: const InputDecoration(hintText: 'e.g. 2500'),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.md),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Pricing Basis', style: AppTypography.title.copyWith(fontSize: 13.5)),
                                              const SizedBox(height: AppSpacing.xs),
                                              DropdownButtonFormField<String>(
                                                isExpanded: true,
                                                initialValue: _pricingType,
                                                decoration: const InputDecoration(),
                                                items: const [
                                                  DropdownMenuItem(value: 'per_day', child: Text('Per Day')),
                                                  DropdownMenuItem(value: 'per_project', child: Text('Per Project')),
                                                ],
                                                onChanged: (v) {
                                                  if (v != null) setState(() => _pricingType = v);
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.lg),
                                  ],

                                  SwitchListTile(
                                    value: _contactForPrice,
                                    activeThumbColor: AppColors.primary,
                                    title: Text('Contact for Price', style: AppTypography.title.copyWith(fontSize: 13.5)),
                                    subtitle: Text('Hide your rate and let clients contact you for pricing.', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
                                    onChanged: (v) => setState(() => _contactForPrice = v),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),

                                  SwitchListTile(
                                    value: _willingToTravel,
                                    activeThumbColor: AppColors.primary,
                                    title: Text('Willing to Travel / Work Abroad', style: AppTypography.title.copyWith(fontSize: 13.5)),
                                    subtitle: Text('Show that you can travel for out-of-town film shoots', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
                                    onChanged: (v) => setState(() => _willingToTravel = v),
                                  ),
                                  const SizedBox(height: AppSpacing.xl),
                                ],
                              ),
                            ),

                            // TAB 2: Portfolio & Work
                            SingleChildScrollView(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Showcase Projects & Reels', style: AppTypography.heading.copyWith(fontSize: 16.0)),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          if (proProfile != null) {
                                            _showAddOrEditPortfolioDialog(context, proProfileId: proProfile.id);
                                          }
                                        },
                                        icon: const Icon(Icons.add_rounded, size: 18.0),
                                        label: const Text('+ Add Work'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: AppColors.background,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.md),

                                  if (portfolio.isEmpty)
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(AppSpacing.xl),
                                      decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius: BorderRadius.circular(16.0),
                                        border: Border.all(color: AppColors.border),
                                      ),
                                      child: Column(
                                        children: [
                                          const Icon(Icons.movie_creation_outlined, size: 44.0, color: AppColors.textMuted),
                                          const SizedBox(height: AppSpacing.sm),
                                          Text('No portfolio projects added yet', style: AppTypography.title.copyWith(fontSize: 14.0)),
                                          const SizedBox(height: 4.0),
                                          Text(
                                            'Tap "+ Add Work" above or below to display showreels, video links, or past commercial projects.',
                                            textAlign: TextAlign.center,
                                            style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                                          ),
                                          const SizedBox(height: AppSpacing.md),
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              if (proProfile != null) {
                                                _showAddOrEditPortfolioDialog(context, proProfileId: proProfile.id);
                                              }
                                            },
                                            icon: const Icon(Icons.add_rounded, size: 18.0),
                                            label: const Text('Add your first project'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.primary,
                                              foregroundColor: AppColors.background,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    ListView.separated(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: portfolio.length,
                                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                                      itemBuilder: (ctx, idx) {
                                        return _buildPortfolioCard(
                                          context,
                                          portfolio[idx],
                                          idx,
                                          portfolio.length,
                                          proProfile!.id,
                                        );
                                      },
                                    ),
                                  const SizedBox(height: AppSpacing.xl),
                                ],
                              ),
                            ),

                            // TAB 3: Contact & Social Links
                            SingleChildScrollView(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Public Social & Portfolio Links', style: AppTypography.heading.copyWith(fontSize: 16.0)),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    'Add your main account links below. Individual showreels or video projects belong in Portfolio & Work.',
                                    style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                                  ),
                                  const SizedBox(height: AppSpacing.md),

                                  _buildSocialField(_linkedinController, 'LinkedIn Profile URL', Icons.link_rounded, hint: 'https://linkedin.com/in/...'),
                                  const SizedBox(height: AppSpacing.sm),
                                  _buildSocialField(_instagramController, 'Instagram Profile URL', Icons.camera_alt_outlined, hint: 'https://instagram.com/... or @handle'),
                                  const SizedBox(height: AppSpacing.sm),
                                  _buildSocialField(_behanceController, 'Behance Portfolio URL', Icons.palette_outlined, hint: 'https://behance.net/...'),
                                  const SizedBox(height: AppSpacing.sm),
                                  _buildSocialField(_vimeoController, 'Vimeo Profile URL', Icons.movie_outlined, hint: 'https://vimeo.com/...'),
                                  const SizedBox(height: AppSpacing.sm),
                                  _buildSocialField(_youtubeController, 'YouTube Channel URL', Icons.video_library_outlined, hint: 'https://youtube.com/@...'),
                                  const SizedBox(height: AppSpacing.sm),
                                  _buildSocialField(_imdbController, 'IMDb Profile URL', Icons.movie_creation_outlined, hint: 'https://imdb.com/name/nm...'),
                                  const SizedBox(height: AppSpacing.sm),
                                  _buildSocialField(_artstationController, 'ArtStation Profile URL', Icons.brush_outlined, hint: 'https://artstation.com/...'),
                                  const SizedBox(height: AppSpacing.sm),
                                  _buildSocialField(_dribbbleController, 'Dribbble Profile URL', Icons.sports_basketball_outlined, hint: 'https://dribbble.com/...'),
                                  const SizedBox(height: AppSpacing.sm),
                                  _buildSocialField(_tiktokController, 'TikTok Profile URL', Icons.music_note_outlined, hint: 'https://tiktok.com/@...'),
                                  const SizedBox(height: AppSpacing.sm),
                                  _buildSocialField(_soundcloudController, 'SoundCloud Profile URL', Icons.cloud_outlined, hint: 'https://soundcloud.com/...'),
                                  const SizedBox(height: AppSpacing.sm),
                                  _buildSocialField(_spotifyController, 'Spotify Profile URL', Icons.library_music_outlined, hint: 'https://spotify.com/...'),
                                  const SizedBox(height: AppSpacing.sm),
                                  _buildSocialField(_websiteController, 'Personal Website', Icons.language_rounded, hint: 'https://yourwebsite.com'),
                                  const SizedBox(height: AppSpacing.sm),
                                  _buildSocialField(_otherPortfolioController, 'Other Portfolio Link', Icons.folder_open_rounded, hint: 'https://portfolio.com'),
                                  const SizedBox(height: AppSpacing.lg),

                                  if (_customLinks.isNotEmpty) ...[
                                    Text('Custom Portfolio & Account Links', style: AppTypography.title.copyWith(fontSize: 14.0)),
                                    const SizedBox(height: AppSpacing.xs),
                                    ListView.separated(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: _customLinks.length,
                                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
                                      itemBuilder: (ctx, cIdx) {
                                        final cLink = _customLinks[cIdx];
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.surface,
                                            borderRadius: BorderRadius.circular(12.0),
                                            border: Border.all(color: AppColors.border),
                                          ),
                                          child: ListTile(
                                            leading: const Icon(Icons.link_rounded, color: AppColors.primary),
                                            title: Text(cLink.title, style: AppTypography.title.copyWith(fontSize: 14.0)),
                                            subtitle: Text(cLink.url, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.caption),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary, size: 18.0),
                                                  onPressed: () => _showAddOrEditCustomLinkDialog(context, existingLink: cLink, index: cIdx),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 18.0),
                                                  onPressed: () => setState(() => _customLinks.removeAt(cIdx)),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                  ],

                                  OutlinedButton.icon(
                                    onPressed: () => _showAddOrEditCustomLinkDialog(context),
                                    icon: const Icon(Icons.add_rounded, size: 18.0),
                                    label: const Text('+ Add Other Link'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.primary,
                                      side: const BorderSide(color: AppColors.primary),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xl),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Save Button Floating Footer (Hidden on Tab 2: Portfolio & Work)
                    if (_tabController.index != 1)
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: SizedBox(
                          width: double.infinity,
                          height: 48.0,
                          child: ElevatedButton(
                            onPressed: notifierState.isLoading ? null : () => _handleSave(profile.id, proProfile),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.background),
                            child: notifierState.isLoading
                                ? const CircularProgressIndicator(color: AppColors.background)
                                : Text('Save Professional Profile', style: AppTypography.button.copyWith(fontWeight: FontWeight.w700, color: AppColors.background)),
                          ),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSocialField(
    TextEditingController controller,
    String label,
    IconData icon, {
    String? hint,
  }) {
    return TextFormField(
      controller: controller,
      style: AppTypography.title.copyWith(fontSize: 14.0),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20.0),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
      ),
    );
  }
}

class _AccessDeniedView extends StatelessWidget {
  final AppLocalizations l10n;
  final String message;

  const _AccessDeniedView({
    required this.l10n,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                color: AppColors.error,
                size: 48.0,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Access Denied',
              style: AppTypography.heading.copyWith(fontSize: 20.0),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  context.go('/profile');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
