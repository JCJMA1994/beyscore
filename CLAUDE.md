# CLAUDE.md

Contexto del proyecto **BeyScore**. Léelo entero antes de tocar código.

---

## 1. Qué es esto

App móvil Flutter para llevar el marcador de combates **físicos** de Beyblade X y gestionar torneos. Los beys giran en una mesa real; la app solo registra lo que pasa.

**Quién la usa:** chavales y organizadores en torneos locales. De pie, con una mano, en un salón ruidoso, **normalmente sin wifi**.

**Tres modos:** combate rápido 1v1 · torneos 3on3 con sorteo y cuadro · estadísticas por jugador.

**Idioma:** UI y comentarios en **español**. Identificadores de código en **inglés**. Sin tildes en comentarios de código (evita problemas de encoding en generadores).

---

## 2. Stack y comandos

```
Flutter · Clean Architecture · BLoC + RxDart · Drift (SQLite) · offline-first
```

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # OBLIGATORIO tras tocar tablas Drift
dart run build_runner watch --delete-conflicting-outputs   # mientras iteras
flutter test
flutter analyze
```

Dependencias clave: `flutter_bloc`, `rxdart`, `drift` + `drift_flutter`, `get_it` + `injectable`, `fpdart` (Either), `go_router`, `connectivity_plus`, `http`, `crypto`.

---

## 3. Las cinco decisiones que mandan

| # | Decisión | Implicación |
|---|---|---|
| 1 | La unidad de dominio es el **`BattleFinish`**, no el marcador | Los puntos son **derivados**. Nunca guardes un marcador editable. |
| 2 | Offline-first **real** | Drift es la fuente de verdad para leer. La red nunca está en el camino crítico de la UI. |
| 3 | Escrituras vía **Outbox + UUID v7 generado en el cliente** | Sin spinners de "guardando". Sin colisiones de id al reconectar. |
| 4 | `Match.tournamentId` **nullable** | Un solo motor de combate para modo rápido y torneo. |
| 5 | Admin es un **permiso sobre un torneo**, no un tipo de usuario | El organizador casi siempre también compite. Guard por recurso (`Tournament.organizerIds`), nunca por `User.role` global. |

---

## 4. Reglas del juego — oficial v12 (marzo 2026)

Están en `assets/data/beyblade_x_parts.json` bajo la clave `rules`. **Léelas del JSON, no las hardcodees.**

### Puntuación — gana quien llegue a 4

| Código | Puntos | Cuándo |
|---|---|---|
| `XTREME` | 3 | El rival cae **entero** en la zona Xtreme y no puede volver |
| `OVER` | 2 | El rival cae entero en la zona de expulsión |
| `BURST` | 2 | Las piezas del rival se sueltan y separan |
| `SPIN` | 1 | El rival se detiene primero dentro de la zona de combate |
| `PENALTY` | 1 | **No es un finish.** 2 faltas de lanzamiento del rival en la misma ronda |

`PENALTY` lleva `isPenalty: true` y se muestra distinto (rayado diagonal). Las estadísticas deben separarlo: quien acumula muchos no juega mejor, necesita practicar el lanzamiento.

### Formato oficial: 3on3

- Cada jugador lleva **3 beys** en orden de combate.
- **Ninguna pieza puede repetirse entre los 3**, incluidas piezas del mismo nombre **en distinto color**.
- Única excepción: lock chips CX **Ares** y **Emperor**, uno de cada.
- Piezas de salón de la fama: prohibidas en individual, permitidas en 3on3.
- Empate en ronda: se repiten los beys del mismo número. 3 rondas sin decidir: se reordena y se sigue.

### Lanzamiento

- Cuenta: **"Three, Two, One, Go-Shoot"**, se lanza en el instante de *Shoot*.
- Máximo **20 cm** del estadio.
- Posición (izquierda/derecha/centro) se decide a piedra-papel-tijera y **no cambia** en toda la partida.
- 2 faltas acumuladas en una ronda → 1 punto al rival y la ronda se reinicia.

### Conducta

Tocar un bey del estadio antes de que el juez declare = **derrota instantánea**. Solo el juez puede aplicarla; nunca desde el teléfono de un jugador.

```dart
sealed class MatchOutcome {}
class PointsReached extends MatchOutcome {}
class InstantLoss extends MatchOutcome { final String reason; }
class Forfeit extends MatchOutcome {}
```

### Torneos

Niveles: `G3` local → `G2` regional → `G1` nacional → `GP` mundial → `UNOFFICIAL`.
Categorías: `OPEN` (6+) y `REGULAR` (6–12). **El sorteo separa por categoría**, no mezcla.

---

## 5. Estructura

```
lib/
├── core/            di · error · sync (Outbox, SyncEngine) · id · usecase
├── config/          router (go_router + guards) · theme · env
├── shared/          widgets y blocs transversales (PointRail, SyncBadge)
└── features/
    ├── catalog/     piezas · las 3 capas SIN usecases
    ├── combo/       combos del usuario
    ├── deck/        decks 3on3 + DeckValidator
    ├── battle/      marcador · las 3 capas CON usecases
    ├── tournament/  sorteo, bracket · las 3 capas CON usecases
    ├── meta/        tier list + "qué puedes armar"
    ├── stats/       estadísticas · SIN usecases
    └── profile/
