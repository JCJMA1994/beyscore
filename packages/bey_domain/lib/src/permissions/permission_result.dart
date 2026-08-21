import 'package:equatable/equatable.dart';

/// Result of evaluating a capability on a resource.
///
/// If allowed is false, provides a clear user-facing reason in [denialReason]
/// instead of silently hiding buttons (as required by SISTEMA.md).
class PermissionResult extends Equatable {
  const PermissionResult({
    required this.isAllowed,
    this.denialReason,
    this.isSelfArbitration = false,
  });

  const PermissionResult.denied(String reason)
      : isAllowed = false,
        denialReason = reason,
        isSelfArbitration = false;

  final bool isAllowed;
  final String? denialReason;
  final bool isSelfArbitration;

  static const allowed = PermissionResult(isAllowed: true);
  static const selfArbitrationAllowed = PermissionResult(
    isAllowed: true,
    isSelfArbitration: true,
  );

  @override
  List<Object?> get props => [isAllowed, denialReason, isSelfArbitration];
}
