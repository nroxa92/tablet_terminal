# 🏠 VillaOS Tablet Terminal

**Premium Digital Reception System for Vacation Rentals**

Android tablet kiosk aplikacija za automatiziran check-in gostiju, digitalno potpisivanje kućnog reda, AI concierge i upravljanje čišćenjem.

---

## 📋 Sadržaj

- [Pregled](#-pregled)
- [Značajke](#-značajke)
- [Arhitektura](#-arhitektura)
- [Tehnologije](#-tehnologije)
- [Struktura Projekta](#-struktura-projekta)
- [Instalacija](#-instalacija)
- [Konfiguracija](#-konfiguracija)
- [Firebase Integracija](#-firebase-integracija)
- [Screens & Flow](#-screens--flow)
- [Verzije](#-verzije)

---

## 🎯 Pregled

VillaOS Tablet je **"Slave"** komponenta VillaOS ekosustava. Radi u paru s **Web Panelom** (Master) koji definira sve postavke, rezervacije i sadržaj.

### Uloge u sustavu:

| Komponenta | Uloga | Odgovornost |
|------------|-------|-------------|
| **Web Panel** | Master | Kreira rezervacije, postavlja sadržaj, upravlja unitima |
| **Tablet** | Slave | Izvršava check-in, prikuplja potpise, prikazuje sadržaj |
| **Firebase** | Backend | Sinkronizacija podataka u realnom vremenu |

---

## ✨ Značajke

### 👤 Guest Check-in
- **MRZ OCR skeniranje** - Automatsko čitanje putovnica i osobnih iskaznica
- **Multi-guest podrška** - Skeniranje svih gostiju u grupi
- **eVisitor priprema** - Podaci spremni za prijavu turista

### ✍️ House Rules
- **Višejezični prikaz** - Automatski jezik prema nacionalnosti
- **Digitalni potpis** - Canvas za potpis gosta
- **Firebase Storage** - Potpisi kao URL-ovi (ne Base64)

### 🤖 AI Concierge
- **Gemini integracija** - AI asistent za goste
- **Kontekstualni promptovi** - Definirani u Web Panelu
- **Chat history** - Logiranje razgovora

### 🧹 Cleaner Mode
- **PIN pristup** - Zaštićen pristup za čistačice
- **Task checklist** - Lista zadataka iz Web Panela
- **Cleaning logs** - Izvještaji o čišćenju

### 📺 Screensaver
- **Galerija slika** - Slike iz Firebase Storage
- **Auto-aktivacija** - Nakon perioda neaktivnosti
- **Touch to wake** - Dodir za povratak

### ⭐ Feedback
- **Rating system** - 1-5 zvjezdica
- **Komentar** - Opcijski tekst
- **Google Review** - Redirect za pozitivne ocjene

---

## 🏗️ Arhitektura

```
┌─────────────────────────────────────────────────────────┐
│                     WEB PANEL (Master)                   │
│         Postavke · Rezervacije · Sadržaj · Analitika     │
└─────────────────────────┬───────────────────────────────┘
                          │
                    Firebase Cloud
                          │
┌─────────────────────────┴───────────────────────────────┐
│                    TABLET (Slave)                        │
│       Check-in · Potpisi · AI Chat · Cleaner Mode        │
└─────────────────────────────────────────────────────────┘
```

### Data Flow:

```
Web Panel                    Firebase                      Tablet
    │                           │                            │
    ├── Create Booking ────────►│                            │
    │                           ├── Sync ──────────────────►│
    │                           │                            ├── Display Guest
    │                           │                            │
    │                           │◄── OCR Scan ──────────────┤
    │                           │◄── Signature Upload ──────┤
    │                           │                            │
    ├── View Check-in ◄────────┤                            │
    │                           │                            │
```

---

## 🛠️ Tehnologije

| Kategorija | Tehnologija |
|------------|-------------|
| **Framework** | Flutter 3.x |
| **Jezik** | Dart |
| **Backend** | Firebase (Firestore, Storage, Auth) |
| **AI** | Google Gemini API |
| **OCR** | Google ML Kit (MRZ Parser) |
| **Local Storage** | Hive |
| **Maps** | Google Places API |

---

## 📁 Struktura Projekta

```
lib/
├── main.dart                    # Entry point
├── config/
│   └── theme.dart               # App theme & colors
├── data/
│   ├── models/
│   │   ├── guest_model.dart     # Guest data model
│   │   ├── chat_message.dart    # AI chat message
│   │   └── place.dart           # Google Places model
│   └── services/
│       ├── firestore_service.dart        # Firebase sync
│       ├── storage_service.dart          # Local storage (Hive)
│       ├── signature_storage_service.dart # Signature upload
│       ├── tablet_auth_service.dart      # Tablet authentication
│       ├── ocr_service.dart              # MRZ scanning
│       ├── gemini_service.dart           # AI integration
│       ├── checkin_service.dart          # Check-in logic
│       ├── places_service.dart           # Google Places
│       └── weather_service.dart          # Weather data
├── ui/
│   └── screens/
│       ├── screensaver_screen.dart       # Idle screensaver
│       ├── welcome_screen.dart           # Guest welcome
│       ├── dashboard_screen.dart         # Main dashboard
│       ├── house_rules_screen.dart       # Rules & signature
│       ├── feedback_screen.dart          # Guest feedback
│       ├── chat_screen.dart              # AI concierge
│       ├── setup_screen.dart             # Initial setup
│       ├── checkin/
│       │   ├── camera_screen.dart        # OCR scanning
│       │   └── guest_confirmation_screen.dart
│       └── cleaner/
│           └── cleaner_tasks_screen.dart # Cleaner checklist
└── utils/
    └── ...                       # Helpers & utilities
```

---

## 🚀 Instalacija

### Preduvjeti

- Flutter SDK 3.x
- Android Studio / VS Code
- Firebase projekt (dijeljen s Web Panelom)
- Android tablet (min. API 24)

### Koraci

```bash
# 1. Kloniraj repozitorij
git clone https://github.com/nroxa92/tablet_terminal.git
cd tablet_terminal

# 2. Instaliraj dependencies
flutter pub get

# 3. Dodaj Firebase konfiguraciju
# Stavi google-services.json u android/app/

# 4. Build
flutter build apk --release
```

---

## ⚙️ Konfiguracija

### Firebase Setup

1. Koristi **isti Firebase projekt** kao Web Panel
2. Dodaj Android app u Firebase Console
3. Preuzmi `google-services.json`
4. Postavi u `android/app/`

### Tablet Registration

Tablet se registrira putem **6-znamenkastog koda** generiranog u Web Panelu:

```
Web Panel → Units → Select Unit → Generate Tablet Code
```

Kod sadrži:
- `ownerId` - ID vlasnika (tenant)
- `unitId` - ID nekretnine
- Expires: 15 minuta

---

## 🔥 Firebase Integracija

### Kolekcije koje Tablet koristi:

| Kolekcija | Pristup | Opis |
|-----------|---------|------|
| `bookings` | Read/Update | Rezervacije i gosti |
| `bookings/{id}/guests` | Read/Write | Guest subcollection |
| `units` | Read | Podaci o nekretnini |
| `settings` | Read | Owner postavke |
| `signatures` | Write | Upload potpisa |
| `cleaning_logs` | Write | Cleaner izvještaji |
| `feedback` | Write | Guest feedback |
| `ai_logs` | Write | AI chat logovi |
| `screensaver_images` | Read | Galerija slika |

### Firestore polja (camelCase standard):

```javascript
// Booking
{
  ownerId: "TENANT123",
  unitId: "unit_abc",
  guestName: "Ivan Horvat",
  guestCount: 4,
  startDate: Timestamp,
  endDate: Timestamp,
  isScanned: false
}

// Signature
{
  ownerId: "TENANT123",
  bookingId: "booking_xyz",   // KRITIČNO za GDPR cleanup!
  signatureUrl: "https://...",
  signedAt: Timestamp
}
```

Vidi: [FIREBASE_DOCUMENTATION.md](./FIREBASE_DOCUMENTATION.md)

---

## 📱 Screens & Flow

### Guest Flow:

```
Screensaver
    │
    ▼ (touch)
Welcome Screen
    │
    ▼ (tap to start)
Dashboard
    │
    ├──► Check-in ──► Camera (OCR) ──► Confirmation
    │
    ├──► House Rules ──► Signature ──► Done
    │
    ├──► AI Concierge ──► Chat
    │
    └──► Feedback ──► Rating ──► Thank You
```

### Cleaner Flow:

```
Dashboard
    │
    ▼ (PIN)
Cleaner Tasks
    │
    ├──► Complete Tasks
    │
    └──► Finish ──► Cleanup ──► Screensaver
```

---

## 🔐 Sigurnost

- **Tenant Isolation** - Svaki vlasnik vidi samo svoje podatke
- **Custom Claims** - `ownerId`, `unitId`, `role: "tablet"`
- **GDPR Compliance** - Automatsko brisanje potpisa nakon checkout-a
- **PIN Protection** - Cleaner i Factory Reset zaštićeni PIN-om

---

## 📦 Verzije

| Verzija | Datum | Promjene |
|---------|-------|----------|
| 5.1 | 2026-01-09 | Firebase sync fix, camelCase standard |
| 5.0 | 2026-01-08 | Guest subcollection, Signature Storage URLs |
| 4.0 | 2026-01-07 | MRZ-only OCR, cleanerChecklist sync |
| 3.0 | 2026-01-05 | Rear camera mirror setup |
| 2.0 | 2026-01-01 | Initial Firebase integration |

---

## 📄 Licenca

Proprietary - VillaOS © 2026

---

## 🔗 Povezano

- [VillaOS Web Panel](https://github.com/nroxa92/villa-web-panel)
- [Firebase Documentation](./FIREBASE_DOCUMENTATION.md)