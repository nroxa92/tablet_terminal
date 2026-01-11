// FILE: lib/utils/translations/lang_hu.dart
// VERZIJA: 4.0 - MAGYAR
// DATUM: 2026-01-11

const Map<String, String> huTranslations = {
  // ════════════════════════════════════════════════════════════════════════
  // WELCOME SCREEN
  // ════════════════════════════════════════════════════════════════════════
  'welcome_app_title': 'VILLA CONCIERGE',
  'welcome_select_language': 'Kérjük, válassza ki a nyelvet',
  'welcome_powered_by': 'Powered by VillaOS',
  'welcome_title': 'Üdvözöljük a\nVilla Mare-ban',
  'welcome_subtitle': 'Miben segíthetek ma?',

  // ════════════════════════════════════════════════════════════════════════
  // CHECK-IN INTRO
  // ════════════════════════════════════════════════════════════════════════
  'intro_title': 'Online bejelentkezés',
  'intro_desc': 'A turisztikai törvények szerint kötelesek vagyunk minden vendéget regisztrálni.',
  'start_btn': 'BEJELENTKEZÉS INDÍTÁSA',
  'skip_btn': 'Később (Kihagyás)',
  'gdpr_badge': 'GDPR kompatibilis • Adatok védettek',
  'consents_title': 'SZÜKSÉGES HOZZÁJÁRULÁSOK',
  'consents_subtitle': 'Kérjük, olvassa el és fogadja el mindkét dokumentumot',
  'gdpr_consent_title': 'Adatkezelési hozzájárulás (GDPR)',
  'truth_consent_title': 'Nyilatkozat és szkennelési hozzájárulás',
  'consent_gdpr': 'Hozzájárulok a dokumentumok szkenneléshez az eVisitor regisztrációhoz. Fotók nem kerülnek tárolásra.',
  'consent_truth': 'Megerősítem, hogy a megadott adatok helyesek.',
  'gdpr_full_text': 'Dokumentumai csak az adatok kinyeréséhez kerülnek szkennelésre. A fotók NEM kerülnek tárolásra.',
  'truth_full_text': 'Kijelentem, hogy minden megadott információ igaz és pontos.',
  'btn_accept': 'ELFOGADOM',

  // ════════════════════════════════════════════════════════════════════════
  // DOCUMENT SELECTION
  // ════════════════════════════════════════════════════════════════════════
  'doc_select_title': 'Válassza ki a dokumentum típusát',
  'issuing_country': 'KIÁLLÍTÓ ORSZÁG',
  'doc_type': 'DOKUMENTUM TÍPUSA',
  'doc_id_card': 'Személyi igazolvány',
  'doc_passport': 'Útlevél',
  'doc_id_sub': 'Elülső és hátsó oldal',
  'doc_passport_sub': 'Fényképes oldal',
  'open_camera': 'KAMERA MEGNYITÁSA',

  // ════════════════════════════════════════════════════════════════════════
  // CAMERA SCREEN
  // ════════════════════════════════════════════════════════════════════════
  'cam_permission_needed': 'Kamera engedély szükséges',
  'cam_not_found': 'Kamera nem található',
  'cam_error': 'Kamera hiba',
  'cam_initializing': 'Kamera inicializálása...',
  'cam_front_side': 'Elülső',
  'cam_back_side': 'Hátsó',
  'cam_guest': 'Vendég',
  'cam_skip_to_back': 'UGRÁS A HÁTSÓRA >',
  'cam_skip_to_review': 'UGRÁS AZ ELLENŐRZÉSRE >',
  'cam_position_doc': '📄 Helyezze a dokumentumot a keretbe',
  'cam_position_mrz': '📄 Helyezze az MRZ zónát a keretbe',
  'cam_flip_doc': '🔄 Fordítsa a dokumentumot a HÁTSÓ oldalra',
  'cam_front_complete': '✅ Elülső oldal kész! Most szkennelje a HÁTSÓ oldalt',
  'cam_mrz_detected': '✅ MRZ Észlelve!',
  'cam_scanning_mrz': 'MRZ zóna szkennelése...',
  'cam_personal_data': 'SZEMÉLYES ADATOK',
  'cam_address_data': 'CÍM',
  'cam_scanning': 'Szkennelés...',
  'cam_detected': 'észlelve',
  'cam_reset_field': 'Mező visszaállítása',
  'cam_continue_manual': 'FOLYTATÁS KÉZILEG →',
  'cam_verify_data': 'Kérjük, ellenőrizze és javítsa ha szükséges',
  'cam_name_required': 'Keresztnév és vezetéknév kötelező',
  'cam_guest_saved': 'Vendég mentve:',
  'cam_save_next': 'MENTÉS & KÖVETKEZŐ VENDÉG',
  'cam_finish_checkin': 'BEJELENTKEZÉS BEFEJEZÉSE',
  'cam_back_scanned': 'Hátsó oldal beszkennelve!',
  'cam_mrz_not_found': 'MRZ nem található. Próbálja újra.',
  'cam_processing': 'Feldolgozás...',
  'cam_manual_entry': 'Kézi bevitel',
  'cam_skip_scan_confirm': 'Szeretné kihagyni a szkennelést és kézzel megadni az adatokat?',
  'cam_yes_manual': 'Igen, kézzel',
  'cam_manual': 'Kézi',
  'cam_position_back': 'Helyezze a dokumentum HÁTSÓ oldalát\n(MRZ zóna a <<<-vel)',
  'cam_position_front': 'Helyezze a dokumentum ELÜLSŐ oldalát\n(fényképpel)',
  'cam_mrz_zone': 'MRZ ZÓNA',

  // ════════════════════════════════════════════════════════════════════════
  // GUEST CONFIRMATION SCREEN
  // ════════════════════════════════════════════════════════════════════════
  'confirm_rescan': 'Újraszkennelés',
  'confirm_fill_fields': 'Töltse ki a mezőket',
  'confirm_fields_required': 'Minden mező kötelező az eVisitor regisztrációhoz',
  'confirm_place_of_birth': 'Születési hely',
  'confirm_country_of_birth': 'Születési ország',
  'confirm_document': 'DOKUMENTUM',
  'confirm_residence': 'LAKHELY',
  'confirm_country': 'Ország',
  'confirm_city': 'Város',
  'confirm_stay': 'TARTÓZKODÁS',
  'confirm_arrival': 'Érkezés',
  'confirm_departure': 'Távozás',
  'confirm_next_guest': 'Megerősítés & következő vendég',
  'confirm_continue': 'Megerősítés & folytatás',
  'confirm_male': 'F (Férfi)',
  'confirm_female': 'N (Nő)',

  // ════════════════════════════════════════════════════════════════════════
  // CHECK-IN SUCCESS SCREEN
  // ════════════════════════════════════════════════════════════════════════
  'success_checkin_complete': 'BEJELENTKEZÉS SIKERES!',
  'success_welcome': 'Üdvözöljük',
  'success_guest': 'Vendég',
  'success_guests': 'Vendég',
  'success_duration': 'Időtartam',
  'success_confirmed': 'Megerősítve',
  'success_auto_redirect': 'Automatikus átirányítás {seconds} másodperc múlva...',

  // ════════════════════════════════════════════════════════════════════════
  // FORM FIELDS
  // ════════════════════════════════════════════════════════════════════════
  'field_first_name': 'Keresztnév',
  'field_last_name': 'Vezetéknév',
  'field_doc_number': 'Dokumentum szám',
  'field_birth_date': 'Születési dátum',
  'field_gender': 'Nem',
  'field_nationality': 'Állampolgárság',
  'field_address': 'Cím',
  'field_expiry_date': 'Lejárati dátum',

  // ════════════════════════════════════════════════════════════════════════
  // BUTTONS
  // ════════════════════════════════════════════════════════════════════════
  'btn_retake': 'Újra',
  'btn_next': 'Következő',
  'btn_finish': 'Befejezés',
  'btn_cancel': 'Mégse',
  'btn_close': 'Bezárás',
  'btn_confirm': 'Megerősítés',
  'btn_done': 'KÉSZ',
  'btn_back': 'Vissza',
  'btn_save': 'Mentés',
  'btn_continue': 'Folytatás',

  // ════════════════════════════════════════════════════════════════════════
  // HOUSE RULES
  // ════════════════════════════════════════════════════════════════════════
  'house_rules_title': 'HÁZIEND',
  'house_rules_subtitle': 'Kérjük, olvassa el és írja alá a folytatáshoz.',
  'guest_signature': 'VENDÉG ALÁÍRÁSA',
  'guest_name': 'TELJES NÉV',
  'enter_name': 'Adja meg teljes nevét',
  'enter_name_first': 'Először adja meg a nevet',
  'signature': 'ALÁÍRÁS',
  'sign_here': 'Írja alá itt az ujjával',
  'clear': 'Törlés',
  'signature_legal': 'Aláírásával megerősíti, hogy elolvasta és elfogadja ezt a házirendet.',
  'agree_continue': 'ELFOGADOM ÉS FOLYTATOM',
  'please_sign': 'KÉRJÜK ÍRJA ALÁ',
  'rules_accepted': 'Szabályok elfogadva! PDF létrehozva.',
  'error': 'Hiba',

  // ════════════════════════════════════════════════════════════════════════
  // DASHBOARD
  // ════════════════════════════════════════════════════════════════════════
  'default_villa_name': 'Villa Vendég',
  'loading_stay': 'Tartózkodás betöltése...',
  'welcome_comma': 'Üdvözöljük,',
  'welcome_to': 'Üdvözöljük a',
  'guests_count': '{count} vendég',
  'checkout_label': 'Kijelentkezés:',
  'wifi_pass_label': 'Jelszó:',
  'check_in_complete': 'BEJELENTKEZÉS KÉSZ',
  'check_out': 'Kijelentkezés',
  'checkout_confirm': 'Biztosan ki szeretne jelentkezni?',
  'checkout_date_info': 'Kijelentkezés dátuma: {date}',
  'need_help': 'Segítségre van szüksége?',
  'contact_host': 'Közvetlenül lépjen kapcsolatba a házigazdával:',
  'agent_reception': 'Recepció',
  'agent_house': 'Okos Ház',
  'agent_gastro': 'Gasztronómiai Útmutató',
  'agent_local': 'Helyi Útmutató',
  'agent_desc_reception': 'Chat, GYIK, Segítség',
  'agent_desc_house': 'Klíma, Világítás, Medence',
  'agent_desc_gastro': 'Éttermek & Házhozszállítás',
  'agent_desc_local': 'Strandok, Túrák, Események',

  // ════════════════════════════════════════════════════════════════════════
  // CHAT
  // ════════════════════════════════════════════════════════════════════════
  'thinking': 'Gondolkodom...',
  'type_message': 'Írjon üzenetet...',
  'chat_hello': 'Helló',
  'chat_hello_name': 'Helló {name}!',
  'chat_no_internet': 'Nincs internet. AI asszisztens nem elérhető.',
  'chat_error': 'Sajnálom, kapcsolódási problémáim vannak. Kérjük, próbálja újra.',
  'chat_no_internet_places': 'Nincs internet. Nem lehet helyeket keresni.',
  'chat_search_failed': 'Keresés sikertelen. Ellenőrizze az internetkapcsolatot.',
  'chat_connecting': 'Csatlakozás: {agent}...',
  'status_online': 'Online',
  'status_offline': 'Offline',
  'quick_wifi': '📶 WiFi jelszó?',
  'quick_wifi_full': 'Mi a WiFi jelszó?',
  'quick_checkout_time': '🕐 Kijelentkezés ideje?',
  'quick_checkout_time_full': 'Mikor van a kijelentkezés?',
  'quick_rules': '📋 Házirend',
  'quick_rules_full': 'Mutassa a házirendet',
  'quick_contact': '📞 Házigazda elérhetősége',
  'quick_contact_full': 'Hogyan érhetem el a házigazdát?',
  'find_nearby': 'Keresés a közelben',
  'searching_nearby': 'Keresés a közelben...',
  'searching_restaurants': 'Éttermek keresése...',
  'searching_attractions': 'Látnivalók keresése...',
  'searching_pharmacy': 'Gyógyszertár/orvos keresése...',
  'places_found': 'Íme néhány jól értékelt hely a közelben:',
  'no_places_found': 'Nem találtam helyeket a közelben. Ellenőrizze a villa címét.',

  // ════════════════════════════════════════════════════════════════════════
  // FEEDBACK
  // ════════════════════════════════════════════════════════════════════════
  'feedback_title': 'Kijelentkezés & Visszajelzés',
  'feedback_subtitle': 'Távozás előtt értékelje tartózkodását.',
  'thank_you': 'Köszönjük',
  'feedback_comment_label': 'MIT JAVÍTHATUNK?',
  'feedback_comment_hint': 'Mondja el, mit tehetünk jobban...',
  'submit_feedback': 'VISSZAJELZÉS KÜLDÉSE',
  'skip_feedback': 'Kihagyás & Kijelentkezés',
  'thank_you_perfect': 'Csodálatos vagy! 💖',
  'thank_you_feedback': 'Köszönjük!',
  'perfect_stay_message': 'Örülünk, hogy élvezte a tartózkodást! Ha van egy perce, hagyjon nekünk értékelést.',
  'feedback_received_message': 'Visszajelzése segít a fejlődésben. Jó utat!',
  'feedback_offline_saved': 'Visszajelzés mentve. Csatlakozás után szinkronizálva lesz.',
  'scan_for_review': 'Szkennelje be a Google értékeléshez',
  'glad_you_enjoyed': 'Örülünk, hogy élvezte a tartózkodást!',
  'complete_checkout': 'KIJELENTKEZÉS BEFEJEZÉSE',
  'touch_to_continue': 'Érintse meg a képernyőt a folytatáshoz',
  'rating_1': 'Nagyon rossz 😞',
  'rating_2': 'Rossz 😕',
  'rating_3': 'Átlagos 😐',
  'rating_4': 'Jó 😊',
  'rating_5': 'Kiváló! 🤩',

  // ════════════════════════════════════════════════════════════════════════
  // CLEANER
  // ════════════════════════════════════════════════════════════════════════
  'cleaner_title': 'Személyzet Hozzáférés',
  'cleaner_mode': 'TAKARÍTÁS MÓD',
  'cleaner_checklist': 'Takarítási ellenőrzőlista',
  'cleaner_booking_label': 'Foglalás:',
  'cleaner_tasks_label': 'FELADATOK',
  'cleaner_notes': 'Probléma jelentése / Megjegyzések',
  'cleaner_notes_label': 'MEGJEGYZÉSEK A TULAJDONOSNAK',
  'cleaner_notes_hint': 'Jelezze a problémákat, hiányzó tárgyakat vagy bármit, amit a tulajdonosnak tudnia kell.',
  'cleaner_notes_placeholder': 'pl. Törött lámpa a hálószobában, kevés sampon...',
  'cleaner_privacy_notice': 'A BEFEJEZÉS megérintésével a vendégek aláírásai és a beszkennelt dokumentumok véglegesen törlésre kerülnek az adatvédelem érdekében.',
  'cleaner_not_all_tasks': 'Nem minden feladat van bejelölve.\nBiztosan be akarja fejezni?',
  'cleaner_finish_anyway': 'BEFEJEZÉS MÉGIS',
  'cleaner_offline_saved': 'Jelentés mentve. Csatlakozás után szinkronizálva lesz.',
  'cleaner_processing': 'FELDOLGOZÁS...',
  'cleaner_complete_btn': 'BEFEJEZVE',
  'cleaner_finish_btn': 'BEFEJEZÉS & JELENTÉS',
  'cleaner_finish': 'BEFEJEZÉS & ELŐKÉSZÍTÉS VENDÉGNEK',
  'cleaner_cleanup_progress': 'Adatok törlése...',
  'cleaner_cleanup_archive': 'Foglalás archiválása, aláírások törlése...',
  'cleaner_complete_title': 'Takarítás befejezve!',
  'cleaner_summary_title': 'Adattörlés összefoglaló',
  'cleaner_signatures_deleted': 'Aláírások törölve',
  'cleaner_guests_deleted': 'Vendégadatok törölve',
  'cleaner_booking_archived': 'Foglalás archiválva',
  'cleaner_report_queued': 'Jelentés sorban. Az adattörlés csatlakozás után fut le.',
  'cleaner_success_online': 'Jelentés elküldve a tulajdonosnak.\nTablet készen áll új vendégekre.',
  'cleaner_success_offline': 'Jelentés helyben mentve.\nTablet készen áll új vendégekre.',
  'cleaner_default_error': 'Alapértelmezett lista használata (nem sikerült betölteni a szerverről)',

  // ════════════════════════════════════════════════════════════════════════
  // KIOSK MODE
  // ════════════════════════════════════════════════════════════════════════
  'kiosk_mode_title': 'Kioszk Mód',
  'kiosk_enter_pin': 'Adja meg a 6 jegyű PIN-t a kilépéshez:',
  'kiosk_enter_all_digits': 'Adja meg mind a 6 számjegyet',
  'kiosk_too_many_attempts': 'Túl sok próbálkozás. Próbálja később.',
  'kiosk_wrong_pin_attempts': 'Hibás PIN. Hátralévő próbálkozások: {attempts}',
  'kiosk_contact_admin': 'Forduljon az adminisztrátorhoz, ha nem ismeri a PIN-t.',
  'kiosk_unlock': 'Feloldás',

  // ════════════════════════════════════════════════════════════════════════
  // PIN
  // ════════════════════════════════════════════════════════════════════════
  'pin_title': 'PIN megadása',
  'pin_cleaner_title': 'Személyzet Hozzáférés',
  'pin_admin_title': 'Admin Hozzáférés',
  'pin_enter': 'Adja meg a PIN kódját',
  'pin_incorrect': 'Hibás PIN',
  'pin_attempts_left': 'Hátralévő próbálkozások: {count}',
  'pin_locked': 'Túl sok próbálkozás. Próbálja {minutes} perc múlva.',
  'pin_forgot': 'Elfelejtette a PIN-t?',

  // ════════════════════════════════════════════════════════════════════════
  // SETUP
  // ════════════════════════════════════════════════════════════════════════
  'setup_app_name': 'VillaOS',
  'setup_app_subtitle': 'Digitális recepciós rendszer',
  'setup_tagline': 'A Recepció,\nAmi Soha Nem Alszik',
  'setup_description': 'Automatizálja a bejelentkezést, elragadja a vendégeket,\njavítsa az értékeléseket',
  'setup_connect_title': 'ESZKÖZ CSATLAKOZTATÁSA',
  'setup_connect_subtitle': 'Kapcsolja össze ezt a tabletet az ingatlanával',
  'setup_tenant_label': 'Tenant ID',
  'setup_tenant_hint': 'pl. TEST22',
  'setup_unit_label': 'Unit ID',
  'setup_unit_hint': 'pl. PLAVI',
  'setup_btn_connect': 'CSATLAKOZÁS',
  'setup_connecting': 'Csatlakozás...',
  'setup_finding_unit': 'Egység keresése...',
  'setup_registering': 'Eszköz regisztrálása...',
  'setup_syncing': 'Beállítások szinkronizálása...',
  'setup_connected': 'Csatlakozva!',
  'setup_stat_properties': 'Ingatlanok',
  'setup_stat_checkins': 'Bejelentkezések',
  'setup_stat_uptime': 'Üzemidő',

  // ════════════════════════════════════════════════════════════════════════
  // VALIDATION
  // ════════════════════════════════════════════════════════════════════════
  'validation_required': 'Kötelező',
  'validation_invalid': 'Érvénytelen bevitel',
  'validation_too_short': 'Túl rövid',
  'validation_too_long': 'Túl hosszú',

  // ════════════════════════════════════════════════════════════════════════
  // ADMIN
  // ════════════════════════════════════════════════════════════════════════
  'admin_title': 'Admin Panel',
  'admin_unit_label': 'Egység:',
  'admin_not_available': 'N/A',
  'admin_debug': 'Debug Panel',
  'admin_kiosk_disable': 'Kioszk Kikapcsolása (5 perc)',
  'admin_sync': 'Szinkronizálás most',
  'admin_factory_reset': 'Gyári visszaállítás',
  'admin_factory_reset_confirm': 'Ez leválasztja a tabletet az egységről. Biztos benne?',
  'debug_status': 'Állapot',
  'debug_firebase': 'Firebase',
  'debug_storage': 'Tárhely',
  'debug_tests': 'Tesztek',
  'debug_actions': 'Műveletek',

  // ════════════════════════════════════════════════════════════════════════
  // OFFLINE
  // ════════════════════════════════════════════════════════════════════════
  'offline_banner': 'Offline módban van',
  'offline_limited': 'Korlátozott funkciók',
  'offline_reconnecting': 'Újracsatlakozás...',
  'offline_connected': 'Újra online!',

  // ════════════════════════════════════════════════════════════════════════
  // ERRORS
  // ════════════════════════════════════════════════════════════════════════
  'error_generic': 'Valami hiba történt',
  'error_network': 'Hálózati hiba',
  'error_try_again': 'Kérjük, próbálja újra',
  'error_timeout': 'Időtúllépés',
  'error_not_found': 'Nem található',
};
