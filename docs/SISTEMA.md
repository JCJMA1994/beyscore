# El sistema completo

Cómo encajan usuario, organizador, mesa y servidor. Este documento consolida y **corrige** los anteriores: al integrarlos aparecieron tres contradicciones que están resueltas aquí.

---

## 1. El sistema en una página

```
┌─────────────────────────────────────────────────────────┐
│  UNA APP FLUTTER · tres shells según el dispositivo      │
├──────────────┬───────────────┬──────────────────────────┤
│ PhoneShell   │ TableShell    │ WideShell / Web          │
│ cuenta       │ emparejado    │ cuenta · solo lectura    │
│ vertical     │ horizontal    │ ancho                    │
└──────┬───────┴───────┬───────┴───────────┬──────────────┘
       │               │                   │
       └───────────────┴───────────────────┘
                       │
              ┌────────▼─────────┐
              │ PermissionService│   12 capacidades por recurso
              │ (función pura)   │   nunca un bool isAdmin
              └────────┬─────────┘
                       │
                 ┌─────▼──────┐
                 │   Drift    │   fuente de verdad para LEER
                 └─────┬──────┘
                       │
                 ┌─────▼──────┐
                 │   Outbox   │   toda escritura pasa por aquí
                 └─────┬──────┘
                       │
        ┌──────────────┴───────────────┐
        │                              │
   ┌────▼─────┐                  ┌─────▼──────┐
   │ HUB LAN  │  torneo          │  SUPABASE  │  personal
   │ tel. del │  ───────────────▶│            │  + torneo en lote
   │ organiz. │                  └─────┬──────┘
   └────▲─────┘                        │
        │                        ┌─────▼──────┐
   mesas y jugadores             │ Panel web  │
                                 └────────────┘
```

**Las tres capas de decisión, que no se mezclan:**

| Capa | Pregunta | Respuesta |
|---|---|---|
| Superficie | ¿dónde se ve? | teléfono · mesa · web |
| Identidad | ¿quién eres? | `userId` (persona) + `deviceId` (instalación) |
| Capacidad | ¿qué puedes? | se **calcula** por recurso |

---

## 2. Los tres actores

### Usuario

```
Instala → apodo → userId + deviceId + código de recuperación
        → arma combos y decks
        → se inscribe a un torneo con un deck
        → compite (en la mesa, o en su teléfono si no hay tablet)
        → ve sus estadísticas
```

Identidad: cuenta anónima con `auth.uid()`. Sin email.

### Organizador

```
Es un usuario que además creó un torneo.
        → crea (3 pasos) → publica inscripción
        → revisa decks, avisa a los ilegales
        → check-in y chequeo de piezas
        → sortea con semilla guardada
        → levanta el HUB y empareja las mesas
        → vigila, resuelve disputas, cierra rondas
        → publica y sube al servidor
```

Identidad: **la misma cuenta.** Ser organizador es tener `tournaments.owner_id = auth.uid()`, no un tipo de usuario.

### Mesa

```
Tablet horizontal sobre el estadio.
        → escanea el QR del organizador → emparejada a Mesa 3
        → reposo → VS → tap to ready → cuenta atrás → marcador
        → confirman los dos → vuelve a reposo
        → si hay desacuerdo: se bloquea y llama al juez
```

Identidad: **ninguna.** Es `DeviceRole.table` con un token de emparejamiento. No tiene cuenta en el servidor.

---

## 3. El recorrido completo, fase por fase

| Fase | Usuario | Organizador | Mesa | Dónde vive el dato |
|---|---|---|---|---|
| **Antes** | arma combos y decks | crea el torneo | — | Drift → Supabase (personal) |
| **Inscripción** | se inscribe con un deck | revisa decks | — | Drift → Supabase |
| **Llegada** | check-in | marca asistencia | — | Drift local |
| **Chequeo** | enseña el QR del deck | valida y **congela snapshot** | — | Drift local |
| **Sorteo** | espera | genera cuadro con semilla | — | Drift del organizador |
| **Montaje** | — | levanta el hub, muestra QR | escanea, se empareja | LAN |
| **Combate** | juega | vigila el panel | **registra los finishes** | Drift de la mesa → hub |
| **Disputa** | discrepa | resuelve desde su teléfono | se bloquea | hub |
| **Cierre ronda** | ve su siguiente combate | cierra y avanza | vuelve a reposo | hub |
| **Fin** | ve su resultado | publica | se despareja | hub → Supabase |
| **Después** | consulta estadísticas | mira el panel web | apagada | Supabase |

