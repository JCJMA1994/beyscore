import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Service to generate official, printable Takara Tomy / B4 v12 tournament rules sheet (A4).
class RulesSheetPdfService {
  const RulesSheetPdfService();

  /// Generates an A4 PDF summary sheet of the 2026 v12 Beyblade X tournament rules.
  Future<Uint8List> generateOfficialRulesSheetPdf({
    String organizationName = 'BeyScore Tournament Network',
    String officialVersion = '12',
    String releaseDate = 'Marzo 2026',
  }) async {
    final doc = pw.Document(
      title: 'Reglamento_Oficial_Beyblade_X_v$officialVersion',
      author: organizationName,
    );

    pw.Font? titleFont;
    pw.Font? bodyFont;
    pw.Font? monoFont;

    try {
      titleFont = await PdfGoogleFonts.orbitronBold();
      bodyFont = await PdfGoogleFonts.montserratMedium();
      monoFont = await PdfGoogleFonts.spaceMonoBold();
    } catch (_) {
      // Fallback
    }

    final primaryGold = PdfColor.fromHex('#F59E0B');
    final darkBg = PdfColor.fromHex('#090D16');
    final textMuted = PdfColor.fromHex('#64748B');

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: primaryGold, width: 2),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            padding: const pw.EdgeInsets.all(18),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Row(
                      children: [
                        pw.Container(
                          width: 32,
                          height: 32,
                          decoration: pw.BoxDecoration(
                            color: darkBg,
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                          ),
                          child: pw.Center(
                            child: pw.Text(
                              'X',
                              style: pw.TextStyle(
                                font: titleFont,
                                fontSize: 18,
                                fontWeight: pw.FontWeight.bold,
                                color: primaryGold,
                              ),
                            ),
                          ),
                        ),
                        pw.SizedBox(width: 10),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'REGLAMENTO OFICIAL BEYBLADE X',
                              style: pw.TextStyle(
                                font: titleFont,
                                fontSize: 13,
                                fontWeight: pw.FontWeight.bold,
                                color: darkBg,
                              ),
                            ),
                            pw.Text(
                              'NORMATIVA DE ARBITRAJE TAKARA TOMY / B4 · EDICIÓN V$officialVersion ($releaseDate)',
                              style: pw.TextStyle(
                                font: bodyFont,
                                fontSize: 7.5,
                                color: textMuted,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: pw.BoxDecoration(
                        color: primaryGold,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                      ),
                      child: pw.Text(
                        'OFICIAL B4',
                        style: pw.TextStyle(
                          font: monoFont,
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                          color: darkBg,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Divider(color: PdfColor.fromHex('#E2E8F0'), thickness: 1),
                pw.SizedBox(height: 10),

                // Section 1: Sistema de Puntuación (Victoria a 4 Puntos)
                pw.Text(
                  '1. SISTEMA DE PUNTUACIÓN (VICTORIA A 4 PUNTOS)',
                  style: pw.TextStyle(
                    font: titleFont,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: darkBg,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColor.fromHex('#CBD5E1'), width: 0.5),
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F8FAFC')),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text('Tipo de Finalización', style: pw.TextStyle(font: bodyFont, fontSize: 8, fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text('Puntos', style: pw.TextStyle(font: bodyFont, fontSize: 8, fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text('Criterio Oficial de Arbitraje', style: pw.TextStyle(font: bodyFont, fontSize: 8, fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                    _buildRuleRow('Xtreme Finish', '3 Pts', 'El Bey rival cae en la zona Xtreme y no puede reingresar al area de combate.', bodyFont),
                    _buildRuleRow('Over Finish', '2 Pts', 'El Bey rival es expulsado fuera del area de combate hacia los bolsillos Over.', bodyFont),
                    _buildRuleRow('Burst Finish', '2 Pts', 'Las piezas del Bey rival se separan y desarticulan primero.', bodyFont),
                    _buildRuleRow('Spin Finish', '1 Pt', 'El Bey rival se detiene primero (velocidad angular cero) dentro del estadio.', bodyFont),
                    _buildRuleRow('Falta de Lanzamiento', '1 Pt', '2 fallas acumuladas de lanzamiento en la misma ronda otorgan 1 pt al rival.', bodyFont),
                  ],
                ),

                pw.SizedBox(height: 14),

                // Section 2: Formato 3on3 y Reglas de Piezas
                pw.Text(
                  '2. FORMATO 3ON3 Y PROHIBICION DE PIEZAS DUPLICADAS',
                  style: pw.TextStyle(
                    font: titleFont,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: darkBg,
                  ),
                ),
                pw.SizedBox(height: 6),
                _buildBulletPoint('Deck 3on3 Oficial: Cada Blader presenta 3 Beys en su Deck Box (BX-12 u homologada).', bodyFont),
                _buildBulletPoint('Sin Piezas Duplicadas: Ninguna pieza (Blade, Ratchet, Bit) puede repetirse entre los 3 Beys, inclusive si tienen distinto color o version cosmetica.', bodyFont),
                _buildBulletPoint('Excepcion Unica CX: Se permite repetir unicamente los Lock Chips Ares y Emperor (maximo 1 de cada uno en el deck).', bodyFont),
                _buildBulletPoint('Salon de la Fama: Las piezas restringidas en 1v1 estan permitidas exclusivamente en formato 3on3 y torneos por equipo.', bodyFont),

                pw.SizedBox(height: 14),

                // Section 3: Normativa de Lanzamiento y Conducta
                pw.Text(
                  '3. PROTOCOLO DE LANZAMIENTO Y CONDUCTA DEPORTIVA',
                  style: pw.TextStyle(
                    font: titleFont,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: darkBg,
                  ),
                ),
                pw.SizedBox(height: 6),
                _buildBulletPoint('Comando de Salida: "3, 2, 1, Go Shoot!" - El lanzamiento debe ejecutarse estrictamente al pronunciar "Shoot".', bodyFont),
                _buildBulletPoint('Altura Maxima de Lanzamiento: 20 cm medidos desde la superficie superior del estadio.', bodyFont),
                _buildBulletPoint('Eleccion de Lado: Izquierda, Derecha o Centro definido por piedra-papel-tijera previo al combate y mantenido en toda la partida.', bodyFont),
                _buildBulletPoint('Prohibido Tocar el Estadio: Tocar un Bey antes de que el arbitro declare el final de la ronda conlleva derrota automatica.', bodyFont),

                pw.SizedBox(height: 14),

                // Section 4: Categorías de Torneo B4
                pw.Text(
                  '4. ESCALA OFICIAL DE EVENTOS B4',
                  style: pw.TextStyle(
                    font: titleFont,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: darkBg,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Row(
                  children: [
                    _buildTierBadge('G3', 'Local / Tiendas B4', PdfColor.fromHex('#10B981'), bodyFont, monoFont),
                    pw.SizedBox(width: 8),
                    _buildTierBadge('G2', 'Regional / Inter-ciudades', PdfColor.fromHex('#F59E0B'), bodyFont, monoFont),
                    pw.SizedBox(width: 8),
                    _buildTierBadge('G1', 'Nacional', PdfColor.fromHex('#EF4444'), bodyFont, monoFont),
                    pw.SizedBox(width: 8),
                    _buildTierBadge('GP', 'Grand Prix Mundial', PdfColor.fromHex('#8B5CF6'), bodyFont, monoFont),
                  ],
                ),

                pw.Spacer(),

                // Footer
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Generado por $organizationName', style: pw.TextStyle(font: bodyFont, fontSize: 7, color: textMuted)),
                    pw.Text('BEYBLADE X™ es marca registrada de TAKARA TOMY / HASBRO. Uso informativo y deportivo.', style: pw.TextStyle(font: bodyFont, fontSize: 6.5, color: textMuted)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    return doc.save();
  }

  static pw.TableRow _buildRuleRow(String title, String pts, String desc, pw.Font? font) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(title, style: pw.TextStyle(font: font, fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(pts, style: pw.TextStyle(font: font, fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#B45309'))),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(desc, style: pw.TextStyle(font: font, fontSize: 7)),
        ),
      ],
    );
  }

  static pw.Widget _buildBulletPoint(String text, pw.Font? font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('• ', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#F59E0B'))),
          pw.Expanded(
            child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: 7.5, color: PdfColor.fromHex('#1E293B'))),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTierBadge(String code, String desc, PdfColor color, pw.Font? bodyFont, pw.Font? monoFont) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(6),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: color, width: 1),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(code, style: pw.TextStyle(font: monoFont, fontSize: 9, fontWeight: pw.FontWeight.bold, color: color)),
            pw.SizedBox(height: 2),
            pw.Text(desc, style: pw.TextStyle(font: bodyFont, fontSize: 6.5, color: PdfColor.fromHex('#475569'))),
          ],
        ),
      ),
    );
  }

  /// Convenience helper to preview or print the official rules sheet.
  Future<void> printOrShareRulesSheet({
    String organizationName = 'BeyScore Tournament Network',
  }) async {
    final pdfBytes = await generateOfficialRulesSheetPdf(
      organizationName: organizationName,
    );
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'Reglamento_Oficial_Beyblade_X_v12.pdf',
    );
  }
}
