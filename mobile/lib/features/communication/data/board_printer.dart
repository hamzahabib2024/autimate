import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../domain/aac_catalog.dart';
import '../domain/custom_card_repository.dart';
import '../domain/sentence_realiser.dart';
import '../domain/symbol_scale.dart';

/// Builds a printable paper copy of the AAC board.
///
/// **Why paper matters here.** A device dies, is left at school, or is taken
/// away for charging, and in that moment a child loses their words entirely.
/// A laminated sheet in a bag does not run out of battery. Teachers ask for
/// this constantly, and it is the cheapest redundancy available.
///
/// The printed board keeps the **same layout and the same word-class colour
/// coding** as the screen. That is the whole value: a child who learned where
/// "help" sits on the tablet finds it in the same place on paper. A prettier
/// print layout that reorganised the cards would be actively harmful.
class BoardPrinter {
  const BoardPrinter();

  /// Fitzgerald-key colours as PDF colours, matched to `AppPalette`.
  ///
  /// Duplicated deliberately rather than read from the theme: the theme is a
  /// Flutter construct and this runs in the PDF layer, and a print that
  /// silently followed dark mode would waste a cartridge.
  static const Map<String, PdfColor> _wordClassColors = {
    'carrier': PdfColor.fromInt(0xFF9A4265),
    'people': PdfColor.fromInt(0xFF8A6E10),
    'verb': PdfColor.fromInt(0xFF3F7A46),
    'descriptor': PdfColor.fromInt(0xFF2F6BA8),
    'noun': PdfColor.fromInt(0xFFA8551F),
    'need': PdfColor.fromInt(0xFF9A4265),
  };

  static String wordClassOf(AacCard card) {
    if (card.category == null) return 'carrier';
    return switch (card.grammar.pos) {
      PartOfSpeech.verb => 'verb',
      PartOfSpeech.adjective => 'descriptor',
      PartOfSpeech.pronoun || PartOfSpeech.carrier => 'carrier',
      _ => switch (card.category!) {
        AacCategory.people => 'people',
        AacCategory.activities => 'verb',
        AacCategory.emotions => 'descriptor',
        AacCategory.needs => 'need',
        _ => 'noun',
      },
    };
  }

  /// Renders the board to PDF bytes.
  ///
  /// [shape] fixes the grid so the paper matches the screen; `flowing` falls
  /// back to a sensible four-across, because a printed page cannot scroll.
  Future<List<int>> build({
    required List<AacCard> deck,
    required Map<String, CustomCard> customCards,
    required AppLanguage language,
    GridShape shape = GridShape.fourByThree,
    String childName = '',
  }) async {
    final document = pw.Document();

    // A font that can draw Urdu. Without it every Urdu label prints as
    // boxes, which would make the feature useless for half its users.
    pw.Font? urduFont;
    if (language == AppLanguage.ur) {
      try {
        final data = await rootBundle.load(
          'assets/fonts/NotoNastaliqUrdu[wght].ttf',
        );
        urduFont = pw.Font.ttf(data);
      } catch (_) {
        // Fall through to the default font; English labels still print.
        urduFont = null;
      }
    }

    final columns = shape.isFixed ? shape.columns : 4;
    final perPage = shape.isFixed ? shape.capacity : 20;

    for (var start = 0; start < deck.length; start += perPage) {
      final page = deck.skip(start).take(perPage).toList();
      document.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                childName.isEmpty
                    ? 'AutiMate communication board'
                    : '$childName — communication board',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Expanded(
                child: pw.GridView(
                  crossAxisCount: columns,
                  childAspectRatio: 1.0,
                  children: [
                    for (final card in page)
                      _cell(card, customCards, language, urduFont),
                  ],
                ),
              ),
              pw.SizedBox(height: 6),
              // The legend is what makes the colour coding teachable to a
              // teacher who has never seen the app.
              _legend(),
            ],
          ),
        ),
      );
    }
    return document.save();
  }

  pw.Widget _cell(
    AacCard card,
    Map<String, CustomCard> customCards,
    AppLanguage language,
    pw.Font? urduFont,
  ) {
    final colour =
        _wordClassColors[wordClassOf(card)] ?? PdfColors.grey700;
    final custom = customCards[card.id];
    final primary = language == AppLanguage.ur
        ? card.grammar.labelUr
        : card.grammar.labelEn;
    final secondary = language == AppLanguage.ur
        ? card.grammar.labelEn
        : card.grammar.labelUr;

    return pw.Container(
      margin: const pw.EdgeInsets.all(3),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: colour, width: 1.5),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        children: [
          // The word-class band, exactly as on screen.
          pw.Container(height: 6, color: colour),
          pw.Expanded(
            child: pw.Center(
              child: custom?.imagePath != null
                  ? _image(custom!.imagePath!)
                  : pw.Text(
                      // Material glyphs cannot be embedded here, so the
                      // printed cell carries a large word instead. Honest,
                      // and still findable in the same position.
                      primary,
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                        font: language == AppLanguage.ur ? urduFont : null,
                      ),
                    ),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Text(
              secondary,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                fontSize: 8,
                color: PdfColors.grey700,
                font: language == AppLanguage.ur ? null : urduFont,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _image(String path) {
    try {
      final bytes = File(path).readAsBytesSync();
      return pw.Image(pw.MemoryImage(bytes), fit: pw.BoxFit.contain);
    } catch (_) {
      return pw.SizedBox();
    }
  }

  pw.Widget _legend() => pw.Row(
    children: [
      for (final entry in _wordClassColors.entries)
        pw.Padding(
          padding: const pw.EdgeInsets.only(right: 10),
          child: pw.Row(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Container(width: 8, height: 8, color: entry.value),
              pw.SizedBox(width: 3),
              pw.Text(
                entry.key,
                style: const pw.TextStyle(fontSize: 7),
              ),
            ],
          ),
        ),
    ],
  );

  /// Hands the PDF to the platform print or share sheet.
  Future<void> present(List<int> bytes, {String name = 'board.pdf'}) async {
    await Printing.sharePdf(
      bytes: bytes is Uint8List ? bytes : Uint8List.fromList(bytes),
      filename: name,
    );
  }
}
