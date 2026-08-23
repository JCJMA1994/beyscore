import 'dart:typed_data';
import 'package:bey_tournament/bey_tournament.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DiplomaPdfService Tests', () {
    const service = DiplomaPdfService();

    test('generates valid PDF bytes in horizontal landscape format for 1st place champion', () async {
      final bytes = await service.generateDiplomaPdf(
        tournamentName: 'Gran Torneo Beyblade X Lima',
        tierLabel: 'G1',
        divisionLabel: 'Senior',
        bladerName: 'Kamen X',
        placeTitle: '1ER LUGAR (CAMPEÓN)',
        placeRank: 1,
        deckInfo: 'Dran Sword 3-60F · Hells Scythe 4-60B · Wizard Arrow 4-80B',
        totalParticipants: 16,
        location: 'Centro de Convenciones',
        organizerName: 'Juez Principal WBBA',
      );

      expect(bytes, isA<Uint8List>());
      expect(bytes.isNotEmpty, isTrue);
      // PDF header magic bytes '%PDF-'
      expect(bytes.sublist(0, 5), equals([0x25, 0x50, 0x44, 0x46, 0x2D]));
    });

    test('generates valid PDF bytes for 2nd and 3rd places with custom optional data', () async {
      final runnerUpBytes = await service.generateDiplomaPdf(
        tournamentName: 'Torneo Relámpago LAN',
        tierLabel: 'G3',
        divisionLabel: 'Open',
        bladerName: 'Bird Kazami',
        placeTitle: '2DO LUGAR (SUBCAMPEÓN)',
        placeRank: 2,
      );

      expect(runnerUpBytes.isNotEmpty, isTrue);
      expect(runnerUpBytes.sublist(0, 5), equals([0x25, 0x50, 0x44, 0x46, 0x2D]));

      final thirdPlaceBytes = await service.generateDiplomaPdf(
        tournamentName: 'Torneo Relámpago LAN',
        tierLabel: 'G3',
        divisionLabel: 'Open',
        bladerName: 'Multi Nanairo',
        placeTitle: '3ER LUGAR (BRONCE)',
        placeRank: 3,
      );

      expect(thirdPlaceBytes.isNotEmpty, isTrue);
      expect(thirdPlaceBytes.sublist(0, 5), equals([0x25, 0x50, 0x44, 0x46, 0x2D]));
    });

    test('generates valid PDF bytes for official rules sheet v12', () async {
      const rulesService = RulesSheetPdfService();
      final bytes = await rulesService.generateOfficialRulesSheetPdf();

      expect(bytes, isA<Uint8List>());
      expect(bytes.isNotEmpty, isTrue);
      expect(bytes.sublist(0, 5), equals([0x25, 0x50, 0x44, 0x46, 0x2D]));
    });

    test('generates valid PDF bytes for 3on3 Champion Card format (style BeybladeHub)', () async {
      final bytes = await service.generateChampionCardPdf(
        tournamentName: 'Chimbote League X 2026',
        tierLabel: 'G2',
        divisionLabel: 'Open',
        bladerName: 'Kamen X',
        placeRank: 1,
        deckCombos: [
          {'blade': 'Wizard Rod', 'ratchet': '9-60', 'bit': 'Ball', 'type': 'Resistencia', 'weight': '38.5'},
          {'blade': 'Phoenix Wing', 'ratchet': '5-60', 'bit': 'Point', 'type': 'Ataque', 'weight': '39.0'},
          {'blade': 'Shark Scale', 'ratchet': '3-60', 'bit': 'Flat', 'type': 'Ataque', 'weight': '37.8'},
        ],
        storeOrVenue: 'Coliseo BeyScore',
      );

      expect(bytes, isA<Uint8List>());
      expect(bytes.isNotEmpty, isTrue);
      expect(bytes.sublist(0, 5), equals([0x25, 0x50, 0x44, 0x46, 0x2D]));
    });

    test('generates valid PDF bytes for Official Podium & Standings Report', () async {
      final bytes = await service.generatePodiumReportPdf(
        tournamentName: 'Torneo Oficial BeyScore Chimbote',
        tierLabel: 'G1',
        divisionLabel: 'Open',
        championName: 'Tyson Granger',
        runnerUpName: 'Kai Hiwatari',
        thirdPlaceName: 'Ray Kon',
        championDeck: [
          {'blade': 'Wizard Rod', 'ratchet': '1-60', 'bit': 'Hexa', 'type': 'Stamina'},
          {'blade': 'Shark Scale', 'ratchet': '1-70', 'bit': 'Low Rush', 'type': 'Attack'},
          {'blade': 'Silver Wolf', 'ratchet': '9-60', 'bit': 'Free Ball', 'type': 'Balance'},
        ],
        totalParticipants: 16,
        totalMatches: 15,
        totalPoints: 48,
        organizerName: 'Organizador Oficial',
      );

      expect(bytes, isA<Uint8List>());
      expect(bytes.isNotEmpty, isTrue);
      expect(bytes.sublist(0, 5), equals([0x25, 0x50, 0x44, 0x46, 0x2D]));
    });
  });
}
