import 'dart:convert';
import 'package:bey_domain/bey_domain.dart';
import 'package:flutter/services.dart';

/// Service that loads and provides official WBO tournament rankings and top winning combos with official part images.
class MetaRankingsService {
  const MetaRankingsService();

  static const _partsAsset = 'packages/bey_catalog/assets/data/beyblade_x_parts.json';
  static const _partsFallbackAsset = 'assets/data/beyblade_x_parts.json';

  Future<Map<String, String>> _loadPartImageMap() async {
    final map = <String, String>{
      'wizard rod': 'https://img.beybladehub.app/blades-db/WzRd.webp',
      'shark scale': 'https://img.beybladehub.app/blades-db/ShSc.webp',
      'phoenix wing': 'https://img.beybladehub.app/blades-db/PhWg.webp',
      'aero pegasus': 'https://img.beybladehub.app/blades-db/AePg.webp',
      'silver wolf': 'https://img.beybladehub.app/blades-db/SlWf.webp',
      'cobalt dragoon': 'https://img.beybladehub.app/blades-db/CbDg.webp',
      'dran sword': 'https://img.beybladehub.app/blades-db/DrSw.webp',
      'hells scythe': 'https://img.beybladehub.app/blades-db/HlSc.webp',
      'tyranno beat': 'https://img.beybladehub.app/blades-db/TyBt.webp',
      'meteor dragoon': 'https://img.beybladehub.app/blades-db/MtDg.webp',
      'wyvern hover': 'https://img.beybladehub.app/blades-db/WyHv.webp',
      'knight shield': 'https://img.beybladehub.app/blades-db/KnSh.webp',
      'knight lance': 'https://img.beybladehub.app/blades-db/KnLn.webp',
      'unicorn sting': 'https://img.beybladehub.app/blades-db/UnSt.webp',
      'viper tail': 'https://img.beybladehub.app/blades-db/VpTl.webp',
      'rhino horn': 'https://img.beybladehub.app/blades-db/RhHn.webp',
      'dran buster': 'https://img.beybladehub.app/blades-db/DrBs.webp',
      'hells chain': 'https://img.beybladehub.app/blades-db/HlCh.webp',
      'black shell': 'https://img.beybladehub.app/blades-db/BkSh.webp',
      'whale wave': 'https://img.beybladehub.app/blades-db/WhWv.webp',
      'bear scratch': 'https://img.beybladehub.app/blades-db/BrSc.webp',
    };

    try {
      String raw;
      try {
        raw = await rootBundle.loadString(_partsAsset);
      } catch (_) {
        raw = await rootBundle.loadString(_partsFallbackAsset);
      }
      final doc = jsonDecode(raw) as Map<String, dynamic>;
      final parts = doc['parts'] as List<dynamic>? ?? [];
      for (final p in parts) {
        if (p is Map<String, dynamic>) {
          final name = (p['name'] as String? ?? '').toLowerCase().trim();
          final img = p['image'] as String? ?? p['imageRemote'] as String?;
          if (name.isNotEmpty && img != null && img.isNotEmpty) {
            map[name] = img;
            map[name.replaceAll(' ', '')] = img;
            map[name.replaceAll('-', '')] = img;
          }
        }
      }
    } catch (_) {}

    return map;
  }

