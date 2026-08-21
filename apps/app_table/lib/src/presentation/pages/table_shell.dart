import 'dart:async';
import 'package:bey_hub/bey_hub.dart';
import 'package:bey_ui/bey_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum TableModePhase {
  pairing, // 01 Emparejar (token / IP / Mesa #)
  idle, // 02 Reposo (Mesa X esperando combate)
  prep, // 03-04 Preparación / Ready
  countdown, // 05 Cuenta atrás 3-2-1
  scoring, // 06-07 Marcador simétrico en vivo
  confirm, // 08 Fin de ronda y confirmación
  dispute, // 09 La mesa no arbitra
  tournamentCompleted, // 10 Torneo Concluido
}

class TableShell extends StatefulWidget {
  const TableShell({
    super.key,
    this.tableNumber = 1,
    this.playerAName = 'BLADER 1',
    this.playerBName = 'BLADER 2',
    this.playerABey = 'Combo A',
    this.playerBBey = 'Combo B',
    this.hubUrl = 'http://127.0.0.1:8080',
    this.clientService,
  });

  final int tableNumber;
  final String playerAName;
  final String playerBName;
  final String playerABey;
  final String playerBBey;
  final String hubUrl;
  final TableClientService? clientService;

  @override
  State<TableShell> createState() => _TableShellState();
}

class _TableShellState extends State<TableShell> with TickerProviderStateMixin {
  late final TableClientService _clientService;
  final _realtimeClient = HubRealtimeClient();
  StreamSubscription<HubEvent>? _realtimeSub;

  TableModePhase _phase = TableModePhase.idle;
  late int _tableNumber;
  late String _playerAName;
  late String _playerBName;
  late String _playerABey;
  late String _playerBBey;
  late String _hubUrl;

  late final TextEditingController _hubUrlController;
  late final TextEditingController _tableNumberController;
  late final TextEditingController _qrTokenController;

  int _scoreA = 0;
  int _scoreB = 0;
  int _faultsA = 0;
  int _faultsB = 0;
  int _currentRound = 1;
  bool _readyA = false;
  bool _readyB = false;
  bool _isConnectedToHub = false;

  int _countdownNumber = 3;
  String _countdownWord = '3';
  Timer? _countdownTimer;
  Timer? _hubPollingTimer;
  Timer? _prepTimer;
  int _prepSeconds = 30;

  Timer? _undoGraceTimer;
  int _undoGraceRemainingMs = 0;
  String? _lastFinishDescription;

  final List<String> _finishHistory = [];

  @override
  void initState() {
    super.initState();
    _clientService = widget.clientService ?? TableClientService();

    _tableNumber = widget.tableNumber;
    _playerAName = widget.playerAName;
    _playerBName = widget.playerBName;
    _playerABey = widget.playerABey;
    _playerBBey = widget.playerBBey;
    _hubUrl = widget.hubUrl;

    _hubUrlController = TextEditingController(text: _hubUrl);
    _tableNumberController = TextEditingController(text: '$_tableNumber');
    _qrTokenController = TextEditingController();

    // Lock to landscape orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _initRealtimeHub();
    _startHubPolling();
  }

  @override
  void dispose() {
    _realtimeSub?.cancel();
    _realtimeClient.dispose();
    _prepTimer?.cancel();
    _countdownTimer?.cancel();
    _hubPollingTimer?.cancel();
    _undoGraceTimer?.cancel();
    _hubUrlController.dispose();
    _tableNumberController.dispose();
    _qrTokenController.dispose();
    super.dispose();
  }

