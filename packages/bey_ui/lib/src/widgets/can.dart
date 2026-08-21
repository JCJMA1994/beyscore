import 'package:bey_domain/bey_domain.dart';
import 'package:flutter/material.dart';

/// Declarative widget that checks capabilities via [PermissionService].
///
/// Ensures no ad-hoc `if (user.isAdmin)` checks exist in widgets.
///
/// Usage:
/// ```dart
/// Can(
///   capability: Capability.editTournament,
///   role: DeviceRole.phone,
///   actorUserId: user.id,
///   tournamentOwnerId: tournament.organizerIds.firstOrNull,
///   child: ElevatedButton(...),
///   fallback: Text('Read-only'),
/// )
/// ```
class Can extends StatelessWidget {
  const Can({
    required this.capability,
    required this.role,
    required this.child,
    this.actorUserId,
    this.tournamentOwnerId,
    this.organizerIds,
    this.matchTableNumber,
    this.currentDeviceTableNumber,
    this.playerAId,
    this.playerBId,
    this.isTournamentMatch = false,
    this.isSoloOrganizer = false,
    this.isMatchConfirmed = false,
    this.fallback,
    this.permissionService = const PermissionService(),
    this.mode = CanMode.hide,
    super.key,
  });

  /// Variant that disables/dims the child instead of removing it from tree.
  const Can.dim({
    required this.capability,
    required this.role,
    required this.child,
    this.actorUserId,
    this.tournamentOwnerId,
    this.organizerIds,
    this.matchTableNumber,
    this.currentDeviceTableNumber,
    this.playerAId,
    this.playerBId,
    this.isTournamentMatch = false,
    this.isSoloOrganizer = false,
    this.isMatchConfirmed = false,
    this.permissionService = const PermissionService(),
    super.key,
  })  : fallback = null,
        mode = CanMode.dim;

  final Capability capability;
  final DeviceRole role;
  final String? actorUserId;
  final String? tournamentOwnerId;
  final List<String>? organizerIds;
  final int? matchTableNumber;
  final int? currentDeviceTableNumber;
  final String? playerAId;
  final String? playerBId;
  final bool isTournamentMatch;
  final bool isSoloOrganizer;
  final bool isMatchConfirmed;
  final Widget child;
  final Widget? fallback;
  final PermissionService permissionService;
  final CanMode mode;

  @override
  Widget build(BuildContext context) {
    final result = permissionService.can(
      capability,
      deviceRole: role,
      actorUserId: actorUserId,
      tournamentOwnerId: tournamentOwnerId,
      organizerIds: organizerIds,
      matchTableNumber: matchTableNumber,
      currentDeviceTableNumber: currentDeviceTableNumber,
      playerAId: playerAId,
      playerBId: playerBId,
      isTournamentMatch: isTournamentMatch,
      isSoloOrganizer: isSoloOrganizer,
      isMatchConfirmed: isMatchConfirmed,
    );

    if (result.isAllowed) {
      return child;
    }

    if (mode == CanMode.dim) {
      return IgnorePointer(
        child: Opacity(
          opacity: 0.38,
          child: child,
        ),
      );
    }

    return fallback ?? const SizedBox.shrink();
  }
}

enum CanMode {
  hide,
  dim,
}
