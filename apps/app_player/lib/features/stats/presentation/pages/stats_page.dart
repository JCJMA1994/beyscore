import 'package:bey_domain/bey_domain.dart';
import 'package:bey_ui/bey_ui.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> with SingleTickerProviderStateMixin {
  final _battleRepo = getIt<BattleRepository>();
  final _identityRepo = getIt<IdentityRepository>();
  final _scoringService = getIt<ScoringService>();
  static const _analyticsService = MetaAnalyticsService();

  late final TabController _tabController;
  String _currentBlader = 'BLADER';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUser();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final profile = await _identityRepo.getActiveProfile();
    if (profile != null && mounted) {
      setState(() {
        _currentBlader = profile.nickname.toUpperCase();
      });
    }
  }

  final _tournamentRepo = getIt<TournamentRepository>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.void_,
      appBar: AppBar(
        backgroundColor: AppColors.steel,
        title: Text(
          'ESTADÍSTICAS & META TRACKER',
          style: AppTypography.mono.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.x,
          labelColor: AppColors.x,
          unselectedLabelColor: AppColors.mute,
          labelStyle: AppTypography.mono.copyWith(fontSize: 11, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'MIS ESTADÍSTICAS'),
            Tab(text: 'META & ARQUETIPOS'),
          ],
        ),
      ),
      body: StreamBuilder<List<Match>>(
        stream: _battleRepo.watchAllMatches(),
        builder: (context, matchSnapshot) {
          return StreamBuilder<List<Tournament>>(
            stream: _tournamentRepo.watchAll(),
            builder: (context, tourneySnapshot) {
              if (matchSnapshot.connectionState == ConnectionState.waiting && tourneySnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.x));
              }

              final matches = matchSnapshot.data ?? [];
              final tournaments = tourneySnapshot.data ?? [];

              return TabBarView(
                controller: _tabController,
                children: [
                  _buildPersonalStatsTab(matches, tournaments),
                  _buildMetaTrackerTab(matches),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPersonalStatsTab(List<Match> matches, List<Tournament> tournaments) {
    var spinCount = 0;
    var overCount = 0;
    var burstCount = 0;
    var xtremeCount = 0;
    var wins = 0;

    // Filter tournaments where the blader participated
    final myTournaments = tournaments.where((t) => t.participants.any((p) => p.toUpperCase() == _currentBlader)).toList();
    final championships = tournaments.where((t) => t.championName != null && t.championName!.toUpperCase() == _currentBlader).length;

    for (final m in matches) {
      final score = _scoringService.scoreOf(m);
      final winner = score.playerAPoints > score.playerBPoints ? m.playerAId : m.playerBId;
      if (winner == _currentBlader) {
        wins++;
      }

      for (final f in m.finishes) {
        if (f.isVoid) continue;
        switch (f.type) {
          case FinishType.spin:
            spinCount++;
          case FinishType.over:
            overCount++;
          case FinishType.burst:
            burstCount++;
          case FinishType.xtreme:
            xtremeCount++;
          case FinishType.penalty:
            break;
        }
      }
    }

    final totalMatches = matches.length;
    final winRate = totalMatches > 0 ? ((wins / totalMatches) * 100).toStringAsFixed(1) : '0.0';
    final totalFinishes = spinCount + overCount + burstCount + xtremeCount;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _metricCard('COMBATES', '$totalMatches', AppColors.x)),
              const SizedBox(width: 8),
              Expanded(child: _metricCard('VICTORIAS', '$wins', AppColors.dragoon)),
              const SizedBox(width: 8),
              Expanded(child: _metricCard('WIN RATE', '$winRate%', AppColors.pegasus)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _metricCard('TORNEOS', '${myTournaments.length}', AppColors.burst)),
              const SizedBox(width: 8),
              Expanded(child: _metricCard('CAMPEÓN', '$championships', AppColors.x)),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'DESGLOSE DE ACABADOS (TOTAL: $totalFinishes)',
            style: AppTypography.mono.copyWith(
              fontSize: 11,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
              color: AppColors.mute,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.panel,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              children: [
                StatBar(
                  label: 'Spin Finish (+1 pt) · $spinCount',
                  value: totalFinishes > 0 ? ((spinCount / totalFinishes) * 100).round() : 0,
                  maxValue: 100,
                  color: AppColors.panel2,
                ),
                const SizedBox(height: 10),
                StatBar(
                  label: 'Over Finish (+2 pts) · $overCount',
                  value: totalFinishes > 0 ? ((overCount / totalFinishes) * 100).round() : 0,
                  maxValue: 100,
                  color: AppColors.pegasus,
                ),
                const SizedBox(height: 10),
                StatBar(
                  label: 'Burst Finish (+2 pts) · $burstCount',
                  value: totalFinishes > 0 ? ((burstCount / totalFinishes) * 100).round() : 0,
                  maxValue: 100,
                  color: AppColors.burst,
                ),
                const SizedBox(height: 10),
                StatBar(
                  label: 'Xtreme Finish (+3 pts) · $xtremeCount',
                  value: totalFinishes > 0 ? ((xtremeCount / totalFinishes) * 100).round() : 0,
                  maxValue: 100,
                  color: AppColors.x,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'HISTORIAL DE BATALLAS RECIENTES',
            style: AppTypography.mono.copyWith(
              fontSize: 11,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
              color: AppColors.mute,
            ),
          ),
          const SizedBox(height: 12),
          if (matches.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.panel,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.line),
              ),
              child: const Center(
                child: Text(
                  'Aún no has registrado combates en tu historial.',
                  style: TextStyle(color: AppColors.mute, fontSize: 12.5),
                ),
              ),
            )
          else
            ...matches.map((m) {
              final score = _scoringService.scoreOf(m);
              final isPlayerAWinner = score.playerAPoints >= score.playerBPoints;

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
                    Icon(
                      Icons.flash_on_rounded,
                      color: isPlayerAWinner ? AppColors.dragoon : AppColors.dranzer,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${m.playerAId} vs ${m.playerBId}',
                            style: AppTypography.mono.copyWith(fontWeight: FontWeight.bold, fontSize: 12.5),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${m.format.name.toUpperCase()} · ${m.finishes.where((f) => !f.isVoid).length} acabados registrados',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.mute, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.steel,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${score.playerAPoints} — ${score.playerBPoints}',
                        style: AppTypography.mono.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildMetaTrackerTab(List<Match> matches) {
    final archetypes = _analyticsService.calculateArchetypeStats(
      matches: matches,
      playerArchetypes: const {},
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Archetype Power Distribution
          Text(
            'RENDIMIENTO DE ARQUETIPOS DE COMBATE',
            style: AppTypography.mono.copyWith(
              fontSize: 11,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
              color: AppColors.mute,
            ),
          ),
          const SizedBox(height: 12),
          ...archetypes.map((arch) {
            final rate = (arch.winRate * 100).toStringAsFixed(1);
            final color = switch (arch.archetype) {
              'Ataque' => AppColors.dranzer,
              'Defensa' => AppColors.dragoon,
              'Resistencia' => AppColors.pegasus,
              _ => AppColors.x,
            };

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.panel,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: color.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      arch.archetype.toUpperCase(),
                      style: AppTypography.displayMedium.copyWith(fontSize: 14, color: color),
                    ),
                  ),
                  Text(
                    '${arch.wins}V / ${arch.losses}D',
                    style: AppTypography.mono.copyWith(fontSize: 11, color: AppColors.mute),
                  ),
                  const SizedBox(width: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                    child: Text(
                      '$rate% WIN',
                      style: AppTypography.mono.copyWith(fontSize: 11, fontWeight: FontWeight.bold, color: color),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 24),

          // Meta Rules Note
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.panel2,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              children: [
                const Icon(Icons.insights, color: AppColors.x, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Las estadísticas del Meta Tracker se calculan en tiempo real a partir de los finishes validados en torneos y combates individuales.',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.mute, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard(String label, String val, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          Text(
            val,
            style: AppTypography.displayMedium.copyWith(fontSize: 20, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.mono.copyWith(fontSize: 8.5, color: AppColors.mute, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
