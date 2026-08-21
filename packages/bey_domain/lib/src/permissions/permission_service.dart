import 'capability.dart';
import 'device_role.dart';
import 'permission_result.dart';

/// Pure function permission service.
///
/// Follows SISTEMA.md:
/// - 12 fine-grained capabilities.
/// - Never checks a global `isAdmin` boolean.
/// - Calculates permissions strictly from the resource context and device role.
/// - Transparent handling of conflict of interest in arbitration.
class PermissionService {
  const PermissionService();

  PermissionResult can(
    Capability capability, {
    required DeviceRole deviceRole,
    String? actorUserId,
    String? tournamentOwnerId,
    List<String>? organizerIds,
    int? matchTableNumber,
    int? currentDeviceTableNumber,
    String? playerAId,
    String? playerBId,
    bool isTournamentMatch = false,
    bool isSoloOrganizer = false,
    bool isMatchConfirmed = false,
  }) {
    // 1. Devices in WideWeb mode (read-only)
    if (deviceRole == DeviceRole.wideWeb) {
      return switch (capability) {
        Capability.viewCatalogAndDecks => PermissionResult.allowed,
        Capability.exportTournamentData => PermissionResult.allowed,
        _ => const PermissionResult.denied('Dispositivo en modo espectador (solo lectura)'),
      };
    }

    // 2. Table Devices (TableShell)
    if (deviceRole == DeviceRole.table) {
      return switch (capability) {
        Capability.recordMatchResult => (currentDeviceTableNumber != null &&
                matchTableNumber == currentDeviceTableNumber)
            ? PermissionResult.allowed
            : PermissionResult.denied('Este combate no está asignado a esta mesa (Mesa $currentDeviceTableNumber)'),

        Capability.confirmResult => PermissionResult.allowed,
        Capability.resolveDispute =>
          const PermissionResult.denied('Un dispositivo de mesa no puede resolver disputas (no tiene identidad personal)'),
        Capability.applyInstantLoss =>
          const PermissionResult.denied('La sanción por descalificación requiere identidad de juez'),
        Capability.closeRound =>
          const PermissionResult.denied('Solo el organizador del torneo puede cerrar la ronda'),
        Capability.runDraw =>
          const PermissionResult.denied('El sorteo solo se realiza desde el dispositivo del organizador'),
        Capability.editTournament =>
          const PermissionResult.denied('No se puede editar el torneo desde una mesa compartida'),
        Capability.viewCatalogAndDecks =>
          const PermissionResult.denied('La mesa está dedicada exclusivamente al combate'),
        Capability.registerToTournament =>
          const PermissionResult.denied('Inscripciones cerradas en dispositivo de mesa'),
        Capability.checkInDeck =>
          const PermissionResult.denied('El chequeo de piezas lo realiza el organizador'),
        Capability.publishResults =>
          const PermissionResult.denied('Publicación reservada al organizador'),
        Capability.exportTournamentData =>
          const PermissionResult.denied('Operación no disponible en mesa'),
      };
    }

    // 3. Phone Devices (User & Organizer)
    final isOwner = actorUserId != null && actorUserId == tournamentOwnerId;
    final isOrganizer = isOwner || (actorUserId != null && organizerIds != null && organizerIds.contains(actorUserId));
    final isPlayerInMatch = actorUserId != null && (actorUserId == playerAId || actorUserId == playerBId);

    return switch (capability) {
      Capability.recordMatchResult => _canRecordMatchResultOnPhone(
          isTournamentMatch: isTournamentMatch,
          isOrganizer: isOrganizer,
          isPlayerInMatch: isPlayerInMatch,
        ),
      Capability.confirmResult => isPlayerInMatch || isOrganizer
          ? PermissionResult.allowed
          : const PermissionResult.denied('Solo los participantes del combate o el juez pueden confirmar'),
      Capability.resolveDispute => _canResolveDisputeOnPhone(
          isOrganizer: isOrganizer,
          isPlayerInMatch: isPlayerInMatch,
          isSoloOrganizer: isSoloOrganizer,
        ),
      Capability.applyInstantLoss => isOrganizer
          ? PermissionResult.allowed
          : const PermissionResult.denied('Solo los jueces u organizadores pueden aplicar derrotas instantáneas'),
      Capability.closeRound => isOrganizer
          ? PermissionResult.allowed
          : const PermissionResult.denied('Solo el organizador puede cerrar la ronda'),
      Capability.runDraw => isOrganizer
          ? PermissionResult.allowed
          : const PermissionResult.denied('Solo el organizador puede sortear el cuadro'),
      Capability.editTournament => isOwner
          ? PermissionResult.allowed
          : const PermissionResult.denied('Solo el creador del torneo puede modificar su configuración'),
      Capability.viewCatalogAndDecks => PermissionResult.allowed,
      Capability.registerToTournament => actorUserId != null
          ? PermissionResult.allowed
          : const PermissionResult.denied('Requiere perfil activo'),
      Capability.checkInDeck => isOrganizer
          ? PermissionResult.allowed
          : const PermissionResult.denied('Solo el equipo organizador valida el pase de chequeo'),
      Capability.publishResults => isOwner
          ? PermissionResult.allowed
          : const PermissionResult.denied('Solo el creador del torneo puede publicar los resultados finales'),
      Capability.exportTournamentData => PermissionResult.allowed,
    };
  }

  PermissionResult _canRecordMatchResultOnPhone({
    required bool isTournamentMatch,
    required bool isOrganizer,
    required bool isPlayerInMatch,
  }) {
    if (!isTournamentMatch) {
      // Casual match outside tournaments: any player can record
      return PermissionResult.allowed;
    }
    if (isOrganizer || isPlayerInMatch) {
      return PermissionResult.allowed;
    }
    return const PermissionResult.denied('No eres participante ni juez de este combate');
  }

  PermissionResult _canResolveDisputeOnPhone({
    required bool isOrganizer,
    required bool isPlayerInMatch,
    required bool isSoloOrganizer,
  }) {
    if (!isOrganizer) {
      return const PermissionResult.denied('Solo los organizadores o jueces pueden resolver disputas');
    }
    if (isPlayerInMatch) {
      if (isSoloOrganizer) {
        // Transparent self-arbitration allowed as last resort (SISTEMA.md §6 & docs/2-organizador.html §10)
        return PermissionResult.selfArbitrationAllowed;
      }
      return const PermissionResult.denied(
        'Conflicto de interés: Eres participante de este combate. Debe resolverlo otro juez asignado.',
      );
    }
    return PermissionResult.allowed;
  }
}
