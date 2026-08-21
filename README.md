# BeyScore 🌪️

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.11+-0175C2?logo=dart)](https://dart.dev)
[![Melos](https://img.shields.io/badge/Monorepo-Melos-FF6B6B?logo=dart)](https://melos.invertase.dev)
[![Arquitectura](https://img.shields.io/badge/Arquitectura-Clean%20%2B%20Offline--First-4CAF50)](#principios-de-diseño-y-arquitectura)
[![Licencia](https://img.shields.io/badge/Licencia-MIT-blue.svg)](LICENSE)

**BeyScore** es un ecosistema móvil y de escritorio desarrollado con Flutter y diseñado con un enfoque **offline-first** para el registro de combates físicos de **Beyblade X** y la gestión integral de torneos.

Diseñado específicamente para operar en entornos de torneo ruidosos y de ritmo acelerado donde la conexión a internet es nula o inestable, BeyScore gestiona el arbitraje de partidas, la validación de barajas (reglamento 3on3), la generación determinista de cuadros de torneo (brackets), mesas de arbitraje y la emisión de diplomas oficiales en PDF.

---

## 📑 Tabla de Contenidos

- [Visión General y Aplicaciones](#-visión-general-y-aplicaciones)
- [Arquitectura del Monorepo](#-arquitectura-del-monorepo)
- [Principios de Diseño y Arquitectura](#-principios-de-diseño-y-arquitectura)
- [Motor de Reglas Oficiales (Beyblade X)](#-motor-de-reglas-oficiales-beyblade-x)
- [Requisitos Previos](#-requisitos-previos)
- [Instalación y Configuración](#-instalación-y-configuración)
- [Compilación y Ejecución](#-compilación-y-ejecución)
- [Pruebas y Control de Calidad](#-pruebas-y-control-de-calidad)
- [Estructura del Proyecto](#-estructura-del-proyecto)

---

## 📱 Visión General y Aplicaciones

BeyScore está dividido en **tres aplicaciones Flutter especializadas** construidas sobre paquetes modulares compartidos:

```
                  ┌───────────────────────────────┐
                  │      Ecosistema BeyScore      │
                  └───────────────┬───────────────┘
         ┌────────────────────────┼────────────────────────┐
         ▼                        ▼                        ▼
┌─────────────────┐      ┌─────────────────┐      ┌─────────────────┐
│   App Player    │      │  App Organizer  │      │    App Table    │
│  (Jugador/Deck) │      │ (Organizador)   │      │ (Mesa Arbitraje)│
├─────────────────┤      ├─────────────────┤      ├─────────────────┤
│ • Validador de  │      │ • Gestión de    │      │ • Marcador 1v1  │
│   Decks 3on3    │      │   Torneos       │      │   y Torneo      │
│ • Catálogo      │      │ • Generador de  │      │ • Botones de    │
│ • Historial     │      │   Brackets      │      │   Gran Tamaño   │
│ • Estadísticas  │      │ • Diplomas PDF  │      │ • Sincronización│
│   del Blader    │      │ • Monitor Mesas │      │   Local (Hub)   │
└─────────────────┘      └─────────────────┘      └─────────────────┘
```

1. **`apps/app_player` (Aplicación del Jugador / Blader)**:
   - Construcción y validación de barajas 3on3 oficiales (bloqueo de piezas repetidas, incluso en diferente color).
   - Consulta y filtrado del catálogo de piezas (Blades, Ratchets, Bits, Lock Chips).
   - Perfil con código QR y métricas de rendimiento por tipo de finalización (Spin, Burst, Over, Xtreme).

2. **`apps/app_organizer` (Panel del Organizador)**:
   - Creación y administración de torneos en categorías `OPEN` y `REGULAR`, con niveles oficiales (G3, G2, G1, GP).
   - Generación determinista de cuadros de eliminación directa, doble eliminación y sistema suizo.
   - Supervisión en tiempo real de mesas de combate y exportación automática de diplomas en PDF.

3. **`apps/app_table` (Consola de Mesa de Arbitraje)**:
   - Interfaz de alto contraste optimizada para operar a una mano en torneos físicos.
   - Registro directo de tipos de victoria (`XTREME` = 3 pts, `OVER` = 2 pts, `BURST` = 2 pts, `SPIN` = 1 pt, `PENALTY` = 1 pt).
   - Sincronización en red local (P2P/Hub) sin dependencia de internet.

---

## 🏗️ Arquitectura del Monorepo

El proyecto utiliza **Clean Architecture** estructurada en paquetes Dart/Flutter desacoplados:

```
packages/
├── bey_domain/       # Entidades, value objects y lógica de negocio pura (Dart puro)
├── bey_data/         # Base de datos local Drift (SQLite), migraciones y motor Outbox
├── bey_catalog/      # Catálogo de piezas Beyblade X, búsqueda y compatibilidad
├── bey_tournament/   # Gestión de torneos, emparejamientos y generación de diplomas PDF
├── bey_hub/          # Puente de sincronización en red local (LAN/P2P)
└── bey_ui/           # Sistema de diseño compartido, componentes visuales (PointRail, etc.)
```

**Regla de dependencias:** `presentación (apps) ➔ dominio  datos`.
El paquete `bey_domain` es completamente independiente de Flutter y de motores de bases de datos.

---

## ⚡ Principios de Diseño y Arquitectura

1. **El `BattleFinish` como unidad atómica**: El marcador no es un número editable; los puntos son valores derivados calculados a partir del historial de finalizaciones registradas en cada ronda.
2. **Offline-First real**: Drift (SQLite) es la única fuente de verdad para lecturas en la interfaz de usuario. Las operaciones de red no bloquean la experiencia de uso.
3. **Patrón Outbox con UUID v7**: Cada evento genera un identificador UUID v7 ordenable temporalmente en el cliente y se encola en el Outbox para su sincronización eventual sin colisiones.
4. **Servicios de dominio deterministas**: La lógica crítica (`ScoringService`, `DeckValidator`, `BracketGenerator`, `SeededShuffle`) reside en servicios puros con cobertura de pruebas unitarias al 100%.

---

## 🎯 Motor de Reglas Oficiales (Beyblade X)

El sistema implementa el reglamento oficial de torneos (v12 / Marzo 2026):

| Tipo de Victoria | Puntos | Condición |
|---|:---:|---|
| **XTREME** | `3` | El Beyblade rival entra por completo a la zona Xtreme y no puede regresar. |
| **OVER** | `2` | El Beyblade rival es expulsado fuera del área de combate a la zona Over. |
| **BURST** | `2` | Las piezas del Beyblade rival se desacoplan y separan durante el combate. |
| **SPIN** | `1` | El Beyblade rival se detiene primero dentro de la zona de combate. |
| **PENALTY** | `1` | Falta técnica acumulada (2 faltas de lanzamiento en la misma ronda). |

- **Meta de victoria**: Primer jugador en alcanzar **4 puntos**.
- **Regla de Decks 3on3**: Ninguna pieza puede repetirse entre los 3 Beys (aplica también a piezas del mismo nombre en distinto color). Única excepción: Lock Chips CX Ares y Emperor (uno de cada uno).

---

## 📋 Requisitos Previos

Antes de compilar y ejecutar el proyecto, asegúrate de contar con el siguiente entorno:

- **Flutter SDK**: `>= 3.29.0` ([Instrucciones de instalación](https://docs.flutter.dev/get-started/install))
- **Dart SDK**: `>= 3.11.0` (incluido en Flutter)
- **Melos**: Herramienta de gestión para monorepos Dart/Flutter
  ```bash
  dart pub global activate melos
  ```
- **Herramientas de plataforma (según el objetivo de compilación)**:
  - Android Studio / Android SDK (para compilar en Android)
  - Xcode y CocoaPods (para compilar en iOS / macOS)
  - Visual Studio C++ Build Tools (para compilar en Windows Desktop)

---

## 🚀 Instalación y Configuración

1. **Clonar el repositorio**:
   ```bash
   git clone https://github.com/beyscore/beyscore.git
   cd beyscore
   ```

2. **Vincular paquetes e instalar dependencias (Bootstrap)**:
   ```bash
   melos bootstrap
   # o alternativamente: dart pub get
   ```

3. **Generación de código (Tablas Drift, Inyección de Dependencias, Serializadores)**:
   ```bash
   # Ejecuta build_runner en todos los paquetes del monorepo
   melos exec -- "dart run build_runner build --delete-conflicting-outputs"
   ```

   > **Nota de desarrollo**: Durante el desarrollo activo, puedes mantener el generador en escucha con:
   > ```bash
   > melos exec -- "dart run build_runner watch --delete-conflicting-outputs"
   > ```

---

## 💻 Compilación y Ejecución

### Ejecución en Modo Desarrollo

Navega a la carpeta de la aplicación deseada y ejecuta `flutter run`:

#### 1. App del Jugador (`app_player`)
```bash
cd apps/app_player
flutter run
```

#### 2. App del Organizador (`app_organizer`)
```bash
cd apps/app_organizer
flutter run
```

#### 3. App de Mesa de Arbitraje (`app_table`)
```bash
cd apps/app_table
flutter run
```

---

### Compilación de Binarios de Producción

Puedes generar ejecutables y paquetes instalables usando los scripts configurados en Melos o los comandos nativos de Flutter:

#### Android (APK)
```bash
# Mediante scripts de Melos:
melos run build:player:apk
melos run build:organizer:apk
melos run build:table:apk

# O directamente desde la aplicación:
cd apps/app_table && flutter build apk --release
```

#### Windows Desktop
```bash
cd apps/app_organizer
flutter build windows --release
```

#### iOS (Bundle / IPA)
```bash
cd apps/app_player
flutter build ipa --release
```

---

## 🧪 Pruebas y Control de Calidad

BeyScore cuenta con suites de pruebas unitarias y de análisis estático:

```bash
# Ejecutar todas las pruebas unitarias y de widgets en el monorepo
melos run test

# Ejecutar únicamente las pruebas de lógica pura de dominio
melos run test:domain

# Ejecutar el análisis estático y linter en todo el código
melos run analyze
```

---

## 📂 Estructura del Proyecto

```
├── .github/                 # Flujos de integración continua (CI/CD)
├── apps/
│   ├── app_organizer/       # Aplicación para directores de torneo
│   ├── app_player/          # Aplicación para jugadores y constructores de decks
│   └── app_table/           # Terminal de arbitraje y mesa de combate
├── packages/
│   ├── bey_catalog/         # Base de datos de piezas y motor de compatibilidad
│   ├── bey_data/            # Base de datos Drift (SQLite) y sincronización Outbox
│   ├── bey_domain/          # Modelos de dominio puros y servicios de reglas
│   ├── bey_hub/             # Puente de comunicación y sincronización local
│   ├── bey_tournament/      # Algoritmos de brackets, emparejamientos y diplomas PDF
│   └── bey_ui/              # Sistema de diseño y componentes visuales reutilizables
├── assets/
│   └── data/
│       └── beyblade_x_parts.json  # Catálogo oficial de piezas y reglas v12
├── docs/                    # Documentación técnica, mockups y diagramas
├── melos.yaml               # Configuración del monorepo con Melos
└── pubspec.yaml             # Configuración de Dart Workspace raíz
```

---

## 📄 Licencia

Este proyecto está distribuido bajo la licencia MIT. Consulta el archivo [LICENSE](LICENSE) para más información.
