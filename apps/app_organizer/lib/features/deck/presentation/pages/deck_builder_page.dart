import 'package:bey_domain/bey_domain.dart';
import 'package:bey_ui/bey_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';

class DeckBuilderPage extends StatefulWidget {
  const DeckBuilderPage({super.key});

  @override
  State<DeckBuilderPage> createState() => _DeckBuilderPageState();
}

class _DeckBuilderPageState extends State<DeckBuilderPage> {
  final _comboRepo = getIt<ComboRepository>();
  final _deckRepo = getIt<DeckRepository>();
  final _catalogRepo = getIt<CatalogRepository>();
  final _deckValidator = getIt<DeckValidator>();

  final _nameController = TextEditingController(text: 'Mi Deck 3on3');

  Combo? _combo1;
  Combo? _combo2;
  Combo? _combo3;

  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  List<DeckViolation> _checkViolations() {
    if (_combo1 == null || _combo2 == null || _combo3 == null) {
      return [];
    }

    final beys = [_combo1!, _combo2!, _combo3!].map((c) {
      final parts = <PartRef>[
        PartRef(identityKey: c.bladeId, name: c.bladeId, type: PartKind.blade),
        PartRef(identityKey: c.ratchetId, name: c.ratchetId, type: PartKind.ratchet),
        PartRef(identityKey: c.bitId, name: c.bitId, type: PartKind.bit),
      ];
      if (c.lockChipId != null && c.lockChipId!.isNotEmpty) {
        parts.add(PartRef(identityKey: c.lockChipId!, name: c.lockChipId!, type: PartKind.lockChip));
      }
      if (c.assistBladeId != null && c.assistBladeId!.isNotEmpty) {
        parts.add(PartRef(identityKey: c.assistBladeId!, name: c.assistBladeId!, type: PartKind.assistBlade));
      }
      if (c.overBladeId != null && c.overBladeId!.isNotEmpty) {
        parts.add(PartRef(identityKey: c.overBladeId!, name: c.overBladeId!, type: PartKind.overBlade));
      }
      final isLeft = c.bladeId.toLowerCase().contains('dragoon') || c.bladeId.toLowerCase().contains('l-');
      return BeyBuild(
        spinsLeft: isLeft,
        parts: parts,
      );
    }).toList();

    final result = _deckValidator.validate(
      beys,
      isSingles: false,
      hallOfFamePartIds: const {},
      ownsLeftLauncher: true,
    );

    return result.fold((violations) => violations, (_) => []);
  }

