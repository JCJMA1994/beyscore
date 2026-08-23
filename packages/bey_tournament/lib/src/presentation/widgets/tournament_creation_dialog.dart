import 'dart:math' as math;
import 'package:bey_domain/bey_domain.dart';
import 'package:bey_ui/bey_ui.dart';
import 'package:flutter/material.dart';

class TournamentCreationDialog extends StatefulWidget {
  const TournamentCreationDialog({
    super.key,
    this.organizerId = 'organizer-local',
  });

  final String organizerId;

  @override
  State<TournamentCreationDialog> createState() => _TournamentCreationDialogState();
}

class _TournamentCreationDialogState extends State<TournamentCreationDialog> {
  final _nameController = TextEditingController(text: 'Copa Beyblade X 2026');
  final _bladerInputController = TextEditingController();

  TournamentTier _selectedTier = TournamentTier.g3;
  AgeDivision _selectedAge = AgeDivision.open;
  int _seed = math.Random().nextInt(999999);

  final List<String> _participants = [
    'Tyson Granger',
    'Kai Hiwatari',
    'Ray Kon',
    'Max Tate',
    'Robin Kazami',
    'Bird Kazami',
    'Multi Nanairo',
    'Ekusu Kurosu',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _bladerInputController.dispose();
    super.dispose();
  }

  void _addParticipant() {
    final name = _bladerInputController.text.trim();
    if (name.isNotEmpty && !_participants.contains(name)) {
      setState(() {
        _participants.add(name);
        _bladerInputController.clear();
      });
    }
  }

  void _removeParticipant(int index) {
    setState(() => _participants.removeAt(index));
  }

  void _loadPreset(int count) {
    final presetNames = [
      'Ekusu Kurosu',
      'Bird Kazami',
      'Multi Nanairo',
      'Tyson Granger',
      'Kai Hiwatari',
      'Ray Kon',
      'Max Tate',
      'Brooklyn M.',
      'Ryuga',
      'Ginga Hagane',
      'Kyoya Tategami',
      'Valt Aoi',
      'Shu Kurenai',
      'Free De La Hoya',
      'Lui Shirosagijo',
      'Aiga Akaba',
      'Daigo Kurogami',
      'Rantaro Kiyama',
      'Wakiya Murasaki',
      'Ken Midori',
      'Silas Karlisle',
      'Joshua Burns',
      'Cuza Ackermann',
      'Ren Kurenai',
      'Meiko Ohtori',
      'King',
      'Jack',
      'Damian Hart',
      'Zeo Abyss',
      'Tsubasa Otori',
      'Yu Tendo',
      'Masamune Kadoya',
    ];

    setState(() {
      _participants
        ..clear()
        ..addAll(presetNames.take(count));
    });
  }

  void _regenerateSeed() {
    setState(() => _seed = math.Random().nextInt(999999));
  }

