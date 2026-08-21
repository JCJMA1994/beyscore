import 'package:app_table/src/presentation/pages/table_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('TableShell renders table view', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TableShell(
          tableNumber: 1,
          playerAName: 'TYSON',
          playerBName: 'KAI',
        ),
      ),
    );

    expect(find.text('MESA 1'), findsOneWidget);
  });
}
