import 'package:bey_domain/bey_domain.dart';
import 'package:flutter/material.dart';

import '../theme/app_typography.dart';
import 'part_image.dart';

/// Presentation theme for the Champion Card.
enum ChampionCardTheme {
  electric,
  floral,
}

/// A combo entry for the Champion Card's 3on3 deck display.
class ChampionDeckEntry {
  const ChampionDeckEntry({
    required this.blade,
    required this.ratchet,
    required this.bit,
    this.customName,
    this.archetype,
  });

  final Part blade;
  final Part ratchet;
  final Part bit;
  final String? customName;
  final String? archetype;
}

/// Official 4:5 aspect ratio Champion & Podium share card.
///
/// Designed for high-res social media sharing (Instagram, Threads, WhatsApp)
/// and tournament award ceremonies.
class ChampionCardWidget extends StatelessWidget {
  const ChampionCardWidget({
    required this.tournamentName,
    required this.tierLabel,
    required this.bladerName,
    required this.placeRank,
    required this.deckEntries,
    this.theme = ChampionCardTheme.electric,
    this.eventDate,
    this.storeOrVenue,
    this.playerAvatarUrl,
    this.customRankText,
    super.key,
  });

  final String tournamentName;
  final String tierLabel;
  final String bladerName;
  final int placeRank; // 1 = Gold, 2 = Silver, 3 = Bronze, 4+ = Merit/MVP
  final List<ChampionDeckEntry> deckEntries; // up to 3 Beys
  final ChampionCardTheme theme;
  final DateTime? eventDate;
  final String? storeOrVenue;
  final String? playerAvatarUrl;
  final String? customRankText;

