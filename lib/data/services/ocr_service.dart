// FILE: lib/data/services/ocr_service.dart
// VERZIJA: 5.0 - ČISTI MRZ PARSER
//
// STRATEGIJA:
// 1. STRAŽNJA STRANA → MRZ parsing (ime, prezime, datum, spol, državljanstvo, br.dok)
// 2. STRAŽNJA STRANA → Adresa parsing (izvan MRZ zone)
// 3. PREDNJA STRANA → Mjesto rođenja
//
// MRZ FORMATI:
// - TD1 (ID kartice): 3 linije x 30 znakova
// - TD3 (Putovnice):  2 linije x 44 znaka

import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';

class OCRService {
  static final _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  // ══════════════════════════════════════════════════════════════════════════
  // GLAVNA METODA
  // ══════════════════════════════════════════════════════════════════════════

  /// Skenira sliku i vraća strukturirane podatke
  ///
  /// [imagePath] - putanja do slike
  /// [scanType] - 'back' za stražnju stranu (MRZ), 'front' za prednju
  /// [flipHorizontal] - true ako treba flipati sliku prije OCR-a
  static Future<Map<String, dynamic>> scanDocument({
    required String imagePath,
    required String scanType, // 'back' ili 'front'
    bool flipHorizontal = true,
  }) async {
    try {
      debugPrint('📷 OCR START: $scanType, flip=$flipHorizontal');

      // 1. Flip sliku ako treba
      String processPath = imagePath;
      if (flipHorizontal) {
        processPath = await _flipImage(imagePath);
        debugPrint('🔄 Slika flippana');
      }

      // 2. OCR
      final inputImage = InputImage.fromFilePath(processPath);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      final rawText = recognizedText.text;

      // 3. Debug ispis
      final lines =
          rawText.split('\n').where((l) => l.trim().isNotEmpty).toList();
      debugPrint('📝 OCR RAW (${lines.length} linija):');
      for (int i = 0; i < lines.length && i < 15; i++) {
        debugPrint('   [$i] ${lines[i]}');
      }

      // 4. Parse ovisno o tipu
      Map<String, dynamic> result = {
        'success': false,
        'raw': rawText,
        'lines': lines,
      };

      if (scanType == 'back') {
        result = _parseBackSide(lines, result);
      } else if (scanType == 'front') {
        result = _parseFrontSide(lines, result);
      }

      // 5. Cleanup temp fajla
      if (processPath != imagePath) {
        try {
          await File(processPath).delete();
        } catch (_) {}
      }

      return result;
    } catch (e) {
      debugPrint('❌ OCR ERROR: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FLIP SLIKE
  // ══════════════════════════════════════════════════════════════════════════

  static Future<String> _flipImage(String imagePath) async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final original = frame.image;

      final w = original.width;
      final h = original.height;

      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      canvas.translate(w.toDouble(), 0);
      canvas.scale(-1, 1);
      canvas.drawImage(original, ui.Offset.zero, ui.Paint());

      final picture = recorder.endRecording();
      final flipped = await picture.toImage(w, h);
      final data = await flipped.toByteData(format: ui.ImageByteFormat.png);

      if (data == null) return imagePath;

      final dir = await getTemporaryDirectory();
      final outPath =
          '${dir.path}/flip_${DateTime.now().millisecondsSinceEpoch}.png';
      await File(outPath).writeAsBytes(data.buffer.asUint8List());

      original.dispose();
      flipped.dispose();

      return outPath;
    } catch (e) {
      debugPrint('❌ Flip error: $e');
      return imagePath;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STRAŽNJA STRANA - MRZ + ADRESA
  // ══════════════════════════════════════════════════════════════════════════

  static Map<String, dynamic> _parseBackSide(
      List<String> lines, Map<String, dynamic> result) {
    debugPrint('🔍 Parsing STRAŽNJA STRANA...');

    // Traži MRZ linije (sadrže < znakove)
    List<String> mrzLines = [];
    List<String> nonMrzLines = [];

    for (String line in lines) {
      String cleaned = line.replaceAll(' ', '').replaceAll('«', '<');
      if (cleaned.contains('<') && cleaned.length >= 20) {
        mrzLines.add(cleaned);
      } else {
        nonMrzLines.add(line);
      }
    }

    debugPrint('   MRZ linije: ${mrzLines.length}');
    debugPrint('   Non-MRZ linije: ${nonMrzLines.length}');

    // Parse MRZ
    if (mrzLines.isNotEmpty) {
      result = _parseMRZ(mrzLines, result);
    }

    // Parse adresu iz non-MRZ linija
    result = _parseAddress(nonMrzLines, result);

    // Parse OIB (11 znamenki)
    result = _parseOIB(lines, result);

    result['success'] =
        result['firstName'] != null || result['lastName'] != null;

    _debugResult(result, 'STRAŽNJA');
    return result;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // MRZ PARSER
  // ══════════════════════════════════════════════════════════════════════════

  static Map<String, dynamic> _parseMRZ(
      List<String> mrzLines, Map<String, dynamic> result) {
    debugPrint('   🔍 MRZ parsing (${mrzLines.length} linije)...');

    for (String line in mrzLines) {
      debugPrint('      MRZ: $line');
    }

    // Pronađi liniju s imenima (PREZIME<<IME ili PREZIME<IME)
    for (String line in mrzLines) {
      if (_containsNamePattern(line)) {
        final names = _extractNames(line);
        if (names != null) {
          result['lastName'] = names['lastName'];
          result['firstName'] = names['firstName'];
          debugPrint(
              '   ✓ Imena iz MRZ: ${names['firstName']} ${names['lastName']}');
        }
      }
    }

    // Pronađi liniju s datumima i spolom
    // Format: YYMMDD[check]S[YYMMDD][check][nationality]...
    for (String line in mrzLines) {
      // Datum rođenja: 6 znamenki na početku ili nakon IO/ID prefiksa
      RegExp dobRegex = RegExp(r'(\d{6})\d?([MF])(\d{6})');
      if (dobRegex.hasMatch(line)) {
        var match = dobRegex.firstMatch(line)!;

        // Datum rođenja
        String dobRaw = match.group(1)!;
        result['dateOfBirth'] = _formatMRZDate(dobRaw);
        debugPrint('   ✓ Datum rođenja: ${result['dateOfBirth']}');

        // Spol
        String sex = match.group(2)!;
        result['sex'] = sex == 'M' ? 'M' : 'Ž';
        debugPrint('   ✓ Spol: ${result['sex']}');

        // Datum isteka
        String expRaw = match.group(3)!;
        result['expiryDate'] = _formatMRZDate(expRaw);
      }

      // Državljanstvo (3 slova, obično HRV, DEU, itd.)
      RegExp natRegex = RegExp(r'([A-Z]{3})(?:<|$)');
      if (natRegex.hasMatch(line) && result['nationality'] == null) {
        var match = natRegex.firstMatch(line)!;
        String natCode = match.group(1)!;
        // Ignoriraj ako je dio MRZ padding-a
        if (natCode != 'XXX' && !natCode.contains('<')) {
          result['nationalityCode'] = natCode;
          result['nationality'] = _countryName(natCode);
          debugPrint('   ✓ Državljanstvo: ${result['nationality']} ($natCode)');
        }
      }
    }

    // Broj dokumenta (9 znamenki za HR, ili iz prve MRZ linije)
    for (String line in mrzLines) {
      // TD1 format: IOHRV123456789<<<...
      RegExp docRegex = RegExp(r'[A-Z]{2}[A-Z]{3}(\d{9})');
      if (docRegex.hasMatch(line)) {
        result['documentNumber'] = docRegex.firstMatch(line)!.group(1);
        debugPrint('   ✓ Broj dokumenta: ${result['documentNumber']}');
        break;
      }

      // Alternativno: samo 9 znamenki
      RegExp simpleDocRegex = RegExp(r'(\d{9})');
      if (simpleDocRegex.hasMatch(line) && result['documentNumber'] == null) {
        result['documentNumber'] = simpleDocRegex.firstMatch(line)!.group(1);
        debugPrint('   ✓ Broj dokumenta (alt): ${result['documentNumber']}');
      }
    }

    // Tip dokumenta
    for (String line in mrzLines) {
      if (line.startsWith('P<') || line.startsWith('P0')) {
        result['documentType'] = 'PASSPORT';
        break;
      } else if (line.startsWith('IO') ||
          line.startsWith('ID') ||
          line.startsWith('I<')) {
        result['documentType'] = 'ID_CARD';
        break;
      }
    }

    return result;
  }

  /// Provjera sadrži li linija name pattern (<<)
  static bool _containsNamePattern(String line) {
    // Mora imati << i biti pretežno slova
    if (!line.contains('<<')) return false;

    // Ignoriraj linije koje su samo brojevi i <<
    String withoutBrackets = line.replaceAll('<', '');
    int letters = withoutBrackets.replaceAll(RegExp(r'[^A-Za-z]'), '').length;

    return letters >= 3;
  }

  /// Izvlači imena iz MRZ linije
  static Map<String, String>? _extractNames(String line) {
    // Format: PREZIME<<IME<<<<<< ili PREZIME<C<IME<<<

    // Očisti
    String cleaned = line.toUpperCase().replaceAll('«', '<');

    // Makni prefiks ako postoji (npr. IO, P<, itd.)
    if (RegExp(r'^[A-Z]{1,2}<').hasMatch(cleaned)) {
      cleaned = cleaned.substring(cleaned.indexOf('<') + 1);
    }

    // Nađi << separator
    int separatorIndex = cleaned.indexOf('<<');
    if (separatorIndex == -1) return null;

    // Prezime je prije <<
    String lastName =
        cleaned.substring(0, separatorIndex).replaceAll('<', ' ').trim();

    // Ime je nakon <<
    String rest = cleaned.substring(separatorIndex + 2);
    // Uzmi samo do sljedećih << ili kraja
    int nextSep = rest.indexOf('<<');
    if (nextSep != -1) {
      rest = rest.substring(0, nextSep);
    }
    String firstName = rest.replaceAll('<', ' ').trim();

    // Očisti ne-slova
    lastName = lastName.replaceAll(RegExp(r'[^A-Za-z\s]'), '').trim();
    firstName = firstName.replaceAll(RegExp(r'[^A-Za-z\s]'), '').trim();

    if (lastName.isEmpty || firstName.isEmpty) return null;

    return {
      'lastName': _capitalize(lastName),
      'firstName': _capitalize(firstName),
    };
  }

  /// MRZ datum (YYMMDD) u DD.MM.YYYY
  static String _formatMRZDate(String mrz) {
    if (mrz.length != 6) return '';

    String yy = mrz.substring(0, 2);
    String mm = mrz.substring(2, 4);
    String dd = mrz.substring(4, 6);

    // Godina: 00-30 = 2000+, 31-99 = 1900+
    int year = int.tryParse(yy) ?? 0;
    if (year <= 30) {
      year += 2000;
    } else {
      year += 1900;
    }

    return '$dd.$mm.$year';
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ADRESA PARSER (izvan MRZ zone)
  // ══════════════════════════════════════════════════════════════════════════

  static Map<String, dynamic> _parseAddress(
      List<String> lines, Map<String, dynamic> result) {
    List<String> addressParts = [];

    for (String line in lines) {
      String trimmed = line.trim();

      // Preskoči kratke linije
      if (trimmed.length < 3) continue;

      // Preskoči brojeve (OIB, datumi)
      if (RegExp(r'^\d+$').hasMatch(trimmed)) continue;
      if (RegExp(r'^\d{2}\s*\d{2}\s*\d{4}$').hasMatch(trimmed)) continue;

      // Adresa indikatori
      bool isAddress = trimmed.contains(',') || // "VIR, VIR"
          RegExp(r'[A-Za-z]+\s+[IVX]+\s*\d+')
              .hasMatch(trimmed) || // "SOLDATICA XI 14"
          trimmed.toUpperCase().startsWith('PU ') || // "PU ZADARSKA"
          RegExp(r'^[A-Z\s]+\d+[A-Z]?$', caseSensitive: false)
              .hasMatch(trimmed); // "ULICA 14A"

      if (isAddress && addressParts.length < 3) {
        addressParts.add(trimmed);
      }
    }

    if (addressParts.isNotEmpty) {
      result['address'] = addressParts.join(', ');

      // Izvuci grad iz prve linije (npr. "VIR, VIR" → "Vir")
      String firstPart = addressParts[0];
      if (firstPart.contains(',')) {
        result['residenceCity'] = _capitalize(firstPart.split(',')[0].trim());
      } else {
        result['residenceCity'] = _capitalize(firstPart.split(' ')[0]);
      }

      // Za HR osobnu, država je Hrvatska
      result['residenceCountry'] = 'Hrvatska';

      debugPrint('   ✓ Adresa: ${result['address']}');
      debugPrint('   ✓ Grad: ${result['residenceCity']}');
    }

    return result;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // OIB PARSER
  // ══════════════════════════════════════════════════════════════════════════

  static Map<String, dynamic> _parseOIB(
      List<String> lines, Map<String, dynamic> result) {
    for (String line in lines) {
      RegExp oibRegex = RegExp(r'\b(\d{11})\b');
      if (oibRegex.hasMatch(line)) {
        result['oib'] = oibRegex.firstMatch(line)!.group(1);
        debugPrint('   ✓ OIB: ${result['oib']}');
        break;
      }
    }
    return result;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PREDNJA STRANA - MJESTO ROĐENJA
  // ══════════════════════════════════════════════════════════════════════════

  static Map<String, dynamic> _parseFrontSide(
      List<String> lines, Map<String, dynamic> result) {
    debugPrint('🔍 Parsing PREDNJA STRANA...');

    // Traži mjesto rođenja
    // Na HR osobnoj je format: "ZADAR, HRV" ili samo "ZADAR"

    // Strategija 1: Traži liniju s formatom "GRAD, DRŽAVA"
    for (String line in lines) {
      if (line.contains(',')) {
        List<String> parts = line.split(',').map((p) => p.trim()).toList();
        if (parts.length >= 2) {
          String city = parts[0];
          String country = parts[1];

          // Provjeri da nije adresa (nema brojeva)
          if (!RegExp(r'\d').hasMatch(city) &&
              city.length >= 2 &&
              city.length <= 30) {
            // Provjeri da nije header (REPUBLIKA, CROATIA, itd.)
            if (!_isHeaderWord(city)) {
              result['placeOfBirth'] = _capitalize(city);
              result['countryOfBirth'] = _countryName(country);
              debugPrint('   ✓ Mjesto rođenja: ${result['placeOfBirth']}');
              debugPrint('   ✓ Država rođenja: ${result['countryOfBirth']}');
              result['success'] = true;
              break;
            }
          }
        }
      }
    }

    // Strategija 2: Ako nema zareza, traži poznate gradove
    if (result['placeOfBirth'] == null) {
      final knownCities = [
        'ZAGREB',
        'SPLIT',
        'RIJEKA',
        'OSIJEK',
        'ZADAR',
        'PULA',
        'DUBROVNIK',
        'ŠIBENIK',
        'KARLOVAC',
        'VARAŽDIN',
        'SISAK'
      ];

      for (String line in lines) {
        String upper = line.toUpperCase().trim();
        for (String city in knownCities) {
          if (upper == city ||
              upper.startsWith('$city ') ||
              upper.startsWith('$city,')) {
            result['placeOfBirth'] = _capitalize(city);
            result['countryOfBirth'] = 'Hrvatska';
            result['success'] = true;
            debugPrint(
                '   ✓ Mjesto rođenja (poznati grad): ${result['placeOfBirth']}');
            break;
          }
        }
        if (result['placeOfBirth'] != null) break;
      }
    }

    _debugResult(result, 'PREDNJA');
    return result;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HELPER METODE
  // ══════════════════════════════════════════════════════════════════════════

  static bool _isHeaderWord(String word) {
    final headers = [
      'REPUBLIKA',
      'HRVATSKA',
      'REPUBLIC',
      'CROATIA',
      'OF',
      'OSOBNA',
      'ISKAZNICA',
      'IDENTITY',
      'CARD',
      'PASSPORT',
      'PUTOVNICA',
      'PREZIME',
      'SURNAME',
      'IME',
      'NAME',
      'GIVEN'
    ];
    return headers.contains(word.toUpperCase());
  }

  static String _capitalize(String text) {
    if (text.isEmpty) return '';
    text = text.toLowerCase().trim();
    return text
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  static String _countryName(String code) {
    const countries = {
      'HRV': 'Hrvatska',
      'HR': 'Hrvatska',
      'DEU': 'Njemačka',
      'DE': 'Njemačka',
      'AUT': 'Austrija',
      'AT': 'Austrija',
      'ITA': 'Italija',
      'IT': 'Italija',
      'SVN': 'Slovenija',
      'SI': 'Slovenija',
      'HUN': 'Mađarska',
      'HU': 'Mađarska',
      'CZE': 'Češka',
      'CZ': 'Češka',
      'POL': 'Poljska',
      'PL': 'Poljska',
      'GBR': 'Velika Britanija',
      'GB': 'Velika Britanija',
      'FRA': 'Francuska',
      'FR': 'Francuska',
      'USA': 'SAD',
      'US': 'SAD',
      'SRB': 'Srbija',
      'RS': 'Srbija',
      'BIH': 'BiH',
      'BA': 'BiH',
    };

    String upper = code.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    return countries[upper] ?? _capitalize(code);
  }

  static void _debugResult(Map<String, dynamic> result, String side) {
    debugPrint('═══════════════════════════════════════');
    debugPrint('📋 REZULTAT ($side):');
    result.forEach((key, value) {
      if (key != 'raw' && key != 'lines' && value != null) {
        debugPrint('   $key: $value');
      }
    });
    debugPrint('═══════════════════════════════════════');
  }

  /// Zatvori recognizer
  static void close() {
    _textRecognizer.close();
  }
}
