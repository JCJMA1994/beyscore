/// A single logged arbitration event during tournament proceedings.
class ArbitrationAuditLog {
  const ArbitrationAuditLog({
    required this.id,
    required this.tournamentId,
    required this.tableNumber,
    required this.judgeName,
    required this.actionType, // 'PENALTY', 'VAR_REVIEW', 'INSTANT_LOSS', 'DISPUTE_RESOLUTION'
    required this.description,
    required this.timestamp,
  });

  final String id;
  final String tournamentId;
  final int tableNumber;
  final String judgeName;
  final String actionType;
  final String description;
  final DateTime timestamp;
}

/// Official tournament closing document with standings and arbitration audit trail.
class OfficialTournamentLedger {
  const OfficialTournamentLedger({
    required this.tournamentName,
    required this.tierLabel,
    required this.divisionLabel,
    required this.champion,
    this.runnerUp,
    this.thirdPlace,
    required this.totalMatches,
    required this.totalParticipants,
    required this.auditLogs,
    required this.generatedAt,
  });

  final String tournamentName;
  final String tierLabel;
  final String divisionLabel;
  final String champion;
  final String? runnerUp;
  final String? thirdPlace;
  final int totalMatches;
  final int totalParticipants;
  final List<ArbitrationAuditLog> auditLogs;
  final DateTime generatedAt;
}

/// Domain service that formats official immutable tournament closing ledgers.
class ArbitrationAuditService {
  const ArbitrationAuditService();

  String formatLedgerToMarkdown(OfficialTournamentLedger ledger) {
    final buffer = StringBuffer()
      ..writeln('# ACTA OFICIAL DE CLAUSURA DE TORNEO BEYSCORE')
      ..writeln('**Torneo:** ${ledger.tournamentName.toUpperCase()}')
      ..writeln('**Nivel Oficial:** ${ledger.tierLabel} · **División:** ${ledger.divisionLabel}')
      ..writeln('**Fecha de Emisión:** ${ledger.generatedAt.toIso8601String()}')
      ..writeln('**Participantes Totales:** ${ledger.totalParticipants} · **Combates Disputados:** ${ledger.totalMatches}')
      ..writeln('')
      ..writeln('---')
      ..writeln('## 🏆 CUADRO DE HONOR Y PODIO OFICIAL')
      ..writeln('1. 🥇 **CAMPEÓN (ORO):** ${ledger.champion}')
      ..writeln('2. 🥈 **SUBCAMPEÓN (PLATA):** ${ledger.runnerUp ?? "N/A"}')
      ..writeln('3. 🥉 **TERCER LUGAR (BRONCE):** ${ledger.thirdPlace ?? "N/A"}')
      ..writeln('')
      ..writeln('---')
      ..writeln('## ⚖️ REGISTRO DE AUDITORÍA ARBITRAL');

    if (ledger.auditLogs.isEmpty) {
      buffer.writeln('_No se registraron incidentes ni disputas arbitrales durante el torneo. Torneo 100% limpio._');
    } else {
      buffer
        ..writeln('| Hora | Mesa | Tipo de Acción | Juez / Árbitro | Dictamen / Motivo |')
        ..writeln('| :--- | :---: | :--- | :--- | :--- |');
      for (final log in ledger.auditLogs) {
        final timeStr = log.timestamp.toIso8601String().split('T').last.substring(0, 8);
        buffer.writeln('| $timeStr | Mesa ${log.tableNumber} | `${log.actionType}` | ${log.judgeName} | ${log.description} |');
      }
    }

    buffer
      ..writeln('')
      ..writeln('---')
      ..writeln('_Documento oficial emitido conforme a las Reglas Oficiales Takara Tomy / WBO v12._');

    return buffer.toString();
  }
}
