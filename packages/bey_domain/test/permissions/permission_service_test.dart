import 'package:bey_domain/bey_domain.dart';
import 'package:test/test.dart';

void main() {
  const permissionService = PermissionService();

  group('PermissionService - Table Role (3-mesa.html & SISTEMA.md)', () {
    test('allows recordMatchResult only on assigned table', () {
      final resAllowed = permissionService.can(
        Capability.recordMatchResult,
        deviceRole: DeviceRole.table,
        matchTableNumber: 3,
        currentDeviceTableNumber: 3,
      );
      expect(resAllowed.isAllowed, isTrue);

      final resDenied = permissionService.can(
        Capability.recordMatchResult,
        deviceRole: DeviceRole.table,
        matchTableNumber: 4,
        currentDeviceTableNumber: 3,
      );
      expect(resDenied.isAllowed, isFalse);
    });

    test('allows confirmResult on table device', () {
      final res = permissionService.can(
        Capability.confirmResult,
        deviceRole: DeviceRole.table,
        currentDeviceTableNumber: 2,
      );
      expect(res.isAllowed, isTrue);
    });

    test('denies resolveDispute, applyInstantLoss, and tournament edits on table', () {
      expect(
        permissionService.can(Capability.resolveDispute, deviceRole: DeviceRole.table).isAllowed,
        isFalse,
      );
      expect(
        permissionService.can(Capability.applyInstantLoss, deviceRole: DeviceRole.table).isAllowed,
        isFalse,
      );
      expect(
        permissionService.can(Capability.closeRound, deviceRole: DeviceRole.table).isAllowed,
        isFalse,
      );
      expect(
        permissionService.can(Capability.editTournament, deviceRole: DeviceRole.table).isAllowed,
        isFalse,
      );
      expect(
        permissionService.can(Capability.viewCatalogAndDecks, deviceRole: DeviceRole.table).isAllowed,
        isFalse,
      );
    });
  });

  group('PermissionService - Phone Role (User & Organizer)', () {
    test('casual match (tournamentId is null) can be recorded by any player', () {
      final res = permissionService.can(
        Capability.recordMatchResult,
        deviceRole: DeviceRole.phone,
        isTournamentMatch: false,
      );
      expect(res.isAllowed, isTrue);
    });

    test('tournament match requires organizer or participant', () {
      final resParticipant = permissionService.can(
        Capability.recordMatchResult,
        deviceRole: DeviceRole.phone,
        actorUserId: 'user-a',
        playerAId: 'user-a',
        playerBId: 'user-b',
        isTournamentMatch: true,
      );
      expect(resParticipant.isAllowed, isTrue);

      final resOrganizer = permissionService.can(
        Capability.recordMatchResult,
        deviceRole: DeviceRole.phone,
        actorUserId: 'organizer-1',
        tournamentOwnerId: 'organizer-1',
        playerAId: 'user-a',
        playerBId: 'user-b',
        isTournamentMatch: true,
      );
      expect(resOrganizer.isAllowed, isTrue);

      final resSpectator = permissionService.can(
        Capability.recordMatchResult,
        deviceRole: DeviceRole.phone,
        actorUserId: 'spectator-x',
        tournamentOwnerId: 'organizer-1',
        playerAId: 'user-a',
        playerBId: 'user-b',
        isTournamentMatch: true,
      );
      expect(resSpectator.isAllowed, isFalse);
    });

    test('arbitration conflict of interest rules (SISTEMA.md §6 & 2-organizador.html §10)', () {
      // Normal organizer resolving dispute for two other players
      final normalDispute = permissionService.can(
        Capability.resolveDispute,
        deviceRole: DeviceRole.phone,
        actorUserId: 'org-1',
        tournamentOwnerId: 'org-1',
        playerAId: 'p1',
        playerBId: 'p2',
      );
      expect(normalDispute.isAllowed, isTrue);
      expect(normalDispute.isSelfArbitration, isFalse);

      // Organizer is also Player A in a multi-organizer setting -> blocked
      final conflictBlocked = permissionService.can(
        Capability.resolveDispute,
        deviceRole: DeviceRole.phone,
        actorUserId: 'org-1',
        tournamentOwnerId: 'org-1',
        playerAId: 'org-1',
        playerBId: 'p2',
        isSoloOrganizer: false,
      );
      expect(conflictBlocked.isAllowed, isFalse);

      // Solo organizer with nobody else to judge -> allowed with self-arbitration flag
      final soloSelfArbitration = permissionService.can(
        Capability.resolveDispute,
        deviceRole: DeviceRole.phone,
        actorUserId: 'org-1',
        tournamentOwnerId: 'org-1',
        playerAId: 'org-1',
        playerBId: 'p2',
        isSoloOrganizer: true,
      );
      expect(soloSelfArbitration.isAllowed, isTrue);
      expect(soloSelfArbitration.isSelfArbitration, isTrue);
    });
  });

  group('PermissionService - WideWeb Role', () {
    test('is read-only: allows catalog and export, denies all mutations', () {
      expect(
        permissionService.can(Capability.viewCatalogAndDecks, deviceRole: DeviceRole.wideWeb).isAllowed,
        isTrue,
      );
      expect(
        permissionService.can(Capability.exportTournamentData, deviceRole: DeviceRole.wideWeb).isAllowed,
        isTrue,
      );
      expect(
        permissionService.can(Capability.recordMatchResult, deviceRole: DeviceRole.wideWeb).isAllowed,
        isFalse,
      );
      expect(
        permissionService.can(Capability.closeRound, deviceRole: DeviceRole.wideWeb).isAllowed,
        isFalse,
      );
    });
  });
}
