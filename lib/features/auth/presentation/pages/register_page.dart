import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

/// Registration Page for new users.
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedAccountType = 'user';

  @override
  void initState() {
    super.initState();
    _fullNameController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _passwordController.addListener(_onFieldChanged);
    _confirmPasswordController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    ref.read(authNotifierProvider.notifier).clearMessages();
  }

  @override
  void dispose() {
    _fullNameController.removeListener(_onFieldChanged);
    _emailController.removeListener(_onFieldChanged);
    _passwordController.removeListener(_onFieldChanged);
    _confirmPasswordController.removeListener(_onFieldChanged);
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    ref.read(authNotifierProvider.notifier).clearMessages();

    final success = await ref.read(authNotifierProvider.notifier).signUp(
          email: _emailController.text,
          password: _passwordController.text,
          fullName: _fullNameController.text,
          accountType: _selectedAccountType,
        );

    if (mounted && success) {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        context.go('/profile-setup');
      } else {
        final authState = ref.read(authNotifierProvider);
        if (authState.infoMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.checkEmailVerification,
              ),
              backgroundColor: AppColors.primary,
            ),
          );
        }
        context.pop();
      }
    }
  }

  String _getErrorMessage(AppLocalizations l10n, String key) {
    switch (key) {
      case 'invalidCredentialsError':
        return l10n.invalidCredentialsError;
      case 'checkEmailVerification':
        return l10n.checkEmailVerification;
      case 'userAlreadyExistsError':
        return l10n.userAlreadyExistsError;
      case 'signupDisabledError':
        return l10n.signupDisabledError;
      case 'rateLimitError':
        return l10n.rateLimitError;
      case 'networkError':
        return l10n.networkError;
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.createAccount,
                  style: AppTypography.heading.copyWith(
                    fontSize: 28.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.discoveryMarketplace,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 14.0,
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                if (authState.errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.error,
                          size: 20.0,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            _getErrorMessage(l10n, authState.errorMessage!),
                            style: AppTypography.caption.copyWith(
                              color: AppColors.error,
                              fontSize: 13.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],

                // Full Name Field
                Text(
                  l10n.fullNameLabel,
                  style: AppTypography.title.copyWith(fontSize: 13.5),
                ),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _fullNameController,
                  style: AppTypography.title.copyWith(fontSize: 14.0),
                  decoration: InputDecoration(
                    hintText: 'Ahmed Nabil',
                    hintStyle: AppTypography.caption.copyWith(
                      color: AppColors.textMuted,
                    ),
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

                const SizedBox(height: AppSpacing.md),

                // Email Field
                Text(
                  l10n.emailLabel,
                  style: AppTypography.title.copyWith(fontSize: 13.5),
                ),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  style: AppTypography.title.copyWith(fontSize: 14.0),
                  decoration: InputDecoration(
                    hintText: 'name@example.com',
                    hintStyle: AppTypography.caption.copyWith(
                      color: AppColors.textMuted,
                    ),
                    prefixIcon: const Icon(
                      Icons.email_outlined,
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
                    if (value == null || value.trim().isEmpty || !value.contains('@') || !value.contains('.')) {
                      return l10n.emailValidation;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.md),

                // Password Field
                Text(
                  l10n.passwordLabel,
                  style: AppTypography.title.copyWith(fontSize: 13.5),
                ),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: AppTypography.title.copyWith(fontSize: 14.0),
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    hintStyle: AppTypography.caption.copyWith(
                      color: AppColors.textMuted,
                    ),
                    prefixIcon: const Icon(
                      Icons.lock_outline_rounded,
                      color: AppColors.textSecondary,
                      size: 20.0,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textSecondary,
                        size: 20.0,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
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
                    if (value == null || value.length < 6) {
                      return l10n.passwordValidation;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.md),

                // Confirm Password Field
                Text(
                  l10n.confirmPasswordLabel,
                  style: AppTypography.title.copyWith(fontSize: 13.5),
                ),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  style: AppTypography.title.copyWith(fontSize: 14.0),
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    hintStyle: AppTypography.caption.copyWith(
                      color: AppColors.textMuted,
                    ),
                    prefixIcon: const Icon(
                      Icons.lock_outline_rounded,
                      color: AppColors.textSecondary,
                      size: 20.0,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textSecondary,
                        size: 20.0,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
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
                    if (value != _passwordController.text) {
                      return l10n.passwordMismatch;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.md),

                // Account Type Selector
                Text(
                  l10n.accountTypeLabel,
                  style: AppTypography.title.copyWith(fontSize: 13.5),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Expanded(
                      child: _buildAccountTypeOption(
                        type: 'user',
                        label: 'User',
                        icon: Icons.person_outline_rounded,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: _buildAccountTypeOption(
                        type: 'professional',
                        label: 'Professional',
                        icon: Icons.badge_outlined,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: _buildAccountTypeOption(
                        type: 'business',
                        label: 'Business',
                        icon: Icons.storefront_outlined,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Create Account Button
                SizedBox(
                  width: double.infinity,
                  height: 52.0,
                  child: ElevatedButton(
                    onPressed: authState.isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                      elevation: 0,
                    ),
                    child: authState.isLoading
                        ? const SizedBox(
                            width: 22.0,
                            height: 22.0,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.background,
                            ),
                          )
                        : Text(
                            l10n.createAccount,
                            style: AppTypography.button.copyWith(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w700,
                              color: AppColors.background,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Sign In Link
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      l10n.alreadyHaveAccount,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Text(
                        l10n.signIn,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountTypeOption({
    required String type,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedAccountType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAccountType = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySoft : AppColors.surface,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20.0,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: 4.0),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 11.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
