// FILE: lib/data/services/checkin_validator.dart
// OPIS: Validacija guest podataka za check-in
// VERZIJA: 1.1 - POPRAVLJEN IMPORT
// DATUM: 2026-01-10

import 'package:flutter/material.dart';
import 'sentry_service.dart';

/// Rezultat validacije
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  final double completionScore;

  ValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
    this.completionScore = 0.0,
  });

  bool get hasWarnings => warnings.isNotEmpty;
}

/// Validator za check-in podatke
class CheckInValidator {
  // ============================================================
  // REQUIRED FIELDS (bez ovih ne može proći)
  // ============================================================

  static const List<String> _requiredFields = [
    'firstName',
    'lastName',
    'documentNumber',
  ];

  // ============================================================
  // RECOMMENDED FIELDS (warnings ako nedostaju)
  // ============================================================

  static const List<String> _recommendedFields = [
    'dateOfBirth',
    'nationality',
    'address',
  ];

  // ============================================================
  // CROATIAN SPECIFIC
  // ============================================================

  static const List<String> _croatianRequiredFields = [
    'oib', // OIB obavezan za HR goste
  ];

  // ============================================================
  // MAIN VALIDATION
  // ============================================================

  /// Validira podatke jednog gosta
  static ValidationResult validateGuest(
    Map<String, dynamic> guestData, {
    String? countryCode,
    int? guestNumber,
  }) {
    final errors = <String>[];
    final warnings = <String>[];
    int filledRequired = 0;
    int totalRequired = _requiredFields.length;

    // 1. Check required fields
    for (final field in _requiredFields) {
      final value = guestData[field]?.toString().trim() ?? '';
      if (value.isEmpty) {
        errors.add(_getFieldDisplayName(field));
      } else {
        filledRequired++;
      }
    }

    // 2. Check recommended fields
    for (final field in _recommendedFields) {
      final value = guestData[field]?.toString().trim() ?? '';
      if (value.isEmpty) {
        warnings.add('${_getFieldDisplayName(field)} nije popunjen');
      }
    }

    // 3. Croatian specific validation
    if (countryCode == 'HR') {
      totalRequired += _croatianRequiredFields.length;
      for (final field in _croatianRequiredFields) {
        final value = guestData[field]?.toString().trim() ?? '';
        if (value.isEmpty) {
          errors.add(_getFieldDisplayName(field));
        } else {
          filledRequired++;
          // Validate OIB format
          if (field == 'oib' && !_isValidOIB(value)) {
            errors.add('OIB nije ispravan (mora biti 11 znamenki)');
          }
        }
      }
    }

    // 4. Format validations
    final dateOfBirth = guestData['dateOfBirth']?.toString().trim() ?? '';
    if (dateOfBirth.isNotEmpty && !_isValidDateFormat(dateOfBirth)) {
      warnings.add('Datum rođenja možda nije u ispravnom formatu');
    }

    final docNumber = guestData['documentNumber']?.toString().trim() ?? '';
    if (docNumber.isNotEmpty && docNumber.length < 5) {
      warnings.add('Broj dokumenta izgleda prekratak');
    }

    // Calculate completion score
    final completionScore =
        totalRequired > 0 ? filledRequired / totalRequired : 0.0;

    final isValid = errors.isEmpty;

    // Log to Sentry
    SentryService.logGuestValidation(
      guestNumber: guestNumber ?? 0,
      isValid: isValid,
      missingFields: errors.isNotEmpty ? errors : null,
    );

    return ValidationResult(
      isValid: isValid,
      errors: errors,
      warnings: warnings,
      completionScore: completionScore,
    );
  }