---

## 4. Las rutas de escritura

Esto es lo que la integración obligó a definir con precisión.

### La regla del único subidor

> **Cada torneo tiene exactamente un dispositivo que lo sube al servidor: el teléfono del organizador.**

```
Mesa ──LAN──▶ Hub ──internet──▶ Supabase
Jugador ──LAN──▶ Hub ──────────▶ Supabase
```

Por qué importa: elimina de raíz los conflictos de escritura sobre un torneo. Nadie más puede insertar en `battle_finishes` de ese torneo, así que no hay nada que reconciliar.

### Las dos excepciones

| Qué | Ruta | Por qué |
|---|---|---|
| Combos, decks, perfil | teléfono del usuario → Supabase **directo** | son suyos, un solo dueño |
| Combate suelto (`tournament_id IS NULL`) | teléfono del jugador → Supabase **directo** | no hay torneo ni organizador |

Todo lo demás pasa por el hub.

---

## 5. Contradicciones que aparecieron al integrar

Los documentos anteriores eran correctos por separado. Juntos, no.

### a) Los jugadores no podían registrar resultados

La política de RLS decía *"solo el dueño del torneo inserta en `battle_finishes`"*. Pero en un torneo pequeño sin tablets, los jugadores registran en sus teléfonos.

**Resolución:** los combates de torneo van siempre por el hub, aunque el jugador los registre en su móvil. La política se queda como está. Los combates sueltos tienen `tournament_id IS NULL` y otra política.

```sql
create policy "combate suelto lo escriben sus jugadores" on battle_finishes
  for insert with check (
    exists (
      select 1 from match_rounds mr join matches m on m.id = mr.match_id
      where mr.id = round_id
        and m.tournament_id is null
        and (m.player_a = auth.uid() or m.player_b = auth.uid())
    )
  );
```

### b) El organizador no podía crear jugadores invitados

`profiles` tenía la política `auth.uid() = id` para insertar. Un invitado tiene un `userId` que **no es** el del organizador, así que la inserción se rechazaba.

**Resolución:** columna `created_by` y una política nueva.

```sql
alter table profiles add column created_by uuid references profiles(id);

create policy "puedo crear invitados" on profiles for insert
  with check (
    auth.uid() = id                                   -- mi propio perfil
    or (is_guest = true and created_by = auth.uid())  -- o un invitado mío
  );
```

### c) El `writerLock` sobraba

Diseñé un mecanismo de bloqueo para que dos dispositivos no registraran el mismo combate. Pero el organizador ya asigna cada combate a una mesa.

**Resolución: `matches.table_number` ES el bloqueo.** Un combate, una mesa, asignada antes de jugar. Se elimina el protocolo de locks, sus TTL y sus casos de caducidad.

> Regla que me llevo: **si dos mecanismos garantizan lo mismo, uno sobra.** La asignación de mesa ya era autoritativa; el lock era ceremonia.

---

## 6. Falsos positivos eliminados

Cosas que parecían correctas y no lo son. Cada una costó una corrección real.

| Idea que suena bien | Por qué falla |
|---|---|
| `user.isAdmin` global | El organizador también compite. Capacidades por recurso |
| Dar cuenta de servidor a la mesa | Rompe el único subidor y crea tokens que se filtran |
| Realtime en el servidor para el directo | El directo es LAN. El servidor recibe lotes |
| Jugadores escribiendo el torneo directo al servidor | Conflictos que la LAN ya evitaba |
| Reclamar invitado reescribiendo sus filas | Cambia el pasado. Se **enlaza** con `merged_into` |
| Código de recuperación de 8 caracteres | 40 bits. Son 12 caracteres y se guarda el hash |
| Sesión anónima como recuperación | Muere al desinstalar. Hace falta código → sesión |
| Resolver conflictos por `updatedAt` | Relojes desincronizados. `lamport` |
| Guardar el torneo como blob JSON | Imposible consultar y unir. Tablas normalizadas |
| Guardar el marcador final | Sin el log no hay analítica ni reconstrucción |
| Deducir el tipo de bit por el nombre | 32% de acierto. Viene de la fuente |
| WebSocket en la LAN | El sondeo ya es la lógica de reconexión |
| mDNS para encontrar el hub | Falla en la mitad de los routers. QR |
| `writerLock` además de asignar mesa | Dos mecanismos, misma garantía |

---

## 7. Escalabilidad

### Lo que aguanta

