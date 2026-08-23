import '../catalog/part_type.dart';
import '../combo/combo.dart';
import '../id/uuid_v7_generator.dart';

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
      id: id ?? UuidV7Generator.v7(),
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
      name: 'Wizard Rod 1-60H',
      archetype: 'Resistencia',
      tier: 'S+',
      description: 'El rey supremo del meta WBO. Estabilidad orbital insuperable con 1-60 y Hexa.',
      bladeId: 'wizard_rod',
      ratchetId: '1-60',
      bitId: 'hexa',
      system: BeySystem.ux,
    ),
    MetaPreset(
      name: 'Shark Scale 1-70LR',
      archetype: 'Ataque',
      tier: 'S+',
      description: 'Ataque de contacto alto anti-Wizard Rod. Letalidad extrema en órbita rápida.',
      bladeId: 'shark_scale',
      ratchetId: '1-70',
      bitId: 'low_rush',
      system: BeySystem.ux,
    ),
    MetaPreset(
      name: 'Silver Wolf 9-60FB',
      archetype: 'Balance',
      tier: 'S',
      description: 'Absorción de impacto y contraataque con giro libre amortiguado.',
      bladeId: 'silver_wolf',
      ratchetId: '9-60',
      bitId: 'free_ball',
      system: BeySystem.ux,
    ),
    MetaPreset(
      name: 'Shark Scale 4-50K',
      archetype: 'Ataque',
      tier: 'S',
      description: 'Aceleración baja y rebote activo para knockouts ascendentes constantes.',
      bladeId: 'shark_scale',
      ratchetId: '4-50',
      bitId: 'kick',
      system: BeySystem.ux,
    ),
    MetaPreset(
      name: 'Aero Pegasus 3-60R',
      archetype: 'Ataque',
      tier: 'S',
      description: 'Aerodinámica de 3 alas para ráfagas continuas de alta velocidad en el riel.',
      bladeId: 'aero_pegasus',
      ratchetId: '3-60',
      bitId: 'rush',
      system: BeySystem.ux,
    ),
    MetaPreset(
      name: 'Cobalt Dragoon 1-60L',
      archetype: 'Ataque',
      tier: 'A+',
      description: 'Giro izquierdo que desestabiliza oponentes con impacto invertido constante.',
      bladeId: 'cobalt_dragoon',
      ratchetId: '1-60',
      bitId: 'level',
      system: BeySystem.bx,
    ),
    MetaPreset(
      name: 'Phoenix Wing 5-60P',
      archetype: 'Ataque',
      tier: 'A+',
      description: 'Ataque pesado con gran control de centro y letalidad de Over Finish.',
      bladeId: 'phoenix_wing',
      ratchetId: '5-60',
      bitId: 'point',
      system: BeySystem.bx,
    ),
    MetaPreset(
      name: 'Dran Strike 1-60LR',
      archetype: 'Ataque',
      tier: 'A',
      description: 'Impacto frontal masivo temprano en el riel Xtreme.',
      bladeId: 'dran_strike',
      ratchetId: '1-60',
      bitId: 'low_rush',
      system: BeySystem.bx,
    ),
  ];

  List<MetaPreset> getPresets() => popularPresets;
}
