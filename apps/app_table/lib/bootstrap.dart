import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Stadium Tablet: Lock to landscape
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Stadium Tablet: Hide Android/iOS system bars for fullscreen gaming
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Stadium Tablet: Keep screen awake indefinitely mounted on stadium
  try {
    await WakelockPlus.enable();
  } catch (_) {
    // Non-mobile fallback (desktop / web testing)
  }
}
