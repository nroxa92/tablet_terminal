// FILE: lib/utils/translations/lang_fr.dart
// VERZIJA: 4.0 - FRANÇAIS
// DATUM: 2026-01-11

const Map<String, String> frTranslations = {
  // ════════════════════════════════════════════════════════════════════════
  // WELCOME SCREEN
  // ════════════════════════════════════════════════════════════════════════
  'welcome_app_title': 'VILLA CONCIERGE',
  'welcome_select_language': 'Veuillez sélectionner votre langue',
  'welcome_powered_by': 'Powered by VillaOS',
  'welcome_title': 'Bienvenue à\nVilla Mare',
  'welcome_subtitle': 'Comment puis-je vous aider aujourd\'hui?',

  // ════════════════════════════════════════════════════════════════════════
  // CHECK-IN INTRO
  // ════════════════════════════════════════════════════════════════════════
  'intro_title': 'Enregistrement en ligne',
  'intro_desc': 'Selon les lois touristiques, nous sommes tenus d\'enregistrer tous les clients.',
  'start_btn': 'COMMENCER L\'ENREGISTREMENT',
  'skip_btn': 'Plus tard (Passer)',
  'gdpr_badge': 'Conforme RGPD • Données protégées',
  'consents_title': 'CONSENTEMENTS REQUIS',
  'consents_subtitle': 'Veuillez lire et accepter les deux documents',
  'gdpr_consent_title': 'Consentement au traitement des données (RGPD)',
  'truth_consent_title': 'Déclaration et consentement de numérisation',
  'consent_gdpr': 'J\'accepte la numérisation des documents pour l\'enregistrement eVisitor. Aucune photo n\'est stockée.',
  'consent_truth': 'Je confirme que les données fournies sont exactes.',
  'gdpr_full_text': 'Vos documents sont numérisés uniquement pour extraire les données. Les photos ne sont PAS stockées.',
  'truth_full_text': 'Je déclare que toutes les informations fournies sont véridiques et exactes.',
  'btn_accept': 'J\'ACCEPTE',

  // ════════════════════════════════════════════════════════════════════════
  // DOCUMENT SELECTION
  // ════════════════════════════════════════════════════════════════════════
  'doc_select_title': 'Sélectionner le type de document',
  'issuing_country': 'PAYS D\'ÉMISSION',
  'doc_type': 'TYPE DE DOCUMENT',
  'doc_id_card': 'Carte d\'identité',
  'doc_passport': 'Passeport',
  'doc_id_sub': 'Recto et verso',
  'doc_passport_sub': 'Page photo',
  'open_camera': 'OUVRIR LA CAMÉRA',

  // ════════════════════════════════════════════════════════════════════════
  // CAMERA SCREEN
  // ════════════════════════════════════════════════════════════════════════
  'cam_permission_needed': 'Permission caméra requise',
  'cam_not_found': 'Aucune caméra trouvée',
  'cam_error': 'Erreur caméra',
  'cam_initializing': 'Initialisation de la caméra...',
  'cam_front_side': 'Recto',
  'cam_back_side': 'Verso',
  'cam_guest': 'Client',
  'cam_skip_to_back': 'ALLER AU VERSO >',
  'cam_skip_to_review': 'ALLER À LA RÉVISION >',
  'cam_position_doc': '📄 Positionnez le document dans le cadre',
  'cam_position_mrz': '📄 Positionnez la zone MRZ dans le cadre',
  'cam_flip_doc': '🔄 Retournez le document côté VERSO',
  'cam_front_complete': '✅ Recto terminé ! Maintenant numérisez le VERSO',
  'cam_mrz_detected': '✅ MRZ Détecté !',
  'cam_scanning_mrz': 'Numérisation de la zone MRZ...',
  'cam_personal_data': 'DONNÉES PERSONNELLES',
  'cam_address_data': 'ADRESSE',
  'cam_scanning': 'Numérisation...',
  'cam_detected': 'détecté',
  'cam_reset_field': 'Réinitialiser le champ',
  'cam_continue_manual': 'CONTINUER MANUELLEMENT →',
  'cam_verify_data': 'Veuillez vérifier et corriger si nécessaire',
  'cam_name_required': 'Le nom et le prénom sont obligatoires',
  'cam_guest_saved': 'Client enregistré :',
  'cam_save_next': 'ENREGISTRER & CLIENT SUIVANT',
  'cam_finish_checkin': 'TERMINER L\'ENREGISTREMENT',
  'cam_back_scanned': 'Verso numérisé !',
  'cam_mrz_not_found': 'MRZ non trouvé. Réessayez.',
  'cam_processing': 'Traitement...',
  'cam_manual_entry': 'Saisie manuelle',
  'cam_skip_scan_confirm': 'Voulez-vous ignorer la numérisation et saisir les données manuellement ?',
  'cam_yes_manual': 'Oui, saisie manuelle',
  'cam_manual': 'Manuel',
  'cam_position_back': 'Positionnez le VERSO du document\n(zone MRZ avec <<<)',
  'cam_position_front': 'Positionnez le RECTO du document\n(avec photo)',
  'cam_mrz_zone': 'ZONE MRZ',

  // ════════════════════════════════════════════════════════════════════════
  // GUEST CONFIRMATION SCREEN
  // ════════════════════════════════════════════════════════════════════════
  'confirm_rescan': 'Re-numériser',
  'confirm_fill_fields': 'Remplir les champs',
  'confirm_fields_required': 'Tous les champs sont obligatoires pour l\'enregistrement eVisitor',
  'confirm_place_of_birth': 'Lieu de naissance',
  'confirm_country_of_birth': 'Pays de naissance',
  'confirm_document': 'DOCUMENT',
  'confirm_residence': 'RÉSIDENCE',
  'confirm_country': 'Pays',
  'confirm_city': 'Ville',
  'confirm_stay': 'SÉJOUR',
  'confirm_arrival': 'Arrivée',
  'confirm_departure': 'Départ',
  'confirm_next_guest': 'Confirmer & client suivant',
  'confirm_continue': 'Confirmer & continuer',
  'confirm_male': 'M (Masculin)',
  'confirm_female': 'F (Féminin)',

  // ════════════════════════════════════════════════════════════════════════
  // CHECK-IN SUCCESS SCREEN
  // ════════════════════════════════════════════════════════════════════════
  'success_checkin_complete': 'ENREGISTREMENT RÉUSSI !',
  'success_welcome': 'Bienvenue',
  'success_guest': 'Client',
  'success_guests': 'Clients',
  'success_duration': 'Durée',
  'success_confirmed': 'Confirmé',
  'success_auto_redirect': 'Redirection automatique dans {seconds} secondes...',

  // ════════════════════════════════════════════════════════════════════════
  // FORM FIELDS
  // ════════════════════════════════════════════════════════════════════════
  'field_first_name': 'Prénom',
  'field_last_name': 'Nom',
  'field_doc_number': 'Numéro de document',
  'field_birth_date': 'Date de naissance',
  'field_gender': 'Genre',
  'field_nationality': 'Nationalité',
  'field_address': 'Adresse',
  'field_expiry_date': 'Date d\'expiration',

  // ════════════════════════════════════════════════════════════════════════
  // BUTTONS
  // ════════════════════════════════════════════════════════════════════════
  'btn_retake': 'Reprendre',
  'btn_next': 'Suivant',
  'btn_finish': 'Terminer',
  'btn_cancel': 'Annuler',
  'btn_close': 'Fermer',
  'btn_confirm': 'Confirmer',
  'btn_done': 'FAIT',
  'btn_back': 'Retour',
  'btn_save': 'Enregistrer',
  'btn_continue': 'Continuer',

  // ════════════════════════════════════════════════════════════════════════
  // HOUSE RULES
  // ════════════════════════════════════════════════════════════════════════
  'house_rules_title': 'RÈGLEMENT INTÉRIEUR',
  'house_rules_subtitle': 'Veuillez lire et signer pour continuer.',
  'guest_signature': 'SIGNATURE DU CLIENT',
  'guest_name': 'NOM COMPLET',
  'enter_name': 'Entrez votre nom complet',
  'enter_name_first': 'Entrez d\'abord le nom',
  'signature': 'SIGNATURE',
  'sign_here': 'Signez ici avec votre doigt',
  'clear': 'Effacer',
  'signature_legal': 'En signant, vous confirmez avoir lu et accepté ce règlement intérieur.',
  'agree_continue': 'J\'ACCEPTE ET CONTINUE',
  'please_sign': 'VEUILLEZ SIGNER',
  'rules_accepted': 'Règlement accepté ! PDF généré.',
  'error': 'Erreur',

  // ════════════════════════════════════════════════════════════════════════
  // DASHBOARD
  // ════════════════════════════════════════════════════════════════════════
  'default_villa_name': 'Villa Client',
  'loading_stay': 'Chargement de votre séjour...',
  'welcome_comma': 'Bienvenue,',
  'welcome_to': 'Bienvenue à',
  'guests_count': '{count} clients',
  'checkout_label': 'Départ :',
  'wifi_pass_label': 'Mot de passe :',
  'check_in_complete': 'ENREGISTREMENT TERMINÉ',
  'check_out': 'Départ',
  'checkout_confirm': 'Êtes-vous sûr de vouloir partir ?',
  'checkout_date_info': 'Date de départ : {date}',
  'need_help': 'Besoin d\'aide ?',
  'contact_host': 'Contactez directement l\'hôte :',
  'agent_reception': 'Réception',
  'agent_house': 'Maison Connectée',
  'agent_gastro': 'Guide Gastronomique',
  'agent_local': 'Guide Local',
  'agent_desc_reception': 'Chat, FAQ, Assistance',
  'agent_desc_house': 'Clim, Lumières, Piscine',
  'agent_desc_gastro': 'Restaurants & Livraison',
  'agent_desc_local': 'Plages, Tours, Événements',

  // ════════════════════════════════════════════════════════════════════════
  // CHAT
  // ════════════════════════════════════════════════════════════════════════
  'thinking': 'Je réfléchis...',
  'type_message': 'Tapez un message...',
  'chat_hello': 'Bonjour',
  'chat_hello_name': 'Bonjour {name} !',
  'chat_no_internet': 'Pas d\'internet. Assistant IA indisponible.',
  'chat_error': 'Désolé, j\'ai des problèmes de connexion. Veuillez réessayer.',
  'chat_no_internet_places': 'Pas d\'internet. Impossible de rechercher des lieux.',
  'chat_search_failed': 'Recherche échouée. Vérifiez votre connexion internet.',
  'chat_connecting': 'Connexion à {agent}...',
  'status_online': 'En ligne',
  'status_offline': 'Hors ligne',
  'quick_wifi': '📶 Mot de passe WiFi ?',
  'quick_wifi_full': 'Quel est le mot de passe WiFi ?',
  'quick_checkout_time': '🕐 Heure de départ ?',
  'quick_checkout_time_full': 'À quelle heure est le départ ?',
  'quick_rules': '📋 Règlement intérieur',
  'quick_rules_full': 'Montrez-moi le règlement intérieur',
  'quick_contact': '📞 Contacter l\'hôte',
  'quick_contact_full': 'Comment puis-je contacter l\'hôte ?',
  'find_nearby': 'Trouver à proximité',
  'searching_nearby': 'Recherche à proximité...',
  'searching_restaurants': 'Recherche de restaurants...',
  'searching_attractions': 'Recherche d\'attractions...',
  'searching_pharmacy': 'Recherche pharmacie/médecin...',
  'places_found': 'Voici quelques lieux bien notés à proximité :',
  'no_places_found': 'Aucun lieu trouvé à proximité. Vérifiez l\'adresse de la villa.',

  // ════════════════════════════════════════════════════════════════════════
  // FEEDBACK
  // ════════════════════════════════════════════════════════════════════════
  'feedback_title': 'Départ & Avis',
  'feedback_subtitle': 'Avant de partir, notez votre séjour.',
  'thank_you': 'Merci',
  'feedback_comment_label': 'QUE POUVONS-NOUS AMÉLIORER ?',
  'feedback_comment_hint': 'Dites-nous ce que nous pouvons améliorer...',
  'submit_feedback': 'ENVOYER L\'AVIS',
  'skip_feedback': 'Passer & Partir',
  'thank_you_perfect': 'Vous êtes formidable ! 💖',
  'thank_you_feedback': 'Merci !',
  'perfect_stay_message': 'Nous sommes ravis que vous ayez apprécié votre séjour ! Si vous avez un moment, laissez-nous un avis.',
  'feedback_received_message': 'Votre avis nous aide à nous améliorer. Bon voyage !',
  'feedback_offline_saved': 'Avis enregistré. Sera synchronisé une fois en ligne.',
  'scan_for_review': 'Scannez pour laisser un avis Google',
  'glad_you_enjoyed': 'Nous sommes ravis que vous ayez apprécié votre séjour !',
  'complete_checkout': 'TERMINER LE DÉPART',
  'touch_to_continue': 'Touchez l\'écran pour continuer',
  'rating_1': 'Très mauvais 😞',
  'rating_2': 'Mauvais 😕',
  'rating_3': 'Moyen 😐',
  'rating_4': 'Bon 😊',
  'rating_5': 'Excellent ! 🤩',

  // ════════════════════════════════════════════════════════════════════════
  // CLEANER
  // ════════════════════════════════════════════════════════════════════════
  'cleaner_title': 'Accès Personnel',
  'cleaner_mode': 'MODE NETTOYAGE',
  'cleaner_checklist': 'Liste de contrôle nettoyage',
  'cleaner_booking_label': 'Réservation :',
  'cleaner_tasks_label': 'TÂCHES',
  'cleaner_notes': 'Signaler un problème / Notes',
  'cleaner_notes_label': 'NOTES POUR LE PROPRIÉTAIRE',
  'cleaner_notes_hint': 'Signalez les problèmes, articles manquants ou tout ce que le propriétaire doit savoir.',
  'cleaner_notes_placeholder': 'ex. Lampe cassée dans la chambre, peu de shampoing...',
  'cleaner_privacy_notice': 'En appuyant sur TERMINER, les signatures des clients et documents numérisés seront définitivement supprimés pour la confidentialité.',
  'cleaner_not_all_tasks': 'Toutes les tâches ne sont pas cochées.\nÊtes-vous sûr de vouloir terminer ?',
  'cleaner_finish_anyway': 'TERMINER QUAND MÊME',
  'cleaner_offline_saved': 'Rapport enregistré. Sera synchronisé une fois en ligne.',
  'cleaner_processing': 'TRAITEMENT...',
  'cleaner_complete_btn': 'TERMINÉ',
  'cleaner_finish_btn': 'TERMINER & SIGNALER',
  'cleaner_finish': 'TERMINER & PRÉPARER POUR CLIENT',
  'cleaner_cleanup_progress': 'Nettoyage des données...',
  'cleaner_cleanup_archive': 'Archivage réservation, suppression signatures...',
  'cleaner_complete_title': 'Nettoyage terminé !',
  'cleaner_summary_title': 'Résumé du nettoyage des données',
  'cleaner_signatures_deleted': 'Signatures supprimées',
  'cleaner_guests_deleted': 'Données clients supprimées',
  'cleaner_booking_archived': 'Réservation archivée',
  'cleaner_report_queued': 'Rapport en file d\'attente. Le nettoyage des données s\'exécutera une fois en ligne.',
  'cleaner_success_online': 'Rapport envoyé au propriétaire.\nTablette prête pour nouveaux clients.',
  'cleaner_success_offline': 'Rapport enregistré localement.\nTablette prête pour nouveaux clients.',
  'cleaner_default_error': 'Utilisation de la liste par défaut (impossible de charger depuis le serveur)',

  // ════════════════════════════════════════════════════════════════════════
  // KIOSK MODE
  // ════════════════════════════════════════════════════════════════════════
  'kiosk_mode_title': 'Mode Kiosque',
  'kiosk_enter_pin': 'Entrez le PIN à 6 chiffres pour quitter :',
  'kiosk_enter_all_digits': 'Entrez les 6 chiffres',
  'kiosk_too_many_attempts': 'Trop de tentatives. Réessayez plus tard.',
  'kiosk_wrong_pin_attempts': 'PIN incorrect. Tentatives restantes : {attempts}',
  'kiosk_contact_admin': 'Contactez l\'administrateur si vous ne connaissez pas le PIN.',
  'kiosk_unlock': 'Déverrouiller',

  // ════════════════════════════════════════════════════════════════════════
  // PIN
  // ════════════════════════════════════════════════════════════════════════
  'pin_title': 'Entrez le PIN',
  'pin_cleaner_title': 'Accès Personnel',
  'pin_admin_title': 'Accès Admin',
  'pin_enter': 'Entrez votre code PIN',
  'pin_incorrect': 'PIN incorrect',
  'pin_attempts_left': 'Tentatives restantes : {count}',
  'pin_locked': 'Trop de tentatives. Réessayez dans {minutes} minutes.',
  'pin_forgot': 'PIN oublié ?',

  // ════════════════════════════════════════════════════════════════════════
  // SETUP
  // ════════════════════════════════════════════════════════════════════════
  'setup_app_name': 'VillaOS',
  'setup_app_subtitle': 'Système de réception numérique',
  'setup_tagline': 'La Réception\nQui Ne Dort Jamais',
  'setup_description': 'Automatisez l\'enregistrement, enchantez les clients,\naméliorez vos avis',
  'setup_connect_title': 'CONNECTER L\'APPAREIL',
  'setup_connect_subtitle': 'Liez cette tablette à votre propriété',
  'setup_tenant_label': 'Tenant ID',
  'setup_tenant_hint': 'ex. TEST22',
  'setup_unit_label': 'Unit ID',
  'setup_unit_hint': 'ex. PLAVI',
  'setup_btn_connect': 'CONNECTER',
  'setup_connecting': 'Connexion...',
  'setup_finding_unit': 'Recherche de l\'unité...',
  'setup_registering': 'Enregistrement de l\'appareil...',
  'setup_syncing': 'Synchronisation des paramètres...',
  'setup_connected': 'Connecté !',
  'setup_stat_properties': 'Propriétés',
  'setup_stat_checkins': 'Enregistrements',
  'setup_stat_uptime': 'Disponibilité',

  // ════════════════════════════════════════════════════════════════════════
  // VALIDATION
  // ════════════════════════════════════════════════════════════════════════
  'validation_required': 'Obligatoire',
  'validation_invalid': 'Entrée non valide',
  'validation_too_short': 'Trop court',
  'validation_too_long': 'Trop long',

  // ════════════════════════════════════════════════════════════════════════
  // ADMIN
  // ════════════════════════════════════════════════════════════════════════
  'admin_title': 'Panneau Admin',
  'admin_unit_label': 'Unité :',
  'admin_not_available': 'N/D',
  'admin_debug': 'Panneau Debug',
  'admin_kiosk_disable': 'Désactiver Kiosque (5 min)',
  'admin_sync': 'Synchroniser maintenant',
  'admin_factory_reset': 'Réinitialisation usine',
  'admin_factory_reset_confirm': 'Cela déconnectera cette tablette de l\'unité. Êtes-vous sûr ?',
  'debug_status': 'Statut',
  'debug_firebase': 'Firebase',
  'debug_storage': 'Stockage',
  'debug_tests': 'Tests',
  'debug_actions': 'Actions',

  // ════════════════════════════════════════════════════════════════════════
  // OFFLINE
  // ════════════════════════════════════════════════════════════════════════
  'offline_banner': 'Vous êtes hors ligne',
  'offline_limited': 'Fonctionnalité limitée',
  'offline_reconnecting': 'Reconnexion...',
  'offline_connected': 'De retour en ligne !',

  // ════════════════════════════════════════════════════════════════════════
  // ERRORS
  // ════════════════════════════════════════════════════════════════════════
  'error_generic': 'Une erreur s\'est produite',
  'error_network': 'Erreur réseau',
  'error_try_again': 'Veuillez réessayer',
  'error_timeout': 'Délai d\'attente dépassé',
  'error_not_found': 'Non trouvé',
};
