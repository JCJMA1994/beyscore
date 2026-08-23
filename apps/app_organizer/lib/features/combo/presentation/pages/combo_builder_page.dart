import 'package:bey_domain/bey_domain.dart';
import 'package:bey_ui/bey_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';

class ComboBuilderPage extends StatefulWidget {
  const ComboBuilderPage({super.key});

  @override
  State<ComboBuilderPage> createState() => _ComboBuilderPageState();
}

class _ComboBuilderPageState extends State<ComboBuilderPage> {
  final _catalogRepo = getIt<CatalogRepository>();
  final _comboRepo = getIt<ComboRepository>();
  final _metaAdvisor = getIt<MetaAdvisorService>();

  BeySystem _selectedSystem = BeySystem.bx;
  Part? _selectedBlade;
  Part? _selectedRatchet;
  Part? _selectedBit;
  Part? _selectedLockChip;
  Part? _selectedAssistBlade;
  Part? _selectedOverBlade;

  final _nameController = TextEditingController();
  bool _isSaving = false;
  bool _userEditedName = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  double? get _totalWeight {
    final b = _selectedBlade?.weightG ?? 32.0;
    final r = _selectedRatchet?.weightG ?? 6.5;
    final bit = _selectedBit?.weightG ?? 2.3;
    final lock = _selectedLockChip?.weightG ?? (_selectedLockChip != null ? 1.8 : 0.0);
    final assist = _selectedAssistBlade?.weightG ?? (_selectedAssistBlade != null ? 4.8 : 0.0);
    final over = _selectedOverBlade?.weightG ?? (_selectedOverBlade != null ? 3.5 : 0.0);

    if (_selectedBlade == null || _selectedRatchet == null || _selectedBit == null) return null;
    return double.parse((b + r + bit + lock + assist + over).toStringAsFixed(1));
  }

  void _updateAutoName() {
    if (_userEditedName) return;

    final bladeName = _selectedBlade?.name ?? '';
    final ratchetName = _selectedRatchet?.name ?? '';
    final bitName = _selectedBit?.code ?? _selectedBit?.name ?? '';
    final assistName = _selectedAssistBlade != null ? ' (${_selectedAssistBlade!.name})' : '';

    if (bladeName.isNotEmpty || ratchetName.isNotEmpty || bitName.isNotEmpty) {
      final parts = [bladeName, ratchetName, bitName].where((s) => s.isNotEmpty).join(' ');
      _nameController.text = '$parts$assistName';
    }
  }

