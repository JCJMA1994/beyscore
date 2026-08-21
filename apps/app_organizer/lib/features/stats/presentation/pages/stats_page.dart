import 'package:bey_domain/bey_domain.dart';
import 'package:bey_ui/bey_ui.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final _battleRepo = getIt<BattleRepository>();
  final _identityRepo = getIt<IdentityRepository>();
  final _scoringService = getIt<ScoringService>();

  String _currentBlader = 'BLADER';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final profile = await _identityRepo.getActiveProfile();
    if (profile != null && mounted) {
      setState(() {
        _currentBlader = profile.nickname.toUpperCase();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.void_,
      appBar: AppBar(
        backgroundColor: AppColors.steel,
        title: Text(
          'HISTORIAL & ESTADÍSTICAS',
          style: AppTypography.mono.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<Match>>(
        stream: _battleRepo.watchAllMatches(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.x));
          }

          final matches = snapshot.data ?? [];

          // Compute Stats
          var spinCount = 0;
          var overCount = 0;
          var burstCount = 0;
          var xtremeCount = 0;
          var wins = 0;

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
                // Quick Metrics Row
                Row(
                  children: [
                    Expanded(child: _metricCard('COMBATES', '$totalMatches', AppColors.x)),
                    const SizedBox(width: 10),
                    Expanded(child: _metricCard('VICTORIAS', '$wins', AppColors.dragoon)),
                    const SizedBox(width: 10),
                    Expanded(child: _metricCard('WIN RATE', '$winRate%', AppColors.pegasus)),
                  ],
                ),

                const SizedBox(height: 24),

                // Finish Breakdown Section
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

                // Match History List
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
        },
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
