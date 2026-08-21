import 'dart:math' as math;
import 'package:bey_domain/bey_domain.dart';
import 'package:bey_ui/bey_ui.dart';
import 'package:flutter/material.dart';

/// Full screen page for tournament creation (Organizer mode).
class TournamentCreatePage extends StatefulWidget {
  const TournamentCreatePage({
    super.key,
    this.organizerNickname,
    this.organizerId = 'organizer-local',
  });

  final String? organizerNickname;
  final String organizerId;

  @override
  State<TournamentCreatePage> createState() => _TournamentCreatePageState();
}

class _TournamentCreatePageState extends State<TournamentCreatePage> {
  final _nameController = TextEditingController(text: 'Copa Beyblade X 2026');
  final _organizerNicknameController = TextEditingController();
  final _bladerInputController = TextEditingController();

  TournamentTier _selectedTier = TournamentTier.g3;
  AgeDivision _selectedAge = AgeDivision.open;
  int _seed = math.Random().nextInt(999999);

  bool _isOpenRegistration = true;
  bool _organizerIsPlayer = false;

  final List<String> _manualParticipants = [];

  @override
  void initState() {
    super.initState();
    _organizerNicknameController.text = widget.organizerNickname ?? 'Organizador';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _organizerNicknameController.dispose();
    _bladerInputController.dispose();
    super.dispose();
  }

  void _addParticipant() {
    final name = _bladerInputController.text.trim();
    if (name.isNotEmpty && !_manualParticipants.contains(name)) {
      setState(() {
        _manualParticipants.add(name);
        _bladerInputController.clear();
      });
    }
  }

  void _removeParticipant(int index) {
    setState(() => _manualParticipants.removeAt(index));
  }

  void _regenerateSeed() {
    setState(() => _seed = math.Random().nextInt(999999));
  }

  void _loadPreset(int count) {
    const presetNames = [
      'Tyson G.',
      'Kai Hiwatari',
      'Ray Kon',
      'Max Tate',
      'Bird Kazami',
      'Kamen X',
      'Multi Nanairo',
      'King',
      'Brooklyn M.',
      'Ryuga',
      'Ginga Hagane',
      'Kyoya Tategami',
      'Valt Aoi',
      'Shu Kurenai',
      'Free De La Hoya',
      'Lui Shirosagijo',
    ];
    setState(() {
      _manualParticipants
        ..clear()
        ..addAll(presetNames.take(count));
    });
  }

  List<String> _buildFinalParticipantsList() {
    final list = <String>[];
    if (_organizerIsPlayer) {
      final orgName = _organizerNicknameController.text.trim();
      list.add(orgName.isNotEmpty ? orgName : 'Organizador');
    }
    for (final p in _manualParticipants) {
      if (!list.contains(p)) {
        list.add(p);
      }
    }
    return list;
  }