  void _initRealtimeHub() {
    _realtimeSub?.cancel();
    _realtimeSub = _realtimeClient.events.listen((event) {
      if (!mounted) return;
      final targetTable = event.payload['tableNumber'] as int? ?? event.payload['table'] as int?;

      switch (event.type) {
        case HubEventType.matchAssigned:
          if (targetTable == _tableNumber) {
            final pA = event.payload['playerA'] as String? ?? '';
            final pB = event.payload['playerB'] as String? ?? '';
            if (_phase == TableModePhase.idle && pA.isNotEmpty) {
              setState(() {
                _playerAName = pA;
                _playerBName = pB;
                _scoreA = event.payload['scoreA'] as int? ?? 0;
                _scoreB = event.payload['scoreB'] as int? ?? 0;
                _readyA = false;
                _readyB = false;
                _phase = TableModePhase.prep;
                _isConnectedToHub = true;
              });
              _startPrepTimer();
            }
          }
        case HubEventType.scoreUpdated:
          if (targetTable == _tableNumber) {
            final status = event.payload['status'] as String?;
            if (_phase == TableModePhase.dispute && status == 'RUNNING') {
              setState(() {
                _scoreA = event.payload['scoreA'] as int? ?? _scoreA;
                _scoreB = event.payload['scoreB'] as int? ?? _scoreB;
                _phase = TableModePhase.scoring;
                _isConnectedToHub = true;
              });
            }
          }
        case HubEventType.tournamentUpdated:
          final tStatus = event.payload['status'] as String? ?? event.payload['tournamentStatus'] as String?;
          if (tStatus == 'completed' && _phase != TableModePhase.tournamentCompleted) {
            setState(() {
              _phase = TableModePhase.tournamentCompleted;
            });
          }
        case HubEventType.disputeFlagged:
        case HubEventType.checkInVerified:
        case HubEventType.checkInRejected:
        case HubEventType.heartbeat:
        case HubEventType.unknown:
          break;
      }
    });

    _realtimeClient.connect(
      hubUrl: _hubUrl,
      tableNumber: _tableNumber,
    );
  }

