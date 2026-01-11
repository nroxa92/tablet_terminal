// FILE: lib/utils/translations/lang_cs.dart
// VERZIJA: 4.0 - ČEŠTINA
// DATUM: 2026-01-11

const Map<String, String> csTranslations = {
  // ════════════════════════════════════════════════════════════════════════
  // WELCOME SCREEN
  // ════════════════════════════════════════════════════════════════════════
  'welcome_app_title': 'VILLA CONCIERGE',
  'welcome_select_language': 'Prosím vyberte svůj jazyk',
  'welcome_powered_by': 'Powered by VillaOS',
  'welcome_title': 'Vítejte ve\nVilla Mare',
  'welcome_subtitle': 'Jak vám mohu dnes pomoci?',

  // ════════════════════════════════════════════════════════════════════════
  // CHECK-IN INTRO
  // ════════════════════════════════════════════════════════════════════════
  'intro_title': 'Online check-in',
  'intro_desc': 'Podle turistických zákonů jsme povinni registrovat všechny hosty.',
  'start_btn': 'ZAHÁJIT CHECK-IN',
  'skip_btn': 'Později (Přeskočit)',
  'gdpr_badge': 'V souladu s GDPR • Data chráněna',
  'consents_title': 'POŽADOVANÉ SOUHLASY',
  'consents_subtitle': 'Prosím přečtěte si a přijměte oba dokumenty',
  'gdpr_consent_title': 'Souhlas se zpracováním údajů (GDPR)',
  'truth_consent_title': 'Prohlášení a souhlas se skenováním',
  'consent_gdpr': 'Souhlasím se skenováním dokumentů pro registraci eVisitor. Žádné fotografie nejsou ukládány.',
  'consent_truth': 'Potvrzuji, že poskytnuté údaje jsou správné.',
  'gdpr_full_text': 'Vaše dokumenty jsou skenovány pouze pro extrakci údajů. Fotografie NEJSOU ukládány.',
  'truth_full_text': 'Prohlašuji, že všechny poskytnuté informace jsou pravdivé a přesné.',
  'btn_accept': 'PŘIJÍMÁM',

  // ════════════════════════════════════════════════════════════════════════
  // DOCUMENT SELECTION
  // ════════════════════════════════════════════════════════════════════════
  'doc_select_title': 'Vyberte typ dokumentu',
  'issuing_country': 'ZEMĚ VYDÁNÍ',
  'doc_type': 'TYP DOKUMENTU',
  'doc_id_card': 'Občanský průkaz',
  'doc_passport': 'Cestovní pas',
  'doc_id_sub': 'Přední a zadní strana',
  'doc_passport_sub': 'Strana s fotografií',
  'open_camera': 'OTEVŘÍT FOTOAPARÁT',

  // ════════════════════════════════════════════════════════════════════════
  // CAMERA SCREEN
  // ════════════════════════════════════════════════════════════════════════
  'cam_permission_needed': 'Je vyžadováno povolení fotoaparátu',
  'cam_not_found': 'Fotoaparát nenalezen',
  'cam_error': 'Chyba fotoaparátu',
  'cam_initializing': 'Inicializace fotoaparátu...',
  'cam_front_side': 'Přední',
  'cam_back_side': 'Zadní',
  'cam_guest': 'Host',
  'cam_skip_to_back': 'PŘEJÍT NA ZADNÍ >',
  'cam_skip_to_review': 'PŘEJÍT NA KONTROLU >',
  'cam_position_doc': '📄 Umístěte dokument do rámečku',
  'cam_position_mrz': '📄 Umístěte MRZ zónu do rámečku',
  'cam_flip_doc': '🔄 Otočte dokument na ZADNÍ stranu',
  'cam_front_complete': '✅ Přední strana hotová! Nyní naskenujte ZADNÍ',
  'cam_mrz_detected': '✅ MRZ Detekováno!',
  'cam_scanning_mrz': 'Skenování MRZ zóny...',
  'cam_personal_data': 'OSOBNÍ ÚDAJE',
  'cam_address_data': 'ADRESA',
  'cam_scanning': 'Skenování...',
  'cam_detected': 'detekováno',
  'cam_reset_field': 'Resetovat pole',
  'cam_continue_manual': 'POKRAČOVAT RUČNĚ →',
  'cam_verify_data': 'Prosím zkontrolujte a opravte pokud je třeba',
  'cam_name_required': 'Jméno a příjmení jsou povinné',
  'cam_guest_saved': 'Host uložen:',
  'cam_save_next': 'ULOŽIT & DALŠÍ HOST',
  'cam_finish_checkin': 'DOKONČIT CHECK-IN',
  'cam_back_scanned': 'Zadní strana naskenována!',
  'cam_mrz_not_found': 'MRZ nenalezeno. Zkuste znovu.',
  'cam_processing': 'Zpracování...',
  'cam_manual_entry': 'Ruční zadání',
  'cam_skip_scan_confirm': 'Chcete přeskočit skenování a zadat údaje ručně?',
  'cam_yes_manual': 'Ano, ručně',
  'cam_manual': 'Ručně',
  'cam_position_back': 'Umístěte ZADNÍ stranu dokumentu\n(MRZ zóna s <<<)',
  'cam_position_front': 'Umístěte PŘEDNÍ stranu dokumentu\n(s fotografií)',
  'cam_mrz_zone': 'MRZ ZÓNA',

  // ════════════════════════════════════════════════════════════════════════
  // GUEST CONFIRMATION SCREEN
  // ════════════════════════════════════════════════════════════════════════
  'confirm_rescan': 'Znovu naskenovat',
  'confirm_fill_fields': 'Vyplňte pole',
  'confirm_fields_required': 'Všechna pole jsou povinná pro registraci eVisitor',
  'confirm_place_of_birth': 'Místo narození',
  'confirm_country_of_birth': 'Země narození',
  'confirm_document': 'DOKUMENT',
  'confirm_residence': 'BYDLIŠTĚ',
  'confirm_country': 'Země',
  'confirm_city': 'Město',
  'confirm_stay': 'POBYT',
  'confirm_arrival': 'Příjezd',
  'confirm_departure': 'Odjezd',
  'confirm_next_guest': 'Potvrdit & další host',
  'confirm_continue': 'Potvrdit & pokračovat',
  'confirm_male': 'M (Muž)',
  'confirm_female': 'Ž (Žena)',

  // ════════════════════════════════════════════════════════════════════════
  // CHECK-IN SUCCESS SCREEN
  // ════════════════════════════════════════════════════════════════════════
  'success_checkin_complete': 'CHECK-IN ÚSPĚŠNÝ!',
  'success_welcome': 'Vítejte',
  'success_guest': 'Host',
  'success_guests': 'Hostů',
  'success_duration': 'Délka',
  'success_confirmed': 'Potvrzeno',
  'success_auto_redirect': 'Automatické přesměrování za {seconds} sekund...',

  // ════════════════════════════════════════════════════════════════════════
  // FORM FIELDS
  // ════════════════════════════════════════════════════════════════════════
  'field_first_name': 'Jméno',
  'field_last_name': 'Příjmení',
  'field_doc_number': 'Číslo dokumentu',
  'field_birth_date': 'Datum narození',
  'field_gender': 'Pohlaví',
  'field_nationality': 'Státní příslušnost',
  'field_address': 'Adresa',
  'field_expiry_date': 'Datum platnosti',

  // ════════════════════════════════════════════════════════════════════════
  // BUTTONS
  // ════════════════════════════════════════════════════════════════════════
  'btn_retake': 'Opakovat',
  'btn_next': 'Další',
  'btn_finish': 'Dokončit',
  'btn_cancel': 'Zrušit',
  'btn_close': 'Zavřít',
  'btn_confirm': 'Potvrdit',
  'btn_done': 'HOTOVO',
  'btn_back': 'Zpět',
  'btn_save': 'Uložit',
  'btn_continue': 'Pokračovat',

  // ════════════════════════════════════════════════════════════════════════
  // HOUSE RULES
  // ════════════════════════════════════════════════════════════════════════
  'house_rules_title': 'DOMOVNÍ ŘÁD',
  'house_rules_subtitle': 'Prosím přečtěte si a podepište pro pokračování.',
  'guest_signature': 'PODPIS HOSTA',
  'guest_name': 'CELÉ JMÉNO',
  'enter_name': 'Zadejte své celé jméno',
  'enter_name_first': 'Nejdříve zadejte jméno',
  'signature': 'PODPIS',
  'sign_here': 'Podepište zde prstem',
  'clear': 'Vymazat',
  'signature_legal': 'Podpisem potvrzujete, že jste si přečetli a souhlasíte s tímto domovním řádem.',
  'agree_continue': 'SOUHLASÍM A POKRAČUJI',
  'please_sign': 'PROSÍM PODEPIŠTE',
  'rules_accepted': 'Pravidla přijata! PDF vygenerováno.',
  'error': 'Chyba',

  // ════════════════════════════════════════════════════════════════════════
  // DASHBOARD
  // ════════════════════════════════════════════════════════════════════════
  'default_villa_name': 'Villa Host',
  'loading_stay': 'Načítání vašeho pobytu...',
  'welcome_comma': 'Vítejte,',
  'welcome_to': 'Vítejte ve',
  'guests_count': '{count} hostů',
  'checkout_label': 'Check-out:',
  'wifi_pass_label': 'Heslo:',
  'check_in_complete': 'CHECK-IN DOKONČEN',
  'check_out': 'Check-out',
  'checkout_confirm': 'Opravdu se chcete odhlásit?',
  'checkout_date_info': 'Datum check-outu: {date}',
  'need_help': 'Potřebujete pomoc?',
  'contact_host': 'Kontaktujte přímo hostitele:',
  'agent_reception': 'Recepce',
  'agent_house': 'Chytrý Dům',
  'agent_gastro': 'Gastronomický Průvodce',
  'agent_local': 'Místní Průvodce',
  'agent_desc_reception': 'Chat, FAQ, Pomoc',
  'agent_desc_house': 'Klima, Světla, Bazén',
  'agent_desc_gastro': 'Restaurace & Rozvoz',
  'agent_desc_local': 'Pláže, Výlety, Události',

  // ════════════════════════════════════════════════════════════════════════
  // CHAT
  // ════════════════════════════════════════════════════════════════════════
  'thinking': 'Přemýšlím...',
  'type_message': 'Napište zprávu...',
  'chat_hello': 'Ahoj',
  'chat_hello_name': 'Ahoj {name}!',
  'chat_no_internet': 'Bez internetu. AI asistent nedostupný.',
  'chat_error': 'Omlouvám se, mám problémy s připojením. Zkuste to znovu.',
  'chat_no_internet_places': 'Bez internetu. Nelze vyhledávat místa.',
  'chat_search_failed': 'Vyhledávání selhalo. Zkontrolujte připojení k internetu.',
  'chat_connecting': 'Připojování k {agent}...',
  'status_online': 'Online',
  'status_offline': 'Offline',
  'quick_wifi': '📶 WiFi heslo?',
  'quick_wifi_full': 'Jaké je WiFi heslo?',
  'quick_checkout_time': '🕐 Čas check-outu?',
  'quick_checkout_time_full': 'V kolik je check-out?',
  'quick_rules': '📋 Domovní řád',
  'quick_rules_full': 'Ukažte mi domovní řád',
  'quick_contact': '📞 Kontakt na hostitele',
  'quick_contact_full': 'Jak mohu kontaktovat hostitele?',
  'find_nearby': 'Najít v okolí',
  'searching_nearby': 'Hledám v okolí...',
  'searching_restaurants': 'Hledám restaurace...',
  'searching_attractions': 'Hledám atrakce...',
  'searching_pharmacy': 'Hledám lékárnu/lékaře...',
  'places_found': 'Zde je několik dobře hodnocených míst v okolí:',
  'no_places_found': 'V okolí nebyla nalezena žádná místa. Zkontrolujte adresu vily.',

  // ════════════════════════════════════════════════════════════════════════
  // FEEDBACK
  // ════════════════════════════════════════════════════════════════════════
  'feedback_title': 'Check-out & Zpětná vazba',
  'feedback_subtitle': 'Před odjezdem ohodnoťte svůj pobyt.',
  'thank_you': 'Děkujeme',
  'feedback_comment_label': 'CO MŮŽEME ZLEPŠIT?',
  'feedback_comment_hint': 'Řekněte nám, co můžeme udělat lépe...',
  'submit_feedback': 'ODESLAT ZPĚTNOU VAZBU',
  'skip_feedback': 'Přeskočit & Check-out',
  'thank_you_perfect': 'Jste úžasní! 💖',
  'thank_you_feedback': 'Děkujeme!',
  'perfect_stay_message': 'Jsme rádi, že se vám pobyt líbil! Pokud máte chvilku, zanechte nám recenzi.',
  'feedback_received_message': 'Vaše zpětná vazba nám pomáhá zlepšovat se. Šťastnou cestu!',
  'feedback_offline_saved': 'Zpětná vazba uložena. Bude synchronizována po připojení.',
  'scan_for_review': 'Naskenujte pro Google recenzi',
  'glad_you_enjoyed': 'Jsme rádi, že se vám pobyt líbil!',
  'complete_checkout': 'DOKONČIT CHECK-OUT',
  'touch_to_continue': 'Dotkněte se obrazovky pro pokračování',
  'rating_1': 'Velmi špatné 😞',
  'rating_2': 'Špatné 😕',
  'rating_3': 'Průměrné 😐',
  'rating_4': 'Dobré 😊',
  'rating_5': 'Výborné! 🤩',

  // ════════════════════════════════════════════════════════════════════════
  // CLEANER
  // ════════════════════════════════════════════════════════════════════════
  'cleaner_title': 'Přístup Personálu',
  'cleaner_mode': 'REŽIM ÚKLIDU',
  'cleaner_checklist': 'Kontrolní seznam úklidu',
  'cleaner_booking_label': 'Rezervace:',
  'cleaner_tasks_label': 'ÚKOLY',
  'cleaner_notes': 'Nahlásit problém / Poznámky',
  'cleaner_notes_label': 'POZNÁMKY PRO MAJITELE',
  'cleaner_notes_hint': 'Nahlaste problémy, chybějící položky nebo cokoliv, co by měl majitel vědět.',
  'cleaner_notes_placeholder': 'např. Rozbitá lampa v ložnici, málo šamponu...',
  'cleaner_privacy_notice': 'Po klepnutí na DOKONČIT budou podpisy hostů a naskenované dokumenty trvale smazány z důvodu ochrany soukromí.',
  'cleaner_not_all_tasks': 'Nejsou zaškrtnuty všechny úkoly.\nOpravdu chcete dokončit?',
  'cleaner_finish_anyway': 'PŘESTO DOKONČIT',
  'cleaner_offline_saved': 'Hlášení uloženo. Bude synchronizováno po připojení.',
  'cleaner_processing': 'ZPRACOVÁNÍ...',
  'cleaner_complete_btn': 'DOKONČENO',
  'cleaner_finish_btn': 'DOKONČIT & NAHLÁSIT',
  'cleaner_finish': 'DOKONČIT & PŘIPRAVIT PRO HOSTA',
  'cleaner_cleanup_progress': 'Čištění dat...',
  'cleaner_cleanup_archive': 'Archivace rezervace, mazání podpisů...',
  'cleaner_complete_title': 'Úklid dokončen!',
  'cleaner_summary_title': 'Souhrn čištění dat',
  'cleaner_signatures_deleted': 'Podpisy smazány',
  'cleaner_guests_deleted': 'Data hostů smazána',
  'cleaner_booking_archived': 'Rezervace archivována',
  'cleaner_report_queued': 'Hlášení ve frontě. Čištění dat proběhne po připojení.',
  'cleaner_success_online': 'Hlášení odesláno majiteli.\nTablet připraven pro nové hosty.',
  'cleaner_success_offline': 'Hlášení uloženo lokálně.\nTablet připraven pro nové hosty.',
  'cleaner_default_error': 'Použití výchozího seznamu (nelze načíst ze serveru)',

  // ════════════════════════════════════════════════════════════════════════
  // KIOSK MODE
  // ════════════════════════════════════════════════════════════════════════
  'kiosk_mode_title': 'Režim Kiosku',
  'kiosk_enter_pin': 'Zadejte 6místný PIN pro ukončení:',
  'kiosk_enter_all_digits': 'Zadejte všech 6 číslic',
  'kiosk_too_many_attempts': 'Příliš mnoho pokusů. Zkuste později.',
  'kiosk_wrong_pin_attempts': 'Špatný PIN. Zbývající pokusy: {attempts}',
  'kiosk_contact_admin': 'Kontaktujte administrátora, pokud neznáte PIN.',
  'kiosk_unlock': 'Odemknout',

  // ════════════════════════════════════════════════════════════════════════
  // PIN
  // ════════════════════════════════════════════════════════════════════════
  'pin_title': 'Zadejte PIN',
  'pin_cleaner_title': 'Přístup Personálu',
  'pin_admin_title': 'Přístup Admina',
  'pin_enter': 'Zadejte svůj PIN kód',
  'pin_incorrect': 'Nesprávný PIN',
  'pin_attempts_left': 'Zbývající pokusy: {count}',
  'pin_locked': 'Příliš mnoho pokusů. Zkuste za {minutes} minut.',
  'pin_forgot': 'Zapomněli jste PIN?',

  // ════════════════════════════════════════════════════════════════════════
  // SETUP
  // ════════════════════════════════════════════════════════════════════════
  'setup_app_name': 'VillaOS',
  'setup_app_subtitle': 'Digitální recepční systém',
  'setup_tagline': 'Recepce,\nKterá Nikdy Nespí',
  'setup_description': 'Automatizujte check-in, potěšte hosty,\nzlepšete recenze',
  'setup_connect_title': 'PŘIPOJIT ZAŘÍZENÍ',
  'setup_connect_subtitle': 'Propojte tento tablet s vaší nemovitostí',
  'setup_tenant_label': 'Tenant ID',
  'setup_tenant_hint': 'např. TEST22',
  'setup_unit_label': 'Unit ID',
  'setup_unit_hint': 'např. PLAVI',
  'setup_btn_connect': 'PŘIPOJIT',
  'setup_connecting': 'Připojování...',
  'setup_finding_unit': 'Hledání jednotky...',
  'setup_registering': 'Registrace zařízení...',
  'setup_syncing': 'Synchronizace nastavení...',
  'setup_connected': 'Připojeno!',
  'setup_stat_properties': 'Nemovitosti',
  'setup_stat_checkins': 'Check-iny',
  'setup_stat_uptime': 'Doba provozu',

  // ════════════════════════════════════════════════════════════════════════
  // VALIDATION
  // ════════════════════════════════════════════════════════════════════════
  'validation_required': 'Povinné',
  'validation_invalid': 'Neplatný vstup',
  'validation_too_short': 'Příliš krátké',
  'validation_too_long': 'Příliš dlouhé',

  // ════════════════════════════════════════════════════════════════════════
  // ADMIN
  // ════════════════════════════════════════════════════════════════════════
  'admin_title': 'Admin Panel',
  'admin_unit_label': 'Jednotka:',
  'admin_not_available': 'N/A',
  'admin_debug': 'Debug Panel',
  'admin_kiosk_disable': 'Vypnout Kiosk (5 min)',
  'admin_sync': 'Synchronizovat nyní',
  'admin_factory_reset': 'Tovární reset',
  'admin_factory_reset_confirm': 'Tím se odpojí tablet od jednotky. Jste si jisti?',
  'debug_status': 'Stav',
  'debug_firebase': 'Firebase',
  'debug_storage': 'Úložiště',
  'debug_tests': 'Testy',
  'debug_actions': 'Akce',

  // ════════════════════════════════════════════════════════════════════════
  // OFFLINE
  // ════════════════════════════════════════════════════════════════════════
  'offline_banner': 'Jste offline',
  'offline_limited': 'Omezená funkčnost',
  'offline_reconnecting': 'Opětovné připojování...',
  'offline_connected': 'Zpět online!',

  // ════════════════════════════════════════════════════════════════════════
  // ERRORS
  // ════════════════════════════════════════════════════════════════════════
  'error_generic': 'Něco se pokazilo',
  'error_network': 'Chyba sítě',
  'error_try_again': 'Zkuste to prosím znovu',
  'error_timeout': 'Časový limit vypršel',
  'error_not_found': 'Nenalezeno',
};