  void _openPartPicker(PartType type, String title) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.void_,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        side: BorderSide(color: AppColors.line),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) {
          return StreamBuilder<List<Part>>(
            stream: _catalogRepo.watchByType(type),
            builder: (context, snapshot) {
              final allParts = snapshot.data ?? [];
              final filteredParts = allParts.where((p) {
                if (type == PartType.blade) {
                  return p.system == _selectedSystem;
                }
                return true;
              }).toList();

              return Column(
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
                          'ELEGIR $title (${filteredParts.length} PIEZAS)',
                          style: AppTypography.mono.copyWith(
                            fontSize: 13,
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
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Expanded(
                      child: Center(child: CircularProgressIndicator(color: AppColors.x)),
                    )
                  else if (filteredParts.isEmpty)
                    Expanded(
                      child: Center(
                        child: Text(
                          'No hay piezas disponibles en esta categoría.',
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.mute),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.all(12),
                        itemCount: filteredParts.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final part = filteredParts[index];
                          final typeColor = switch (part.beyType) {
                            BeyType.attack => AppColors.dranzer,
                            BeyType.defense => AppColors.dragoon,
                            BeyType.stamina => AppColors.pegasus,
                            BeyType.balance => AppColors.burst,
                            null => AppColors.x,
                          };

                          return InkWell(
                            onTap: () {
                              setState(() {
                                if (type == PartType.blade) {
                                  _selectedBlade = part;
                                } else if (type == PartType.ratchet) {
                                  _selectedRatchet = part;
                                } else if (type == PartType.bit) {
                                  _selectedBit = part;
                                } else if (type == PartType.lockChip) {
                                  _selectedLockChip = part;
                                } else if (type == PartType.assistBlade) {
                                  _selectedAssistBlade = part;
                                } else if (type == PartType.overBlade) {
                                  _selectedOverBlade = part;
                                }
                                _updateAutoName();
                              });
                              Navigator.pop(ctx);
                            },
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.panel,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.line),
                              ),
                              child: Row(
                                children: [
                                  PartImage(
                                    type: part.type,
                                    imageRemote: part.imageRemote,
                                    imageLocal: part.imageLocal,
                                    size: 40,
                                    color: typeColor,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          part.name,
                                          style: AppTypography.mono.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          '${part.system.name.toUpperCase()} ${part.code != null ? '· [${part.code}]' : ''} ${part.metaTier != null ? '· Tier ${part.metaTier}' : ''}',
                                          style: AppTypography.bodySmall.copyWith(
                                            color: AppColors.mute,
                                            fontSize: 10.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (part.weightG != null)
                                    Text(
                                      '${part.weightG}g',
                                      style: AppTypography.mono.copyWith(
                                        fontSize: 11,
                                        color: AppColors.x,
                                        fontWeight: FontWeight.bold,
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
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _applyMetaAdvice(MetaAdvice advice) async {
    final allRatchets = await _catalogRepo.watchByType(PartType.ratchet).first;
    final allBits = await _catalogRepo.watchByType(PartType.bit).first;

    if (advice.recommendedRatchets.isNotEmpty) {
      final recR = advice.recommendedRatchets.first.partCode.toLowerCase();
      final matchedR = allRatchets.firstWhere(
        (r) => (r.code ?? r.name).toLowerCase() == recR || r.name.toLowerCase().contains(recR),
        orElse: () => allRatchets.first,
      );
      _selectedRatchet = matchedR;
    }

    if (advice.recommendedBits.isNotEmpty) {
      final recB = advice.recommendedBits.first.partCode.toLowerCase();
      final matchedB = allBits.firstWhere(
        (b) => (b.code ?? b.name).toLowerCase() == recB || b.name.toLowerCase().contains(recB),
        orElse: () => allBits.first,
      );
      _selectedBit = matchedB;
    }

    setState(_updateAutoName);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.steel,
          content: Text(
            '¡Combo Meta WBO aplicado: ${_selectedBlade?.name} ${_selectedRatchet?.name} ${_selectedBit?.name}!',
            style: AppTypography.mono.copyWith(fontSize: 11, color: AppColors.x),
          ),
        ),
      );
    }
  }

  Future<void> _saveCombo() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      await BeyFeedbackDialog.showError(
        context,
        title: 'Nombre de Combo Requerido',
        message: 'Debes asignarle un nombre a tu Beyblade armado.',
        solution: 'Ingresa un nombre en el campo superior (ej. "DranSword 3-60F").',
      );
      return;
    }

    if (_selectedBlade == null || _selectedRatchet == null || _selectedBit == null) {
      final missing = <String>[
        if (_selectedBlade == null) 'Blade',
        if (_selectedRatchet == null) 'Ratchet',
        if (_selectedBit == null) 'Bit',
      ];
      await BeyFeedbackDialog.showError(
        context,
        title: 'Piezas Incompletas',
        message: 'Un Beyblade X funcional requiere Blade, Ratchet y Bit ensamblados.\nFalta seleccionar: ${missing.join(', ')}.',
        solution: 'Toca las ranuras vacías para elegir piezas de tu catálogo.',
      );
      return;
    }

    setState(() => _isSaving = true);

    final combo = Combo(
      id: 'combo-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      bladeId: _selectedBlade!.id,
      ratchetId: _selectedRatchet!.id,
      bitId: _selectedBit!.id,
      lockChipId: _selectedLockChip?.id,
      assistBladeId: _selectedAssistBlade?.id,
      overBladeId: _selectedOverBlade?.id,
      system: _selectedBlade!.system,
      calculatedWeight: _totalWeight,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _comboRepo.save(combo);

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCx = _selectedSystem == BeySystem.cx;
    final isComplete = _selectedBlade != null && _selectedRatchet != null && _selectedBit != null;
    final metaAdvice = _selectedBlade != null ? _metaAdvisor.adviseForBlade(_selectedBlade!) : null;

    return Scaffold(
      backgroundColor: AppColors.void_,
      appBar: AppBar(
        backgroundColor: AppColors.steel,
        title: Text(
          'ARMADOR DE BEY / COMBO',
          style: AppTypography.mono.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // System Selector Tabs (BX, UX, CX)
            Row(
              children: BeySystem.values.map((sys) {
                final isSelected = _selectedSystem == sys;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedSystem = sys;
                          _selectedBlade = null;
                          _selectedLockChip = null;
                          _selectedAssistBlade = null;
                          _selectedOverBlade = null;
                          _updateAutoName();
                        });
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.x.withValues(alpha: 0.15) : AppColors.panel,
                          border: Border.all(color: isSelected ? AppColors.x : AppColors.line),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              sys.name.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: AppTypography.mono.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? AppColors.x : AppColors.mute,
                              ),
                            ),
                            if (sys == BeySystem.cx) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.dranzer.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Text(
                                  'MODULAR',
                                  style: AppTypography.mono.copyWith(fontSize: 8, color: AppColors.dranzer, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // CX Modular Parts Picker (Lock Chip, Over Blade, Assist Blade)
            if (isCx) ...[
              Container(
                padding: const EdgeInsets.all(12),
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
                        const Icon(Icons.extension, size: 16, color: AppColors.x),
                        const SizedBox(width: 8),
                        Text(
                          'MÓDULOS DEL SISTEMA CX (CROSS X)',
                          style: AppTypography.mono.copyWith(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.x),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildSlotCard(
                      type: PartType.lockChip,
                      part: _selectedLockChip,
                      label: 'LOCK CHIP (EMBLEMA)',
                      onTap: () => _openPartPicker(PartType.lockChip, 'LOCK CHIP'),
                    ),
                    const SizedBox(height: 8),
                    _buildSlotCard(
                      type: PartType.assistBlade,
                      part: _selectedAssistBlade,
                      label: 'ASSIST BLADE (J, B, T, W, H...)',
                      onTap: () => _openPartPicker(PartType.assistBlade, 'ASSIST BLADE'),
                    ),
                    const SizedBox(height: 8),
                    _buildSlotCard(
                      type: PartType.overBlade,
                      part: _selectedOverBlade,
                      label: 'OVER BLADE (MODO PEAK / BREAK / GUARD)',
                      onTap: () => _openPartPicker(PartType.overBlade, 'OVER BLADE'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Core Stacking Slots (Blade -> Ratchet -> Bit)
            _buildSlotCard(
              type: PartType.blade,
              part: _selectedBlade,
              label: isCx ? 'MAIN BLADE (CUERPO CENTRAL)' : 'BLADE',
              onTap: () => _openPartPicker(PartType.blade, isCx ? 'MAIN BLADE' : 'BLADE'),
            ),
            const SizedBox(height: 8),

            // Meta Advisor Intelligence Card
            if (metaAdvice != null) ...[
              _buildMetaAdvisorCard(metaAdvice),
              const SizedBox(height: 10),
            ],

            _buildSlotCard(
              type: PartType.ratchet,
              part: _selectedRatchet,
              label: 'RATCHET',
              onTap: () => _openPartPicker(PartType.ratchet, 'RATCHET'),
            ),
            const SizedBox(height: 8),
            _buildSlotCard(
              type: PartType.bit,
              part: _selectedBit,
              label: 'BIT',
              onTap: () => _openPartPicker(PartType.bit, 'BIT'),
            ),
            const SizedBox(height: 18),

            // Rich Live Combo Preview Card
            if (isComplete)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ComboPreviewCard(
                  blade: _selectedBlade!,
                  ratchet: _selectedRatchet!,
                  bit: _selectedBit!,
                  lockChip: _selectedLockChip,
                  assistBlade: _selectedAssistBlade,
                  overBlade: _selectedOverBlade,
                ),
              ),

            // Name & Code Editor Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.panel,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: isComplete ? AppColors.x : AppColors.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NOMBRE DEL BEYBLADE ARMADO',
                    style: AppTypography.mono.copyWith(fontSize: 10, color: AppColors.mute, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _nameController,
                    onChanged: (_) => _userEditedName = true,
                    style: AppTypography.displaySmall.copyWith(fontSize: 16, color: AppColors.text),
                    decoration: const InputDecoration(
                      hintText: 'Ej: DranSword 3-60F',
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            ChamferButton(
              text: _isSaving ? 'GUARDANDO...' : (isComplete ? 'GUARDAR BEY EN ARSENAL' : 'COMPLETA LAS PIEZAS'),
              variant: isComplete ? ChamferButtonVariant.go : ChamferButtonVariant.ghost,
              onPressed: isComplete && !_isSaving ? _saveCombo : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaAdvisorCard(MetaAdvice advice) {
    final typeColor = switch (advice.archetype) {
      BeyType.attack => AppColors.dranzer,
      BeyType.defense => AppColors.dragoon,
      BeyType.stamina => AppColors.pegasus,
      BeyType.balance => AppColors.burst,
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.panel2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.x.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.lightbulb_outline, size: 16, color: AppColors.x),
                  const SizedBox(width: 6),
                  Text(
                    'ASESOR DEL META WBO',
                    style: AppTypography.mono.copyWith(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.x),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${advice.estimatedTier} · ${advice.estimatedWinrate}% WIN',
                  style: AppTypography.mono.copyWith(fontSize: 9.5, fontWeight: FontWeight.bold, color: typeColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            advice.tacticalOverview,
            style: AppTypography.bodySmall.copyWith(fontSize: 10.5, color: AppColors.text),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              ...advice.recommendedRatchets.take(2).map((r) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.steel, borderRadius: BorderRadius.circular(4)),
                    child: Text(
                      'Ratchet: ${r.partName}',
                      style: AppTypography.mono.copyWith(fontSize: 9, color: AppColors.x),
                    ),
                  )),
              ...advice.recommendedBits.take(2).map((b) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.steel, borderRadius: BorderRadius.circular(4)),
                    child: Text(
                      'Bit: ${b.partName}',
                      style: AppTypography.mono.copyWith(fontSize: 9, color: AppColors.x),
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () => _applyMetaAdvice(advice),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.x.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.x),
                ),
                child: Text(
                  'APLICAR SUGERENCIA META',
                  style: AppTypography.mono.copyWith(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.x),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotCard({
    required PartType type,
    required Part? part,
    required String label,
    required VoidCallback onTap,
  }) {
    final hasPart = part != null;

    final typeColor = switch (part?.beyType) {
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
          color: hasPart ? AppColors.panel2 : AppColors.panel,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: hasPart ? AppColors.x.withValues(alpha: 0.5) : AppColors.line,
          ),
        ),
        child: Row(
          children: [
            PartImage(
              type: type,
              imageRemote: part?.imageRemote,
              imageLocal: part?.imageLocal,
              size: 44,
              color: typeColor,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.mono.copyWith(fontSize: 9, color: AppColors.mute, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasPart ? part.name : 'Seleccionar $label...',
                    style: AppTypography.mono.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: hasPart ? AppColors.text : AppColors.mute,
                    ),
                  ),
                  if (hasPart && part.weightG != null)
                    Text(
                      '${part.weightG}g · ${part.beyType?.name ?? 'Parte'}',
                      style: AppTypography.bodySmall.copyWith(fontSize: 10, color: AppColors.mute),
                    ),
                ],
              ),
            ),
            Icon(
              hasPart ? Icons.check_circle : Icons.add_circle_outline,
              color: hasPart ? AppColors.x : AppColors.mute,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