  void _startPrepTimer() {
    _prepTimer?.cancel();
    setState(() => _prepSeconds = 30);
    _prepTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_phase != TableModePhase.prep) {
        t.cancel();
        return;
      }
      if (_prepSeconds > 0) {
        setState(() => _prepSeconds--);
        if (_prepSeconds <= 3 && _prepSeconds > 0) {
          unawaited(BeyAudioService.instance.playCount(_prepSeconds));
        }
      } else {
        t.cancel();
        // Time expired: automatically launch countdown
        _startCountdown();
      }
    });
  }

  void _startHubPolling() {
    _hubPollingTimer?.cancel();
    _hubPollingTimer = Timer.periodic(const Duration(milliseconds: 2000), (timer) async {
      if (!mounted) return;

      if (!_realtimeClient.isConnected) {
        _realtimeClient.connect(
          hubUrl: _hubUrl,
          tableNumber: _tableNumber,
        );
      }

      final data = await _clientService.fetchTableStatus(
        hubUrl: _hubUrl,
        tableNumber: _tableNumber,
      );

      if (!mounted) return;

      if (data != null) {
        if (!_isConnectedToHub) {
          setState(() => _isConnectedToHub = true);
        }

        // When in IDLE, if hub assigns match, automatically load it and start 30s prep timer
        if (_phase == TableModePhase.idle && data.status == 'RUNNING' && data.playerA.isNotEmpty) {
          setState(() {
            _playerAName = data.playerA;
            _playerBName = data.playerB;
            _scoreA = data.scoreA;
            _scoreB = data.scoreB;
            _readyA = false;
            _readyB = false;
            _phase = TableModePhase.prep;
          });
          _startPrepTimer();
        }

        // When tournament completes
        if (data.status == 'COMPLETED' && _phase != TableModePhase.tournamentCompleted) {
          setState(() {
            _phase = TableModePhase.tournamentCompleted;
          });
        }

        // When in DISPUTE, if judge resolved it, apply scores and resume scoring
        if (_phase == TableModePhase.dispute && data.status == 'RUNNING') {
          setState(() {
            _scoreA = data.scoreA;
            _scoreB = data.scoreB;
            _phase = TableModePhase.scoring;
          });
        }
      } else {
        if (_isConnectedToHub && !_realtimeClient.isConnected) {
          setState(() => _isConnectedToHub = false);
        }
      }
    });
  }

  Color? _flashColor;
  Timer? _flashTimer;

  void _triggerFlash(Color color) {
    _flashTimer?.cancel();
    setState(() => _flashColor = color.withValues(alpha: 0.22));
    _flashTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _flashColor = null);
    });
  }

  void _startCountdown() {
    _prepTimer?.cancel();
    setState(() {
      _phase = TableModePhase.countdown;
      _countdownNumber = 3;
      _countdownWord = '3';
    });

    unawaited(HapticFeedback.selectionClick());
    unawaited(BeyAudioService.instance.playCount(3));

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(milliseconds: 900), (timer) {
      if (!mounted) return;
      setState(() {
        if (_countdownNumber == 3) {
          _countdownNumber = 2;
          _countdownWord = '2';
          unawaited(HapticFeedback.selectionClick());
          unawaited(BeyAudioService.instance.playCount(2));
        } else if (_countdownNumber == 2) {
          _countdownNumber = 1;
          _countdownWord = '1';
          unawaited(HapticFeedback.selectionClick());
          unawaited(BeyAudioService.instance.playCount(1));
        } else if (_countdownNumber == 1) {
          _countdownNumber = 0;
          _countdownWord = BeyAudioService.instance.language == AnnouncerLanguage.spanish
              ? '¡LANZAMIENTO!'
              : 'GO SHOOT!';
          unawaited(HapticFeedback.heavyImpact());
          unawaited(BeyAudioService.instance.playGoShoot());
        } else {
          timer.cancel();
          _phase = TableModePhase.scoring;
        }
      });
    });
  }

  void _syncScoresToHub({String? finishType, bool isPenalty = false}) {
    _clientService.sendScore(
      hubUrl: _hubUrl,
      tableNumber: _tableNumber,
      scoreA: _scoreA,
      scoreB: _scoreB,
      finishType: finishType,
      isPenalty: isPenalty,
    );
  }

  void _triggerUndoGrace(String description) {
    _lastFinishDescription = description;
    _undoGraceRemainingMs = 5000;
    _undoGraceTimer?.cancel();
    _undoGraceTimer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_undoGraceRemainingMs > 100) {
        setState(() => _undoGraceRemainingMs -= 100);
      } else {
        t.cancel();
        setState(() => _undoGraceRemainingMs = 0);
      }
    });
  }

  void _addFinish(String player, String finishType, int points) {
    setState(() {
      if (player == 'A') {
        _scoreA += points;
      } else {
        _scoreB += points;
      }
      _finishHistory.add('$player:$finishType:$points');
      _faultsA = 0;
      _faultsB = 0;
      _currentRound++;
    });

    final flashColor = switch (finishType.toUpperCase()) {
      'XTREME' => AppColors.x,
      'BURST' => AppColors.burst,
      'OVER' => AppColors.pegasus,
      _ => AppColors.dragoon,
    };
    _triggerFlash(flashColor);

    // Haptic feedback tailored to finish impact
    if (finishType.toUpperCase() == 'XTREME') {
      unawaited(HapticFeedback.heavyImpact());
    } else if (finishType.toUpperCase() == 'BURST' || finishType.toUpperCase() == 'OVER') {
      unawaited(HapticFeedback.mediumImpact());
    } else {
      unawaited(HapticFeedback.lightImpact());
    }

    _triggerUndoGrace('${player == 'A' ? _playerAName : _playerBName} +$points ($finishType)');
    unawaited(BeyAudioService.instance.playFinish(finishType));
    _syncScoresToHub(finishType: finishType);
  }

  void _selectFault(String player, int level) {
    if (player == 'A') {
      if (_faultsA == level) {
        setState(() => _faultsA = 0);
        return;
      }
      if (level == 1) {
        setState(() => _faultsA = 1);
        unawaited(HapticFeedback.lightImpact());
        unawaited(BeyAudioService.instance.playFault());
      } else if (level == 2) {
        setState(() {
          _faultsA = 0;
          _scoreB += 1;
          _finishHistory.add('B:PENALTY:1');
          _currentRound++;
        });
        _triggerFlash(AppColors.dranzer);
        _triggerUndoGrace('PUNTO POR PENALIZACIÓN (+1 A $_playerBName)');
        unawaited(HapticFeedback.vibrate());
        unawaited(BeyAudioService.instance.playFault());
        _syncScoresToHub(isPenalty: true, finishType: 'PENALTY');
      }
    } else {
      if (_faultsB == level) {
        setState(() => _faultsB = 0);
        return;
      }
      if (level == 1) {
        setState(() => _faultsB = 1);
        unawaited(HapticFeedback.lightImpact());
        unawaited(BeyAudioService.instance.playFault());
      } else if (level == 2) {
        setState(() {
          _faultsB = 0;
          _scoreA += 1;
          _finishHistory.add('A:PENALTY:1');
          _currentRound++;
        });
        _triggerFlash(AppColors.dragoon);
        _triggerUndoGrace('PUNTO POR PENALIZACIÓN (+1 A $_playerAName)');
        unawaited(HapticFeedback.vibrate());
        unawaited(BeyAudioService.instance.playFault());
        _syncScoresToHub(isPenalty: true, finishType: 'PENALTY');
      }
    }
  }

  void _undo() {
    _undoGraceTimer?.cancel();
    setState(() => _undoGraceRemainingMs = 0);

    if (_finishHistory.isEmpty) return;
    final last = _finishHistory.removeLast();
    final parts = last.split(':');
    final player = parts[0];
    final points = int.parse(parts[2]);

    setState(() {
      if (player == 'A') {
        _scoreA = (_scoreA - points).clamp(0, 99);
      } else {
        _scoreB = (_scoreB - points).clamp(0, 99);
      }
      if (_currentRound > 1) _currentRound--;
    });

    _syncScoresToHub();
  }

  Future<void> _notifyDispute() async {
    setState(() => _phase = TableModePhase.dispute);
    await _clientService.sendDispute(
      hubUrl: _hubUrl,
      tableNumber: _tableNumber,
    );
  }

  Future<void> _confirmAndFinishMatch() async {
    await _clientService.sendConfirm(
      hubUrl: _hubUrl,
      tableNumber: _tableNumber,
    );

    setState(() {
      _scoreA = 0;
      _scoreB = 0;
      _currentRound = 1;
      _finishHistory.clear();
      _phase = TableModePhase.idle;
    });
  }

  void _parseQrPairingToken(String tokenUri) {
    final token = TablePairingToken.fromQrString(tokenUri);
    if (token != null && token.isValid('beyscore-secret-key')) {
      setState(() {
        _tableNumber = token.tableNumber;
        _hubUrl = token.hubUrl;
        _phase = TableModePhase.idle;
      });
      _startHubPolling();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.void_,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: switch (_phase) {
            TableModePhase.pairing => _buildPairingView(),
            TableModePhase.idle => _buildIdleView(),
            TableModePhase.prep => _buildPrepView(),
            TableModePhase.countdown => _buildCountdownView(),
            TableModePhase.scoring => _buildScoringView(),
            TableModePhase.confirm => _buildConfirmView(),
            TableModePhase.dispute => _buildDisputeView(),
            TableModePhase.tournamentCompleted => _buildTournamentCompletedView(),
          },
        ),
      ),
    );
  }

  // 01 Pairing View
  Widget _buildPairingView() {
    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'CONFIGURAR Y EMPAREJAR MESA',
                  style: AppTypography.displayMedium.copyWith(fontSize: 22),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ingresa la IP del Hub Organizador o pega el token QR de la mesa.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.mute, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _hubUrlController,
                        decoration: const InputDecoration(
                          labelText: 'URL o IP del Hub Organizador',
                          hintText: 'http://192.168.1.50:8080',
                          prefixIcon: Icon(Icons.wifi_tethering, color: AppColors.x),
                          border: OutlineInputBorder(),
                        ),
                        style: AppTypography.mono.copyWith(fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      tooltip: 'Auto-detectar Hub en Wi-Fi',
                      style: IconButton.styleFrom(backgroundColor: AppColors.x, foregroundColor: Colors.black),
                      onPressed: () async {
                        final disc = LanDiscoveryService();
                        final foundUrl = await disc.discoverHubUrl();
                        if (foundUrl != null && mounted) {
                          setState(() {
                            _hubUrl = foundUrl;
                            _hubUrlController.text = foundUrl;
                          });
                          unawaited(
                            BeyFeedbackDialog.showSuccess(
                              context,
                              title: 'Hub Encontrado',
                              message: 'Se sincronizó automáticamente con el Hub en $foundUrl.',
                            ),
                          );
                        } else if (mounted) {
                          unawaited(
                            BeyFeedbackDialog.showError(
                              context,
                              title: 'Hub No Encontrado',
                              message: 'No se detectó un Hub emitiendo en esta red Wi-Fi.',
                              solution: 'Asegúrate de que la app de organizador tenga el Hub LAN levantado y que ambos dispositivos estén en la misma red Wi-Fi.',
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.radar),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _tableNumberController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Número de Mesa',
                    hintText: '1',
                    prefixIcon: Icon(Icons.pin, color: AppColors.x),
                    border: OutlineInputBorder(),
                  ),
                  style: AppTypography.mono.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _qrTokenController,
                  decoration: const InputDecoration(
                    labelText: 'Pegar Token QR (opcional)',
                    hintText: 'beyscore://pair?...',
                    prefixIcon: Icon(Icons.qr_code, color: AppColors.x),
                    border: OutlineInputBorder(),
                  ),
                  style: AppTypography.mono.copyWith(fontSize: 11),
                  onSubmitted: _parseQrPairingToken,
                ),
                const SizedBox(height: 24),
                ChamferButton(
                  text: 'Guardar y Pasar a Reposo',
                  variant: ChamferButtonVariant.go,
                  onPressed: () {
                    if (_qrTokenController.text.trim().isNotEmpty) {
                      _parseQrPairingToken(_qrTokenController.text.trim());
                      return;
                    }
                    final num = int.tryParse(_tableNumberController.text.trim()) ?? _tableNumber;
                    setState(() {
                      _tableNumber = num;
                      _hubUrl = _hubUrlController.text.trim();
                      _phase = TableModePhase.idle;
                    });
                    _startHubPolling();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 02 Idle View (Reposo)
  Widget _buildIdleView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.panel2,
              border: Border.all(color: AppColors.x),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'MESA $_tableNumber',
              style: AppTypography.displayMedium.copyWith(fontSize: 32, color: AppColors.x),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isConnectedToHub ? AppColors.x : AppColors.dranzer,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _isConnectedToHub ? 'CONECTADO AL HUB · ESPERANDO COMBATE' : 'BUSCANDO HUB LAN ($hubHost)...',
                style: AppTypography.mono.copyWith(
                  fontSize: 11,
                  letterSpacing: 1.5,
                  color: _isConnectedToHub ? AppColors.x : AppColors.mute,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 170,
                child: ChamferButton(
                  text: 'Reconfigurar Mesa',
                  variant: ChamferButtonVariant.ghost,
                  onPressed: () => setState(() => _phase = TableModePhase.pairing),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 170,
                child: ChamferButton(
                  text: 'Combate Demo',
                  variant: ChamferButtonVariant.go,
                  onPressed: () => setState(() => _phase = TableModePhase.prep),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String get hubHost {
    try {
      final uri = Uri.parse(_hubUrl);
      return uri.host.isNotEmpty ? '${uri.host}:${uri.port}' : _hubUrl;
    } catch (_) {
      return _hubUrl;
    }
  }

  // 03-04 Preparation View (Ready tap)
  Widget _buildPrepView() {
    return Row(
      children: [
        // Player A Ready Card
        Expanded(
          child: InkWell(
            onTap: () {
              setState(() {
                _readyA = !_readyA;
                if (_readyA && _readyB) _startCountdown();
              });
            },
            child: Container(
              color: _readyA ? AppColors.dragoon.withValues(alpha: 0.25) : AppColors.steel,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _playerAName.toUpperCase(),
                    style: AppTypography.displayMedium.copyWith(fontSize: 28, color: AppColors.dragoon),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(_playerABey, style: AppTypography.mono.copyWith(color: AppColors.mute, fontSize: 11)),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: _readyA ? AppColors.dragoon : AppColors.panel,
                      border: Border.all(color: AppColors.dragoon),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _readyA ? '¡LISTO!' : 'TOCA PARA ESTAR LISTO',
                      style: AppTypography.mono.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _readyA ? AppColors.text : AppColors.dragoon,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Center Preparation Timer & VS
        Container(
          width: 140,
          color: AppColors.void_,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'PREPARACIÓN',
                style: AppTypography.mono.copyWith(fontSize: 8.5, fontWeight: FontWeight.bold, color: AppColors.mute),
              ),
              const SizedBox(height: 8),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.panel,
                  border: Border.all(
                    color: _prepSeconds <= 5
                        ? AppColors.dranzer
                        : _prepSeconds <= 10
                            ? AppColors.pegasus
                            : AppColors.x,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_prepSeconds <= 5
                              ? AppColors.dranzer
                              : _prepSeconds <= 10
                                  ? AppColors.pegasus
                                  : AppColors.x)
                          .withValues(alpha: 0.3),
                      blurRadius: 12,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  '${_prepSeconds}s',
                  style: AppTypography.mono.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _prepSeconds <= 5
                        ? AppColors.dranzer
                        : _prepSeconds <= 10
                            ? AppColors.pegasus
                            : AppColors.text,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'VS',
                style: AppTypography.displayLarge.copyWith(fontSize: 22, color: AppColors.line2),
              ),
              const SizedBox(height: 10),
              ChamferButton(
                text: 'INICIAR',
                height: 28,
                variant: ChamferButtonVariant.go,
                onPressed: _startCountdown,
              ),
            ],
          ),
        ),

        // Player B Ready Card
        Expanded(
          child: InkWell(
            onTap: () {
              setState(() {
                _readyB = !_readyB;
                if (_readyA && _readyB) _startCountdown();
              });
            },
            child: Container(
              color: _readyB ? AppColors.dranzer.withValues(alpha: 0.25) : AppColors.steel,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _playerBName.toUpperCase(),
                    style: AppTypography.displayMedium.copyWith(fontSize: 28, color: AppColors.dranzer),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(_playerBBey, style: AppTypography.mono.copyWith(color: AppColors.mute, fontSize: 11)),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: _readyB ? AppColors.dranzer : AppColors.panel,
                      border: Border.all(color: AppColors.dranzer),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _readyB ? '¡LISTO!' : 'TOCA PARA ESTAR LISTO',
                      style: AppTypography.mono.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _readyB ? AppColors.text : AppColors.dranzer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 05 Countdown View (3... 2... 1... GO SHOOT!)
  Widget _buildCountdownView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '3 · 2 · 1',
            style: AppTypography.mono.copyWith(fontSize: 16, letterSpacing: 4, color: AppColors.mute),
          ),
          const SizedBox(height: 12),
          Text(
            _countdownWord,
            style: AppTypography.displayLarge.copyWith(
              fontSize: _countdownWord.length > 2 ? 56 : 96,
              color: _countdownWord.length > 2 ? AppColors.x : AppColors.pegasus,
              shadows: [
                Shadow(
                  color: AppColors.x.withValues(alpha: 0.6),
                  blurRadius: 30,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 06-07 Symmetrical Scoring View
  Widget _buildScoringView() {
    final canFinishMatch = _scoreA >= 4 || _scoreB >= 4;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      color: _flashColor ?? Colors.transparent,
      child: Column(
        children: [
          // Top Status Bar with Audio and LAN indicators
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          color: AppColors.steel,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.table_restaurant_outlined, size: 14, color: AppColors.x),
                  const SizedBox(width: 6),
                  Text(
                    'MESA $_tableNumber · COMBATE EN VIVO',
                    style: AppTypography.mono.copyWith(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // Audio Announcer Toggle
                  InkWell(
                    onTap: () => setState(BeyAudioService.instance.toggleMute),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            BeyAudioService.instance.isMuted ? Icons.volume_off : Icons.volume_up,
                            size: 16,
                            color: BeyAudioService.instance.isMuted ? AppColors.mute : AppColors.x,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            BeyAudioService.instance.isMuted ? 'AUDIO OFF' : 'AUDIO ON',
                            style: AppTypography.mono.copyWith(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: BeyAudioService.instance.isMuted ? AppColors.mute : AppColors.x,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Voice settings & Preview Dialog Button
                  InkWell(
                    onTap: () async {
                      await BeyVoiceSelectorDialog.show(context);
                      if (mounted) setState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.panel,
                        border: Border.all(color: AppColors.x),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.record_voice_over, size: 12, color: AppColors.x),
                          const SizedBox(width: 4),
                          Text(
                            BeyAudioService.instance.language == AnnouncerLanguage.spanish ? 'VOZ: ES' : 'VOZ: OFICIAL',
                            style: AppTypography.mono.copyWith(
                              fontSize: 8.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.x,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // VAR Referee Review Trigger
                  InkWell(
                    onTap: _notifyDispute,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.dranzer.withValues(alpha: 0.18),
                        border: Border.all(color: AppColors.dranzer),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.videocam_outlined, size: 11, color: AppColors.dranzer),
                          const SizedBox(width: 3),
                          Text(
                            'VAR',
                            style: AppTypography.mono.copyWith(
                              fontSize: 8.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.dranzer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isConnectedToHub ? AppColors.x : AppColors.dranzer,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isConnectedToHub ? 'LAN EN VIVO' : 'SIN CONEXIÓN',
                    style: AppTypography.mono.copyWith(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: _isConnectedToHub ? AppColors.x : AppColors.dranzer,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Arena halves
        Expanded(
          child: Row(
            children: [
              // Player A Half (Dragoon Blue Zone)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.panel,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.dragoon.withValues(alpha: 0.2),
                        AppColors.panel,
                      ],
                    ),
                    border: const Border(right: BorderSide(color: AppColors.line)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _playerAName.toUpperCase(),
                                  style: AppTypography.displayMedium.copyWith(fontSize: 18, color: AppColors.dragoon),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(_playerABey, style: AppTypography.mono.copyWith(fontSize: 9.5, color: AppColors.mute)),
                              ],
                            ),
                          ),
                          _buildFaultSelector('A', _faultsA),
                        ],
                      ),
                      const Spacer(),
                      Center(
                        child: Text(
                          '$_scoreA',
                          style: AppTypography.displayLarge.copyWith(
                            fontSize: 76,
                            color: _scoreA >= 4 ? AppColors.x : AppColors.dragoon,
                            shadows: [
                              Shadow(color: AppColors.dragoon.withValues(alpha: 0.6), blurRadius: 24),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildFinishButton('SPIN +1', AppColors.panel2, () => _addFinish('A', 'SPIN', 1)),
                          _buildFinishButton('OVER +2', AppColors.pegasus, () => _addFinish('A', 'OVER', 2)),
                          _buildFinishButton('BURST +2', AppColors.burst, () => _addFinish('A', 'BURST', 2)),
                          _buildFinishButton('XTREME +3', AppColors.x, () => _addFinish('A', 'XTREME', 3)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Middle Column
              Container(
                width: 120,
                color: AppColors.steel,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('RONDA', style: AppTypography.mono.copyWith(fontSize: 8.5, color: AppColors.mute)),
                    Text('R$_currentRound', style: AppTypography.displayMedium.copyWith(fontSize: 18)),
                    const SizedBox(height: 8),

                    // Countdown button for every round
                    ChamferButton(
                      text: 'CONTEO 3-2-1',
                      height: 28,
                      variant: ChamferButtonVariant.go,
                      onPressed: _startCountdown,
                    ),
                    const SizedBox(height: 6),

                    ChamferButton(
                      text: 'DESHACER',
                      height: 26,
                      variant: ChamferButtonVariant.ghost,
                      onPressed: _finishHistory.isNotEmpty ? _undo : null,
                    ),
                    const SizedBox(height: 6),

                    ChamferButton(
                      text: 'VAR / JUEZ',
                      height: 26,
                      variant: ChamferButtonVariant.danger,
                      onPressed: _notifyDispute,
                    ),

                    if (canFinishMatch) ...[
                      const SizedBox(height: 8),
                      ChamferButton(
                        text: 'TERMINAR',
                        height: 30,
                        variant: ChamferButtonVariant.go,
                        onPressed: () => setState(() => _phase = TableModePhase.confirm),
                      ),
                    ],
                  ],
                ),
              ),

              // Player B Half (Dranzer Red Zone)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.panel,
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        AppColors.dranzer.withValues(alpha: 0.2),
                        AppColors.panel,
                      ],
                    ),
                    border: const Border(left: BorderSide(color: AppColors.line)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildFaultSelector('B', _faultsB),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _playerBName.toUpperCase(),
                                  style: AppTypography.displayMedium.copyWith(fontSize: 18, color: AppColors.dranzer),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(_playerBBey, style: AppTypography.mono.copyWith(fontSize: 9.5, color: AppColors.mute)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Center(
                        child: Text(
                          '$_scoreB',
                          style: AppTypography.displayLarge.copyWith(
                            fontSize: 76,
                            color: _scoreB >= 4 ? AppColors.x : AppColors.dranzer,
                            shadows: [
                              Shadow(color: AppColors.dranzer.withValues(alpha: 0.6), blurRadius: 24),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.end,
                        children: [
                          _buildFinishButton('SPIN +1', AppColors.panel2, () => _addFinish('B', 'SPIN', 1)),
                          _buildFinishButton('OVER +2', AppColors.pegasus, () => _addFinish('B', 'OVER', 2)),
                          _buildFinishButton('BURST +2', AppColors.burst, () => _addFinish('B', 'BURST', 2)),
                          _buildFinishButton('XTREME +3', AppColors.x, () => _addFinish('B', 'XTREME', 3)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // 5-Second Undo Grace Period Banner
        if (_undoGraceRemainingMs > 0)
          Container(
            height: 38,
            color: AppColors.dranzer.withValues(alpha: 0.18),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.history, size: 16, color: AppColors.dranzer),
                    const SizedBox(width: 8),
                    Text(
                      'PUNTO REGISTRADO: ${_lastFinishDescription ?? ''}',
                      style: AppTypography.mono.copyWith(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: _undo,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.dranzer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.undo_rounded, size: 14, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          'DESHACER (${(_undoGraceRemainingMs / 1000).toStringAsFixed(1)}s)',
                          style: AppTypography.mono.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Live Finishes Chronicle Bar
        if (_finishHistory.isNotEmpty)
          Container(
            height: 34,
            color: AppColors.panel2,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _finishHistory.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final parts = _finishHistory[idx].split(':');
                final isA = parts[0] == 'A';
                final type = parts.length > 1 ? parts[1] : '';
                final pts = parts.length > 2 ? parts[2] : '1';
                final pColor = isA ? AppColors.dragoon : AppColors.dranzer;

                return Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.void_,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: pColor.withValues(alpha: 0.6)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isA ? _playerAName.split(' ').first : _playerBName.split(' ').first,
                          style: AppTypography.mono.copyWith(fontSize: 9, fontWeight: FontWeight.bold, color: pColor),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$type (+$pts)',
                          style: AppTypography.mono.copyWith(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: type == 'PENALTY'
                                ? AppColors.pegasus
                                : type == 'XTREME'
                                    ? AppColors.x
                                    : type == 'BURST'
                                        ? AppColors.burst
                                        : type == 'OVER'
                                            ? AppColors.pegasus
                                            : AppColors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 08 Confirmation View
  Widget _buildConfirmView() {
    final winner = _scoreA >= 4 ? _playerAName : _playerBName;
    final winnerColor = _scoreA >= 4 ? AppColors.dragoon : AppColors.dranzer;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'VICTORIA DE $winner',
                style: AppTypography.displayMedium.copyWith(fontSize: 26, color: winnerColor),
              ),
              const SizedBox(height: 6),
              Text(
                'MARCADOR FINAL: $_scoreA — $_scoreB',
                style: AppTypography.mono.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ChamferButton(
                text: 'Confirmar y Enviar al Hub',
                variant: ChamferButtonVariant.go,
                onPressed: _confirmAndFinishMatch,
              ),
              const SizedBox(height: 10),
              ChamferButton(
                text: 'Corregir Marcador',
                variant: ChamferButtonVariant.ghost,
                onPressed: () => setState(() => _phase = TableModePhase.scoring),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 09 Dispute Lock Screen
  Widget _buildDisputeView() {
    return Container(
      color: AppColors.void_,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.gavel, size: 48, color: AppColors.dranzer),
            const SizedBox(height: 12),
            Text(
              'DESACUERDO · LLAMANDO AL JUEZ',
              style: AppTypography.displaySmall.copyWith(fontSize: 20, color: AppColors.dranzer),
            ),
            const SizedBox(height: 8),
            const Text(
              'La mesa no arbitra ni decide disputas.\nEl combate queda en pausa hasta que el juez lo resuelva desde su dispositivo.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.text, height: 1.5),
            ),
            const SizedBox(height: 20),
            ChamferButton(
              text: 'Reanudar Combate',
              variant: ChamferButtonVariant.ghost,
              height: 38,
              onPressed: () => setState(() => _phase = TableModePhase.scoring),
            ),
          ],
        ),
      ),
    );
  }

  // 10 Tournament Completed Screen
  Widget _buildTournamentCompletedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.emoji_events, size: 64, color: AppColors.pegasus),
          const SizedBox(height: 16),
          Text(
            'TORNEO FINALIZADO',
            style: AppTypography.displayMedium.copyWith(fontSize: 32, color: AppColors.pegasus),
          ),
          const SizedBox(height: 8),
          Text(
            'Todos los combates del torneo han concluido.',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.mute),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 220,
            child: ChamferButton(
              text: 'Volver a Reposo',
              variant: ChamferButtonVariant.ghost,
              onPressed: () => setState(() => _phase = TableModePhase.idle),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaultSelector(String player, int currentFault) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => _selectFault(player, 1),
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: currentFault == 1 ? AppColors.pegasus : AppColors.panel,
              border: Border.all(color: currentFault == 1 ? AppColors.pegasus : AppColors.line),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning_amber, size: 12, color: currentFault == 1 ? AppColors.void_ : AppColors.pegasus),
                const SizedBox(width: 3),
                Text(
                  'FALTA 1',
                  style: AppTypography.mono.copyWith(
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                    color: currentFault == 1 ? AppColors.void_ : AppColors.text,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 4),
        InkWell(
          onTap: () => _selectFault(player, 2),
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.panel,
              border: Border.all(color: AppColors.dranzer),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.gavel, size: 12, color: AppColors.dranzer),
                const SizedBox(width: 3),
                Text(
                  'FALTA 2 (+1)',
                  style: AppTypography.mono.copyWith(
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dranzer,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinishButton(String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.panel,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.32),
              AppColors.panel2,
            ],
          ),
          border: Border.all(color: color.withValues(alpha: 0.95), width: 1.5),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: AppTypography.mono.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
            color: color == AppColors.panel2 ? AppColors.text : color,
          ),
        ),
      ),
    );
  }
}