  @override
  Widget build(BuildContext context) {
    final (rankText, stops, glowColor) = _resolveRankColors();
    final isElectric = theme == ChampionCardTheme.electric;

    return AspectRatio(
      aspectRatio: 4 / 5,
      child: Container(
        decoration: BoxDecoration(
          color: isElectric ? const Color(0xFF090A12) : const Color(0xFF0B0E14),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isElectric ? const Color(0xFF2C324B) : const Color(0xFF332B1E),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: glowColor.withValues(alpha: 0.25),
              blurRadius: 28,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            children: [
              // Background Accents / Cyber Grid
              Positioned.fill(
                child: CustomPaint(
                  painter: _CardBackgroundPainter(
                    isElectric: isElectric,
                    accentColor: glowColor,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Header Bar: Circuit & Tournament metadata
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: glowColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: glowColor.withValues(alpha: 0.5)),
                                    ),
                                    child: Text(
                                      'TIER $tierLabel',
                                      style: AppTypography.mono.copyWith(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        color: glowColor,
                                      ),
                                    ),
                                  ),
                                  if (storeOrVenue != null) ...[
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        storeOrVenue!,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.mono.copyWith(
                                          fontSize: 9,
                                          color: const Color(0xFF94A3B8),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tournamentName.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.displaySmall.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Date Badge
                        if (eventDate != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF141724),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFF262C42)),
                            ),
                            child: Text(
                              '${eventDate!.day}/${eventDate!.month}/${eventDate!.year}',
                              style: AppTypography.mono.copyWith(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFCBD5E1),
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // 2. Hero Section: Rank Banner + Blader Name & Avatar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            glowColor.withValues(alpha: 0.12),
                            const Color(0xFF141724),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: glowColor.withValues(alpha: 0.4), width: 1.2),
                      ),
                      child: Row(
                        children: [
                          // Player Avatar / Photo Frame
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: glowColor, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: glowColor.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: playerAvatarUrl != null
                                  ? Image.network(
                                      playerAvatarUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => _avatarFallback(),
                                    )
                                  : _avatarFallback(),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    colors: stops,
                                  ).createShader(bounds),
                                  child: Text(
                                    (customRankText ?? rankText).toUpperCase(),
                                    style: AppTypography.displaySmall.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  bladerName.toUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.displaySmall.copyWith(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Section Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'DECK 3ON3 VENCEDOR',
                          style: AppTypography.mono.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                        Text(
                          'REGLAMENTO OFICIAL V12',
                          style: AppTypography.mono.copyWith(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // 3. Deck 3on3 Panels (3 Slots)
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (var i = 0; i < 3; i++)
                            _buildComboSlot(
                              slotNumber: i + 1,
                              entry: i < deckEntries.length ? deckEntries[i] : null,
                              accentColor: glowColor,
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 4. Footer & Verification Barcode Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: const Color(0xFF00E5D0),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Center(
                                child: Text(
                                  'X',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'BEYSCORE TOURNAMENT NETWORK',
                              style: AppTypography.mono.copyWith(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'VERIFIED DECK',
                          style: AppTypography.mono.copyWith(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF10B981),
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComboSlot({
    required int slotNumber,
    ChampionDeckEntry? entry,
    required Color accentColor,
  }) {
    if (entry == null) {
      return Container(
        height: 64,
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF0F121C),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF1C2234)),
        ),
        child: Center(
          child: Text(
            'SLOT #$slotNumber — SIN ASIGNAR',
            style: AppTypography.mono.copyWith(
              fontSize: 10,
              color: const Color(0xFF475569),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    final blade = entry.blade;
    final ratchet = entry.ratchet;
    final bit = entry.bit;
    final comboCode = '${blade.productCode ?? '—'} · ${ratchet.code ?? ratchet.name} · ${bit.code ?? bit.name}';

    return Container(
      height: 68,
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF111422),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF242A42)),
      ),
      child: Row(
        children: [
          // Slot Number Badge
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFF1A2033),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF333D5E)),
            ),
            child: Center(
              child: Text(
                '$slotNumber',
                style: AppTypography.mono.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Blade Image
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0A0C14),
              border: Border.all(color: const Color(0xFF242A42)),
            ),
            child: ClipOval(
              child: PartImage(
                type: PartType.blade,
                imageRemote: blade.imageRemote,
                imageLocal: blade.imageLocal,
                size: 48,
                showBorder: false,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Combo Name & Parts Breakdown
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  blade.name.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.displaySmall.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  comboCode,
                  style: AppTypography.mono.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF00E5D0),
                  ),
                ),
              ],
            ),
          ),

          // Archetype Badge
          if (entry.archetype != null || blade.beyType != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF192033),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                (entry.archetype ?? blade.beyType!.name).toUpperCase(),
                style: AppTypography.mono.copyWith(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _avatarFallback() {
    return const ColoredBox(
      color: Color(0xFF141724),
      child: Center(
        child: Icon(Icons.person, color: Color(0xFF64748B), size: 28),
      ),
    );
  }

  (String rankText, List<Color> stops, Color glowColor) _resolveRankColors() {
    return switch (placeRank) {
      1 => (
          '1er Lugar · Campeón',
          const [Color(0xFFFFF3C4), Color(0xFFFFD96B), Color(0xFFD99A2B)],
          const Color(0xFFF59E0B),
        ),
      2 => (
          '2do Lugar · Subcampeón',
          const [Color(0xFFFFFFFF), Color(0xFFDCE2EC), Color(0xFF9AA6B8)],
          const Color(0xFF94A3B8),
        ),
      3 => (
          '3er Lugar · Bronce',
          const [Color(0xFFFFD9B0), Color(0xFFE6A86A), Color(0xFFB0703A)],
          const Color(0xFFD97706),
        ),
      _ => (
          'Distinción MVP',
          const [Color(0xFF80FFEA), Color(0xFF00E5D0), Color(0xFF009688)],
          const Color(0xFF00E5D0),
        ),
    };
  }
}

class _CardBackgroundPainter extends CustomPainter {
  _CardBackgroundPainter({
    required this.isElectric,
    required this.accentColor,
  });

  final bool isElectric;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accentColor.withValues(alpha: 0.04)
      ..strokeWidth = 1;

    // Diagonal futuristic lines
    for (var x = -size.height; x < size.width; x += 36) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CardBackgroundPainter oldDelegate) {
    return oldDelegate.isElectric != isElectric || oldDelegate.accentColor != accentColor;
  }
}
