# 📱 Vesta Lumina Client Terminal - Pregled Sustava

> **Što je tablet aplikacija i kako radi u okviru Vesta Lumina System**
> **Napisano jednostavno i razumljivo**

---

## 📋 Sadržaj

1. [Što je Client Terminal?](#-što-je-client-terminal)
2. [Gdje se Uklapa u Sustav?](#-gdje-se-uklapa-u-sustav)
3. [Glavne Funkcije](#-glavne-funkcije)
4. [Kako Radi?](#-kako-radi)
5. [Tko Koristi Tablet?](#-tko-koristi-tablet)
6. [Tehnički Pregled](#-tehnički-pregled)
7. [Sigurnost i Privatnost](#-sigurnost-i-privatnost)
8. [Brzi Pregled](#-brzi-pregled)

---

## 🎯 Što je Client Terminal?

### Jednostavno Objašnjenje

**Vesta Lumina Client Terminal** je **tablet aplikacija** koja stoji u vašem smještajnom objektu (vila, apartman, soba) i služi kao **digitalna recepcija** za goste.

Zamislite ga kao **pametnog asistenta** koji:
- Dočekuje goste
- Obavlja check-in (skenira dokumente)
- Odgovara na pitanja
- Pokazuje kućna pravila
- Daje WiFi lozinku

### Prije i Poslije

**Prije (bez tableta):**
```
📋 Ručno pisanje podataka gostiju
📞 Gosti vas zovu za svako pitanje
📝 Papir za potpis kućnih pravila
😓 "Koja je WiFi lozinka?"
```

**Poslije (s tabletom):**
```
📱 Automatski OCR scan dokumenata
🤖 AI odgovara na pitanja 24/7
✍️ Digitalni potpis na tabletu
📶 WiFi lozinka na ekranu
```

---

## 🧩 Gdje se Uklapa u Sustav?

### Vesta Lumina System - 3 Komponente

```
╔═══════════════════════════════════════════════════════════════════╗
║                     VESTA LUMINA SYSTEM                           ║
╠═══════════════════════════════════════════════════════════════════╣
║                                                                   ║
║   ┌─────────────────┐                    ┌─────────────────┐     ║
║   │                 │                    │                 │     ║
║   │  💻 WEB PANEL   │◄──── CLOUD ────►  │   📱 TABLET    │     ║
║   │   (za vas)      │     (Firebase)     │   (za goste)   │     ║
║   │                 │                    │                 │     ║
║   │  • Rezervacije  │                    │  • Check-in    │     ║
║   │  • Postavke     │                    │  • AI chat     │     ║
║   │  • Analitika    │                    │  • Potpis      │     ║
║   │                 │                    │                 │     ║
║   └─────────────────┘                    └─────────────────┘     ║
║          ▲                                       ▲               ║
║          │              ☁️ FIREBASE              │               ║
║          │          (čuva i sinkronizira)        │               ║
║          └───────────────────────────────────────┘               ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝
```

### Master-Slave Arhitektura

| Komponenta | Uloga | Objašnjenje |
|------------|-------|-------------|
| **Web Panel** | MASTER | Vi definirate sve (pravila, postavke, rezervacije) |
| **Tablet** | SLAVE | Tablet samo čita i prikazuje te podatke gostima |
| **Firebase** | CLOUD | Sinkronizira podatke između Mastera i Slave-a |

**Što to znači u praksi?**

1. Vi napišete kućna pravila u Web Panelu
2. Firebase ih automatski šalje na tablet
3. Tablet prikazuje pravila gostu
4. Gost potpiše → potpis se šalje natrag kroz Firebase → vi ga vidite u Web Panelu

---

## ✨ Glavne Funkcije

### Za Goste

| Funkcija | Opis |
|----------|------|
| **🌍 Višejezičnost** | 11 jezika - gost bira svoj |
| **📋 Kućna Pravila** | Automatski prevedena na odabrani jezik |
| **📷 OCR Check-in** | Skeniranje MRZ zone s putovnice/osobne |
| **✍️ Digitalni Potpis** | Potpisivanje pravila prstom na ekranu |
| **🤖 AI Asistent** | Chatbot odgovara na pitanja |
| **📶 WiFi Info** | Lozinka uvijek vidljiva |
| **📞 Kontakt** | Hitni brojevi vlasnika |
| **🖼️ Screensaver** | Lijepe slike kad je tablet neaktivan |

### Za Čistače

| Funkcija | Opis |
|----------|------|
| **🧹 Checklist** | Lista zadataka za čišćenje |
| **📝 Napomene** | Mogućnost unosa napomena |
| **⏱️ Timestamp** | Automatski bilježi vrijeme završetka |

### Za Vas (Vlasnika)

| Funkcija | Opis |
|----------|------|
| **🔐 Admin Panel** | Debug, dijagnostika, reset |
| **📊 Monitoring** | Sentry crash reporting |
| **🔄 Remote Control** | Uključi/isključi kiosk iz Web Panela |

---

## ⚙️ Kako Radi?

### Životni Ciklus Check-ina

```
    GOST                          TABLET                         VAS (WEB PANEL)
      │                              │                                 │
      │   1. Dodirne ekran           │                                 │
      │ ──────────────────────────►  │                                 │
      │                              │                                 │
      │   2. Odabere jezik           │                                 │
      │ ──────────────────────────►  │                                 │
      │                              │                                 │
      │   3. Klikne "Check-in"       │                                 │
      │ ──────────────────────────►  │                                 │
      │                              │                                 │
      │   4. Skenira dokument        │                                 │
      │ ──────────────────────────►  │  OCR izvlači podatke            │
      │                              │                                 │
      │   5. Potvrđuje podatke       │                                 │
      │ ──────────────────────────►  │                                 │
      │                              │                                 │
      │   6. Čita pravila            │                                 │
      │ ◄──────────────────────────  │                                 │
      │                              │                                 │
      │   7. Potpisuje               │                                 │
      │ ──────────────────────────►  │                                 │
      │                              │                                 │
      │                              │   8. Šalje u Firebase           │
      │                              │ ─────────────────────────────►  │
      │                              │                                 │
      │                              │                                 │  9. Vi vidite
      │                              │                                 │     guest data
      │   10. Check-in uspješan!     │                                 │     + potpis
      │ ◄──────────────────────────  │                                 │
      │                              │                                 │
```

### Sinkronizacija Podataka

**Od Web Panela → Tablet:**
- Kućna pravila
- AI knowledge
- WiFi podaci
- Cleaner checklist
- Screensaver slike

**Od Tableta → Web Panel:**
- Guest podaci (skenirani)
- Potpisi (slike)
- Cleaning logs
- AI chat logs

### Offline Mode

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   📴 OFFLINE?  Nema problema!                               │
│                                                             │
│   1. Tablet koristi LOKALNO SPREMLJENE podatke             │
│   2. Novi podaci se stavljaju u QUEUE                      │
│   3. Kad se veza vrati → automatski SYNC                   │
│                                                             │
│   ┌───────────┐        ┌───────────┐        ┌───────────┐  │
│   │  HIVE DB  │───────►│   QUEUE   │───────►│  FIREBASE │  │
│   │  (local)  │  save  │  (local)  │  sync  │  (cloud)  │  │
│   └───────────┘        └───────────┘        └───────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 👥 Tko Koristi Tablet?

### Gosti (Primary Users)

**Što rade:**
- Check-in (skeniranje dokumenta)
- Čitaju pravila
- Koriste AI chat
- Gledaju WiFi
- Potpisuju dokumente

**Što NE mogu:**
- Izaći iz aplikacije (kiosk mode)
- Pristupiti Android sustavu
- Vidjeti podatke drugih gostiju
- Promijeniti postavke

### Čistači (Secondary Users)

**Što rade:**
- Pristupaju s Cleaner PIN-om
- Označavaju obavljene zadatke
- Unose napomene

**Što NE mogu:**
- Pristupiti Admin panelu
- Resetirati tablet
- Vidjeti guest podatke

### Vi / Admin (Admin Users)

**Što radite:**
- Pristupate s Master PIN-om
- Koristite Debug panel
- Privremeno isključujete kiosk
- Factory reset ako treba

---

## 🔧 Tehnički Pregled

### Arhitektura Aplikacije

```
┌─────────────────────────────────────────────────────────────┐
│                       TABLET APP                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   UI Layer (Screens)                                        │
│   ├── WelcomeScreen                                         │
│   ├── DashboardScreen                                       │
│   ├── CheckinFlow (5 screens)                               │
│   ├── CleanerFlow (2 screens)                               │
│   ├── AdminFlow (2 screens)                                 │
│   └── ChatScreen                                            │
│                                                             │
│   ─────────────────────────────────────────────────────     │
│                                                             │
│   Service Layer (15 services)                               │
│   ├── FirestoreService (sync)                               │
│   ├── StorageService (local DB)                             │
│   ├── TabletAuthService (auth)                              │
│   ├── OCRService (MRZ scan)                                 │
│   ├── KioskService (lockdown)                               │
│   ├── ConnectivityService (network)                         │
│   ├── OfflineQueueService (queue)                           │
│   └── ... 8 more                                            │
│                                                             │
│   ─────────────────────────────────────────────────────     │
│                                                             │
│   Data Layer                                                │
│   ├── Hive (local storage)                                  │
│   ├── Firebase Firestore (cloud)                            │
│   └── Firebase Storage (files)                              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Korištene Tehnologije

| Tehnologija | Svrha |
|-------------|-------|
| **Flutter** | UI framework |
| **Dart** | Programski jezik |
| **Firebase Auth** | Autentikacija |
| **Cloud Firestore** | Cloud baza podataka |
| **Firebase Storage** | Spremanje slika (potpisi) |
| **Google ML Kit** | OCR / MRZ skeniranje |
| **Hive** | Lokalna baza podataka |
| **Sentry** | Error tracking |
| **Gemini AI** | AI chatbot |

### Statistika Koda

```
╔═══════════════════════════════════════════════════════════════════╗
║              VESTA LUMINA CLIENT TERMINAL v0.0.9                  ║
╠═══════════════════════════════════════════════════════════════════╣
║                                                                   ║
║  📁 DART KOD                                                      ║
║  ──────────────────────────────────────────────────────────────   ║
║  │ Screens         │ 17 fajlova  │ ~5,200 linija                 ║
║  │ Services        │ 15 fajlova  │ ~3,500 linija                 ║
║  │ Widgets         │ 6 fajlova   │ ~600 linija                   ║
║  │ Models          │ 3 fajla     │ ~300 linija                   ║
║  │ Config/Utils    │ 4 fajla     │ ~650 linija                   ║
║  │ Barrel Files    │ 10 fajlova  │ ~100 linija                   ║
║  │                                                               ║
║  │ UKUPNO          │ 45+ fajlova │ ~12,000 linija                ║
║                                                                   ║
║  🌍 LOKALIZACIJA                                                  ║
║  ──────────────────────────────────────────────────────────────   ║
║  │ Podržani jezici │ 11                                          ║
║  │ EN, HR, DE, IT, ES, FR, PL, SK, CS, HU, SL                    ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝
```

---

## 🔒 Sigurnost i Privatnost

### Kiosk Mode

| Zaštita | Implementacija |
|---------|----------------|
| **App Pinning** | DevicePolicyManager lockTask |
| **System Bar** | Potpuno skrivena |
| **Home/Back** | Onemogućeni |
| **Auto Re-enable** | Kiosk se vraća ako se nekako isključi |
| **Remote Control** | Uključi/isključi iz Web Panela |

### PIN Zaštita

| PIN | Duljina | Svrha |
|-----|---------|-------|
| **Cleaner PIN** | 4 znamenke | Pristup cleaning flow-u |
| **Master PIN** | 6 znamenki | Pristup Admin panelu |

### Brute-force Zaštita

```
Pogrešan PIN pokušaj #1  →  ⚠️ "Preostalo: 4 pokušaja"
Pogrešan PIN pokušaj #2  →  ⚠️ "Preostalo: 3 pokušaja"
Pogrešan PIN pokušaj #3  →  ⚠️ "Preostalo: 2 pokušaja"
Pogrešan PIN pokušaj #4  →  ⚠️ "Preostalo: 1 pokušaj"
Pogrešan PIN pokušaj #5  →  🔒 ZAKLJUČANO 5 MINUTA
```

### GDPR Compliance

| Mjera | Implementacija |
|-------|----------------|
| **Minimalno prikupljanje** | Samo potrebni podaci |
| **Automatsko brisanje** | Guest podaci se brišu nakon checkout-a |
| **Potpisi** | Automatski se brišu iz Storage-a |
| **Offline data** | Briše se pri Factory Reset |

### Monitoring (Sentry)

- Crash reporting
- Performance tracing
- Security event logging (PIN pokušaji)
- User context (bez PII)

---

## 📊 Brzi Pregled

```
╔═══════════════════════════════════════════════════════════════════╗
║              VESTA LUMINA CLIENT TERMINAL                         ║
║                    "Digitalna Recepcija"                          ║
╠═══════════════════════════════════════════════════════════════════╣
║                                                                   ║
║  🎯 ŠTO JE                                                        ║
║  ──────────────────────────────────────────────────────────────   ║
║  Tablet aplikacija u smještaju koja služi kao digitalni           ║
║  concierge za goste. Obavlja check-in, odgovara na pitanja,      ║
║  prikazuje kućna pravila i prikuplja potpise.                    ║
║                                                                   ║
║  👥 ZA KOGA                                                       ║
║  ──────────────────────────────────────────────────────────────   ║
║  │ Gosti       │ Check-in, AI chat, pravila, WiFi               ║
║  │ Čistači     │ Cleaning checklist, napomene                   ║
║  │ Vlasnici    │ Admin panel, debug, reset                      ║
║                                                                   ║
║  ✨ GLAVNE FUNKCIJE                                               ║
║  ──────────────────────────────────────────────────────────────   ║
║  │ OCR Check-in      │ Skeniranje MRZ zone dokumenta            ║
║  │ Digitalni potpis  │ Potpisivanje pravila prstom              ║
║  │ AI Asistent       │ Gemini-powered chatbot                   ║
║  │ 11 Jezika         │ Automatski prijevod                      ║
║  │ Kiosk Mode        │ Gosti ne mogu izaći iz app-a             ║
║  │ Offline Mode      │ Radi i bez interneta                     ║
║                                                                   ║
║  🔧 TEHNOLOGIJA                                                   ║
║  ──────────────────────────────────────────────────────────────   ║
║  │ Flutter + Dart    │ UI framework                             ║
║  │ Firebase          │ Auth, Firestore, Storage                 ║
║  │ Google ML Kit     │ OCR / MRZ scanning                       ║
║  │ Hive              │ Local database                           ║
║  │ Sentry            │ Crash reporting                          ║
║                                                                   ║
║  📱 ZAHTJEVI                                                      ║
║  ──────────────────────────────────────────────────────────────   ║
║  │ Android 8.0+      │ Minimum                                  ║
║  │ 10" tablet        │ Preporučeno                              ║
║  │ Stražnja kamera   │ Za MRZ skeniranje                        ║
║  │ WiFi              │ Za Firebase sync                         ║
║                                                                   ║
║  🔗 DIO SUSTAVA                                                   ║
║  ──────────────────────────────────────────────────────────────   ║
║  │ Web Panel  ←→  Firebase  ←→  Tablet                          ║
║  │ (Master)       (Cloud)       (Slave)                         ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝

                    Part of Vesta Lumina System
                    © 2025-2026 All Rights Reserved
```

---

## 📜 Napomena

```
Vesta Lumina Client Terminal - Verzija 0.0.9 Beta
© 2025-2026 Sva prava pridržana.

Part of Vesta Lumina System:
• Vesta Lumina Admin Panel (Web)
• Vesta Lumina Client Terminal (Tablet)

Ovaj dokument je informativne prirode.
```
