# Cómo usar estos archivos

Guía de integración de `beyblade_x_parts.json` y los tres archivos Dart en un proyecto Flutter nuevo.

Tiempo estimado: **unos 40 minutos** hasta ver el catálogo en pantalla.

---

## Qué es cada archivo

| Archivo | Qué hace | Dónde va |
|---|---|---|
| `beyblade_x_parts.json` | 239 piezas + reglas oficiales v12 | `assets/data/` |
| `catalog_local_datasource.dart` | Tablas Drift + carga del JSON + consultas | `lib/features/catalog/data/datasources/` |
| `catalog_updater.dart` | Busca versiones nuevas en el CDN | `lib/features/catalog/data/` |
| `deck_validator.dart` | Valida decks 3on3 (regla de piezas no repetibles) | `lib/features/deck/domain/services/` |
| `cdn/` | Sitio estático para servir el catálogo | fuera del proyecto Flutter |

Los tres Dart son independientes entre sí. Puedes empezar solo con el datasource.

---

## Paso 1 — Crear el proyecto

```bash
flutter create beyscore
cd beyscore
```

## Paso 2 — Dependencias

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  drift: ^2.20.0
  drift_flutter: ^0.2.0
  path_provider: ^2.1.4
  fpdart: ^1.1.0        # Either, para deck_validator
  http: ^1.2.2          # solo para catalog_updater
  crypto: ^3.0.5        # verificación sha256

dev_dependencies:
  build_runner: ^2.4.13
  drift_dev: ^2.20.0

flutter:
  assets:
    - assets/data/
```

```bash
flutter pub get
```

## Paso 3 — Colocar los archivos

```bash
mkdir -p assets/data
mkdir -p lib/features/catalog/data/datasources
mkdir -p lib/features/deck/domain/services

cp beyblade_x_parts.json          assets/data/
cp catalog_local_datasource.dart  lib/features/catalog/data/datasources/
cp catalog_updater.dart           lib/features/catalog/data/
cp deck_validator.dart            lib/features/deck/domain/services/
```

## Paso 4 — Crear la base de datos

`catalog_local_datasource.dart` define la **tabla**, pero no la base. Crea esto:

```dart
// lib/core/database/app_database.dart
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import '../../features/catalog/data/datasources/catalog_local_datasource.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Parts])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'beyscore'));

  @override
  int get schemaVersion => 1;
}
```

## Paso 5 — Generar el código

```bash
dart run build_runner build --delete-conflicting-outputs
```

Esto crea `app_database.g.dart` con `PartsCompanion`, `PartRow` y todo lo tipado. **Sin este paso nada compila** — es normal ver errores rojos hasta que lo ejecutas.

Mientras iteras:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

## Paso 6 — Cargar el catálogo al arrancar

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/database/app_database.dart';
import 'features/catalog/data/datasources/catalog_local_datasource.dart';

late final AppDatabase db;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  db = AppDatabase();

  final prefs = await SharedPreferences.getInstance();
  final versionLocal = prefs.getInt('catalogVersion') ?? 0;

  // Instantáneo y sin red: el JSON viaja dentro del APK.
  await CatalogSeeder(db).seedIfNeeded(currentVersion: versionLocal);
  await prefs.setInt('catalogVersion', 5);

  runApp(const BeyScoreApp());
}
```

**Importante:** `seedIfNeeded` es idempotente. Puedes llamarlo en cada arranque sin coste: si la versión ya está cargada, sale enseguida.

## Paso 7 — Comprobar que funciona

```dart
final ds = CatalogLocalDataSource(db);

StreamBuilder<List<PartRow>>(
  stream: ds.watchByType(PartType.blade),
  builder: (context, snap) {
    if (!snap.hasData) return const CircularProgressIndicator();
    final blades = snap.data!;
    return ListView.builder(
      itemCount: blades.length,
      itemBuilder: (_, i) {
        final b = blades[i];
        return ListTile(
          title: Text(b.name),
          subtitle: Text('${b.weightG ?? "?"} g · ${b.productCode ?? ""}'),
        );
      },
    );
  },
)
```

Si ves 68 blades, ya está.

---

## Cómo está organizado el JSON

