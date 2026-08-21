/// Finish types in Beyblade X combat.
///
/// Pure Dart. Points are DERIVED from finishes, never stored directly.
/// PENALTY is NOT a finish — it's a foul accumulation (CLAUDE.md section 4).
enum FinishType {
  /// 3 points. Rival falls whole into the Xtreme zone.
  xtreme,

  /// 2 points. Rival is expelled from the stadium.
  over,

  /// 2 points. Rival's parts separate.
  burst,

  /// 1 point. Rival stops spinning first inside the combat zone.
  spin,

  /// 1 point. NOT a real finish. 2 launch faults by the rival in the same round.
  /// Shown with diagonal hatching. Separate in stats: high penalty rate
  /// means the player needs to practice their launch, not that they play well.
  penalty;

  /// Official point value for this finish type (rules v12).
  int get points => switch (this) {
        FinishType.xtreme => 3,
        FinishType.over => 2,
        FinishType.burst => 2,
        FinishType.spin => 1,
        FinishType.penalty => 1,
      };

  /// Display name in Spanish.
  String get displayName => switch (this) {
        FinishType.xtreme => 'Xtreme Finish',
        FinishType.over => 'Over Finish',
        FinishType.burst => 'Burst Finish',
        FinishType.spin => 'Spin Finish',
        FinishType.penalty => 'Penalización',
      };
}
