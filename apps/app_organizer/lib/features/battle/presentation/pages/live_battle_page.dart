import 'dart:async';

import 'package:bey_domain/bey_domain.dart';
import 'package:bey_ui/bey_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';

class LiveBattlePage extends StatefulWidget {
  const LiveBattlePage({super.key});

  @override
  State<LiveBattlePage> createState() => _LiveBattlePageState();
}

class _LiveBattlePageState extends State<LiveBattlePage> with SingleTickerProviderStateMixin {
  final _scoringService = getIt<ScoringService>();
  final _battleRepo = getIt<BattleRepository>();
  final _identityRepo = getIt<IdentityRepository>();

  late String _matchId;
  String _playerAName = 'TÚ (BLADER 1)';
  final String _playerBName = 'RIVAL (BLADER 2)';
  final String _playerABey = 'DranSword 3-60F';
  final String _playerBBey = 'WizardRod 5-70DB';

  final int _targetPoints = 4;
  int _roundIndex = 1;
  int _faultsA = 0;
  int _faultsB = 0;
  List<BattleFinish> _finishes = [];

  // Countdown state
  bool _isCountingDown = true;
  int _countdownStep = 3; // 3 -> 2 -> 1 -> 0 (GO SHOOT)
  Timer? _countdownTimer;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _matchId = 'match-${DateTime.now().millisecondsSinceEpoch}';
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _loadUser();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _isCountingDown = true;
      _countdownStep = 3;
    });

    _triggerTickHaptic();
    unawaited(BeyAudioService.instance.playCount(3));
    _animController.forward(from: 0);

    _countdownTimer = Timer.periodic(const Duration(milliseconds: 950), (timer) {
      if (!mounted) return;
      setState(() {
        if (_countdownStep > 1) {
          _countdownStep--;
          _triggerTickHaptic();
          unawaited(BeyAudioService.instance.playCount(_countdownStep));
          _animController.forward(from: 0);
        } else if (_countdownStep == 1) {
          _countdownStep = 0; // 0 = GO SHOOT!
          _triggerShootHaptic();
          unawaited(BeyAudioService.instance.playGoShoot());
          _animController.forward(from: 0);
        } else {
          timer.cancel();
          _isCountingDown = false;
        }
      });
    });
  }

  void _skipCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _isCountingDown = false;
    });
  }

  void _triggerTickHaptic() {
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  void _triggerShootHaptic() {
    try {
      HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  Future<void> _loadUser() async {
    final profile = await _identityRepo.getActiveProfile();
    if (profile != null && mounted) {
      setState(() {
        _playerAName = profile.nickname.toUpperCase();
      });
    }
  }

  Match get _currentMatch => Match(
        id: _matchId,
        playerAId: _playerAName,
        playerBId: _playerBName,
        format: MatchFormat.singles,
        rules: MatchRules(targetPoints: _targetPoints),
        status: MatchStatus.inProgress,
        finishes: _finishes,
        createdAt: DateTime.now(),
      );

  MatchScore get _currentScore => _scoringService.scoreOf(_currentMatch);

  void _addFinish(String scoringPlayerId, FinishType type, {bool isPenalty = false}) {
    final finish = BattleFinish(
      id: 'fin-${DateTime.now().millisecondsSinceEpoch}-${_finishes.length}',
      matchId: _matchId,
      roundIndex: _roundIndex,
      sequence: _finishes.length + 1,
      type: type,
      scoringPlayerId: scoringPlayerId,
      isPenalty: isPenalty,
      createdAt: DateTime.now(),
    );

    unawaited(BeyAudioService.instance.playFinish(type.name));

    setState(() {
      _finishes = [..._finishes, finish];
      _roundIndex++;
      _faultsA = 0;
      _faultsB = 0;
    });
  }

  void _selectFault(bool isPlayerA, int level) {
    if (isPlayerA) {
      if (_faultsA == level) {
        setState(() => _faultsA = 0);
        return;
      }
      if (level == 1) {
        setState(() => _faultsA = 1);
        _triggerTickHaptic();
        unawaited(BeyAudioService.instance.playFault());
      } else if (level == 2) {
        _addFinish(_playerBName, FinishType.penalty, isPenalty: true);
        BeyFeedbackDialog.showWarning(
          context,
          title: 'Penalización por Faltas',
          message: 'Se declaró Falta 2. Se otorga +1 punto de penalización reglamentaria a $_playerBName.',
          solution: 'El contador de faltas se ha reiniciado a 0.',
          cancelText: null,
        );
      }
    } else {
      if (_faultsB == level) {
        setState(() => _faultsB = 0);
        return;
      }
      if (level == 1) {
        setState(() => _faultsB = 1);
        _triggerTickHaptic();
        unawaited(BeyAudioService.instance.playFault());
      } else if (level == 2) {
        _addFinish(_playerAName, FinishType.penalty, isPenalty: true);
        BeyFeedbackDialog.showWarning(
          context,
          title: 'Penalización por Faltas',
          message: 'El rival cometió Falta 2. Se otorga +1 punto de penalización reglamentaria a $_playerAName.',
          solution: 'El contador de faltas se ha reiniciado a 0.',
          cancelText: null,
        );
      }
    }
  }

  void _recordTie() {
    setState(() {
      _roundIndex++;
      _faultsA = 0;
      _faultsB = 0;
    });

    BeyFeedbackDialog.showInfo(
      context,
      title: 'Ronda Empatada',
      message: 'Ambos Beys se detuvieron o salieron simultáneamente. La ronda no otorga puntos a ningún combatiente.',
      solution: 'Prepara nuevamente tu Bey y lanzador para repetir el combate.',
      confirmText: 'CONTINUAR',
    );
  }

  void _undoLastFinish() {
    if (_finishes.isEmpty) return;

    final activeFinishes = _finishes.where((f) => !f.isVoid).toList();
    if (activeFinishes.isEmpty) return;

    final lastActive = activeFinishes.last;
    final voidFinish = BattleFinish(
      id: 'fin-void-${DateTime.now().millisecondsSinceEpoch}',
      matchId: _matchId,
      roundIndex: lastActive.roundIndex,
      sequence: _finishes.length + 1,
      type: lastActive.type,
      scoringPlayerId: lastActive.scoringPlayerId,
      createdAt: DateTime.now(),
      voidedTargetId: lastActive.id,
    );

    setState(() {
      _finishes = [..._finishes, voidFinish];
      if (_roundIndex > 1) _roundIndex--;
    });
  }

  Future<void> _finalizeMatch({required String winnerId}) async {
    final closedMatch = Match(
      id: _matchId,
      playerAId: _playerAName,
      playerBId: _playerBName,
      format: MatchFormat.singles,
      rules: MatchRules(targetPoints: _targetPoints),
      status: MatchStatus.confirmed,
      finishes: _finishes,
      outcome: const PointsReached(),
      createdAt: DateTime.now(),
    );

    await _battleRepo.saveMatch(closedMatch);

    if (!mounted) return;

    final score = _currentScore;
    final isPlayerAWinner = winnerId == _playerAName;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.steel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: isPlayerAWinner ? AppColors.x : AppColors.dranzer, width: 2),
        ),
        title: Center(
          child: Column(
            children: [
              Icon(
                isPlayerAWinner ? Icons.emoji_events : Icons.shield,
                color: isPlayerAWinner ? AppColors.x : AppColors.pegasus,
                size: 48,
              ),
              const SizedBox(height: 10),
              Text(
                isPlayerAWinner ? '¡VICTORIA!' : 'FIN DEL COMBATE',
                style: AppTypography.displayMedium.copyWith(
                  fontSize: 22,
                  color: isPlayerAWinner ? AppColors.x : AppColors.text,
                ),
              ),
              Text(
                'GANADOR: $winnerId',
                style: AppTypography.mono.copyWith(fontSize: 12, color: AppColors.mute, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${score.playerAPoints}', style: AppTypography.displayLarge.copyWith(fontSize: 42, color: AppColors.dragoon)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('—', style: AppTypography.displayMedium.copyWith(fontSize: 28, color: AppColors.mute)),
                ),
                Text('${score.playerBPoints}', style: AppTypography.displayLarge.copyWith(fontSize: 42, color: AppColors.dranzer)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Rondas disputadas: ${_roundIndex - 1}',
              style: AppTypography.mono.copyWith(fontSize: 11, color: AppColors.mute),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _matchId = 'match-${DateTime.now().millisecondsSinceEpoch}';
                _roundIndex = 1;
                _faultsA = 0;
                _faultsB = 0;
                _finishes = [];
              });
              _startCountdown();
            },
            child: const Text('NUEVA PARTIDA', style: TextStyle(color: AppColors.x, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.panel2),
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/home');
            },
            child: const Text('SALIR AL MENÚ', style: TextStyle(color: AppColors.text)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isCountingDown) {
      return _buildCountdownOverlay();
    }

    return _buildLiveScoringView();
  }

  // ==========================================
  // COUNTDOWN VIEW (3... 2... 1... GO SHOOT!)
  // ==========================================
  Widget _buildCountdownOverlay() {
    final stepText = switch (_countdownStep) {
      3 => '3',
      2 => '2',
      1 => '1',
      _ => 'GO SHOOT!',
    };

    final stepColor = switch (_countdownStep) {
      3 => AppColors.dragoon,
      2 => AppColors.pegasus,
      1 => AppColors.burst,
      _ => AppColors.x,
    };

    return Scaffold(
      backgroundColor: AppColors.void_,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Rotating Background BeyRing
          Positioned(
            child: Opacity(
              opacity: 0.15,
              child: BeyRing(
                size: 380,
                color: stepColor,
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Bar: Round & Category
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.panel2,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: Text(
                          'RONDA $_roundIndex · COMBATE 1V1',
                          style: AppTypography.mono.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _skipCountdown,
                        icon: const Icon(Icons.fast_forward, size: 16, color: AppColors.mute),
                        label: Text(
                          'SALTAR',
                          style: AppTypography.mono.copyWith(fontSize: 11, color: AppColors.mute, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),

                  // Center Stage: Animated Count Number / GO SHOOT!
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'PREPARADOS PARA EL LANZAMIENTO',
                        style: AppTypography.mono.copyWith(
                          fontSize: 11,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                          color: AppColors.mute,
                        ),
                      ),
                      const SizedBox(height: 20),

                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Text(
                          stepText,
                          style: AppTypography.displayLarge.copyWith(
                            fontSize: _countdownStep == 0 ? 56 : 110,
                            fontWeight: FontWeight.w900,
                            color: stepColor,
                            letterSpacing: _countdownStep == 0 ? 2 : 0,
                            shadows: [
                              Shadow(
                                color: stepColor.withValues(alpha: 0.8),
                                blurRadius: 40,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Step Sequence Dots (● ● ● ⚡)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStepDot(active: _countdownStep <= 3, color: AppColors.dragoon, label: '3'),
                          const SizedBox(width: 12),
                          _buildStepDot(active: _countdownStep <= 2, color: AppColors.pegasus, label: '2'),
                          const SizedBox(width: 12),
                          _buildStepDot(active: _countdownStep <= 1, color: AppColors.burst, label: '1'),
                          const SizedBox(width: 12),
                          _buildStepDot(active: _countdownStep == 0, color: AppColors.x, label: 'SHOOT', isShoot: true),
                        ],
                      ),
                    ],
                  ),

                  // Bottom Instructions Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.steel,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  _playerAName.split(' ').first,
                                  style: AppTypography.mono.copyWith(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.dragoon),
                                ),
                                Text('IZQUIERDA', style: AppTypography.mono.copyWith(fontSize: 9, color: AppColors.mute)),
                              ],
                            ),
                            Container(width: 1, height: 24, color: AppColors.line),
                            Column(
                              children: [
                                Text(
                                  _playerBName.split(' ').first,
                                  style: AppTypography.mono.copyWith(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.dranzer),
                                ),
                                Text('DERECHA', style: AppTypography.mono.copyWith(fontSize: 9, color: AppColors.mute)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Regla oficial v12: Lanzar en el instante de "SHOOT" a máx. 20 cm del estadio.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySmall.copyWith(fontSize: 10, color: AppColors.pegasus),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepDot({required bool active, required Color color, required String label, bool isShoot = false}) {
    return Column(
      children: [
        Container(
          width: isShoot ? 36 : 24,
          height: 14,
          decoration: BoxDecoration(
            color: active ? color : AppColors.panel,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: active ? color : AppColors.line),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.6),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.mono.copyWith(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: active ? (isShoot ? Colors.black : Colors.white) : AppColors.mute,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // LIVE SCORING VIEW
  // ==========================================
  Widget _buildLiveScoringView() {
    final score = _currentScore;
    final canFinishMatch = score.playerAPoints >= _targetPoints || score.playerBPoints >= _targetPoints;

    return Scaffold(
      backgroundColor: AppColors.void_,
      appBar: AppBar(
        backgroundColor: AppColors.steel,
        title: Row(
          children: [
            Text(
              'COMBATE 1V1 · RONDA $_roundIndex',
              style: AppTypography.mono.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.record_voice_over, color: AppColors.x, size: 18),
              tooltip: 'Configurar y Probar Voces',
              onPressed: () => BeyVoiceSelectorDialog.show(context),
            ),
            const SizedBox(width: 4),
            // Re-launch Countdown Button
            InkWell(
              onTap: _startCountdown,
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.x.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.x),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, color: AppColors.x, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      '3-2-1 LANZAR',
                      style: AppTypography.mono.copyWith(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.x),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Side A: Player A (Blue Dragoon Zone)
          Expanded(
            child: _buildPlayerZone(
              isPlayerA: true,
              playerName: _playerAName,
              beyName: _playerABey,
              score: score.playerAPoints,
              faults: _faultsA,
              primaryColor: AppColors.dragoon,
              onFinishSelected: (type) => _addFinish(_playerAName, type),
              onFault1Tap: () => _selectFault(true, 1),
              onFault2Tap: () => _selectFault(true, 2),
            ),
          ),

          // Divider Bar with Chronicle summary
          Container(
            height: 32,
            color: AppColors.steel,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_playerAName.split(' ').first}: ${score.playerAPoints} PTS',
                  style: AppTypography.mono.copyWith(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.dragoon),
                ),
                Text(
                  'VS',
                  style: AppTypography.mono.copyWith(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.mute),
                ),
                Text(
                  '${_playerBName.split(' ').first}: ${score.playerBPoints} PTS',
                  style: AppTypography.mono.copyWith(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.dranzer),
                ),
              ],
            ),
          ),

          // Side B: Player B (Red Dranzer Zone)
          Expanded(
            child: _buildPlayerZone(
              isPlayerA: false,
              playerName: _playerBName,
              beyName: _playerBBey,
              score: score.playerBPoints,
              faults: _faultsB,
              primaryColor: AppColors.dranzer,
              onFinishSelected: (type) => _addFinish(_playerBName, type),
              onFault1Tap: () => _selectFault(false, 1),
              onFault2Tap: () => _selectFault(false, 2),
            ),
          ),

          // Live Chronicle / Finishes History strip
          if (_finishes.where((f) => !f.isVoid).isNotEmpty)
            Container(
              height: 38,
              color: AppColors.panel,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _finishes.where((f) => !f.isVoid).length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, idx) {
                  final f = _finishes.where((fin) => !fin.isVoid).toList()[idx];
                  final isA = f.scoringPlayerId == _playerAName;
                  final pColor = isA ? AppColors.dragoon : AppColors.dranzer;

                  return Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.void_,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: pColor.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isA ? 'TÚ' : 'RIVAL',
                            style: AppTypography.mono.copyWith(fontSize: 9, fontWeight: FontWeight.bold, color: pColor),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            f.isPenalty ? 'PENALTY (+1)' : '${f.type.name.toUpperCase()} (+${f.type.points})',
                            style: AppTypography.mono.copyWith(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: f.isPenalty ? AppColors.pegasus : _getFinishColor(f.type),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          // Bottom Action Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: AppColors.void_,
              border: Border(top: BorderSide(color: AppColors.line)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.mute,
                      side: const BorderSide(color: AppColors.line2),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.undo, size: 16),
                    label: const Text('DESHACER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    onPressed: _finishes.isNotEmpty ? _undoLastFinish : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.pegasus,
                      side: BorderSide(color: AppColors.pegasus.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.warning_amber_rounded, size: 16),
                    label: const Text('EMPATE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    onPressed: _recordTie,
                  ),
                ),
                const SizedBox(width: 8),
                if (canFinishMatch)
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.x,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: const Icon(Icons.check_circle_outline, size: 16, color: Colors.black),
                      label: const Text('TERMINAR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      onPressed: () => _finalizeMatch(
                        winnerId: score.playerAPoints >= _targetPoints ? _playerAName : _playerBName,
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.panel2,
                        foregroundColor: AppColors.x,
                        side: const BorderSide(color: AppColors.x),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: const Icon(Icons.play_arrow_rounded, size: 16, color: AppColors.x),
                      label: const Text('3-2-1 SHOOT', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                      onPressed: _startCountdown,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerZone({
    required bool isPlayerA,
    required String playerName,
    required String beyName,
    required int score,
    required int faults,
    required Color primaryColor,
    required ValueChanged<FinishType> onFinishSelected,
    required VoidCallback onFault1Tap,
    required VoidCallback onFault2Tap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.panel,
        gradient: LinearGradient(
          begin: isPlayerA ? Alignment.topLeft : Alignment.bottomLeft,
          end: isPlayerA ? Alignment.bottomRight : Alignment.topRight,
          colors: [
            primaryColor.withValues(alpha: 0.18),
            AppColors.panel,
          ],
        ),
        border: Border(
          bottom: isPlayerA ? const BorderSide(color: AppColors.line) : BorderSide.none,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Name, Bey, Faults and Score
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playerName,
                      style: AppTypography.displayMedium.copyWith(fontSize: 15, color: primaryColor),
                    ),
                    Text(
                      beyName,
                      style: AppTypography.mono.copyWith(fontSize: 10, color: AppColors.mute),
                    ),
                  ],
                ),
              ),

              // Single select fault buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: onFault1Tap,
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: faults == 1 ? AppColors.pegasus : AppColors.void_,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: faults == 1 ? AppColors.pegasus : AppColors.line2),
                      ),
                      child: Text(
                        'F1',
                        style: AppTypography.mono.copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: faults == 1 ? AppColors.void_ : AppColors.pegasus,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: onFault2Tap,
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.void_,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.dranzer),
                      ),
                      child: Text(
                        'F2 (+1)',
                        style: AppTypography.mono.copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.dranzer,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),

              // Big Score
              Text(
                '$score',
                style: AppTypography.displayLarge.copyWith(
                  fontSize: 34,
                  color: score >= _targetPoints ? AppColors.x : primaryColor,
                  shadows: [
                    Shadow(color: primaryColor.withValues(alpha: 0.5), blurRadius: 10),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 4-Point Rail
          Row(
            children: List.generate(_targetPoints, (idx) {
              final isLit = idx < score;
              return Expanded(
                child: Container(
                  height: 10,
                  margin: EdgeInsets.only(right: idx < _targetPoints - 1 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: isLit ? primaryColor : AppColors.void_,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(
                      color: isLit ? primaryColor : AppColors.line2,
                      width: 1,
                    ),
                    boxShadow: isLit
                        ? [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.5),
                              blurRadius: 4,
                            ),
                          ]
                        : null,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),

          // 4 Finish Buttons
          Expanded(
            child: Row(
              children: [
                _buildFinishBtn(
                  title: 'SPIN',
                  points: '+1',
                  color: AppColors.text,
                  onTap: () => onFinishSelected(FinishType.spin),
                ),
                const SizedBox(width: 6),
                _buildFinishBtn(
                  title: 'OVER',
                  points: '+2',
                  color: AppColors.pegasus,
                  onTap: () => onFinishSelected(FinishType.over),
                ),
                const SizedBox(width: 6),
                _buildFinishBtn(
                  title: 'BURST',
                  points: '+2',
                  color: AppColors.burst,
                  onTap: () => onFinishSelected(FinishType.burst),
                ),
                const SizedBox(width: 6),
                _buildFinishBtn(
                  title: 'XTREME',
                  points: '+3',
                  color: AppColors.x,
                  onTap: () => onFinishSelected(FinishType.xtreme),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinishBtn({
    required String title,
    required String points,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.void_,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color.withValues(alpha: 0.6), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: AppTypography.mono.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                points,
                style: AppTypography.displayMedium.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getFinishColor(FinishType type) {
    return switch (type) {
      FinishType.spin => AppColors.text,
      FinishType.over => AppColors.pegasus,
      FinishType.burst => AppColors.burst,
      FinishType.xtreme => AppColors.x,
      FinishType.penalty => AppColors.pegasus,
    };
  }
}
