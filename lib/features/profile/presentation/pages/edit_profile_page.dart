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
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/profile_model.dart';
import '../providers/profile_provider.dart';

/// Common Edit Profile screen for all registered account types (Personal, Professional, Business).
/// Represents the authenticated user account only.
class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();

  EgyptGovernorate _selectedGovernorate = EgyptLocations.governorates.first;
  EgyptDistrict _selectedDistrict = EgyptLocations.governorates.first.districts.first;

  String? _profilePhotoUrl;
  bool _isUploadingPhoto = false;
  bool _sameAsMobile = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneChanged);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onPhoneChanged);
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
    if (_sameAsMobile) {
      _whatsappController.text = _phoneController.text;
    }
  }

  void _prefillData(ProfileModel profile) {
    if (!_initialized) {
      _fullNameController.text = profile.fullName;

      final userEmail = (profile.email != null && profile.email!.isNotEmpty)
          ? profile.email!
          : (ref.read(currentUserProvider)?.email ?? '');
      _emailController.text = userEmail;

      final phoneStr = profile.phone?.trim() ?? '';
      final whatsappStr = profile.whatsapp?.trim() ?? '';

      _phoneController.text = phoneStr;
      _whatsappController.text = whatsappStr;
      _profilePhotoUrl = profile.profilePhoto;

      _selectedGovernorate = EgyptLocations.findGovernorate(profile.city);
      _selectedDistrict = EgyptLocations.findDistrict(_selectedGovernorate, profile.area ?? '');

      _sameAsMobile = (phoneStr.isNotEmpty &&
          whatsappStr.isNotEmpty &&
          phoneStr == whatsappStr);

      if (_sameAsMobile) {
        _whatsappController.text = phoneStr;
      }
      _initialized = true;
    }
  }

  Future<void> _pickAndUploadPhoto(ImageSource source, ProfileModel profile) async {
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
        _isUploadingPhoto = true;
      });

      final url = await StorageService().uploadProfilePhoto(
        userId: profile.id,
        file: file,
      );

      if (mounted) {
        setState(() {
          _profilePhotoUrl = url;
          _isUploadingPhoto = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingPhoto = false;
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

  void _showPhotoPickerSheet(BuildContext context, ProfileModel profile) {
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
                  l10n.changePhoto,
                  style: AppTypography.heading.copyWith(fontSize: 16.0),
                ),
                const SizedBox(height: AppSpacing.sm),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                  title: Text(l10n.takePhoto, style: AppTypography.title.copyWith(fontSize: 14.0)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickAndUploadPhoto(ImageSource.camera, profile);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
                  title: Text(l10n.chooseFromGallery, style: AppTypography.title.copyWith(fontSize: 14.0)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickAndUploadPhoto(ImageSource.gallery, profile);
                  },
                ),
                if (_profilePhotoUrl != null && _profilePhotoUrl!.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                    title: Text(l10n.removePhoto, style: AppTypography.title.copyWith(fontSize: 14.0, color: AppColors.error)),
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _profilePhotoUrl = null;
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

  Future<void> _handleSave(ProfileModel currentProfile) async {
    final phoneTrimmed = _phoneController.text.trim();
    final String? phoneVal = phoneTrimmed.isNotEmpty ? phoneTrimmed : null;

    final String? whatsappVal;
    if (_sameAsMobile) {
      whatsappVal = phoneVal;
    } else {
      final text = _whatsappController.text.trim();
      whatsappVal = text.isNotEmpty ? text : null;
    }

    if (phoneVal == null && whatsappVal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.atLeastOneContactRequired,
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final updatedProfile = currentProfile.copyWith(
      fullName: _fullNameController.text.trim(),
      profilePhoto: _profilePhotoUrl,
      phone: phoneVal,
      whatsapp: whatsappVal,
      city: _selectedGovernorate.nameEn,
      area: _selectedDistrict.nameEn,
      // Keep existing locked accountType
      accountType: currentProfile.accountType,
    );

    final success = await ref
        .read(profileNotifierProvider.notifier)
        .updateProfile(updatedProfile);

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.profileUpdatedSuccess,
          ),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeCode = Localizations.localeOf(context).languageCode;
    final profileAsync = ref.watch(currentProfileProvider);
    final notifierState = ref.watch(profileNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          l10n.editProfile,
          style: AppTypography.heading.copyWith(fontSize: 18.0),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
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
            return const SizedBox.shrink();
          }

          _prefillData(profile);

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Photo / Avatar Section
                    Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () => _showPhotoPickerSheet(context, profile),
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
                                  child: _isUploadingPhoto
                                      ? const Center(
                                          child: CircularProgressIndicator(
                                            color: AppColors.primary,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : ClipOval(
                                          child: (_profilePhotoUrl != null &&
                                                  _profilePhotoUrl!.isNotEmpty)
                                              ? Image.network(
                                                  _profilePhotoUrl!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (ctx, err, stack) => Center(
                                                    child: Text(
                                                      profile.fullName.isNotEmpty
                                                          ? profile.fullName[0].toUpperCase()
                                                          : 'U',
                                                      style: AppTypography.heading.copyWith(
                                                        color: AppColors.primary,
                                                        fontSize: 32.0,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : const Center(
                                                  child: Icon(
                                                    Icons.person_outline_rounded,
                                                    color: AppColors.primary,
                                                    size: 38.0,
                                                  ),
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
                            l10n.changePhoto,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // Locked Read-Only Account Type Indicator
                    Text(
                      l10n.accountTypeLabel,
                      style: AppTypography.title.copyWith(fontSize: 13.5),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md - 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSecondary,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            profile.isBusiness
                                ? Icons.business_outlined
                                : profile.isProfessional
                                    ? Icons.badge_outlined
                                    : Icons.person_outline_rounded,
                            size: 18.0,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: AppSpacing.xs + 2),
                          Expanded(
                            child: Text(
                              profile.accountTypeDisplayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.title.copyWith(
                                fontSize: 14.0,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.lock_outline_rounded,
                            size: 16.0,
                            color: AppColors.textMuted,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs + 2),
                    Text(
                      l10n.contactSupportToChangeType,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 11.0,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Email (Read-only)
                    Text(
                      l10n.emailLabel,
                      style: AppTypography.title.copyWith(fontSize: 13.5),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TextFormField(
                      controller: _emailController,
                      enabled: false,
                      style: AppTypography.title.copyWith(
                        fontSize: 14.0,
                        color: AppColors.textMuted,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: AppColors.textMuted,
                          size: 20.0,
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceSecondary,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.md,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Full Name / Contact Person Name
                    Text(
                      profile.isBusiness ? l10n.contactPersonLabel : l10n.fullNameLabel,
                      style: AppTypography.title.copyWith(fontSize: 13.5),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TextFormField(
                      controller: _fullNameController,
                      style: AppTypography.title.copyWith(fontSize: 14.0),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.person_outline_rounded,
                          color: AppColors.textSecondary,
                          size: 20.0,
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.md,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: AppColors.primary),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.fullNameValidation;
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Mobile Phone Number
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
                        hintStyle: AppTypography.caption.copyWith(
                          color: AppColors.textMuted,
                        ),
                        prefixIcon: const Icon(
                          Icons.phone_outlined,
                          color: AppColors.textSecondary,
                          size: 20.0,
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.md,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: AppColors.primary),
                        ),
                      ),
                      validator: (value) {
                        final phoneTrimmed = value?.trim() ?? '';
                        final whatsappTrimmed = _sameAsMobile
                            ? phoneTrimmed
                            : _whatsappController.text.trim();
                        if (phoneTrimmed.isEmpty && whatsappTrimmed.isEmpty) {
                          return l10n.atLeastOneContactRequired;
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // WhatsApp Same as Mobile Checkbox / Toggle
                    CheckboxListTile(
                      value: _sameAsMobile,
                      activeColor: AppColors.primary,
                      checkColor: AppColors.background,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(
                        l10n.sameAsMobile,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 13.0,
                        ),
                      ),
                      onChanged: (bool? value) {
                        setState(() {
                          _sameAsMobile = value ?? false;
                          if (_sameAsMobile) {
                            _whatsappController.text = _phoneController.text.trim();
                          } else {
                            _whatsappController.clear();
                          }
                        });
                      },
                    ),

                    if (!_sameAsMobile) ...[
                      const SizedBox(height: AppSpacing.md),

                      // WhatsApp Number (Separate)
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
                          hintStyle: AppTypography.caption.copyWith(
                            color: AppColors.textMuted,
                          ),
                          prefixIcon: const Icon(
                            Icons.chat_outlined,
                            color: AppColors.textSecondary,
                            size: 20.0,
                          ),
                          filled: true,
                          fillColor: AppColors.surface,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.md,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: const BorderSide(color: AppColors.primary),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: AppSpacing.lg),

                    // Governorate / City Dropdown
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
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.md,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: AppColors.primary),
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

                    // Area / District Dropdown
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
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.md,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: AppColors.primary),
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

                    const SizedBox(height: AppSpacing.xxl),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50.0,
                      child: ElevatedButton(
                        onPressed: notifierState.isLoading
                            ? null
                            : () => _handleSave(profile),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.background,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.0),
                          ),
                          elevation: 0,
                        ),
                        child: notifierState.isLoading
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
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