  /// Validira sve goste odjednom
  static ValidationResult validateAllGuests(
    List<Map<String, dynamic>> guests, {
    String? countryCode,
  }) {
    final allErrors = <String>[];
    final allWarnings = <String>[];
    double totalScore = 0;

    for (int i = 0; i < guests.length; i++) {
      final result = validateGuest(
        guests[i],
        countryCode: countryCode,
        guestNumber: i + 1,
      );

      if (!result.isValid) {
        allErrors.add('Gost ${i + 1}: ${result.errors.join(", ")}');
      }

      if (result.hasWarnings) {
        allWarnings.addAll(result.warnings.map((w) => 'Gost ${i + 1}: $w'));
      }

      totalScore += result.completionScore;
    }

    final avgScore = guests.isNotEmpty ? totalScore / guests.length : 0.0;

    return ValidationResult(
      isValid: allErrors.isEmpty,
      errors: allErrors,
      warnings: allWarnings,
      completionScore: avgScore,
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  static String _getFieldDisplayName(String field) {
    const names = {
      'firstName': 'Ime',
      'lastName': 'Prezime',
      'documentNumber': 'Broj dokumenta',
      'dateOfBirth': 'Datum rođenja',
      'nationality': 'Državljanstvo',
      'address': 'Adresa',
      'oib': 'OIB',
      'sex': 'Spol',
      'documentType': 'Vrsta dokumenta',
    };
    return names[field] ?? field;
  }

  static bool _isValidOIB(String oib) {
    // OIB mora biti točno 11 znamenki
    if (oib.length != 11) return false;
    if (!RegExp(r'^\d{11}$').hasMatch(oib)) return false;

    // Kontrolna znamenka (Mod 11, 10)
    try {
      int remainder = 10;
      for (int i = 0; i < 10; i++) {
        int digit = int.parse(oib[i]);
        remainder = (remainder + digit) % 10;
        if (remainder == 0) remainder = 10;
        remainder = (remainder * 2) % 11;
      }
      int controlDigit = 11 - remainder;
      if (controlDigit == 10) controlDigit = 0;

      return controlDigit == int.parse(oib[10]);
    } catch (e) {
      return false;
    }
  }

  static bool _isValidDateFormat(String date) {
    // Prihvati razne formate
    final patterns = [
      RegExp(r'^\d{2}\.\d{2}\.\d{4}$'), // DD.MM.YYYY
      RegExp(r'^\d{2}/\d{2}/\d{4}$'), // DD/MM/YYYY
      RegExp(r'^\d{4}-\d{2}-\d{2}$'), // YYYY-MM-DD
      RegExp(r'^\d{2}\d{2}\d{4}$'), // DDMMYYYY
    ];

    return patterns.any((p) => p.hasMatch(date));
  }
}

// ============================================================
// VALIDATION DIALOG
// ============================================================

/// Prikaži validation errors dialog
Future<bool> showValidationDialog(
  BuildContext context, {
  required ValidationResult result,
  String? title,
  bool allowContinue = false,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            result.isValid ? Icons.warning_amber : Icons.error_outline,
            color: result.isValid ? Colors.orange : Colors.red,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            title ?? (result.isValid ? 'Upozorenje' : 'Nedostaju podaci'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Errors
          if (result.errors.isNotEmpty) ...[
            const Text(
              'Obavezna polja koja nedostaju:',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            ...result.errors.map((e) => Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.close, color: Colors.red, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          e,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
          ],

          // Warnings
          if (result.warnings.isNotEmpty) ...[
            const Text(
              'Preporučena polja:',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            ...result.warnings.take(5).map((w) => Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber,
                          color: Colors.orange, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          w,
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                )),
            if (result.warnings.length > 5)
              Text(
                '... i još ${result.warnings.length - 5}',
                style: TextStyle(color: Colors.grey[600], fontSize: 11),
              ),
          ],

          // Completion score
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: result.completionScore,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation(
              result.completionScore >= 0.8
                  ? Colors.green
                  : result.completionScore >= 0.5
                      ? Colors.orange
                      : Colors.red,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(result.completionScore * 100).toInt()}% popunjeno',
            style: TextStyle(color: Colors.grey[500], fontSize: 11),
          ),
        ],
      ),
      actions: [
        if (!result.isValid)
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'ISPRAVI',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        if (result.isValid || allowContinue)
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  result.isValid ? const Color(0xFFD4AF37) : Colors.orange,
              foregroundColor: Colors.black,
            ),
            child: Text(
              result.isValid ? 'NASTAVI' : 'NASTAVI SVEJEDNO',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
      ],
    ),
  );

  return confirmed ?? false;
}
