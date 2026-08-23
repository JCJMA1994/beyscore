import 'package:bey_catalog/bey_catalog.dart';
import 'package:bey_data/bey_data.dart';
import 'package:bey_domain/bey_domain.dart';
import 'package:bey_hub/bey_hub.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies({AppDatabase? database}) async {
  final db = database ?? AppDatabase();

  if (!getIt.isRegistered<AppDatabase>()) {
    getIt.registerLazySingleton<AppDatabase>(() => db);
  }
  if (!getIt.isRegistered<ConnectivityMonitor>()) {
    getIt.registerLazySingleton<ConnectivityMonitor>(ConnectivityMonitor.new);
  }
  if (!getIt.isRegistered<SupabaseSyncService>()) {
    getIt.registerLazySingleton<SupabaseSyncService>(SupabaseSyncService.new);
  }
  if (!getIt.isRegistered<IdentityService>()) {
    getIt.registerLazySingleton<IdentityService>(IdentityService.new);
  }
  if (!getIt.isRegistered<IdentityLocalDataSource>()) {
    getIt.registerLazySingleton<IdentityLocalDataSource>(IdentityLocalDataSourceImpl.new);
  }
  if (!getIt.isRegistered<IdentityRepository>()) {
    getIt.registerLazySingleton<IdentityRepository>(
      () => IdentityRepositoryImpl(
        localDataSource: getIt<IdentityLocalDataSource>(),
        identityService: getIt<IdentityService>(),
        syncService: getIt<SupabaseSyncService>(),
        comboLocalDataSource: getIt<ComboLocalDataSource>(),
        deckLocalDataSource: getIt<DeckLocalDataSource>(),
        tournamentLocalDataSource: getIt<TournamentLocalDataSource>(),
      ),
    );
  }
  if (!getIt.isRegistered<PermissionService>()) {
    getIt.registerLazySingleton<PermissionService>(PermissionService.new);
  }
  if (!getIt.isRegistered<CatalogLocalDataSource>()) {
    getIt.registerLazySingleton<CatalogLocalDataSource>(() => CatalogLocalDataSource(getIt<AppDatabase>()));
  }
  if (!getIt.isRegistered<CatalogRepository>()) {
    getIt.registerLazySingleton<CatalogRepository>(
      () => CatalogRepositoryImpl(localDataSource: getIt<CatalogLocalDataSource>()),
    );
  }
  if (!getIt.isRegistered<ComboLocalDataSource>()) {
    getIt.registerLazySingleton<ComboLocalDataSource>(
      () => ComboLocalDataSource(getIt<AppDatabase>()),
    );
  }
  if (!getIt.isRegistered<DeckLocalDataSource>()) {
    getIt.registerLazySingleton<DeckLocalDataSource>(
      () => DeckLocalDataSource(getIt<AppDatabase>()),
    );
  }
  if (!getIt.isRegistered<ComboRepository>()) {
    getIt.registerLazySingleton<ComboRepository>(
      () => ComboRepositoryImpl(
        getIt<ComboLocalDataSource>(),
        getIt<SupabaseSyncService>(),
        getIt<IdentityLocalDataSource>(),
      ),
    );
  }
  if (!getIt.isRegistered<DeckRepository>()) {
    getIt.registerLazySingleton<DeckRepository>(
      () => DeckRepositoryImpl(
        getIt<DeckLocalDataSource>(),
        getIt<SupabaseSyncService>(),
        getIt<IdentityLocalDataSource>(),
      ),
    );
  }
  if (!getIt.isRegistered<BattleLocalDataSource>()) {
    getIt.registerLazySingleton<BattleLocalDataSource>(
      () => BattleLocalDataSource(getIt<AppDatabase>()),
    );
  }
  if (!getIt.isRegistered<BattleRepository>()) {
    getIt.registerLazySingleton<BattleRepository>(
      () => BattleRepositoryImpl(getIt<BattleLocalDataSource>()),
    );
  }
  if (!getIt.isRegistered<TournamentLocalDataSource>()) {
    getIt.registerLazySingleton<TournamentLocalDataSource>(
      () => TournamentLocalDataSource(getIt<AppDatabase>()),
    );
  }
  if (!getIt.isRegistered<TournamentRepository>()) {
    getIt.registerLazySingleton<TournamentRepository>(
      () => TournamentRepositoryImpl(
        getIt<TournamentLocalDataSource>(),
        getIt<SupabaseSyncService>(),
      ),
    );
  }
  if (!getIt.isRegistered<BracketGenerator>()) {
    getIt.registerLazySingleton<BracketGenerator>(BracketGenerator.new);
  }
  if (!getIt.isRegistered<LanHubServer>()) {
    getIt.registerLazySingleton<LanHubServer>(LanHubServer.new);
  }
  if (!getIt.isRegistered<ScoringService>()) {
    getIt.registerLazySingleton<ScoringService>(ScoringService.new);
  }
  if (!getIt.isRegistered<DeckValidator>()) {
    getIt.registerLazySingleton<DeckValidator>(DeckValidator.new);
  }
  if (!getIt.isRegistered<ComboStatsCalculator>()) {
    getIt.registerLazySingleton<ComboStatsCalculator>(ComboStatsCalculator.new);
  }
  if (!getIt.isRegistered<MetaAdvisorService>()) {
    getIt.registerLazySingleton<MetaAdvisorService>(MetaAdvisorService.new);
  }
  if (!getIt.isRegistered<BuildabilityService>()) {
    getIt.registerLazySingleton<BuildabilityService>(BuildabilityService.new);
  }
  if (!getIt.isRegistered<StartMatch>()) {
    getIt.registerLazySingleton<StartMatch>(
      () => StartMatch(repository: getIt<BattleRepository>()),
    );
  }
  if (!getIt.isRegistered<RegisterFinish>()) {
    getIt.registerLazySingleton<RegisterFinish>(
      () => RegisterFinish(
        repository: getIt<BattleRepository>(),
        scoringService: getIt<ScoringService>(),
      ),
    );
  }
  if (!getIt.isRegistered<UndoLastFinish>()) {
    getIt.registerLazySingleton<UndoLastFinish>(
      () => UndoLastFinish(repository: getIt<BattleRepository>()),
    );
  }
  if (!getIt.isRegistered<WatchMatch>()) {
    getIt.registerLazySingleton<WatchMatch>(
      () => WatchMatch(repository: getIt<BattleRepository>()),
    );
  }
  if (!getIt.isRegistered<SyncEngine>()) {
    getIt.registerLazySingleton<SyncEngine>(
      () => SyncEngine(
        connectivity: getIt<ConnectivityMonitor>(),
        supabaseSync: getIt<SupabaseSyncService>(),
        comboDataSource: getIt<ComboLocalDataSource>(),
        deckDataSource: getIt<DeckLocalDataSource>(),
        identityDataSource: getIt<IdentityLocalDataSource>(),
        tournamentDataSource: getIt<TournamentLocalDataSource>(),
      ),
    );
  }
}
