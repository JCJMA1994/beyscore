import 'dart:convert';
import 'dart:io';

import 'package:bey_data/bey_data.dart';
import 'package:bey_domain/bey_domain.dart';
import 'package:bey_tournament/bey_tournament.dart';
import 'package:bey_ui/bey_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';

class PlayerTournamentsPage extends StatefulWidget {
  const PlayerTournamentsPage({super.key});

  static String lastHubHost = '127.0.0.1';

  @override
  State<PlayerTournamentsPage> createState() => _PlayerTournamentsPageState();
}

class _PlayerTournamentsPageState extends State<PlayerTournamentsPage> {
  final _identityRepo = getIt<IdentityRepository>();
  final _tournamentRepo = getIt<TournamentRepository>();
  String? _currentUserNickname;
  bool _isSyncing = false;
  int _filterIndex = 0; // 0 = Todos, 1 = Activos/En Curso, 2 = Historial/Finalizados
  final Set<String> _activeHubTournamentIds = {};

  @override
  void initState() {
    super.initState();
    _loadUser();
    getIt<SyncEngine>().syncNow();
    _autoProbeLanHub();
  }

  Future<void> _loadUser() async {
    final profile = await _identityRepo.getActiveProfile();
    if (mounted && profile != null) {
      setState(() => _currentUserNickname = profile.nickname);
    }
  }

  Future<void> _autoProbeLanHub() async {
    // Fast parallel discovery on common local hub hosts without blocking manual connects
    final hosts = ['127.0.0.1', '10.0.2.2', 'localhost'];
    if (PlayerTournamentsPage.lastHubHost.isNotEmpty && !hosts.contains(PlayerTournamentsPage.lastHubHost)) {
      hosts.insert(0, PlayerTournamentsPage.lastHubHost);
    }

    for (final host in hosts) {
      final success = await _fetchAndSyncTournamentFromHost(host, 8080, silent: true, timeoutMs: 500);
      if (success) break;
    }
  }

