import 'package:bey_domain/bey_domain.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../datasources/battle_local_datasource.dart';
import '../datasources/combo_local_datasource.dart';
import '../datasources/deck_local_datasource.dart';
import '../datasources/parts_table.dart';
import '../datasources/tournament_local_datasource.dart';

export '../datasources/battle_local_datasource.dart' show MatchesTable;
export '../datasources/combo_local_datasource.dart' show Combos;
export '../datasources/deck_local_datasource.dart' show Decks;
export '../datasources/parts_table.dart' show Parts;
export '../datasources/tournament_local_datasource.dart' show TournamentsTable;

part 'app_database.g.dart';

/// Central Drift database.
///
/// Imports table definitions from each feature's data layer.
/// Run `dart run build_runner build --delete-conflicting-outputs` after
/// any change to tables.
@DriftDatabase(tables: [Parts, Combos, Decks, MatchesTable, TournamentsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'beyscore'));

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(combos);
            await m.createTable(decks);
          }
          if (from < 3) {
            await m.createTable(matchesTable);
          }
          if (from < 4) {
            await m.createTable(tournamentsTable);
          }
        },
      );
}
