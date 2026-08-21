// ignore_for_file: depend_on_referenced_packages, document_ignores
import 'dart:async';
import 'package:bey_catalog/bey_catalog.dart';
import 'package:bey_data/bey_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/di/injector.dart';

late final AppDatabase db;

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait for phone one-handed use.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  db = AppDatabase();

  if (Env.hasSupabaseConfig) {
    try {
      await Supabase.initialize(
        url: Env.current.supabaseUrl,
        // ignore: deprecated_member_use
        anonKey: Env.current.supabaseAnonKey,
      );
    } catch (_) {
      // Graceful offline startup fallback
    }
  }

  await configureDependencies(database: db);

  // Seed catalog from bundled JSON
  await CatalogSeeder(db).seedIfNeeded(currentVersion: 0);

  // Start background sync engine
  getIt<SyncEngine>().start();
}
