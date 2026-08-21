import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'chamfer_button.dart';
import 'chamfer_card.dart';

enum BeyFeedbackType { error, warning, success, info }

/// Tactical modal dialog for errors, warnings, and success notifications.
///
/// Designed to replace transient SnackBars with clear, actionable diagnostics
/// explaining why an action failed and how the user can resolve it.
class BeyFeedbackDialog extends StatelessWidget {
  const BeyFeedbackDialog({
    super.key,
    required this.title,
    required this.message,
    this.solution,
    this.type = BeyFeedbackType.error,
    this.confirmText = 'ENTENDIDO',
    this.cancelText,
    this.onConfirm,
    this.onCancel,
  });

  final String title;
  final String message;
  final String? solution;
  final BeyFeedbackType type;
  final String confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  static Future<bool?> showError(
    BuildContext context, {
    required String title,
    required String message,
    String? solution,
    String confirmText = 'ENTENDIDO',
    VoidCallback? onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (ctx) => BeyFeedbackDialog(
        title: title,
        message: message,
        solution: solution,
        type: BeyFeedbackType.error,
        confirmText: confirmText,
        onConfirm: () {
          Navigator.of(ctx).pop(true);
          onConfirm?.call();
        },
      ),
    );
  }

  static Future<bool?> showWarning(
    BuildContext context, {
    required String title,
    required String message,
    String? solution,
    String confirmText = 'CONTINUAR',
    String? cancelText = 'CANCELAR',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (ctx) => BeyFeedbackDialog(
        title: title,
        message: message,
        solution: solution,
        type: BeyFeedbackType.warning,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: () {
          Navigator.of(ctx).pop(true);
          onConfirm?.call();
        },
        onCancel: () {
          Navigator.of(ctx).pop(false);
          onCancel?.call();
        },
      ),
    );
  }

  static Future<bool?> showConfirm(
    BuildContext context, {
    required String title,
    required String message,
    String? solution,
    String confirmText = 'CONFIRMAR',
    String cancelText = 'CANCELAR',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (ctx) => BeyFeedbackDialog(
        title: title,
        message: message,
        solution: solution,
        type: BeyFeedbackType.warning,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: () {
          Navigator.of(ctx).pop(true);
          onConfirm?.call();
        },
        onCancel: () {
          Navigator.of(ctx).pop(false);
          onCancel?.call();
        },
      ),
    );
  }

  static Future<bool?> showSuccess(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'ACEPTAR',
    VoidCallback? onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black87,
      builder: (ctx) => BeyFeedbackDialog(
        title: title,
        message: message,
        type: BeyFeedbackType.success,
        confirmText: confirmText,
        onConfirm: () {
          Navigator.of(ctx).pop(true);
          onConfirm?.call();
        },
      ),
    );
  }

  static Future<bool?> showInfo(
    BuildContext context, {
    required String title,
    required String message,
    String? solution,
    String confirmText = 'ENTENDIDO',
    VoidCallback? onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black87,
      builder: (ctx) => BeyFeedbackDialog(
        title: title,
        message: message,
        solution: solution,
        type: BeyFeedbackType.info,
        confirmText: confirmText,
        onConfirm: () {
          Navigator.of(ctx).pop(true);
          onConfirm?.call();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final (accentColor, iconData, typeLabel) = switch (type) {
      BeyFeedbackType.error => (AppColors.dranzer, Icons.error_outline_rounded, 'ERROR DETECTADO'),
      BeyFeedbackType.warning => (AppColors.pegasus, Icons.warning_amber_rounded, 'ADVERTENCIA'),
      BeyFeedbackType.success => (AppColors.green, Icons.check_circle_outline_rounded, 'ÉXITO'),
      BeyFeedbackType.info => (AppColors.x, Icons.info_outline_rounded, 'INFORMACIÓN'),
    };

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: ChamferCard(
          backgroundColor: AppColors.void_,
          borderColor: accentColor,
          borderWidth: 1.5,
          glowColor: accentColor.withValues(alpha: 0.2),
          glowRadius: 10,
          cutSize: 14,
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header tag
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      border: Border.all(color: accentColor.withValues(alpha: 0.6)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(iconData, size: 14, color: accentColor),
                        const SizedBox(width: 6),
                        Text(
                          typeLabel,
                          style: AppTypography.mono.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Title
              Text(
                title.toUpperCase(),
                style: AppTypography.displaySmall.copyWith(
                  fontSize: 18,
                  letterSpacing: 0.5,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 10),

              // Problem message
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.panel,
                  border: Border.all(color: AppColors.line),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  message,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.text,
                    height: 1.45,
                  ),
                ),
              ),

              // Solution / Actionable hint (if provided)
              if (solution != null && solution!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.08),
                    border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lightbulb_outline_rounded, size: 18, color: accentColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '¿CÓMO SOLUCIONARLO?',
                              style: AppTypography.mono.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: accentColor,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              solution!,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.text,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 22),

              // Action buttons
              Row(
                children: [
                  if (cancelText != null) ...[
                    Expanded(
                      child: ChamferButton(
                        text: cancelText!,
                        variant: ChamferButtonVariant.ghost,
                        onPressed: onCancel ?? () => Navigator.of(context).pop(false),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: ChamferButton(
                      text: confirmText,
                      variant: switch (type) {
                        BeyFeedbackType.error => ChamferButtonVariant.danger,
                        BeyFeedbackType.warning => ChamferButtonVariant.warning,
                        BeyFeedbackType.success => ChamferButtonVariant.go,
                        BeyFeedbackType.info => ChamferButtonVariant.primary,
                      },
                      onPressed: onConfirm ?? () => Navigator.of(context).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
