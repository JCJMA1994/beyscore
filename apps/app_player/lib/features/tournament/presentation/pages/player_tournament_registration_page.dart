import 'dart:convert';
import 'dart:io';

import 'package:bey_domain/bey_domain.dart';
import 'package:bey_ui/bey_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import 'player_tournaments_page.dart';

class PlayerTournamentRegistrationPage extends StatefulWidget {
  const PlayerTournamentRegistrationPage({
    super.key,
    required this.tournamentId,
  });

  final String tournamentId;

  @override
  State<PlayerTournamentRegistrationPage> createState() => _PlayerTournamentRegistrationPageState();
}

class _PlayerTournamentRegistrationPageState extends State<PlayerTournamentRegistrationPage> {
  final _tournamentRepo = getIt<TournamentRepository>();
  final _deckRepo = getIt<DeckRepository>();
  final _comboRepo = getIt<ComboRepository>();
  final _identityRepo = getIt<IdentityRepository>();
  final _deckValidator = getIt<DeckValidator>();

  Tournament? _tournament;
  UserProfile? _profile;
  List<Deck> _allDecks = [];
  Map<String, Combo> _combosMap = {};
  Deck? _selectedDeck;
  AgeDivision _selectedDivision = AgeDivision.open;
  bool _isLoading = true;
  bool _isRegistering = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final profile = await _identityRepo.getActiveProfile();
      final combos = await _comboRepo.watchAll().first;
      final decks = await _deckRepo.watchAll().first;

      Tournament? tournament;
      try {
        final tournamentStream = _tournamentRepo.watchById(widget.tournamentId);
        tournament = await tournamentStream.first;
      } catch (_) {}

      if (tournament == null) {
        final allTournaments = await _tournamentRepo.watchAll().first;
        tournament = allTournaments.where((t) => t.id == widget.tournamentId).firstOrNull;
      }

