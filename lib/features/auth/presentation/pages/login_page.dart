import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../providers/auth_provider.dart';

/// Clean, dark-themed Login Page for Rent App.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onFieldChanged);
    _passwordController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    ref.read(authNotifierProvider.notifier).clearMessages();
  }

  @override
  void dispose() {
    _emailController.removeListener(_onFieldChanged);
    _passwordController.removeListener(_onFieldChanged);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    ref.read(authNotifierProvider.notifier).clearMessages();

    final success = await ref.read(authNotifierProvider.notifier).signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );

    if (mounted) {
      final authError = ref.read(authNotifierProvider).errorMessage;

      if (success) {
        final user = ref.read(currentUserProvider);
        if (user != null) {
          final profile =
              await ref.read(profileRepositoryProvider).getProfile(user.id);
          if (mounted && profile != null) {
            if (!profile.hasCompletedOnboarding) {
              context.go('/profile-setup');
              return;
            }
          }
        }
        if (mounted) {
          context.pop();
        }
      } else if (authError == 'accountSuspendedMessage' ||
          authError == 'accountDeletedMessage') {
        // Dismiss Sign In modal cleanly. AppShell handles navigation & single SnackBar display!
        if (mounted) {
          context.pop();
        }
      }
    }
  }

  String _getErrorMessage(AppLocalizations l10n, String key) {
    switch (key) {
      case 'invalidCredentialsError':
        return l10n.invalidCredentialsError;
      case 'checkEmailVerification':
        return l10n.checkEmailVerification;
      case 'accountDeletedMessage':
        return l10n.accountDeletedMessage;
      case 'accountSuspendedMessage':
        return l10n.accountSuspendedMessage;
      case 'sessionExpiredMessage':
        return l10n.sessionExpiredMessage;
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
                const SizedBox(height: AppSpacing.md),

                // Welcome Header
                Text(
                  l10n.signIn,
                  style: AppTypography.heading.copyWith(
                    fontSize: 28.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.profileDesc,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 14.0,
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Email Input
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
                    if (value == null || value.trim().isEmpty) {
                      return l10n.emailValidation;
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return l10n.emailValidation;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.lg),

                // Password Input
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
                    if (value == null || value.isEmpty) {
                      return l10n.passwordValidation;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.sm),

                // Forgot Password Link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Navigate to Forgot Password page
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      l10n.forgotPasswordLink,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Credential Error Banner (Only for credential errors on LoginPage)
                if (authState.errorMessage != null &&
                    authState.errorMessage != 'accountSuspendedMessage' &&
                    authState.errorMessage != 'accountDeletedMessage') ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.3),
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
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],

                // Sign In Button
                SizedBox(
                  width: double.infinity,
                  height: 52.0,
                  child: ElevatedButton(
                    onPressed: authState.isLoading ? null : _handleContinueWithButton,
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
                            l10n.signIn,
                            style: AppTypography.button.copyWith(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w700,
                              color: AppColors.background,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.dontHaveAccount,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    GestureDetector(
                      onTap: () {
                        context.pushReplacement('/register');
                      },
                      child: Text(
                        l10n.createAccount,
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

  void _handleContinueWithButton() {
    _handleLogin();
  }
}
