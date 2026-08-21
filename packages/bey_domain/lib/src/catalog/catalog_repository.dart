import 'part.dart';
import 'part_type.dart';

/// Abstract catalog repository.
///
/// No use cases for catalog (CLAUDE.md section 5): the BLoC calls
/// the repository directly.
abstract class CatalogRepository {
  /// Reactive stream of parts filtered by type.
  Stream<List<Part>> watchByType(PartType type);

  /// Search by name, bit code, product code, or Hasbro alias.
  Stream<List<Part>> search(String query, {PartType? type});

  /// Seed the local database from the bundled JSON.
  Future<void> seedIfNeeded({required int currentVersion});
}
