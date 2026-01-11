# Vesta Lumina - Tablet Terminal

[![Version](https://img.shields.io/badge/version-3.0.0-blue.svg)](https://github.com/nroxa92/tablet_terminal)
[![Platform](https://img.shields.io/badge/platform-Android-green.svg)](https://developer.android.com)
[![Flutter](https://img.shields.io/badge/Flutter-3.32+-02569B.svg)](https://flutter.dev)
[![License](https://img.shields.io/badge/license-Proprietary-red.svg)](LICENSE)

> **Guest Self-Service Kiosk Terminal for Short-Term Rental Properties**

---

## ⚠️ PROPRIETARY LICENSE - STRICTLY ENFORCED

```
Copyright © 2024-2026 Neven Roksa. All Rights Reserved.

This repository is PUBLIC FOR PORTFOLIO DEMONSTRATION ONLY.

STRICTLY PROHIBITED:
• Copying, cloning, forking, or downloading this code
• Reverse engineering or decompiling
• Commercial use of any kind
• Use for AI/ML model training
• Any unauthorized distribution

LEGAL CONSEQUENCES:
• DMCA takedown notices
• Cease and desist orders  
• Civil litigation for damages
• Criminal prosecution where applicable

Contact: nevenroksa@gmail.com | GitHub: @nroxa92
```

---

## Sažetak

Tablet Terminal je Android kiosk aplikacija za samoposlužnu prijavu gostiju u kratkoročnom iznajmljivanju. Aplikacija omogućuje OCR skeniranje osobnih dokumenata, digitalno potpisivanje kućnog reda, AI chatbot asistenta te višejezičnu podršku. Dizajnirana je za rad u kiosk modu na tablet uređajima postavljenim u smještajnim jedinicama.

## Pregled Sustava

```
┌─────────────────────────────────────────────────────────────────┐
│                    VESTA LUMINA SUSTAV                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────┐         ┌──────────────┐                     │
│  │ Admin Panel  │◄───────►│   Firebase   │◄───────►┌──────────┐│
│  │  (Flutter    │         │  (Firestore, │         │ Tablet   ││
│  │   Web App)   │         │   Auth,      │         │ Terminal ││
│  │              │         │   Storage,   │         │ (Android)││
│  │  MASTER      │         │   Functions) │         │ SLAVE    ││
│  └──────────────┘         └──────────────┘         └──────────┘│
│        │                        │                       │       │
│        │   Definira sadržaj     │   Sinkronizacija     │       │
│        │   postavke, pravila    │   u realnom vremenu  │       │
│        └────────────────────────┴───────────────────────┘       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Arhitektura Master-Slave

| Komponenta | Uloga | Funkcija |
|------------|-------|----------|
| **Admin Panel** | MASTER | Definira kućna pravila, AI bazu znanja, postavke, screensaver slike |
| **Tablet Terminal** | SLAVE | Prikazuje sadržaj, skenira dokumente, šalje podatke natrag |
| **Firebase** | SYNC | Firestore (podaci), Auth (autentifikacija), Storage (mediji), Functions (logika) |

## Upute za Korištenje

### Za Vlasnike Smještaja

1. **Postavljanje Tableta**
   - Instalirajte aplikaciju na Android tablet (min. 10" zaslon, Android 8.0+)
   - Povežite tablet na WiFi mrežu
   - Pokrenite aplikaciju i unesite pristupni kod iz Admin Panela

2. **Konfiguracija u Admin Panelu**
   - Definirajte kućna pravila za svaku smještajnu jedinicu
   - Postavite AI bazu znanja s odgovorima na česta pitanja
   - Učitajte screensaver slike

3. **Svakodnevno Korištenje**
   - Tablet automatski prikazuje screensaver kada nije u upotrebi
   - Gosti koriste tablet za self-check-in
   - Svi podaci se automatski sinkroniziraju s Admin Panelom

### Za Goste

1. Dodirnite zaslon za početak prijave
2. Unesite referentni broj rezervacije
3. Skenirajte osobni dokument (putovnica/osobna iskaznica)
4. Pregledajte i potvrdite svoje podatke
5. Pročitajte i digitalno potpišite kućna pravila
6. Pristupite WiFi podacima i korisnim informacijama

---

## Technical Documentation

### Project Statistics

| Metric | Value |
|--------|-------|
| **Total Dart Code** | ~12,500 lines |
| **Total Files** | 55+ |
| **Screens** | 17 |
| **Services** | 16 |
| **Widgets** | 6 |
| **Models** | 4 |
| **Languages Supported** | 11 |
| **Minimum Android** | 8.0 (API 26) |

### Project Structure

```
tablet_terminal/
├── android/                    # Android native configuration
│   ├── app/
│   │   ├── build.gradle       # App-level build config
│   │   └── src/main/
│   │       ├── AndroidManifest.xml
│   │       └── kotlin/        # Native Kotlin code
│   └── build.gradle           # Project-level build config
├── lib/
│   ├── main.dart              # Application entry point
│   ├── firebase_options.dart  # Firebase configuration
│   ├── models/                # Data models
│   │   ├── booking_model.dart
│   │   ├── guest_model.dart
│   │   ├── house_rules_model.dart
│   │   └── unit_model.dart
│   ├── screens/               # UI screens (17 total)
│   │   ├── splash_screen.dart
│   │   ├── pairing_screen.dart
│   │   ├── screensaver_screen.dart
│   │   ├── welcome_screen.dart
│   │   ├── booking_lookup_screen.dart
│   │   ├── guest_count_screen.dart
│   │   ├── document_scan_screen.dart
│   │   ├── manual_entry_screen.dart
│   │   ├── guest_confirmation_screen.dart
│   │   ├── additional_guest_screen.dart
│   │   ├── house_rules_screen.dart
│   │   ├── signature_screen.dart
│   │   ├── checkin_success_screen.dart
│   │   ├── wifi_info_screen.dart
│   │   ├── chatbot_screen.dart
│   │   ├── feedback_screen.dart
│   │   └── cleaner_screen.dart
│   ├── services/              # Business logic (16 total)
│   │   ├── firebase_service.dart
│   │   ├── auth_service.dart
│   │   ├── pairing_service.dart
│   │   ├── booking_service.dart
│   │   ├── checkin_service.dart
│   │   ├── ocr_service.dart
│   │   ├── document_parser_service.dart
│   │   ├── signature_service.dart
│   │   ├── house_rules_service.dart
│   │   ├── screensaver_service.dart
│   │   ├── wifi_service.dart
│   │   ├── chatbot_service.dart
│   │   ├── feedback_service.dart
│   │   ├── cleaner_service.dart
│   │   ├── offline_service.dart
│   │   └── analytics_service.dart
│   ├── widgets/               # Reusable components
│   │   ├── custom_button.dart
│   │   ├── loading_overlay.dart
│   │   ├── language_selector.dart
│   │   ├── keyboard_widget.dart
│   │   ├── signature_pad.dart
│   │   └── chat_bubble.dart
│   ├── utils/                 # Utilities
│   │   ├── constants.dart
│   │   ├── validators.dart
│   │   └── formatters.dart
│   └── l10n/                  # Localization
│       ├── app_en.arb
│       ├── app_hr.arb
│       ├── app_de.arb
│       ├── app_it.arb
│       ├── app_sl.arb
│       ├── app_fr.arb
│       ├── app_es.arb
│       ├── app_pt.arb
│       ├── app_nl.arb
│       ├── app_pl.arb
│       └── app_cs.arb
├── assets/
│   ├── images/
│   ├── fonts/
│   └── animations/
├── pubspec.yaml               # Dependencies
└── LICENSE                    # Proprietary license
```

### Core Features

#### 1. OCR Document Scanning
```dart
// Supported document types
- EU ID Cards (all member states)
- Passports (MRZ zone reading)
- Driving Licenses (EU format)

// ML Kit integration
- Real-time text recognition
- Automatic field extraction
- Multi-language support
```

#### 2. Kiosk Mode
```dart
// Android kiosk mode features
- Lock Task Mode (COSU)
- Disable navigation buttons
- Prevent screen timeout
- Auto-restart on crash
- OTA updates support
```

#### 3. Check-in Flow
```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  Screensaver │───►│   Welcome   │───►│   Booking   │
│   (idle)     │    │   Screen    │    │   Lookup    │
└─────────────┘    └─────────────┘    └──────┬──────┘
                                              │
                                              ▼
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Success   │◄───│  Signature  │◄───│   House     │
│   Screen    │    │   Screen    │    │   Rules     │
└─────────────┘    └─────────────┘    └──────┬──────┘
                                              │
                                              ▲
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  Additional │◄───│   Guest     │◄───│  Document   │
│   Guests    │    │   Confirm   │    │   Scan/OCR  │
└─────────────┘    └─────────────┘    └─────────────┘
```

#### 4. AI Chatbot
- Powered by OpenAI GPT-4
- Property-specific knowledge base
- Multi-language conversations
- Offline fallback responses

#### 5. Cleaner Mode
- PIN-protected access
- Digital cleaning checklists
- Photo documentation
- Issue reporting
- Completion confirmation

### Technology Stack

| Category | Technology |
|----------|------------|
| **Framework** | Flutter 3.32+ |
| **Language** | Dart 3.5+ |
| **State Management** | Provider + Riverpod |
| **Local Database** | Hive |
| **Cloud Backend** | Firebase Suite |
| **OCR Engine** | Google ML Kit |
| **AI/Chat** | OpenAI API |
| **Monitoring** | Sentry |
| **Analytics** | Firebase Analytics |

### Firebase Integration

```dart
// Firestore Collections accessed
owners/{ownerId}/
  ├── settings              // Terminal configuration
  ├── units/{unitId}/       // Property units
  │   ├── bookings/{bookingId}/
  │   │   └── guests[]      // Guest array (not subcollection)
  │   ├── house_rules       // Rules document
  │   └── ai_knowledge      // Chatbot knowledge base
  └── cleaning_logs/{logId} // Cleaning records
```

### Data Flow

#### From Admin Panel → Tablet
- House rules content
- AI knowledge base
- WiFi credentials
- Screensaver images
- Cleaning checklists
- Owner contact info

#### From Tablet → Admin Panel
- Scanned guest data (OCR)
- Digital signatures (PNG)
- Cleaning completion logs
- AI chat transcripts
- Guest feedback
- Error reports

### Security Model

| Layer | Implementation |
|-------|----------------|
| **Authentication** | Firebase Auth (anonymous + custom tokens) |
| **Authorization** | Firestore Security Rules |
| **Data Encryption** | TLS 1.3 in transit, AES-256 at rest |
| **Local Storage** | Encrypted Hive boxes |
| **Kiosk Security** | Android Device Owner mode |
| **GDPR Compliance** | Auto-delete after checkout |

### Localization

| Language | Code | Status |
|----------|------|--------|
| English | `en` | ✅ Complete |
| Croatian | `hr` | ✅ Complete |
| German | `de` | ✅ Complete |
| Italian | `it` | ✅ Complete |
| Slovenian | `sl` | ✅ Complete |
| French | `fr` | ✅ Complete |
| Spanish | `es` | ✅ Complete |
| Portuguese | `pt` | ✅ Complete |
| Dutch | `nl` | ✅ Complete |
| Polish | `pl` | ✅ Complete |
| Czech | `cs` | ✅ Complete |

### Minimum Requirements

| Requirement | Specification |
|-------------|---------------|
| **Android Version** | 8.0 (API 26)+ |
| **Screen Size** | 10" minimum |
| **RAM** | 2GB+ |
| **Storage** | 500MB free |
| **Camera** | 5MP+ (for OCR) |
| **Connectivity** | WiFi (offline mode available) |

### Offline Capabilities

```dart
// Offline-first architecture
- Hive local database for caching
- Queue system for pending syncs
- Automatic retry on reconnection
- Graceful degradation of features
- Offline AI responses (FAQ-based)
```

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 3.0.0 | 2026-01 | Multi-guest support, enhanced OCR |
| 2.5.0 | 2025-11 | AI chatbot integration |
| 2.0.0 | 2025-09 | Cleaner mode, offline support |
| 1.5.0 | 2025-07 | Signature capture, house rules |
| 1.0.0 | 2025-05 | Initial release |

---

## Related Components

| Component | Repository | Description |
|-----------|------------|-------------|
| **Admin Panel** | [admin_panel](https://github.com/nroxa92/admin_panel) | Owner management dashboard |
| **Documentation** | This README | Technical documentation |

---

## Contact

**Developer:** Neven Roksa  
**Email:** nevenroksa@gmail.com  
**GitHub:** [@nroxa92](https://github.com/nroxa92)

---

<p align="center">
  <strong>Vesta Lumina System</strong><br>
  <em>Transforming Guest Experience in Short-Term Rentals</em><br><br>
  © 2024-2026 Neven Roksa. All Rights Reserved.
</p>
