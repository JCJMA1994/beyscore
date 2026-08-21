import 'package:bey_domain/bey_domain.dart';
import 'package:bey_ui/bey_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/tournament_bloc.dart';
import '../../services/diploma_pdf_service.dart';

class TournamentBracketPage extends StatefulWidget {
  const TournamentBracketPage({
    super.key,
    required this.tournamentId,
    this.onLaunchBattle,
    this.onOpenHub,
  });

  final String tournamentId;
  final void Function(BuildContext context, Matchup matchup)? onLaunchBattle;
  final void Function(BuildContext context, Tournament tournament)? onOpenHub;

  @override
  State<TournamentBracketPage> createState() => _TournamentBracketPageState();
}

class _TournamentBracketPageState extends State<TournamentBracketPage> {
  int _selectedRoundIndex = 0;

  void _showStartMatchDialog({
    required BuildContext context,
    required String tournamentId,
    required int roundIndex,
    required int matchupIndex,
    required Matchup matchup,
  }) {
    final playerA = matchup.playerAName;
    final playerB = matchup.playerBName ?? '';

    if (!matchup.isReadyToCall) {
      BeyFeedbackDialog.showWarning(
        context,
        title: 'Combate No Listo',
        message: 'Este enfrentamiento aún no cuenta con ambos combatientes definidos.',
        solution: 'Debes completar y registrar los resultados de los matches de la ronda anterior para que clasifiquen a esta llave.',
        cancelText: null,
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.void_,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.line),
          ),
          title: Row(
            children: [
              const Icon(Icons.campaign, color: AppColors.pegasus, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'LLAMAR A ESTADIO (MESA #${matchup.tableNumber ?? 1})',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Confirmas el llamado a la arena para este combate?',
                style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.panel,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: Text(
                        playerA,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.mono.copyWith(color: AppColors.dragoon, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text('VS', style: AppTypography.mono.copyWith(color: AppColors.mute, fontWeight: FontWeight.w900, fontSize: 12)),
                    ),
                    Expanded(
                      child: Text(
                        playerB,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.mono.copyWith(color: AppColors.dranzer, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '• El combate pasará a estado EN COMBATE.\n• Si tienes conectada la pantalla de estadio o stream, se anunciará en vivo.',
                style: AppTypography.bodySmall.copyWith(color: AppColors.mute, fontSize: 11),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('CANCELAR', style: TextStyle(color: AppColors.mute)),
            ),
            FilledButton.icon(
              onPressed: () {
                context.read<TournamentBloc>().add(
                      TournamentMatchStarted(
                        tournamentId: tournamentId,
                        roundIndex: roundIndex,
                        matchupIndex: matchupIndex,
                        tableNumber: matchup.tableNumber,
                      ),
                    );
                Navigator.of(dialogContext).pop();
              },
              icon: const Icon(Icons.sports_kabaddi, size: 16),
              label: const Text('INICIAR ENCUENTRO'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.pegasus,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showWalkoverDialog({
    required BuildContext context,
    required String tournamentId,
    required int roundIndex,
    required int matchupIndex,
    required Matchup matchup,
  }) {
    final playerA = matchup.playerAName;
    final playerB = matchup.playerBName ?? '';

    String? selectedWinner = playerA;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.void_,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.line),
              ),
              title: Row(
                children: [
                  const Icon(Icons.person_off, color: AppColors.dranzer, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'DECLARAR W.O. (NO PRESENTACIÓN)',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selecciona al Blader PRESENTE que gana la llave por incomparecencia del rival:',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.mute),
                  ),
                  const SizedBox(height: 12),
                  // Blader A Option
                  InkWell(
                    onTap: () => setDialogState(() => selectedWinner = playerA),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: selectedWinner == playerA ? AppColors.dragoon.withValues(alpha: 0.2) : AppColors.steel,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selectedWinner == playerA ? AppColors.dragoon : AppColors.line,
                          width: selectedWinner == playerA ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              playerA,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.dragoon),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (selectedWinner == playerA) const Icon(Icons.check_circle, color: AppColors.dragoon, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Blader B Option
                  InkWell(
                    onTap: () => setDialogState(() => selectedWinner = playerB),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: selectedWinner == playerB ? AppColors.dranzer.withValues(alpha: 0.2) : AppColors.steel,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selectedWinner == playerB ? AppColors.dranzer : AppColors.line,
                          width: selectedWinner == playerB ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              playerB,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.dranzer),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (selectedWinner == playerB) const Icon(Icons.check_circle, color: AppColors.dranzer, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('CANCELAR', style: TextStyle(color: AppColors.mute)),
                ),
                FilledButton(
                  onPressed: () {
                    if (selectedWinner != null) {
                      context.read<TournamentBloc>().add(
                            TournamentMatchWalkoverDeclared(
                              tournamentId: tournamentId,
                              roundIndex: roundIndex,
                              matchupIndex: matchupIndex,
                              winnerName: selectedWinner!,
                            ),
                          );
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.dranzer,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('CONFIRMAR W.O.'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showReportMatchDialog({
    required BuildContext context,
    required String tournamentId,
    required int roundIndex,
    required int matchupIndex,
    required Matchup matchup,
  }) {
    final playerA = matchup.playerAName;
    final playerB = matchup.playerBName ?? '';

    if (playerA == 'TBD' || playerB == 'TBD' || playerB.isEmpty) {
      BeyFeedbackDialog.showWarning(
        context,
        title: 'Combate No Listo',
        message: 'Este enfrentamiento aún no cuenta con ambos combatientes definidos.',
        solution: 'Debes completar y registrar los resultados de los matches de la ronda anterior para que clasifiquen a esta llave.',
        cancelText: null,
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        var scoreA = 4;
        var scoreB = 2;
        String? selectedWinner = playerA;

        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.void_,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.line),
              ),
              title: Row(
                children: [
                  const Icon(Icons.gavel, color: AppColors.pegasus, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'REPORTAR RESULTADO MESA #${matchup.tableNumber ?? 1}',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!matchup.isInProgress) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.pegasus.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.pegasus),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: AppColors.pegasus, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Este combate se finalizará directamente con este reporte.',
                              style: AppTypography.bodySmall.copyWith(fontSize: 10, color: AppColors.pegasus),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  Text(
                    'Selecciona al Blader ganador:',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.mute),
                  ),
                  const SizedBox(height: 12),

                  // Option Player A
                  InkWell(
                    onTap: () => setDialogState(() {
                      selectedWinner = playerA;
                      scoreA = 4;
                      scoreB = 2;
                    }),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: selectedWinner == playerA
                            ? AppColors.dragoon.withValues(alpha: 0.2)
                            : AppColors.steel,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selectedWinner == playerA ? AppColors.dragoon : AppColors.line,
                          width: selectedWinner == playerA ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              playerA,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.dragoon,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (selectedWinner == playerA)
                            const Icon(Icons.check_circle, color: AppColors.dragoon, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Option Player B
                  InkWell(
                    onTap: () => setDialogState(() {
                      selectedWinner = playerB;
                      scoreA = 2;
                      scoreB = 4;
                    }),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: selectedWinner == playerB
                            ? AppColors.dranzer.withValues(alpha: 0.2)
                            : AppColors.steel,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selectedWinner == playerB ? AppColors.dranzer : AppColors.line,
                          width: selectedWinner == playerB ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              playerB,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.dranzer,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (selectedWinner == playerB)
                            const Icon(Icons.check_circle, color: AppColors.dranzer, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('CANCELAR', style: TextStyle(color: AppColors.mute)),
                ),
                FilledButton(
                  onPressed: () {
                    if (selectedWinner != null) {
                      context.read<TournamentBloc>().add(
                            TournamentMatchReported(
                              tournamentId: tournamentId,
                              roundIndex: roundIndex,
                              matchupIndex: matchupIndex,
                              winnerName: selectedWinner!,
                              scoreA: scoreA,
                              scoreB: scoreB,
                            ),
                          );
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF00FF66),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('CONFIRMAR RESULTADO'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TournamentBloc, TournamentState>(
      builder: (context, state) {
        if (state is! TournamentLoaded) {
          return const Scaffold(
            backgroundColor: AppColors.void_,
            body: Center(child: CircularProgressIndicator(color: AppColors.pegasus)),
          );
        }

        final matches = state.tournaments.where((t) => t.id == widget.tournamentId);
        if (matches.isEmpty) {
          return Scaffold(
            backgroundColor: AppColors.void_,
            appBar: AppBar(
              backgroundColor: AppColors.steel,
              title: const Text('CARGANDO TORNEO...'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppColors.x),
                  const SizedBox(height: 16),
                  Text(
                    'Cargando datos del torneo...',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.mute),
                  ),
                ],
              ),
            ),
          );
        }

        final tournament = matches.first;

        final tierColor = Color(tournament.tier.colorValue);
        final rounds = tournament.rounds;
        final currentRound = rounds.isNotEmpty
            ? rounds[_selectedRoundIndex.clamp(0, rounds.length - 1)]
            : null;

        return Scaffold(
          backgroundColor: AppColors.void_,
          appBar: AppBar(
            backgroundColor: AppColors.panel,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tournament.name,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                Text(
                  '${tournament.tier.label} • ${tournament.ageDivision.label} • SEED #${tournament.seed ?? 0}',
                  style: AppTypography.mono.copyWith(fontSize: 10, color: AppColors.mute),
                ),
              ],
            ),
            actions: [
              if (widget.onOpenHub != null)
                IconButton(
                  icon: const Icon(Icons.hub_outlined, color: AppColors.x),
                  tooltip: 'Panel Organizador Hub LAN',
                  onPressed: () => widget.onOpenHub?.call(context, tournament),
                ),
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: tierColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: tierColor),
                ),
                child: Text(
                  tournament.status.label.toUpperCase(),
                  style: AppTypography.mono.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: tierColor,
                  ),
                ),
              ),
            ],
          ),

          body: Column(
            children: [
              // Complete 3-Step Podium Banner if Completed
              if (tournament.championName != null) ...[
                Builder(
                  builder: (ctx) {
                    const analytics = MetaAnalyticsService();
                    final report = analytics.generateTournamentReport(
                      tournamentName: tournament.name,
                      rounds: tournament.rounds,
                    );
                    const diplomaService = DiplomaPdfService();

                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFFCC00).withValues(alpha: 0.18),
                            AppColors.steel,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFCC00), width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.emoji_events, color: Color(0xFFFFCC00), size: 28),
                                  const SizedBox(width: 8),
                                  Text(
                                    'PODIO OFICIAL DEL TORNEO',
                                    style: AppTypography.mono.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFFFCC00),
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFFFFCC00),
                                  side: const BorderSide(color: Color(0xFFFFCC00)),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                ),
                                icon: const Icon(Icons.picture_as_pdf, size: 14),
                                label: const Text('DIPLOMAS PDF', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                onPressed: () {
                                  diplomaService.printOrShareDiploma(
                                    context: context,
                                    tournamentName: tournament.name,
                                    tierLabel: tournament.tier.label,
                                    divisionLabel: tournament.ageDivision.label,
                                    bladerName: report.firstPlace,
                                    placeTitle: '1ER LUGAR (CAMPEÓN)',
                                    placeRank: 1,
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // 1st Place Champion
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.panel,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFFFCC00)),
                            ),
                            child: Row(
                              children: [
                                const Text('🥇', style: TextStyle(fontSize: 20)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('1ER LUGAR (CAMPEÓN ORO)', style: AppTypography.mono.copyWith(fontSize: 8.5, color: const Color(0xFFFFCC00), fontWeight: FontWeight.bold)),
                                      Text(report.firstPlace, style: AppTypography.displayMedium.copyWith(fontSize: 15, color: AppColors.text)),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.print, size: 18, color: Color(0xFFFFCC00)),
                                  tooltip: 'Imprimir Diploma 1° Lugar',
                                  onPressed: () {
                                    diplomaService.printOrShareDiploma(
                                      context: context,
                                      tournamentName: tournament.name,
                                      tierLabel: tournament.tier.label,
                                      divisionLabel: tournament.ageDivision.label,
                                      bladerName: report.firstPlace,
                                      placeTitle: '1ER LUGAR (CAMPEÓN)',
                                      placeRank: 1,
                                      totalParticipants: tournament.participants.length,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),

                          if (report.secondPlace != null) ...[
                            const SizedBox(height: 6),
                            // 2nd Place Subchampion
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.panel,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.mute),
                              ),
                              child: Row(
                                children: [
                                  const Text('🥈', style: TextStyle(fontSize: 20)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('2DO LUGAR (SUBCAMPEÓN PLATA)', style: AppTypography.mono.copyWith(fontSize: 8.5, color: AppColors.mute, fontWeight: FontWeight.bold)),
                                        Text(report.secondPlace!, style: AppTypography.displayMedium.copyWith(fontSize: 14, color: AppColors.text)),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.print, size: 18, color: AppColors.mute),
                                    tooltip: 'Imprimir Diploma 2° Lugar',
                                    onPressed: () {
                                      diplomaService.printOrShareDiploma(
                                        context: context,
                                        tournamentName: tournament.name,
                                        tierLabel: tournament.tier.label,
                                        divisionLabel: tournament.ageDivision.label,
                                        bladerName: report.secondPlace!,
                                        placeTitle: '2DO LUGAR (SUBCAMPEÓN)',
                                        placeRank: 2,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],

                          if (report.thirdPlace != null) ...[
                            const SizedBox(height: 6),
                            // 3rd Place Bronze
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.panel,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.dranzer),
                              ),
                              child: Row(
                                children: [
                                  const Text('🥉', style: TextStyle(fontSize: 20)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('3ER LUGAR (BRONCE)', style: AppTypography.mono.copyWith(fontSize: 8.5, color: AppColors.dranzer, fontWeight: FontWeight.bold)),
                                        Text(report.thirdPlace!, style: AppTypography.displayMedium.copyWith(fontSize: 14, color: AppColors.text)),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.print, size: 18, color: AppColors.dranzer),
                                    tooltip: 'Imprimir Diploma 3° Lugar',
                                    onPressed: () {
                                      diplomaService.printOrShareDiploma(
                                        context: context,
                                        tournamentName: tournament.name,
                                        tierLabel: tournament.tier.label,
                                        divisionLabel: tournament.ageDivision.label,
                                        bladerName: report.thirdPlace!,
                                        placeTitle: '3ER LUGAR (BRONCE)',
                                        placeRank: 3,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ],

              // Round Tabs
              if (rounds.isNotEmpty) ...[
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: rounds.length,
                    itemBuilder: (context, index) {
                      final r = rounds[index];
                      final isSelected = index == _selectedRoundIndex;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            r.name.toUpperCase(),
                            style: AppTypography.mono.copyWith(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.black : AppColors.text,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: const Color(0xFF00FF66),
                          backgroundColor: AppColors.panel,
                          side: BorderSide(
                            color: isSelected ? const Color(0xFF00FF66) : AppColors.line,
                          ),
                          onSelected: (val) {
                            if (val) setState(() => _selectedRoundIndex = index);
                          },
                        ),
                      );
                    },
                  ),
                ),
                const Divider(color: AppColors.line, height: 1),
              ],

              // Matchups Grid / List
              Expanded(
                child: currentRound == null
                    ? Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColors.panel,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.line),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(Icons.how_to_reg, size: 44, color: AppColors.x),
                                    const SizedBox(height: 12),
                                    Text(
                                      'INSCRIPCIONES EN CURSO',
                                      style: AppTypography.displayMedium.copyWith(fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${tournament.participants.length} Bladers inscritos',
                                      style: AppTypography.mono.copyWith(fontSize: 12, color: AppColors.pegasus, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'El cuadro eliminatorio se generará cuando el organizador cierre la fase de inscripciones.',
                                      textAlign: TextAlign.center,
                                      style: AppTypography.bodySmall.copyWith(color: AppColors.mute, fontSize: 11),
                                    ),
                                    if (tournament.participants.isNotEmpty) ...[
                                      const SizedBox(height: 14),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: tournament.participants.map((name) {
                                          return Chip(
                                            backgroundColor: AppColors.steel,
                                            side: const BorderSide(color: AppColors.line),
                                            label: Text(name, style: AppTypography.mono.copyWith(fontSize: 10.5, color: AppColors.text)),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                    if (widget.onOpenHub != null) ...[
                                      const SizedBox(height: 18),
                                      ChamferButton(
                                        text: 'Ir al Panel del Organizador',
                                        variant: ChamferButtonVariant.go,
                                        onPressed: () => widget.onOpenHub?.call(context, tournament),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: currentRound.matchups.length,
                        itemBuilder: (context, matchupIdx) {
                          final m = currentRound.matchups[matchupIdx];
                          return _MatchupCard(
                            matchup: m,
                            roundName: currentRound.name,
                            onStartMatch: () => _showStartMatchDialog(
                              context: context,
                              tournamentId: tournament.id,
                              roundIndex: _selectedRoundIndex,
                              matchupIndex: matchupIdx,
                              matchup: m,
                            ),
                            onDeclareWalkover: () => _showWalkoverDialog(
                              context: context,
                              tournamentId: tournament.id,
                              roundIndex: _selectedRoundIndex,
                              matchupIndex: matchupIdx,
                              matchup: m,
                            ),
                            onReportResult: () => _showReportMatchDialog(
                              context: context,
                              tournamentId: tournament.id,
                              roundIndex: _selectedRoundIndex,
                              matchupIndex: matchupIdx,
                              matchup: m,
                            ),
                            onLaunchBattle: widget.onLaunchBattle != null
                                ? () => widget.onLaunchBattle!(context, m)
                                : null,
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

class _MatchupCard extends StatelessWidget {
  const _MatchupCard({
    required this.matchup,
    required this.roundName,
    required this.onStartMatch,
    required this.onDeclareWalkover,
    required this.onReportResult,
    this.onLaunchBattle,
  });

  final Matchup matchup;
  final String roundName;
  final VoidCallback onStartMatch;
  final VoidCallback onDeclareWalkover;
  final VoidCallback onReportResult;
  final VoidCallback? onLaunchBattle;

  @override
  Widget build(BuildContext context) {
    final isBye = matchup.isBye;
    final isCompleted = matchup.isCompleted;
    final isInProgress = matchup.isInProgress;
    final isReadyToCall = matchup.isReadyToCall;
    final winner = matchup.winnerId;

    final borderColor = isCompleted
        ? const Color(0xFF00FF66).withValues(alpha: 0.6)
        : (isInProgress
            ? AppColors.pegasus
            : AppColors.line);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: isInProgress ? 2 : (isCompleted ? 1.5 : 1),
        ),
        boxShadow: isInProgress
            ? [
                BoxShadow(
                  color: AppColors.pegasus.withValues(alpha: 0.15),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          // Header: Match Table & Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: matchup.matchId == 'BRONZE-3RD' || matchup.matchId.contains('3RD')
                  ? AppColors.dranzer.withValues(alpha: 0.15)
                  : (matchup.matchId.contains('FINAL')
                      ? const Color(0xFFFFCC00).withValues(alpha: 0.15)
                      : (isInProgress
                          ? AppColors.pegasus.withValues(alpha: 0.2)
                          : AppColors.steel)),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        matchup.matchId == 'BRONZE-3RD' || matchup.matchId.contains('3RD')
                            ? Icons.military_tech
                            : (matchup.matchId.contains('FINAL')
                                ? Icons.emoji_events
                                : (isInProgress ? Icons.sports_kabaddi : Icons.table_restaurant)),
                        size: 15,
                        color: matchup.matchId == 'BRONZE-3RD' || matchup.matchId.contains('3RD')
                            ? AppColors.dranzer
                            : (matchup.matchId.contains('FINAL')
                                ? const Color(0xFFFFCC00)
                                : (isInProgress ? AppColors.pegasus : AppColors.mute)),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          matchup.matchId == 'BRONZE-3RD' || matchup.matchId.contains('3RD')
                              ? '🥉 3ER PUESTO (BRONCE)'
                              : (matchup.matchId.contains('FINAL')
                                  ? '🏆 GRAN FINAL (ORO / PLATA)'
                                  : 'MESA #${matchup.tableNumber ?? 1} • ${matchup.matchId}'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.mono.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: matchup.matchId == 'BRONZE-3RD' || matchup.matchId.contains('3RD')
                                ? AppColors.dranzer
                                : (matchup.matchId.contains('FINAL')
                                    ? const Color(0xFFFFCC00)
                                    : (isInProgress ? AppColors.pegasus : AppColors.text)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (isBye)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.panel,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'BYE • DIRECTO',
                      style: AppTypography.mono.copyWith(fontSize: 9, color: AppColors.mute),
                    ),
                  )
                else if (isCompleted)
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          matchup.status == MatchupStatus.walkover ? Icons.person_off : Icons.check_circle,
                          size: 14,
                          color: matchup.status == MatchupStatus.walkover ? AppColors.dranzer : const Color(0xFF00FF66),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            matchup.status == MatchupStatus.walkover
                                ? 'W.O. • $winner'
                                : '$winner (${matchup.scoreA}-${matchup.scoreB})',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.mono.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: matchup.status == MatchupStatus.walkover ? AppColors.dranzer : const Color(0xFF00FF66),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (isInProgress)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.pegasus.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.pegasus),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 8,
                          height: 8,
                          child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.pegasus),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'EN COMBATE',
                          style: AppTypography.mono.copyWith(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.pegasus,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (isReadyToCall)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.panel,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Text(
                      'LISTO PARA LLAMAR',
                      style: AppTypography.mono.copyWith(fontSize: 9, color: AppColors.mute),
                    ),
                  )
                else
                  Text(
                    'EN ESPERA',
                    style: AppTypography.mono.copyWith(fontSize: 10, color: AppColors.mute),
                  ),
              ],
            ),
          ),

          // Matchup Combatants
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Player A
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: winner == matchup.playerAName
                          ? AppColors.dragoon.withValues(alpha: 0.15)
                          : AppColors.steel,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: winner == matchup.playerAName ? AppColors.dragoon : AppColors.line,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BLADER 1',
                          style: AppTypography.mono.copyWith(fontSize: 8, color: AppColors.dragoon),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          matchup.playerAName,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: matchup.playerAName == 'TBD' ? AppColors.mute : AppColors.text,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),

                // VS Badge
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'VS',
                    style: AppTypography.mono.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: isInProgress ? AppColors.pegasus : AppColors.mute,
                    ),
                  ),
                ),

                // Player B
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: winner == matchup.playerBName
                          ? AppColors.dranzer.withValues(alpha: 0.15)
                          : AppColors.steel,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: winner == matchup.playerBName ? AppColors.dranzer : AppColors.line,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BLADER 2',
                          style: AppTypography.mono.copyWith(fontSize: 8, color: AppColors.dranzer),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          matchup.playerBName ?? 'BYE',
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: matchup.playerBName == 'TBD' || matchup.playerBName == null
                                ? AppColors.mute
                                : AppColors.text,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons according to MatchupStatus
          if (!isBye && !isCompleted && isReadyToCall) ...[
            const Divider(color: AppColors.line, height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  // State 1: PENDING -> LLAMAR A ESTADIO & W.O.
                  if (!isInProgress) ...[
                    OutlinedButton.icon(
                      onPressed: onDeclareWalkover,
                      icon: const Icon(Icons.person_off, size: 14, color: AppColors.dranzer),
                      label: Text(
                        'W.O.',
                        style: AppTypography.mono.copyWith(fontSize: 10, color: AppColors.dranzer),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.dranzer),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: onStartMatch,
                      icon: const Icon(Icons.campaign, size: 16),
                      label: const Text('LLAMAR A ESTADIO'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.pegasus,
                        foregroundColor: Colors.black,
                        textStyle: AppTypography.mono.copyWith(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                    ),
                  ],

                  // State 2: IN PROGRESS -> MARCADOR & FINALIZAR / REPORTAR RESULTADO
                  if (isInProgress) ...[
                    if (onLaunchBattle != null)
                      OutlinedButton.icon(
                        onPressed: onLaunchBattle,
                        icon: const Icon(Icons.scoreboard, size: 14, color: AppColors.dragoon),
                        label: Text(
                          'MARCADOR 1V1',
                          style: AppTypography.mono.copyWith(fontSize: 10, color: AppColors.dragoon),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.dragoon),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        ),
                      ),
                    FilledButton.icon(
                      onPressed: onReportResult,
                      icon: const Icon(Icons.gavel, size: 15),
                      label: const Text('FINALIZAR / REPORTAR GANADOR'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF00FF66),
                        foregroundColor: Colors.black,
                        textStyle: AppTypography.mono.copyWith(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
