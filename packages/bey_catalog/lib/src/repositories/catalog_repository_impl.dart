import 'package:bey_domain/bey_domain.dart';

import '../datasources/catalog_local_datasource.dart';
import '../datasources/catalog_seeder.dart';

/// Catalog repository implementation.
///
/// Reads from Drift (source of truth). No use cases layer for catalog.
class CatalogRepositoryImpl implements CatalogRepository {
  CatalogRepositoryImpl({
    required CatalogLocalDataSource localDataSource,
    CatalogSeeder? seeder,
  })  : _local = localDataSource,
        _seeder = seeder;

  final CatalogLocalDataSource _local;
  final CatalogSeeder? _seeder;

  @override
  Stream<List<Part>> watchByType(PartType type) {
    return _local.watchByType(type).map(
          (rows) => rows.map(CatalogLocalDataSource.toEntity).toList(),
        );
  }

  @override
  Stream<List<Part>> search(String query, {PartType? type}) {
    return _local.search(query, type: type).map(
          (rows) => rows.map(CatalogLocalDataSource.toEntity).toList(),
        );
  }

  @override
  Future<void> seedIfNeeded({required int currentVersion}) async {
    final seeder = _seeder;
    if (seeder != null) {
      await seeder.seedIfNeeded(currentVersion: currentVersion);
    }
  }
}
