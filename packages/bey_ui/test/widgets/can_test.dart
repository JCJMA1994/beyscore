import 'package:bey_domain/bey_domain.dart';
import 'package:bey_ui/bey_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Can widget tests', () {
    testWidgets('renders child when permission allowed', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Can(
              capability: Capability.viewCatalogAndDecks,
              role: DeviceRole.phone,
              child: Text('Allowed Content'),
            ),
          ),
        ),
      );

      expect(find.text('Allowed Content'), findsOneWidget);
    });

    testWidgets('hides child when permission denied in default hide mode', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Can(
              capability: Capability.editTournament,
              role: DeviceRole.table, // Table role cannot edit tournament
              child: Text('Hidden Content'),
            ),
          ),
        ),
      );

      expect(find.text('Hidden Content'), findsNothing);
    });

    testWidgets('renders fallback when permission denied', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Can(
              capability: Capability.editTournament,
              role: DeviceRole.table,
              fallback: Text('Access Denied'),
              child: Text('Admin Panel'),
            ),
          ),
        ),
      );

      expect(find.text('Admin Panel'), findsNothing);
      expect(find.text('Access Denied'), findsOneWidget);
    });

    testWidgets('dims child when using Can.dim constructor', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Can.dim(
              capability: Capability.editTournament,
              role: DeviceRole.table,
              child: Text('Dimmed Button'),
            ),
          ),
        ),
      );

      expect(find.text('Dimmed Button'), findsOneWidget);
      final opacityWidget = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacityWidget.opacity, 0.38);
    });
  });
}
