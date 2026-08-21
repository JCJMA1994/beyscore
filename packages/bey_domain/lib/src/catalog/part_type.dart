/// Enums for the part catalog.
///
/// Pure Dart. No Flutter, no Drift imports.

/// CX has more subtypes than expected: lock chip, main blade, assist blade,
/// over blade, and metal blade. (CLAUDE.md section 8)
enum PartType {
  blade,
  ratchet,
  bit,
  lockChip,
  mainBlade,
  assistBlade,
  overBlade,
  metalBlade,
  accessory,
}

enum BeySystem { bx, ux, cx }

enum SpinDirection { right, left }

/// beyType comes from the source, NEVER calculated.
/// Guessing by name had 32% accuracy. (CLAUDE.md section 10)
enum BeyType { attack, defense, stamina, balance }
