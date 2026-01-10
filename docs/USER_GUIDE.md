# 📖 Vesta Lumina Client Terminal - Korisnički Priručnik

> **Verzija 0.0.9 Beta** | **Siječanj 2026**
> **Upute za postavljanje i korištenje tablet aplikacije**

---

## 📋 Sadržaj

1. [Što je Client Terminal?](#-što-je-client-terminal)
2. [Postavljanje Tableta](#-postavljanje-tableta)
3. [Povezivanje s Web Panelom](#-povezivanje-s-web-panelom)
4. [Kako Gosti Koriste Tablet](#-kako-gosti-koriste-tablet)
5. [Check-in Proces](#-check-in-proces)
6. [AI Asistent](#-ai-asistent)
7. [Pristup za Čistače](#-pristup-za-čistače)
8. [Admin Panel (Master PIN)](#-admin-panel-master-pin)
9. [Rješavanje Problema](#-rješavanje-problema)
10. [Česta Pitanja (FAQ)](#-česta-pitanja-faq)

---

## 🎯 Što je Client Terminal?

### Ukratko

**Vesta Lumina Client Terminal** je Android tablet aplikacija koja služi kao **digitalna recepcija** u vašem smještajnom objektu. Gosti koriste ovaj tablet za:

- ✅ Check-in putem skeniranja dokumenta (MRZ)
- ✅ Čitanje kućnih pravila na svom jeziku
- ✅ Digitalno potpisivanje dokumenata
- ✅ Dobivanje informacija od AI asistenta
- ✅ Gledanje WiFi lozinke i kontakata

### Kako Izgleda?

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│              🌅 DOBRODOŠLI U VILU SUNSET!                   │
│                                                             │
│              Dragi Marko, hvala što ste odabrali            │
│              naš smještaj za svoj odmor.                    │
│                                                             │
│     ─────────────────────────────────────────────────────   │
│                                                             │
│     📶 WiFi: VillaSunset_Guest                              │
│     🔑 Lozinka: Welcome2026                                 │
│                                                             │
│     ─────────────────────────────────────────────────────   │
│                                                             │
│     [📋 Kućna Pravila]  [🤖 Pitaj AI]  [📞 Kontakt]         │
│                                                             │
│     ─────────────────────────────────────────────────────   │
│                                                             │
│     🌍 [EN] [HR] [DE] [IT] [ES] [FR] [PL] [SK] [CS] [HU] [SL]│
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Kiosk Mode

Aplikacija radi u **kiosk načinu** - to znači:

- ❌ Gosti NE mogu izaći iz aplikacije
- ❌ Home i Back gumbi su onemogućeni
- ❌ System bar je skriven
- ✅ Samo vi možete pristupiti Admin panelu (s Master PIN-om)

---

## 📱 Postavljanje Tableta

### Hardverski Zahtjevi

| Zahtjev | Minimum | Preporučeno |
|---------|---------|-------------|
| **OS** | Android 8.0 (API 26) | Android 11+ |
| **RAM** | 2 GB | 4 GB |
| **Storage** | 2 GB slobodno | 4 GB slobodno |
| **Ekran** | 8" | 10" |
| **Kamera** | Stražnja 5 MP | Stražnja 8+ MP |
| **WiFi** | Da | Da (5 GHz) |

### Preporučeni Tableti

- Samsung Galaxy Tab A8 / A9
- Lenovo Tab M10
- Xiaomi Pad 5
- Bilo koji Android tablet s dobrom stražnjom kamerom

### Fizičko Postavljanje

```
     ┌─────────────────────────────────────────────────┐
     │                                                 │
     │    🪞 ZRCALO (ispod tableta, za MRZ skeniranje) │
     │                                                 │
     ├─────────────────────────────────────────────────┤
     │                                                 │
     │                  📱 TABLET                      │
     │              (montiran na zid)                  │
     │                                                 │
     │           Stražnja kamera gleda dolje           │
     │           prema zrcalu koje reflektira          │
     │           dokument koji gost drži               │
     │                                                 │
     └─────────────────────────────────────────────────┘
                          │
                          ▼
                    🔌 PUNJAČ
                (uvijek spojen!)
```

**VAŽNO:** Stražnja kamera se koristi za MRZ skeniranje. Zrcalo ispod tableta omogućuje gostima da vide što skeniraju.

---

## 🔗 Povezivanje s Web Panelom

### Korak 1: Instalacija Aplikacije

1. Preuzmite APK datoteku (dobiti ćete link od administratora)
2. Omogućite instalaciju iz nepoznatih izvora:
   - Postavke → Sigurnost → Nepoznati izvori → Uključi
3. Instalirajte APK

### Korak 2: Setup Screen

Kada prvi put pokrenete aplikaciju, vidjet ćete **Setup Screen**:

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│              📱 VESTA LUMINA                                │
│              Client Terminal                                │
│                                                             │
│     ─────────────────────────────────────────────────────   │
│                                                             │
│     Unesite kod jedinice:                                   │
│                                                             │
│     ┌─────────────────────────────────────┐                │
│     │                                     │                │
│     │         ABC123                      │                │
│     │                                     │                │
│     └─────────────────────────────────────┘                │
│                                                             │
│              [✅ Poveži]                                    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Korak 3: Unos Koda Jedinice

1. U **Web Panelu** otvorite jedinicu i pronađite **Unit Code**
2. Unesite taj kod na tabletu
3. Kliknite **"Poveži"**
4. Tablet će se povezati s Firebase i preuzeti sve podatke

### Korak 4: Gotovo!

Nakon uspješnog povezivanja:
- Tablet prikazuje Welcome Screen
- Svi podaci se automatski sinkroniziraju
- Tablet je spreman za goste!

---

## 👥 Kako Gosti Koriste Tablet

### Welcome Screen

Kada gost dodirne tablet (ili tablet izađe iz screensaver-a):

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│              🌍 ODABERITE JEZIK / SELECT LANGUAGE           │
│                                                             │
│     [🇬🇧 EN]  [🇭🇷 HR]  [🇩🇪 DE]  [🇮🇹 IT]  [🇪🇸 ES]  [🇫🇷 FR]  │
│                                                             │
│     [🇵🇱 PL]  [🇸🇰 SK]  [🇨🇿 CS]  [🇭🇺 HU]  [🇸🇮 SL]           │
│                                                             │
│     ─────────────────────────────────────────────────────   │
│                                                             │
│              DOBRODOŠLI / WELCOME                           │
│                                                             │
│     ─────────────────────────────────────────────────────   │
│                                                             │
│              [▶️ ZAPOČNI CHECK-IN]                          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Dashboard

Nakon check-ina (ili ako je check-in već obavljen), gost vidi Dashboard:

| Gumb | Funkcija |
|------|----------|
| **📋 Kućna Pravila** | Pravila boravka na odabranom jeziku |
| **🤖 Pitaj AI** | AI asistent za pitanja |
| **📞 Kontakt** | Hitni kontakti vlasnika |
| **⭐ Ostavi Recenziju** | Link na Airbnb/Booking recenziju |
| **🧹 Staff Access** | Pristup za čistače (traži PIN) |

### Screensaver

Kada tablet nije aktivan 2 minute:
- Aktivira se screensaver
- Prikazuju se lijepe slike (učitane kroz Web Panel)
- Dodir bilo gdje vraća na Welcome Screen

---

## ✅ Check-in Proces

### Zašto Check-in na Tabletu?

- Automatsko skeniranje MRZ zone s dokumenta
- Digitalni potpis kućnih pravila
- Podaci spremni za eVisitor prijavu
- Bez papira!

### Korak po Korak

**1. Gost odabire jezik i klikne "Započni Check-in"**

**2. Check-in Intro Screen**
```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│              📋 CHECK-IN                                    │
│                                                             │
│     Za check-in trebat ćemo:                                │
│     • Skenirati vaš dokument (putovnica ili osobna)         │
│     • Ponoviti za svakog gosta                              │
│     • Digitalno potpisati kućna pravila                     │
│                                                             │
│     Broj gostiju: 2                                         │
│                                                             │
│              [▶️ NASTAVI]                                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**3. Skeniranje Dokumenta (MRZ)**
```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│              📷 SKENIRAJTE DOKUMENT                         │
│              Gost 1 od 2                                    │
│                                                             │
│     ┌─────────────────────────────────────────┐            │
│     │                                         │            │
│     │           [KAMERA VIEW]                 │            │
│     │                                         │            │
│     │   Postavite MRZ zonu dokumenta          │            │
│     │   u okvir                               │            │
│     │                                         │            │
│     │   <<<<<<<<<<<<<<<<<<<<<<<<<<<<<         │            │
│     │   P<HRVHORVAT<<MARKO<<<<<<<<<<<         │            │
│     │                                         │            │
│     └─────────────────────────────────────────┘            │
│                                                             │
│     [📸 SNIMI RUČNO]                [🔄 POKUŠAJ PONOVNO]   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

- Kamera automatski skenira svakih 1.5 sekundi
- Kada prepozna MRZ, automatski prelazi na potvrdu
- Gost može i ručno kliknuti "Snimi"

**4. Potvrda Podataka**
```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│              ✅ POTVRDITE PODATKE                           │
│              Gost 1 od 2                                    │
│                                                             │
│     Ime:          Marko                                     │
│     Prezime:      Horvat                                    │
│     Datum rođ.:   15.03.1985                                │
│     Državlj.:     Hrvatska                                  │
│     Dokument:     Putovnica                                 │
│     Broj dok.:    AB1234567                                 │
│                                                             │
│     ⚠️ Ako podaci nisu točni, možete ih ispraviti          │
│                                                             │
│     [✏️ ISPRAVI]              [✅ POTVRDI I NASTAVI]        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**5. Ponovi za Svakog Gosta**

Ako ima više gostiju, proces skeniranja se ponavlja.

**6. Kućna Pravila + Potpis**
```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│              📋 KUĆNA PRAVILA                               │
│                                                             │
│     • Zabranjeno pušenje u objektu                          │
│     • Tihi sati od 22:00 do 08:00                          │
│     • Zabranjene zabave                                     │
│     • Kućni ljubimci nisu dozvoljeni                        │
│     • Maksimalan broj gostiju: 4                            │
│                                                             │
│     ─────────────────────────────────────────────────────   │
│                                                             │
│     Potpišite ovdje:                                        │
│     ┌─────────────────────────────────────────┐            │
│     │                                         │            │
│     │         ~~~~  Marko H.  ~~~~           │            │
│     │                                         │            │
│     └─────────────────────────────────────────┘            │
│                                                             │
│     [🗑️ OBRIŠI]               [✅ POTPIŠI I ZAVRŠI]        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**7. Uspjeh!**
```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│              🎉 CHECK-IN USPJEŠAN!                          │
│                                                             │
│     Hvala, Marko!                                           │
│                                                             │
│     Vaš boravak:                                            │
│     📅 15.01. - 20.01.2026                                 │
│                                                             │
│     Uživajte u odmoru! 🌅                                   │
│                                                             │
│              [▶️ NA POČETNU]                                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Što se Događa s Podacima?

1. **Lokalno:** Podaci se spremaju na tablet (za offline rad)
2. **Cloud:** Sinkroniziraju se s Firebase
3. **Web Panel:** Vi ih možete vidjeti u rezervaciji
4. **Potpis:** Sprema se kao slika u Firebase Storage
5. **GDPR:** Automatski se brišu nakon checkout-a

---

## 🤖 AI Asistent

### Što je AI Asistent?

AI asistent (powered by Gemini) odgovara na pitanja gostiju koristeći znanje koje ste vi definirali u Web Panelu.

### Kategorije Znanja

U Web Panelu možete definirati 4 kategorije AI znanja:

| Kategorija | Primjer Sadržaja |
|------------|------------------|
| **🍽️ Concierge** | Restorani, kafići, noćni život, shopping |
| **🧹 Housekeeper** | Gdje su sredstva za čišćenje, kako radi perilica |
| **💻 Tech** | WiFi troubleshooting, kako radi TV, klima |
| **🗺️ Guide** | Plaže, znamenitosti, parking, javni prijevoz |

### Primjer Razgovora

```
Gost: "Gdje mogu ručati?"

AI:   "🍽️ Preporučujem ove restorane u blizini:

       1. Konoba Fetivi (5 min hoda)
          - Specijalitet: Crni rižot
          - Cijene: 15-25€
          - Tel: +385 21 123 456

       2. Pizzeria Galija (10 min hoda)
          - Specijalitet: Pizza napolitana
          - Cijene: 8-15€
          - Tel: +385 21 789 012

       Trebate upute kako doći?"
```

---

## 🧹 Pristup za Čistače

### Kako Čistač Pristupa?

1. Na Dashboard-u klikne **"🧹 Staff Access"**
2. Unosi **Cleaner PIN** (4 znamenke)
3. Otvara se Cleaner Tasks Screen

### Cleaner Tasks Screen

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│              🧹 ZADACI ČIŠĆENJA                             │
│              Vila Sunset                                    │
│                                                             │
│     ☐ Provjeriti i zamijeniti posteljinu                   │
│     ☐ Temeljito očistiti kupaonicu                         │
│     ☐ Nadopuniti toaletne potrepštine                      │
│     ☐ Iznijeti smeće                                        │
│     ☐ Usisati sve podove                                    │
│     ☐ Obrisati kuhinjske površine                          │
│                                                             │
│     ─────────────────────────────────────────────────────   │
│                                                             │
│     Napomena:                                               │
│     ┌─────────────────────────────────────────┐            │
│     │ Gost traži dodatne ručnike              │            │
│     └─────────────────────────────────────────┘            │
│                                                             │
│     [✅ ZAVRŠI I SPREMI]              [❌ ODUSTANI]         │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Nakon Završetka

- Podaci o čišćenju se šalju u Firebase
- Vi možete vidjeti izvještaj u Web Panelu
- Timestamp se automatski bilježi

---

## 🔐 Admin Panel (Master PIN)

### Što je Admin Panel?

Admin Panel je zaštićeni dio aplikacije namijenjen samo za vas (vlasnika). Pristupa se **Master PIN-om** (6 znamenki).

### Kako Pristupiti?

1. Na Dashboard-u kliknite **"🧹 Staff Access"**
2. Umjesto Cleaner PIN-a, unesite **Master PIN**
3. Otvara se Admin Menu

### Admin Menu Opcije

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│              ⚙️ ADMIN MENU                                  │
│                                                             │
│     [🔍 Debug Panel]                                        │
│     Dijagnostika, status Firebase, testovi                  │
│                                                             │
│     [⏸️ Privremeno Isključi Kiosk]                          │
│     5 minuta pristupa Android sustavu                       │
│                                                             │
│     [🔄 Sync Sada]                                          │
│     Ručna sinkronizacija s Firebase                         │
│                                                             │
│     [🗑️ Factory Reset]                                      │
│     Odspoji tablet od jedinice                              │
│                                                             │
│     [❌ Zatvori]                                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Debug Panel (5 tabova)

| Tab | Sadržaj |
|-----|---------|
| **Status** | Device info, kiosk status, battery, network |
| **Firebase** | Live Firestore pregled, connection status |
| **Storage** | Lokalni Hive podaci, cached bookings |
| **Tests** | Automatski testovi servisa |
| **Actions** | Quick navigation, clear cache |

### Factory Reset

**UPOZORENJE:** Factory Reset briše sve lokalne podatke i odspaja tablet od jedinice!

1. Kliknite **"🗑️ Factory Reset"**
2. Potvrdite akciju
3. Tablet se vraća na Setup Screen
4. Trebat ćete ponovno unijeti Unit Code

---

## 🔧 Rješavanje Problema

### Tablet se ne povezuje s Firebase

**Simptomi:** "Network error", podaci se ne ažuriraju

**Rješenje:**
1. Provjerite WiFi vezu
2. Otvorite Admin Panel → Debug Panel → Firebase tab
3. Provjerite "Connection Status"
4. Kliknite "Sync Sada"

### MRZ skeniranje ne radi

**Simptomi:** Kamera ne prepoznaje dokument

**Rješenje:**
1. Provjerite osvjetljenje (ne presigrno, ne pretamno)
2. Očistite leću kamere
3. Provjerite je li zrcalo čisto i pravilno postavljeno
4. Pokušajte ručno kliknuti "Snimi"

### Screensaver se ne aktivira

**Simptomi:** Ekran ostaje upaljen

**Rješenje:**
1. Provjerite je li screensaver uključen u Web Panelu
2. Timeout je 2 minute neaktivnosti
3. Ako ne radi, restartajte aplikaciju

### Kiosk mode se isključio

**Simptomi:** Gost može izaći iz aplikacije

**Rješenje:**
1. Otvorite aplikaciju ponovno
2. Kiosk se automatski uključuje
3. Provjerite u Web Panelu je li Kiosk omogućen

### Zaboravljen Master PIN

**Rješenje:**
1. Kontaktirajte administratora
2. Administrator može resetirati PIN u Firebase Console
3. Ili: Factory reset tableta (zahtijeva fizički pristup)

---

## ❓ Česta Pitanja (FAQ)

### Postavljanje

**P: Mogu li koristiti prednju kameru za skeniranje?**
O: Ne preporučujemo. Stražnja kamera ima bolju kvalitetu. Koristite zrcalo za refleksiju.

**P: Što ako nemam zrcalo?**
O: Gost može okrenuti dokument prema kameri, ali je nezgodnije.

**P: Mora li tablet biti uvijek na punjaču?**
O: Da, preporučujemo. Kiosk mode troši bateriju.

### Za Goste

**P: Mogu li gosti izaći iz aplikacije?**
O: Ne u kiosk modu. Home i Back gumbi su onemogućeni.

**P: Što ako gost unese krivu lozinku za Staff Access?**
O: Nakon 5 krivih pokušaja, tablet se zaključava na 5 minuta (brute-force zaštita).

**P: Mogu li gosti vidjeti podatke drugih gostiju?**
O: Ne. Svaki gost vidi samo svoje podatke i opće informacije.

### Offline Rad

**P: Što se događa kad nestane internet?**
O: Tablet radi u offline modu. Podaci se lokalno spremaju i sinkroniziraju kad se veza vrati.

**P: Može li se check-in obaviti offline?**
O: Da! Podaci se spremaju lokalno i šalju u cloud kad se veza uspostavi.

### Sigurnost

**P: Što ako netko ukrade tablet?**
O: Tablet je beskoristan bez Unit Code-a. Možete ga udaljeno deregistrirati.

**P: Brišu li se podaci gostiju?**
O: Da, automatski nakon checkout-a (GDPR compliance).

---

## 📞 Podrška

Za tehničku pomoć:

- **Email:** nevenroksa@gmail.com
- **GitHub:** @nroxa92

---

## 📜 Napomena

```
Ovaj priručnik odnosi se na Vesta Lumina Client Terminal verziju 0.0.9 Beta.
Funkcionalnosti se mogu razlikovati u novijim verzijama.

Part of Vesta Lumina System:
• Vesta Lumina Admin Panel (Web)
• Vesta Lumina Client Terminal (Tablet)

© 2025-2026 Sva prava pridržana.
```