```jsonc
{
  "schemaVersion": 5,
  "counts": { "BLADE": 68, "RATCHET": 36, "BIT": 52, "TOTAL": 239 },

  "rules": {              // reglamento oficial v12 — léelo desde la app
    "pointsToWin": 4,
    "finishes": [ ... ],  // incluye PENALTY, que no es un finish
    "format3on3": { "noDuplicateParts": true, ... },
    "launch": { "faultsForPenalty": 2, ... },
    "eventTiers": [ ... ],
    "ageDivisions": [ ... ]
  },

  "meta": { "comboTiers": { "S": [...], "A": [...] } },

  "parts": [ ... ]        // las 239 entradas
}
```

### Ejemplo de una pieza

```jsonc
{
  "id": "bit-ball",
  "type": "BIT",
  "name": "Ball",
  "code": "B",                  // abreviatura para escribir combos: "DranSword 3-60B"
  "beyType": "stamina",         // ⚠️ NO se deduce del nombre — ver aviso abajo
  "tipShape": "round",
  "gearTeeth": 12,              // más dientes = Xtreme Dash más fuerte, menos stamina
  "shaftWidth": 78,
  "heightDmm": 124,             // décimas de mm: 124 = 12.4 mm
  "sets": ["BX-03", "BX-05", "BX-08"],
  "image": "https://img.beybladehub.app/bits/B.webp"
}
```

### Los campos que hay que entender

| Campo | Detalle |
|---|---|
| `heightDmm` | Décimas de milímetro. `60` = 6.0 mm. Divide entre 10 para mostrar. |
| `weightClass` | Notación del origen: `7-` ligero, `7=` medio, `7+` pesado. Es texto, no número. |
| `beyType` | `attack` · `defense` · `stamina` · `balance`. **Nunca lo calcules.** |
| `spinDirection` | `RIGHT` o `LEFT`. Solo 2 blades giran a la izquierda y exigen lanzador L. |
| `metaTier` | `S`, `A`, `B` o `null`. **`null` significa "sin datos", no "malo".** |
| `hasbroAlias` | Nombre occidental. `HellsScythe` → `Scythe Incendio`. Inclúyelo en la búsqueda. |
| `weightG` | Peso listado por el fabricante, no medido. Si el usuario pesa el suyo, ese gana. |

> **Aviso que te ahorra un bug.** El tipo de un bit **no** se puede deducir de su nombre. `Ball` es stamina, no defensa. `Point` y `Taper` son balance. `Needle` y `Wedge` son defensa. Deducirlo por nombre acierta el **32%** de las veces. Usa siempre `beyType` del JSON.

### Leer las reglas desde la app

No copies los puntos a constantes de Dart: si el reglamento cambia, actualizas el JSON y listo.

```dart
final rules = doc['rules'] as Map<String, dynamic>;
final meta = rules['pointsToWin'] as int;               // 4

final puntos = {
  for (final f in rules['finishes'] as List)
    f['code'] as String: f['points'] as int,
};
// {XTREME: 3, OVER: 2, BURST: 2, SPIN: 1, PENALTY: 1}
```

---

## Usar el validador de decks

Es una función pura: no necesita base de datos, red ni Flutter.

```dart
final validador = const DeckValidator();

final resultado = validador.validate(
  [bey1, bey2, bey3],
  isSingles: false,               // true en combate individual
  hallOfFamePartIds: {},          // piezas de salón de la fama del torneo
  ownsLeftLauncher: true,
);

resultado.fold(
  (violaciones) {
    for (final v in violaciones) {
      print(v.message);
      print('beys implicados: ${v.beyIndexes}');   // para resaltarlos en la UI
    }
  },
  (deckLegal) => guardarDeck(deckLegal),
);
```

### Construir un `BeyBuild` desde tus filas de Drift

```dart
BeyBuild desdeCombo(PartRow blade, PartRow ratchet, PartRow bit) {
  return BeyBuild(
    spinsLeft: blade.spinDirection == SpinDirection.left,
    parts: [blade, ratchet, bit].map((p) => PartRef(
      // ⚠️ el id del CATÁLOGO, no el id del ejemplar que posee el usuario
      identityKey: p.id,
      name: p.name,
      type: _mapKind(p.type),
    )).toList(),
  );
}
```

**Este es el punto donde es fácil equivocarse.** Si el usuario tiene dos DranSword de distinto color en su inventario, cada uno tendrá su propio id de inventario, pero **los dos comparten `identityKey`**. Si pasas el id de inventario, el validador no detectará la duplicación y el jugador se llevará la sorpresa en la mesa de chequeo.

### Probarlo

