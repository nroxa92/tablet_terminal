// FILE: lib/utils/translations/lang_de.dart
// VERZIJA: 4.0 - DEUTSCH
// DATUM: 2026-01-11

const Map<String, String> deTranslations = {
  // ════════════════════════════════════════════════════════════════════════
  // WELCOME SCREEN
  // ════════════════════════════════════════════════════════════════════════
  'welcome_app_title': 'VILLA CONCIERGE',
  'welcome_select_language': 'Bitte wählen Sie Ihre Sprache',
  'welcome_powered_by': 'Powered by VillaOS',
  'welcome_title': 'Willkommen in\nVilla Mare',
  'welcome_subtitle': 'Wie kann ich Ihnen helfen?',

  // ════════════════════════════════════════════════════════════════════════
  // CHECK-IN INTRO
  // ════════════════════════════════════════════════════════════════════════
  'intro_title': 'Online Check-in',
  'intro_desc': 'Gemäß den Tourismusgesetzen sind wir verpflichtet, alle Gäste zu registrieren.',
  'start_btn': 'CHECK-IN STARTEN',
  'skip_btn': 'Später (Überspringen)',
  'gdpr_badge': 'DSGVO-konform • Daten geschützt',
  'consents_title': 'ERFORDERLICHE EINWILLIGUNGEN',
  'consents_subtitle': 'Bitte lesen und akzeptieren Sie beide Dokumente',
  'gdpr_consent_title': 'Einwilligung zur Datenverarbeitung (DSGVO)',
  'truth_consent_title': 'Erklärung & Scan-Einwilligung',
  'consent_gdpr': 'Ich stimme dem Dokumentenscan für die eVisitor-Registrierung zu. Keine Fotos werden gespeichert.',
  'consent_truth': 'Ich bestätige, dass die angegebenen Daten korrekt sind.',
  'gdpr_full_text': 'Ihre Dokumente werden nur gescannt, um Daten zu extrahieren. Fotos werden NICHT gespeichert.',
  'truth_full_text': 'Ich erkläre, dass alle angegebenen Informationen wahrheitsgemäß und korrekt sind.',
  'btn_accept': 'ICH AKZEPTIERE',

  // ════════════════════════════════════════════════════════════════════════
  // DOCUMENT SELECTION
  // ════════════════════════════════════════════════════════════════════════
  'doc_select_title': 'Dokumenttyp wählen',
  'issuing_country': 'AUSSTELLUNGSLAND',
  'doc_type': 'DOKUMENTTYP',
  'doc_id_card': 'Personalausweis',
  'doc_passport': 'Reisepass',
  'doc_id_sub': 'Vorder- & Rückseite',
  'doc_passport_sub': 'Fotoseite',
  'open_camera': 'KAMERA ÖFFNEN',

  // ════════════════════════════════════════════════════════════════════════
  // CAMERA SCREEN
  // ════════════════════════════════════════════════════════════════════════
  'cam_permission_needed': 'Kameraberechtigung erforderlich',
  'cam_not_found': 'Keine Kamera gefunden',
  'cam_error': 'Kamerafehler',
  'cam_initializing': 'Kamera wird initialisiert...',
  'cam_front_side': 'Vorderseite',
  'cam_back_side': 'Rückseite',
  'cam_guest': 'Gast',
  'cam_skip_to_back': 'ZUR RÜCKSEITE >',
  'cam_skip_to_review': 'ZUR ÜBERPRÜFUNG >',
  'cam_position_doc': '📄 Dokument im Rahmen positionieren',
  'cam_position_mrz': '📄 MRZ-Zone im Rahmen positionieren',
  'cam_flip_doc': '🔄 Dokument auf RÜCKSEITE drehen',
  'cam_front_complete': '✅ Vorderseite fertig! Jetzt RÜCKSEITE scannen',
  'cam_mrz_detected': '✅ MRZ Erkannt!',
  'cam_scanning_mrz': 'MRZ-Zone wird gescannt...',
  'cam_personal_data': 'PERSÖNLICHE DATEN',
  'cam_address_data': 'ADRESSE',
  'cam_scanning': 'Scannen...',
  'cam_detected': 'erkannt',
  'cam_reset_field': 'Feld zurücksetzen',
  'cam_continue_manual': 'MANUELL FORTFAHREN →',
  'cam_verify_data': 'Bitte überprüfen und korrigieren',
  'cam_name_required': 'Name und Nachname sind erforderlich',
  'cam_guest_saved': 'Gast gespeichert:',
  'cam_save_next': 'SPEICHERN & NÄCHSTER GAST',
  'cam_finish_checkin': 'CHECK-IN ABSCHLIESSEN',
  // NEW - Camera screen additions
  'cam_back_scanned': 'Rückseite gescannt!',
  'cam_mrz_not_found': 'MRZ nicht gefunden. Bitte erneut versuchen.',
  'cam_processing': 'Verarbeitung...',
  'cam_manual_entry': 'Manuelle Eingabe',
  'cam_skip_scan_confirm': 'Möchten Sie das Scannen überspringen und Daten manuell eingeben?',
  'cam_yes_manual': 'Ja, manuell eingeben',
  'cam_manual': 'Manuell',
  'cam_position_back': 'Positionieren Sie die RÜCKSEITE des Dokuments\n(MRZ-Zone mit <<<)',
  'cam_position_front': 'Positionieren Sie die VORDERSEITE des Dokuments\n(mit Foto)',
  'cam_mrz_zone': 'MRZ ZONE',

  // ════════════════════════════════════════════════════════════════════════
  // GUEST CONFIRMATION SCREEN
  // ════════════════════════════════════════════════════════════════════════
  'confirm_rescan': 'Neu scannen',
  'confirm_fill_fields': 'Felder ausfüllen',
  'confirm_fields_required': 'Alle Felder sind für die eVisitor-Registrierung erforderlich',
  'confirm_place_of_birth': 'Geburtsort',
  'confirm_country_of_birth': 'Geburtsland',
  'confirm_document': 'DOKUMENT',
  'confirm_residence': 'WOHNSITZ',
  'confirm_country': 'Land',
  'confirm_city': 'Stadt',
  'confirm_stay': 'AUFENTHALT',
  'confirm_arrival': 'Ankunft',
  'confirm_departure': 'Abreise',
  'confirm_next_guest': 'Bestätigen & nächster Gast',
  'confirm_continue': 'Bestätigen & fortfahren',
  'confirm_male': 'M (Männlich)',
  'confirm_female': 'W (Weiblich)',

  // ════════════════════════════════════════════════════════════════════════
  // CHECK-IN SUCCESS SCREEN
  // ════════════════════════════════════════════════════════════════════════
  'success_checkin_complete': 'CHECK-IN ERFOLGREICH!',
  'success_welcome': 'Willkommen',
  'success_guest': 'Gast',
  'success_guests': 'Gäste',
  'success_duration': 'Dauer',
  'success_confirmed': 'Bestätigt',
  'success_auto_redirect': 'Automatische Weiterleitung in {seconds} Sekunden...',

  // ════════════════════════════════════════════════════════════════════════
  // FORM FIELDS
  // ════════════════════════════════════════════════════════════════════════
  'field_first_name': 'Vorname',
  'field_last_name': 'Nachname',
  'field_doc_number': 'Dokumentnummer',
  'field_birth_date': 'Geburtsdatum',
  'field_gender': 'Geschlecht',
  'field_nationality': 'Staatsangehörigkeit',
  'field_address': 'Adresse',
  'field_expiry_date': 'Ablaufdatum',

  // ════════════════════════════════════════════════════════════════════════
  // BUTTONS
  // ════════════════════════════════════════════════════════════════════════
  'btn_retake': 'Wiederholen',
  'btn_next': 'Weiter',
  'btn_finish': 'Fertig',
  'btn_cancel': 'Abbrechen',
  'btn_close': 'Schließen',
  'btn_confirm': 'Bestätigen',
  'btn_done': 'FERTIG',
  'btn_back': 'Zurück',
  'btn_save': 'Speichern',
  'btn_continue': 'Fortfahren',

  // ════════════════════════════════════════════════════════════════════════
  // HOUSE RULES
  // ════════════════════════════════════════════════════════════════════════
  'house_rules_title': 'HAUSREGELN',
  'house_rules_subtitle': 'Bitte lesen und unterschreiben Sie.',
  'guest_signature': 'GAST-UNTERSCHRIFT',
  'guest_name': 'VOLLSTÄNDIGER NAME',
  'enter_name': 'Geben Sie Ihren vollständigen Namen ein',
  'enter_name_first': 'Zuerst Name eingeben',
  'signature': 'UNTERSCHRIFT',
  'sign_here': 'Hier mit dem Finger unterschreiben',
  'clear': 'Löschen',
  'signature_legal': 'Mit Ihrer Unterschrift bestätigen Sie, dass Sie diese Hausregeln gelesen haben und akzeptieren.',
  'agree_continue': 'ZUSTIMMEN & FORTFAHREN',
  'please_sign': 'BITTE UNTERSCHREIBEN',
  'rules_accepted': 'Regeln akzeptiert! PDF erstellt.',
  'error': 'Fehler',

  // ════════════════════════════════════════════════════════════════════════
  // DASHBOARD
  // ════════════════════════════════════════════════════════════════════════
  'default_villa_name': 'Villa Gast',
  'loading_stay': 'Laden Ihres Aufenthalts...',
  'welcome_comma': 'Willkommen,',
  'welcome_to': 'Willkommen in',
  'guests_count': '{count} Gäste',
  'checkout_label': 'Check-out:',
  'wifi_pass_label': 'Passwort:',
  'check_in_complete': 'CHECK-IN ABGESCHLOSSEN',
  'check_out': 'Check-out',
  'checkout_confirm': 'Möchten Sie wirklich auschecken?',
  'checkout_date_info': 'Check-out-Datum: {date}',
  'need_help': 'Brauchen Sie Hilfe?',
  'contact_host': 'Kontaktieren Sie den Gastgeber:',
  'agent_reception': 'Rezeption',
  'agent_house': 'Smart Home',
  'agent_gastro': 'Gastro-Guide',
  'agent_local': 'Reiseführer',
  'agent_desc_reception': 'Chat, FAQ, Hilfe',
  'agent_desc_house': 'Klima, Licht, Pool',
  'agent_desc_gastro': 'Restaurants & Lieferung',
  'agent_desc_local': 'Strände, Touren, Events',

  // ════════════════════════════════════════════════════════════════════════
  // CHAT
  // ════════════════════════════════════════════════════════════════════════
  'thinking': 'Denke nach...',
  'type_message': 'Nachricht eingeben...',
  'chat_hello': 'Hallo',
  'chat_hello_name': 'Hallo {name}!',
  'chat_no_internet': 'Kein Internet. KI-Assistent nicht verfügbar.',
  'chat_error': 'Entschuldigung, ich habe Verbindungsprobleme. Bitte versuchen Sie es erneut.',
  'chat_no_internet_places': 'Kein Internet. Orte können nicht gesucht werden.',
  'chat_search_failed': 'Suche fehlgeschlagen. Bitte überprüfen Sie Ihre Internetverbindung.',
  'chat_connecting': 'Verbinde mit {agent}...',
  'status_online': 'Online',
  'status_offline': 'Offline',
  'quick_wifi': '📶 WLAN-Passwort?',
  'quick_wifi_full': 'Wie lautet das WLAN-Passwort?',
  'quick_checkout_time': '🕐 Check-out-Zeit?',
  'quick_checkout_time_full': 'Wann ist Check-out?',
  'quick_rules': '📋 Hausregeln',
  'quick_rules_full': 'Zeigen Sie mir die Hausregeln',
  'quick_contact': '📞 Gastgeber kontaktieren',
  'quick_contact_full': 'Wie kann ich den Gastgeber kontaktieren?',
  'find_nearby': 'In der Nähe finden',
  'searching_nearby': 'Suche in der Nähe...',
  'searching_restaurants': 'Suche Restaurants...',
  'searching_attractions': 'Suche Sehenswürdigkeiten...',
  'searching_pharmacy': 'Suche Apotheke/Arzt...',
  'places_found': 'Hier sind einige bestbewertete Orte in der Nähe:',
  'no_places_found': 'Keine Orte in der Nähe gefunden. Bitte überprüfen Sie die Villa-Adresse.',

  // ════════════════════════════════════════════════════════════════════════
  // FEEDBACK
  // ════════════════════════════════════════════════════════════════════════
  'feedback_title': 'Check-out & Feedback',
  'feedback_subtitle': 'Bevor Sie gehen, bewerten Sie bitte Ihren Aufenthalt.',
  'thank_you': 'Danke',
  'feedback_comment_label': 'WAS KÖNNEN WIR VERBESSERN?',
  'feedback_comment_hint': 'Sagen Sie uns, was wir besser machen können...',
  'submit_feedback': 'FEEDBACK SENDEN',
  'skip_feedback': 'Überspringen & Auschecken',
  'thank_you_perfect': 'Sie sind großartig! 💖',
  'thank_you_feedback': 'Vielen Dank!',
  'perfect_stay_message': 'Wir freuen uns, dass Sie Ihren Aufenthalt genossen haben! Bitte hinterlassen Sie uns eine Bewertung.',
  'feedback_received_message': 'Ihr Feedback hilft uns, uns zu verbessern. Gute Reise!',
  'feedback_offline_saved': 'Feedback gespeichert. Wird synchronisiert, wenn online.',
  'scan_for_review': 'Scannen für Google-Bewertung',
  'glad_you_enjoyed': 'Wir freuen uns, dass Sie Ihren Aufenthalt genossen haben!',
  'complete_checkout': 'CHECK-OUT ABSCHLIESSEN',
  'touch_to_continue': 'Bildschirm berühren zum Fortfahren',
  'rating_1': 'Sehr schlecht 😞',
  'rating_2': 'Schlecht 😕',
  'rating_3': 'Durchschnitt 😐',
  'rating_4': 'Gut 😊',
  'rating_5': 'Ausgezeichnet! 🤩',

  // ════════════════════════════════════════════════════════════════════════
  // CLEANER
  // ════════════════════════════════════════════════════════════════════════
  'cleaner_title': 'Mitarbeiterzugang',
  'cleaner_mode': 'REINIGUNGSMODUS',
  'cleaner_checklist': 'Reinigungscheckliste',
  'cleaner_booking_label': 'Buchung:',
  'cleaner_tasks_label': 'AUFGABEN',
  'cleaner_notes': 'Problem melden / Notizen',
  'cleaner_notes_label': 'NOTIZEN FÜR EIGENTÜMER',
  'cleaner_notes_hint': 'Melden Sie Probleme, fehlende Artikel oder alles, was der Eigentümer wissen sollte.',
  'cleaner_notes_placeholder': 'z.B. Kaputte Lampe im Schlafzimmer, wenig Shampoo...',
  'cleaner_privacy_notice': 'Wenn Sie FERTIG tippen, werden Gästeunterschriften und gescannte Dokumente aus Datenschutzgründen dauerhaft gelöscht.',
  'cleaner_not_all_tasks': 'Nicht alle Aufgaben sind erledigt.\nSind Sie sicher, dass Sie beenden möchten?',
  'cleaner_finish_anyway': 'TROTZDEM BEENDEN',
  'cleaner_offline_saved': 'Bericht gespeichert. Wird synchronisiert, wenn online.',
  'cleaner_processing': 'VERARBEITUNG...',
  'cleaner_complete_btn': 'ABGESCHLOSSEN',
  'cleaner_finish_btn': 'BEENDEN & MELDEN',
  'cleaner_finish': 'BEENDEN & FÜR GAST ZURÜCKSETZEN',
  'cleaner_cleanup_progress': 'Daten werden bereinigt...',
  'cleaner_cleanup_archive': 'Buchung archivieren, Unterschriften löschen...',
  'cleaner_complete_title': 'Reinigung abgeschlossen!',
  'cleaner_summary_title': 'Zusammenfassung der Datenbereinigung',
  'cleaner_signatures_deleted': 'Unterschriften gelöscht',
  'cleaner_guests_deleted': 'Gästedaten gelöscht',
  'cleaner_booking_archived': 'Buchung archiviert',
  'cleaner_report_queued': 'Bericht in Warteschlange. Datenbereinigung erfolgt, wenn online.',
  'cleaner_success_online': 'Bericht an Eigentümer gesendet.\nTablet ist bereit für neue Gäste.',
  'cleaner_success_offline': 'Bericht lokal gespeichert.\nTablet ist bereit für neue Gäste.',
  'cleaner_default_error': 'Standard-Checkliste verwendet (konnte nicht vom Server laden)',

  // ════════════════════════════════════════════════════════════════════════
  // KIOSK MODE
  // ════════════════════════════════════════════════════════════════════════
  'kiosk_mode_title': 'Kiosk-Modus',
  'kiosk_enter_pin': '6-stellige PIN eingeben:',
  'kiosk_enter_all_digits': 'Alle 6 Ziffern eingeben',
  'kiosk_too_many_attempts': 'Zu viele Versuche. Bitte später versuchen.',
  'kiosk_wrong_pin_attempts': 'Falsche PIN. Verbleibende Versuche: {attempts}',
  'kiosk_contact_admin': 'Kontaktieren Sie den Administrator, wenn Sie die PIN nicht kennen.',
  'kiosk_unlock': 'Entsperren',

  // ════════════════════════════════════════════════════════════════════════
  // PIN
  // ════════════════════════════════════════════════════════════════════════
  'pin_title': 'PIN eingeben',
  'pin_cleaner_title': 'Mitarbeiterzugang',
  'pin_admin_title': 'Admin-Zugang',
  'pin_enter': 'Geben Sie Ihren PIN-Code ein',
  'pin_incorrect': 'Falsche PIN',
  'pin_attempts_left': 'Verbleibende Versuche: {count}',
  'pin_locked': 'Zu viele Versuche. Versuchen Sie es in {minutes} Minuten erneut.',
  'pin_forgot': 'PIN vergessen?',

  // ════════════════════════════════════════════════════════════════════════
  // SETUP
  // ════════════════════════════════════════════════════════════════════════
  'setup_app_name': 'VillaOS',
  'setup_app_subtitle': 'Digitales Empfangssystem',
  'setup_tagline': 'Die Rezeption,\ndie nie schläft',
  'setup_description': 'Automatisieren Sie den Check-in, begeistern Sie Gäste,\nverbessern Sie Bewertungen',
  'setup_connect_title': 'GERÄT VERBINDEN',
  'setup_connect_subtitle': 'Verbinden Sie dieses Tablet mit Ihrer Unterkunft',
  'setup_tenant_label': 'Tenant ID',
  'setup_tenant_hint': 'z.B. TEST22',
  'setup_unit_label': 'Unit ID',
  'setup_unit_hint': 'z.B. PLAVI',
  'setup_btn_connect': 'VERBINDEN',
  'setup_connecting': 'Verbinde...',
  'setup_finding_unit': 'Suche Einheit...',
  'setup_registering': 'Registriere Gerät...',
  'setup_syncing': 'Synchronisiere Einstellungen...',
  'setup_connected': 'Verbunden!',
  'setup_stat_properties': 'Unterkünfte',
  'setup_stat_checkins': 'Check-ins',
  'setup_stat_uptime': 'Betriebszeit',

  // ════════════════════════════════════════════════════════════════════════
  // VALIDATION
  // ════════════════════════════════════════════════════════════════════════
  'validation_required': 'Erforderlich',
  'validation_invalid': 'Ungültige Eingabe',
  'validation_too_short': 'Zu kurz',
  'validation_too_long': 'Zu lang',

  // ════════════════════════════════════════════════════════════════════════
  // ADMIN
  // ════════════════════════════════════════════════════════════════════════
  'admin_title': 'Admin-Panel',
  'admin_unit_label': 'Einheit:',
  'admin_not_available': 'N/V',
  'admin_debug': 'Debug-Panel',
  'admin_kiosk_disable': 'Kiosk deaktivieren (5 min)',
  'admin_sync': 'Jetzt synchronisieren',
  'admin_factory_reset': 'Werksreset',
  'admin_factory_reset_confirm': 'Dadurch wird dieses Tablet von der Einheit getrennt. Sind Sie sicher?',
  'debug_status': 'Status',
  'debug_firebase': 'Firebase',
  'debug_storage': 'Speicher',
  'debug_tests': 'Tests',
  'debug_actions': 'Aktionen',

  // ════════════════════════════════════════════════════════════════════════
  // OFFLINE
  // ════════════════════════════════════════════════════════════════════════
  'offline_banner': 'Sie sind offline',
  'offline_limited': 'Eingeschränkte Funktionalität',
  'offline_reconnecting': 'Verbindung wird wiederhergestellt...',
  'offline_connected': 'Wieder online!',

  // ════════════════════════════════════════════════════════════════════════
  // ERRORS
  // ════════════════════════════════════════════════════════════════════════
  'error_generic': 'Etwas ist schief gelaufen',
  'error_network': 'Netzwerkfehler',
  'error_try_again': 'Bitte versuchen Sie es erneut',
  'error_timeout': 'Zeitüberschreitung',
  'error_not_found': 'Nicht gefunden',
};
