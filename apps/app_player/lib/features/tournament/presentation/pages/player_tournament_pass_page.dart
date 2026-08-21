import 'dart:async';

import 'package:bey_domain/bey_domain.dart';
import 'package:bey_hub/bey_hub.dart';
import 'package:bey_ui/bey_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/di/injector.dart';
import 'player_tournaments_page.dart';

class PlayerTournamentPassPage extends StatefulWidget {
  const PlayerTournamentPassPage({
    super.key,
    required this.tournamentId,
  });

  final String tournamentId;

  @override
  State<PlayerTournamentPassPage> createState() => _PlayerTournamentPassPageState();
}

class _PlayerTournamentPassPageState extends State<PlayerTournamentPassPage> {
  final _tournamentRepo = getIt<TournamentRepository>();
  final _identityRepo = getIt<IdentityRepository>();
  final _deckRepo = getIt<DeckRepository>();
  final _comboRepo = getIt<ComboRepository>();
  final _clientService = TableClientService();
  final _realtimeClient = HubRealtimeClient();
  StreamSubscription<HubEvent>? _realtimeSub;

  Tournament? _tournament;
  UserProfile? _profile;
  Deck? _deck;
  List<Combo> _combos = [];
  bool _isLoading = true;
  Timer? _pollingTimer;
  PlayerHubStatus? _hubStatus;

  @override
  void initState() {
    super.initState();
    _loadData();
    _initRealtimeHub();
    _startHubPolling();
  }

  @override
  void dispose() {
    _realtimeSub?.cancel();
    _realtimeClient.dispose();
    _pollingTimer?.cancel();
    super.dispose();
  }

  String _resolveHubUrl() {
    var host = PlayerTournamentsPage.lastHubHost.trim();
    if (host.startsWith('http://')) host = host.substring(7);
    if (host.startsWith('https://')) host = host.substring(8);
    var port = 8080;
    if (host.contains(':')) {
      final parts = host.split(':');
      host = parts[0];
      final p = int.tryParse(parts[1].replaceAll(RegExp('[^0-9]'), ''));
      if (p != null) port = p;
    }
    if (host.endsWith('/')) host = host.substring(0, host.length - 1);
    return 'http://$host:$port';
  }