  void _createTournament() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      BeyFeedbackDialog.showError(
        context,
        title: 'Nombre de Torneo Requerido',
        message: 'No puedes crear un torneo sin un nombre oficial.',
        solution: 'Escribe el nombre del torneo en el campo superior.',
      );
      return;
    }
    if (_participants.length < 2) {
      BeyFeedbackDialog.showError(
        context,
        title: 'Participantes Insuficientes',
        message: 'Se requieren al menos 2 competidores para armar el cuadro del torneo.',
        solution: 'Usa los botones de preajuste (8, 16, 32) o agrega los nombres de los Bladers manualmente.',
      );
      return;
    }

    const generator = BracketGenerator();
    final rounds = generator.generateBracketTree(
      playerNames: _participants,
      seed: _seed,
    );

    final tournament = Tournament(
      id: UuidV7Generator.v7(),
      name: name,
      organizerIds: [widget.organizerId],
      tier: _selectedTier,
      ageDivision: _selectedAge,
      status: TournamentStatus.inProgress,
      participants: List.unmodifiable(_participants),
      rounds: rounds,
      seed: _seed,
      createdAt: DateTime.now(),
    );

    Navigator.of(context).pop(tournament);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.void_,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.line),
      ),
      child: Container(
        width: 540,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.emoji_events, color: AppColors.pegasus, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'ORGANIZAR TORNEO',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: AppColors.mute, size: 20),
                ),
              ],
            ),
            const Divider(color: AppColors.line),
            const SizedBox(height: 12),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name Field
                    Text('NOMBRE DEL TORNEO', style: AppTypography.mono.copyWith(fontSize: 10, color: AppColors.mute)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _nameController,
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.text),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.steel,
                        hintText: 'Ej. Copa Regional Lima 2026',
                        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.mute),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.line),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tier Selection
                    Text('CATEGORÍA OFICIAL', style: AppTypography.mono.copyWith(fontSize: 10, color: AppColors.mute)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: TournamentTier.values.map((tier) {
                        final isSelected = tier == _selectedTier;
                        final tierColor = Color(tier.colorValue);
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
                          selectedColor: tierColor,
                          backgroundColor: AppColors.panel,
                          side: BorderSide(color: isSelected ? tierColor : AppColors.line),
                          onSelected: (val) {
                            if (val) setState(() => _selectedTier = tier);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Age Division
                    Text('DIVISIÓN DE EDAD', style: AppTypography.mono.copyWith(fontSize: 10, color: AppColors.mute)),
                    const SizedBox(height: 8),
                    Row(
                      children: AgeDivision.values.map((div) {
                        final isSelected = div == _selectedAge;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(
                              div.label,
                              style: AppTypography.mono.copyWith(
                                fontSize: 11,
                                color: isSelected ? Colors.black : AppColors.text,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: AppColors.dragoon,
                            backgroundColor: AppColors.panel,
                            side: BorderSide(color: isSelected ? AppColors.dragoon : AppColors.line),
                            onSelected: (val) {
                              if (val) setState(() => _selectedAge = div);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Seed & Random Draw Auditing
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.steel,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SEMILLA DE SORTEO (PRNG AUDITABLE)',
                                style: AppTypography.mono.copyWith(fontSize: 9, color: AppColors.mute),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '#$_seed',
                                style: AppTypography.mono.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF00FF66),
                                ),
                              ),
                            ],
                          ),
                          OutlinedButton.icon(
                            onPressed: _regenerateSeed,
                            icon: const Icon(Icons.shuffle, size: 14, color: AppColors.pegasus),
                            label: Text('RE-SORTEAR', style: AppTypography.mono.copyWith(fontSize: 10, color: AppColors.pegasus)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.pegasus),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Participants List
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'BLADERS INSCRITOS (${_participants.length})',
                          style: AppTypography.mono.copyWith(fontSize: 10, color: AppColors.mute),
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => _loadPreset(4),
                              child: Text('4P', style: AppTypography.mono.copyWith(fontSize: 10, color: AppColors.pegasus)),
                            ),
                            TextButton(
                              onPressed: () => _loadPreset(8),
                              child: Text('8P', style: AppTypography.mono.copyWith(fontSize: 10, color: AppColors.pegasus)),
                            ),
                            TextButton(
                              onPressed: () => _loadPreset(16),
                              child: Text('16P', style: AppTypography.mono.copyWith(fontSize: 10, color: AppColors.pegasus)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Add Blader Input
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _bladerInputController,
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.text),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.steel,
                              hintText: 'Nombre del Blader...',
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
                            backgroundColor: AppColors.dragoon,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Participant Chips
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.panel,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: _participants.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text(
                                  'Agrega participantes para generar el bracket.',
                                  style: AppTypography.bodySmall.copyWith(color: AppColors.mute),
                                ),
                              ),
                            )
                          : Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: List.generate(_participants.length, (index) {
                                final name = _participants[index];
                                return Chip(
                                  backgroundColor: AppColors.steel,
                                  side: const BorderSide(color: AppColors.line),
                                  label: Text(
                                    '#${index + 1} $name',
                                    style: AppTypography.mono.copyWith(fontSize: 11, color: AppColors.text),
                                  ),
                                  deleteIcon: const Icon(Icons.close, size: 14, color: AppColors.mute),
                                  onDeleted: () => _removeParticipant(index),
                                );
                              }),
                            ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Divider(color: AppColors.line),
            const SizedBox(height: 8),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.mute,
                    side: const BorderSide(color: AppColors.line),
                  ),
                  child: const Text('CANCELAR'),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _createTournament,
                  icon: const Icon(Icons.play_arrow, size: 16),
                  label: const Text('CREAR Y GENERAR LLAVES'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF00FF66),
                    foregroundColor: Colors.black,
                    textStyle: AppTypography.mono.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
