/// Data and persistence layer for BeyScore.
///
/// Contains Drift SQLite database, local datasources, outbox pattern,
/// Supabase sync engine, and repository implementations.
library;

export 'src/database/app_database.dart';
export 'src/datasources/battle_local_datasource.dart';
export 'src/datasources/combo_local_datasource.dart';
export 'src/datasources/deck_local_datasource.dart';
export 'src/datasources/identity_local_datasource.dart';
export 'src/datasources/parts_table.dart';
export 'src/datasources/tournament_local_datasource.dart';
export 'src/env/env.dart';
export 'src/repositories/battle_repository_impl.dart';
export 'src/repositories/combo_repository_impl.dart';
export 'src/repositories/deck_repository_impl.dart';
export 'src/repositories/identity_repository_impl.dart';
export 'src/repositories/tournament_repository_impl.dart';
export 'src/sync/conflict_resolver.dart';
export 'src/sync/connectivity_monitor.dart';
export 'src/sync/outbox_entry.dart';
export 'src/sync/supabase_sync_service.dart';
export 'src/sync/sync_engine.dart';
