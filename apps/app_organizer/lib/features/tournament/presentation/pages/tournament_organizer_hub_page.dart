import 'dart:async';
import 'package:bey_domain/bey_domain.dart';
import 'package:bey_hub/bey_hub.dart';
import 'package:bey_tournament/bey_tournament.dart';
import 'package:bey_ui/bey_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/di/injector.dart';

class TournamentOrganizerHubPage extends StatefulWidget {
  const TournamentOrganizerHubPage({
    super.key,
    required this.tournament,
  });

  final Tournament tournament;

  @override
  State<TournamentOrganizerHubPage> createState() => _TournamentOrganizerHubPageState();
}

class _TournamentOrganizerHubPageState extends State<TournamentOrganizerHubPage> with SingleTickerProviderStateMixin {
  final _hubServer = getIt<LanHubServer>();
  final _permissionService = getIt<PermissionService>();
  final _identityRepo = getIt<IdentityRepository>();
  final _tournamentRepo = getIt<TournamentRepository>();
  final _deckRepo = getIt<DeckRepository>();
  final _comboRepo = getIt<ComboRepository>();

  late TabController _tabController;
  late Tournament _currentTournament;
  bool _isHubRunning = false;
  bool _isSmartDispatcherEnabled = true;
  String? _currentUserId;
  StreamSubscription<Tournament>? _tournamentSubscription;
  StreamSubscription<Map<int, TableStatus>>? _tablesSubscription;
  StreamSubscription<Map<String, dynamic>>? _registrationSubscription;
  final Set<String> _verifiedCheckIns = {};

