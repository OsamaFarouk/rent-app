import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/egypt_locations.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../domain/business_profile_model.dart';
import '../providers/business_providers.dart';
import '../providers/profile_provider.dart';

/// Screen allowing business / rental house accounts to view and edit their dedicated public business profile details.
class MyBusinessProfilePage extends ConsumerStatefulWidget {
  const MyBusinessProfilePage({super.key});

  @override
  ConsumerState<MyBusinessProfilePage> createState() => _MyBusinessProfilePageState();
}

class _MyBusinessProfilePageState extends ConsumerState<MyBusinessProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _businessAddressController = TextEditingController();
  final TextEditingController _businessDescriptionController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _websiteUrlController = TextEditingController();
  final TextEditingController _workingHoursController = TextEditingController();

  EgyptGovernorate _selectedGovernorate = EgyptLocations.governorates.first;
  EgyptDistrict _selectedDistrict = EgyptLocations.governorates.first.districts.first;

  String? _logoUrl;
  bool _isUploadingLogo = false;
  bool _initialized = false;

  // Working Hours Selector State
  String _selectedDayPreset = 'Sun – Thu';
  TimeOfDay _openTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _closeTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  void dispose() {
    _businessNameController.dispose();
    _businessAddressController.dispose();
    _businessDescriptionController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _websiteUrlController.dispose();
    _workingHoursController.dispose();
    super.dispose();
  }

  void _prefillData(BusinessProfileModel? business, String userId, String userPhone, String userWhatsapp, String userEmail, String userCity, String userArea) {
    if (!_initialized) {
      _businessNameController.text = business?.businessName ?? '';
      _businessAddressController.text = business?.businessAddress ?? '';
      _businessDescriptionController.text = business?.businessDescription ?? '';
      _phoneController.text = business?.phone ?? userPhone;
      _whatsappController.text = business?.whatsapp ?? userWhatsapp;
      _emailController.text = business?.email ?? userEmail;
      _websiteUrlController.text = business?.websiteUrl ?? '';
      _workingHoursController.text = (business?.workingHours != null && business!.workingHours!.isNotEmpty)
          ? business.workingHours!
          : 'Sun – Thu, 10:00 AM – 8:00 PM';
      _logoUrl = business?.logoUrl;

      final cityToMatch = (business?.city != null && business!.city.isNotEmpty) ? business.city : userCity;
      final areaToMatch = (business?.area != null && business!.area!.isNotEmpty) ? business.area! : userArea;

      _selectedGovernorate = EgyptLocations.findGovernorate(cityToMatch);
      _selectedDistrict = EgyptLocations.findDistrict(_selectedGovernorate, areaToMatch);

      _initialized = true;
    }
  }

  void _updateWorkingHoursString() {
    if (_selectedDayPreset == 'Closed') {
      _workingHoursController.text = 'Closed';
      return;
    }
    final openStr = _openTime.format(context);
    final closeStr = _closeTime.format(context);
    _workingHoursController.text = '$_selectedDayPreset, $openStr – $closeStr';
  }

  Future<void> _pickTime(bool isOpenTime) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isOpenTime ? _openTime : _closeTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isOpenTime) {
          _openTime = picked;
        } else {
          _closeTime = picked;
        }
        _updateWorkingHoursString();
      });
    }
  }

  Future<void> _pickAndUploadLogo(ImageSource source, String userId) async {
    final picker = ImagePicker();
    try {
      final file = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (file == null) return;

      setState(() {
        _isUploadingLogo = true;
      });

      final url = await StorageService().uploadProfilePhoto(
        userId: userId,
        file: file,
      );

      if (mounted) {
        setState(() {
          _logoUrl = url;
          _isUploadingLogo = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingLogo = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.networkError),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showLogoPickerSheet(BuildContext context, String userId) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.businessLogo,
                  style: AppTypography.heading.copyWith(fontSize: 16.0),
                ),
                const SizedBox(height: AppSpacing.sm),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                  title: Text(l10n.takePhoto, style: AppTypography.title.copyWith(fontSize: 14.0)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickAndUploadLogo(ImageSource.camera, userId);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
                  title: Text(l10n.chooseFromGallery, style: AppTypography.title.copyWith(fontSize: 14.0)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickAndUploadLogo(ImageSource.gallery, userId);
                  },
                ),
                if (_logoUrl != null && _logoUrl!.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                    title: Text(l10n.removePhoto, style: AppTypography.title.copyWith(fontSize: 14.0, color: AppColors.error)),
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _logoUrl = null;
                      });
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSave(String userId, BusinessProfileModel? existing) async {
    if (!_formKey.currentState!.validate()) return;

    final updated = BusinessProfileModel(
      id: existing?.id ?? '',
      userId: userId,
      businessName: _businessNameController.text.trim(),
      businessAddress: _businessAddressController.text.trim().isNotEmpty
          ? _businessAddressController.text.trim()
          : null,
      businessDescription: _businessDescriptionController.text.trim().isNotEmpty
          ? _businessDescriptionController.text.trim()
          : null,
      logoUrl: _logoUrl,
      phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
      whatsapp: _whatsappController.text.trim().isNotEmpty ? _whatsappController.text.trim() : null,
      email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
      city: _selectedGovernorate.nameEn,
      area: _selectedDistrict.nameEn,
      websiteUrl: _websiteUrlController.text.trim().isNotEmpty
          ? _websiteUrlController.text.trim()
          : null,
      workingHours: _workingHoursController.text.trim().isNotEmpty
          ? _workingHoursController.text.trim()
          : null,
      approvalStatus: existing?.approvalStatus ?? 'approved',
      isActive: existing?.isActive ?? true,
    );

    final success = await ref
        .read(businessNotifierProvider.notifier)
        .updateBusinessProfile(updated);

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.profileUpdatedSuccess),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeCode = Localizations.localeOf(context).languageCode;
    final profileAsync = ref.watch(currentProfileProvider);
    final businessProfileAsync = ref.watch(currentBusinessProfileProvider);
    final businessState = ref.watch(businessNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: l10n.myBusinessProfile,
        subtitle: l10n.businessProfileSubtitle,
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
            // Security Access Guard: Strictly block non-business accounts
            if (profile == null || !profile.isBusiness) {
              return _AccessDeniedView(
                l10n: l10n,
                message: l10n.accessDeniedBusinessOnly,
              );
            }

            return businessProfileAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (err, stack) => Center(
                child: Text(l10n.networkError),
              ),
              data: (businessProfile) {
                _prefillData(
                  businessProfile,
                  profile.id,
                  profile.phone ?? '',
                  profile.whatsapp ?? '',
                  profile.email ?? '',
                  profile.city,
                  profile.area ?? '',
                );

                final isApproved = businessProfile?.isApproved ?? true;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.sm),

                        // Approval & Status Banner
                        Container(
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
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: const Icon(
                                  Icons.business_outlined,
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
                                      _businessNameController.text.isNotEmpty
                                          ? _businessNameController.text
                                          : 'Rental House',
                                      style: AppTypography.heading.copyWith(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2.0),
                                    Text(
                                      l10n.profileTypeBusiness,
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

                        const SizedBox(height: AppSpacing.xl),

                        // Logo Section
                        Center(
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () => _showLogoPickerSheet(context, profile.id),
                                child: Stack(
                                  children: [
                                    Container(
                                      width: 96.0,
                                      height: 96.0,
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceElevated,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: AppColors.border, width: 2.0),
                                      ),
                                      child: _isUploadingLogo
                                          ? const Center(
                                              child: CircularProgressIndicator(
                                                color: AppColors.primary,
                                                strokeWidth: 2.5,
                                              ),
                                            )
                                          : ClipOval(
                                              child: (_logoUrl != null && _logoUrl!.isNotEmpty)
                                                  ? Image.network(
                                                      _logoUrl!,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (ctx, err, stack) => const Icon(
                                                        Icons.business_outlined,
                                                        color: AppColors.primary,
                                                        size: 38.0,
                                                      ),
                                                    )
                                                  : const Icon(
                                                      Icons.business_outlined,
                                                      color: AppColors.primary,
                                                      size: 38.0,
                                                    ),
                                            ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(AppSpacing.xs),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors.background,
                                            width: 2.0,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt_rounded,
                                          color: AppColors.background,
                                          size: 16.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                l10n.businessLogo,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xxl),

                        // Business Name
                        Text(
                          l10n.businessNameLabel,
                          style: AppTypography.title.copyWith(fontSize: 13.5),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        TextFormField(
                          controller: _businessNameController,
                          style: AppTypography.title.copyWith(fontSize: 14.0),
                          decoration: InputDecoration(
                            hintText: 'e.g. Cairo Cine Equipment Rental',
                            hintStyle: AppTypography.caption.copyWith(color: AppColors.textMuted),
                            prefixIcon: const Icon(
                              Icons.business_outlined,
                              color: AppColors.textSecondary,
                              size: 20.0,
                            ),
                            filled: true,
                            fillColor: AppColors.surface,
                            contentPadding: const EdgeInsets.all(AppSpacing.md),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.businessNameValidation;
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // Short Business Description
                        Text(
                          l10n.businessDescriptionLabel,
                          style: AppTypography.title.copyWith(fontSize: 13.5),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        TextFormField(
                          controller: _businessDescriptionController,
                          maxLines: 3,
                          style: AppTypography.title.copyWith(fontSize: 14.0),
                          decoration: InputDecoration(
                            hintText: 'Brief summary of rental services & available gear...',
                            hintStyle: AppTypography.caption.copyWith(color: AppColors.textMuted),
                            filled: true,
                            fillColor: AppColors.surface,
                            contentPadding: const EdgeInsets.all(AppSpacing.md),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // City & Area
                        Text(
                          l10n.governorateLabel,
                          style: AppTypography.title.copyWith(fontSize: 13.5),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        DropdownButtonFormField<EgyptGovernorate>(
                          isExpanded: true,
                          key: ValueKey('gov_${_selectedGovernorate.id}'),
                          initialValue: _selectedGovernorate,
                          dropdownColor: AppColors.surface,
                          style: AppTypography.title.copyWith(fontSize: 14.0),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.surface,
                            contentPadding: const EdgeInsets.all(AppSpacing.md),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                          ),
                          items: EgyptLocations.governorates.map((gov) {
                            return DropdownMenuItem<EgyptGovernorate>(
                              value: gov,
                              child: Text(gov.getLocalizedName(localeCode)),
                            );
                          }).toList(),
                          onChanged: (newGov) {
                            if (newGov != null) {
                              setState(() {
                                _selectedGovernorate = newGov;
                                _selectedDistrict = newGov.districts.first;
                              });
                            }
                          },
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        Text(
                          l10n.districtLabel,
                          style: AppTypography.title.copyWith(fontSize: 13.5),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        DropdownButtonFormField<EgyptDistrict>(
                          isExpanded: true,
                          key: ValueKey('dist_${_selectedGovernorate.id}_${_selectedDistrict.id}'),
                          initialValue: _selectedDistrict,
                          dropdownColor: AppColors.surface,
                          style: AppTypography.title.copyWith(fontSize: 14.0),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.surface,
                            contentPadding: const EdgeInsets.all(AppSpacing.md),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                          ),
                          items: _selectedGovernorate.districts.map((dist) {
                            return DropdownMenuItem<EgyptDistrict>(
                              value: dist,
                              child: Text(dist.getLocalizedName(localeCode)),
                            );
                          }).toList(),
                          onChanged: (newDist) {
                            if (newDist != null) {
                              setState(() {
                                _selectedDistrict = newDist;
                              });
                            }
                          },
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // Full Business Address
                        Text(
                          l10n.fullAddressLabel,
                          style: AppTypography.title.copyWith(fontSize: 13.5),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        TextFormField(
                          controller: _businessAddressController,
                          style: AppTypography.title.copyWith(fontSize: 14.0),
                          decoration: InputDecoration(
                            hintText: 'e.g. Building 14, Road 9, Maadi',
                            hintStyle: AppTypography.caption.copyWith(color: AppColors.textMuted),
                            filled: true,
                            fillColor: AppColors.surface,
                            contentPadding: const EdgeInsets.all(AppSpacing.md),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // Contact Details (Phone, WhatsApp, Business Email)
                        Text(
                          l10n.phoneLabel,
                          style: AppTypography.title.copyWith(fontSize: 13.5),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: AppTypography.title.copyWith(fontSize: 14.0),
                          decoration: InputDecoration(
                            hintText: '+20 100 000 0000',
                            prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.textSecondary, size: 20.0),
                            filled: true,
                            fillColor: AppColors.surface,
                            contentPadding: const EdgeInsets.all(AppSpacing.md),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        Text(
                          l10n.whatsappLabel,
                          style: AppTypography.title.copyWith(fontSize: 13.5),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        TextFormField(
                          controller: _whatsappController,
                          keyboardType: TextInputType.phone,
                          style: AppTypography.title.copyWith(fontSize: 14.0),
                          decoration: InputDecoration(
                            hintText: '+20 100 000 0000',
                            prefixIcon: const Icon(Icons.chat_outlined, color: AppColors.textSecondary, size: 20.0),
                            filled: true,
                            fillColor: AppColors.surface,
                            contentPadding: const EdgeInsets.all(AppSpacing.md),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        Text(
                          l10n.websiteUrlLabel,
                          style: AppTypography.title.copyWith(fontSize: 13.5),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        TextFormField(
                          controller: _websiteUrlController,
                          keyboardType: TextInputType.url,
                          style: AppTypography.title.copyWith(fontSize: 14.0),
                          decoration: InputDecoration(
                            hintText: 'https://www.cairocine.com',
                            hintStyle: AppTypography.caption.copyWith(color: AppColors.textMuted),
                            filled: true,
                            fillColor: AppColors.surface,
                            contentPadding: const EdgeInsets.all(AppSpacing.md),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // Working Hours Selector Widget
                        Text(
                          l10n.workingHoursLabel,
                          style: AppTypography.title.copyWith(fontSize: 13.5),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownButtonFormField<String>(
                                isExpanded: true,
                                key: ValueKey('days_$_selectedDayPreset'),
                                initialValue: _selectedDayPreset,
                                dropdownColor: AppColors.surface,
                                style: AppTypography.title.copyWith(fontSize: 13.5),
                                decoration: InputDecoration(
                                  labelText: l10n.workingDaysLabel,
                                  labelStyle: AppTypography.caption.copyWith(color: AppColors.primary),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: AppSpacing.xs,
                                  ),
                                  border: const OutlineInputBorder(),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'Sun – Thu', child: Text('Sun – Thu')),
                                  DropdownMenuItem(value: 'Sun – Sat (Daily)', child: Text('Sun – Sat (Daily)')),
                                  DropdownMenuItem(value: 'Sat – Thu', child: Text('Sat – Thu')),
                                  DropdownMenuItem(value: 'Mon – Fri', child: Text('Mon – Fri')),
                                  DropdownMenuItem(value: 'Closed', child: Text('Closed')),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _selectedDayPreset = val;
                                      _updateWorkingHoursString();
                                    });
                                  }
                                },
                              ),
                              if (_selectedDayPreset != 'Closed') ...[
                                const SizedBox(height: AppSpacing.md),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () => _pickTime(true),
                                        icon: const Icon(Icons.access_time_rounded, size: 16.0),
                                        label: Text('${l10n.openTimeLabel}: ${_openTime.format(context)}'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.textPrimary,
                                          side: const BorderSide(color: AppColors.border),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () => _pickTime(false),
                                        icon: const Icon(Icons.access_time_filled_rounded, size: 16.0),
                                        label: Text('${l10n.closeTimeLabel}: ${_closeTime.format(context)}'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.textPrimary,
                                          side: const BorderSide(color: AppColors.border),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xs),
                        TextFormField(
                          controller: _workingHoursController,
                          style: AppTypography.title.copyWith(fontSize: 13.5),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.surfaceSecondary,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.xs + 4,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xxl),

                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          height: 50.0,
                          child: ElevatedButton(
                            onPressed: businessState.isLoading
                                ? null
                                : () => _handleSave(profile.id, businessProfile),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.background,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                              elevation: 0,
                            ),
                            child: businessState.isLoading
                                ? const SizedBox(
                                    width: 22.0,
                                    height: 22.0,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: AppColors.background,
                                    ),
                                  )
                                : Text(
                                    l10n.saveChanges,
                                    style: AppTypography.button.copyWith(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.background,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
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