```

**Regla de dependencias, sin excepciones:** `presentation → domain ← data`.
`domain/` no importa Flutter, ni Drift, ni Dio. Si compila en Dart puro, está bien hecho.

**Capas por complejidad, no por simetría:**
- `battle` y `tournament` → tres capas completas con use cases. Ahí hay lógica real.
- `catalog`, `profile`, `stats` → **sin `usecases/`**. El BLoC llama al repositorio.
- **Nunca crees un use case que solo haga `return repo.doThing()`.** Eso es burocracia.

---

## 6. Dónde vive la lógica

Servicios de dominio **puros** (sin I/O, sin Flutter, testeables sin mocks):

| Servicio | Qué hace |
|---|---|
| `ScoringService` | Valida y aplica finishes, calcula el marcador, cierra el combate |
| `DeckValidator` | Regla de piezas no repetibles, salón de la fama, lanzador L |
| `BracketGenerator` | Genera el cuadro, byes, avance de ronda |
| `SeededShuffle` | Barajado determinista con semilla guardada |
| `BuildabilityService` | Intersección inventario ∩ combos top |

Estos van al 100% de cobertura de tests. Son puros: no hay excusa.

**El BLoC solo orquesta.** Recibe el tap, llama al caso de uso, emite estado. Si te descubres poniendo reglas del juego en un BLoC, sácalas al dominio.

### RxDart: solo en cuatro sitios

1. `debounceTime` en búsqueda del catálogo (239 piezas)
2. `throttleTime` en botones de finish (evita doble tap en pleno grito)
3. `Rx.combineLatest` para el estado de sincronización (3 streams)
4. `BehaviorSubject` en `SyncEngine` (suscriptor tardío necesita el último valor)

**No** envuelvas cada repositorio en `Observable`. **No** uses `PublishSubject` como bus global entre features. **No** reemplaces `Either` por streams de error.

---

## 7. Sincronización — invariantes que no se rompen

```
Usuario toca "BURST"
  → escribe en Drift            (la UI ya reaccionó por stream)
  → inserta OutboxEntry PENDING
  → SyncEngine al reconectar / cada 30s / al abrir
      éxito → SYNCED
      fallo → backoff exponencial 1s,2s,4s… máx 5 → FAILED (visible al admin)
```

Toda tabla sincronizable lleva: `id` (UUID v7), `updatedAt`, `version`, `isDirty`, `isDeleted` (borrado lógico).

### Resolución de conflictos por tipo de dato

| Dato | Estrategia |
|---|---|
| Catálogo | El servidor gana siempre (solo lectura para el usuario) |
| Combos y decks | Última escritura gana (un dueño único) |
| `BattleFinish` | **Append-only, unión de conjuntos** por `(matchId, roundIndex, sequence)` |
| Bracket / torneo | El dispositivo del organizador es autoritativo |
| Resultado en disputa | **Escalar al humano.** La app no adivina. |

**Nunca resuelvas conflictos por `updatedAt`.** Los relojes de los teléfonos no están sincronizados: quien tenga la hora adelantada ganaría todos los conflictos. Usa reloj lógico (`deviceId` + contador monótono). `updatedAt` sirve para mostrar, jamás para decidir.

**El "deshacer" es una entrada nueva** (`FinishVoided(targetFinishId)`), no un borrado. Nunca borres un hecho que otro dispositivo pudo replicar.

**Un solo escritor por combate:** al abrir el marcador el dispositivo toma un `writerLock`. Elimina el 95% de los conflictos en origen, que es mejor que resolverlos bien.

---

## 8. Catálogo — 239 piezas

`assets/data/beyblade_x_parts.json`, `schemaVersion: 5`.

| Tipo | Cantidad |
|---|---|
| BLADE | 68 |
| LOCK_CHIP / MAIN_BLADE / ASSIST_BLADE / OVER_BLADE / METAL_BLADE (CX) | 66 |
| RATCHET | 36 |
| BIT | 52 |
| ACCESSORY | 17 |

Todas con imagen. No lleva Outbox: reemplazo total por versión, en **una transacción**.

### Campos que hay que entender

| Campo | Detalle |
|---|---|
| `heightDmm` | Décimas de mm. `60` = 6.0 mm |
| `weightClass` | Texto del origen: `7-` ligero, `7=` medio, `7+` pesado |
| `beyType` | `attack`/`defense`/`stamina`/`balance`. **Viene de la fuente, jamás se calcula** |
| `gearTeeth` | Más dientes = Xtreme Dash más fuerte pero gasta más stamina |
| `shaftWidth` | Diámetro del eje → resistencia al burst |
| `spinDirection` | Solo 2 blades giran a la izquierda; exigen lanzador L (BX-40/BX-47) |
| `metaTier` | `S`/`A`/`B` o `null`. **`null` = sin datos, no "malo"** |
| `hasbroAlias` | Nombre occidental. `HellsScythe` → `Scythe Incendio`. **Inclúyelo en la búsqueda** |
| `weightG` | Peso **listado**, no medido. El peso que mida el usuario siempre gana |

### Actualización

CDN estático (`cdn/`), no backend:
- `/catalog/manifest.json` — caché 5 min
- `/catalog/vN.json` — caché 1 año, `immutable`

**Una versión nunca cambia de contenido.** Datos nuevos salen como `v6.json`, nunca editando `v5.json`. Por eso el sha256 sirve y el caché puede ser de un año.

`CatalogUpdater` corre **después de `runApp()`**, nunca antes. Verifica el hash antes de tocar la base, rechaza catálogos con menos de 50 piezas, y reemplaza en una transacción. Si algo falla, se queda con la copia empaquetada.

---

## 9. Diseño

Tokens en `config/theme/`. **Cada color tiene un trabajo fijo. Ningún color decora.**

```dart
const void_    = Color(0xFF06070C);   // fondo
const steel    = Color(0xFF0E1220);
const panel    = Color(0xFF151B29);
const line     = Color(0xFF28324A);
const text     = Color(0xFFEEF1F7);
const mute     = Color(0xFF78859D);

