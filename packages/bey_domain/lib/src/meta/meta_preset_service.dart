import '../catalog/part_type.dart';
import '../combo/combo.dart';

/// Pre-configured meta combo template with tactical description.
class MetaPreset {
  const MetaPreset({
    required this.name,
    required this.archetype,
    required this.tier,
    required this.description,
    required this.bladeId,
    required this.ratchetId,
    required this.bitId,
    this.system = BeySystem.bx,
  });

  final String name;
  final String archetype; // 'Ataque', 'Defensa', 'Resistencia', 'Balance'
  final String tier; // 'S', 'A', 'B'
  final String description;
  final String bladeId;
  final String ratchetId;
  final String bitId;
  final BeySystem system;

  Combo toCombo({String? id}) {
    return Combo(
      id: id ?? name.toLowerCase().replaceAll(' ', '_'),
      name: name,
      bladeId: bladeId,
      ratchetId: ratchetId,
      bitId: bitId,
      system: system,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

/// Repository of official WBO and Takara Tomy competitive Meta Presets.
class MetaPresetService {
  const MetaPresetService();

  static const List<MetaPreset> popularPresets = [
    MetaPreset(
      name: 'Wizard Rod 9-60B',
      archetype: 'Resistencia',
      tier: 'S',
      description: 'El rey absoluto de la resistencia. Máxima inercia centrífuga y estabilidad.',
      bladeId: 'wizard_rod',
      ratchetId: '9-60',
      bitId: 'ball',
      system: BeySystem.ux,
    ),
    MetaPreset(
      name: 'Phoenix Wing 5-60P',
      archetype: 'Ataque',
      tier: 'S',
      description: 'Ataque pesado con gran control de centro y letalidad de Over Finish.',
      bladeId: 'phoenix_wing',
      ratchetId: '5-60',
      bitId: 'point',
      system: BeySystem.bx,
    ),
    MetaPreset(
      name: 'Dran Sword 3-60F',
      archetype: 'Ataque',
      tier: 'A',
      description: 'El clásico agresivo del X-Dash. Velocidad vertiginosa en el rail.',
      bladeId: 'dran_sword',
      ratchetId: '3-60',
      bitId: 'flat',
      system: BeySystem.bx,
    ),
    MetaPreset(
      name: 'Shark Edge 1-60LF',
      archetype: 'Ataque',
      tier: 'A',
      description: 'Impacto bajo demoledor diseñado para provocar Burst Finishes instantáneos.',
      bladeId: 'shark_edge',
      ratchetId: '1-60',
      bitId: 'low_flat',
      system: BeySystem.bx,
    ),
    MetaPreset(
      name: 'Hell Scythe 4-60B',
      archetype: 'Balance',
      tier: 'A',
      description: 'Excelente amortiguación contra impactos pesados y contraataque consistente.',
      bladeId: 'hell_scythe',
      ratchetId: '4-60',
      bitId: 'ball',
      system: BeySystem.bx,
    ),
    MetaPreset(
      name: 'Unicorn Sting 3-60T',
      archetype: 'Balance',
      tier: 'A',
      description: 'Equilibrio perfecto entre aceleración de ataque y retención de giro.',
      bladeId: 'unicorn_sting',
      ratchetId: '3-60',
      bitId: 'taper',
      system: BeySystem.bx,
    ),
  ];

  List<MetaPreset> getPresets() => popularPresets;
}
