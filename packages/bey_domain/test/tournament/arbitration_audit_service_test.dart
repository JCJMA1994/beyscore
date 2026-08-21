import 'package:bey_domain/bey_domain.dart';
import 'package:test/test.dart';

void main() {
  group('ArbitrationAuditService Tests', () {
    const service = ArbitrationAuditService();

    final now = DateTime.now();
    final ledger = OfficialTournamentLedger(
      tournamentName: 'Copa Nacional WBO 2026',
      tierLabel: 'G1 Championship',
      divisionLabel: 'Open Division',
      champion: 'Kento',
      runnerUp: 'Bird',
      thirdPlace: 'Ekusu',
      totalMatches: 28,
      totalParticipants: 32,
      auditLogs: [
        ArbitrationAuditLog(
          id: 'log-1',
          tournamentId: 't1',
          tableNumber: 2,
          judgeName: 'Juez Principal #1',
          actionType: 'VAR_REVIEW',
          description: 'Revisión en video de detención simultánea. Dictamen: Combate Nulo (Rematch)',
          timestamp: now.subtract(const Duration(minutes: 40)),
        ),
        ArbitrationAuditLog(
          id: 'log-2',
          tournamentId: 't1',
          tableNumber: 1,
          judgeName: 'Juez de Mesa #3',
          actionType: 'PENALTY',
          description: 'Lanzamiento antes de señal ("3-2-1"). Advertencia +1 pt otorgado al rival.',
          timestamp: now.subtract(const Duration(minutes: 15)),
        ),
      ],
      generatedAt: now,
    );

    test('generates complete official ledger markdown report with audit trail', () {
      final markdown = service.formatLedgerToMarkdown(ledger);

      expect(markdown, contains('# ACTA OFICIAL DE CLAUSURA DE TORNEO BEYSCORE'));
      expect(markdown, contains('COPA NACIONAL WBO 2026'));
      expect(markdown, contains('Kento'));
      expect(markdown, contains('VAR_REVIEW'));
      expect(markdown, contains('PENALTY'));
      expect(markdown, contains('Mesa 2'));
      expect(markdown, contains('Mesa 1'));
    });
  });
}
