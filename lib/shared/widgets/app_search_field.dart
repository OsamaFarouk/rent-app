import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Reusable dark search input with optional trailing filter action button.
class AppSearchField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFilterTap;
  final bool showFilterButton;
  final TextInputAction textInputAction;
  final bool autoFocus;

  const AppSearchField({
    super.key,
    required this.hintText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onFilterTap,
    this.showFilterButton = true,
    this.textInputAction = TextInputAction.search,
    this.autoFocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 46.0,
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              textInputAction: textInputAction,
              autofocus: autoFocus,
              style: AppTypography.body.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: AppTypography.body.copyWith(color: AppColors.textMuted),
                prefixIcon: IconButton(
                  icon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.textMuted,
                    size: 20.0,
                  ),
                  onPressed: () {
                    if (onSubmitted != null && controller != null) {
                      onSubmitted!(controller!.text);
                    }
                  },
                ),
                suffixIcon: (controller != null && controller!.text.isNotEmpty)
                    ? IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppColors.textMuted,
                          size: 18.0,
                        ),
                        onPressed: () {
                          controller!.clear();
                          if (onChanged != null) onChanged!('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm + 2,
                ),
              ),
            ),
          ),
        ),
        if (showFilterButton) ...[
          const SizedBox(width: AppSpacing.sm),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onFilterTap,
              borderRadius: BorderRadius.circular(14.0),
              child: Container(
                width: 46.0,
                height: 46.0,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: AppColors.textPrimary,
                  size: 20.0,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
