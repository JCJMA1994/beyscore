import 'dart:ui' as ui;
import 'package:bey_tournament/src/services/diploma_pdf_service.dart';
import 'package:bey_tournament/src/services/rules_sheet_pdf_service.dart';
import 'package:bey_ui/bey_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:printing/printing.dart';

/// Modal dialog allowing organizers and players to view, customize,
/// and export the 4:5 Champion Social Card and Official PDF Diploma.
class ChampionCardDialog extends StatefulWidget {
  const ChampionCardDialog({
    required this.tournamentName,
    required this.tierLabel,
    required this.bladerName,
    required this.placeRank,
    required this.deckEntries,
    this.eventDate,
    this.storeOrVenue,
    this.playerAvatarUrl,
    super.key,
  });

  final String tournamentName;
  final String tierLabel;
  final String bladerName;
  final int placeRank;
  final List<ChampionDeckEntry> deckEntries;
  final DateTime? eventDate;
  final String? storeOrVenue;
  final String? playerAvatarUrl;

  static Future<void> show(
    BuildContext context, {
    required String tournamentName,
    required String tierLabel,
    required String bladerName,
    required int placeRank,
    required List<ChampionDeckEntry> deckEntries,
    DateTime? eventDate,
    String? storeOrVenue,
    String? playerAvatarUrl,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => ChampionCardDialog(
        tournamentName: tournamentName,
        tierLabel: tierLabel,
        bladerName: bladerName,
        placeRank: placeRank,
        deckEntries: deckEntries,
        eventDate: eventDate,
        storeOrVenue: storeOrVenue,
        playerAvatarUrl: playerAvatarUrl,
      ),
    );
  }

  @override
  State<ChampionCardDialog> createState() => _ChampionCardDialogState();
}

class _ChampionCardDialogState extends State<ChampionCardDialog> {
  final GlobalKey _cardBoundaryKey = GlobalKey();
  ChampionCardTheme _theme = ChampionCardTheme.electric;
  bool _isExporting = false;

  Future<void> _exportPng() async {
    setState(() => _isExporting = true);
    try {
      final boundary =
          _cardBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final pngBytes = byteData.buffer.asUint8List();
      await Printing.sharePdf(
        bytes: pngBytes,
        filename: 'Champion_Card_${widget.bladerName}_${widget.tournamentName}.png',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar imagen: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _exportChampionDeckPdf() async {
    setState(() => _isExporting = true);
    try {
      const diplomaService = DiplomaPdfService();
      final combosList = widget.deckEntries.map((e) {
        return {
          'blade': e.blade.name,
          'ratchet': e.ratchet.code ?? e.ratchet.name,
          'bit': e.bit.code ?? e.bit.name,
          'type': e.archetype ?? 'Ataque',
          'weight': e.blade.weightG != null ? e.blade.weightG.toString() : '35.0',
        };
      }).toList();

      await diplomaService.printOrShareChampionCardPdf(
        context: context,
        tournamentName: widget.tournamentName,
        tierLabel: widget.tierLabel,
        divisionLabel: 'Open (6+)',
        bladerName: widget.bladerName,
        placeRank: widget.placeRank,
        deckCombos: combosList,
        storeOrVenue: widget.storeOrVenue,
        eventDate: widget.eventDate,
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _exportDiplomaPdf() async {
    setState(() => _isExporting = true);
    try {
      const diplomaService = DiplomaPdfService();
      final deckText = widget.deckEntries
          .map((e) => '${e.blade.name} ${e.ratchet.code ?? e.ratchet.name} ${e.bit.code ?? e.bit.name}')
          .join(' // ');

      await diplomaService.printOrShareDiploma(
        context: context,
        tournamentName: widget.tournamentName,
        tierLabel: widget.tierLabel,
        divisionLabel: 'Open (6+)',
        bladerName: widget.bladerName,
        placeTitle: widget.placeRank == 1 ? 'Campeón Oficial' : 'Finalista',
        placeRank: widget.placeRank,
        deckInfo: deckText.isNotEmpty ? deckText : null,
        location: widget.storeOrVenue,
        date: widget.eventDate,
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _exportRulesPdf() async {
    const rulesService = RulesSheetPdfService();
    await rulesService.printOrShareRulesSheet();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0F111A),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF232A40)),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 720),
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            // Modal Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TARJETA DE CAMPEÓN 4:5',
                      style: AppTypography.mono.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF00E5D0),
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      'Previsualización y Exportación',
                      style: AppTypography.displaySmall.copyWith(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Theme Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildThemeChip(
                  label: 'Electric Neon',
                  theme: ChampionCardTheme.electric,
                  color: const Color(0xFF00E5D0),
                ),
                const SizedBox(width: 12),
                _buildThemeChip(
                  label: 'Floral Golden',
                  theme: ChampionCardTheme.floral,
                  color: const Color(0xFFF59E0B),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Card Render Box (RepaintBoundary for Image Snapshot)
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: RepaintBoundary(
                    key: _cardBoundaryKey,
                    child: ChampionCardWidget(
                      tournamentName: widget.tournamentName,
                      tierLabel: widget.tierLabel,
                      bladerName: widget.bladerName,
                      placeRank: widget.placeRank,
                      deckEntries: widget.deckEntries,
                      theme: _theme,
                      eventDate: widget.eventDate,
                      storeOrVenue: widget.storeOrVenue,
                      playerAvatarUrl: widget.playerAvatarUrl,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                // Share PNG Button
                ElevatedButton.icon(
                  onPressed: _isExporting ? null : _exportPng,
                  icon: const Icon(Icons.share, size: 15),
                  label: const Text('COMPARTIR (PNG)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5D0),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    textStyle: AppTypography.mono.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Champion Deck 3on3 PDF Button (New BeybladeHub Style)
                ElevatedButton.icon(
                  onPressed: _isExporting ? null : _exportChampionDeckPdf,
                  icon: const Icon(Icons.badge, size: 15),
                  label: const Text('DIPLOMA 3ON3 (PDF)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFCC00),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    textStyle: AppTypography.mono.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Classic Diploma PDF Button
                OutlinedButton.icon(
                  onPressed: _isExporting ? null : _exportDiplomaPdf,
                  icon: const Icon(Icons.picture_as_pdf, size: 15),
                  label: const Text('DIPLOMA CLÁSICO'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF333E5E)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    textStyle: AppTypography.mono.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Rules PDF Button
                IconButton(
                  tooltip: 'Descargar Reglamento Oficial v12 en PDF',
                  onPressed: _exportRulesPdf,
                  icon: const Icon(Icons.menu_book, color: Color(0xFFF59E0B)),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF1E1B0E),
                    side: const BorderSide(color: Color(0xFF78350F)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeChip({
    required String label,
    required ChampionCardTheme theme,
    required Color color,
  }) {
    final isSelected = _theme == theme;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _theme = theme),
      selectedColor: color.withValues(alpha: 0.2),
      backgroundColor: const Color(0xFF141724),
      labelStyle: AppTypography.mono.copyWith(
        fontSize: 10,
        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
        color: isSelected ? color : const Color(0xFF94A3B8),
      ),
      side: BorderSide(
        color: isSelected ? color : const Color(0xFF283049),
      ),
    );
  }
}
