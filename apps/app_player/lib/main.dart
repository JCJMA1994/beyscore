import 'dart:async';
import 'package:bey_ui/bey_ui.dart';
import 'package:flutter/material.dart';

import 'bootstrap.dart';
import 'config/router/app_router.dart';

Future<void> main() async {
  await runZonedGuarded(
    () async {
      await bootstrap();
      runApp(const BeyScorePlayerApp());
    },
    (error, stack) {
      debugPrint('Uncaught app error: $error\n$stack');
    },
  );
}

class BeyScorePlayerApp extends StatelessWidget {
  const BeyScorePlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Chimbote Blader',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: appRouter,
    );
  }
}