```dart
test('detecta el mismo blade en dos beys aunque sea otro color', () {
  final dran = PartRef(identityKey: 'blade-dransword', name: 'DranSword', type: PartKind.blade);
  // ...
  final r = const DeckValidator().validate([bey1, bey2, bey3],
      isSingles: false, hallOfFamePartIds: {}, ownsLeftLauncher: true);

  expect(r.isLeft(), true);
  r.fold((vs) {
    expect(vs.first.kind, DeckViolationKind.duplicatePart);
    expect(vs.first.beyIndexes, [0, 1]);
  }, (_) => fail('debía fallar'));
});
```

Sin mocks, sin `setUp`, sin async. Ese es el punto de tener la regla en el dominio.

---

## Actualizar el catálogo desde el CDN

Opcional. La app funciona sin esto.

### Publicar

```bash
cd cdn
vercel --prod
```

Quedan dos rutas:
- `/catalog/manifest.json` — 1.6 KB, caché 5 min
- `/catalog/v5.json` — 108 KB, caché **un año** (`immutable`)

### Conectarlo

```dart
// después de runApp(), nunca antes
unawaited(() async {
  final r = await CatalogUpdater(
    baseUrl: 'https://TU-PROYECTO.vercel.app',
    db: db,
  ).checkAndApply(localVersion: versionLocal);

  if (r.applied) {
    await prefs.setInt('catalogVersion', r.newVersion!);
    // Drift avisa a la UI por stream: no hace falta reiniciar
  }
}());
```

Corre **después** de `runApp`. La app arranca con su copia empaquetada; la actualización pasa en segundo plano. Un catálogo desactualizado es un inconveniente; una app que no abre es un fallo.

### Publicar una versión nueva

1. Genera `cdn/catalog/v6.json`
2. `shasum -a 256 cdn/catalog/v6.json`
3. Añade la entrada `"6"` en `manifest.json` con ese hash y sube `latestVersion` a 6
4. **No borres `v5.json`** — apps viejas lo siguen pidiendo
5. `vercel --prod`

Regla que sostiene el diseño: **una versión nunca cambia de contenido.** Por eso el hash sirve y el caché puede ser de un año.

---

## Imágenes

El JSON trae URLs remotas. Para que funcionen sin conexión, descárgalas una vez:

```bash
python scrape_details.py beyblade_x_parts.json --images assets/parts
```

Y añade a `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/data/
    - assets/parts/
```

En la UI, local primero y remoto como respaldo:

```dart
Image.asset(
  part.imageLocal ?? '',
  errorBuilder: (_, __, ___) => Image.network(
    part.imageRemote ?? '',
    errorBuilder: (_, __, ___) => const BeySilhouettePlaceholder(),
  ),
)
```

---

## Problemas comunes

**`PartsCompanion` no existe / errores rojos por todas partes**
Falta generar el código. `dart run build_runner build --delete-conflicting-outputs`.

**`Unable to load asset: assets/data/beyblade_x_parts.json`**
Revisa la indentación de `pubspec.yaml` (dos espacios, no tabs) y haz `flutter clean && flutter pub get`.

**El catálogo no se actualiza al cambiar el JSON**
`seedIfNeeded` solo escribe si `schemaVersion` del JSON es mayor que la guardada. Sube el número o borra los datos de la app.

**El validador no detecta duplicados**
Casi seguro estás pasando el id de inventario en `identityKey` en vez del id del catálogo. Ver arriba.

**`comboWeight` devuelve null**
Es correcto: alguna pieza no tiene peso publicado. Sumar ceros mostraría un número falso. Muestra "sin datos".

---

## Orden sugerido para construir

1. Catálogo en pantalla (pasos 1–7) — **ya tienes algo que se ve**
2. Armado de combos, todo local
3. `deck_validator` en el armado de decks
4. Marcador 1v1: un teléfono, dos jugadores. **Aquí ya es un producto usable.**
5. Estadísticas
6. Marcador 3on3 con alineación
7. Torneos: sorteo, cuadro, mesas
8. Confirmación entre dispositivos, Outbox y backend

Cada paso es una app que sirve por sí sola. Si el proyecto se detiene en el 4, igual tienes algo que la gente usa.

---

## Atribución

Datos recopilados de [beybladehub.app](https://beybladehub.app), [beybxdb.com](https://www.beybxdb.com), [beyxhub.org](https://beyxhub.org) y la [Beyblade Wiki](https://beyblade.fandom.com) (CC-BY-SA). Reglamento oficial v12 (marzo 2026).

BEYBLADE X es marca de Takara Tomy / Hasbro. Estos datos son factuales y de uso no comercial. Incluye una pantalla "Acerca de" con estos créditos.
