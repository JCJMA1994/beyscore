import 'package:bey_domain/bey_domain.dart';
import 'package:bey_ui/bey_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const blade = Part(
    id: 'shark_scale',
    name: 'Shark Scale',
    type: PartType.blade,
    system: BeySystem.bx,
    productCode: 'BX-34',
    attack: 82,
    defense: 42,
    stamina: 54,
    weightG: 34.3,
    metaTier: 'S+',
  );

  const ratchet = Part(
    id: '9-60',
    name: '9-60',
    code: '9-60',
    type: PartType.ratchet,
    system: BeySystem.bx,
    attack: 12,
    defense: 11,
    stamina: 10,
    weightG: 6.4,
    metaTier: 'S',
  );

  const bit = Part(
    id: 'elevate',
    name: 'Elevate',
    code: 'E',
    type: PartType.bit,
    system: BeySystem.bx,
    attack: 20,
    defense: 10,
    stamina: 15,
    weightG: 3.3,
    metaTier: 'A',
  );

  testWidgets('ComboPreviewCard renders full stats, synergy and tier badge', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ComboPreviewCard(
            blade: blade,
            ratchet: ratchet,
            bit: bit,
          ),
        ),
      ),
    );

    expect(find.text('ANTEPRIMA COMBO'), findsOneWidget);
    expect(find.text('SHARK SCALE'), findsOneWidget);
    expect(find.text('BX-34 · 9-60 · E'), findsOneWidget);
    expect(find.text('114'), findsOneWidget); // ATK
    expect(find.text('63'), findsOneWidget); // DEF
    expect(find.text('79'), findsOneWidget); // STA
    expect(find.text('44.0g'), findsOneWidget); // WGT
    expect(find.text('256'), findsOneWidget); // Total Stats
    expect(find.text('TOTAL STATS'), findsOneWidget);
    expect(find.text('SINERGIA'), findsOneWidget);
  });

  testWidgets('ChampionCardWidget renders in 4:5 with 3on3 deck entries', (tester) async {
    const deckEntries = [
      ChampionDeckEntry(
        blade: blade,
        ratchet: ratchet,
        bit: bit,
        archetype: 'Ataque',
      ),
    ];

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ChampionCardWidget(
            tournamentName: 'Gran Copa Beyblade X',
            tierLabel: 'G1',
            bladerName: 'Kamen X',
            placeRank: 1,
            deckEntries: deckEntries,
          ),
        ),
      ),
    );

    expect(find.text('TIER G1'), findsOneWidget);
    expect(find.text('KAMEN X'), findsOneWidget);
    expect(find.text('GRAN COPA BEYBLADE X'), findsOneWidget);
    expect(find.text('DECK 3ON3 VENCEDOR'), findsOneWidget);
    expect(find.text('SHARK SCALE'), findsOneWidget);
    expect(find.text('VERIFIED DECK'), findsOneWidget);
  });
}
