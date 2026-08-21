import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';

/// Styled input field matching the dark chamfered aesthetic.
class BeyInput extends StatelessWidget {
  const BeyInput({
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.keyboardType,
    super.key,
  });

  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: AppTypography.bodyMedium.copyWith(color: AppColors.text),
      cursorColor: AppColors.x,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: AppTypography.bodySmall.copyWith(color: AppColors.mute),
        hintText: hintText,
        hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.mute.withValues(alpha: 0.6)),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.panel,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.cornerRadius),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.cornerRadius),
          borderSide: const BorderSide(color: AppColors.x, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
