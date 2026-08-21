import 'dart:convert';
import 'dart:io';

import 'package:bey_data/bey_data.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import 'catalog_seeder.dart';

class CatalogUpdateResult {
  const CatalogUpdateResult.upToDate(this.currentVersion)
      : applied = false,
        newVersion = null,
        error = null;
  const CatalogUpdateResult.applied(this.currentVersion, this.newVersion)
      : applied = true,
        error = null;
  const CatalogUpdateResult.failed(this.currentVersion, this.error)
      : applied = false,
        newVersion = null;

  final int currentVersion;
  final int? newVersion;
  final bool applied;
  final Object? error;
}

class CatalogUpdater {
  CatalogUpdater({
    required this.baseUrl,
    required AppDatabase db,
    http.Client? client,
  })  : _db = db,
        _client = client ?? http.Client();

  final String baseUrl;
  final AppDatabase _db;
  final http.Client _client;

  static const _timeout = Duration(seconds: 10);

  /// Call in background after runApp(). Never on the critical path.
  Future<CatalogUpdateResult> checkAndApply({
    required int localVersion,
  }) async {
    try {
      final manifest = await _fetchJson('$baseUrl/catalog/manifest.json');
      final latest = manifest['latestVersion'] as int;

      if (latest <= localVersion) {
        return CatalogUpdateResult.upToDate(localVersion);
      }

      final info =
          (manifest['files'] as Map)['$latest'] as Map<String, dynamic>;
      final url = '$baseUrl${info['url']}';
      final expected = info['sha256'] as String;

      final res = await _client.get(Uri.parse(url)).timeout(_timeout);
      if (res.statusCode != 200) {
        return CatalogUpdateResult.failed(
          localVersion,
          HttpException('HTTP ${res.statusCode}'),
        );
      }

      final actual = sha256.convert(res.bodyBytes).toString();
      if (actual != expected) {
        return CatalogUpdateResult.failed(
          localVersion,
          StateError('Hash mismatch'),
        );
      }

      final doc =
          json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      final parts = (doc['parts'] as List).cast<Map<String, dynamic>>();

      // Reject suspiciously short catalogs.
      if (parts.length < 50) {
        return CatalogUpdateResult.failed(
          localVersion,
          StateError('Catalog suspiciously short: ${parts.length} parts'),
        );
      }

      // Atomic replacement in one transaction.
      await _db.transaction(() async {
        await _db.delete(_db.parts).go();
        await _db.batch(
          (b) => b.insertAll(_db.parts, parts.map(CatalogSeeder.toCompanion).toList()),
        );
      });

      return CatalogUpdateResult.applied(localVersion, latest);
    } catch (e) {
      return CatalogUpdateResult.failed(localVersion, e);
    }
  }

  Future<Map<String, dynamic>> _fetchJson(String url) async {
    final res = await _client.get(Uri.parse(url)).timeout(_timeout);
    if (res.statusCode != 200) {
      throw HttpException('HTTP ${res.statusCode} at $url');
    }
    return json.decode(res.body) as Map<String, dynamic>;
  }
}
