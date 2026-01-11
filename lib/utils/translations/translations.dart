// FILE: lib/utils/translations/translations.dart
// VERZIJA: 4.1 - FIXED STATIC ACCESS
// DATUM: 2026-01-11

import 'lang_en.dart';
import 'lang_hr.dart';
import 'lang_de.dart';
import 'lang_it.dart';
import 'lang_es.dart';
import 'lang_fr.dart';
import 'lang_pl.dart';
import 'lang_cs.dart';
import 'lang_sk.dart';
import 'lang_sl.dart';
import 'lang_hu.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// TRANSLATIONS SERVICE
/// Centralized translation management for VillaOS
/// Supports: EN, HR, DE, IT, ES, FR, PL, CS, SK, SL, HU (11 languages)
/// ═══════════════════════════════════════════════════════════════════════════
class Translations {
  // ─────────────────────────────────────────────────────────────────────────
  // SINGLETON PATTERN
  // ─────────────────────────────────────────────────────────────────────────
  static final Translations _instance = Translations._internal();
  factory Translations() => _instance;
  Translations._internal();

  // ─────────────────────────────────────────────────────────────────────────
  // STATE
  // ─────────────────────────────────────────────────────────────────────────
  String _currentLanguage = 'en';

  // ─────────────────────────────────────────────────────────────────────────
  // ALL TRANSLATIONS MAP - 11 LANGUAGES
  // ─────────────────────────────────────────────────────────────────────────
  static final Map<String, Map<String, String>> _allTranslations = {
    'en': enTranslations,
    'hr': hrTranslations,
    'de': deTranslations,
    'it': itTranslations,
    'es': esTranslations,
    'fr': frTranslations,
    'pl': plTranslations,
    'cs': csTranslations,
    'sk': skTranslations,
    'sl': slTranslations,
    'hu': huTranslations,
  };

  // ─────────────────────────────────────────────────────────────────────────
  // SUPPORTED LANGUAGES WITH METADATA
  // ─────────────────────────────────────────────────────────────────────────
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
    {'code': 'hr', 'name': 'Hrvatski', 'flag': '🇭🇷'},
    {'code': 'de', 'name': 'Deutsch', 'flag': '🇩🇪'},
    {'code': 'it', 'name': 'Italiano', 'flag': '🇮🇹'},
    {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
    {'code': 'pl', 'name': 'Polski', 'flag': '🇵🇱'},
    {'code': 'cs', 'name': 'Čeština', 'flag': '🇨🇿'},
    {'code': 'sk', 'name': 'Slovenčina', 'flag': '🇸🇰'},
    {'code': 'sl', 'name': 'Slovenščina', 'flag': '🇸🇮'},
    {'code': 'hu', 'name': 'Magyar', 'flag': '🇭🇺'},
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // GETTERS
  // ─────────────────────────────────────────────────────────────────────────
  String get currentLanguage => _currentLanguage;

  static String get current => _instance._currentLanguage;

  Map<String, String> get currentTranslations =>
      _allTranslations[_currentLanguage] ?? _allTranslations['en']!;

  static List<String> get availableLanguageCodes =>
      _allTranslations.keys.toList();

  // ─────────────────────────────────────────────────────────────────────────
  // LANGUAGE MANAGEMENT - STATIC
  // ─────────────────────────────────────────────────────────────────────────
  static void setLanguage(String languageCode) {
    if (_allTranslations.containsKey(languageCode)) {
      _instance._currentLanguage = languageCode;
    } else {
      _instance._currentLanguage = 'en'; // Fallback
    }
  }

  static bool isLanguageSupported(String languageCode) {
    return _allTranslations.containsKey(languageCode);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TRANSLATION LOOKUP - STATIC METHODS (MAIN API)
  // ─────────────────────────────────────────────────────────────────────────

  /// Main translation method - STATIC
  /// Example: Translations.t('hello_name', {'name': 'John'}) -> "Hello John!"
  static String t(String key, [Map<String, String>? params]) {
    final translations =
        _allTranslations[_instance._currentLanguage] ?? _allTranslations['en']!;

    String text = translations[key] ?? _allTranslations['en']?[key] ?? key;

    // Parameter substitution
    if (params != null) {
      params.forEach((paramKey, value) {
        text = text.replaceAll('{$paramKey}', value);
      });
    }

    return text;
  }

  /// Translation for specific language - STATIC
  /// Example: Translations.tp('welcome', 'de') -> "Willkommen"
  static String tp(String key, String languageCode,
      [Map<String, String>? params]) {
    final translations =
        _allTranslations[languageCode] ?? _allTranslations['en']!;
    String text = translations[key] ?? _allTranslations['en']?[key] ?? key;

    if (params != null) {
      params.forEach((paramKey, value) {
        text = text.replaceAll('{$paramKey}', value);
      });
    }

    return text;
  }

  /// Alias for tp
  static String tFor(String key, String languageCode,
      [Map<String, String>? params]) {
    return tp(key, languageCode, params);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UTILITY METHODS - STATIC
  // ─────────────────────────────────────────────────────────────────────────

  /// Get language metadata by code
  static Map<String, String>? getLanguageInfo(String code) {
    try {
      return supportedLanguages.firstWhere((lang) => lang['code'] == code);
    } catch (_) {
      return null;
    }
  }

  /// Get flag emoji for language code
  static String getFlag(String code) {
    return getLanguageInfo(code)?['flag'] ?? '🏳️';
  }

  /// Get native name for language code
  static String getNativeName(String code) {
    return getLanguageInfo(code)?['name'] ?? code.toUpperCase();
  }

  /// Check if key exists in current language
  static bool hasKey(String key) {
    final translations =
        _allTranslations[_instance._currentLanguage] ?? _allTranslations['en']!;
    return translations.containsKey(key);
  }

  /// Get all keys (useful for debugging)
  static List<String> getAllKeys() {
    final translations =
        _allTranslations[_instance._currentLanguage] ?? _allTranslations['en']!;
    return translations.keys.toList();
  }

  /// Get translation count for current language
  static int get translationCount {
    final translations =
        _allTranslations[_instance._currentLanguage] ?? _allTranslations['en']!;
    return translations.length;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// GLOBAL SHORTCUT FUNCTION
// ═══════════════════════════════════════════════════════════════════════════

/// Global translation function for easy access
/// Usage: tr('welcome_title') or tr('hello_name', {'name': 'John'})
String tr(String key, [Map<String, String>? params]) {
  return Translations.t(key, params);
}
