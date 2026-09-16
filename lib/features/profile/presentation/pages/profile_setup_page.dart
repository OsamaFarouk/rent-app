import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

/// One-time Profile Setup screen asking "Who does this account represent?".
class ProfileSetupPage extends ConsumerStatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  ConsumerState<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends ConsumerState<ProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _businessNameController = TextEditingController();
  String? _selectedProfileType;

  @override
  void dispose() {
    _businessNameController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      context.go('/');
      return;
    }

    if (_selectedProfileType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.selectAccountTypeValidation),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedProfileType == 'business') {
      final isFormValid = _formKey.currentState?.validate() ?? false;
      final name = _businessNameController.text.trim();
      if (!isFormValid || name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.businessNameValidation),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    final success = await ref
        .read(profileNotifierProvider.notifier)
        .completeProfileSetup(
          userId: user.id,
          profileType: _selectedProfileType!,
          businessName: _selectedProfileType == 'business' ? _businessNameController.text.trim() : null,
        );

    if (mounted && success) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final notifierState = ref.watch(profileNotifierProvider);
    final isBusiness = _selectedProfileType == 'business';

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),

                // Title & Description
                Text(
                  l10n.profileSetupHeading,
                  style: AppTypography.heading.copyWith(
                    fontSize: 26.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.profileSetupSubtitle,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 14.0,
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Option 1: User
                _buildOptionCard(
                  type: 'user',
                  title: 'User',
                  description: l10n.personalOptionDesc,
                  icon: Icons.person_outline_rounded,
                ),

                const SizedBox(height: AppSpacing.lg),

                // Option 2: Professional
                _buildOptionCard(
                  type: 'professional',
                  title: l10n.professionalOptionTitle,
                  description: l10n.professionalOptionDesc,
                  icon: Icons.badge_outlined,
                ),

                const SizedBox(height: AppSpacing.lg),

                // Option 3: Business / Rental House
                _buildOptionCard(
                  type: 'business',
                  title: l10n.businessOptionTitle,
                  description: l10n.businessOptionDesc,
                  icon: Icons.business_outlined,
                ),

                // Business Name Field (Required when Business is selected)
                if (isBusiness) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              l10n.businessNameLabel,
                              style: AppTypography.title.copyWith(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                            const Text(
                              ' *',
                              style: TextStyle(color: AppColors.error, fontSize: 14.0),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        TextFormField(
                          controller: _businessNameController,
                          style: AppTypography.title.copyWith(fontSize: 14.0),
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'e.g. Cairo Cine Equipment Rental',
                            hintStyle: AppTypography.caption.copyWith(color: AppColors.textMuted),
                            filled: true,
                            fillColor: AppColors.surfaceElevated,
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
                            if (isBusiness && (value == null || value.trim().isEmpty)) {
                              return l10n.businessNameValidation;
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.xxl),

                if (notifierState.errorMessage != null) ...[
                  Text(
                    l10n.networkError,
                    style: AppTypography.caption.copyWith(color: AppColors.error),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                // Continue Button
                SizedBox(
                  width: double.infinity,
                  height: 52.0,
                  child: ElevatedButton(
                    onPressed: notifierState.isLoading ? null : _handleContinue,
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
                            l10n.continueButton,
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
      ),
    ),
  );
}

  Widget _buildOptionCard({
    required String type,
    required String title,
    required String description,
    required IconData icon,
  }) {
    final isSelected = _selectedProfileType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedProfileType = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySoft : AppColors.surface,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm + 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 26.0,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.title.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    description,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
              size: 22.0,
            ),
          ],
        ),
      ),
    );
  }
}