  final TextEditingController _offlineBladerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentTournament = widget.tournament;
    _tabController = TabController(length: 2, vsync: this);
    _checkHubState();
    _loadUser();
    _listenToTournamentUpdates();
    _listenToTableConfirmations();
    _listenToRegistrations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tournamentSubscription?.cancel();
    _tablesSubscription?.cancel();
    _registrationSubscription?.cancel();
    _offlineBladerController.dispose();
    super.dispose();
  }

  void _listenToTournamentUpdates() {
    _tournamentSubscription = _tournamentRepo.watchById(_currentTournament.id).listen((t) {
      if (!mounted) return;
      setState(() => _currentTournament = t);
      if (_isHubRunning) {
        _syncTournamentToHub();
        _assignCurrentRoundMatchesToHub();
      }
    });
  }

  void _listenToRegistrations() {
    _registrationSubscription = _hubServer.registrationStream.listen((event) async {
      if (!mounted) return;
      final nickname = event['nickname'] as String? ?? '';
      if (nickname.isEmpty) return;

      if (!_currentTournament.participants.contains(nickname)) {
        final updatedParticipants = List<String>.from(_currentTournament.participants)..add(nickname);
        final updated = _currentTournament.copyWith(participants: updatedParticipants);
        await _tournamentRepo.save(updated);
        if (mounted) {
          setState(() => _currentTournament = updated);
          _syncTournamentToHub();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('¡Nuevo Blader inscrito: $nickname!'),
              backgroundColor: AppColors.x,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } else if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deck actualizado para $nickname'),
            backgroundColor: AppColors.pegasus,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _listenToTableConfirmations() {
    _tablesSubscription = _hubServer.tablesStream.listen((tables) {
      if (!mounted) return;

      for (final table in tables.values) {
        if (table.status == 'CONFIRMED') {
          _handleTableConfirmed(table);
        }
      }
    });
  }

  void _handleTableConfirmed(TableStatus table) {
    if (table.scoreA == table.scoreB) {
      // Tie: cannot determine winner. Require manual resolution.
      if (mounted) {
        BeyFeedbackDialog.showWarning(
          context,
          title: 'Empate en Mesa ${table.tableNumber}',
          message: 'El combate finalizó en empate (${table.scoreA} - ${table.scoreB}) entre ${table.playerA} y ${table.playerB}. El sistema no puede avanzar automáticamente a ningún ganador.',
          solution: 'Toca sobre la tarjeta de la mesa para abrir el panel de arbitraje y definir el desempate reglamentario.',
        );
      }
      return;
    }

    for (var rIdx = 0; rIdx < _currentTournament.rounds.length; rIdx++) {
      final round = _currentTournament.rounds[rIdx];
      for (var mIdx = 0; mIdx < round.matchups.length; mIdx++) {
        final matchup = round.matchups[mIdx];
        if (matchup.tableNumber == table.tableNumber && !matchup.isCompleted) {
          final winner = table.scoreA > table.scoreB ? table.playerA : table.playerB;
          context.read<TournamentBloc>().add(
                TournamentMatchReported(
                  tournamentId: _currentTournament.id,
                  roundIndex: rIdx,
                  matchupIndex: mIdx,
                  winnerName: winner,
                  scoreA: table.scoreA,
                  scoreB: table.scoreB,
                ),
              );
          break;
        }
      }
    }
  }

  Future<void> _loadUser() async {
    final profile = await _identityRepo.getActiveProfile();
    if (mounted) {
      setState(() => _currentUserId = profile?.id ?? 'organizer-local');
    }
  }

  Future<void> _checkHubState() async {
    if (!_hubServer.isRunning) {
      await _hubServer.start();
    }
    _syncTournamentToHub();
    _assignCurrentRoundMatchesToHub();
    if (mounted) {
      setState(() => _isHubRunning = _hubServer.isRunning);
    }
  }

  void _syncTournamentToHub() {
    _hubServer.currentTournamentJson = {
      'id': _currentTournament.id,
      'name': _currentTournament.name,
      'organizerIds': _currentTournament.organizerIds,
      'tier': _currentTournament.tier.name,
      'ageDivision': _currentTournament.ageDivision.name,
      'status': _currentTournament.status.name,
      'participants': _currentTournament.participants,
      'seed': _currentTournament.seed,
      'rounds': _currentTournament.rounds
          .map((r) => {
                'roundIndex': r.roundIndex,
                'name': r.name,
                'matchups': r.matchups
                    .map((m) => {
                          'matchId': m.matchId,
                          'playerAName': m.playerAName,
                          'playerBName': m.playerBName,
                          'scoreA': m.scoreA,
                          'scoreB': m.scoreB,
                          'isCompleted': m.isCompleted,
                          'isBye': m.isBye,
                          'tableNumber': m.tableNumber,
                          'winnerId': m.winnerId,
                        })
                    .toList(),
              })
          .toList(),
    };
  }

  Future<void> _toggleHub() async {
    if (_isHubRunning) {
      await _hubServer.stop();
    } else {
      await _hubServer.start();
      _syncTournamentToHub();
      _assignCurrentRoundMatchesToHub();
    }
    setState(() => _isHubRunning = _hubServer.isRunning);
  }

  void _assignCurrentRoundMatchesToHub() {
    if (_currentTournament.rounds.isEmpty) return;
    final activeRound = _currentTournament.rounds.firstWhere(
      (r) => r.matchups.any((m) => !m.isCompleted && !m.isBye),
      orElse: () => _currentTournament.rounds.last,
    );

    var tableNum = 1;
    for (final m in activeRound.matchups) {
      if (!m.isCompleted && !m.isBye && m.playerAName != 'TBD' && m.playerBName != 'TBD') {
        _hubServer.assignMatchToTable(
          tableNumber: tableNum,
          playerA: m.playerAName,
          playerB: m.playerBName ?? '',
        );
        tableNum++;
      }
    }
  }

  Future<void> _closeRegistrationAndStartCheckIn() async {
    if (_currentTournament.participants.length < 2) {
      await BeyFeedbackDialog.showError(
        context,
        title: 'Participantes Insuficientes',
        message: 'No puedes cerrar inscripciones con menos de 2 Bladers registrados.',
        solution: 'Espera a que se inscriban más participantes o agrega competidores locales usando el botón "+" en la pestaña de Inscritos.',
      );
      return;
    }

    final updated = _currentTournament.copyWith(
      status: TournamentStatus.checkIn,
    );

    await _tournamentRepo.save(updated);

    if (mounted) {
      setState(() => _currentTournament = updated);
      _syncTournamentToHub();

      await BeyFeedbackDialog.showInfo(
        context,
        title: 'Fase de Check-in Iniciada',
        message: 'Inscripciones cerradas con ${_currentTournament.participants.length} Bladers registrados.',
        solution: 'Revisa físicamente los decks 3on3 de cada competidor en mesa de control tocando "VER DECK" antes de sortear el cuadro.',
      );
    }
  }

  Future<void> _generateBracketAndStart() async {
    final pendingCount = _currentTournament.participants.where((p) => !_verifiedCheckIns.contains(p)).length;
    if (pendingCount > 0) {
      final confirm = await BeyFeedbackDialog.showConfirm(
        context,
        title: 'Decks Pendientes de Aprobación',
        message: 'Hay $pendingCount Blader(s) con Deck aún no verificado por el juez.\n\nSegún el reglamento oficial v12, un jugador solo está LISTO para competir cuando su Deck 3on3 ha sido aprobado.',
        confirmText: 'VALIDAR EN MESA Y SORTEAR',
        cancelText: 'REVISAR DECKS PENDIENTES',
      );
      if (confirm != true) return;

      // Batch approve remaining bladers if judge decides in person
      _verifiedCheckIns.addAll(_currentTournament.participants);
      _currentTournament.participants.forEach(_hubServer.verifyBladerCheckIn);
    }

    const generator = BracketGenerator();
    final rounds = generator.generateBracketTree(
      playerNames: _currentTournament.participants,
      seed: _currentTournament.seed ?? 123456,
    );

    final updated = _currentTournament.copyWith(
      rounds: rounds,
      status: TournamentStatus.inProgress,
    );

    await _tournamentRepo.save(updated);

    if (mounted) {
      setState(() => _currentTournament = updated);
      context.read<TournamentBloc>().add(TournamentCreated(updated));
      _tabController.animateTo(0);
      if (_isHubRunning) {
        _assignCurrentRoundMatchesToHub();
      }

      await BeyFeedbackDialog.showSuccess(
        context,
        title: '¡Torneo Iniciado!',
        message: 'Se generaron las llaves deterministas para ${_currentTournament.participants.length} competidores y se transmitieron los primeros combates a las mesas.',
      );
    }
  }

  Future<void> _addOfflineBlader() async {
    final name = _offlineBladerController.text.trim();
    if (name.isEmpty) return;

    if (_currentTournament.participants.any((p) => p.trim().toLowerCase() == name.toLowerCase())) {
      await BeyFeedbackDialog.showError(
        context,
        title: 'Blader Ya Registrado',
        message: 'El nombre "$name" ya se encuentra en la lista de participantes.',
        solution: 'Usa un apodo o nombre distintivo para evitar confusiones en el cuadro.',
      );
      return;
    }

    final updatedParticipants = List<String>.from(_currentTournament.participants)..add(name);
    final updated = _currentTournament.copyWith(participants: updatedParticipants);

    await _tournamentRepo.save(updated);
    if (mounted) {
      setState(() {
        _currentTournament = updated;
        _offlineBladerController.clear();
      });
    }
  }

  Future<void> _removeBlader(String name) async {
    final updatedParticipants = List<String>.from(_currentTournament.participants)..remove(name);
    final updated = _currentTournament.copyWith(participants: updatedParticipants);

    await _tournamentRepo.save(updated);
    if (mounted) {
      setState(() {
        _currentTournament = updated;
        _verifiedCheckIns.remove(name);
      });
    }
  }

  List<DeckViolation> _validateDeckFromCombos(List<Combo> comboList) {
    const validator = DeckValidator();
    final beys = comboList.map((c) {
      return BeyBuild(
        spinsLeft: false,
        parts: [
          PartRef(identityKey: c.bladeId, name: c.bladeId.replaceAll('blade-', ''), type: PartKind.blade),
          PartRef(identityKey: c.ratchetId, name: c.ratchetId.replaceAll('ratchet-', ''), type: PartKind.ratchet),
          PartRef(identityKey: c.bitId, name: c.bitId.replaceAll('bit-', ''), type: PartKind.bit),
        ],
      );
    }).toList();

    final result = validator.validate(
      beys,
      isSingles: false,
      hallOfFamePartIds: const {},
      ownsLeftLauncher: true,
    );

    return result.fold((violations) => violations, (_) => []);
  }

  void _showDeckInspectionSheet(String bladerName) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.void_,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        side: BorderSide(color: AppColors.line),
      ),
      builder: (ctx) {
        // Check if blader submitted deck over LanHubServer
        final remotePayload = _hubServer.getDeckForBlader(bladerName);
        final remoteCombosRaw = remotePayload?['combos'] as List<dynamic>? ?? [];
        final remoteDeckRaw = remotePayload?['deck'] as Map<String, dynamic>?;

        final remoteCombos = <Combo>[];
        if (remoteCombosRaw.isNotEmpty) {
          for (var i = 0; i < remoteCombosRaw.length; i++) {
            final c = remoteCombosRaw[i] as Map<String, dynamic>;
            remoteCombos.add(
              Combo(
                id: c['id'] as String? ?? 'rc-$i',
                name: c['name'] as String? ?? 'BEY #${i + 1}',
                bladeId: c['bladeId'] as String? ?? c['blade_id'] as String? ?? '',
                ratchetId: c['ratchetId'] as String? ?? c['ratchet_id'] as String? ?? '',
                bitId: c['bitId'] as String? ?? c['bit_id'] as String? ?? '',
                lockChipId: c['lockChipId'] as String? ?? c['lock_chip_id'] as String?,
                assistBladeId: c['assistBladeId'] as String? ?? c['assist_blade_id'] as String?,
                system: BeySystem.values[(c['system'] as int?) ?? 0],
                calculatedWeight: (c['calculatedWeight'] as num? ?? c['calculated_weight'] as num?)?.toDouble(),
              ),
            );
          }
        }

        return FutureBuilder(
          future: Future.wait([
            _deckRepo.watchAll().first,
            _comboRepo.watchAll().first,
          ]),
          builder: (context, snapshot) {
            final localDecks = snapshot.hasData ? snapshot.data![0] as List<Deck> : <Deck>[];
            final localCombos = snapshot.hasData ? snapshot.data![1] as List<Combo> : <Combo>[];

            final List<Combo> deckCombos;
            final Deck? deck;
            final Map<String, Combo> combosMap;

            if (remoteCombos.isNotEmpty) {
              deckCombos = remoteCombos;
              combosMap = {for (final c in remoteCombos) c.id: c};
              deck = Deck(
                id: remoteDeckRaw?['id'] as String? ?? 'remote-deck',
                name: remoteDeckRaw?['name'] as String? ?? 'Deck 3on3',
                comboIds: remoteCombos.map((c) => c.id).toList(),
              );
            } else {
              combosMap = {for (final c in localCombos) c.id: c};
              deck = localDecks.isNotEmpty ? localDecks.first : null;
              deckCombos = deck != null
                  ? deck.comboIds
                      .map((cid) => combosMap[cid])
                      .whereType<Combo>()
                      .toList()
                  : <Combo>[];
            }

            final violations = deckCombos.length == 3
                ? _validateDeckFromCombos(deckCombos)
                : <DeckViolation>[];
            final isDeckValid = deckCombos.length == 3 && violations.isEmpty;

            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.shield, color: AppColors.x, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'DECK 3ON3 · ${bladerName.toUpperCase()}',
                                    style: AppTypography.mono.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: AppColors.mute),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Alineación oficial declarada para revisión de mesa.',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.mute, fontSize: 11),
                      ),
                      const SizedBox(height: 16),

                      if (deck == null || deck.comboIds.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.panel,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              'Deck pendiente de registro por parte del Blader.',
                              style: TextStyle(color: AppColors.mute, fontSize: 12),
                            ),
                          ),
                        )
                      else
                        ...deck.comboIds.asMap().entries.map((entry) {
                          final idx = entry.key + 1;
                          final cid = entry.value;
                          final combo = combosMap[cid];
                          final name = combo?.name ?? 'BEY #$idx';
                          final parts = combo != null
                              ? '${combo.bladeId.replaceAll('blade-', '')} · ${combo.ratchetId.replaceAll('ratchet-', '')} · ${combo.bitId.replaceAll('bit-', '')}'
                              : 'Piezas oficiales declaradas';
                          final beyViolations = violations.where((v) => v.beyIndexes.contains(entry.key)).toList();
                          final beyHasError = beyViolations.isNotEmpty;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: beyHasError ? AppColors.dranzer.withValues(alpha: 0.08) : AppColors.panel,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: beyHasError ? AppColors.dranzer : AppColors.line),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.steel,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text('BEY #$idx', style: AppTypography.mono.copyWith(fontSize: 9.5, color: beyHasError ? AppColors.dranzer : AppColors.x, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(name.toUpperCase(), style: AppTypography.mono.copyWith(fontWeight: FontWeight.bold, fontSize: 12)),
                                      Text(parts, style: AppTypography.bodySmall.copyWith(fontSize: 10, color: AppColors.mute)),
                                      if (beyHasError)
                                        ...beyViolations.map((v) => Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text(
                                            v.message,
                                            style: AppTypography.bodySmall.copyWith(fontSize: 10, color: AppColors.dranzer),
                                          ),
                                        )),
                                    ],
                                  ),
                                ),
                                Icon(
                                  beyHasError ? Icons.error_outline : Icons.check_circle_outline,
                                  color: beyHasError ? AppColors.dranzer : const Color(0xFF00FF66),
                                  size: 16,
                                ),
                              ],
                            ),
                          );
                        }),

                      // Show global violations (wrongBeyCount, etc.)
                      if (violations.where((v) => v.beyIndexes.isEmpty).isNotEmpty) ...[
                        const SizedBox(height: 8),
                        ...violations.where((v) => v.beyIndexes.isEmpty).map((v) => Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.dranzer.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.dranzer),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber, color: AppColors.dranzer, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(v.message, style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.dranzer)),
                              ),
                            ],
                          ),
                        )),
                      ],

                      const SizedBox(height: 16),

                      // Validation status banner
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDeckValid ? AppColors.x.withValues(alpha: 0.1) : AppColors.dranzer.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: isDeckValid ? AppColors.x : AppColors.dranzer),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isDeckValid ? Icons.verified : Icons.block,
                              color: isDeckValid ? AppColors.x : AppColors.dranzer,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isDeckValid ? 'DECK LEGAL — Cumple reglamento v12' : 'DECK ILEGAL — ${violations.length} violación(es) encontrada(s)',
                                style: AppTypography.mono.copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isDeckValid ? AppColors.x : AppColors.dranzer,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      ChamferButton(
                        text: isDeckValid
                            ? 'APROBAR Y VALIDAR CHECK-IN'
                            : (deck == null || deck.comboIds.isEmpty
                                ? 'APROBAR CHECK-IN (REVISIÓN EN MESA)'
                                : 'APROBACIÓN EXCEPCIONAL POR JUEZ'),
                        variant: isDeckValid ? ChamferButtonVariant.go : ChamferButtonVariant.ghost,
                        onPressed: () {
                          setState(() => _verifiedCheckIns.add(bladerName));
                          _hubServer.verifyBladerCheckIn(bladerName);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Deck y check-in de $bladerName aprobados. ¡Blader marcado como LISTO!'),
                              backgroundColor: const Color(0xFF00FF66),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showTablePairingQrDialog(int tableNumber) {
    final token = TablePairingToken.generate(
      tournamentId: _currentTournament.id,
      tableNumber: tableNumber,
      hubIp: _hubServer.localIp ?? '127.0.0.1',
      port: _hubServer.port,
      secretKey: 'beyscore-secret-key',
      validDuration: const Duration(hours: 4),
    );
    final qrData = token.toQrString();

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.panel,
        title: Text(
          'EMPAREJAR MESA $tableNumber',
          style: AppTypography.mono.copyWith(fontWeight: FontWeight.bold, color: AppColors.text),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.white,
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 200,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Escanea este código con la tablet de Mesa $tableNumber para conectar al Hub LAN.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(color: AppColors.mute),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CERRAR', style: TextStyle(color: AppColors.x)),
          ),
        ],
      ),
    );
  }

  void _showRegistrationQrDialog() {
    final cleanIp = _hubServer.localIp ?? '127.0.0.1';
    final port = _hubServer.port;
    final qrData = 'beyscore://join?hub=$cleanIp:$port&tournament=${_currentTournament.id}';

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.panel,
        title: Row(
          children: [
            const Icon(Icons.qr_code_2, color: AppColors.x, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'QR DE INSCRIPCIÓN LAN',
                style: AppTypography.mono.copyWith(fontWeight: FontWeight.bold, color: AppColors.text, fontSize: 13),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.white,
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 210,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Muestra este QR a los Bladers en el recinto para que su app se conecte a tu Hub LAN y envíen su Deck por Wi-Fi.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(color: AppColors.mute, fontSize: 11.5),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.steel,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'HOST IP: $cleanIp:$port',
                style: AppTypography.mono.copyWith(fontSize: 11, color: AppColors.x, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CERRAR', style: TextStyle(color: AppColors.x)),
          ),
        ],
      ),
    );
  }

  void _showBroadcastSharingDialog() {
    final hubUrl = _hubServer.hubUrl;
    final cleanIp = _hubServer.localIp ?? '127.0.0.1';

    final links = [
      (
        'OBS OVERLAY · ESTÁNDAR (HUD)',
        '$hubUrl/stream-overlay?table=1',
        'HUD inferior completo para stream de mesa 1 con animaciones de finish.',
        Icons.desktop_windows_rounded,
        AppColors.x,
      ),
      (
        'OBS OVERLAY · COMPACTO (SCOREBUG)',
        '$hubUrl/stream-overlay?table=1&layout=compact',
        'Scorebug discreto para esquinas superiores o inferiores de transmisión.',
        Icons.crop_16_9_rounded,
        AppColors.pegasus,
      ),
      (
        'OBS CHROMA GREEN',
        '$hubUrl/stream-overlay?table=1&chroma=true',
        'Fondo verde #00FF00 para recortar por croma en vMix / Wirecast.',
        Icons.videocam_rounded,
        const Color(0xFF00FF66),
      ),
      (
        'PANTALLA GIGANTE / JUMBOTRON',
        '$hubUrl/stadium-board',
        'Pantalla gigante de estadio con rotación automática para Smart TV o proyector.',
        Icons.tv_rounded,
        AppColors.pegasus,
      ),
      (
        'ESPECTADOR WEB LOCAL',
        '$hubUrl/spectator',
        'Dashboard interactivo para que los espectadores en el público sigan el torneo.',
        Icons.public_rounded,
        AppColors.dragoon,
      ),
    ];

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.panel,
        title: Row(
          children: [
            const Icon(Icons.broadcast_on_personal_rounded, color: AppColors.x, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'CENTRO DE EMISIÓN & LIVESTREAM',
                style: AppTypography.mono.copyWith(fontWeight: FontWeight.bold, color: AppColors.text, fontSize: 13),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Copia los enlaces de transmisión o compártelos con la mesa de producción audiovisual en la misma red Wi-Fi ($cleanIp):',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.mute, fontSize: 11.5),
                ),
                const SizedBox(height: 14),
                ...links.map((item) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.steel,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: item.$5.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(item.$4, color: item.$5, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.$1,
                                style: AppTypography.mono.copyWith(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: item.$5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.$3,
                          style: AppTypography.bodySmall.copyWith(fontSize: 10.5, color: AppColors.mute),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.void_,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item.$2,
                                  style: AppTypography.mono.copyWith(fontSize: 9, color: AppColors.text),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: item.$2));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('¡Copiado!: ${item.$1}'),
                                    backgroundColor: item.$5,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: item.$5,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'COPIAR',
                                  style: AppTypography.mono.copyWith(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CERRAR', style: TextStyle(color: AppColors.x)),
          ),
        ],
      ),
    );
  }

  void _openDisputeResolutionDialog(TableStatus table) {
    final perm = _permissionService.can(
      Capability.resolveDispute,
      deviceRole: DeviceRole.phone,
      tournamentOwnerId: _currentTournament.organizerIds.isNotEmpty ? _currentTournament.organizerIds.first : _currentUserId,
      actorUserId: _currentUserId,
    );

    if (!perm.isAllowed) {
      BeyFeedbackDialog.showError(
        context,
        title: 'Arbitraje Denegado',
        message: perm.denialReason ?? 'Tu usuario no cuenta con facultades de juez principal para resolver disputas en este torneo.',
        solution: 'Debes iniciar sesión con una cuenta de organizador autorizada en Tournament.organizerIds.',
      );
      return;
    }

    var scoreA = table.scoreA;
    var scoreB = table.scoreB;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            backgroundColor: AppColors.panel,
            title: Text(
              'RESOLUCIÓN DE DISPUTA · MESA ${table.tableNumber}',
              style: AppTypography.mono.copyWith(fontWeight: FontWeight.bold, color: AppColors.dranzer),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'El árbitro de mesa reportó un conflicto. Como organizador, dicta el marcador oficial definitivo:',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.mute),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(table.playerA, style: AppTypography.mono.copyWith(fontWeight: FontWeight.bold, color: AppColors.dragoon)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: AppColors.mute),
                              onPressed: () => setModalState(() => scoreA = (scoreA - 1).clamp(0, 7)),
                            ),
                            Text('$scoreA', style: AppTypography.displayMedium.copyWith(fontSize: 24)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, color: AppColors.x),
                              onPressed: () => setModalState(() => scoreA = (scoreA + 1).clamp(0, 7)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text('—', style: AppTypography.displayMedium.copyWith(color: AppColors.line2)),
                    Column(
                      children: [
                        Text(table.playerB, style: AppTypography.mono.copyWith(fontWeight: FontWeight.bold, color: AppColors.dranzer)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: AppColors.mute),
                              onPressed: () => setModalState(() => scoreB = (scoreB - 1).clamp(0, 7)),
                            ),
                            Text('$scoreB', style: AppTypography.displayMedium.copyWith(fontSize: 24)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, color: AppColors.x),
                              onPressed: () => setModalState(() => scoreB = (scoreB + 1).clamp(0, 7)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('CANCELAR', style: TextStyle(color: AppColors.mute)),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppColors.x, foregroundColor: Colors.black),
                onPressed: () {
                  _hubServer.resolveDispute(tableNumber: table.tableNumber, scoreA: scoreA, scoreB: scoreB);
                  Navigator.pop(ctx);
                },
                child: const Text('DICTAR RESOLUCIÓN'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showTournamentReportDialog() {
    const analytics = MetaAnalyticsService();
    final report = analytics.generateTournamentReport(
      tournamentName: _currentTournament.name,
      rounds: _currentTournament.rounds,
    );

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.panel,
        title: Row(
          children: [
            const Icon(Icons.emoji_events, color: AppColors.pegasus),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'PODIO & REPORTE OFICIAL',
                style: AppTypography.mono.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _currentTournament.name.toUpperCase(),
                style: AppTypography.displayMedium.copyWith(fontSize: 16, color: AppColors.x),
              ),
              Text(
                '${_currentTournament.tier.label} · ${_currentTournament.format.label}',
                style: AppTypography.mono.copyWith(fontSize: 10, color: AppColors.mute),
              ),
              const SizedBox(height: 16),

              // Podium Cards
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.steel,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.pegasus),
                ),
                child: Row(
                  children: [
                    const Text('🥇', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('1ER LUGAR (CAMPEÓN)', style: AppTypography.mono.copyWith(fontSize: 9, color: AppColors.pegasus, fontWeight: FontWeight.bold)),
                          Text(report.firstPlace, style: AppTypography.displayMedium.copyWith(fontSize: 15, color: AppColors.text)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.picture_as_pdf, color: AppColors.pegasus, size: 20),
                      tooltip: 'Generar Diploma PDF (Horizontal)',
                      onPressed: () {
                        final payload = _hubServer.getDeckForBlader(report.firstPlace);
                        final rawCombos = (payload?['combos'] as List<dynamic>?) ?? <dynamic>[];
                        final names = <String>[];
                        for (final item in rawCombos) {
                          if (item is Map) {
                            names.add((item['name'] as String? ?? 'BEY').toUpperCase());
                          }
                        }
                        final combos = names.isEmpty ? null : names.join(' · ');

                        const DiplomaPdfService().printOrShareDiploma(
                          context: context,
                          tournamentName: _currentTournament.name,
                          tierLabel: _currentTournament.tier.label,
                          divisionLabel: _currentTournament.ageDivision.label,
                          bladerName: report.firstPlace,
                          placeTitle: '1ER LUGAR (CAMPEÓN)',
                          placeRank: 1,
                          deckInfo: combos,
                          totalParticipants: _currentTournament.participants.length,
                          organizerName: _currentUserId,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              if (report.secondPlace != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.steel,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.mute),
                  ),
                  child: Row(
                    children: [
                      const Text('🥈', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('2DO LUGAR (SUBCAMPEÓN)', style: AppTypography.mono.copyWith(fontSize: 9, color: AppColors.mute, fontWeight: FontWeight.bold)),
                            Text(report.secondPlace!, style: AppTypography.displayMedium.copyWith(fontSize: 15, color: AppColors.text)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.picture_as_pdf, color: AppColors.mute, size: 20),
                        tooltip: 'Generar Diploma PDF (Horizontal)',
                        onPressed: () {
                          final payload = _hubServer.getDeckForBlader(report.secondPlace!);
                          final rawCombos = (payload?['combos'] as List<dynamic>?) ?? <dynamic>[];
                          final names = <String>[];
                          for (final item in rawCombos) {
                            if (item is Map) {
                              names.add((item['name'] as String? ?? 'BEY').toUpperCase());
                            }
                          }
                          final combos = names.isEmpty ? null : names.join(' · ');

                          const DiplomaPdfService().printOrShareDiploma(
                            context: context,
                            tournamentName: _currentTournament.name,
                            tierLabel: _currentTournament.tier.label,
                            divisionLabel: _currentTournament.ageDivision.label,
                            bladerName: report.secondPlace!,
                            placeTitle: '2DO LUGAR (SUBCAMPEÓN)',
                            placeRank: 2,
                            deckInfo: combos,
                            totalParticipants: _currentTournament.participants.length,
                            organizerName: _currentUserId,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              if (report.thirdPlace != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.steel,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.dranzer),
                  ),
                  child: Row(
                    children: [
                      const Text('🥉', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('3ER LUGAR (BRONCE)', style: AppTypography.mono.copyWith(fontSize: 9, color: AppColors.dranzer, fontWeight: FontWeight.bold)),
                            Text(report.thirdPlace!, style: AppTypography.displayMedium.copyWith(fontSize: 15, color: AppColors.text)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.picture_as_pdf, color: AppColors.dranzer, size: 20),
                        tooltip: 'Generar Diploma PDF (Horizontal)',
                        onPressed: () {
                          final payload = _hubServer.getDeckForBlader(report.thirdPlace!);
                          final rawCombos = (payload?['combos'] as List<dynamic>?) ?? <dynamic>[];
                          final names = <String>[];
                          for (final item in rawCombos) {
                            if (item is Map) {
                              names.add((item['name'] as String? ?? 'BEY').toUpperCase());
                            }
                          }
                          final combos = names.isEmpty ? null : names.join(' · ');

                          const DiplomaPdfService().printOrShareDiploma(
                            context: context,
                            tournamentName: _currentTournament.name,
                            tierLabel: _currentTournament.tier.label,
                            divisionLabel: _currentTournament.ageDivision.label,
                            bladerName: report.thirdPlace!,
                            placeTitle: '3ER LUGAR (BRONCE)',
                            placeRank: 3,
                            deckInfo: combos,
                            totalParticipants: _currentTournament.participants.length,
                            organizerName: _currentUserId,
                          );
                        },
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),
              // Tournament Stats
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: AppColors.steel, borderRadius: BorderRadius.circular(4)),
                      child: Column(
                        children: [
                          Text('${report.totalMatches}', style: AppTypography.mono.copyWith(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.x)),
                          Text('COMBATES', style: AppTypography.mono.copyWith(fontSize: 8, color: AppColors.mute)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: AppColors.steel, borderRadius: BorderRadius.circular(4)),
                      child: Column(
                        children: [
                          Text('${report.totalPointsScored}', style: AppTypography.mono.copyWith(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.dragoon)),
                          Text('PUNTOS TOTALES', style: AppTypography.mono.copyWith(fontSize: 8, color: AppColors.mute)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.picture_as_pdf, size: 16, color: AppColors.pegasus),
            label: const Text('DIPLOMA CAMPEÓN', style: TextStyle(color: AppColors.pegasus, fontWeight: FontWeight.bold)),
            onPressed: () {
              final payload = _hubServer.getDeckForBlader(report.firstPlace);
              final rawCombos = (payload?['combos'] as List<dynamic>?) ?? <dynamic>[];
              final names = <String>[];
              for (final item in rawCombos) {
                if (item is Map) {
                  names.add((item['name'] as String? ?? 'BEY').toUpperCase());
                }
              }
              final combos = names.isEmpty ? null : names.join(' · ');

              const DiplomaPdfService().printOrShareDiploma(
                context: context,
                tournamentName: _currentTournament.name,
                tierLabel: _currentTournament.tier.label,
                divisionLabel: _currentTournament.ageDivision.label,
                bladerName: report.firstPlace,
                placeTitle: '1ER LUGAR (CAMPEÓN)',
                placeRank: 1,
                deckInfo: combos,
                totalParticipants: _currentTournament.participants.length,
                organizerName: _currentUserId,
              );
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.share, size: 16, color: AppColors.x),
            label: const Text('COPIAR REPORTE', style: TextStyle(color: AppColors.x, fontWeight: FontWeight.bold)),
            onPressed: () {
              final text = StringBuffer()
                ..writeln('🏆 REPORTE OFICIAL BEYSCORE 🏆')
                ..writeln('Torneo: ${_currentTournament.name.toUpperCase()}')
                ..writeln('Nivel: ${_currentTournament.tier.label} · ${_currentTournament.ageDivision.label}')
                ..writeln('')
                ..writeln('🥇 Campeón (ORO): ${report.firstPlace}')
                ..writeln('🥈 Subcampeón (PLATA): ${report.secondPlace ?? "N/A"}')
                ..writeln('🥉 3er Puesto (BRONCE): ${report.thirdPlace ?? "N/A"}')
                ..writeln('')
                ..writeln('📊 Estadísticas del Torneo:')
                ..writeln('• Combates totales: ${report.totalMatches}')
                ..writeln('• Puntos totales anotados: ${report.totalPointsScored}')
                ..writeln('• Acabados: Spin (${report.spinFinishesCount}) · Over (${report.overFinishesCount}) · Burst (${report.burstFinishesCount}) · Xtreme (${report.xtremeFinishesCount})')
                ..writeln('')
                ..writeln('Generado por BeyScore Hub LAN');

              Clipboard.setData(ClipboardData(text: text.toString()));
              Navigator.pop(ctx);
              BeyFeedbackDialog.showSuccess(
                context,
                title: 'Reporte Copiado al Portapapeles',
                message: 'Pega este reporte oficial en WhatsApp, Telegram o Discord.',
              );
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.description_outlined, size: 16, color: AppColors.pegasus),
            label: const Text('ACTA OFICIAL', style: TextStyle(color: AppColors.pegasus, fontWeight: FontWeight.bold)),
            onPressed: () {
              const auditService = ArbitrationAuditService();
              final ledger = OfficialTournamentLedger(
                tournamentName: _currentTournament.name,
                tierLabel: _currentTournament.tier.label,
                divisionLabel: _currentTournament.ageDivision.label,
                champion: report.firstPlace,
                runnerUp: report.secondPlace,
                thirdPlace: report.thirdPlace,
                totalMatches: report.totalMatches,
                totalParticipants: _currentTournament.participants.length,
                auditLogs: const [],
                generatedAt: DateTime.now(),
              );

              final markdown = auditService.formatLedgerToMarkdown(ledger);
              Clipboard.setData(ClipboardData(text: markdown));
              Navigator.pop(ctx);
              BeyFeedbackDialog.showSuccess(
                context,
                title: 'Acta Oficial Copiada',
                message: 'Acta formal de clausura copiada en formato Markdown para archivo oficial.',
              );
            },
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CERRAR', style: TextStyle(color: AppColors.mute)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = _currentTournament;
    final isRegistration = t.status == TournamentStatus.registration || t.rounds.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.void_,
      appBar: AppBar(
        backgroundColor: AppColors.steel,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.name.toUpperCase(),
              style: AppTypography.displaySmall.copyWith(fontSize: 15, letterSpacing: 1.1),
            ),
            Text(
              '${t.tier.label} · ${t.ageDivision.label} · ${t.status.label.toUpperCase()}',
              style: AppTypography.mono.copyWith(fontSize: 9.5, color: AppColors.mute),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events_outlined, color: AppColors.pegasus),
            tooltip: 'Podio & Reporte de Torneo',
            onPressed: _showTournamentReportDialog,
          ),
        ],
        bottom: MediaQuery.sizeOf(context).width >= 720
            ? null
            : TabBar(
                controller: _tabController,
                indicatorColor: AppColors.x,
                labelColor: AppColors.x,
                unselectedLabelColor: AppColors.mute,
                tabs: [
                  const Tab(text: 'MESAS Y HUB LAN'),
                  Tab(text: 'INSCRITOS (${t.participants.length})'),
                ],
              ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTabletOrDesktop = constraints.maxWidth >= 720;

          return Column(
            children: [
              _buildTournamentStepper(),
              if (isTabletOrDesktop)
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 48,
                        child: _buildHubTab(isRegistration),
                      ),
                      Container(width: 1, color: AppColors.line),
                      Expanded(
                        flex: 52,
                        child: _buildParticipantsTab(isRegistration),
                      ),
                    ],
                  ),
                )
              else
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildHubTab(isRegistration),
                      _buildParticipantsTab(isRegistration),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTournamentStepper() {
    final t = _currentTournament;
    final int currentStep;
    if (t.status == TournamentStatus.completed) {
      currentStep = 4;
    } else if (t.status == TournamentStatus.inProgress && t.rounds.isNotEmpty) {
      final lastRound = t.rounds.last;
      final isFinal = lastRound.matchups.length <= 2;
      currentStep = isFinal ? 3 : 2;
    } else {
      currentStep = 1;
    }

    final steps = [
      (1, 'INSCRIPCIÓN', Icons.app_registration_rounded),
      (2, 'RONDAS', Icons.sports_mma_rounded),
      (3, 'FASE FINAL', Icons.military_tech_rounded),
      (4, 'PODIO', Icons.emoji_events_rounded),
    ];

    return Container(
      color: AppColors.steel,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: steps.map((s) {
            final stepNum = s.$1;
            final label = s.$2;
            final icon = s.$3;
            final isCompleted = currentStep > stepNum;
            final isCurrent = currentStep == stepNum;

            final color = isCurrent
                ? AppColors.x
                : (isCompleted ? AppColors.pegasus : AppColors.mute);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(isCompleted ? Icons.check_circle : icon, size: 13, color: color),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: AppTypography.mono.copyWith(
                      fontSize: 9,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: color,
                    ),
                  ),
                  if (stepNum < 4) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.chevron_right, size: 11, color: AppColors.line),
                  ],
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildHubTab(bool isRegistration) {
    return StreamBuilder<Map<int, TableStatus>>(
      stream: _hubServer.tablesStream,
      initialData: _hubServer.currentTables,
      builder: (context, snapshot) {
        final tables = snapshot.data ?? {};

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Registration banner notice if registration is open
              if (isRegistration)
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.pegasus.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.pegasus.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.pegasus, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'El torneo está en fase de inscripción (${_currentTournament.participants.length} Bladers inscritos). Ve a la pestaña "INSCRITOS" para revisar decks y generar el bracket.',
                          style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.text),
                        ),
                      ),
                    ],
                  ),
                ),

              // Hub LAN Controls
              ChamferCard(
                borderColor: _isHubRunning ? AppColors.x.withValues(alpha: 0.4) : AppColors.line2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.wifi, size: 16, color: _isHubRunning ? AppColors.x : AppColors.mute),
                            const SizedBox(width: 8),
                            Text(
                              'SERVIDOR LOCAL LAN',
                              style: AppTypography.mono.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.mute,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                        if (_isHubRunning)
                          Text(
                            _hubServer.hubUrl,
                            style: AppTypography.mono.copyWith(
                              fontSize: 10,
                              color: AppColors.x,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isHubRunning
                          ? 'Las tablets de mesa se conectan a tu teléfono por Wi-Fi local sin consumir datos ni internet.'
                          : 'Inicia el servidor local para emparejar las mesas mediante QR y recibir marcadores en vivo.',
                      style: const TextStyle(fontSize: 11.5, color: AppColors.mute, height: 1.3),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ChamferButton(
                            text: _isHubRunning ? 'Detener Hub LAN' : 'Levantar Hub LAN',
                            variant: _isHubRunning ? ChamferButtonVariant.ghost : ChamferButtonVariant.go,
                            height: 36,
                            onPressed: _toggleHub,
                          ),
                        ),
                        if (_isHubRunning) ...[
                          const SizedBox(width: 8),
                          IconButton.filled(
                            tooltip: 'QR de Inscripción para Jugadores (LAN)',
                            style: IconButton.styleFrom(backgroundColor: AppColors.steel, foregroundColor: AppColors.x),
                            icon: const Icon(Icons.qr_code_2_rounded, size: 20),
                            onPressed: _showRegistrationQrDialog,
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(
                            tooltip: 'Centro de Emisión, OBS & Pantallas',
                            style: IconButton.styleFrom(backgroundColor: AppColors.steel, foregroundColor: AppColors.pegasus),
                            icon: const Icon(Icons.broadcast_on_personal_rounded, size: 20),
                            onPressed: _showBroadcastSharingDialog,
                          ),
                        ],
                      ],
                    ),
                    if (_isHubRunning) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.steel,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.auto_mode_rounded, size: 16, color: AppColors.x),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'DESPACHO INTELIGENTE DE MESAS',
                                      style: AppTypography.mono.copyWith(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppColors.text),
                                    ),
                                    Text(
                                      'Auto-asigna el próximo combate al liberarse una mesa.',
                                      style: AppTypography.bodySmall.copyWith(fontSize: 9, color: AppColors.mute),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Switch(
                              value: _isSmartDispatcherEnabled,
                              activeThumbColor: AppColors.x,
                              onChanged: (val) {
                                setState(() => _isSmartDispatcherEnabled = val);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(val ? 'Despacho inteligente de mesas activado' : 'Despacho automático desactivado'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Live Tables Panel
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'MESAS ASIGNADAS (${tables.length})',
                    style: AppTypography.mono.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: AppColors.mute,
                    ),
                  ),
                  Text(
                    'WEBSOCKET LAN EN TIEMPO REAL',
                    style: AppTypography.mono.copyWith(
                      fontSize: 9,
                      color: AppColors.x,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (tables.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.panel,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: const Center(
                    child: Text(
                      'No hay mesas asignadas aún. Genera el bracket y activa el Hub LAN.',
                      style: TextStyle(color: AppColors.mute, fontSize: 11.5),
                    ),
                  ),
                )
              else
                ...tables.values.map((table) {
                  final isDispute = table.status == 'DISPUTE';
                  final isConfirmed = table.status == 'CONFIRMED';
                  final lastSeenSec = DateTime.now().difference(table.lastSeen).inSeconds;
                  final isOnline = lastSeenSec < 12;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ChamferCard(
                      borderColor: isDispute
                          ? AppColors.dranzer
                          : isConfirmed
                              ? AppColors.x.withValues(alpha: 0.4)
                              : AppColors.line2,
                      backgroundColor: isDispute
                          ? AppColors.dranzer.withValues(alpha: 0.08)
                          : AppColors.panel,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.steel,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      'MESA ${table.tableNumber}',
                                      style: AppTypography.mono.copyWith(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.text,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${table.playerA} vs ${table.playerB}',
                                    style: AppTypography.displaySmall.copyWith(fontSize: 13),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.qr_code, size: 16, color: AppColors.x),
                                    tooltip: 'Generar QR de emparejamiento',
                                    onPressed: () => _showTablePairingQrDialog(table.tableNumber),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isDispute
                                          ? AppColors.dranzer
                                          : isConfirmed
                                              ? AppColors.x.withValues(alpha: 0.2)
                                              : AppColors.panel2,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      isDispute
                                          ? 'DESACUERDO'
                                          : isConfirmed
                                              ? 'CONFIRMADO'
                                              : 'EN COMBATE',
                                      style: AppTypography.mono.copyWith(
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                        color: isDispute
                                            ? AppColors.text
                                            : isConfirmed
                                                ? AppColors.x
                                                : AppColors.mute,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'MARCADOR: ${table.scoreA} — ${table.scoreB}',
                                    style: AppTypography.mono.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isDispute ? AppColors.dranzer : AppColors.text,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isOnline ? AppColors.x : AppColors.mute,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isOnline ? 'Online' : 'Inactiva (${lastSeenSec}s)',
                                    style: AppTypography.mono.copyWith(fontSize: 8, color: AppColors.mute),
                                  ),
                                ],
                              ),
                              if (isDispute)
                                ChamferButton(
                                  text: 'Resolver Disputa',
                                  variant: ChamferButtonVariant.danger,
                                  height: 30,
                                  onPressed: () => _openDisputeResolutionDialog(table),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 16),

              if (!isRegistration) ...[
                ChamferButton(
                  text: 'Cerrar Ronda y Asignar Mesas',
                  variant: ChamferButtonVariant.go,
                  onPressed: () {
                    _assignCurrentRoundMatchesToHub();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ronda consolidada · Nuevas mesas asignadas al Hub LAN'),
                        backgroundColor: AppColors.steel,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildParticipantsTab(bool isRegistration) {
    final participants = _currentTournament.participants;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Registration Status Header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.panel,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isRegistration ? 'INSCRIPCIONES ABIERTAS' : 'BRACKET ACTIVO',
                      style: AppTypography.mono.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isRegistration ? AppColors.x : AppColors.dragoon,
                      ),
                    ),
                    Text(
                      '${participants.length} INSCRITOS',
                      style: AppTypography.mono.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.pegasus,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Verifica los Decks 3on3 de cada Blader antes de iniciar el sorteo de llaves.',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.mute, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Add offline participant input & QR Pass Fast Check-in
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _offlineBladerController,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.text),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.steel,
                    hintText: 'Inscribir o escanear Pase QR...',
                    hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.mute),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.line),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onSubmitted: (val) {
                    if (val.startsWith('beyscore://checkin')) {
                      final uri = Uri.tryParse(val);
                      final nick = uri?.queryParameters['nickname'];
                      if (nick != null && nick.isNotEmpty) {
                        _offlineBladerController.text = nick;
                        _addOfflineBlader();
                        return;
                      }
                    }
                    _addOfflineBlader();
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                tooltip: 'Inscribir Blader',
                onPressed: () {
                  final val = _offlineBladerController.text.trim();
                  if (val.startsWith('beyscore://checkin')) {
                    final uri = Uri.tryParse(val);
                    final nick = uri?.queryParameters['nickname'];
                    if (nick != null && nick.isNotEmpty) {
                      _offlineBladerController.text = nick;
                    }
                  }
                  _addOfflineBlader();
                },
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.x,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Participants List
          if (participants.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.panel,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.line),
              ),
              child: const Center(
                child: Text(
                  'No hay Bladers inscritos todavía.',
                  style: TextStyle(color: AppColors.mute, fontSize: 12),
                ),
              ),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'BLADERS INSCRITOS (${participants.length})',
                    style: AppTypography.mono.copyWith(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.mute),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _verifiedCheckIns.length == participants.length && participants.isNotEmpty
                          ? const Color(0xFF00FF66).withValues(alpha: 0.12)
                          : AppColors.dranzer.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: _verifiedCheckIns.length == participants.length && participants.isNotEmpty
                            ? const Color(0xFF00FF66)
                            : AppColors.dranzer,
                      ),
                    ),
                    child: Text(
                      'LISTOS: ${_verifiedCheckIns.length}/${participants.length}',
                      style: AppTypography.mono.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _verifiedCheckIns.length == participants.length && participants.isNotEmpty
                            ? const Color(0xFF00FF66)
                            : AppColors.dranzer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...participants.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final name = entry.value;
              final isVerified = _verifiedCheckIns.contains(name);

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.panel,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isVerified ? const Color(0xFF00FF66).withValues(alpha: 0.6) : AppColors.line),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.steel,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '#$index',
                        style: AppTypography.mono.copyWith(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.dragoon),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name.toUpperCase(),
                            style: AppTypography.mono.copyWith(fontWeight: FontWeight.bold, fontSize: 12.5),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(
                                isVerified ? Icons.verified : Icons.pending_outlined,
                                size: 12,
                                color: isVerified ? const Color(0xFF00FF66) : AppColors.dranzer,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isVerified ? 'LISTO (DECK APROBADO)' : 'NO LISTO (DECK PENDIENTE)',
                                style: AppTypography.mono.copyWith(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  color: isVerified ? const Color(0xFF00FF66) : AppColors.dranzer,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(Icons.remove_red_eye_outlined, size: 14, color: AppColors.pegasus),
                      label: Text('VER DECK', style: AppTypography.mono.copyWith(fontSize: 10, color: AppColors.pegasus, fontWeight: FontWeight.bold)),
                      onPressed: () => _showDeckInspectionSheet(name),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.mute),
                      onPressed: () => _removeBlader(name),
                    ),
                  ],
                ),
              );
            }),
          ],

          const SizedBox(height: 20),

          const SizedBox(height: 20),

          // Action buttons depending on tournament state
          if (_currentTournament.status == TournamentStatus.registration || _currentTournament.status == TournamentStatus.draft)
            ChamferButton(
              text: 'CERRAR INSCRIPCIÓN Y PASAR A CHECK-IN (${participants.length}P)',
              variant: participants.length >= 2 ? ChamferButtonVariant.go : ChamferButtonVariant.ghost,
              onPressed: participants.length >= 2 ? _closeRegistrationAndStartCheckIn : null,
            )
          else if (_currentTournament.status == TournamentStatus.checkIn)
            ChamferButton(
              text: 'SORTEAR BRACKET E INICIAR TORNEO (${participants.length}P)',
              variant: participants.length >= 2 ? ChamferButtonVariant.go : ChamferButtonVariant.ghost,
              onPressed: participants.length >= 2 ? _generateBracketAndStart : null,
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
