import 'package:equatable/equatable.dart';

/// Top competitive combo evaluated in official WBO tournaments.
class MetaCombo extends Equatable {
  const MetaCombo({
    required this.rank,
    required this.name,
    required this.blade,
    required this.ratchet,
    required this.bit,
    required this.type,
    required this.tier,
    required this.totalPoints,
    required this.firstPlaces,
    required this.secondPlaces,
    required this.thirdPlaces,
    required this.winrate,
    required this.metaPick,
    required this.description,
    this.bladeImage,
    this.bladeImageLocal,
  });

  factory MetaCombo.fromJson(Map<String, dynamic> json) {
    return MetaCombo(
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      blade: json['blade'] as String? ?? '',
      ratchet: json['ratchet'] as String? ?? '',
      bit: json['bit'] as String? ?? '',
      type: json['type'] as String? ?? 'Attack',
      tier: json['tier'] as String? ?? 'A',
      totalPoints: (json['totalPoints'] as num?)?.toInt() ?? 0,
      firstPlaces: (json['firstPlaces'] as num?)?.toInt() ?? 0,
      secondPlaces: (json['secondPlaces'] as num?)?.toInt() ?? 0,
      thirdPlaces: (json['thirdPlaces'] as num?)?.toInt() ?? 0,
      winrate: (json['winrate'] as num?)?.toInt() ?? 50,
      metaPick: json['metaPick'] as bool? ?? false,
      description: json['description'] as String? ?? '',
      bladeImage: json['bladeImage'] as String?,
      bladeImageLocal: json['bladeImageLocal'] as String?,
    );
  }

  final int rank;
  final String name;
  final String blade;
  final String ratchet;
  final String bit;
  final String type;
  final String tier;
  final int totalPoints;
  final int firstPlaces;
  final int secondPlaces;
  final int thirdPlaces;
  final int winrate;
  final bool metaPick;
  final String description;
  final String? bladeImage;
  final String? bladeImageLocal;

  MetaCombo copyWith({
    String? bladeImage,
    String? bladeImageLocal,
  }) {
    return MetaCombo(
      rank: rank,
      name: name,
      blade: blade,
      ratchet: ratchet,
      bit: bit,
      type: type,
      tier: tier,
      totalPoints: totalPoints,
      firstPlaces: firstPlaces,
      secondPlaces: secondPlaces,
      thirdPlaces: thirdPlaces,
      winrate: winrate,
      metaPick: metaPick,
      description: description,
      bladeImage: bladeImage ?? this.bladeImage,
      bladeImageLocal: bladeImageLocal ?? this.bladeImageLocal,
    );
  }

  @override
  List<Object?> get props => [
        rank,
        name,
        blade,
        ratchet,
        bit,
        type,
        tier,
        totalPoints,
        firstPlaces,
        secondPlaces,
        thirdPlaces,
        winrate,
        metaPick,
        description,
        bladeImage,
        bladeImageLocal,
      ];
}

/// Piece tier ranking with score and trend.
class MetaPieceRanking extends Equatable {
  const MetaPieceRanking({
    required this.name,
    required this.score,
    required this.rank,
    required this.trend,
    required this.tier,
    this.imageRemote,
    this.imageLocal,
  });

  factory MetaPieceRanking.fromJson(Map<String, dynamic> json) {
    return MetaPieceRanking(
      name: json['name'] as String? ?? '',
      score: (json['score'] as num?)?.toInt() ?? 0,
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      trend: json['trend'] as String? ?? 'stable',
      tier: json['tier'] as String? ?? 'A',
      imageRemote: json['imageRemote'] as String?,
      imageLocal: json['imageLocal'] as String?,
    );
  }

  final String name;
  final int score;
  final int rank;
  final String trend;
  final String tier;
  final String? imageRemote;
  final String? imageLocal;

  MetaPieceRanking copyWith({
    String? imageRemote,
    String? imageLocal,
  }) {
    return MetaPieceRanking(
      name: name,
      score: score,
      rank: rank,
      trend: trend,
      tier: tier,
      imageRemote: imageRemote ?? this.imageRemote,
      imageLocal: imageLocal ?? this.imageLocal,
    );
  }

  @override
  List<Object?> get props => [name, score, rank, trend, tier, imageRemote, imageLocal];
}
