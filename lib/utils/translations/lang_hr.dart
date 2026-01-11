// FILE: lib/utils/translations/lang_hr.dart
// VERZIJA: 4.0 - HRVATSKI
// DATUM: 2026-01-11

const Map<String, String> hrTranslations = {
  // ════════════════════════════════════════════════════════════════════════
  // WELCOME SCREEN
  // ════════════════════════════════════════════════════════════════════════
  'welcome_app_title': 'VILLA CONCIERGE',
  'welcome_select_language': 'Molimo odaberite jezik',
  'welcome_powered_by': 'Pokreće VillaOS',
  'welcome_title': 'Dobrodošli u\nVilla Mare',
  'welcome_subtitle': 'Kako vam mogu pomoći?',

  // ════════════════════════════════════════════════════════════════════════
  // CHECK-IN INTRO
  // ════════════════════════════════════════════════════════════════════════
  'intro_title': 'Online Prijava',
  'intro_desc': 'Prema zakonu o turizmu, obvezni smo prijaviti sve goste.',
  'start_btn': 'ZAPOČNI PRIJAVU',
  'skip_btn': 'Kasnije (Preskoči)',
  'gdpr_badge': 'GDPR sukladno • Podaci zaštićeni',
  'consents_title': 'POTREBNI PRISTANCI',
  'consents_subtitle': 'Molimo pročitajte i prihvatite oba dokumenta',
  'gdpr_consent_title': 'Pristanak za obradu podataka (GDPR)',
  'truth_consent_title': 'Izjava i suglasnost za skeniranje',
  'consent_gdpr': 'Pristajem na skeniranje dokumenata za eVisitor. Fotografije se ne pohranjuju.',
  'consent_truth': 'Potvrđujem da su podaci točni.',
  'gdpr_full_text': 'Vaši dokumenti se skeniraju samo za izdvajanje podataka. Fotografije se NE pohranjuju.',
  'truth_full_text': 'Izjavljujem da su svi navedeni podaci istiniti i točni.',
  'btn_accept': 'PRIHVAĆAM',

  // ════════════════════════════════════════════════════════════════════════
  // DOCUMENT SELECTION
  // ════════════════════════════════════════════════════════════════════════
  'doc_select_title': 'Vrsta dokumenta',
  'issuing_country': 'DRŽAVA IZDAVATELJA',
  'doc_type': 'VRSTA DOKUMENTA',
  'doc_id_card': 'Osobna iskaznica',
  'doc_passport': 'Putovnica',
  'doc_id_sub': 'Obostrano',
  'doc_passport_sub': 'Stranica sa slikom',
  'open_camera': 'OTVORI KAMERU',

  // ════════════════════════════════════════════════════════════════════════
  // CAMERA SCREEN
  // ════════════════════════════════════════════════════════════════════════
  'cam_permission_needed': 'Potrebna je dozvola za kameru',
  'cam_not_found': 'Kamera nije pronađena',
  'cam_error': 'Greška kamere',
  'cam_initializing': 'Inicijalizacija kamere...',
  'cam_front_side': 'Prednja',
  'cam_back_side': 'Stražnja',
  'cam_guest': 'Gost',
  'cam_skip_to_back': 'PRESKOČI NA STRAŽNJU >',
  'cam_skip_to_review': 'PRESKOČI NA PREGLED >',
  'cam_position_doc': '📄 Postavite dokument u okvir',
  'cam_position_mrz': '📄 Postavite MRZ zonu u okvir',
  'cam_flip_doc': '🔄 Okrenite dokument na STRAŽNJU stranu',
  'cam_front_complete': '✅ Prednja gotova! Sada skenirajte STRAŽNJU',
  'cam_mrz_detected': '✅ MRZ Prepoznat!',
  'cam_scanning_mrz': 'Skeniranje MRZ zone...',
  'cam_personal_data': 'OSOBNI PODACI',
  'cam_address_data': 'ADRESA',
  'cam_scanning': 'Skeniranje...',
  'cam_detected': 'prepoznato',
  'cam_reset_field': 'Resetiraj polje',
  'cam_continue_manual': 'NASTAVI RUČNO →',
  'cam_verify_data': 'Provjerite i ispravite ako je potrebno',
  'cam_name_required': 'Ime i prezime su obavezni',
  'cam_guest_saved': 'Gost spremljen:',
  'cam_save_next': 'SPREMI I SLJEDEĆI GOST',
  'cam_finish_checkin': 'ZAVRŠI PRIJAVU',
  // NEW - Camera screen additions
  'cam_back_scanned': 'Stražnja strana skenirana!',
  'cam_mrz_not_found': 'MRZ nije pronađen. Pokušajte ponovo.',
  'cam_processing': 'Obrada...',
  'cam_manual_entry': 'Ručni unos',
  'cam_skip_scan_confirm': 'Želite li preskočiti skeniranje i ručno unijeti podatke?',
  'cam_yes_manual': 'Da, ručni unos',
  'cam_manual': 'Ručno',
  'cam_position_back': 'Postavite STRAŽNJU stranu dokumenta\n(MRZ zona s <<<)',
  'cam_position_front': 'Postavite PREDNJU stranu dokumenta\n(sa slikom)',
  'cam_mrz_zone': 'MRZ ZONA',

  // ════════════════════════════════════════════════════════════════════════
  // GUEST CONFIRMATION SCREEN
  // ════════════════════════════════════════════════════════════════════════
  'confirm_rescan': 'Ponovi sken',
  'confirm_fill_fields': 'Popunite polja',
  'confirm_fields_required': 'Sva polja su obavezna za eVisitor prijavu',
  'confirm_place_of_birth': 'Mjesto rođenja',
  'confirm_country_of_birth': 'Država rođenja',
  'confirm_document': 'DOKUMENT',
  'confirm_residence': 'PREBIVALIŠTE',
  'confirm_country': 'Država',
  'confirm_city': 'Grad',
  'confirm_stay': 'BORAVAK',
  'confirm_arrival': 'Dolazak',
  'confirm_departure': 'Odlazak',
  'confirm_next_guest': 'Potvrdi i sljedeći gost',
  'confirm_continue': 'Potvrdi i nastavi',
  'confirm_male': 'M (Muški)',
  'confirm_female': 'Ž (Ženski)',

  // ════════════════════════════════════════════════════════════════════════
  // CHECK-IN SUCCESS SCREEN
  // ════════════════════════════════════════════════════════════════════════
  'success_checkin_complete': 'CHECK-IN USPJEŠAN!',
  'success_welcome': 'Dobrodošli',
  'success_guest': 'Gost',
  'success_guests': 'Gostiju',
  'success_duration': 'Trajanje',
  'success_confirmed': 'Potvrđeno',
  'success_auto_redirect': 'Automatski prelazak za {seconds} sekundi...',

  // ════════════════════════════════════════════════════════════════════════
  // FORM FIELDS
  // ════════════════════════════════════════════════════════════════════════
  'field_first_name': 'Ime',
  'field_last_name': 'Prezime',
  'field_doc_number': 'Broj dokumenta',
  'field_birth_date': 'Datum rođenja',
  'field_gender': 'Spol',
  'field_nationality': 'Državljanstvo',
  'field_address': 'Adresa',
  'field_expiry_date': 'Datum isteka',

  // ════════════════════════════════════════════════════════════════════════
  // BUTTONS
  // ════════════════════════════════════════════════════════════════════════
  'btn_retake': 'Ponovi',
  'btn_next': 'Dalje',
  'btn_finish': 'Završi',
  'btn_cancel': 'Odustani',
  'btn_close': 'Zatvori',
  'btn_confirm': 'Potvrdi',
  'btn_done': 'GOTOVO',
  'btn_back': 'Natrag',
  'btn_save': 'Spremi',
  'btn_continue': 'Nastavi',

  // ════════════════════════════════════════════════════════════════════════
  // HOUSE RULES
  // ════════════════════════════════════════════════════════════════════════
  'house_rules_title': 'KUĆNA PRAVILA',
  'house_rules_subtitle': 'Molimo pročitajte i potpišite za nastavak.',
  'guest_signature': 'POTPIS GOSTA',
  'guest_name': 'IME I PREZIME',
  'enter_name': 'Unesite ime i prezime',
  'enter_name_first': 'Unesite ime',
  'signature': 'POTPIS',
  'sign_here': 'Potpišite prstom ovdje',
  'clear': 'Obriši',
  'signature_legal': 'Potpisom potvrđujete da ste pročitali i prihvaćate ova kućna pravila.',
  'agree_continue': 'PRIHVAĆAM I NASTAVLJAM',
  'please_sign': 'POTPIŠITE',
  'rules_accepted': 'Pravila prihvaćena! PDF generiran.',
  'error': 'Greška',

  // ════════════════════════════════════════════════════════════════════════
  // DASHBOARD
  // ════════════════════════════════════════════════════════════════════════
  'default_villa_name': 'Villa Gost',
  'loading_stay': 'Učitavam vaš boravak...',
  'welcome_comma': 'Dobrodošli,',
  'welcome_to': 'Dobrodošli u',
  'guests_count': '{count} gostiju',
  'checkout_label': 'Odjava:',
  'wifi_pass_label': 'Lozinka:',
  'check_in_complete': 'PRIJAVA ZAVRŠENA',
  'check_out': 'Odjava',
  'checkout_confirm': 'Jeste li sigurni da se želite odjaviti?',
  'checkout_date_info': 'Datum odjave: {date}',
  'need_help': 'Trebate pomoć?',
  'contact_host': 'Kontaktirajte domaćina:',
  'agent_reception': 'Recepcija',
  'agent_house': 'Pametna Kuća',
  'agent_gastro': 'Gastro Vodič',
  'agent_local': 'Lokalni Vodič',
  'agent_desc_reception': 'Chat, FAQ, Pomoć',
  'agent_desc_house': 'Klima, Svjetla, Bazen',
  'agent_desc_gastro': 'Restorani i Dostava',
  'agent_desc_local': 'Plaže, Ture, Događaji',

  // ════════════════════════════════════════════════════════════════════════
  // CHAT
  // ════════════════════════════════════════════════════════════════════════
  'thinking': 'Razmišljam...',
  'type_message': 'Upišite poruku...',
  'chat_hello': 'Pozdrav',
  'chat_hello_name': 'Pozdrav {name}!',
  'chat_no_internet': 'Nema interneta. AI asistent nedostupan.',
  'chat_error': 'Žao mi je, imam problema s povezivanjem. Molimo pokušajte ponovno.',
  'chat_no_internet_places': 'Nema interneta. Ne mogu pretraživati mjesta.',
  'chat_search_failed': 'Pretraživanje neuspjelo. Provjerite internet vezu.',
  'chat_connecting': 'Povezujem se na {agent}...',
  'status_online': 'Online',
  'status_offline': 'Offline',
  'quick_wifi': '📶 WiFi lozinka?',
  'quick_wifi_full': 'Koja je WiFi lozinka?',
  'quick_checkout_time': '🕐 Vrijeme odjave?',
  'quick_checkout_time_full': 'U koje vrijeme je odjava?',
  'quick_rules': '📋 Kućna pravila',
  'quick_rules_full': 'Pokaži mi kućna pravila',
  'quick_contact': '📞 Kontakt domaćin',
  'quick_contact_full': 'Kako mogu kontaktirati domaćina?',
  'find_nearby': 'Pronađi u blizini',
  'searching_nearby': 'Tražim u blizini...',
  'searching_restaurants': 'Tražim restorane...',
  'searching_attractions': 'Tražim atrakcije...',
  'searching_pharmacy': 'Tražim ljekarne/doktore...',
  'places_found': 'Evo nekoliko najbolje ocijenjenih mjesta u blizini:',
  'no_places_found': 'Nisam pronašao mjesta u blizini. Provjerite je li adresa vile ispravna.',

  // ════════════════════════════════════════════════════════════════════════
  // FEEDBACK
  // ════════════════════════════════════════════════════════════════════════
  'feedback_title': 'Odjava i Recenzija',
  'feedback_subtitle': 'Prije odlaska, ocijenite svoj boravak.',
  'thank_you': 'Hvala',
  'feedback_comment_label': 'ŠTO MOŽEMO POBOLJŠATI?',
  'feedback_comment_hint': 'Recite nam što možemo učiniti bolje...',
  'submit_feedback': 'POŠALJI RECENZIJU',
  'skip_feedback': 'Preskoči i Odjavi se',
  'thank_you_perfect': 'Vi ste nevjerojatni! 💖',
  'thank_you_feedback': 'Hvala Vam!',
  'perfect_stay_message': 'Drago nam je da ste uživali! Ako imate trenutak, ostavite nam recenziju.',
  'feedback_received_message': 'Vaša povratna informacija nam pomaže. Sretan put!',
  'feedback_offline_saved': 'Recenzija spremljena. Sinkronizirat će se kad bude online.',
  'scan_for_review': 'Skenirajte za Google Recenziju',
  'glad_you_enjoyed': 'Drago nam je da ste uživali u boravku!',
  'complete_checkout': 'ZAVRŠI ODJAVU',
  'touch_to_continue': 'Dodirnite ekran za nastavak',
  'rating_1': 'Vrlo loše 😞',
  'rating_2': 'Loše 😕',
  'rating_3': 'Prosječno 😐',
  'rating_4': 'Dobro 😊',
  'rating_5': 'Izvrsno! 🤩',

  // ════════════════════════════════════════════════════════════════════════
  // CLEANER
  // ════════════════════════════════════════════════════════════════════════
  'cleaner_title': 'Pristup Osoblju',
  'cleaner_mode': 'NAČIN ČIŠĆENJA',
  'cleaner_checklist': 'Lista Čišćenja',
  'cleaner_booking_label': 'Rezervacija:',
  'cleaner_tasks_label': 'ZADACI',
  'cleaner_notes': 'Prijavi Problem / Napomene',
  'cleaner_notes_label': 'NAPOMENE ZA VLASNIKA',
  'cleaner_notes_hint': 'Prijavite probleme, stvari koje nedostaju ili bilo što što vlasnik treba znati.',
  'cleaner_notes_placeholder': 'npr. Pokvarena lampa u spavaćoj sobi, niska razina šampona...',
  'cleaner_privacy_notice': 'Kada pritisnete ZAVRŠI, potpisi gostiju i skenirani dokumenti bit će trajno izbrisani radi privatnosti.',
  'cleaner_not_all_tasks': 'Nisu svi zadaci označeni.\nJeste li sigurni da želite završiti?',
  'cleaner_finish_anyway': 'SVEJEDNO ZAVRŠI',
  'cleaner_offline_saved': 'Izvještaj spremljen. Sinkronizirat će se kad bude online.',
  'cleaner_processing': 'OBRAĐUJEM...',
  'cleaner_complete_btn': 'ZAVRŠENO',
  'cleaner_finish_btn': 'ZAVRŠI I PRIJAVI',
  'cleaner_finish': 'ZAVRŠI I RESETIRAJ ZA GOSTA',
  'cleaner_cleanup_progress': 'Čišćenje podataka...',
  'cleaner_cleanup_archive': 'Arhiviranje rezervacije, brisanje potpisa...',
  'cleaner_complete_title': 'Čišćenje Završeno!',
  'cleaner_summary_title': 'Sažetak Čišćenja Podataka',
  'cleaner_signatures_deleted': 'Potpisi izbrisani',
  'cleaner_guests_deleted': 'Zapisi gostiju izbrisani',
  'cleaner_booking_archived': 'Rezervacija arhivirana',
  'cleaner_report_queued': 'Izvještaj na čekanju. Čišćenje podataka pokrenut će se kad bude online.',
  'cleaner_success_online': 'Izvještaj poslan vlasniku.\nTablet je spreman za nove goste.',
  'cleaner_success_offline': 'Izvještaj spremljen lokalno.\nTablet je spreman za nove goste.',
  'cleaner_default_error': 'Korištenje zadane liste (nije moguće učitati s poslužitelja)',

  // ════════════════════════════════════════════════════════════════════════
  // KIOSK MODE
  // ════════════════════════════════════════════════════════════════════════
  'kiosk_mode_title': 'Kiosk Mode',
  'kiosk_enter_pin': 'Unesite 6-znamenkasti PIN za izlaz:',
  'kiosk_enter_all_digits': 'Unesite svih 6 znamenki',
  'kiosk_too_many_attempts': 'Previše pokušaja. Pokušajte kasnije.',
  'kiosk_wrong_pin_attempts': 'Pogrešan PIN. Preostalo pokušaja: {attempts}',
  'kiosk_contact_admin': 'Kontaktirajte administratora ako ne znate PIN.',
  'kiosk_unlock': 'Otključaj',

  // ════════════════════════════════════════════════════════════════════════
  // PIN
  // ════════════════════════════════════════════════════════════════════════
  'pin_title': 'Unesite PIN',
  'pin_cleaner_title': 'Pristup Osoblju',
  'pin_admin_title': 'Admin Pristup',
  'pin_enter': 'Unesite PIN kod',
  'pin_incorrect': 'Neispravan PIN',
  'pin_attempts_left': 'Preostalo pokušaja: {count}',
  'pin_locked': 'Previše pokušaja. Pokušajte ponovno za {minutes} minuta.',
  'pin_forgot': 'Zaboravili PIN?',

  // ════════════════════════════════════════════════════════════════════════
  // SETUP
  // ════════════════════════════════════════════════════════════════════════
  'setup_app_name': 'VillaOS',
  'setup_app_subtitle': 'Digitalni Recepcijski Sustav',
  'setup_tagline': 'Recepcija\nKoja Nikad Ne Spava',
  'setup_description': 'Automatizirajte prijavu, oduševite goste,\npoboljšajte recenzije',
  'setup_connect_title': 'POVEŽI UREĐAJ',
  'setup_connect_subtitle': 'Povežite ovaj tablet s vašim objektom',
  'setup_tenant_label': 'Tenant ID',
  'setup_tenant_hint': 'npr. TEST22',
  'setup_unit_label': 'Unit ID',
  'setup_unit_hint': 'npr. PLAVI',
  'setup_btn_connect': 'POVEŽI',
  'setup_connecting': 'Povezujem...',
  'setup_finding_unit': 'Tražim jedinicu...',
  'setup_registering': 'Registriram uređaj...',
  'setup_syncing': 'Sinkroniziram postavke...',
  'setup_connected': 'Povezano!',
  'setup_stat_properties': 'Objekata',
  'setup_stat_checkins': 'Prijava',
  'setup_stat_uptime': 'Dostupnost',

  // ════════════════════════════════════════════════════════════════════════
  // VALIDATION
  // ════════════════════════════════════════════════════════════════════════
  'validation_required': 'Obavezno',
  'validation_invalid': 'Neispravan unos',
  'validation_too_short': 'Prekratko',
  'validation_too_long': 'Predugo',

  // ════════════════════════════════════════════════════════════════════════
  // ADMIN
  // ════════════════════════════════════════════════════════════════════════
  'admin_title': 'Admin Panel',
  'admin_unit_label': 'Jedinica:',
  'admin_not_available': 'N/A',
  'admin_debug': 'Debug Panel',
  'admin_kiosk_disable': 'Isključi Kiosk (5 min)',
  'admin_sync': 'Sinkroniziraj',
  'admin_factory_reset': 'Tvorničke postavke',
  'admin_factory_reset_confirm': 'Ovo će odspojiti tablet od jedinice. Jeste li sigurni?',
  'debug_status': 'Status',
  'debug_firebase': 'Firebase',
  'debug_storage': 'Pohrana',
  'debug_tests': 'Testovi',
  'debug_actions': 'Akcije',

  // ════════════════════════════════════════════════════════════════════════
  // OFFLINE
  // ════════════════════════════════════════════════════════════════════════
  'offline_banner': 'Nema internetske veze',
  'offline_limited': 'Ograničena funkcionalnost',
  'offline_reconnecting': 'Ponovno povezivanje...',
  'offline_connected': 'Ponovno online!',

  // ════════════════════════════════════════════════════════════════════════
  // ERRORS
  // ════════════════════════════════════════════════════════════════════════
  'error_generic': 'Nešto je pošlo po zlu',
  'error_network': 'Mrežna greška',
  'error_try_again': 'Molimo pokušajte ponovno',
  'error_timeout': 'Isteklo vrijeme zahtjeva',
  'error_not_found': 'Nije pronađeno',
};
