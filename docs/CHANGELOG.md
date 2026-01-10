# 📝 Changelog

> **Vesta Lumina Client Terminal** - All notable changes to this project
> **Part of Vesta Lumina System**

---

## ⚠️ LEGAL NOTICE

```
This software is PROPRIETARY. Unauthorized use is prohibited.
© 2025-2026 All rights reserved.
```

---

## [0.0.9] - 2026-01-10

### 🎉 Beta Release - Production Ready

#### ✅ Fixed
- **Critical:** Fixed `checkin_service.dart` field naming inconsistency
  - Bug: Using `snake_case` (`unit_id`, `start_date`) while rest of app uses `camelCase`
  - Fix: Standardized to `camelCase` (`unitId`, `startDate`) for Firebase compatibility
- **Critical:** Fixed guest storage dual-path issue
  - Bug: Two different methods for saving guests (Array vs Subcollection)
  - Fix: Consolidated to Subcollection approach matching Web Panel structure

#### ➕ Added
- **FAZA 4: Admin Panel & Debug System**
  - Admin Menu Screen (420 lines) - Opens after Master PIN
  - Debug Panel with 5 tabs (650 lines):
    - Status Tab - Device info, kiosk status, connectivity
    - Firebase Tab - Live Firestore document viewer
    - Storage Tab - Local Hive data dump
    - Tests Tab - Automated service tests (5 tests)
    - Actions Tab - Quick navigation & debug tools
  - Temporary Kiosk Disable (5 min auto re-enable)
  - Factory Reset moved to Admin Menu

- **Barrel File Implementation**
  - 10 barrel files for organized imports
  - Reduced main.dart imports from 20+ to 4
  
- **QA Checklist**
  - 80+ manual test cases
  - docs/QA_CHECKLIST.md

#### 🔄 Changed
- Master PIN now opens Admin Menu instead of direct Factory Reset
- Cleaner Login info text updated ("Opens Admin Panel")
- main.dart refactored with barrel imports
- All screens now use barrel imports

#### 📊 New Files Added
| File | Lines | Purpose |
|------|-------|---------|
| admin_menu_screen.dart | 420 | Admin options after Master PIN |
| debug_screen.dart | 650 | 5-tab debug panel for QA |
| config/config.dart | 8 | Barrel export |
| data/models/models.dart | 9 | Barrel export |
| data/services/services.dart | 25 | Barrel export (15 services) |
| ui/screens/screens.dart | 18 | Barrel export (all screens) |
| ui/screens/admin/admin_screens.dart | 6 | Barrel export |
| ui/screens/checkin/checkin_screens.dart | 10 | Barrel export |
| ui/screens/cleaner/cleaner_screens.dart | 6 | Barrel export |
| ui/widgets/widgets.dart | 9 | Barrel export |
| utils/utils.dart | 6 | Barrel export |

---

## [0.0.8] - 2026-01-09

### 🔒 FAZA 2.5: Kiosk Mode & Remote Control

#### ➕ Added
- **Kiosk Service** (220 lines)
  - Full kiosk mode lockdown
  - Remote enable/disable from Web Panel via Firebase
  - Android DevicePolicyManager integration
  - Auto re-enable on app resume
  - System bar hiding
- **Kiosk Exit Dialog**
  - Confirmation before exiting kiosk
  - PIN verification option
- **App Lifecycle Handling**
  - WidgetsBindingObserver integration
  - Kiosk re-enables on app resume
  - Immersive mode auto-restore

#### 🔄 Changed
- main.dart updated with WidgetsBindingObserver mixin
- Added KioskService.init() to startup sequence
- VillaApp now listens to app lifecycle changes

---

## [0.0.7] - 2026-01-08

### 🛡️ FAZA 1: Monitoring & Security

#### ➕ Added
- **Sentry Service** (185 lines)
  - Crash reporting to Sentry.io
  - Performance monitoring
  - User context tracking (unit, owner, device)
  - Breadcrumb navigation logging
  - PIN attempt security logging
- **Performance Service** (95 lines)
  - Firebase Performance integration
  - Custom traces for sync operations
  - Network request monitoring
- **Brute-force Protection**
  - 5 wrong PIN attempts → 5 minute lockout
  - Lockout state persisted in Hive storage
  - Visual countdown timer UI
  - Sentry security event logging
  - Automatic lockout reset

#### 🔄 Changed
- Cleaner Login Screen with lockout UI
  - Animated lock icon on lockout
  - Countdown timer display
  - Remaining attempts warning
- All navigation logged to Sentry
- _SentryNavigatorObserver in MaterialApp

---

## [0.0.6] - 2026-01-07

### 📴 FAZA 2: Offline Resilience

#### ➕ Added
- **Connectivity Service** (130 lines)
  - Real-time network monitoring with connectivity_plus
  - Stream-based status updates
  - Manual connection check method
  - Auto-reconnect detection
- **Offline Queue Service** (290 lines)
  - Queue operations when offline
  - Auto-sync when connection restored
  - Hive persistence for queue
  - Conflict resolution (last-write-wins)
  - Queue status monitoring
- **Offline Indicator Widget** (85 lines)
  - Visual feedback for offline state
  - Animated icon
  - Positioned at bottom of screen

#### 🔄 Changed
- FirestoreService with offline fallbacks
- Guest saving queued when offline
- Signature upload queued when offline
- Sync operations check connectivity first

---

## [0.0.5] - 2026-01-05

### ✍️ Signature System

#### ➕ Added
- **Signature Storage Service** (180 lines)
  - Firebase Storage upload
  - URL generation for Web Panel
  - PNG format export
  - Automatic cleanup after checkout
  - Retry logic for failed uploads