  void _createTournament() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      BeyFeedbackDialog.showError(
        context,
        title: 'Nombre de Torneo Requerido',
        message: 'No puedes crear un torneo sin especificar su nombre oficial.',
        solution: 'Ingresa un nombre identificativo para la competencia (ej. "Copa Beyblade X 2026").',
      );
      return;
    }

    final participants = _buildFinalParticipantsList();

    if (!_isOpenRegistration && participants.length < 2) {
      BeyFeedbackDialog.showError(
        context,
        title: 'Participantes Insuficientes',
        message: 'El modo de inicio inmediato requiere al menos 2 competidores para generar la llave eliminatoria.',
        solution: 'Agrega al menos 2 Bladers o activa la opción "Habilitar Inscripciones Abiertas (LAN)" para que se unan desde sus móviles.',
      );
      return;
    }

    final List<BracketRound> rounds;
    final TournamentStatus status;

    if (_isOpenRegistration) {
      rounds = const [];
      status = TournamentStatus.registration;
    } else {
      const generator = BracketGenerator();
      rounds = generator.generateBracketTree(
        playerNames: participants,
        seed: _seed,
      );
      status = TournamentStatus.inProgress;
    }

    final tournament = Tournament(
      id: const UuidV7Generator().generate(),
      name: name,
      organizerIds: [widget.organizerId],
      tier: _selectedTier,
      ageDivision: _selectedAge,
      status: status,
      participants: List.unmodifiable(participants),
      rounds: rounds,
      seed: _seed,
      createdAt: DateTime.now(),
    );

    Navigator.of(context).pop(tournament);
  }

  @override
  Widget build(BuildContext context) {
    final tierColor = Color(_selectedTier.colorValue);
    final participants = _buildFinalParticipantsList();

    return Scaffold(
      backgroundColor: AppColors.void_,
      appBar: AppBar(
        backgroundColor: AppColors.steel,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'CREAR TORNEO',
          style: AppTypography.mono.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: _createTournament,
              icon: const Icon(Icons.check, size: 16, color: Color(0xFF00FF66)),
              label: Text(
                'GUARDAR',
                style: AppTypography.mono.copyWith(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00FF66),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner Section
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.panel,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.line),
                gradient: LinearGradient(
                  colors: [
                    AppColors.panel,
                    tierColor.withValues(alpha: 0.12),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: tierColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: tierColor),
                    ),
                    child: Icon(Icons.emoji_events, color: tierColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CONFIGURACIÓN DEL TORNEO',
                          style: AppTypography.displaySmall.copyWith(fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Reglamento oficial Takara Tomy v12 con sorteo auditable.',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.mute, fontSize: 10.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Section 1: Tournament Name
            _buildSectionCard(
              title: '1. NOMBRE DEL TORNEO',
              icon: Icons.title,
              child: TextField(
                controller: _nameController,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.text),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.steel,
                  hintText: 'Ej. Copa Regional Beyblade X 2026',
                  hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.mute),
                  prefixIcon: const Icon(Icons.edit_note, color: AppColors.mute, size: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.line),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Section 2: Official Tier
            _buildSectionCard(
              title: '2. CATEGORÍA OFICIAL (TIER)',
              icon: Icons.shield,
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: TournamentTier.values.map((tier) {
                  final isSelected = tier == _selectedTier;
                  final tColor = Color(tier.colorValue);
                  return ChoiceChip(
                    label: Text(
                      '${tier.label} (${tier.capacityNote})',
                      style: AppTypography.mono.copyWith(
                        fontSize: 10,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.black : AppColors.text,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: tColor,
                    backgroundColor: AppColors.steel,
                    side: BorderSide(color: isSelected ? tColor : AppColors.line),
                    onSelected: (val) {
                      if (val) setState(() => _selectedTier = tier);
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),

            // Section 3: Age Division
            _buildSectionCard(
              title: '3. DIVISIÓN DE EDAD',
              icon: Icons.people,
              child: Row(
                children: AgeDivision.values.map((div) {
                  final isSelected = div == _selectedAge;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: InkWell(
                        onTap: () => setState(() => _selectedAge = div),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.dragoon.withValues(alpha: 0.15) : AppColors.steel,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isSelected ? AppColors.dragoon : AppColors.line,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              div.label.toUpperCase(),
                              style: AppTypography.mono.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? AppColors.dragoon : AppColors.mute,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),

            // Section 4: Modalidad de Inscripción
            _buildSectionCard(
              title: '4. MODALIDAD DE INSCRIPCIÓN',
              icon: Icons.how_to_reg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildRegistrationModeButton(
                          title: 'INSCRIPCIÓN ABIERTA',
                          subtitle: 'Los Bladers se inscriben desde su app con su Deck',
                          isSelected: _isOpenRegistration,
                          onTap: () => setState(() => _isOpenRegistration = true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildRegistrationModeButton(
                          title: 'INICIO INMEDIATO',
                          subtitle: 'Generar bracket ahora con lista offline o presets',
                          isSelected: !_isOpenRegistration,
                          onTap: () => setState(() => _isOpenRegistration = false),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Section 5: Participación del Organizador
            _buildSectionCard(
              title: '5. PARTICIPACIÓN DEL ORGANIZADOR',
              icon: Icons.person_pin,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: AppColors.x,
                    title: Text(
                      '¿El organizador también compite como jugador?',
                      style: AppTypography.mono.copyWith(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Se registrará tu apodo automáticamente en la lista de participantes.',
                      style: AppTypography.bodySmall.copyWith(fontSize: 10, color: AppColors.mute),
                    ),
                    value: _organizerIsPlayer,
                    onChanged: (val) => setState(() => _organizerIsPlayer = val),
                  ),
                  if (_organizerIsPlayer) ...[
                    const SizedBox(height: 6),
                    TextField(
                      controller: _organizerNicknameController,
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.text),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.steel,
                        labelText: 'Apodo de Blader del Organizador',
                        labelStyle: AppTypography.mono.copyWith(fontSize: 11, color: AppColors.x),
                        prefixIcon: const Icon(Icons.sports_esports, color: AppColors.x, size: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.line),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Section 6: Seed & PRNG Auditing
            _buildSectionCard(
              title: '6. SEMILLA DE SORTEO (PRNG AUDITABLE)',
              icon: Icons.casino_outlined,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Semilla criptográfica de emparejamientos:',
                          style: AppTypography.bodySmall.copyWith(fontSize: 10, color: AppColors.mute),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '#$_seed',
                          style: AppTypography.mono.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF00FF66),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _regenerateSeed,
                    icon: const Icon(Icons.shuffle, size: 14, color: AppColors.pegasus),
                    label: Text(
                      'RE-SORTEAR',
                      style: AppTypography.mono.copyWith(fontSize: 10, color: AppColors.pegasus, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.pegasus),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Section 7: Participantes Offline / Presets (Opcional)
            _buildSectionCard(
              title: '7. BLADERS PARTICIPANTES (${participants.length})',
              icon: Icons.group_add,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!_isOpenRegistration) ...[
                    Row(
                      children: [
                        Text('Presets rápidos:', style: AppTypography.mono.copyWith(fontSize: 10, color: AppColors.mute)),
                        const Spacer(),
                        _buildPresetButton(4),
                        _buildPresetButton(8),
                        _buildPresetButton(16),
                        _buildPresetButton(32),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Input to add blader manually
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _bladerInputController,
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.text),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.steel,
                            hintText: 'Agregar Blader offline...',
                            hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.mute),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AppColors.line),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          onSubmitted: (_) => _addParticipant(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: _addParticipant,
                        icon: const Icon(Icons.add, size: 18),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.x,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Participant list chips
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 50),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.void_,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: participants.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                _isOpenRegistration
                                    ? 'Los jugadores podrán inscribirse desde su app una vez creado el torneo.'
                                    : 'Agrega al menos 2 participantes para generar el bracket.',
                                textAlign: TextAlign.center,
                                style: AppTypography.bodySmall.copyWith(color: AppColors.mute, fontSize: 10.5),
                              ),
                            ),
                          )
                        : Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: List.generate(participants.length, (index) {
                              final name = participants[index];
                              final isOrganizer = _organizerIsPlayer && index == 0;

                              return Chip(
                                backgroundColor: isOrganizer ? AppColors.x.withValues(alpha: 0.15) : AppColors.steel,
                                side: BorderSide(color: isOrganizer ? AppColors.x : AppColors.line),
                                avatar: CircleAvatar(
                                  backgroundColor: isOrganizer ? AppColors.x : AppColors.dragoon.withValues(alpha: 0.3),
                                  child: Text(
                                    '${index + 1}',
                                    style: AppTypography.mono.copyWith(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ),
                                label: Text(
                                  isOrganizer ? '$name (Organizador)' : name,
                                  style: AppTypography.mono.copyWith(fontSize: 10.5, color: AppColors.text),
                                ),
                                deleteIcon: isOrganizer ? null : const Icon(Icons.close, size: 14, color: AppColors.mute),
                                onDeleted: isOrganizer
                                    ? null
                                    : () {
                                        final manualIdx = _organizerIsPlayer ? index - 1 : index;
                                        if (manualIdx >= 0 && manualIdx < _manualParticipants.length) {
                                          _removeParticipant(manualIdx);
                                        }
                                      },
                              );
                            }),
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Submit Button
            ChamferButton(
              text: _isOpenRegistration
                  ? 'CREAR Y ABRIR INSCRIPCIÓN'
                  : 'CREAR Y GENERAR LLAVES (${participants.length}P)',
              variant: (!_isOpenRegistration && participants.length < 2)
                  ? ChamferButtonVariant.ghost
                  : ChamferButtonVariant.go,
              onPressed: (!_isOpenRegistration && participants.length < 2) ? null : _createTournament,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationModeButton({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.x.withValues(alpha: 0.15) : AppColors.steel,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? AppColors.x : AppColors.line,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTypography.mono.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.x : AppColors.text,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTypography.bodySmall.copyWith(fontSize: 9, color: AppColors.mute),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetButton(int count) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: TextButton(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: () => _loadPreset(count),
        child: Text(
          '${count}P',
          style: AppTypography.mono.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.pegasus,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
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
            children: [
              Icon(icon, size: 15, color: AppColors.mute),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.mono.copyWith(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.mute,
                    letterSpacing: 1.1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
