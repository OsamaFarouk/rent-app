import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/egypt_locations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../domain/category_model.dart';
import '../../domain/equipment_model.dart';
import '../providers/equipment_providers.dart';

/// Form screen for adding a new equipment listing or editing an existing equipment listing.
class AddEquipmentPage extends ConsumerStatefulWidget {
  final EquipmentModel? equipmentToEdit;
  final String? equipmentId;

  const AddEquipmentPage({
    super.key,
    this.equipmentToEdit,
    this.equipmentId,
  });

  @override
  ConsumerState<AddEquipmentPage> createState() => _AddEquipmentPageState();
}

class _AddEquipmentPageState extends ConsumerState<AddEquipmentPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _dailyPriceController = TextEditingController();
  final TextEditingController _weeklyPriceController = TextEditingController();
  final TextEditingController _accessoriesController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  CategoryModel? _selectedCategory;
  String _selectedCondition = 'Excellent';
  EgyptGovernorate _selectedGovernorate = EgyptLocations.governorates.first;
  EgyptDistrict _selectedDistrict = EgyptLocations.governorates.first.districts.first;

  List<String> _existingImageUrls = [];
  final List<XFile> _selectedImages = [];
  bool _isSubmitting = false;
  bool _initializedProfileData = false;
  bool _isEditingInitialized = false;

  final List<String> _conditions = ['Like New', 'Excellent', 'Good', 'Fair'];

  bool get _isEditing =>
      widget.equipmentToEdit != null || (widget.equipmentId != null && widget.equipmentId!.isNotEmpty);

  EquipmentModel? _getEditingEquipment() {
    if (widget.equipmentToEdit != null) return widget.equipmentToEdit;
    if (widget.equipmentId != null && widget.equipmentId!.isNotEmpty) {
      return ref.watch(equipmentDetailProvider(widget.equipmentId!)).value;
    }
    return null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _dailyPriceController.dispose();
    _weeklyPriceController.dispose();
    _accessoriesController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _prefillUserLocation() {
    if (!_initializedProfileData && !_isEditing) {
      final profile = ref.read(currentProfileProvider).value;
      if (profile != null) {
        _selectedGovernorate = EgyptLocations.findGovernorate(profile.city);
        _selectedDistrict = EgyptLocations.findDistrict(_selectedGovernorate, profile.area ?? '');
      }
      _initializedProfileData = true;
    }
  }

  void _prefillEquipmentData(EquipmentModel equipment) {
    if (_isEditingInitialized) return;
    _isEditingInitialized = true;

    _nameController.text = equipment.name;
    _brandController.text = equipment.brand ?? '';
    _modelController.text = equipment.model ?? '';
    _dailyPriceController.text = equipment.dailyPrice == equipment.dailyPrice.roundToDouble()
        ? equipment.dailyPrice.toInt().toString()
        : equipment.dailyPrice.toString();
    _weeklyPriceController.text = equipment.weeklyPrice != null
        ? (equipment.weeklyPrice == equipment.weeklyPrice!.roundToDouble()
            ? equipment.weeklyPrice!.toInt().toString()
            : equipment.weeklyPrice!.toString())
        : '';
    _accessoriesController.text = equipment.accessories ?? '';
    _descriptionController.text = equipment.description ?? '';

    if (equipment.condition != null && _conditions.contains(equipment.condition)) {
      _selectedCondition = equipment.condition!;
    }

    _selectedGovernorate = EgyptLocations.findGovernorate(equipment.city);
    _selectedDistrict = EgyptLocations.findDistrict(_selectedGovernorate, equipment.area ?? '');

    if (equipment.images.isNotEmpty) {
      _existingImageUrls = equipment.images.map((img) => img.imageUrl).toList();
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    try {
      final pickedFiles = await picker.pickMultiImage(
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (pickedFiles.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(pickedFiles);
        });
      }
    } catch (e) {
      debugPrint('[AddEquipmentPage] Image pick error: $e');
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider);
    if (user == null) {
      context.push('/login');
      return;
    }

    final dailyPriceNum = double.tryParse(_dailyPriceController.text.trim());
    if (dailyPriceNum == null || dailyPriceNum <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid daily price.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final weeklyPriceNum = double.tryParse(_weeklyPriceController.text.trim());

    final targetEquipment = _getEditingEquipment();
    if (_isEditing && targetEquipment != null) {
      if (user.id != targetEquipment.ownerId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You are not authorized to edit this equipment.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (_isEditing && targetEquipment != null) {
        await ref.read(equipmentRepositoryProvider).updateEquipment(
              equipmentId: targetEquipment.id,
              ownerId: user.id,
              name: _nameController.text.trim(),
              dailyPrice: dailyPriceNum,
              weeklyPrice: weeklyPriceNum,
              categoryId: _selectedCategory?.id,
              brand: _brandController.text.trim(),
              model: _modelController.text.trim(),
              description: _descriptionController.text.trim(),
              condition: _selectedCondition,
              accessories: _accessoriesController.text.trim(),
              city: _selectedGovernorate.nameEn,
              area: _selectedDistrict.nameEn,
              newImageFiles: _selectedImages,
              existingImageUrls: _existingImageUrls,
            );

        ref.invalidate(myEquipmentProvider);
        ref.invalidate(publicApprovedEquipmentProvider);
        ref.invalidate(equipmentDetailProvider(targetEquipment.id));
      } else {
        await ref.read(equipmentRepositoryProvider).createEquipment(
              ownerId: user.id,
              name: _nameController.text.trim(),
              dailyPrice: dailyPriceNum,
              weeklyPrice: weeklyPriceNum,
              categoryId: _selectedCategory?.id,
              brand: _brandController.text.trim(),
              model: _modelController.text.trim(),
              description: _descriptionController.text.trim(),
              condition: _selectedCondition,
              accessories: _accessoriesController.text.trim(),
              city: _selectedGovernorate.nameEn,
              area: _selectedDistrict.nameEn,
              imageFiles: _selectedImages,
            );

        ref.invalidate(myEquipmentProvider);
        ref.invalidate(publicApprovedEquipmentProvider);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.equipmentSubmittedSuccess),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 4),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeCode = Localizations.localeOf(context).languageCode;
    final categoriesAsync = ref.watch(equipmentCategoriesProvider);

    final editingEquipment = _getEditingEquipment();
    if (editingEquipment != null) {
      _prefillEquipmentData(editingEquipment);
    } else {
      _prefillUserLocation();
    }

    final totalImagesCount = 1 + _existingImageUrls.length + _selectedImages.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          _isEditing ? 'Edit Equipment' : l10n.addEquipment,
          style: AppTypography.heading.copyWith(fontSize: 18.0),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Equipment Name Input
                Text('Equipment Title / Name *', style: AppTypography.title.copyWith(fontSize: 13.5)),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _nameController,
                  style: AppTypography.title.copyWith(fontSize: 14.0),
                  decoration: _buildInputDecoration('e.g. Sony FX3 Cinema Camera', Icons.camera_alt_outlined),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Please enter equipment title.';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // Category Selector Dropdown
                Text('Category', style: AppTypography.title.copyWith(fontSize: 13.5)),
                const SizedBox(height: AppSpacing.xs),
                categoriesAsync.when(
                  loading: () => const SizedBox(
                    height: 48,
                    child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (categories) {
                    if (_selectedCategory == null && categories.isNotEmpty) {
                      if (_isEditing && editingEquipment?.categoryId != null) {
                        _selectedCategory = categories.firstWhere(
                          (cat) => cat.id == editingEquipment!.categoryId,
                          orElse: () => categories.first,
                        );
                      } else {
                        _selectedCategory = categories.first;
                      }
                    }
                    return DropdownButtonFormField<CategoryModel>(
                      initialValue: _selectedCategory,
                      dropdownColor: AppColors.surface,
                      style: AppTypography.title.copyWith(fontSize: 14.0),
                      decoration: _buildInputDecoration('Select category', Icons.category_outlined),
                      items: categories.map((cat) {
                        return DropdownMenuItem<CategoryModel>(
                          value: cat,
                          child: Text(cat.getLocalizedName(localeCode)),
                        );
                      }).toList(),
                      onChanged: (cat) {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // Brand & Model Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Brand', style: AppTypography.title.copyWith(fontSize: 13.5)),
                          const SizedBox(height: AppSpacing.xs),
                          TextFormField(
                            controller: _brandController,
                            style: AppTypography.title.copyWith(fontSize: 14.0),
                            decoration: _buildInputDecoration('e.g. Sony', Icons.branding_watermark_outlined),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Model', style: AppTypography.title.copyWith(fontSize: 13.5)),
                          const SizedBox(height: AppSpacing.xs),
                          TextFormField(
                            controller: _modelController,
                            style: AppTypography.title.copyWith(fontSize: 14.0),
                            decoration: _buildInputDecoration('e.g. FX3', Icons.memory_outlined),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Pricing Row (Daily & Weekly)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Daily Price (EGP) *', style: AppTypography.title.copyWith(fontSize: 13.5)),
                          const SizedBox(height: AppSpacing.xs),
                          TextFormField(
                            controller: _dailyPriceController,
                            keyboardType: TextInputType.number,
                            style: AppTypography.title.copyWith(fontSize: 14.0),
                            decoration: _buildInputDecoration('2500', Icons.payments_outlined),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'Enter daily price.';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Weekly Price (EGP)', style: AppTypography.title.copyWith(fontSize: 13.5)),
                          const SizedBox(height: AppSpacing.xs),
                          TextFormField(
                            controller: _weeklyPriceController,
                            keyboardType: TextInputType.number,
                            style: AppTypography.title.copyWith(fontSize: 14.0),
                            decoration: _buildInputDecoration('12000', Icons.account_balance_wallet_outlined),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Condition Dropdown
                Text('Condition', style: AppTypography.title.copyWith(fontSize: 13.5)),
                const SizedBox(height: AppSpacing.xs),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCondition,
                  dropdownColor: AppColors.surface,
                  style: AppTypography.title.copyWith(fontSize: 14.0),
                  decoration: _buildInputDecoration('Condition', Icons.stars_outlined),
                  items: _conditions.map((c) {
                    return DropdownMenuItem<String>(
                      value: c,
                      child: Text(c),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedCondition = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // City / Governorate Dropdown
                Text('City / Governorate', style: AppTypography.title.copyWith(fontSize: 13.5)),
                const SizedBox(height: AppSpacing.xs),
                DropdownButtonFormField<EgyptGovernorate>(
                  initialValue: _selectedGovernorate,
                  dropdownColor: AppColors.surface,
                  style: AppTypography.title.copyWith(fontSize: 14.0),
                  decoration: _buildInputDecoration('Governorate', Icons.location_city_outlined),
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
                const SizedBox(height: AppSpacing.md),

                // District / Area Dropdown
                Text('District / Area', style: AppTypography.title.copyWith(fontSize: 13.5)),
                const SizedBox(height: AppSpacing.xs),
                DropdownButtonFormField<EgyptDistrict>(
                  key: ValueKey('dist_${_selectedGovernorate.id}_${_selectedDistrict.id}'),
                  initialValue: _selectedDistrict,
                  dropdownColor: AppColors.surface,
                  style: AppTypography.title.copyWith(fontSize: 14.0),
                  decoration: _buildInputDecoration('Area', Icons.map_outlined),
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
                const SizedBox(height: AppSpacing.md),

                // Accessories
                Text('Included Accessories', style: AppTypography.title.copyWith(fontSize: 13.5)),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _accessoriesController,
                  style: AppTypography.title.copyWith(fontSize: 14.0),
                  decoration: _buildInputDecoration('e.g. 2x Batteries, Charger, XLR Handle, 160GB CFexpress Card', Icons.extension_outlined),
                ),
                const SizedBox(height: AppSpacing.md),

                // Description
                Text('Description', style: AppTypography.title.copyWith(fontSize: 13.5)),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  style: AppTypography.title.copyWith(fontSize: 14.0),
                  decoration: _buildInputDecoration('Detailed description of the equipment...', Icons.description_outlined),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Photos Section
                Text('Equipment Photos', style: AppTypography.title.copyWith(fontSize: 13.5)),
                const SizedBox(height: AppSpacing.xs),
                SizedBox(
                  height: 90.0,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: totalImagesCount,
                    separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return GestureDetector(
                          onTap: _pickImages,
                          child: Container(
                            width: 90.0,
                            height: 90.0,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_outlined, color: AppColors.primary, size: 24.0),
                                SizedBox(height: 4.0),
                                Text(
                                  'Add Photo',
                                  style: TextStyle(color: AppColors.primary, fontSize: 10.0, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final existingCount = _existingImageUrls.length;
                      if (index <= existingCount) {
                        final existingUrlIndex = index - 1;
                        final url = _existingImageUrls[existingUrlIndex];
                        return Stack(
                          children: [
                            Container(
                              width: 90.0,
                              height: 90.0,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: (url.startsWith('http://') || url.startsWith('https://'))
                                  ? Image.network(
                                      url,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Center(
                                        child: Icon(Icons.camera_alt_outlined, color: AppColors.textMuted, size: 24),
                                      ),
                                    )
                                  : Image.asset(
                                      url,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Center(
                                        child: Icon(Icons.camera_alt_outlined, color: AppColors.textMuted, size: 24),
                                      ),
                                    ),
                            ),
                            Positioned(
                              top: 2,
                              right: 2,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _existingImageUrls.removeAt(existingUrlIndex);
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: AppColors.error,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white, size: 14),
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      final fileIndex = index - 1 - existingCount;
                      final file = _selectedImages[fileIndex];
                      return Stack(
                        children: [
                          Container(
                            width: 90.0,
                            height: 90.0,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Image.file(
                              File(file.path),
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 2,
                            right: 2,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedImages.removeAt(fileIndex);
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, color: Colors.white, size: 14),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50.0,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22.0,
                            height: 22.0,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.background,
                            ),
                          )
                        : Text(
                            _isEditing ? l10n.saveChanges : l10n.addEquipment,
                            style: AppTypography.button.copyWith(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w700,
                              color: AppColors.background,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.caption.copyWith(color: AppColors.textMuted),
      prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20.0),
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
    );
  }
}
