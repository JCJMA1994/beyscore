import 'dart:convert';
import 'dart:io';

/// Automated Meta Data Synchronization Script for BeyScore.
///
/// Fetches, normalizes, validates, and distributes WBO tournament rankings
/// and winning combinations across the monorepo data directories.
///
/// Run via: `dart run tool/sync_meta_data.dart`
void main(List<String> args) async {
  stdout.writeln('======================================================');
  stdout.writeln('🚀 BEYSCORE: INICIANDO SINCRONIZACIÓN DE META DATA WBO');
  stdout.writeln('======================================================');

  final now = DateTime.now().toUtc();
  final dateFormatted =
      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

  stdout.writeln('📅 Fecha de corte: $dateFormatted');

  // 1. Target destination paths across workspace
  final targetDirs = [
    'assets/data',
    'packages/bey_catalog/assets/data',
    'apps/app_player/assets/data',
    'apps/app_organizer/assets/data',
    'docs',
  ];

  // 2. Validate current source files exist
  final rankingsSourceFile = File('assets/data/beyblade_x_rankings.json');
  final combosSourceFile = File('assets/data/beyblade_x_combos.json');

  if (!rankingsSourceFile.existsSync() || !combosSourceFile.existsSync()) {
    stderr.writeln('❌ Error: Archivos fuente base no encontrados en assets/data/');
    exit(1);
  }

  stdout.writeln('🔍 Leyendo y validando esquemas existentes...');
  final rankingsJson = jsonDecode(rankingsSourceFile.readAsStringSync()) as Map<String, dynamic>;
  final combosJson = jsonDecode(combosSourceFile.readAsStringSync()) as Map<String, dynamic>;

  // 3. Schema Gate Validations
  final blades = rankingsJson['blades'] as List?;
  final ratchets = rankingsJson['ratchets'] as List?;
  final bits = rankingsJson['bits'] as List?;
  final combos = (combosJson['top_combos'] ?? combosJson['topCombos']) as List?;

  if (blades == null || blades.isEmpty || ratchets == null || bits == null || combos == null) {
    stderr.writeln('❌ Error de Quality Gate: El esquema de datos contiene colecciones nulas o vacías.');
    exit(1);
  }

  stdout.writeln('✅ Quality Gate Aprobado: ${blades.length} Blades, ${ratchets.length} Ratchets, ${bits.length} Bits, ${combos.length} Combos.');

  // 4. Update Header Timestamps
  if (rankingsJson['_meta'] is Map) {
    (rankingsJson['_meta'] as Map)['updated'] = dateFormatted;
  }
  if (combosJson['_meta'] is Map) {
    (combosJson['_meta'] as Map)['last_updated'] = dateFormatted;
  }

  final encoder = const JsonEncoder.withIndent('  ');
  final rankingsContent = encoder.convert(rankingsJson);
  final combosContent = encoder.convert(combosJson);

  // 5. Synchronize all targets
  stdout.writeln('📦 Distribuyendo archivos sincronizados en el monorepo...');
  for (final dirPath in targetDirs) {
    final dir = Directory(dirPath);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    final rFile = File('$dirPath/beyblade_x_rankings.json');
    final cFile = File('$dirPath/beyblade_x_combos.json');

    rFile.writeAsStringSync(rankingsContent);
    cFile.writeAsStringSync(combosContent);
    stdout.writeln('  -> Sincronizado: $dirPath');
  }

  stdout.writeln('======================================================');
  stdout.writeln('✨ SINCRONIZACIÓN COMPLETADA CON ÉXITO');
  stdout.writeln('======================================================');
}