  Future<({List<MetaPieceRanking> blades, List<MetaPieceRanking> ratchets, List<MetaPieceRanking> bits})>
      loadPieceRankings() async {
    final imageMap = await _loadPartImageMap();

    try {
      String jsonStr;
      try {
        jsonStr = await rootBundle.loadString('packages/bey_catalog/assets/data/beyblade_x_rankings.json');
      } catch (_) {
        jsonStr = await rootBundle.loadString('assets/data/beyblade_x_rankings.json');
      }
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;

      final blades = (data['blades'] as List<dynamic>? ?? []).map((e) {
        final item = MetaPieceRanking.fromJson(e as Map<String, dynamic>);
        final normalized = item.name.toLowerCase().trim();
        final img = imageMap[normalized] ?? imageMap[normalized.replaceAll(' ', '')];
        return item.copyWith(imageRemote: img);
      }).toList();

      final ratchets = (data['ratchets'] as List<dynamic>? ?? []).map((e) {
        final item = MetaPieceRanking.fromJson(e as Map<String, dynamic>);
        final normalized = item.name.toLowerCase().trim();
        final img = imageMap[normalized] ?? imageMap[normalized.replaceAll(' ', '')];
        return item.copyWith(imageRemote: img);
      }).toList();

      final bits = (data['bits'] as List<dynamic>? ?? []).map((e) {
        final item = MetaPieceRanking.fromJson(e as Map<String, dynamic>);
        final normalized = item.name.toLowerCase().trim();
        final img = imageMap[normalized] ?? imageMap[normalized.replaceAll(' ', '')];
        return item.copyWith(imageRemote: img);
      }).toList();

      return (blades: blades, ratchets: ratchets, bits: bits);
    } catch (_) {
      return (
        blades: [
          MetaPieceRanking(name: 'Shark Scale', score: 90, rank: 1, trend: 'stable', tier: 'S+', imageRemote: imageMap['shark scale']),
          MetaPieceRanking(name: 'Wizard Rod', score: 84, rank: 2, trend: 'stable', tier: 'S+', imageRemote: imageMap['wizard rod']),
          MetaPieceRanking(name: 'Aero Pegasus', score: 66, rank: 3, trend: 'stable', tier: 'S', imageRemote: imageMap['aero pegasus']),
          MetaPieceRanking(name: 'Meteor Dragoon', score: 57, rank: 4, trend: 'up', tier: 'S', imageRemote: imageMap['meteor dragoon']),
          MetaPieceRanking(name: 'Wyvern Hover', score: 51, rank: 5, trend: 'stable', tier: 'A+', imageRemote: imageMap['wyvern hover']),
          MetaPieceRanking(name: 'Phoenix Wing', score: 44, rank: 9, trend: 'up', tier: 'A', imageRemote: imageMap['phoenix wing']),
          MetaPieceRanking(name: 'Silver Wolf', score: 44, rank: 10, trend: 'stable', tier: 'A', imageRemote: imageMap['silver wolf']),
        ],
        ratchets: const [
          MetaPieceRanking(name: '1-60', score: 100, rank: 1, trend: 'stable', tier: 'S+'),
          MetaPieceRanking(name: '9-60', score: 75, rank: 2, trend: 'stable', tier: 'S'),
          MetaPieceRanking(name: '3-60', score: 57, rank: 3, trend: 'stable', tier: 'S'),
          MetaPieceRanking(name: '1-70', score: 55, rank: 6, trend: 'stable', tier: 'A'),
          MetaPieceRanking(name: '5-60', score: 41, rank: 11, trend: 'stable', tier: 'B'),
        ],
        bits: const [
          MetaPieceRanking(name: 'Low Rush', score: 76, rank: 1, trend: 'stable', tier: 'S+'),
          MetaPieceRanking(name: 'Hexa', score: 74, rank: 2, trend: 'down', tier: 'S+'),
          MetaPieceRanking(name: 'Rush', score: 66, rank: 3, trend: 'stable', tier: 'S'),
          MetaPieceRanking(name: 'Free Ball', score: 57, rank: 5, trend: 'up', tier: 'A+'),
          MetaPieceRanking(name: 'Point', score: 40, rank: 11, trend: 'stable', tier: 'B'),
        ]
      );
    }
  }

  Future<List<MetaCombo>> loadTopCombos() async {
    final imageMap = await _loadPartImageMap();

    try {
      String jsonStr;
      try {
        jsonStr = await rootBundle.loadString('packages/bey_catalog/assets/data/beyblade_x_combos.json');
      } catch (_) {
        jsonStr = await rootBundle.loadString('assets/data/beyblade_x_combos.json');
      }
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      final list = (data['top_combos'] ?? data['topCombos']) as List<dynamic>? ?? [];
      return list.map((e) {
        final item = MetaCombo.fromJson(e as Map<String, dynamic>);
        final normalizedBlade = item.blade.toLowerCase().trim();
        final img = imageMap[normalizedBlade] ?? imageMap[normalizedBlade.replaceAll(' ', '')];
        return item.copyWith(bladeImage: img);
      }).toList();
    } catch (_) {
      return [
        MetaCombo(
          rank: 1,
          name: 'Hexa Tower',
          blade: 'Wizard Rod',
          ratchet: '1-60',
          bit: 'Hexa',
          type: 'Stamina',
          tier: 'S+',
          totalPoints: 18410,
          firstPlaces: 28,
          secondPlaces: 20,
          thirdPlaces: 18,
          winrate: 73,
          metaPick: true,
          description:
              'El combo más dominante del meta. Wizard Rod con ratchet mínimo 1-60 y Hexa garantiza estabilidad orbital y resistencia extrema a Burst.',
          bladeImage: imageMap['wizard rod'],
        ),
        MetaCombo(
          rank: 2,
          name: 'Scale Rush High',
          blade: 'Shark Scale',
          ratchet: '1-70',
          bit: 'Low Rush',
          type: 'Attack',
          tier: 'S',
          totalPoints: 8704,
          firstPlaces: 12,
          secondPlaces: 10,
          thirdPlaces: 8,
          winrate: 71,
          metaPick: true,
          description:
              'Shark Scale ultra agresivo en ratchet alto 1-70 con Low Rush para ataque de órbita y KOs demoledores.',
          bladeImage: imageMap['shark scale'],
        ),
        MetaCombo(
          rank: 3,
          name: 'Wolf Orbit',
          blade: 'Silver Wolf',
          ratchet: '9-60',
          bit: 'Free Ball',
          type: 'Balance',
          tier: 'S',
          totalPoints: 7920,
          firstPlaces: 11,
          secondPlaces: 9,
          thirdPlaces: 7,
          winrate: 69,
          metaPick: true,
          description:
              'Gran estabilidad de giro libre con Free Ball y peso centralizado 9-60.',
          bladeImage: imageMap['silver wolf'],
        ),
      ];
    }
  }
}