  Future<bool> _fetchAndSyncTournamentFromHost(
    String host,
    int port, {
    bool silent = false,
    bool isManual = false,
    int timeoutMs = 4000,
  }) async {
    var cleanHost = host.trim();
    if (cleanHost.startsWith('http://')) cleanHost = cleanHost.substring(7);
    if (cleanHost.startsWith('https://')) cleanHost = cleanHost.substring(8);
    var targetPort = port;
    if (cleanHost.contains(':')) {
      final parts = cleanHost.split(':');
      cleanHost = parts[0];
      final parsedPort = int.tryParse(parts[1].replaceAll(RegExp('[^0-9]'), ''));
      if (parsedPort != null) targetPort = parsedPort;
    }
    if (cleanHost.endsWith('/')) cleanHost = cleanHost.substring(0, cleanHost.length - 1);
    if (cleanHost.isEmpty) return false;

    if (_isSyncing && !isManual) return false;
    if (mounted) setState(() => _isSyncing = true);

    try {
      final client = HttpClient()..connectionTimeout = Duration(milliseconds: timeoutMs);
      final request = await client.getUrl(Uri.parse('http://$cleanHost:$targetPort/api/tournament'));
      final response = await request.close();

      if (response.statusCode == HttpStatus.ok) {
        final body = await response.transform(utf8.decoder).join();
        final json = jsonDecode(body) as Map<String, dynamic>;

        final tier = TournamentTier.values.firstWhere(
          (t) => t.name == json['tier'],
          orElse: () => TournamentTier.g3,
        );
        final division = AgeDivision.values.firstWhere(
          (d) => d.name == json['ageDivision'],
          orElse: () => AgeDivision.open,
        );
        final status = TournamentStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => TournamentStatus.registration,
        );

        final roundsRaw = json['rounds'] as List<dynamic>? ?? [];
        final parsedRounds = roundsRaw.map((r) {
          final rMap = r as Map<String, dynamic>;
          final matchupsRaw = rMap['matchups'] as List<dynamic>? ?? [];
          final matchups = matchupsRaw.map((m) {
            final mMap = m as Map<String, dynamic>;
            final pAName = mMap['playerAName'] as String? ?? 'TBD';
            final pBName = mMap['playerBName'] as String?;

            return Matchup(
              matchId: mMap['matchId'] as String? ?? 'm-${DateTime.now().millisecondsSinceEpoch}',
              playerAId: mMap['playerAId'] as String? ?? pAName,
              playerAName: pAName,
              playerBId: mMap['playerBId'] as String? ?? pBName,
              playerBName: pBName,
              scoreA: mMap['scoreA'] as int? ?? 0,
              scoreB: mMap['scoreB'] as int? ?? 0,
              isCompleted: mMap['isCompleted'] as bool? ?? false,
              tableNumber: mMap['tableNumber'] as int?,
              winnerId: mMap['winnerId'] as String?,
            );
          }).toList();

          return BracketRound(
            roundIndex: rMap['roundIndex'] as int? ?? 0,
            name: rMap['name'] as String? ?? 'Ronda',
            matchups: matchups,
          );
        }).toList();

        final tournament = Tournament(
          id: json['id'] as String,
          name: json['name'] as String,
          organizerIds: List<String>.from(json['organizerIds'] as List? ?? ['organizer-local']),
          tier: tier,
          ageDivision: division,
          status: status,
          participants: List<String>.from(json['participants'] as List? ?? []),
          seed: json['seed'] as int?,
          createdAt: DateTime.now(),
          rounds: parsedRounds,
        );

        PlayerTournamentsPage.lastHubHost = cleanHost;
        _activeHubTournamentIds.add(tournament.id);
        await _tournamentRepo.save(tournament);

        if (mounted) {
          context.read<TournamentBloc>().add(TournamentStarted());
          if (!silent) {
            await BeyFeedbackDialog.showSuccess(
              context,
              title: 'Torneo Sincronizado',
              message: 'Se cargó exitosamente el torneo "${tournament.name}" desde el Hub LAN ($cleanHost:$targetPort). Ya puedes inscribirte.',
            );
          }
        }
        return true;
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
    return false;
  }

  void _showConnectHubDialog(BuildContext pageContext) {
    final defaultIp = PlayerTournamentsPage.lastHubHost != '127.0.0.1' && PlayerTournamentsPage.lastHubHost != 'localhost'
        ? PlayerTournamentsPage.lastHubHost
        : '192.168.1.';
    final ipController = TextEditingController(text: defaultIp);
    var isConnecting = false;

    showDialog<void>(
      context: pageContext,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.panel,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.line),
          ),
          title: Row(
            children: [
              const Icon(Icons.hub_outlined, color: AppColors.x),
              const SizedBox(width: 8),
              Text(
                'CONECTAR A HUB LAN',
                style: AppTypography.displayMedium.copyWith(fontSize: 16),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ingresa la IP del organizador que aparece en su pantalla (Hub LAN):',
                style: AppTypography.bodySmall.copyWith(color: AppColors.mute),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ipController,
                autofocus: true,
                enabled: !isConnecting,
                style: AppTypography.mono.copyWith(color: AppColors.text, fontSize: 13),
                decoration: const InputDecoration(
                  labelText: 'IP / Host del Hub',
                  hintText: 'ej. 192.168.1.15 ó 127.0.0.1',
                  prefixIcon: Icon(Icons.wifi, color: AppColors.x, size: 18),
                  suffixText: ':8080',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isConnecting ? null : () => Navigator.pop(dialogCtx),
              child: const Text('CANCELAR', style: TextStyle(color: AppColors.mute)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.x),
              onPressed: isConnecting
                  ? null
                  : () async {
                      final host = ipController.text.trim();
                      setDialogState(() => isConnecting = true);

                      final success = await _fetchAndSyncTournamentFromHost(host, 8080, isManual: true, timeoutMs: 4000);
                      if (dialogCtx.mounted) {
                        Navigator.pop(dialogCtx);
                      }
                      if (!success) {
                        if (!pageContext.mounted) return;
                        await BeyFeedbackDialog.showError(
                          pageContext,
                          title: 'Fallo de Conexión LAN',
                          message: 'No fue posible establecer conexión con el Hub en $host:8080.',
                          solution: '1. Verifica que el organizador tenga su servidor Hub encendido ("Levantar Hub LAN").\n2. Asegúrate de que ambos dispositivos estén en la misma red Wi-Fi.\n3. Confirma que la IP coincida con la del organizador.',
                        );
                      }
                    },
              child: isConnecting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : const Text('CONECTAR', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TournamentBloc(repository: _tournamentRepo)..add(TournamentStarted()),
      child: BlocBuilder<TournamentBloc, TournamentState>(
        builder: (context, state) {
          final tournaments = state is TournamentLoaded ? state.tournaments : <Tournament>[];
          final filteredTournaments = switch (_filterIndex) {
            1 => tournaments.where((t) => t.status != TournamentStatus.completed).toList(),
            2 => tournaments.where((t) => t.status == TournamentStatus.completed).toList(),
            _ => tournaments,
          };
          return Scaffold(
            backgroundColor: AppColors.void_,
            appBar: AppBar(
              backgroundColor: AppColors.steel,
              title: Text(
                'TORNEOS CHIMBOTE BEYBLADE X',
                style: AppTypography.mono.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              actions: [
                IconButton(
                  icon: _isSyncing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.x),
                        )
                      : const Icon(Icons.sync, color: AppColors.x),
                  tooltip: 'Sincronizar con Nube / Hub LAN',
                  onPressed: () async {
                    setState(() => _isSyncing = true);
                    await getIt<SyncEngine>().syncNow();
                    await _autoProbeLanHub();
                    if (mounted) setState(() => _isSyncing = false);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.hub_outlined, color: AppColors.pegasus),
                  tooltip: 'Ingresar IP del Organizador',
                  onPressed: () => _showConnectHubDialog(context),
                ),
              ],
            ),
            body: RefreshIndicator(
              color: AppColors.x,
              backgroundColor: AppColors.panel,
              onRefresh: () async {
                await getIt<SyncEngine>().syncNow();
                await _autoProbeLanHub();
                if (context.mounted) {
                  context.read<TournamentBloc>().add(TournamentStarted());
                }
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Banner Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.panel,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.line),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.panel,
                          AppColors.x.withValues(alpha: 0.1),
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
                              'INSCRIPCIÓN A TORNEOS',
                              style: AppTypography.displayMedium.copyWith(fontSize: 16),
                            ),
                            const BeyBadge(label: 'OFICIAL V12', color: AppColors.x),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Elige un torneo organizado, selecciona tu Deck 3on3 y genera tu pase de chequeo QR para el juez de mesa.',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.mute, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Filter Chips (Todos / En Curso / Historial)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _filterChip(label: 'TODOS (${tournaments.length})', index: 0),
                        const SizedBox(width: 8),
                        _filterChip(
                          label: 'EN CURSO (${tournaments.where((t) => t.status != TournamentStatus.completed).length})',
                          index: 1,
                        ),
                        const SizedBox(width: 8),
                        _filterChip(
                          label: 'HISTORIAL (${tournaments.where((t) => t.status == TournamentStatus.completed).length})',
                          index: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (filteredTournaments.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.panel,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _filterIndex == 2 ? Icons.history : Icons.emoji_events_outlined,
                            size: 48,
                            color: AppColors.mute,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _filterIndex == 2 ? 'No hay torneos en el historial' : 'No hay torneos disponibles',
                            style: AppTypography.displayMedium.copyWith(fontSize: 15),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _filterIndex == 2
                                ? 'Los torneos completados donde participaste o que concluyeron en tu comunidad aparecerán aquí.'
                                : 'Los torneos creados por los organizadores en tu comunidad o en la red local aparecerán aquí.',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodySmall.copyWith(color: AppColors.mute, fontSize: 11),
                          ),
                        ],
                      ),
                    )
                  else
                    ...filteredTournaments.map((t) => _buildTournamentCard(context, t)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _filterChip({required String label, required int index}) {
    final isSelected = _filterIndex == index;
    return ChoiceChip(
      label: Text(
        label,
        style: AppTypography.mono.copyWith(
          fontSize: 10.5,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.black : AppColors.text,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.x,
      backgroundColor: AppColors.panel,
      side: BorderSide(color: isSelected ? AppColors.x : AppColors.line),
      onSelected: (val) {
        if (val) setState(() => _filterIndex = index);
      },
    );
  }

  Widget _buildTournamentCard(BuildContext context, Tournament t) {
    final isRegistered = _currentUserNickname != null && t.participants.contains(_currentUserNickname);
    final isOpen = t.status == TournamentStatus.registration || t.status == TournamentStatus.draft;
    final tierColor = Color(t.tier.colorValue);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isRegistered ? AppColors.x : AppColors.line,
          width: isRegistered ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Tags
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: tierColor,
                    ),
                  ),
                ),
                Row(
                  children: [
                    if (t.status != TournamentStatus.completed) ...[
                      BeyBadge(
                        label: _activeHubTournamentIds.contains(t.id) ? 'HUB ACTIVO' : 'HUB OFFLINE',
                        color: _activeHubTournamentIds.contains(t.id) ? AppColors.x : AppColors.dranzer,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: t.status == TournamentStatus.inProgress
                            ? AppColors.dragoon.withValues(alpha: 0.2)
                            : (t.status == TournamentStatus.completed
                                ? AppColors.pegasus.withValues(alpha: 0.2)
                                : AppColors.steel),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        t.status.label.toUpperCase(),
                        style: AppTypography.mono.copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: t.status == TournamentStatus.inProgress
                              ? AppColors.dragoon
                              : (t.status == TournamentStatus.completed ? AppColors.pegasus : AppColors.mute),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.mute),
                      tooltip: 'Eliminar de este dispositivo',
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () async {
                        final confirm = await BeyFeedbackDialog.showConfirm(
                          context,
                          title: 'Eliminar Torneo',
                          message: '¿Deseas descartar "${t.name}" de la lista local de tu dispositivo?',
                          confirmText: 'ELIMINAR',
                          cancelText: 'CANCELAR',
                        );
                        if (confirm == true && context.mounted) {
                          await _tournamentRepo.delete(t.id);
                          if (context.mounted) {
                            context.read<TournamentBloc>().add(TournamentStarted());
                          }
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Tournament Name
            Text(
              t.name.toUpperCase(),
              style: AppTypography.displayMedium.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 4),

            // Rules and Division
            Row(
              children: [
                const Icon(Icons.people_alt_outlined, size: 14, color: AppColors.mute),
                const SizedBox(width: 4),
                Text(
                  '${t.participants.length} Bladers inscriptos',
                  style: AppTypography.mono.copyWith(fontSize: 10.5, color: AppColors.mute),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.verified_user_outlined, size: 14, color: AppColors.mute),
                const SizedBox(width: 4),
                Text(
                  t.ageDivision.label,
                  style: AppTypography.mono.copyWith(fontSize: 10.5, color: AppColors.mute),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Action Buttons
            if (isRegistered)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.x,
                        side: const BorderSide(color: AppColors.x),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: const Icon(Icons.qr_code, size: 16),
                      label: const Text('MI PASE QR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        context.push('/tournaments/${t.id}/pass');
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.panel2,
                        foregroundColor: AppColors.text,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: const Icon(Icons.account_tree_outlined, size: 16),
                      label: const Text('VER CUADRO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        context.push('/tournaments/${t.id}/bracket');
                      },
                    ),
                  ),
                ],
              )
            else if (isOpen && _activeHubTournamentIds.contains(t.id))
              ChamferButton(
                text: 'INSCRIBIRME A ESTE TORNEO',
                variant: ChamferButtonVariant.go,
                onPressed: () async {
                  await _tournamentRepo.save(t);
                  if (context.mounted) {
                    await context.push('/tournaments/${t.id}/register');
                    if (context.mounted) {
                      context.read<TournamentBloc>().add(TournamentStarted());
                    }
                  }
                },
              )
            else if (isOpen)
              ChamferButton(
                text: 'HUB INACTIVO · CONECTAR CON ORGANIZADOR',
                variant: ChamferButtonVariant.ghost,
                icon: const Icon(Icons.wifi_find_rounded, size: 16, color: AppColors.mute),
                onPressed: () => _showConnectHubDialog(context),
              )
            else if (t.status == TournamentStatus.completed)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFFCC00),
                        side: const BorderSide(color: Color(0xFFFFCC00)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: const Icon(Icons.badge, size: 16),
                      label: const Text('DIPLOMA / TARJETA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        ChampionCardDialog.show(
                          context,
                          tournamentName: t.name,
                          tierLabel: t.tier.label,
                          bladerName: t.championName ?? 'Campeón',
                          placeRank: 1,
                          deckEntries: const [
                            ChampionDeckEntry(
                              blade: Part(id: 'shark_scale', name: 'Shark Scale', type: PartType.blade, system: BeySystem.bx, productCode: 'BX-34'),
                              ratchet: Part(id: '9-60', name: '9-60', code: '9-60', type: PartType.ratchet, system: BeySystem.bx),
                              bit: Part(id: 'elevate', name: 'Elevate', code: 'E', type: PartType.bit, system: BeySystem.bx),
                              archetype: 'Ataque',
                            ),
                          ],
                          eventDate: t.createdAt,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.panel2,
                        foregroundColor: AppColors.text,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: const Icon(Icons.account_tree_outlined, size: 16),
                      label: const Text('VER CUADRO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        context.push('/tournaments/${t.id}/bracket');
                      },
                    ),
                  ),
                ],
              )
            else
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.steel,
                  foregroundColor: AppColors.mute,
                  minimumSize: const Size(double.infinity, 40),
                ),
                icon: const Icon(Icons.account_tree_outlined, size: 16),
                label: const Text('VER CUADRO Y RESULTADOS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                onPressed: () {
                  context.push('/tournaments/${t.id}/bracket');
                },
              ),
          ],
        ),
      ),
    );
  }
}
