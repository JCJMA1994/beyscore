import 'package:bey_domain/bey_domain.dart';
import 'package:bey_ui/bey_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';

class HomeDashboardPage extends StatefulWidget {
  const HomeDashboardPage({super.key});

  @override
  State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> {
  final _identityRepo = getIt<IdentityRepository>();
  final _comboRepo = getIt<ComboRepository>();
  final _battleRepo = getIt<BattleRepository>();
  final _scoringService = getIt<ScoringService>();

  UserProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _identityRepo.getActiveProfile();
    if (mounted) {
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.void_,
        body: Center(child: CircularProgressIndicator(color: AppColors.x)),
      );
    }

    final nickname = _profile?.nickname ?? 'BLADER';

    return Scaffold(
      backgroundColor: AppColors.void_,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.panel,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.line),
                gradient: LinearGradient(
                  colors: [
                    AppColors.panel,
                    AppColors.dragoon.withValues(alpha: 0.12),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '¡HOLA, $nickname!',
                        style: AppTypography.displayMedium.copyWith(fontSize: 22),
                      ),
                      const BeyBadge(label: 'BLADER OFICIAL', color: AppColors.dragoon),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sistema de combate físico offline-first para Beyblade X.',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.mute),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ChamferButton(
                          text: 'COMBATE 1V1',
                          variant: ChamferButtonVariant.go,
                          onPressed: () => context.push('/battle'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ChamferButton(
                          text: 'NUEVO COMBO',
                          variant: ChamferButtonVariant.ghost,
                          onPressed: () => context.push('/combos/new'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick Hub Navigation Cards
            Text(
              'MÓDULOS DEL SISTEMA',
              style: AppTypography.mono.copyWith(
                fontSize: 11,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
                color: AppColors.mute,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    title: 'CATÁLOGO',
                    subtitle: '239 piezas oficiales',
                    icon: Icons.grid_view_rounded,
                    color: AppColors.x,
                    onTap: () => context.push('/catalog'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    title: 'DECKS 3ON3',
                    subtitle: 'Validador oficial V12',
                    icon: Icons.layers_rounded,
                    color: AppColors.dragoon,
                    onTap: () => context.push('/decks'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    title: 'RANKINGS',
                    subtitle: 'Meta WBO & Tiers',
                    icon: Icons.leaderboard_rounded,
                    color: const Color(0xFFFFD700),
                    onTap: () => context.push('/rankings'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Real-time Combos Stream Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ARSENAL DE COMBOS',
                  style: AppTypography.mono.copyWith(
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.mute,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/combos'),
                  child: Text(
                    'VER TODOS',
                    style: AppTypography.mono.copyWith(
                      fontSize: 11,
                      color: AppColors.x,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            StreamBuilder<List<Combo>>(
              stream: _comboRepo.watchAll(),
              builder: (context, snapshot) {
                final combos = snapshot.data ?? [];

                if (combos.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.panel,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.tune, color: AppColors.mute, size: 36),
                        const SizedBox(height: 10),
                        const Text(
                          'Aún no tienes combos en tu arsenal',
                          style: TextStyle(color: AppColors.mute, fontSize: 12.5),
                        ),
                        const SizedBox(height: 12),
                        ChamferButton(
                          text: 'Armar mi primer combo',
                          variant: ChamferButtonVariant.ghost,
                          onPressed: () => context.push('/combos/new'),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: combos.take(3).map((c) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.panel,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.blur_on, color: AppColors.x, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.name.toUpperCase(),
                                  style: AppTypography.mono.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  '${c.bladeId} · ${c.ratchetId} · ${c.bitId}',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.mute,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (c.calculatedWeight != null)
                            Text(
                              '${c.calculatedWeight}g',
                              style: AppTypography.mono.copyWith(
                                fontSize: 11,
                                color: AppColors.x,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 24),

            // Live Match History Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'HISTORIAL RECIENTE',
                  style: AppTypography.mono.copyWith(
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.mute,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/stats'),
                  child: Text(
                    'ESTADÍSTICAS',
                    style: AppTypography.mono.copyWith(
                      fontSize: 11,
                      color: AppColors.pegasus,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            StreamBuilder<List<Match>>(
              stream: _battleRepo.watchAllMatches(),
              builder: (context, snapshot) {
                final matches = snapshot.data ?? [];

                if (matches.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.panel,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: const Center(
                      child: Text(
                        'Sin batallas registradas. ¡Inicia un combate 1v1!',
                        style: TextStyle(color: AppColors.mute, fontSize: 12.5),
                      ),
                    ),
                  );
                }

                final recent = matches.take(3);
                return Column(
                  children: recent.map((m) {
                    final score = _scoringService.scoreOf(m);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.panel,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.flash_on_rounded, color: AppColors.dragoon, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${m.playerAId} vs ${m.playerBId}',
                              style: AppTypography.mono.copyWith(fontWeight: FontWeight.bold, fontSize: 12.5),
                            ),
                          ),
                          Text(
                            '${score.playerAPoints} — ${score.playerBPoints}',
                            style: AppTypography.mono.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.x,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTypography.mono.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTypography.bodySmall.copyWith(
                fontSize: 10.5,
                color: AppColors.mute,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