      if (mounted) {
        setState(() {
          _profile = profile;
          _tournament = tournament;
          _allDecks = decks;
          _combosMap = {for (final c in combos) c.id: c};
          if (tournament != null) {
            _selectedDivision = tournament.ageDivision;
          }
          if (decks.isNotEmpty && (_selectedDeck == null || !decks.any((d) => d.id == _selectedDeck?.id))) {
            _selectedDeck = decks.last;
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _navigateToCreateDeck() async {
    await context.push('/decks/new');
    if (mounted) {
      await _loadData();
    }
  }

  bool _isDeckLegal(Deck? deck) {
    if (deck == null || deck.comboIds.length != 3) return false;
    final c1 = _combosMap[deck.comboIds[0]];
    final c2 = _combosMap[deck.comboIds[1]];
    final c3 = _combosMap[deck.comboIds[2]];

    if (c1 == null || c2 == null || c3 == null) return false;

    try {
      final beys = [c1, c2, c3].map((c) {
        return BeyBuild(
          spinsLeft: false,
          parts: [
            PartRef(identityKey: c.bladeId, name: c.bladeId, type: PartKind.blade),
            PartRef(identityKey: c.ratchetId, name: c.ratchetId, type: PartKind.ratchet),
            PartRef(identityKey: c.bitId, name: c.bitId, type: PartKind.bit),
          ],
        );
      }).toList();

      final result = _deckValidator.validate(
        beys,
        isSingles: false,
        hallOfFamePartIds: const {},
        ownsLeftLauncher: true,
      );

      return result.isRight();
    } catch (_) {
      return false;
    }
  }

  Future<void> _notifyHubOfRegistration(String nickname, Deck deck) async {
    final combosPayload = deck.comboIds.map((cid) {
      final c = _combosMap[cid];
      if (c == null) return {'id': cid};
      return {
        'id': c.id,
        'name': c.name,
        'bladeId': c.bladeId,
        'ratchetId': c.ratchetId,
        'bitId': c.bitId,
        'lockChipId': c.lockChipId,
        'assistBladeId': c.assistBladeId,
        'system': c.system.index,
        'calculatedWeight': c.calculatedWeight,
      };
    }).toList();

    final candidateHosts = [
      PlayerTournamentsPage.lastHubHost,
      '127.0.0.1',
      '10.0.2.2',
      'localhost',
    ];

    for (final host in candidateHosts.toSet()) {
      if (host.isEmpty) continue;
      var cleanHost = host.trim();
      if (cleanHost.startsWith('http://')) cleanHost = cleanHost.substring(7);
      if (cleanHost.startsWith('https://')) cleanHost = cleanHost.substring(8);
      var targetPort = 8080;
      if (cleanHost.contains(':')) {
        final parts = cleanHost.split(':');
        cleanHost = parts[0];
        final p = int.tryParse(parts[1].replaceAll(RegExp('[^0-9]'), ''));
        if (p != null) targetPort = p;
      }
      if (cleanHost.endsWith('/')) cleanHost = cleanHost.substring(0, cleanHost.length - 1);
      if (cleanHost.isEmpty) continue;

      try {
        final client = HttpClient()..connectionTimeout = const Duration(seconds: 3);
        final request = await client.postUrl(Uri.parse('http://$cleanHost:$targetPort/api/tournament/register'));
        request.headers.contentType = ContentType.json;
        request.write(jsonEncode({
          'nickname': nickname,
          'deck': {
            'id': deck.id,
            'name': deck.name,
            'comboIds': deck.comboIds,
          },
          'combos': combosPayload,
        }));
        final response = await request.close();
        if (response.statusCode == HttpStatus.ok) {
          break;
        }
      } catch (_) {}
    }
  }

  Future<void> _register() async {
    if (_tournament == null || _profile == null) return;
    if (_selectedDeck == null) {
      await BeyFeedbackDialog.showError(
        context,
        title: 'Deck 3on3 Requerido',
        message: 'No puedes inscribirte a un torneo oficial sin registrar tu Deck de 3 Beys reglamentario.',
        solution: 'Crea o selecciona un Deck 3on3 legal de tu inventario en la lista de abajo.',
      );
      return;
    }

    setState(() => _isRegistering = true);

    final currentParticipants = List<String>.from(_tournament!.participants);
    if (!currentParticipants.contains(_profile!.nickname)) {
      currentParticipants.add(_profile!.nickname);
    }

    final updated = _tournament!.copyWith(
      participants: currentParticipants,
    );

    await _tournamentRepo.save(updated);
    await _notifyHubOfRegistration(_profile!.nickname, _selectedDeck!);

    if (mounted) {
      context.pushReplacement('/tournaments/${widget.tournamentId}/pass');
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
    if (t == null) {
      return Scaffold(
        backgroundColor: AppColors.void_,
        appBar: AppBar(title: const Text('TORNEO NO ENCONTRADO')),
        body: const Center(child: Text('El torneo solicitado no existe.')),
      );
    }

    final isLegal = _isDeckLegal(_selectedDeck);

    return Scaffold(
      backgroundColor: AppColors.void_,
      appBar: AppBar(
        backgroundColor: AppColors.steel,
        title: Text(
          'INSCRIBIRSE · ${t.name.toUpperCase()}',
          style: AppTypography.mono.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tournament Header Card
            Container(
              padding: const EdgeInsets.all(16),
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
                        'INSCRIPCIÓN ABIERTA',
                        style: AppTypography.mono.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.x,
                        ),
                      ),
                      Text(
                        '${t.participants.length} PARTICIPANTES',
                        style: AppTypography.mono.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.pegasus,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.name.toUpperCase(),
                    style: AppTypography.displayMedium.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Reglamento Oficial Beyblade X v12 · Sistema 3on3',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.mute, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Age Division Selection
            Text(
              'TU CATEGORÍA / DIVISIÓN',
              style: AppTypography.mono.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.mute,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildDivisionChip(
                    division: AgeDivision.open,
                    label: 'ABIERTA 6+',
                    isSelected: _selectedDivision == AgeDivision.open,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDivisionChip(
                    division: AgeDivision.regular,
                    label: 'REGULAR 6–12',
                    isSelected: _selectedDivision == AgeDivision.regular,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Deck Selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CON QUÉ DECK 3ON3 PARTICIPAS',
                  style: AppTypography.mono.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.mute,
                  ),
                ),
                TextButton(
                  onPressed: _navigateToCreateDeck,
                  child: Text(
                    '+ CREAR DECK',
                    style: AppTypography.mono.copyWith(fontSize: 11, color: AppColors.x, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            if (_allDecks.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.panel,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.line),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.layers_clear, size: 36, color: AppColors.mute),
                    const SizedBox(height: 8),
                    const Text('No tienes ningún Deck 3on3 creado aún.'),
                    const SizedBox(height: 12),
                    ChamferButton(
                      text: 'Crear Deck 3on3',
                      variant: ChamferButtonVariant.go,
                      onPressed: _navigateToCreateDeck,
                    ),
                  ],
                ),
              )
            else
              ..._allDecks.map((d) {
                final isSelected = _selectedDeck?.id == d.id;
                final deckLegal = _isDeckLegal(d);

                final beysNames = d.comboIds.map((cid) {
                  final c = _combosMap[cid];
                  return c?.name ?? cid;
                }).join(' · ');

                return InkWell(
                  onTap: () => setState(() => _selectedDeck = d),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.panel2 : AppColors.panel,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppColors.x : AppColors.line,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: isSelected ? AppColors.x : AppColors.mute,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                d.name.toUpperCase(),
                                style: AppTypography.mono.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                beysNames,
                                style: AppTypography.bodySmall.copyWith(fontSize: 10.5, color: AppColors.mute),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: deckLegal ? AppColors.x.withValues(alpha: 0.15) : AppColors.dranzer.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: deckLegal ? AppColors.x : AppColors.dranzer),
                          ),
                          child: Text(
                            deckLegal ? 'LEGAL' : 'ILEGAL',
                            style: AppTypography.mono.copyWith(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: deckLegal ? AppColors.x : AppColors.dranzer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

            const SizedBox(height: 16),

            // Warning note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.pegasus.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.pegasus.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.pegasus, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Chequeo de piezas obligatorio: El día del torneo se escaneará tu código QR y tu deck quedará bloqueado.',
                      style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.text),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            ChamferButton(
              text: _isRegistering ? 'INSCRIBIENDO...' : 'CONFIRMAR INSCRIPCIÓN',
              variant: (isLegal && !_isRegistering) ? ChamferButtonVariant.go : ChamferButtonVariant.ghost,
              onPressed: (isLegal && !_isRegistering) ? _register : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivisionChip({
    required AgeDivision division,
    required String label,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => setState(() => _selectedDivision = division),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.x.withValues(alpha: 0.15) : AppColors.panel,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? AppColors.x : AppColors.line,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.mono.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.x : AppColors.mute,
            ),
          ),
        ),
      ),
    );
  }
}
