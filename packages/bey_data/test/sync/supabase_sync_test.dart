import 'package:bey_data/bey_data.dart';
import 'package:bey_domain/bey_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SupabaseSyncService Tests', () {
    late SupabaseSyncService syncService;

    setUp(() {
      syncService = SupabaseSyncService();
    });

    test('isAvailable returns false when not configured with valid url/key', () {
      expect(syncService.isAvailable, isFalse);
    });

    test('gracefully returns false on push operations when client unconfigured', () async {
      const combo = Combo(
        id: 'c-1',
        name: 'DranSword 3-60F',
        bladeId: 'b-1',
        ratchetId: 'r-1',
        bitId: 'bit-1',
        system: BeySystem.bx,
      );

      const deck = Deck(
        id: 'd-1',
        name: 'Deck Oficial',
        comboIds: ['c-1'],
      );

      final comboResult = await syncService.pushCombos([combo]);
      final deckResult = await syncService.pushDecks([deck]);
      final profileResult = await syncService.syncProfile(nickname: 'BladerX');
      final invResult = await syncService.pushUserInventory(['BX-01', 'B-P']);
      final spinResult = await syncService.pushSpinBenchmarks([
        SpinTestRecord(
          id: 'sp-1',
          comboName: 'WizardRod 9-60B',
          durationMs: 75000,
          launcherType: 'Winder',
          recordedAt: DateTime.now(),
        ),
      ]);
      final prefResult = await syncService.pushPreferences(announcerLanguage: 'spanish', handedness: 'RIGHT');
      final trophyResult = await syncService.pushTrophies([
        {
          'id': 'tr-1',
          'tournament_name': 'Copa 2026',
          'rank_position': 1,
        }
      ]);

      expect(comboResult, isFalse);
      expect(deckResult, isFalse);
      expect(profileResult, isFalse);
      expect(invResult, isFalse);
      expect(spinResult, isFalse);
      expect(prefResult, isFalse);
      expect(trophyResult, isFalse);
    });

    test('gracefully returns empty lists on pull operations when client unconfigured', () async {
      final inv = await syncService.pullUserInventory('user-1');
      final spins = await syncService.pullSpinBenchmarks('user-1');
      final prefs = await syncService.pullPreferences('user-1');
      final trophies = await syncService.pullTrophies('user-1');

      expect(inv, isEmpty);
      expect(spins, isEmpty);
      expect(prefs, isNull);
      expect(trophies, isEmpty);
    });
  });
}