| Escenario | Carga | Veredicto |
|---|---|---|
| 8 mesas sondeando cada 2 s | 4 req/s contra un teléfono | trivial |
| Torneo de 64, 3on3, doble | ~1.600 finishes ≈ 320 KB | trivial |
| 6.000 torneos en Supabase gratis | 500 MB | años |
| Panel web con 200 espectadores | lecturas cacheadas | trivial |

### Dónde está el límite real

**El hub en un teléfono deja de tener sentido por encima de ~10 mesas.** No por rendimiento, sino porque un evento de ese tamaño (G1, GP) tiene wifi e internet de verdad.

```
G3 · G2   →  hub en el teléfono del organizador   (sin internet)
G1 · GP   →  Supabase directo                     (con internet)
```

El mismo `RemoteDataSource` sirve para los dos: cambia a qué URL apunta. **No hay reescritura, hay configuración.**

### Por qué la arquitectura lo aguanta

1. **Los finishes son append-only.** Escalar lecturas es cachear; nunca hay que invalidar nada.
2. **Las clasificaciones son proyecciones.** Si el cálculo se queda corto, se materializa más agresivamente sin tocar la verdad.
3. **El dominio es puro.** `ScoringService`, `DeckValidator` y `BracketGenerator` no saben si hay red, hub o servidor.
4. **El Outbox desacopla.** Añadir un destino nuevo es una implementación más de `RemoteDataSource`.
5. **El catálogo está versionado.** 239 piezas hoy, 400 mañana, sin migración de esquema.

---

## 8. Delta de esquema respecto a los documentos anteriores

```sql
-- de la contradicción (b)
alter table profiles add column created_by uuid references profiles(id);

-- el enlace de invitados, de la §7 de SERVIDOR.md
alter table profiles add column merged_into uuid references profiles(id);

-- de la contradicción (c): la asignación de mesa es autoritativa
alter table matches add column table_number int;
create unique index one_match_per_table
  on matches (tournament_id, table_number)
  where status = 'RUNNING';   -- una mesa, un combate en curso
```

Ese índice único es lo que sustituye a todo el protocolo de locks: **la base de datos garantiza que una mesa no puede tener dos combates a la vez.**

---

## 9. Orden de construcción

| # | Qué | Depende de | Ya sirve para |
|---|---|---|---|
| 1 | Identidad local + combos + decks | — | armar beys |
| 2 | Combate 1v1 en un teléfono | 1 | jugar con un amigo |
| 3 | Torneo en un solo dispositivo | 2 | torneo de 8 en casa |
| 4 | `TableShell` + emparejamiento | 3 | una mesa con tablet |
| 5 | Hub LAN + sondeo | 4 | **varias mesas sin internet** |
| 6 | Supabase: perfiles + código | 1 | recuperar identidad |
| 7 | Subida del torneo en lote | 5, 6 | historial permanente |
| 8 | Panel web | 7 | resultados y analítica |

Cada paso deja algo usable. El **5** es el valor diferencial: ninguna app que conozcas corre un torneo de varias mesas sin internet.

---

## 10. Las siete reglas del sistema

> **No existe "ser admin".** Existe poder hacer X sobre Y, y se calcula.

> **Dos ids:** uno para la persona, otro para la instalación.

> **Un torneo, un subidor:** el teléfono del organizador.

> **Nada de lo que ve el jugador cruza la red.** El marcador es local; sincronizar es observar.

> **Guarda hechos, no conclusiones.** Los finishes son hechos; el ranking se recalcula.

> **Congela lo que se referencia desde el pasado.** Un torneo terminado no cambia porque alguien editó su combo.

> **Si dos mecanismos garantizan lo mismo, uno sobra.**

---

## 11. Comprobación antes de lanzar

**Datos**
- [ ] Cerrar la app de verdad y reabrir: los datos siguen
- [ ] `select tablename from pg_tables where rowsecurity = false` → 0 filas
- [ ] `battle_finishes` sin update ni delete
- [ ] La *service role key* no está en el cliente

**Identidad**
- [ ] Códigos de 12 caracteres, guardados como hash, 5 intentos máximo
- [ ] Reclamar invitado **enlaza**, no reescribe
- [ ] Ninguna clave foránea apunta al alias

**Permisos**
- [ ] Nadie arbitra un combate que juega, salvo que no haya otro juez (y queda marcado)
- [ ] La mesa no puede resolver disputas
- [ ] Ningún `if (isAdmin)` en ningún widget

**Sincronización**
- [ ] Perder el hub no interrumpe ningún combate
- [ ] El índice único impide dos combates en la misma mesa
- [ ] Ningún conflicto se resuelve por `updatedAt`
