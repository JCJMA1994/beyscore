import 'package:bey_domain/bey_domain.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/part_image.dart';

/// Meta Rankings & Tier List Page displaying official WBO tournament statistics.
class MetaRankingsPage extends StatefulWidget {
  const MetaRankingsPage({
    super.key,
    required this.topCombos,
    required this.blades,
    required this.ratchets,
    required this.bits,
    this.onSelectCombo,
  });

  final List<MetaCombo> topCombos;
  final List<MetaPieceRanking> blades;
  final List<MetaPieceRanking> ratchets;
  final List<MetaPieceRanking> bits;
  final void Function(MetaCombo combo)? onSelectCombo;

  @override
  State<MetaRankingsPage> createState() => _MetaRankingsPageState();
}

class _MetaRankingsPageState extends State<MetaRankingsPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String _pieceFilter = 'blades';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.void_,
      appBar: AppBar(
        backgroundColor: AppColors.steel,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RANKINGS & META WBO',
              style: AppTypography.mono.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: AppColors.text,
              ),
            ),
            Text(
              'TEMPORADA OFICIAL 2026',
              style: AppTypography.mono.copyWith(
                fontSize: 9,
                color: const Color(0xFF00E5D0),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.x,
          indicatorWeight: 3,
          labelColor: AppColors.x,
          unselectedLabelColor: AppColors.mute,
          labelStyle: AppTypography.mono.copyWith(fontSize: 11, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'TOP COMBOS'),
            Tab(text: 'TIER LIST'),
            Tab(text: 'USO EN PODIO'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTopCombosTab(),
          _buildTierListTab(),
          _buildUsageRankingTab(),
        ],
      ),
    );
  }

  Widget _buildTopCombosTab() {
    if (widget.topCombos.isEmpty) {
      return Center(
        child: Text(
          'No hay datos de combos disponibles.',
          style: AppTypography.mono.copyWith(color: AppColors.mute),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.topCombos.length,
      itemBuilder: (context, index) {
        final combo = widget.topCombos[index];
        final rank = combo.rank;
        final rankColor = switch (rank) {
          1 => const Color(0xFFFFD700),
          2 => const Color(0xFFC0C0C0),
          3 => const Color(0xFFCD7F32),
          _ => const Color(0xFF64748B),
        };

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF111422),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: rank == 1 ? const Color(0xFFF59E0B) : const Color(0xFF232A42),
              width: rank == 1 ? 1.5 : 1,
            ),
            boxShadow: rank == 1
                ? [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                      blurRadius: 10,
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Rank Badge
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: rankColor.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: rankColor),
                      ),
                      child: Center(
                        child: Text(
                          '#$rank',
                          style: AppTypography.mono.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: rankColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Blade Image Thumbnail
                    PartImage(
                      type: PartType.blade,
                      imageRemote: combo.bladeImage,
                      imageLocal: combo.bladeImageLocal,
                      size: 44,
                      color: rankColor,
                    ),
                    const SizedBox(width: 10),

                    // Combo Name & Type
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            combo.name.toUpperCase(),
                            style: AppTypography.displaySmall.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${combo.blade} · ${combo.ratchet} · ${combo.bit}',
                            style: AppTypography.mono.copyWith(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF00E5D0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Tier Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFFF59E0B)),
                      ),
                      child: Text(
                        '${combo.tier} TIER',
                        style: AppTypography.mono.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFFFD96B),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Metrics Row
                Row(
                  children: [
                    _buildMetricChip(
                      label: 'WIN RATE',
                      value: '${combo.winrate}%',
                      color: const Color(0xFF10B981),
                    ),
                    const SizedBox(width: 8),
                    _buildMetricChip(
                      label: 'PUNTOS WBO',
                      value: '${combo.totalPoints}',
                      color: const Color(0xFF38BDF8),
                    ),
                    const SizedBox(width: 8),
                    _buildMetricChip(
                      label: '1° PUESTOS',
                      value: '${combo.firstPlaces} 🥇',
                      color: const Color(0xFFF59E0B),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Tactical Description
                Text(
                  combo.description,
                  style: AppTypography.bodySmall.copyWith(
                    color: const Color(0xFF94A3B8),
                    height: 1.35,
                  ),
                ),

                if (widget.onSelectCombo != null) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => widget.onSelectCombo!(combo),
                      icon: const Icon(Icons.tune, size: 14, color: AppColors.x),
                      label: Text(
                        'ARMAR EN BUILDER',
                        style: AppTypography.mono.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.x,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricChip({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0D18),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFF1E263C)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: AppTypography.mono.copyWith(
                fontSize: 8,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: AppTypography.mono.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTierListTab() {
    return Column(
      children: [
        // Filter Selector (Blades / Ratchets / Bits)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: AppColors.steel,
          child: Row(
            children: [
              _buildFilterChip('Blades', 'blades'),
              const SizedBox(width: 8),
              _buildFilterChip('Ratchets', 'ratchets'),
              const SizedBox(width: 8),
              _buildFilterChip('Bits', 'bits'),
            ],
          ),
        ),

        Expanded(
          child: Builder(
            builder: (context) {
              final list = switch (_pieceFilter) {
                'ratchets' => widget.ratchets,
                'bits' => widget.bits,
                _ => widget.blades,
              };

              final tierGroups = <String, List<MetaPieceRanking>>{};
              for (final p in list) {
                tierGroups.putIfAbsent(p.tier, () => []).add(p);
              }

              final tierOrder = ['S+', 'S', 'A+', 'A', 'B+', 'B', 'C'];

              return ListView(
                padding: const EdgeInsets.all(16),
                children: tierOrder.where(tierGroups.containsKey).map((tier) {
                  final pieces = tierGroups[tier]!;
                  final tierColor = switch (tier) {
                    'S+' => const Color(0xFFFFD700),
                    'S' => const Color(0xFFF59E0B),
                    'A+' => const Color(0xFF10B981),
                    'A' => const Color(0xFF06B6D4),
                    'B+' => const Color(0xFF8B5CF6),
                    _ => const Color(0xFF64748B),
                  };

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111422),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF232A42)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tier Header Bar
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: tierColor.withValues(alpha: 0.15),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
                            border: Border(bottom: BorderSide(color: tierColor.withValues(alpha: 0.4))),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '$tier TIER',
                                style: AppTypography.mono.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: tierColor,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${pieces.length} piezas',
                                style: AppTypography.mono.copyWith(
                                  fontSize: 10,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Pieces Grid / List
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: pieces.map((p) {
                              final pType = switch (_pieceFilter) {
                                'ratchets' => PartType.ratchet,
                                'bits' => PartType.bit,
                                _ => PartType.blade,
                              };

                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0A0C14),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFF1E263C)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    PartImage(
                                      type: pType,
                                      imageRemote: p.imageRemote,
                                      imageLocal: p.imageLocal,
                                      size: 26,
                                      showBorder: false,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      p.name,
                                      style: AppTypography.mono.copyWith(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    _buildTrendIcon(p.trend),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUsageRankingTab() {
    final list = switch (_pieceFilter) {
      'ratchets' => widget.ratchets,
      'bits' => widget.bits,
      _ => widget.blades,
    };

    final pType = switch (_pieceFilter) {
      'ratchets' => PartType.ratchet,
      'bits' => PartType.bit,
      _ => PartType.blade,
    };

    return Column(
      children: [
        // Filter Selector
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: AppColors.steel,
          child: Row(
            children: [
              _buildFilterChip('Blades', 'blades'),
              const SizedBox(width: 8),
              _buildFilterChip('Ratchets', 'ratchets'),
              const SizedBox(width: 8),
              _buildFilterChip('Bits', 'bits'),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final piece = list[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF111422),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF1F263B)),
                ),
                child: Row(
                  children: [
                    // Rank
                    SizedBox(
                      width: 24,
                      child: Text(
                        '#${piece.rank}',
                        style: AppTypography.mono.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Piece Thumbnail Image
                    PartImage(
                      type: pType,
                      imageRemote: piece.imageRemote,
                      imageLocal: piece.imageLocal,
                      size: 30,
                      showBorder: false,
                    ),
                    const SizedBox(width: 8),
                    // Piece Name
                    Expanded(
                      flex: 3,
                      child: Text(
                        piece.name,
                        style: AppTypography.mono.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Progress Bar
                    Expanded(
                      flex: 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: (piece.score / 100).clamp(0.05, 1.0),
                          backgroundColor: const Color(0xFF1E263C),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            piece.score >= 80
                                ? const Color(0xFFFFD700)
                                : (piece.score >= 50 ? const Color(0xFF00E5D0) : const Color(0xFF64748B)),
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Score
                    SizedBox(
                      width: 28,
                      child: Text(
                        '${piece.score}',
                        textAlign: TextAlign.end,
                        style: AppTypography.mono.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    _buildTrendIcon(piece.trend),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String key) {
    final isSelected = _pieceFilter == key;
    return InkWell(
      onTap: () => setState(() => _pieceFilter = key),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.x.withValues(alpha: 0.2) : AppColors.panel,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: isSelected ? AppColors.x : AppColors.line),
        ),
        child: Text(
          label.toUpperCase(),
          style: AppTypography.mono.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isSelected ? AppColors.x : AppColors.mute,
          ),
        ),
      ),
    );
  }

  Widget _buildTrendIcon(String trend) {
    return switch (trend) {
      'up' => const Icon(Icons.arrow_upward, size: 12, color: Color(0xFF10B981)),
      'down' => const Icon(Icons.arrow_downward, size: 12, color: Color(0xFFEF4444)),
      _ => const Icon(Icons.remove, size: 12, color: Color(0xFF64748B)),
    };
  }
}
