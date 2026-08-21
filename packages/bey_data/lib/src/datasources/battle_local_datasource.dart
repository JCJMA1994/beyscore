import 'dart:convert';
import 'package:bey_domain/bey_domain.dart';
import 'package:drift/drift.dart';

import '../database/app_database.dart';

@DataClassName('MatchRow')
class MatchesTable extends Table {
  TextColumn get id => text()();
  TextColumn get playerAId => text()();
  TextColumn get playerBId => text()();
  TextColumn get tournamentId => text().nullable()();
  IntColumn get targetPoints => integer().withDefault(const Constant(4))();
  IntColumn get format => intEnum<MatchFormat>().withDefault(const Constant(0))();
  IntColumn get status => intEnum<MatchStatus>().withDefault(const Constant(0))();
  TextColumn get finishesJson => text().withDefault(const Constant('[]'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class BattleLocalDataSource {
  BattleLocalDataSource(this._db);
  final AppDatabase _db;

  Stream<List<Match>> watchAllMatches() {
    return (_db.select(_db.matchesTable)
          ..orderBy([
            (r) => OrderingTerm(
                  expression: r.updatedAt,
                  mode: OrderingMode.desc,
                ),
          ]))
        .watch()
        .map((rows) => rows.map(toEntity).toList());
  }

  Future<List<Match>> getMatchHistory() async {
    final rows = await (_db.select(_db.matchesTable)
          ..orderBy([
            (r) => OrderingTerm(
                  expression: r.updatedAt,
                  mode: OrderingMode.desc,
                ),
          ]))
        .get();
    return rows.map(toEntity).toList();
  }

  Future<Match?> getMatchById(String id) async {
    final row = await (_db.select(_db.matchesTable)..where((r) => r.id.equals(id)))
        .getSingleOrNull();
    return row != null ? toEntity(row) : null;
  }

  Future<void> insertOrUpdateMatch(Match match) {
    return _db.into(_db.matchesTable).insertOnConflictUpdate(toCompanion(match));
  }

  Future<void> deleteMatch(String id) {
    return (_db.delete(_db.matchesTable)..where((r) => r.id.equals(id))).go();
  }

  static Match toEntity(MatchRow row) {
    final finishesRaw = jsonDecode(row.finishesJson) as List<dynamic>? ?? [];
    final finishes = finishesRaw.map((f) {
      final map = f as Map<String, dynamic>;
      return BattleFinish(
        id: map['id'] as String,
        matchId: map['matchId'] as String,
        roundIndex: map['roundIndex'] as int,
        sequence: map['sequence'] as int,
        type: FinishType.values.firstWhere(
          (e) => e.name == map['type'],
          orElse: () => FinishType.spin,
        ),
        scoringPlayerId: map['scoringPlayerId'] as String,
        isPenalty: map['isPenalty'] as bool? ?? false,
        voidedTargetId: map['voidedTargetId'] as String?,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
    }).toList();

    return Match(
      id: row.id,
      playerAId: row.playerAId,
      playerBId: row.playerBId,
      tournamentId: row.tournamentId,
      format: row.format,
      status: row.status,
      rules: MatchRules(targetPoints: row.targetPoints),
      finishes: finishes,
      createdAt: row.createdAt,
    );
  }

  static MatchesTableCompanion toCompanion(Match match) {
    final finishesJson = jsonEncode(match.finishes.map((f) => {
      'id': f.id,
      'matchId': f.matchId,
      'roundIndex': f.roundIndex,
      'sequence': f.sequence,
      'type': f.type.name,
      'scoringPlayerId': f.scoringPlayerId,
      'isVoid': f.isVoid,
      'voidedTargetId': f.voidedTargetId,
      'createdAt': f.createdAt.toIso8601String(),
    }).toList());

    return MatchesTableCompanion.insert(
      id: match.id,
      playerAId: match.playerAId,
      playerBId: match.playerBId,
      tournamentId: Value(match.tournamentId),
      targetPoints: Value(match.rules.targetPoints),
      format: Value(match.format),
      status: Value(match.status),
      finishesJson: Value(finishesJson),
      createdAt: match.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
