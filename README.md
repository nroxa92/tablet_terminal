# 📱 Vesta Lumina Client Terminal

> **Tablet Kiosk Application for Guest Check-in**
> **Part of Vesta Lumina System**

[![License](https://img.shields.io/badge/License-Proprietary-red.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.2+-blue.svg)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Backend-orange.svg)](https://firebase.google.com)
[![Version](https://img.shields.io/badge/Version-0.0.9-blue.svg)]()
[![Status](https://img.shields.io/badge/Status-Beta-yellow.svg)]()

---

## ⚠️ PRAVNA NAPOMENA / LEGAL NOTICE

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                                                                               ║
║                    ⚖️  VLASNIČKI SOFTVER / PROPRIETARY SOFTWARE  ⚖️            ║
║                                                                               ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║  🇭🇷 HRVATSKI:                                                                 ║
║  Ovaj softver je PRIVATNO VLASNIŠTVO i zaštićen zakonima o autorskim         ║
║  pravima. Repozitorij je javno vidljiv ISKLJUČIVO u svrhu demonstracije.     ║
║                                                                               ║
║  🇬🇧 ENGLISH:                                                                  ║
║  This software is PROPRIETARY and protected by copyright law.                ║
║  Repository is publicly visible FOR DEMONSTRATION PURPOSES ONLY.             ║
║                                                                               ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║  🔒 STROGO ZABRANJENO / STRICTLY PROHIBITED:                                  ║
║                                                                               ║
║     ❌ Kopiranje, kloniranje ili preuzimanje koda                             ║
║     ❌ Reverse engineering ili dekompilacija                                  ║
║     ❌ Korištenje u komercijalne ili osobne svrhe                             ║
║     ❌ Distribucija ili dijeljenje bilo kojeg dijela                          ║
║     ❌ Kreiranje izvedenih djela                                              ║
║     ❌ Korištenje za AI/ML treniranje                                         ║
║                                                                               ║
║  ⚖️ PRAVNE POSLJEDICE:                                                        ║
║     Neovlašteno korištenje podliježe građanskoj i kaznenoj odgovornosti      ║
║     prema međunarodnim zakonima o autorskim pravima (DMCA, Bern Convention). ║
║                                                                               ║
║  📧 Kontakt: nevenroksa@gmail.com | GitHub: @nroxa92                         ║
║                                                                               ║
║                        © 2025-2026 Sva prava pridržana                        ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

---

## 📋 Sadržaj

- [O Projektu](#-o-projektu)
- [Vesta Lumina System](#-vesta-lumina-system)
- [Statistika Projekta](#-statistika-projekta)
- [Tehnička Arhitektura](#-tehnička-arhitektura)
- [Kompletna Struktura Projekta](#-kompletna-struktura-projekta)
- [Funkcionalnosti](#-funkcionalnosti)
- [Kiosk Mode](#-kiosk-mode)
- [OCR Scanning](#-ocr-scanning)
- [Verzije](#-verzije)

---

## 🎯 O Projektu

**Vesta Lumina Client Terminal** je Android tablet aplikacija dizajnirana za kiosk mode. Služi kao digitalna recepcija za goste smještajnih objekata, omogućujući samoposlužni check-in putem OCR skeniranja dokumenata.

### Ključne Značajke

- Kiosk mode s potpunim zaključavanjem uređaja
- MRZ OCR skeniranje putovnica i osobnih iskaznica
- Digitalni potpis kućnih pravila
- AI concierge chatbot
- Offline podrška s automatskom sinkronizacijom
- Podrška za 11 jezika
- GDPR compliant automatsko brisanje podataka

---

## 🌟 Vesta Lumina System

**Vesta Lumina System** je kompletni ekosustav za upravljanje smještajnim objektima:

| Komponenta | Opis | Tehnologija | Status |
|------------|------|-------------|--------|
| **Vesta Lumina Admin Panel** | Web aplikacija za vlasnike | Flutter Web | ✅ Beta |
| **Vesta Lumina Client Terminal** | Tablet aplikacija za goste (Kiosk mode) | Flutter Android | ✅ Beta |
| **Firebase Backend** | Cloud infrastruktura | Firebase | ✅ Aktivan |

### Arhitektura

```
┌─────────────────────────────────────────────────────────────────────┐
│                        VESTA LUMINA SYSTEM                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   ┌─────────────────┐         ┌─────────────────┐                  │
│   │   ADMIN PANEL   │◄───────►│    FIREBASE     │                  │
│   │   (Web Panel)   │         │    BACKEND      │                  │
│   │     MASTER      │         │                 │                  │
│   └─────────────────┘         └────────┬────────┘                  │
│                                        │                            │
│                                        ▼                            │
│                               ┌─────────────────┐                  │
│                               │ CLIENT TERMINAL │                  │
│                               │    (Tablet)     │                  │
│                               │     SLAVE       │                  │
│                               └─────────────────┘                  │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 📊 Statistika Projekta

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                  VESTA LUMINA CLIENT TERMINAL v0.0.9                          ║
║                          KOMPLETNA STATISTIKA                                 ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║  📁 IZVORNI KOD (lib/)                                                        ║
║  ───────────────────────────────────────────────────────────────────────────  ║
║  │ Screens (17 datoteka)             │ 5,200+ linija                         ║
║  │ Services (15 datoteka)            │ 3,500+ linija                         ║
║  │ Widgets (6 datoteka)              │ 600+ linija                           ║
║  │ Models (3 datoteke)               │ 300+ linija                           ║
║  │ Config (2 datoteke)               │ 400+ linija                           ║
║  │ Utils (2 datoteke)                │ 250+ linija                           ║
║  │ Barrel Files (10 datoteka)        │ 100+ linija                           ║
║  │ Root (main.dart)                  │ 230+ linija                           ║
║  │                                                                           ║
║  │ UKUPNO DART KOD                   │ ~12,000 linija                        ║
║                                                                               ║
║  📱 ANDROID NATIVE                                                            ║
║  ───────────────────────────────────────────────────────────────────────────  ║
║  │ Kiosk Mode (DevicePolicyManager)  │ Native integration                    ║
║  │ Camera (ML Kit)                   │ MRZ scanning                          ║
║                                                                               ║
║  🌍 LOKALIZACIJA                                                              ║
║  ───────────────────────────────────────────────────────────────────────────  ║
║  │ Podržani jezici                   │ 11 jezika                             ║
║  │ EN, HR, DE, IT, ES, FR, PL, SK, CS, HU, SL                                ║
║                                                                               ║
║  ☁️ FIREBASE INTEGRACIJA                                                      ║
║  ───────────────────────────────────────────────────────────────────────────  ║
║  │ Firestore (read/write)            │ 6 kolekcija                           ║
║  │ Storage (signatures)              │ PNG upload                            ║
║  │ Auth (anonymous + custom)         │ Session management                    ║
║                                                                               ║
║  ═══════════════════════════════════════════════════════════════════════════  ║
║  │ UKUPNO LINIJA KODA                │ ~12,000 linija                        ║
║  │ UKUPNO DATOTEKA                   │ 45+ datoteka                          ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

---

## 🏗️ Tehnička Arhitektura

### Technology Stack

```
┌────────────────────────────────────────────────────────────────────┐
│                           FRONTEND                                  │
│  Flutter 3.2+ │ Dart 3.x │ Material Design │ Hive Local Storage    │
├────────────────────────────────────────────────────────────────────┤
│                           BACKEND                                   │
│  Firebase Auth │ Cloud Firestore │ Cloud Storage │ Sentry.io       │
├────────────────────────────────────────────────────────────────────┤
│                         NATIVE ANDROID                              │
│  ML Kit OCR │ DevicePolicyManager │ Camera2 API │ Kiosk Mode       │
└────────────────────────────────────────────────────────────────────┘
```

### Slave-Master Architecture

Tablet je **SLAVE** komponenta koja slijedi strukturu Web Panela (**MASTER**):

| Aspect | Rule |
|--------|------|
| **Data Structure** | Must match Web Panel Firestore schema |
| **Field Naming** | camelCase (matching Web Panel) |
| **Guests Storage** | Subcollection under bookings |
| **Signatures** | Firebase Storage URLs |
| **Tenant Isolation** | All data under owners/{ownerId}/... |

---

## 📁 Kompletna Struktura Projekta

```
lib/
├── main.dart                          # Entry point (230 lines)
│
├── config/                            # Konfiguracija
│   ├── config.dart                    # 🆕 Barrel export
│   ├── constants.dart                 # API keys, Firebase config
│   └── theme.dart                     # Dark theme, colors
│
├── data/
│   ├── models/                        # Data modeli
│   │   ├── models.dart                # 🆕 Barrel export
│   │   ├── chat_message.dart          # AI chat message
│   │   ├── guest_model.dart           # Guest data
│   │   └── place.dart                 # Place recommendation
│   │
│   └── services/                      # Business logic (15 services)
│       ├── services.dart              # 🆕 Barrel export
│       ├── storage_service.dart       # Hive local storage
│       ├── firestore_service.dart     # Firebase sync
│       ├── tablet_auth_service.dart   # Authentication
│       ├── checkin_service.dart       # Check-in flow
│       ├── checkin_validator.dart     # Data validation
│       ├── ocr_service.dart           # MRZ scanning
│       ├── signature_storage_service.dart # Signature upload
│       ├── kiosk_service.dart         # Kiosk mode control
│       ├── sentry_service.dart        # Error tracking
│       ├── performance_service.dart   # Performance monitoring
│       ├── connectivity_service.dart  # Network status
│       ├── offline_queue_service.dart # Offline operations
│       ├── gemini_service.dart        # AI chatbot
│       ├── weather_service.dart       # Weather API
│       └── places_service.dart        # Places API
│
├── ui/
│   ├── screens/                       # Ekrani (17 screens)
│   │   ├── screens.dart               # 🆕 Barrel export
│   │   ├── welcome_screen.dart        # Language selection
│   │   ├── setup_screen.dart          # Unit code entry
│   │   ├── dashboard_screen.dart      # Main dashboard
│   │   ├── house_rules_screen.dart    # Rules + signature
│   │   ├── chat_screen.dart           # AI chatbot
│   │   ├── feedback_screen.dart       # Guest feedback
│   │   ├── screensaver_screen.dart    # Idle screen
│   │   │
│   │   ├── admin/                     # 🆕 Admin Panel
│   │   │   ├── admin_screens.dart     # Barrel export
│   │   │   ├── admin_menu_screen.dart # Admin options
│   │   │   └── debug_screen.dart      # 5-tab debug panel
│   │   │
│   │   ├── checkin/                   # Check-in flow
│   │   │   ├── checkin_screens.dart   # Barrel export
│   │   │   ├── checkin_intro_screen.dart
│   │   │   ├── document_selection_screen.dart
│   │   │   ├── camera_screen.dart     # OCR scanning
│   │   │   ├── guest_confirmation_screen.dart
│   │   │   ├── guest_scan_coordinator.dart
│   │   │   └── checkin_success_screen.dart
│   │   │
│   │   └── cleaner/                   # Cleaner flow
│   │       ├── cleaner_screens.dart   # Barrel export
│   │       ├── cleaner_login_screen.dart
│   │       └── cleaner_tasks_screen.dart
│   │
│   └── widgets/                       # Reusable widgets
│       ├── widgets.dart               # 🆕 Barrel export
│       ├── error_boundary.dart
│       ├── kiosk_exit_dialog.dart
│       ├── offline_indicator.dart
│       ├── place_card.dart
│       └── welcome_message_overlay.dart
│
└── utils/                             # Utilities
    ├── utils.dart                     # 🆕 Barrel export
    ├── inactivity_wrapper.dart        # Screensaver trigger
    └── translations.dart              # 11 languages
```

---

## 🔧 Funkcionalnosti

### Guest Check-in Flow

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Welcome   │───►│  Check-in   │───►│   Camera    │───►│   Confirm   │
│   Screen    │    │    Intro    │    │  MRZ Scan   │    │    Data     │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
                                                                │
┌─────────────┐    ┌─────────────┐    ┌─────────────┐           │
│  Dashboard  │◄───│   Success   │◄───│  Signature  │◄──────────┘
│             │    │   Screen    │    │  House Rules│
└─────────────┘    └─────────────┘    └─────────────┘
```

### Features Matrix

| Feature | Status | Description |
|---------|--------|-------------|
| Multi-language | ✅ | 11 languages |
| MRZ OCR Scan | ✅ | Passport/ID scanning |
| Digital Signature | ✅ | House rules signing |
| AI Chatbot | ✅ | Gemini-powered concierge |
| Kiosk Mode | ✅ | Full device lockdown |
| Offline Support | ✅ | Queue + auto-sync |
| Brute-force Protection | ✅ | 5 attempts → 5 min lockout |
| Admin Panel | ✅ | Debug + Factory Reset |
| Sentry Monitoring | ✅ | Crash reporting |
| Firebase Sync | ✅ | Real-time data |

---

## 🔒 Kiosk Mode

### Features

- Full screen immersive mode
- System bars hidden
- Home/Back button disabled
- App pinning via DevicePolicyManager
- Remote enable/disable from Web Panel
- Auto re-enable on app resume

### Admin Access

```
Dashboard → Staff Access → Master PIN → Admin Menu
                                           │
                              ┌────────────┼────────────┐
                              ▼            ▼            ▼
                         Debug Panel  Kiosk Disable  Factory Reset
                         (5 tabs)     (5 min temp)   (Unlink device)
```

---

## 📷 OCR Scanning

### MRZ Detection

- **Supported Documents:** Passport, ID Card
- **Technology:** Google ML Kit Text Recognition
- **Extracted Data:**
  - First Name, Last Name
  - Date of Birth
  - Nationality
  - Document Number
  - Document Type

### Camera Setup

- Rear camera with mirror (for wall-mounted tablets)
- Auto-capture every 1.5 seconds
- Manual capture option
- Real-time feedback

---

## 📌 Verzije

### Trenutna verzija: 0.0.9 (Siječanj 2026)

```
v0.0.9 - Beta Release (Siječanj 2026)
═══════════════════════════════════════════════════════════════
✅ Admin Panel (Admin Menu + Debug Screen)
✅ Barrel File Implementation (10 files)
✅ Fixed checkin_service.dart field naming
✅ QA Checklist (80+ test cases)

v0.0.8 - Kiosk Mode
═══════════════════════════════════════════════════════════════
✅ Full Kiosk Lockdown
✅ Remote Control from Web Panel
✅ App Lifecycle Handling

v0.0.7 - Monitoring & Security
═══════════════════════════════════════════════════════════════
✅ Sentry Error Tracking
✅ Brute-force Protection
✅ Performance Monitoring

v0.0.1 - Core System
═══════════════════════════════════════════════════════════════
✅ MRZ OCR Scanning
✅ Digital Signature
✅ Firebase Sync
✅ 11 Languages
```

---

## 📜 Licenca

Ovaj softver je zaštićen **vlasničkom licencom**. Pogledajte [LICENSE](LICENSE) datoteku za potpune uvjete.

```
© 2025-2026 Sva prava pridržana.
Neovlašteno kopiranje ili korištenje je strogo zabranjeno.
```

---

## 📧 Kontakt

Za upite o licenciranju ili poslovnu suradnju:

- **GitHub:** [@nroxa92](https://github.com/nroxa92)
- **Email:** nevenroksa@gmail.com

---

<div align="center">

**Vesta Lumina Client Terminal** | Part of **Vesta Lumina System**

*Digital Reception for Vacation Rentals*

*Built with Flutter & Firebase*

v0.0.9 Beta

</div>