  void _initRealtimeHub() {
    _realtimeSub?.cancel();
    _realtimeSub = _realtimeClient.events.listen((event) {
      if (!mounted) return;
      final myNick = (_profile?.nickname ?? '').trim().toLowerCase();
      if (myNick.isEmpty) return;

      switch (event.type) {
        case HubEventType.matchAssigned:
          final pA = (event.payload['playerA'] as String? ?? '').trim().toLowerCase();
          final pB = (event.payload['playerB'] as String? ?? '').trim().toLowerCase();
          final table = event.payload['tableNumber'] as int? ?? event.payload['table'] as int?;

          if ((pA == myNick || pB == myNick) && table != null) {
            final opponent = pA == myNick ? event.payload['playerB'] : event.payload['playerA'];
            unawaited(HapticFeedback.heavyImpact());
            unawaited(BeyAudioService.instance.playGoShoot());
            if (mounted) {
              unawaited(
                BeyFeedbackDialog.showInfo(
                  context,
                  title: '¡LLAMADO A COMBATE!',
                  message: 'Has sido asignado a la MESA $table contra $opponent.\n\nPresenta tu código QR en la mesa para iniciar.',
                  confirmText: '¡ENTENDIDO!',
                ),
              );
            }
          }
        case HubEventType.checkInVerified:
          final nick = (event.payload['nickname'] as String? ?? '').trim().toLowerCase();
          if (nick == myNick) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Tu Deck 3on3 ha sido aprobado por el juez!'),
                backgroundColor: Color(0xFF00FF66),
                duration: Duration(seconds: 3),
              ),
            );
          }
        case HubEventType.checkInRejected:
          final nick = (event.payload['nickname'] as String? ?? '').trim().toLowerCase();
          if (nick == myNick) {
            final reason = event.payload['rejectionReason'] as String? ?? 'No cumple con el reglamento';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Deck rechazado: $reason'),
                backgroundColor: const Color(0xFFFF3B2F),
                duration: const Duration(seconds: 4),
              ),
            );
          }
        case HubEventType.scoreUpdated:
          final pA = (event.payload['playerA'] as String? ?? '').trim().toLowerCase();
          final pB = (event.payload['playerB'] as String? ?? '').trim().toLowerCase();
          if (pA == myNick || pB == myNick) {
            final myScore = pA == myNick ? (event.payload['scoreA'] as int? ?? 0) : (event.payload['scoreB'] as int? ?? 0);
            final oppScore = pA == myNick ? (event.payload['scoreB'] as int? ?? 0) : (event.payload['scoreA'] as int? ?? 0);
            final tableStatus = event.payload['status'] as String? ?? 'RUNNING';

            if (_hubStatus != null) {
              setState(() {
                _hubStatus = PlayerHubStatus(
                  nickname: _hubStatus!.nickname,
                  isRegistered: _hubStatus!.isRegistered,
                  checkInVerified: _hubStatus!.checkInVerified,
                  isRejected: _hubStatus!.isRejected,
                  rejectionReason: _hubStatus!.rejectionReason,
                  assignedTable: _hubStatus!.assignedTable,
                  opponent: _hubStatus!.opponent,
                  myScore: myScore,
                  opponentScore: oppScore,
                  tableStatus: tableStatus,
                  tournamentStatus: _hubStatus!.tournamentStatus,
                );
              });
            }
          }
        case HubEventType.disputeFlagged:
        case HubEventType.tournamentUpdated:
        case HubEventType.heartbeat:
        case HubEventType.unknown:
          break;
      }
    });
  }

  void _startHubPolling() {
    _pollingTimer = Timer.periodic(const Duration(milliseconds: 3000), (_) async {
      final nickname = _profile?.nickname;
      if (nickname == null || nickname.isEmpty) return;

      final hubUrl = _resolveHubUrl();

      // Ensure realtime client is connected
      if (!_realtimeClient.isConnected) {
        _realtimeClient.connect(
          hubUrl: hubUrl,
          playerNickname: nickname,
        );
      }

      final status = await _clientService.fetchPlayerStatus(
        hubUrl: hubUrl,
        nickname: nickname,
      );

      if (mounted && status != null) {
        final wasNotAssigned = _hubStatus?.assignedTable == null;
        final wasNotVerified = _hubStatus?.checkInVerified != true;

        setState(() => _hubStatus = status);

        if (status.checkInVerified && wasNotVerified) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Tu Deck 3on3 ha sido aprobado por el juez!'),
              backgroundColor: Color(0xFF00FF66),
              duration: Duration(seconds: 3),
            ),
          );
        }

        if (status.assignedTable != null && wasNotAssigned) {
          unawaited(HapticFeedback.heavyImpact());
          unawaited(BeyAudioService.instance.playGoShoot());
          if (mounted) {
            unawaited(
              BeyFeedbackDialog.showInfo(
                context,
                title: '¡LLAMADO A COMBATE!',
                message: 'Has sido asignado a la MESA ${status.assignedTable} contra ${status.opponent ?? 'tu rival'}.\n\nPresenta tu código QR en la mesa para iniciar.',
                confirmText: '¡ENTENDIDO!',
              ),
            );
          }
        }
      }
    });
  }

  Future<void> _loadData() async {
    final profile = await _identityRepo.getActiveProfile();
    final tournament = await _tournamentRepo.watchById(widget.tournamentId).first;
    final decks = await _deckRepo.watchAll().first;
    final combos = await _comboRepo.watchAll().first;

    final deck = decks.isNotEmpty ? decks.first : null;
    final deckCombos = deck != null
        ? deck.comboIds.map((id) => combos.firstWhere((c) => c.id == id, orElse: () => combos.first)).toList()
        : <Combo>[];

    if (mounted) {
      setState(() {
        _profile = profile;
        _tournament = tournament;
        _deck = deck;
        _combos = deckCombos;
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

    final t = _tournament;
    final nickname = _profile?.nickname.toUpperCase() ?? 'BLADER';
    final qrData = 'beyscore://checkin?tournament=${widget.tournamentId}&blader=$nickname';

    return Scaffold(
      backgroundColor: AppColors.void_,
      appBar: AppBar(
        backgroundColor: AppColors.steel,
        title: Text(
          'PASE DE CHEQUEO DE DECK',
          style: AppTypography.mono.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Live Match / Turn Alert Banner
            if (_hubStatus?.assignedTable != null)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.x.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.x, width: 2),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.flash_on, color: AppColors.x, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          '¡ES TU TURNO DE COMBATIR!',
                          style: AppTypography.mono.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.x,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Preséntate de inmediato en MESA ${_hubStatus!.assignedTable}',
                      style: AppTypography.displayMedium.copyWith(fontSize: 17),
                    ),
                    if (_hubStatus?.opponent != null && _hubStatus!.opponent!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'RIVAL: ${_hubStatus!.opponent!.toUpperCase()}  ·  Marcador en vivo: ${_hubStatus!.myScore} - ${_hubStatus!.opponentScore}',
                        style: AppTypography.mono.copyWith(fontSize: 11, color: AppColors.pegasus),
                      ),
                    ],
                  ],
                ),
              )
            else if (_hubStatus?.isRejected == true)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.dranzer.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.dranzer, width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.dranzer, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DECK RECHAZADO POR EL JUEZ',
                            style: AppTypography.mono.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.dranzer,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _hubStatus?.rejectionReason ?? 'Revisa tus piezas en la mesa de control.',
                            style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.text),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else if (_hubStatus?.checkInVerified == true)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF00FF66).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF00FF66)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Color(0xFF00FF66), size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Check-in verificado por el juez. Esperando asignación de mesa...',
                        style: AppTypography.mono.copyWith(fontSize: 11, color: const Color(0xFF00FF66)),
                      ),
                    ),
                  ],
                ),
              ),

            // Instruction header
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.x.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.x),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified, color: AppColors.x, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Enséñale este pase QR al juez en la mesa de control junto con tu caja de deck.',
                      style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.text),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // QR Code Container Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.panel,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.line2),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 180,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    nickname,
                    style: AppTypography.displayMedium.copyWith(fontSize: 18, color: AppColors.x),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_deck?.name.toUpperCase() ?? 'DECK 3ON3'} · ${t?.name ?? 'TORNEO OFICIAL'}',
                    style: AppTypography.mono.copyWith(fontSize: 10.5, color: AppColors.mute),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3 Beys Lineup Card
            Text(
              'ALINEACIÓN OFICIAL DECLARADA (3 BEYS)',
              style: AppTypography.mono.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.mute,
              ),
            ),
            const SizedBox(height: 8),

            ..._combos.asMap().entries.map((entry) {
              final idx = entry.key + 1;
              final combo = entry.value;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.panel,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.steel,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'BEY #$idx',
                        style: AppTypography.mono.copyWith(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.x),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            combo.name.toUpperCase(),
                            style: AppTypography.mono.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            '${combo.bladeId.replaceAll('blade-', '')} · ${combo.ratchetId.replaceAll('ratchet-', '')} · ${combo.bitId.replaceAll('bit-', '')}',
                            style: AppTypography.bodySmall.copyWith(fontSize: 10, color: AppColors.mute),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 16),

            // Warning note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.dranzer.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.dranzer.withValues(alpha: 0.4)),
              ),
              child: Text(
                'El orden de los 3 Beys (1, 2, 3) queda bloqueado tras la revisión y no se puede alterar durante la fase eliminatoria.',
                style: AppTypography.bodySmall.copyWith(fontSize: 10.5, color: AppColors.mute),
              ),
            ),
            const SizedBox(height: 20),

            // View Bracket Button
            ChamferButton(
              text: 'VER CUADRO Y BRACKET DEL TORNEO',
              variant: ChamferButtonVariant.go,
              onPressed: () {
                context.push('/tournaments/${widget.tournamentId}/bracket');
              },
            ),
          ],
        ),
      ),
    );
  }
}
