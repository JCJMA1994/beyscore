-- ==============================================================================
-- BeyScore — Esquema Oficial de Base de Datos para Supabase (PostgreSQL)
-- Versión: 3.0 (Tipado Robusto TEXT para Compatibilidad Total con Drift/UUIDs)
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. TABLA: profiles (Identidad Anónima & Hash de Recuperación)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.profiles (
    id TEXT PRIMARY KEY,
    nickname TEXT NOT NULL,
    recovery_code_hash TEXT,
    avatar_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "profiles_select_policy" ON public.profiles;
CREATE POLICY "profiles_select_policy" ON public.profiles FOR SELECT USING (true);

DROP POLICY IF EXISTS "profiles_all_policy" ON public.profiles;
CREATE POLICY "profiles_all_policy" ON public.profiles FOR ALL USING (true) WITH CHECK (true);

-- ------------------------------------------------------------------------------
-- 2. TABLA: combos (Taller de Ensamblaje)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.combos (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    name TEXT NOT NULL,
    blade_id TEXT NOT NULL,
    ratchet_id TEXT NOT NULL,
    bit_id TEXT NOT NULL,
    lock_chip_id TEXT,
    assist_blade_id TEXT,
    system INT NOT NULL DEFAULT 0, -- 0: BX, 1: UX, 2: CX
    calculated_weight NUMERIC(5,2),
    is_favorite BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.combos ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "combos_select_policy" ON public.combos;
CREATE POLICY "combos_select_policy" ON public.combos FOR SELECT USING (true);

DROP POLICY IF EXISTS "combos_all_policy" ON public.combos;
CREATE POLICY "combos_all_policy" ON public.combos FOR ALL USING (true) WITH CHECK (true);

-- ------------------------------------------------------------------------------
-- 3. TABLA: decks (Mazos 3on3 Competitivos)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.decks (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    name TEXT NOT NULL,
    combo_ids JSONB NOT NULL DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.decks ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "decks_select_policy" ON public.decks;
CREATE POLICY "decks_select_policy" ON public.decks FOR SELECT USING (true);

DROP POLICY IF EXISTS "decks_all_policy" ON public.decks;
CREATE POLICY "decks_all_policy" ON public.decks FOR ALL USING (true) WITH CHECK (true);

-- ------------------------------------------------------------------------------
-- 4. TABLA: user_inventory (Inventario Físico de Piezas Reales)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.user_inventory (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    part_id TEXT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    is_owned BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (user_id, part_id)
);

ALTER TABLE public.user_inventory ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "user_inventory_all_policy" ON public.user_inventory;
CREATE POLICY "user_inventory_all_policy" ON public.user_inventory FOR ALL USING (true) WITH CHECK (true);

-- ------------------------------------------------------------------------------
-- 5. TABLA: spin_benchmarks (Pruebas de Giro & Récords de Resistencia)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.spin_benchmarks (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    combo_name TEXT NOT NULL,
    blade_id TEXT,
    ratchet_id TEXT,
    bit_id TEXT,
    duration_ms INT NOT NULL,
    launcher_type TEXT NOT NULL DEFAULT 'Winder Launcher',
    recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.spin_benchmarks ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "spin_benchmarks_all_policy" ON public.spin_benchmarks;
CREATE POLICY "spin_benchmarks_all_policy" ON public.spin_benchmarks FOR ALL USING (true) WITH CHECK (true);

-- ------------------------------------------------------------------------------
-- 6. TABLA: tournament_trophies (Palmarés y Podios Oficiales)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.tournament_trophies (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    tournament_name TEXT NOT NULL,
    tier TEXT NOT NULL DEFAULT 'G3',
    rank_position INT NOT NULL,
    total_participants INT NOT NULL DEFAULT 0,
    awarded_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.tournament_trophies ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "tournament_trophies_all_policy" ON public.tournament_trophies;
CREATE POLICY "tournament_trophies_all_policy" ON public.tournament_trophies FOR ALL USING (true) WITH CHECK (true);

-- ------------------------------------------------------------------------------
-- 7. TABLA: player_rivalries (Historial Head-to-Head Sincronizado)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.player_rivalries (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    opponent_nickname TEXT NOT NULL,
    total_matches INT NOT NULL DEFAULT 0,
    wins INT NOT NULL DEFAULT 0,
    losses INT NOT NULL DEFAULT 0,
    last_winner TEXT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (user_id, opponent_nickname)
);

ALTER TABLE public.player_rivalries ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "player_rivalries_all_policy" ON public.player_rivalries;
CREATE POLICY "player_rivalries_all_policy" ON public.player_rivalries FOR ALL USING (true) WITH CHECK (true);

-- ------------------------------------------------------------------------------
-- 8. TABLA: player_preferences (Ajustes de Sonido, Mano y Experiencia)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.player_preferences (
    user_id TEXT PRIMARY KEY,
    announcer_language TEXT NOT NULL DEFAULT 'official',
    audio_enabled BOOLEAN NOT NULL DEFAULT true,
    haptics_enabled BOOLEAN NOT NULL DEFAULT true,
    preferred_handedness TEXT NOT NULL DEFAULT 'RIGHT',
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.player_preferences ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "player_preferences_all_policy" ON public.player_preferences;
CREATE POLICY "player_preferences_all_policy" ON public.player_preferences FOR ALL USING (true) WITH CHECK (true);

-- ------------------------------------------------------------------------------
-- 9. TABLA: tournaments (Organizador)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.tournaments (
    id TEXT PRIMARY KEY,
    organizer_id TEXT NOT NULL,
    code TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    tier TEXT NOT NULL DEFAULT 'G3',
    age_division TEXT NOT NULL DEFAULT 'OPEN',
    status TEXT NOT NULL DEFAULT 'IN_PROGRESS',
    seed INT NOT NULL DEFAULT 0,
    rounds JSONB NOT NULL DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.tournaments ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "tournaments_all_policy" ON public.tournaments;
CREATE POLICY "tournaments_all_policy" ON public.tournaments FOR ALL USING (true) WITH CHECK (true);

-- ------------------------------------------------------------------------------
-- 10. TABLA: tournament_participants
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.tournament_participants (
    id TEXT PRIMARY KEY,
    tournament_id TEXT NOT NULL,
    user_id TEXT NOT NULL,
    deck_id TEXT,
    nickname TEXT NOT NULL,
    seed_position INT,
    joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (tournament_id, user_id)
);

ALTER TABLE public.tournament_participants ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "tournament_participants_all_policy" ON public.tournament_participants;
CREATE POLICY "tournament_participants_all_policy" ON public.tournament_participants FOR ALL USING (true) WITH CHECK (true);

-- Habilitar Realtime
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' 
          AND schemaname = 'public' 
          AND tablename = 'tournaments'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.tournaments;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' 
          AND schemaname = 'public' 
          AND tablename = 'tournament_participants'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.tournament_participants;
    END IF;
END $$;
