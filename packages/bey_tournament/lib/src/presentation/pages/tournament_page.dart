import 'package:bey_domain/bey_domain.dart';
import 'package:bey_ui/bey_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/tournament_bloc.dart';
import 'tournament_bracket_page.dart';
import 'tournament_create_page.dart';

class TournamentPage extends StatelessWidget {
  const TournamentPage({
    super.key,
    this.onLaunchBattle,
    this.onOpenHub,
  });

  final void Function(BuildContext context, Matchup matchup)? onLaunchBattle;
  final void Function(BuildContext context, Tournament tournament)? onOpenHub;

  @override
  Widget build(BuildContext context) {
    return _TournamentView(
      onLaunchBattle: onLaunchBattle,
      onOpenHub: onOpenHub,
    );
  }
}

class _TournamentView extends StatelessWidget {
  const _TournamentView({
    this.onLaunchBattle,
    this.onOpenHub,
  });

  final void Function(BuildContext context, Matchup matchup)? onLaunchBattle;
  final void Function(BuildContext context, Tournament tournament)? onOpenHub;

  Future<void> _openCreatePage(BuildContext context) async {
    final tournament = await Navigator.of(context).push<Tournament>(
      MaterialPageRoute(
        builder: (_) => const TournamentCreatePage(),
      ),
    );

    if (tournament != null && context.mounted) {
      final bloc = context.read<TournamentBloc>()..add(TournamentCreated(tournament));

      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: bloc,
            child: TournamentBracketPage(
              tournamentId: tournament.id,
              onLaunchBattle: onLaunchBattle,
              onOpenHub: onOpenHub,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TournamentBloc, TournamentState>(
      builder: (context, state) {
        final tournaments = state is TournamentLoaded ? state.tournaments : <Tournament>[];

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Organize Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TORNEOS Y LLAVES',
                    style: AppTypography.displaySmall.copyWith(
                      color: AppColors.text,
                      fontSize: 20,
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => _openCreatePage(context),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('ORGANIZAR'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF00FF66),
                      foregroundColor: Colors.black,
                      textStyle: AppTypography.mono.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Official Tiers Guide
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.steel,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined, size: 16, color: AppColors.pegasus),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Categorías oficiales: G3 Local • G2 Regional • G1 Nacional • GP Mundial',
                        style: AppTypography.mono.copyWith(fontSize: 10, color: AppColors.mute),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // List of Tournaments or Empty State
              Expanded(
                child: tournaments.isEmpty
                    ? Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.panel,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.line),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.emoji_events_outlined, size: 48, color: AppColors.mute),
                              const SizedBox(height: 12),
                              Text(
                                'No hay torneos activos',
                                style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Crea una competencia con sorteo determinista, mesas de combate y avance automático de llaves.',
                                textAlign: TextAlign.center,
                                style: AppTypography.bodyMedium.copyWith(color: AppColors.mute),
                              ),
                              const SizedBox(height: 16),
                              FilledButton.icon(
                                onPressed: () => _openCreatePage(context),
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text('CREAR PRIMER TORNEO'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.pegasus,
                                  foregroundColor: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: tournaments.length,
                        itemBuilder: (context, index) {
                          final t = tournaments[index];
                          final tierColor = Color(t.tier.colorValue);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: AppColors.panel,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.line),
                            ),
                            child: InkWell(
                              onTap: () {
                                final bloc = context.read<TournamentBloc>();
                                Navigator.of(context).push<void>(
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider.value(
                                      value: bloc,
                                      child: TournamentBracketPage(
                                        tournamentId: t.id,
                                        onLaunchBattle: onLaunchBattle,
                                        onOpenHub: onOpenHub,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Tier Tag
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: tierColor.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: tierColor),
                                          ),
                                          child: Text(
                                            t.tier.label,
                                            style: AppTypography.mono.copyWith(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: tierColor,
                                            ),
                                          ),
                                        ),

                                        // Status Tag & Delete Menu
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppColors.steel,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                t.status.label.toUpperCase(),
                                                style: AppTypography.mono.copyWith(
                                                  fontSize: 9,
                                                  color: t.status == TournamentStatus.completed
                                                      ? const Color(0xFF00FF66)
                                                      : AppColors.mute,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.mute),
                                              onPressed: () {
                                                context.read<TournamentBloc>().add(TournamentDeleted(t.id));
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    // Tournament Name
                                    Text(
                                      t.name,
                                      style: AppTypography.bodyLarge.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.text,
                                      ),
                                    ),
                                    const SizedBox(height: 6),

                                    // Info row
                                    Row(
                                      children: [
                                        const Icon(Icons.people, size: 14, color: AppColors.mute),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${t.participants.length} Bladers',
                                          style: AppTypography.mono.copyWith(fontSize: 10, color: AppColors.mute),
                                        ),
                                        const SizedBox(width: 12),
                                        const Icon(Icons.shuffle, size: 14, color: AppColors.mute),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Seed #${t.seed ?? 0}',
                                          style: AppTypography.mono.copyWith(fontSize: 10, color: AppColors.mute),
                                        ),
                                        if (t.championName != null) ...[
                                          const SizedBox(width: 12),
                                          const Icon(Icons.emoji_events, size: 14, color: Color(0xFFFFCC00)),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Campeón: ${t.championName}',
                                            style: AppTypography.mono.copyWith(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFFFFCC00),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
