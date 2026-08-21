import 'bracket.dart';

/// Tournament entity.
///
/// Admin is a permission on the tournament, not a user type (decision #5).
/// Tournament.organizerIds decides who can manage, not User.role.
///
/// Tiers: G3 local -> G2 regional -> G1 national -> GP world -> UNOFFICIAL
/// Age divisions: OPEN (6+) and REGULAR (6-12).
enum TournamentTier {
  g3('G3 LOCAL', '8-16 Bladers', 0xFF00FF66),
  g2('G2 REGIONAL', '32 Bladers', 0xFF00E5FF),
  g1('G1 NACIONAL', '64 Bladers', 0xFFFFCC00),
  gp('GRAND PRIX GP', '128 Bladers', 0xFFFF3366),
  unofficial('AMISTOSO', 'Libre', 0xFF9E9E9E);

  const TournamentTier(this.label, this.capacityNote, this.colorValue);
  final String label;
  final String capacityNote;
  final int colorValue;
}

enum AgeDivision {
  open('OPEN (6+)'),
  regular('REGULAR (6-12)');

  const AgeDivision(this.label);
  final String label;
}

enum TournamentStatus {
  draft('Borrador'),
  registration('Registro'),
  checkIn('Check-in'),
  inProgress('En Progreso'),
  completed('Finalizado');

  const TournamentStatus(this.label);
  final String label;
}

enum TournamentFormat {
  singleElimination('Eliminación Directa'),
  swiss('Sistema Suizo');

  const TournamentFormat(this.label);
  final String label;
}

class Tournament {
  const Tournament({
    required this.id,
    required this.name,
    required this.organizerIds,
    required this.tier,
    required this.ageDivision,
    required this.status,
    this.format = TournamentFormat.singleElimination,
    this.participants = const [],
    this.rounds = const [],
    this.championName,
    this.seed,
    this.createdAt,
  });

  final String id;
  final String name;

  /// Who can manage this tournament. Guard by resource, not by global role.
  final List<String> organizerIds;

  final TournamentTier tier;
  final AgeDivision ageDivision;
  final TournamentStatus status;
  final TournamentFormat format;

  /// Registered participants (Blader names)
  final List<String> participants;

  /// Elimination Bracket rounds
  final List<BracketRound> rounds;

  /// Winner / Champion of the tournament
  final String? championName;

  /// Saved seed for deterministic bracket regeneration.
  final int? seed;

  final DateTime? createdAt;

  Tournament copyWith({
    String? id,
    String? name,
    List<String>? organizerIds,
    TournamentTier? tier,
    AgeDivision? ageDivision,
    TournamentStatus? status,
    TournamentFormat? format,
    List<String>? participants,
    List<BracketRound>? rounds,
    String? championName,
    int? seed,
    DateTime? createdAt,
  }) {
    return Tournament(
      id: id ?? this.id,
      name: name ?? this.name,
      organizerIds: organizerIds ?? this.organizerIds,
      tier: tier ?? this.tier,
      ageDivision: ageDivision ?? this.ageDivision,
      status: status ?? this.status,
      format: format ?? this.format,
      participants: participants ?? this.participants,
      rounds: rounds ?? this.rounds,
      championName: championName ?? this.championName,
      seed: seed ?? this.seed,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