- **Signature Pad Integration**
  - Touch signature capture (signature package)
  - Clear and redo options
  - Preview before confirm
  - Responsive sizing

#### 🔄 Changed
- House Rules Screen includes signature step
- Check-in flow requires signature
- Signature URL stored in booking document
- GDPR: Auto-delete signatures after checkout

---

## [0.0.4] - 2026-01-03

### 📷 OCR & MRZ Scanning

#### ➕ Added
- **OCR Service** (340 lines)
  - Google ML Kit Text Recognition
  - MRZ (Machine Readable Zone) detection
  - MRZ parsing for passport/ID data
  - Auto-capture every 1.5 seconds
  - Manual capture option
  - Data extraction: name, DOB, nationality, document number
- **Camera Screen** (450 lines)
  - Rear camera with mirror support
  - Document frame overlay
  - Real-time scan feedback
  - Flash control
  - Focus indicators
- **Guest Confirmation Screen** (320 lines)
  - Editable extracted data
  - Field validation
  - Manual correction option
- **Guest Scan Coordinator** (280 lines)
  - Multi-guest flow management
  - Progress tracking (Guest 1 of N)
  - Back/Next navigation
  - Summary before submit

#### 🔄 Changed
- Simplified to MRZ-only scanning (removed front document scan)
- Check-in intro leads to camera flow
- Guest data stored in Firestore subcollection

---

## [0.0.3] - 2025-12-30

### 🏠 Dashboard & Navigation

#### ➕ Added
- **Dashboard Screen** (380 lines)
  - Current booking display
  - Guest name & count
  - Check-in/out dates
  - Quick action buttons (Chat, Feedback, etc.)
  - Weather widget integration
  - AI chat access cards
- **Welcome Screen** (320 lines)
  - Language selection (11 languages)
  - Animated welcome message
  - Check-in CTA button
  - Beautiful gradient animations
- **Screensaver Screen** (180 lines)
  - Idle timeout activation (2 min)
  - Wake on touch
  - Clock display
  - Gallery slideshow (from Firebase)
- **Inactivity Wrapper** (120 lines)
  - Auto screensaver trigger
  - Configurable timeout
  - Touch detection reset

#### 🔄 Changed
- Navigation flow established (Welcome → Check-in → Dashboard)
- Route guards for auth state
- Deep linking support

---

## [0.0.2] - 2025-12-25

### 🔐 Authentication & Setup

#### ➕ Added
- **Tablet Auth Service** (280 lines)
  - Unit code validation against Firestore
  - Firebase anonymous authentication
  - Custom token with ownerId claim
  - Session persistence
  - Auto token refresh (every 45 min)
  - Heartbeat mechanism (every 5 min)
  - Session restore on app start
- **Setup Screen** (250 lines)
  - Unit code entry (6-digit)
  - Real-time validation
  - Error feedback
  - Success animation
  - Keyboard handling
- **Storage Service** (320 lines)
  - Hive local database
  - Unit/Owner ID persistence
  - Booking cache
  - PIN storage (cleaner, master)
  - Villa data cache
  - Check-in status tracking

#### 🔄 Changed
- Initial app structure created
- Firebase configuration (google-services.json)
- Android manifest for kiosk permissions

---

## [0.0.1] - 2025-12-20

### 🚀 Initial Release

#### ➕ Added
- Flutter project initialization
  - Package name: villa_ai_terminal
  - Min SDK: 21
  - Target SDK: 34
- Basic folder structure
  - lib/config/
  - lib/data/models/
  - lib/data/services/
  - lib/ui/screens/
  - lib/ui/widgets/
  - lib/utils/
- Firebase Core integration
  - firebase_core
  - firebase_auth
  - cloud_firestore
  - firebase_storage
- Theme configuration
  - Dark mode default
  - Gold accent color (#D4AF37)
  - Material Design 3
- Constants configuration
  - API keys placeholder
  - Firebase config loading
- Basic translations
  - 11 languages supported
  - EN, HR, DE, IT, ES, FR, PL, SK, CS, HU, SL

---

## Version History Summary

| Version | Date | Highlights |
|---------|------|------------|
| 0.0.9 | 2026-01-10 | Beta Release, Admin Panel, Debug Screen, Barrel Files, Bug Fixes |
| 0.0.8 | 2026-01-09 | Kiosk Mode (220 lines), Remote Control, App Lifecycle |
| 0.0.7 | 2026-01-08 | Sentry Monitoring (185 lines), Brute-force Protection |
| 0.0.6 | 2026-01-07 | Offline Queue (290 lines), Connectivity Service |
| 0.0.5 | 2026-01-05 | Signature System (180 lines), Firebase Storage |
| 0.0.4 | 2026-01-03 | OCR/MRZ Scanning (340 lines), Camera Integration |
| 0.0.3 | 2025-12-30 | Dashboard, Welcome Screen, Screensaver |
| 0.0.2 | 2025-12-25 | Authentication (280 lines), Setup, Storage |
| 0.0.1 | 2025-12-20 | Initial Release - Project Foundation |

---

## Statistics Summary

| Metric | Value |
|--------|-------|
| **Total Dart Files** | 45+ |
| **Total Dart Lines** | ~12,000 |
| **Services** | 15 |
| **Screens** | 17 |
| **Widgets** | 6 |
| **Models** | 3 |
| **Barrel Files** | 10 |
| **Languages** | 11 |
| **Dependencies** | 25 |

---

## 📜 License

```
© 2025-2026 Neven Roksa (@nroxa92). All rights reserved.
This is proprietary software. Unauthorized use is prohibited.

Part of Vesta Lumina System:
• Vesta Lumina Admin Panel
• Vesta Lumina Client Terminal
```
