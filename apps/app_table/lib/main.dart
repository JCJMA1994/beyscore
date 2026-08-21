import 'dart:async';
import 'package:bey_ui/bey_ui.dart';
import 'package:flutter/material.dart';

import 'bootstrap.dart';
import 'src/presentation/pages/table_shell.dart';

Future<void> main() async {
  await runZonedGuarded(
    () async {
      await bootstrap();
      runApp(const BeyScoreTableApp());
    },
    (error, stack) {
      debugPrint('Uncaught app error: $error\n$stack');
    },
  );
}

class BeyScoreTableApp extends StatelessWidget {
  const BeyScoreTableApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chimbote Stadium',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const TableShell(),
    );
  }
}
