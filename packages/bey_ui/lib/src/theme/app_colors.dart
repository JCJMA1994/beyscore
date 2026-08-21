import 'dart:ui';

/// Design tokens — colors.
///
/// Every color has a fixed job. No color decorates. (CLAUDE.md section 9)
abstract final class AppColors {
  // -- Surfaces --
  static const void_ = Color(0xFF06070C); // background
  static const steel = Color(0xFF0E1220);
  static const panel = Color(0xFF151B29);
  static const panel2 = Color(0xFF1C2434);
  static const line = Color(0xFF28324A);
  static const line2 = Color(0xFF3A4762);

  // -- Text --
  static const text = Color(0xFFEEF1F7);
  static const mute = Color(0xFF78859D);

  // -- Semantic --
  static const dragoon = Color(0xFF2B6BFF); // player A, ALWAYS
  static const dranzer = Color(0xFFFF3B2F); // player B, ALWAYS
  static const pegasus = Color(0xFFFFC400); // Over Finish / not synced
  static const burst = Color(0xFFA855F7); // Burst Finish
  static const x = Color(0xFF00E5D0); // Xtreme Finish / primary action
  static const green = Color(0xFF00FF66); // Success confirmation / online
}
