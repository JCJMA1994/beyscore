// features/catalog/data/catalog_updater.dart
//
// Revisa si hay una version mas nueva del catalogo y la aplica.
// NUNCA bloquea el arranque: si falla cualquier cosa, la app sigue con la
// copia que trae empaquetada. Un catalogo desactualizado es un inconveniente;
// una app que no abre es un fallo.

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;

class CatalogUpdateResult {
  const CatalogUpdateResult.upToDate(this.currentVersion)
      : applied = false, newVersion = null, error = null;
  const CatalogUpdateResult.applied(this.currentVersion, this.newVersion)
      : applied = true, error = null;
  const CatalogUpdateResult.failed(this.currentVersion, this.error)
      : applied = false, newVersion = null;

  final int currentVersion;
  final int? newVersion;
  final bool applied;
  final Object? error;
}

class CatalogUpdater {
  CatalogUpdater({
    required this.baseUrl,
    required GeneratedDatabase db,
    http.Client? client,
  })  : _db = db,
        _client = client ?? http.Client();

  /// Ej: https://beyscore-catalog.vercel.app
  final String baseUrl;
  final GeneratedDatabase _db;
  final http.Client _client;

  static const _timeout = Duration(seconds: 10);

  /// Llamar en segundo plano tras el arranque. Nunca en el camino critico.
  Future<CatalogUpdateResult> checkAndApply({required int localVersion}) async {
    try {
      // 1. El manifest son ~2 KB. Barato de pedir incluso en 3G.
      final manifest = await _fetchJson('$baseUrl/catalog/manifest.json');
      final latest = manifest['latestVersion'] as int;

      if (latest <= localVersion) {
        return CatalogUpdateResult.upToDate(localVersion);
      }

      // 2. Si el servidor exige una version minima mayor que la nuestra,
      //    el salto no es seguro: hace falta actualizar la app, no los datos.
      final minSupported = manifest['minSupportedVersion'] as int? ?? 0;
      if (minSupported > latest) {
        return CatalogUpdateResult.failed(
            localVersion, StateError('manifest inconsistente'));
      }

      final info = (manifest['files'] as Map)['$latest'] as Map<String, dynamic>;
      final url = '$baseUrl${info['url']}';
      final esperado = info['sha256'] as String;

      // 3. Descargar y verificar ANTES de tocar la base de datos.
      final res = await _client.get(Uri.parse(url)).timeout(_timeout);
      if (res.statusCode != 200) {
        return CatalogUpdateResult.failed(
            localVersion, HttpException('HTTP ${res.statusCode}'));
      }

      final real = sha256.convert(res.bodyBytes).toString();
      if (real != esperado) {
        // Descarga corrupta o manipulada. Nos quedamos con lo que ya tenemos.
        return CatalogUpdateResult.failed(
            localVersion, StateError('el hash no coincide'));
      }

      final doc = json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      final piezas = (doc['parts'] as List).cast<Map<String, dynamic>>();

      // Un catalogo vacio o absurdamente corto es señal de que algo salio mal
      // en el origen. Mejor no aplicarlo que dejar al usuario sin piezas.
      if (piezas.length < 50) {
        return CatalogUpdateResult.failed(
            localVersion, StateError('catalogo sospechosamente corto'));
      }

      // 4. Reemplazo en UNA transaccion. O entra entero, o no entra nada:
      //    nunca un estado a medias donde faltan bits pero sobran blades.
      await _db.transaction(() async {
        final t = _db.parts as TableInfo;
        await _db.delete(t).go();
        await _db.batch((b) => b.insertAll(
              t,
              piezas.map(CatalogSeeder.toCompanion).toList(),
            ));
      });

      return CatalogUpdateResult.applied(localVersion, latest);
    } catch (e) {
      // Sin red, DNS caido, timeout, JSON invalido: da igual. La app sigue.
      return CatalogUpdateResult.failed(localVersion, e);
    }
  }

  Future<Map<String, dynamic>> _fetchJson(String url) async {
    final res = await _client.get(Uri.parse(url)).timeout(_timeout);
    if (res.statusCode != 200) {
      throw HttpException('HTTP ${res.statusCode} en $url');
    }
    return json.decode(res.body) as Map<String, dynamic>;
  }
}

// ---------------------------------------------------------------- uso

// bootstrap.dart
//
// Future<void> bootstrap() async {
//   final db = AppDatabase();
//
//   // 1. SIEMPRE primero: la copia empaquetada. Instantanea, sin red.
//   await CatalogSeeder(db).seedIfNeeded(currentVersion: prefs.catalogVersion);
//
//   runApp(const BeyScoreApp());   // <- la app ya arranco
//
//   // 2. Despues, sin bloquear nada, buscar si hay algo mas nuevo.
//   unawaited(() async {
//     final r = await CatalogUpdater(
//       baseUrl: Env.catalogBaseUrl,
//       db: db,
//     ).checkAndApply(localVersion: prefs.catalogVersion);
//
//     if (r.applied) {
//       await prefs.setCatalogVersion(r.newVersion!);
//       // Drift avisa a la UI por stream: no hace falta reiniciar.
//     }
//   }());
// }