const dragoon  = Color(0xFF2B6BFF);   // jugador A, SIEMPRE
const dranzer  = Color(0xFFFF3B2F);   // jugador B, SIEMPRE
const pegasus  = Color(0xFFFFC400);   // Over Finish · sin sincronizar
const burst    = Color(0xFFA855F7);   // Burst Finish
const x        = Color(0xFF00E5D0);   // Xtreme Finish · acción principal
```

Tipografía: display `Archivo Black` con `skewX(-8°)` · cuerpo `Inter Tight` · datos y códigos `JetBrains Mono` · nombres japoneses `Noto Sans JP`.

Forma: esquinas biseladas 8px (16px en contenedores grandes), tomadas de la geometría de las piezas.

Elementos firma:
- **Riel de puntos** — 4 segmentos en diagonal que se llenan hacia el centro, como el X-Dash del estadio. Penalizaciones en rayado diagonal.
- **Anillos girando** detrás de cada marcador, en sentidos opuestos. Único movimiento de la app. Respeta `prefers-reduced-motion`.
- **Siluetas por tipo** — ataque con picos, defensa hexagonal, stamina aro liso, balance mezcla. Placeholder mientras carga la foto.
- **Diagrama del estadio** con zonas tocables: el juez toca dónde cayó el bey en vez de recordar qué finish vale qué.

---

## 10. Trampas — errores que ya cometimos

Esto es lo más importante del documento. Cada punto costó una corrección real.

### No deduzcas lo que puedes buscar

Deduje el tipo de cada bit por su nombre. Medido contra los datos reales: **32% de acierto** en 52 bits. `Ball` es stamina, no defensa. `Point` y `Taper` son balance. `Needle` y `Wedge` son defensa. Y `Ball` es el bit más usado del juego competitivo.

> **Deriva solo cuando la derivación sea una *definición*, no una *inferencia*.**
>
> `3-60` = 3 picos, 60 de altura → definición del sistema de nombres, no puede fallar.
> `Ball` = defensivo → suposición sobre decisiones de diseño de Takara Tomy.
>
> Prueba práctica: si no puedes escribir la regla como función total sin excepciones, es adivinanza.

### Confirmar un dato no cierra el tema

Investigué la puntuación al principio, la confirmé, y nunca busqué el reglamento de torneo. Resultado: construí un marcador 1v1 para un juego que en torneos se juega 3on3.

> **Cuando encuentres un dato que confirma lo que esperabas, esa es la señal de seguir buscando, no de parar.**

### Mira los datos antes de diseñar la UI

Diseñé la pantalla de catálogo asumiendo stats completos. Llegaron 2 de 138. La pantalla se veía rota y parecía defecto de la app cuando el defecto era del mundo.

> Nullable en la base, **ausencia explícita en la UI**. Nunca un 0 donde falta un dato. La jerarquía visual se ordena por cobertura real, no por lo que sería bonito.

### El fallo ruidoso gana al dato silenciosamente equivocado

Al pedir `blade.php?id=4` el sitio redirigió al índice y devolvió HTML válido. Un parser ingenuo habría guardado los stats del índice como si fueran de esa pieza. Por eso el scraper **valida que el título coincida y falla si no**.

### `identityKey` es el id del catálogo, no el del inventario

En `DeckValidator`, si el usuario tiene dos DranSword de distinto color, cada ejemplar tiene su id de inventario pero **comparten identidad a efectos de la regla**. Pasar el id equivocado hace que el validador no detecte nada y el jugador se lleve la descalificación en la mesa de chequeo.

### No sumes ceros

`comboWeight` devuelve `null` si falta el peso de cualquier pieza, en vez de sumar ceros y mostrar "34.2 g" para un combo cuyo peso real se desconoce. Y devuelve un **rango**, no un escalar; nunca promedies un rango, porque promediar reinventa la precisión que el rango existía para evitar.

---

## 11. Convenciones

**Estados sellados** siempre:
```dart
sealed class BattleState {}
final class BattleInProgress extends BattleState { ... }
```

**Errores con `Either`**, no excepciones, en dominio y datos. `Failure` es `sealed`.

**Streams, no futures sueltos**, para todo lo que la UI observa. Drift avisa; nadie llama a `refresh()`.

**La respuesta de la API nunca va a la UI directamente.** Aterriza en Drift y Drift avisa por stream. Un solo camino de datos, un solo sitio donde depurar.

**Nombres:** `snake_case.dart` para archivos, `PascalCase` para clases, sufijos `_bloc` / `_page` / `_repository_impl` / `_local_datasource`.

**Tests:** servicios de dominio 100% · use cases 90% · blocs con `bloc_test` · `SyncEngine` con integración simulando pérdida de red · widgets solo en flujos críticos.

---

## 12. Mapa de archivos entregados

| Archivo | Qué es |
|---|---|
| `beyblade_x_parts.json` | 239 piezas + reglamento v12 → `assets/data/` |
| `catalog_local_datasource.dart` | Tabla Drift + seeder + consultas |
| `catalog_updater.dart` | Actualización desde CDN con verificación sha256 |
| `deck_validator.dart` | Validación 3on3, función pura |
| `cdn/` | Sitio estático (manifest + versiones) |
| `INTEGRACION.md` | Guía paso a paso de montaje |
| `arquitectura.md` | Decisiones completas + 6 pasadas de autocrítica |
| `mockups-mobile.html` | 16 pantallas |
| `flujo-interactivo.html` | Explicador de flujos paso a paso |

---

## 13. Orden de construcción

1. `core/` + tema + Drift con catálogo semilla
2. `combo` — armar y guardar combos, todo local
3. `deck` + `DeckValidator`
4. `battle` 1v1, un teléfono. **Aquí ya hay producto usable**
5. `stats` con snapshot materializado
6. `battle` 3on3 con alineación y rondas
7. `tournament` — sorteo, cuadro, mesas
8. Confirmación entre dispositivos + `SyncEngine` + backend

Cada paso es una app que sirve sola. Si el proyecto se detiene en el 4, igual hay algo que la gente usa.

---

## 14. Antes de dar algo por hecho

- [ ] `flutter analyze` limpio
- [ ] Tests de dominio pasan
- [ ] Ninguna regla del juego nueva quedó en un BLoC o widget
- [ ] Nada consulta la red en el camino crítico de la UI
- [ ] Ningún dato ausente se muestra como 0
- [ ] Ningún conflicto se resuelve por `updatedAt`
- [ ] Si añadiste un campo derivado: ¿es definición o inferencia?

---

## 15. Lo que sigue sin verificar

- El reglamento v12 es el de la distribuidora de Taiwán. **La WBO usa reglas propias que difieren.** La app debería permitir elegir reglamento por torneo, no imponer uno.
- No se leyó el PDF oficial completo, solo el resumen. Los casos límite (qué cuenta exactamente como "el bey entero" en la zona Xtreme) están ahí.
- 239 piezas no es definitivo: Takara Tomy lanza continuamente. Por eso el catálogo está versionado desde el día uno.
- Los pesos son listados por el fabricante, no medidos.

---

## Atribución

Datos de [beybladehub.app](https://beybladehub.app), [beybxdb.com](https://www.beybxdb.com), [beyxhub.org](https://beyxhub.org) y la [Beyblade Wiki](https://beyblade.fandom.com) (CC-BY-SA). Reglamento oficial v12, marzo 2026.

BEYBLADE X es marca de Takara Tomy / Hasbro. Datos factuales, uso no comercial. La app debe incluir pantalla "Acerca de" con estos créditos.
