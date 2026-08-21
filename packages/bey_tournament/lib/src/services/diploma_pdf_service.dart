import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Servicio de generación y emisión de Diplomas y Certificados Oficiales BeyScore en formato Horizontal (Landscape).
class DiplomaPdfService {
  const DiplomaPdfService();

  /// Genera un diploma PDF de alta resolución en orientación horizontal (A4 Landscape).
  Future<Uint8List> generateDiplomaPdf({
    required String tournamentName,
    required String tierLabel,
    required String divisionLabel,
    required String bladerName,
    required String placeTitle,
    required int placeRank,
    String? deckInfo,
    int? totalParticipants,
    String? location,
    String? organizerName,
    DateTime? date,
  }) async {
    final doc = pw.Document(
      title: 'Diploma_${placeRank}_${bladerName}_$tournamentName',
      author: 'BeyScore Official Tournament Network',
    );

    final issueDate = date ?? DateTime.now();
    final formattedDate =
        '${issueDate.day.toString().padLeft(2, '0')}/${issueDate.month.toString().padLeft(2, '0')}/${issueDate.year}';

    // Paleta de colores metálicos y contrastes de alta gama según posición
    final primaryColor = switch (placeRank) {
      1 => PdfColor.fromHex('#D4AF37'), // Oro Metálico Brillante
      2 => PdfColor.fromHex('#94A3B8'), // Plata Titanio
      3 => PdfColor.fromHex('#CD7F32'), // Bronce Cuproso
      _ => PdfColor.fromHex('#00E5D0'), // Cian Neón BeyScore
    };

    final primaryDarkColor = switch (placeRank) {
      1 => PdfColor.fromHex('#8F6F1E'),
      2 => PdfColor.fromHex('#475569'),
      3 => PdfColor.fromHex('#78350F'),
      _ => PdfColor.fromHex('#006B61'),
    };

    final rankBannerText = switch (placeRank) {
      1 => '1ER LUGAR · CAMPEÓN OFICIAL',
      2 => '2DO LUGAR · SUBCAMPEÓN',
      3 => '3ER LUGAR · MEDALLA DE BRONCE',
      _ => 'DISTINCIÓN AL MÉRITO DEPORTIVO',
    };

    final certificateSub = switch (placeRank) {
      1 => 'Por haber alcanzado la máxima gloria, demostrando maestría táctica, potencia y temple de campeón.',
      2 => 'Por su sobresaliente desempeño y tenacidad en la gran final del torneo.',
      3 => 'Por su destacada destreza y espíritu competitivo al conquistar el podio del torneo.',
      _ => 'Por su intachable conducta deportiva y participación en la contienda oficial.',
    };

    pw.Font? titleFont;
    pw.Font? bodyFont;
    pw.Font? monoFont;

    try {
      titleFont = await PdfGoogleFonts.orbitronBold();
      bodyFont = await PdfGoogleFonts.montserratMedium();
      monoFont = await PdfGoogleFonts.spaceMonoBold();
    } catch (_) {
      // Fallback estándar en caso de no disponer de conexión a internet
    }

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(14),
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              border: pw.Border.all(color: primaryColor, width: 4),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
            ),
            child: pw.Container(
              margin: const pw.EdgeInsets.all(4),
              padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#FCFCFD'),
                border: pw.Border.all(color: primaryDarkColor, width: 1.2),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  // ==========================================
                  // 1. CABECERA Y MARCAS DEL CIRCUITO OFICIAL
                  // ==========================================
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      // Escudo y Título del Circuito
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Container(
                            width: 36,
                            height: 36,
                            decoration: pw.BoxDecoration(
                              color: PdfColor.fromHex('#090D16'),
                              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                              border: pw.Border.all(color: primaryColor, width: 1.5),
                            ),
                            child: pw.Center(
                              child: pw.Text(
                                'X',
                                style: pw.TextStyle(
                                  font: titleFont,
                                  fontSize: 20,
                                  fontWeight: pw.FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ),
                          pw.SizedBox(width: 10),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'BEYSCORE TOURNAMENT NETWORK',
                                style: pw.TextStyle(
                                  font: titleFont,
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColor.fromHex('#090D16'),
                                  letterSpacing: 1.5,
                                ),
                              ),
                              pw.Text(
                                'LIGA OFICIAL BEYBLADE X · FORMATO 3ON3 · REGLAMENTO V12',
                                style: pw.TextStyle(
                                  font: bodyFont,
                                  fontSize: 7,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColor.fromHex('#64748B'),
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Etiquetas de Categoría y División
                      pw.Row(
                        children: [
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: pw.BoxDecoration(
                              color: PdfColor.fromHex('#090D16'),
                              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                              border: pw.Border.all(color: primaryColor, width: 1),
                            ),
                            child: pw.Text(
                              'TIER ${tierLabel.toUpperCase()}',
                              style: pw.TextStyle(
                                font: monoFont,
                                fontSize: 8,
                                fontWeight: pw.FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ),
                          pw.SizedBox(width: 6),
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: pw.BoxDecoration(
                              color: PdfColor.fromHex('#F1F5F9'),
                              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                              border: pw.Border.all(color: PdfColor.fromHex('#CBD5E1')),
                            ),
                            child: pw.Text(
                              'DIVISIÓN ${divisionLabel.toUpperCase()}',
                              style: pw.TextStyle(
                                font: monoFont,
                                fontSize: 8,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColor.fromHex('#1E293B'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // ==========================================
                  // 2. TÍTULO PRINCIPAL Y CINTA DE HONOR
                  // ==========================================
                  pw.Column(
                    children: [
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'CERTIFICADO DE HONOR Y MÉRITO DEPORTIVO',
                        style: pw.TextStyle(
                          font: titleFont,
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 2.2,
                          color: PdfColor.fromHex('#090D16'),
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Container(width: 50, height: 1.5, color: primaryColor),
                          pw.Container(
                            margin: const pw.EdgeInsets.symmetric(horizontal: 8),
                            width: 6,
                            height: 6,
                            decoration: pw.BoxDecoration(
                              color: primaryColor,
                              shape: pw.BoxShape.circle,
                            ),
                          ),
                          pw.Container(width: 50, height: 1.5, color: primaryColor),
                        ],
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        certificateSub,
                        style: pw.TextStyle(
                          font: bodyFont,
                          fontSize: 8.5,
                          color: PdfColor.fromHex('#475569'),
                          fontStyle: pw.FontStyle.italic,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ],
                  ),

                  // ==========================================
                  // 3. NOMBRE DEL BLADER (HERO BOX)
                  // ==========================================
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#F8FAFC'),
                      border: pw.Border.symmetric(
                        horizontal: pw.BorderSide(color: primaryColor, width: 2),
                      ),
                    ),
                    child: pw.Center(
                      child: pw.Text(
                        bladerName.toUpperCase(),
                        style: pw.TextStyle(
                          font: titleFont,
                          fontSize: 26,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 2.5,
                          color: PdfColor.fromHex('#090D16'),
                        ),
                      ),
                    ),
                  ),

                  // ==========================================
                  // 4. DISTINCIÓN Y DATOS DEL TORNEO
                  // ==========================================
                  pw.Column(
                    children: [
                      // Banner de posición
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                        decoration: pw.BoxDecoration(
                          color: primaryColor,
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(20)),
                        ),
                        child: pw.Text(
                          rankBannerText,
                          style: pw.TextStyle(
                            font: titleFont,
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: placeRank == 1 ? PdfColors.black : PdfColors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 5),

                      // Nombre del Torneo y Estadísticas de Competencia
                      pw.Text(
                        'TORNEO: "${tournamentName.toUpperCase()}"',
                        style: pw.TextStyle(
                          font: titleFont,
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#090D16'),
                          letterSpacing: 1,
                        ),
                      ),
                      pw.SizedBox(height: 2),

                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          if (totalParticipants != null && totalParticipants > 0) ...[
                            pw.Text(
                              'Participantes: $totalParticipants Bladers  ·  ',
                              style: pw.TextStyle(font: bodyFont, fontSize: 8, color: PdfColor.fromHex('#64748B')),
                            ),
                          ],
                          if (location != null && location.isNotEmpty) ...[
                            pw.Text(
                              'Sede: $location  ·  ',
                              style: pw.TextStyle(font: bodyFont, fontSize: 8, color: PdfColor.fromHex('#64748B')),
                            ),
                          ],
                          pw.Text(
                            'Reglamento: Oficial Takara Tomy / WBBA v12',
                            style: pw.TextStyle(font: bodyFont, fontSize: 8, color: PdfColor.fromHex('#64748B')),
                          ),
                        ],
                      ),

                      // Desglose del Deck 3on3 si existe
                      if (deckInfo != null && deckInfo.isNotEmpty) ...[
                        pw.SizedBox(height: 4),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                          decoration: pw.BoxDecoration(
                            color: PdfColor.fromHex('#F1F5F9'),
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                            border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
                          ),
                          child: pw.Text(
                            'Arsenal Oficial Declarado (3on3): $deckInfo',
                            style: pw.TextStyle(
                              font: monoFont,
                              fontSize: 7.5,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromHex('#334155'),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  // ==========================================
                  // 5. SELLO DIGITAL, FIRMA Y AUTENTICACIÓN
                  // ==========================================
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      // QR y Verificación Criptográfica
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Container(
                            padding: const pw.EdgeInsets.all(3),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.white,
                              border: pw.Border.all(color: PdfColor.fromHex('#CBD5E1')),
                              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                            ),
                            child: pw.BarcodeWidget(
                              barcode: pw.Barcode.qrCode(),
                              data:
                                  'https://beyscore.app/verify?blader=$bladerName&tournament=$tournamentName&rank=$placeRank&date=$formattedDate',
                              width: 38,
                              height: 38,
                            ),
                          ),
                          pw.SizedBox(width: 8),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'REGISTRO DIGITAL OFICIAL',
                                style: pw.TextStyle(
                                  font: titleFont,
                                  fontSize: 6.5,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColor.fromHex('#090D16'),
                                ),
                              ),
                              pw.Text(
                                'Validación por Red Local / Nube',
                                style: pw.TextStyle(
                                  font: bodyFont,
                                  fontSize: 6,
                                  color: PdfColor.fromHex('#64748B'),
                                ),
                              ),
                              pw.Text(
                                'HASH: ${bladerName.hashCode.abs().toRadixString(16).toUpperCase()}-${issueDate.millisecondsSinceEpoch.toRadixString(16).toUpperCase()}',
                                style: pw.TextStyle(
                                  font: monoFont,
                                  fontSize: 5.5,
                                  color: PdfColor.fromHex('#94A3B8'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Línea de Firma Oficial
                      pw.Column(
                        children: [
                          pw.Container(
                            width: 160,
                            decoration: pw.BoxDecoration(
                              border: pw.Border(
                                top: pw.BorderSide(color: PdfColor.fromHex('#334155'), width: 1.2),
                              ),
                            ),
                          ),
                          pw.SizedBox(height: 3),
                          pw.Text(
                            organizerName != null && organizerName.isNotEmpty
                                ? organizerName.toUpperCase()
                                : 'JUEZ PRINCIPAL / ORGANIZADOR',
                            style: pw.TextStyle(
                              font: titleFont,
                              fontSize: 7.5,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromHex('#090D16'),
                            ),
                          ),
                          pw.Text(
                            'Comité Oficial de Arbitraje y Certificación',
                            style: pw.TextStyle(
                              font: bodyFont,
                              fontSize: 6.5,
                              color: PdfColor.fromHex('#64748B'),
                            ),
                          ),
                        ],
                      ),

                      // Sello Holográfico y Fecha
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(color: primaryColor, width: 1.2),
                              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                              color: primaryColor,
                            ),
                            child: pw.Text(
                              'SELLO OFICIAL V12',
                              style: pw.TextStyle(
                                font: monoFont,
                                fontSize: 7,
                                fontWeight: pw.FontWeight.bold,
                                color: placeRank == 1 ? PdfColors.black : PdfColors.white,
                              ),
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'Emisión: $formattedDate',
                            style: pw.TextStyle(
                              font: monoFont,
                              fontSize: 7,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromHex('#334155'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    return doc.save();
  }

  /// Abre directamente el visor de impresión del sistema operativo preconfigurado en orientación horizontal (Landscape).
  Future<void> printOrShareDiploma({
    required BuildContext context,
    required String tournamentName,
    required String tierLabel,
    required String divisionLabel,
    required String bladerName,
    required String placeTitle,
    required int placeRank,
    String? deckInfo,
    int? totalParticipants,
    String? location,
    String? organizerName,
    DateTime? date,
  }) async {
    final pdfBytes = await generateDiplomaPdf(
      tournamentName: tournamentName,
      tierLabel: tierLabel,
      divisionLabel: divisionLabel,
      bladerName: bladerName,
      placeTitle: placeTitle,
      placeRank: placeRank,
      deckInfo: deckInfo,
      totalParticipants: totalParticipants,
      location: location,
      organizerName: organizerName,
      date: date,
    );

    final cleanFileName =
        'Diploma_${placeRank}_${bladerName.replaceAll(' ', '_')}_${tournamentName.replaceAll(' ', '_')}.pdf';

    await Printing.layoutPdf(
      name: cleanFileName,
      format: PdfPageFormat.a4.landscape,
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  }
}
