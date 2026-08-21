import 'dart:convert';
import 'package:bey_domain/bey_domain.dart';
import 'package:drift/drift.dart';

import '../database/app_database.dart';

@DataClassName('TournamentRow')
class TournamentsTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get organizerIdsJson => text().withDefault(const Constant('[]'))();
  IntColumn get tier => intEnum<TournamentTier>().withDefault(const Constant(0))();
  IntColumn get ageDivision => intEnum<AgeDivision>().withDefault(const Constant(0))();
  IntColumn get status => intEnum<TournamentStatus>().withDefault(const Constant(0))();
  TextColumn get participantsJson => text().withDefault(const Constant('[]'))();
  TextColumn get roundsJson => text().withDefault(const Constant('[]'))();
  TextColumn get championName => text().nullable()();
  IntColumn get seed => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class TournamentLocalDataSource {
  TournamentLocalDataSource(this._db);
  final AppDatabase _db;

  Stream<List<Tournament>> watchTournaments() {
    return (_db.select(_db.tournamentsTable)
          ..orderBy([
            (r) => OrderingTerm(
                  expression: r.createdAt,
                  mode: OrderingMode.desc,
                ),
          ]))
        .watch()
        .map((rows) => rows.map(toEntity).toList());
  }

  Future<List<Tournament>> getTournaments() async {
    final rows = await (_db.select(_db.tournamentsTable)
          ..orderBy([
            (r) => OrderingTerm(
                  expression: r.createdAt,
                  mode: OrderingMode.desc,
                ),
          ]))
        .get();
    return rows.map(toEntity).toList();
  }

  Future<Tournament?> getTournamentById(String id) async {
    final row = await (_db.select(_db.tournamentsTable)..where((r) => r.id.equals(id)))
        .getSingleOrNull();
    return row != null ? toEntity(row) : null;
  }

  Stream<Tournament> watchTournamentById(String id) {
    return (_db.select(_db.tournamentsTable)..where((r) => r.id.equals(id)))
        .watchSingle()
        .map(toEntity);
  }

  Future<void> saveTournament(Tournament tournament) {
    return _db.into(_db.tournamentsTable).insertOnConflictUpdate(toCompanion(tournament));
  }

  Future<void> deleteTournament(String id) {
    return (_db.delete(_db.tournamentsTable)..where((r) => r.id.equals(id))).go();
  }

  static Tournament toEntity(TournamentRow row) {
    final rawOrganizerIds = jsonDecode(row.organizerIdsJson) as List<dynamic>;
    final rawParticipants = jsonDecode(row.participantsJson) as List<dynamic>;
    final rawRounds = jsonDecode(row.roundsJson) as List<dynamic>;

    final rounds = rawRounds.map((r) {
      final rMap = r as Map<String, dynamic>;
      final rawMatchups = (rMap['matchups'] as List<dynamic>?) ?? [];
      final matchups = rawMatchups.map((m) {
        final mMap = m as Map<String, dynamic>;
        return Matchup(
          matchId: mMap['matchId'] as String? ?? '',
          playerAId: mMap['playerAId'] as String? ?? '',
          playerAName: mMap['playerAName'] as String? ?? '',
          playerBId: mMap['playerBId'] as String?,
          playerBName: mMap['playerBName'] as String?,
          tableNumber: mMap['tableNumber'] as int?,
          winnerId: mMap['winnerId'] as String?,
          scoreA: mMap['scoreA'] as int? ?? 0,
          scoreB: mMap['scoreB'] as int? ?? 0,
          isCompleted: mMap['isCompleted'] as bool? ?? false,
        );
      }).toList();

      return BracketRound(
        roundIndex: rMap['roundIndex'] as int? ?? 0,
        name: rMap['name'] as String? ?? '',
        matchups: matchups,
      );
    }).toList();

    return Tournament(
      id: row.id,
      name: row.name,
      organizerIds: rawOrganizerIds.map((e) => e.toString()).toList(),
      tier: row.tier,
      ageDivision: row.ageDivision,
      status: row.status,
      participants: rawParticipants.map((e) => e.toString()).toList(),
      rounds: rounds,
      championName: row.championName,
      seed: row.seed,
      createdAt: row.createdAt,
    );
  }

  static TournamentsTableCompanion toCompanion(Tournament tournament) {
    final roundsList = tournament.rounds.map((r) {
      return {
        'roundIndex': r.roundIndex,
        'name': r.name,
        'matchups': r.matchups.map((m) {
          return {
            'matchId': m.matchId,
            'playerAId': m.playerAId,
            'playerAName': m.playerAName,
            'playerBId': m.playerBId,
            'playerBName': m.playerBName,
            'tableNumber': m.tableNumber,
            'winnerId': m.winnerId,
            'scoreA': m.scoreA,
            'scoreB': m.scoreB,
            'isCompleted': m.isCompleted,
          };
        }).toList(),
      };
    }).toList();

    return TournamentsTableCompanion(
      id: Value(tournament.id),
      name: Value(tournament.name),
      organizerIdsJson: Value(jsonEncode(tournament.organizerIds)),
      tier: Value(tournament.tier),
      ageDivision: Value(tournament.ageDivision),
      status: Value(tournament.status),
      participantsJson: Value(jsonEncode(tournament.participants)),
      roundsJson: Value(jsonEncode(roundsList)),
      championName: Value(tournament.championName),
      seed: Value(tournament.seed),
      createdAt: Value(tournament.createdAt ?? DateTime.now()),
    );
  }
}
