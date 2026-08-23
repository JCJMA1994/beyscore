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

  /// Genera la Tarjeta de Campeón y Diploma 3on3 en PDF con diseño BeybladeHub en alta resolución.
  Future<Uint8List> generateChampionCardPdf({
    required String tournamentName,
    required String tierLabel,
    required String divisionLabel,
    required String bladerName,
    required int placeRank,
    List<Map<String, String>> deckCombos = const [],
    String? storeOrVenue,
    DateTime? eventDate,
    String? organizerName,
  }) async {
    final doc = pw.Document(
      title: 'Champion_Card_${bladerName}_$tournamentName',
      author: 'BeyScore Tournament Network',
    );

    final issueDate = eventDate ?? DateTime.now();
    final formattedDate =
        '${issueDate.day.toString().padLeft(2, '0')}/${issueDate.month.toString().padLeft(2, '0')}/${issueDate.year}';

    final isGold = placeRank == 1;
    final primaryColor = isGold ? PdfColor.fromHex('#FFCC00') : PdfColor.fromHex('#00E5D0');
    final darkBg = PdfColor.fromHex('#090A12');
    final cardBg = PdfColor.fromHex('#131622');
    final borderColor = isGold ? PdfColor.fromHex('#D4AF37') : PdfColor.fromHex('#00A896');

    pw.Font? titleFont;
    pw.Font? bodyFont;
    pw.Font? monoFont;

    try {
      titleFont = await PdfGoogleFonts.orbitronBold();
      bodyFont = await PdfGoogleFonts.montserratMedium();
      monoFont = await PdfGoogleFonts.spaceMonoBold();
    } catch (_) {}

    final rankTitle = switch (placeRank) {
      1 => 'CAMPEÓN · 1ER LUGAR (ORO)',
      2 => 'SUBCAMPEÓN · 2DO LUGAR (PLATA)',
      3 => '3ER LUGAR (BRONCE)',
      _ => 'MÉRITO DEPORTIVO',
    };

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(16),
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(18),
            decoration: pw.BoxDecoration(
              color: darkBg,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
              border: pw.Border.all(color: primaryColor, width: 2.5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                // 1. Cabecera Cyber & Torneo
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Row(
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: pw.BoxDecoration(
                            color: primaryColor,
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                          ),
                          child: pw.Text(
                            'BEYBLADE X',
                            style: pw.TextStyle(
                              font: titleFont,
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.black,
                            ),
                          ),
                        ),
                        pw.SizedBox(width: 8),
                        pw.Text(
                          'CHAMPION DECK CARD · 3ON3',
                          style: pw.TextStyle(
                            font: monoFont,
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#94A3B8'),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: primaryColor),
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                      ),
                      child: pw.Text(
                        'TIER $tierLabel · $divisionLabel',
                        style: pw.TextStyle(
                          font: monoFont,
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 10),

                // 2. Banner de Campeón y Nombre
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: pw.BoxDecoration(
                    color: cardBg,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                    border: pw.Border.all(color: borderColor, width: 1.2),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            rankTitle,
                            style: pw.TextStyle(
                              font: titleFont,
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: primaryColor,
                              letterSpacing: 1.2,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            bladerName.toUpperCase(),
                            style: pw.TextStyle(
                              font: titleFont,
                              fontSize: 22,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'Torneo: $tournamentName',
                            style: pw.TextStyle(
                              font: bodyFont,
                              fontSize: 9,
                              color: PdfColor.fromHex('#CBD5E1'),
                            ),
                          ),
                        ],
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        decoration: pw.BoxDecoration(
                          shape: pw.BoxShape.circle,
                          border: pw.Border.all(color: primaryColor, width: 1.5),
                        ),
                        child: pw.Text(
                          isGold ? '1st' : '${placeRank}th',
                          style: pw.TextStyle(
                            font: titleFont,
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 12),

                // 3. Título de Sección Deck 3on3
                pw.Row(
                  children: [
                    pw.Container(width: 4, height: 14, color: primaryColor),
                    pw.SizedBox(width: 6),
                    pw.Text(
                      'ARSENAL VENCEDOR (DECK 3ON3)',
                      style: pw.TextStyle(
                        font: monoFont,
                        fontSize: 9.5,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 8),

                // 4. Los 3 Beys del Deck en 3 Columnas
                pw.Row(
                  children: [
                    for (int i = 0; i < 3; i++) ...[
                      if (i > 0) pw.SizedBox(width: 8),
                      pw.Expanded(
                        child: pw.Container(
                          padding: const pw.EdgeInsets.all(10),
                          decoration: pw.BoxDecoration(
                            color: cardBg,
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                            border: pw.Border.all(
                              color: i < deckCombos.length ? borderColor : PdfColor.fromHex('#334155'),
                              width: 1,
                            ),
                          ),
                          child: i < deckCombos.length
                              ? pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Row(
                                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                      children: [
                                        pw.Text(
                                          'BEY #${i + 1}',
                                          style: pw.TextStyle(
                                            font: monoFont,
                                            fontSize: 8,
                                            fontWeight: pw.FontWeight.bold,
                                            color: primaryColor,
                                          ),
                                        ),
                                        pw.Container(
                                          padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                          decoration: pw.BoxDecoration(
                                            color: PdfColor.fromHex('#1E293B'),
                                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
                                          ),
                                          child: pw.Text(
                                            deckCombos[i]['type'] ?? 'Ataque',
                                            style: pw.TextStyle(
                                              font: monoFont,
                                              fontSize: 6.5,
                                              color: PdfColor.fromHex('#38BDF8'),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    pw.SizedBox(height: 6),
                                    pw.Text(
                                      deckCombos[i]['blade'] ?? 'Blade',
                                      style: pw.TextStyle(
                                        font: titleFont,
                                        fontSize: 11,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColors.white,
                                      ),
                                    ),
                                    pw.SizedBox(height: 4),
                                    pw.Text(
                                      '${deckCombos[i]['ratchet'] ?? 'Ratchet'} ${deckCombos[i]['bit'] ?? 'Bit'}',
                                      style: pw.TextStyle(
                                        font: monoFont,
                                        fontSize: 9,
                                        fontWeight: pw.FontWeight.bold,
                                        color: primaryColor,
                                      ),
                                    ),
                                    if (deckCombos[i]['weight'] != null) ...[
                                      pw.SizedBox(height: 4),
                                      pw.Text(
                                        'Peso: ${deckCombos[i]['weight']}g',
                                        style: pw.TextStyle(
                                          font: monoFont,
                                          fontSize: 7.5,
                                          color: PdfColor.fromHex('#94A3B8'),
                                        ),
                                      ),
                                    ],
                                  ],
                                )
                              : pw.Center(
                                  child: pw.Text(
                                    'Slot #${i + 1}\n(Sin registro)',
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      font: monoFont,
                                      fontSize: 8,
                                      color: PdfColor.fromHex('#64748B'),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ],
                ),

                pw.SizedBox(height: 12),

                // 5. Pie de Autenticación, QR y Sello
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Row(
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.all(3),
                          decoration: const pw.BoxDecoration(
                            color: PdfColors.white,
                            borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
                          ),
                          child: pw.BarcodeWidget(
                            barcode: pw.Barcode.qrCode(),
                            data:
                                'https://beyscore.app/verify?blader=$bladerName&tournament=$tournamentName&rank=$placeRank',
                            width: 42,
                            height: 42,
                          ),
                        ),
                        pw.SizedBox(width: 8),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'VERIFICADO OFICIAL BEYSCORE',
                              style: pw.TextStyle(
                                font: monoFont,
                                fontSize: 7,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.white,
                              ),
                            ),
                            pw.Text(
                              'Reglamento Oficial Takara Tomy v12',
                              style: pw.TextStyle(
                                font: bodyFont,
                                fontSize: 6.5,
                                color: PdfColor.fromHex('#94A3B8'),
                              ),
                            ),
                            pw.Text(
                              'Fecha: $formattedDate',
                              style: pw.TextStyle(
                                font: monoFont,
                                fontSize: 6.5,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: pw.BoxDecoration(
                            color: primaryColor,
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                          ),
                          child: pw.Text(
                            'SELLO OFICIAL WBBA',
                            style: pw.TextStyle(
                              font: monoFont,
                              fontSize: 7.5,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.black,
                            ),
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          storeOrVenue ?? 'Circuito Chimbote Beyblade X',
                          style: pw.TextStyle(
                            font: bodyFont,
                            fontSize: 7,
                            color: PdfColor.fromHex('#94A3B8'),
                          ),
                        ),
                      ],
                    ),
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

  /// Imprime o comparte la Tarjeta de Campeón 3on3 en PDF.
  Future<void> printOrShareChampionCardPdf({
    required BuildContext context,
    required String tournamentName,
    required String tierLabel,
    required String divisionLabel,
    required String bladerName,
    required int placeRank,
    List<Map<String, String>> deckCombos = const [],
    String? storeOrVenue,
    DateTime? eventDate,
    String? organizerName,
  }) async {
    final pdfBytes = await generateChampionCardPdf(
      tournamentName: tournamentName,
      tierLabel: tierLabel,
      divisionLabel: divisionLabel,
      bladerName: bladerName,
      placeRank: placeRank,
      deckCombos: deckCombos,
      storeOrVenue: storeOrVenue,
      eventDate: eventDate,
      organizerName: organizerName,
    );

    final cleanFileName =
        'ChampionCard_${placeRank}_${bladerName.replaceAll(' ', '_')}_${tournamentName.replaceAll(' ', '_')}.pdf';

    await Printing.layoutPdf(
      name: cleanFileName,
      format: PdfPageFormat.a4,
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  }

  /// Genera el Acta Oficial de Podio y Resultados de Torneo en PDF de alta resolución.
  Future<Uint8List> generatePodiumReportPdf({
    required String tournamentName,
    required String tierLabel,
    required String divisionLabel,
    required String championName,
    required String runnerUpName,
    String? thirdPlaceName,
    String? fourthPlaceName,
    List<Map<String, String>> championDeck = const [],
    List<Map<String, String>> runnerUpDeck = const [],
    List<Map<String, String>> thirdPlaceDeck = const [],
    int totalParticipants = 0,
    int totalMatches = 0,
    int totalPoints = 0,
    String? organizerName,
    DateTime? eventDate,
  }) async {
    final doc = pw.Document(
      title: 'Acta_Podio_$tournamentName',
      author: 'BeyScore Tournament Network',
    );

    final issueDate = eventDate ?? DateTime.now();
    final formattedDate =
        '${issueDate.day.toString().padLeft(2, '0')}/${issueDate.month.toString().padLeft(2, '0')}/${issueDate.year}';

    pw.Font? titleFont;
    pw.Font? bodyFont;
    pw.Font? monoFont;

    try {
      titleFont = await PdfGoogleFonts.orbitronBold();
      bodyFont = await PdfGoogleFonts.montserratMedium();
      monoFont = await PdfGoogleFonts.spaceMonoBold();
    } catch (_) {}

    final darkBg = PdfColor.fromHex('#090A12');
    final cardBg = PdfColor.fromHex('#131622');
    final goldColor = PdfColor.fromHex('#FFD700');
    final silverColor = PdfColor.fromHex('#E2E8F0');
    final bronzeColor = PdfColor.fromHex('#D97706');
    final cyanColor = PdfColor.fromHex('#00E5D0');

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(18),
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              color: darkBg,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
              border: pw.Border.all(color: goldColor, width: 2),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                // 1. Cabecera Oficial
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Row(
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: pw.BoxDecoration(
                            color: goldColor,
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                          ),
                          child: pw.Text(
                            'BEYBLADE X',
                            style: pw.TextStyle(
                              font: titleFont,
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.black,
                            ),
                          ),
                        ),
                        pw.SizedBox(width: 10),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'ACTA OFICIAL DE PODIO Y RESULTADOS',
                              style: pw.TextStyle(
                                font: monoFont,
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                            pw.Text(
                              'FORMATO 3ON3 · REGLAS OFICIALES V12',
                              style: pw.TextStyle(
                                font: bodyFont,
                                fontSize: 7.5,
                                color: PdfColor.fromHex('#94A3B8'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: cyanColor),
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                      ),
                      child: pw.Text(
                        'TIER $tierLabel · $divisionLabel',
                        style: pw.TextStyle(
                          font: monoFont,
                          fontSize: 8.5,
                          fontWeight: pw.FontWeight.bold,
                          color: cyanColor,
                        ),
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 12),

                // 2. Tarjeta del Torneo
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: cardBg,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                    border: pw.Border.all(color: PdfColor.fromHex('#334155')),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            tournamentName.toUpperCase(),
                            style: pw.TextStyle(
                              font: titleFont,
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white,
                            ),
                          ),
                          pw.SizedBox(height: 3),
                          pw.Text(
                            'Juez / Organizador: ${organizerName ?? 'Mesa de Control Oficial'} · Fecha: $formattedDate',
                            style: pw.TextStyle(
                              font: bodyFont,
                              fontSize: 8.5,
                              color: PdfColor.fromHex('#CBD5E1'),
                            ),
                          ),
                        ],
                      ),
                      pw.Row(
                        children: [
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: pw.BoxDecoration(
                              color: PdfColor.fromHex('#1E293B'),
                              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                            ),
                            child: pw.Column(
                              children: [
                                pw.Text(
                                  '$totalParticipants',
                                  style: pw.TextStyle(
                                    font: monoFont,
                                    fontSize: 12,
                                    fontWeight: pw.FontWeight.bold,
                                    color: cyanColor,
                                  ),
                                ),
                                pw.Text(
                                  'BLADERS',
                                  style: pw.TextStyle(font: monoFont, fontSize: 6.5, color: PdfColor.fromHex('#94A3B8')),
                                ),
                              ],
                            ),
                          ),
                          pw.SizedBox(width: 6),
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: pw.BoxDecoration(
                              color: PdfColor.fromHex('#1E293B'),
                              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                            ),
                            child: pw.Column(
                              children: [
                                pw.Text(
                                  '$totalMatches',
                                  style: pw.TextStyle(
                                    font: monoFont,
                                    fontSize: 12,
                                    fontWeight: pw.FontWeight.bold,
                                    color: goldColor,
                                  ),
                                ),
                                pw.Text(
                                  'COMBATES',
                                  style: pw.TextStyle(font: monoFont, fontSize: 6.5, color: PdfColor.fromHex('#94A3B8')),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 12),

                // 3. Podio Oficial de Ganadores (1ro, 2do, 3ro)
                pw.Text(
                  'CUADRO DE HONOR Y PODIO OFICIAL',
                  style: pw.TextStyle(
                    font: monoFont,
                    fontSize: 9.5,
                    fontWeight: pw.FontWeight.bold,
                    color: goldColor,
                    letterSpacing: 1.5,
                  ),
                ),
                pw.SizedBox(height: 6),

                // 1er Lugar (Oro)
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: cardBg,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                    border: pw.Border.all(color: goldColor, width: 1.5),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: pw.BoxDecoration(
                          color: goldColor,
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                        ),
                        child: pw.Text(
                          '1° ORO',
                          style: pw.TextStyle(
                            font: titleFont,
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black,
                          ),
                        ),
                      ),
                      pw.SizedBox(width: 14),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'CAMPEÓN DEL TORNEO',
                              style: pw.TextStyle(
                                font: monoFont,
                                fontSize: 8,
                                color: goldColor,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(
                              championName.toUpperCase(),
                              style: pw.TextStyle(
                                font: titleFont,
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.white,
                              ),
                            ),
                            if (championDeck.isNotEmpty) ...[
                              pw.SizedBox(height: 3),
                              pw.Text(
                                championDeck.map((c) => '${c['blade'] ?? ''} ${c['ratchet'] ?? ''} ${c['bit'] ?? ''}').where((s) => s.trim().isNotEmpty).join('  |  '),
                                style: pw.TextStyle(
                                  font: monoFont,
                                  fontSize: 7.5,
                                  color: PdfColor.fromHex('#94A3B8'),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 8),

                // 2do Lugar (Plata)
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: cardBg,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                    border: pw.Border.all(color: silverColor, width: 1.2),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: pw.BoxDecoration(
                          color: silverColor,
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                        ),
                        child: pw.Text(
                          '2° PLATA',
                          style: pw.TextStyle(
                            font: titleFont,
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black,
                          ),
                        ),
                      ),
                      pw.SizedBox(width: 14),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'SUBCAMPEÓN',
                              style: pw.TextStyle(
                                font: monoFont,
                                fontSize: 7.5,
                                color: silverColor,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(
                              runnerUpName.toUpperCase(),
                              style: pw.TextStyle(
                                font: titleFont,
                                fontSize: 13,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.white,
                              ),
                            ),
                            if (runnerUpDeck.isNotEmpty) ...[
                              pw.SizedBox(height: 2),
                              pw.Text(
                                runnerUpDeck.map((c) => '${c['blade'] ?? ''} ${c['ratchet'] ?? ''} ${c['bit'] ?? ''}').where((s) => s.trim().isNotEmpty).join('  |  '),
                                style: pw.TextStyle(
                                  font: monoFont,
                                  fontSize: 7,
                                  color: PdfColor.fromHex('#94A3B8'),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                if (thirdPlaceName != null && thirdPlaceName.isNotEmpty) ...[
                  pw.SizedBox(height: 8),
                  // 3er Lugar (Bronce)
                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      color: cardBg,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                      border: pw.Border.all(color: bronzeColor, width: 1.2),
                    ),
                    child: pw.Row(
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: pw.BoxDecoration(
                            color: bronzeColor,
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                          ),
                          child: pw.Text(
                            '3° BRONCE',
                            style: pw.TextStyle(
                              font: titleFont,
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white,
                            ),
                          ),
                        ),
                        pw.SizedBox(width: 14),
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'TERCER PUESTO',
                                style: pw.TextStyle(
                                  font: monoFont,
                                  fontSize: 7.5,
                                  color: bronzeColor,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.Text(
                                thirdPlaceName.toUpperCase(),
                                style: pw.TextStyle(
                                  font: titleFont,
                                  fontSize: 13,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.white,
                                ),
                              ),
                              if (thirdPlaceDeck.isNotEmpty) ...[
                                pw.SizedBox(height: 2),
                                pw.Text(
                                  thirdPlaceDeck.map((c) => '${c['blade'] ?? ''} ${c['ratchet'] ?? ''} ${c['bit'] ?? ''}').where((s) => s.trim().isNotEmpty).join('  |  '),
                                  style: pw.TextStyle(
                                    font: monoFont,
                                    fontSize: 7,
                                    color: PdfColor.fromHex('#94A3B8'),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                pw.SizedBox(height: 14),

                // 4. Pie de Página y Sello de Validación
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                          width: 140,
                          height: 1,
                          color: PdfColor.fromHex('#475569'),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'FIRMA JUEZ / ORGANIZADOR',
                          style: pw.TextStyle(
                            font: monoFont,
                            fontSize: 7.5,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#94A3B8'),
                          ),
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: pw.BoxDecoration(
                        color: cardBg,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                        border: pw.Border.all(color: cyanColor, width: 0.8),
                      ),
                      child: pw.Text(
                        'VERIFICACIÓN DIGITAL BEYSCORE · $formattedDate',
                        style: pw.TextStyle(
                          font: monoFont,
                          fontSize: 7.5,
                          fontWeight: pw.FontWeight.bold,
                          color: cyanColor,
                        ),
                      ),
                    ),
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

  /// Imprime o comparte el Acta de Podio en PDF.
  Future<void> printOrSharePodiumReportPdf({
    required BuildContext context,
    required String tournamentName,
    required String tierLabel,
    required String divisionLabel,
    required String championName,
    required String runnerUpName,
    String? thirdPlaceName,
    String? fourthPlaceName,
    List<Map<String, String>> championDeck = const [],
    List<Map<String, String>> runnerUpDeck = const [],
    List<Map<String, String>> thirdPlaceDeck = const [],
    int totalParticipants = 0,
    int totalMatches = 0,
    int totalPoints = 0,
    String? organizerName,
    DateTime? eventDate,
  }) async {
    final pdfBytes = await generatePodiumReportPdf(
      tournamentName: tournamentName,
      tierLabel: tierLabel,
      divisionLabel: divisionLabel,
      championName: championName,
      runnerUpName: runnerUpName,
      thirdPlaceName: thirdPlaceName,
      fourthPlaceName: fourthPlaceName,
      championDeck: championDeck,
      runnerUpDeck: runnerUpDeck,
      thirdPlaceDeck: thirdPlaceDeck,
      totalParticipants: totalParticipants,
      totalMatches: totalMatches,
      totalPoints: totalPoints,
      organizerName: organizerName,
      eventDate: eventDate,
    );

    final cleanFileName =
        'Acta_Podio_${tournamentName.replaceAll(' ', '_')}.pdf';

    await Printing.layoutPdf(
      name: cleanFileName,
      format: PdfPageFormat.a4,
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  }
}