  void _openComboSelector(int slotIndex, List<Combo> allCombos, Map<String, Part> bladesMap) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.void_,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        side: BorderSide(color: AppColors.line),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: AppColors.steel,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SELECCIONAR BEY PARA POSICIÓN #$slotIndex',
                  style: AppTypography.mono.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.mute),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
          ),
          if (allCombos.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text('No tienes combos creados en tu arsenal.'),
                  const SizedBox(height: 12),
                  ChamferButton(
                    text: 'CREAR UN COMBO PRIMERO',
                    variant: ChamferButtonVariant.go,
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.push('/combos/new');
                    },
                  ),
                ],
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.all(12),
                itemCount: allCombos.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final c = allCombos[index];
                  final bladePart = bladesMap[c.bladeId];

                  final accentColor = switch (bladePart?.beyType) {
                    BeyType.attack => AppColors.dranzer,
                    BeyType.defense => AppColors.dragoon,
                    BeyType.stamina => AppColors.pegasus,
                    BeyType.balance => AppColors.burst,
                    null => AppColors.x,
                  };

                  return InkWell(
                    onTap: () {
                      setState(() {
                        if (slotIndex == 1) _combo1 = c;
                        if (slotIndex == 2) _combo2 = c;
                        if (slotIndex == 3) _combo3 = c;
                      });
                      Navigator.pop(ctx);
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.panel,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Row(
                        children: [
                          PartImage(
                            type: PartType.blade,
                            imageRemote: bladePart?.imageRemote,
                            imageLocal: bladePart?.imageLocal,
                            size: 40,
                            color: accentColor,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.name.toUpperCase(),
                                  style: AppTypography.mono.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${c.bladeId.replaceAll('blade-', '')} · ${c.ratchetId.replaceAll('ratchet-', '')} · ${c.bitId.replaceAll('bit-', '')}',
                                  style: AppTypography.bodySmall.copyWith(color: AppColors.mute, fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                          if (c.calculatedWeight != null)
                            Text(
                              '${c.calculatedWeight}g',
                              style: AppTypography.mono.copyWith(fontSize: 11, color: AppColors.x, fontWeight: FontWeight.bold),
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

  Future<void> _saveDeck() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      await BeyFeedbackDialog.showError(
        context,
        title: 'Nombre de Deck Requerido',
        message: 'Debes asignarle un nombre a tu alineación 3on3 antes de guardarla.',
        solution: 'Ingresa un nombre en la parte superior (ej. "Deck Torneo G1").',
      );
      return;
    }

    if (_combo1 == null || _combo2 == null || _combo3 == null) {
      await BeyFeedbackDialog.showError(
        context,
        title: 'Alineación Incompleta',
        message: 'Un Deck 3on3 oficial de Beyblade X debe contener exactamente 3 Beys armados.',
        solution: 'Selecciona los 3 Beys en las ranuras #1, #2 y #3.',
      );
      return;
    }

    final violations = _checkViolations();
    if (violations.isNotEmpty) {
      final reasons = violations.map((v) => '• ${v.message}').join('\n');
      await BeyFeedbackDialog.showError(
        context,
        title: 'Deck Ilegal (Reglamento v12)',
        message: 'Tu alineación no cumple con las reglas oficiales:\n$reasons',
        solution: 'Reemplaza las piezas o Beys duplicados. Ningún Blade, Ratchet o Bit puede repetirse entre los 3 Beys del mazo.',
      );
      return;
    }

    setState(() => _isSaving = true);

    final deck = Deck(
      id: 'deck-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      comboIds: [_combo1!.id, _combo2!.id, _combo3!.id],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _deckRepo.save(deck);

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Part>>(
      stream: _catalogRepo.watchByType(PartType.blade),
      builder: (context, bladeSnapshot) {
        final bladesMap = {for (final b in bladeSnapshot.data ?? <Part>[]) b.id: b};

        return StreamBuilder<List<Combo>>(
          stream: _comboRepo.watchAll(),
          builder: (context, comboSnapshot) {
            final allCombos = comboSnapshot.data ?? [];
            final violations = _checkViolations();
            final isAllSelected = _combo1 != null && _combo2 != null && _combo3 != null;
            final isLegal = isAllSelected && violations.isEmpty;

            final conflict12 = _hasPartConflict(_combo1, _combo2);
            final conflict23 = _hasPartConflict(_combo2, _combo3);

            return Scaffold(
              backgroundColor: AppColors.void_,
              appBar: AppBar(
                backgroundColor: AppColors.steel,
                title: Text(
                  'CREADOR DE DECK 3ON3',
                  style: AppTypography.mono.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Deck Name Input
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.panel,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NOMBRE DEL DECK',
                            style: AppTypography.mono.copyWith(fontSize: 9, color: AppColors.mute, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          TextField(
                            controller: _nameController,
                            style: AppTypography.displayMedium.copyWith(fontSize: 16),
                            decoration: const InputDecoration(
                              hintText: 'Ej: Deck Competitivo 3on3',
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              border: InputBorder.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Information banner
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.dragoon.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.dragoon.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: AppColors.dragoon, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'El orden de los 3 Beys define el orden de enfrentamiento oficial (Bey 1 vs Bey 1).',
                              style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.text),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Slot 1
                    _buildSlotCard(
                      slotIndex: 1,
                      combo: _combo1,
                      bladesMap: bladesMap,
                      hasConflict: conflict12,
                      onTap: () => _openComboSelector(1, allCombos, bladesMap),
                    ),

                    if (conflict12)
                      _buildConflictLink('MISMA PIEZA REPETIDA ENTRE BEY 1 Y BEY 2'),

                    const SizedBox(height: 8),

                    // Slot 2
                    _buildSlotCard(
                      slotIndex: 2,
                      combo: _combo2,
                      bladesMap: bladesMap,
                      hasConflict: conflict12 || conflict23,
                      onTap: () => _openComboSelector(2, allCombos, bladesMap),
                    ),

                    if (conflict23)
                      _buildConflictLink('MISMA PIEZA REPETIDA ENTRE BEY 2 Y BEY 3'),

                    const SizedBox(height: 8),

                    // Slot 3
                    _buildSlotCard(
                      slotIndex: 3,
                      combo: _combo3,
                      bladesMap: bladesMap,
                      hasConflict: conflict23,
                      onTap: () => _openComboSelector(3, allCombos, bladesMap),
                    ),
                    const SizedBox(height: 16),

                    // Status / Legality Box
                    if (isAllSelected)
                      if (isLegal)
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.x.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.x),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.verified, color: AppColors.x, size: 22),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'DECK 3ON3 LEGAL (OFICIAL V12)',
                                      style: AppTypography.mono.copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.x,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '9 piezas distintas · Sin piezas prohibidas · Cumple reglamento',
                                      style: AppTypography.bodySmall.copyWith(fontSize: 10.5, color: AppColors.text),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.dranzer.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.dranzer),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning, color: AppColors.dranzer, size: 22),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'DECK ILEGAL / CONFLICTO',
                                      style: AppTypography.mono.copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.dranzer,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      violations.isNotEmpty
                                          ? violations.first.message
                                          : 'El reglamento v12 prohíbe repetir piezas entre los 3 beys.',
                                      style: AppTypography.bodySmall.copyWith(fontSize: 10.5, color: AppColors.text),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    const SizedBox(height: 24),

                    // Save Button
                    ChamferButton(
                      text: _isSaving ? 'GUARDANDO...' : (isLegal ? 'GUARDAR DECK 3ON3' : 'COMPLETA UN DECK LEGAL'),
                      variant: isLegal ? ChamferButtonVariant.go : ChamferButtonVariant.ghost,
                      onPressed: isLegal && !_isSaving ? _saveDeck : null,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  bool _hasPartConflict(Combo? a, Combo? b) {
    if (a == null || b == null) return false;
    const normA = DeckValidator.normalizeIdentityKey;
    if (normA(a.bladeId) == normA(b.bladeId)) return true;
    if (normA(a.ratchetId) == normA(b.ratchetId)) return true;
    if (normA(a.bitId) == normA(b.bitId)) return true;
    if (a.assistBladeId != null && b.assistBladeId != null && normA(a.assistBladeId!) == normA(b.assistBladeId!)) return true;
    if (a.overBladeId != null && b.overBladeId != null && normA(a.overBladeId!) == normA(b.overBladeId!)) return true;
    if (a.lockChipId != null && b.lockChipId != null) {
      final chipA = normA(a.lockChipId!);
      final chipB = normA(b.lockChipId!);
      // Ares and Emperor are allowed to repeat once (2 across deck)
      final isException = chipA.contains('ares') || chipA.contains('emperor');
      if (!isException && chipA == chipB) return true;
    }
    return false;
  }

  Widget _buildConflictLink(String message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.dranzer.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.dranzer.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.link_off, size: 14, color: AppColors.dranzer),
          const SizedBox(width: 6),
          Text(
            message,
            style: AppTypography.mono.copyWith(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppColors.dranzer),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotCard({
    required int slotIndex,
    required Combo? combo,
    required Map<String, Part> bladesMap,
    required bool hasConflict,
    required VoidCallback onTap,
  }) {
    final hasCombo = combo != null;
    final bladePart = hasCombo ? bladesMap[combo.bladeId] : null;

    final accentColor = switch (bladePart?.beyType) {
      BeyType.attack => AppColors.dranzer,
      BeyType.defense => AppColors.dragoon,
      BeyType.stamina => AppColors.pegasus,
      BeyType.balance => AppColors.burst,
      null => AppColors.x,
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: hasConflict
              ? AppColors.dranzer.withValues(alpha: 0.1)
              : (hasCombo ? AppColors.panel2 : AppColors.panel),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: hasConflict
                ? AppColors.dranzer
                : (hasCombo ? AppColors.x.withValues(alpha: 0.4) : AppColors.line),
            width: hasConflict ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: hasConflict ? AppColors.dranzer : AppColors.steel,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'BEY #$slotIndex',
                style: AppTypography.mono.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: hasConflict ? Colors.white : AppColors.x,
                ),
              ),
            ),
            const SizedBox(width: 12),
            if (hasCombo) ...[
              PartImage(
                type: PartType.blade,
                imageRemote: bladePart?.imageRemote,
                imageLocal: bladePart?.imageLocal,
                size: 40,
                color: accentColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      combo.name.toUpperCase(),
                      style: AppTypography.mono.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${combo.bladeId.replaceAll('blade-', '')} · ${combo.ratchetId.replaceAll('ratchet-', '')} · ${combo.bitId.replaceAll('bit-', '')}',
                      style: AppTypography.bodySmall.copyWith(fontSize: 10, color: AppColors.mute),
                    ),
                  ],
                ),
              ),
              if (combo.calculatedWeight != null)
                Text(
                  '${combo.calculatedWeight}g',
                  style: AppTypography.mono.copyWith(fontSize: 11, color: AppColors.x, fontWeight: FontWeight.bold),
                ),
            ] else
              Expanded(
                child: Text(
                  'Toca para seleccionar Bey #$slotIndex...',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.mute),
                ),
              ),
            const SizedBox(width: 8),
            Icon(
              hasCombo ? Icons.check_circle : Icons.add_circle_outline,
              color: hasConflict ? AppColors.dranzer : (hasCombo ? AppColors.x : AppColors.mute),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
