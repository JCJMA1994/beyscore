import 'dart:math' as math;
import 'package:flutter/painting.dart';

/// Typography tokens.
///
/// - Display: Archivo Black with skewX(-8 deg)
/// - Body: Inter Tight
/// - Data/codes: JetBrains Mono
/// - Japanese names: Noto Sans JP
abstract final class AppTypography {
  // -- Font families --
  static const displayFamily = 'ArchivoBlack';
  static const bodyFamily = 'InterTight';
  static const monoFamily = 'JetBrainsMono';
  static const jpFamily = 'NotoSansJP';

  // -- Skew for display text (italic-like aggressive lean) --
  static const double displaySkew = -8.0 * (math.pi / 180);

  // -- Preset styles --
  static const displayLarge = TextStyle(
    fontFamily: displayFamily,
    fontSize: 40,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.5,
  );

  static const displayMedium = TextStyle(
    fontFamily: displayFamily,
    fontSize: 28,
    fontWeight: FontWeight.w900,
  );

  static const displaySmall = TextStyle(
    fontFamily: displayFamily,
    fontSize: 20,
    fontWeight: FontWeight.w900,
  );

  static const bodyLarge = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static const bodyMedium = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const bodySmall = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static const mono = TextStyle(
    fontFamily: monoFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );

  static const japanese = TextStyle(
    fontFamily: jpFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );
}
