// FILE: lib/utils/translations/lang_es.dart
// VERZIJA: 4.0 - ESPAÑOL
// DATUM: 2026-01-11

const Map<String, String> esTranslations = {
  // ════════════════════════════════════════════════════════════════════════
  // WELCOME SCREEN
  // ════════════════════════════════════════════════════════════════════════
  'welcome_app_title': 'VILLA CONCIERGE',
  'welcome_select_language': 'Por favor selecciona tu idioma',
  'welcome_powered_by': 'Powered by VillaOS',
  'welcome_title': 'Bienvenido a\nVilla Mare',
  'welcome_subtitle': '¿Cómo puedo ayudarte hoy?',

  // ════════════════════════════════════════════════════════════════════════
  // CHECK-IN INTRO
  // ════════════════════════════════════════════════════════════════════════
  'intro_title': 'Check-in Online',
  'intro_desc': 'Según las leyes de turismo, estamos obligados a registrar a todos los huéspedes.',
  'start_btn': 'INICIAR CHECK-IN',
  'skip_btn': 'Más tarde (Saltar)',
  'gdpr_badge': 'Cumple GDPR • Datos protegidos',
  'consents_title': 'CONSENTIMIENTOS REQUERIDOS',
  'consents_subtitle': 'Por favor lee y acepta ambos documentos',
  'gdpr_consent_title': 'Consentimiento de procesamiento de datos (GDPR)',
  'truth_consent_title': 'Declaración y consentimiento de escaneo',
  'consent_gdpr': 'Acepto el escaneo de documentos para registro eVisitor. No se guardan fotos.',
  'consent_truth': 'Confirmo que los datos proporcionados son precisos.',
  'gdpr_full_text': 'Tus documentos se escanean solo para extraer datos. Las fotos NO se guardan.',
  'truth_full_text': 'Declaro que toda la información proporcionada es veraz y precisa.',
  'btn_accept': 'ACEPTO',

  // ════════════════════════════════════════════════════════════════════════
  // DOCUMENT SELECTION
  // ════════════════════════════════════════════════════════════════════════
  'doc_select_title': 'Selecciona tipo de documento',
  'issuing_country': 'PAÍS DE EMISIÓN',
  'doc_type': 'TIPO DE DOCUMENTO',
  'doc_id_card': 'DNI / Cédula',
  'doc_passport': 'Pasaporte',
  'doc_id_sub': 'Anverso y reverso',
  'doc_passport_sub': 'Página con foto',
  'open_camera': 'ABRIR CÁMARA',

  // ════════════════════════════════════════════════════════════════════════
  // CAMERA SCREEN
  // ════════════════════════════════════════════════════════════════════════
  'cam_permission_needed': 'Se requiere permiso de cámara',
  'cam_not_found': 'No se encontró cámara',
  'cam_error': 'Error de cámara',
  'cam_initializing': 'Inicializando cámara...',
  'cam_front_side': 'Anverso',
  'cam_back_side': 'Reverso',
  'cam_guest': 'Huésped',
  'cam_skip_to_back': 'IR AL REVERSO >',
  'cam_skip_to_review': 'IR A REVISIÓN >',
  'cam_position_doc': '📄 Posiciona el documento en el marco',
  'cam_position_mrz': '📄 Posiciona la zona MRZ en el marco',
  'cam_flip_doc': '🔄 Voltea el documento al REVERSO',
  'cam_front_complete': '✅ ¡Anverso completo! Ahora escanea el REVERSO',
  'cam_mrz_detected': '✅ ¡MRZ Detectado!',
  'cam_scanning_mrz': 'Escaneando zona MRZ...',
  'cam_personal_data': 'DATOS PERSONALES',
  'cam_address_data': 'DIRECCIÓN',
  'cam_scanning': 'Escaneando...',
  'cam_detected': 'detectado',
  'cam_reset_field': 'Restablecer campo',
  'cam_continue_manual': 'CONTINUAR MANUALMENTE →',
  'cam_verify_data': 'Verifica y corrige si es necesario',
  'cam_name_required': 'Nombre y apellido son obligatorios',
  'cam_guest_saved': 'Huésped guardado:',
  'cam_save_next': 'GUARDAR & SIGUIENTE HUÉSPED',
  'cam_finish_checkin': 'FINALIZAR CHECK-IN',
  'cam_back_scanned': '¡Reverso escaneado!',
  'cam_mrz_not_found': 'MRZ no encontrado. Intenta de nuevo.',
  'cam_processing': 'Procesando...',
  'cam_manual_entry': 'Entrada manual',
  'cam_skip_scan_confirm': '¿Deseas saltar el escaneo e ingresar datos manualmente?',
  'cam_yes_manual': 'Sí, entrada manual',
  'cam_manual': 'Manual',
  'cam_position_back': 'Posiciona el REVERSO del documento\n(zona MRZ con <<<)',
  'cam_position_front': 'Posiciona el ANVERSO del documento\n(con foto)',
  'cam_mrz_zone': 'ZONA MRZ',

  // ════════════════════════════════════════════════════════════════════════
  // GUEST CONFIRMATION SCREEN
  // ════════════════════════════════════════════════════════════════════════
  'confirm_rescan': 'Re-escanear',
  'confirm_fill_fields': 'Completar campos',
  'confirm_fields_required': 'Todos los campos son obligatorios para el registro eVisitor',
  'confirm_place_of_birth': 'Lugar de nacimiento',
  'confirm_country_of_birth': 'País de nacimiento',
  'confirm_document': 'DOCUMENTO',
  'confirm_residence': 'RESIDENCIA',
  'confirm_country': 'País',
  'confirm_city': 'Ciudad',
  'confirm_stay': 'ESTANCIA',
  'confirm_arrival': 'Llegada',
  'confirm_departure': 'Salida',
  'confirm_next_guest': 'Confirmar & siguiente huésped',
  'confirm_continue': 'Confirmar & continuar',
  'confirm_male': 'M (Masculino)',
  'confirm_female': 'F (Femenino)',

  // ════════════════════════════════════════════════════════════════════════
  // CHECK-IN SUCCESS SCREEN
  // ════════════════════════════════════════════════════════════════════════
  'success_checkin_complete': '¡CHECK-IN COMPLETADO!',
  'success_welcome': 'Bienvenido',
  'success_guest': 'Huésped',
  'success_guests': 'Huéspedes',
  'success_duration': 'Duración',
  'success_confirmed': 'Confirmado',
  'success_auto_redirect': 'Redirección automática en {seconds} segundos...',

  // ════════════════════════════════════════════════════════════════════════
  // FORM FIELDS
  // ════════════════════════════════════════════════════════════════════════
  'field_first_name': 'Nombre',
  'field_last_name': 'Apellido',
  'field_doc_number': 'Número de documento',
  'field_birth_date': 'Fecha de nacimiento',
  'field_gender': 'Género',
  'field_nationality': 'Nacionalidad',
  'field_address': 'Dirección',
  'field_expiry_date': 'Fecha de vencimiento',

  // ════════════════════════════════════════════════════════════════════════
  // BUTTONS
  // ════════════════════════════════════════════════════════════════════════
  'btn_retake': 'Repetir',
  'btn_next': 'Siguiente',
  'btn_finish': 'Finalizar',
  'btn_cancel': 'Cancelar',
  'btn_close': 'Cerrar',
  'btn_confirm': 'Confirmar',
  'btn_done': 'HECHO',
  'btn_back': 'Atrás',
  'btn_save': 'Guardar',
  'btn_continue': 'Continuar',

  // ════════════════════════════════════════════════════════════════════════
  // HOUSE RULES
  // ════════════════════════════════════════════════════════════════════════
  'house_rules_title': 'REGLAS DE LA CASA',
  'house_rules_subtitle': 'Por favor lee y firma para continuar.',
  'guest_signature': 'FIRMA DEL HUÉSPED',
  'guest_name': 'NOMBRE COMPLETO',
  'enter_name': 'Ingresa tu nombre completo',
  'enter_name_first': 'Ingresa primero el nombre',
  'signature': 'FIRMA',
  'sign_here': 'Firma aquí con el dedo',
  'clear': 'Borrar',
  'signature_legal': 'Al firmar, confirmas que has leído y aceptas estas reglas de la casa.',
  'agree_continue': 'ACEPTO Y CONTINÚO',
  'please_sign': 'POR FAVOR FIRMA',
  'rules_accepted': '¡Reglas aceptadas! PDF generado.',
  'error': 'Error',

  // ════════════════════════════════════════════════════════════════════════
  // DASHBOARD
  // ════════════════════════════════════════════════════════════════════════
  'default_villa_name': 'Villa Huésped',
  'loading_stay': 'Cargando tu estancia...',
  'welcome_comma': 'Bienvenido,',
  'welcome_to': 'Bienvenido a',
  'guests_count': '{count} huéspedes',
  'checkout_label': 'Check-out:',
  'wifi_pass_label': 'Contraseña:',
  'check_in_complete': 'CHECK-IN COMPLETADO',
  'check_out': 'Check-out',
  'checkout_confirm': '¿Estás seguro de que quieres hacer check-out?',
  'checkout_date_info': 'Fecha de check-out: {date}',
  'need_help': '¿Necesitas ayuda?',
  'contact_host': 'Contacta directamente al anfitrión:',
  'agent_reception': 'Recepción',
  'agent_house': 'Casa Inteligente',
  'agent_gastro': 'Guía Gastronómica',
  'agent_local': 'Guía Local',
  'agent_desc_reception': 'Chat, FAQ, Asistencia',
  'agent_desc_house': 'AC, Luces, Piscina',
  'agent_desc_gastro': 'Restaurantes & Delivery',
  'agent_desc_local': 'Playas, Tours, Eventos',

  // ════════════════════════════════════════════════════════════════════════
  // CHAT
  // ════════════════════════════════════════════════════════════════════════
  'thinking': 'Pensando...',
  'type_message': 'Escribe un mensaje...',
  'chat_hello': 'Hola',
  'chat_hello_name': '¡Hola {name}!',
  'chat_no_internet': 'Sin internet. Asistente IA no disponible.',
  'chat_error': 'Lo siento, tengo problemas de conexión. Por favor intenta de nuevo.',
  'chat_no_internet_places': 'Sin internet. No se pueden buscar lugares.',
  'chat_search_failed': 'Búsqueda fallida. Verifica tu conexión a internet.',
  'chat_connecting': 'Conectando a {agent}...',
  'status_online': 'En línea',
  'status_offline': 'Desconectado',
  'quick_wifi': '📶 ¿Contraseña WiFi?',
  'quick_wifi_full': '¿Cuál es la contraseña del WiFi?',
  'quick_checkout_time': '🕐 ¿Hora de check-out?',
  'quick_checkout_time_full': '¿A qué hora es el check-out?',
  'quick_rules': '📋 Reglas de la casa',
  'quick_rules_full': 'Muéstrame las reglas de la casa',
  'quick_contact': '📞 Contactar anfitrión',
  'quick_contact_full': '¿Cómo puedo contactar al anfitrión?',
  'find_nearby': 'Encontrar cerca',
  'searching_nearby': 'Buscando cerca...',
  'searching_restaurants': 'Buscando restaurantes...',
  'searching_attractions': 'Buscando atracciones...',
  'searching_pharmacy': 'Buscando farmacia/médico...',
  'places_found': 'Aquí hay algunos lugares bien valorados cerca:',
  'no_places_found': 'No encontré lugares cerca. Verifica la dirección de la villa.',

  // ════════════════════════════════════════════════════════════════════════
  // FEEDBACK
  // ════════════════════════════════════════════════════════════════════════
  'feedback_title': 'Check-out & Opinión',
  'feedback_subtitle': 'Antes de irte, califica tu estancia.',
  'thank_you': 'Gracias',
  'feedback_comment_label': '¿QUÉ PODEMOS MEJORAR?',
  'feedback_comment_hint': 'Dinos qué podemos hacer mejor...',
  'submit_feedback': 'ENVIAR OPINIÓN',
  'skip_feedback': 'Saltar & Check-out',
  'thank_you_perfect': '¡Eres increíble! 💖',
  'thank_you_feedback': '¡Gracias!',
  'perfect_stay_message': '¡Nos alegra que hayas disfrutado tu estancia! Si tienes un momento, déjanos una reseña.',
  'feedback_received_message': 'Tu opinión nos ayuda a mejorar. ¡Buen viaje!',
  'feedback_offline_saved': 'Opinión guardada. Se sincronizará cuando esté en línea.',
  'scan_for_review': 'Escanea para dejar una reseña en Google',
  'glad_you_enjoyed': '¡Nos alegra que hayas disfrutado tu estancia!',
  'complete_checkout': 'COMPLETAR CHECK-OUT',
  'touch_to_continue': 'Toca la pantalla para continuar',
  'rating_1': 'Muy malo 😞',
  'rating_2': 'Malo 😕',
  'rating_3': 'Regular 😐',
  'rating_4': 'Bueno 😊',
  'rating_5': '¡Excelente! 🤩',

  // ════════════════════════════════════════════════════════════════════════
  // CLEANER
  // ════════════════════════════════════════════════════════════════════════
  'cleaner_title': 'Acceso Personal',
  'cleaner_mode': 'MODO LIMPIEZA',
  'cleaner_checklist': 'Lista de limpieza',
  'cleaner_booking_label': 'Reserva:',
  'cleaner_tasks_label': 'TAREAS',
  'cleaner_notes': 'Reportar problema / Notas',
  'cleaner_notes_label': 'NOTAS PARA EL PROPIETARIO',
  'cleaner_notes_hint': 'Reporta problemas, artículos faltantes o cualquier cosa que el propietario deba saber.',
  'cleaner_notes_placeholder': 'ej. Lámpara rota en dormitorio, poco shampoo...',
  'cleaner_privacy_notice': 'Al tocar FINALIZAR, las firmas de huéspedes y documentos escaneados se eliminarán permanentemente por privacidad.',
  'cleaner_not_all_tasks': 'No todas las tareas están marcadas.\n¿Estás seguro de que quieres finalizar?',
  'cleaner_finish_anyway': 'FINALIZAR DE TODOS MODOS',
  'cleaner_offline_saved': 'Reporte guardado. Se sincronizará cuando esté en línea.',
  'cleaner_processing': 'PROCESANDO...',
  'cleaner_complete_btn': 'COMPLETADO',
  'cleaner_finish_btn': 'FINALIZAR & REPORTAR',
  'cleaner_finish': 'FINALIZAR & PREPARAR PARA HUÉSPED',
  'cleaner_cleanup_progress': 'Limpiando datos...',
  'cleaner_cleanup_archive': 'Archivando reserva, eliminando firmas...',
  'cleaner_complete_title': '¡Limpieza completada!',
  'cleaner_summary_title': 'Resumen de limpieza de datos',
  'cleaner_signatures_deleted': 'Firmas eliminadas',
  'cleaner_guests_deleted': 'Registros de huéspedes eliminados',
  'cleaner_booking_archived': 'Reserva archivada',
  'cleaner_report_queued': 'Reporte en cola. La limpieza de datos se ejecutará cuando esté en línea.',
  'cleaner_success_online': 'Reporte enviado al propietario.\nTablet lista para nuevos huéspedes.',
  'cleaner_success_offline': 'Reporte guardado localmente.\nTablet lista para nuevos huéspedes.',
  'cleaner_default_error': 'Usando lista predeterminada (no se pudo cargar del servidor)',

  // ════════════════════════════════════════════════════════════════════════
  // KIOSK MODE
  // ════════════════════════════════════════════════════════════════════════
  'kiosk_mode_title': 'Modo Kiosko',
  'kiosk_enter_pin': 'Ingresa PIN de 6 dígitos para salir:',
  'kiosk_enter_all_digits': 'Ingresa los 6 dígitos',
  'kiosk_too_many_attempts': 'Demasiados intentos. Intenta más tarde.',
  'kiosk_wrong_pin_attempts': 'PIN incorrecto. Intentos restantes: {attempts}',
  'kiosk_contact_admin': 'Contacta al administrador si no conoces el PIN.',
  'kiosk_unlock': 'Desbloquear',

  // ════════════════════════════════════════════════════════════════════════
  // PIN
  // ════════════════════════════════════════════════════════════════════════
  'pin_title': 'Ingresa PIN',
  'pin_cleaner_title': 'Acceso Personal',
  'pin_admin_title': 'Acceso Admin',
  'pin_enter': 'Ingresa tu código PIN',
  'pin_incorrect': 'PIN incorrecto',
  'pin_attempts_left': 'Intentos restantes: {count}',
  'pin_locked': 'Demasiados intentos. Intenta en {minutes} minutos.',
  'pin_forgot': '¿Olvidaste el PIN?',

  // ════════════════════════════════════════════════════════════════════════
  // SETUP
  // ════════════════════════════════════════════════════════════════════════
  'setup_app_name': 'VillaOS',
  'setup_app_subtitle': 'Sistema de recepción digital',
  'setup_tagline': 'La Recepción\nQue Nunca Duerme',
  'setup_description': 'Automatiza el check-in, deleita huéspedes,\nmejora tus reseñas',
  'setup_connect_title': 'CONECTAR DISPOSITIVO',
  'setup_connect_subtitle': 'Vincula esta tablet a tu propiedad',
  'setup_tenant_label': 'Tenant ID',
  'setup_tenant_hint': 'ej. TEST22',
  'setup_unit_label': 'Unit ID',
  'setup_unit_hint': 'ej. PLAVI',
  'setup_btn_connect': 'CONECTAR',
  'setup_connecting': 'Conectando...',
  'setup_finding_unit': 'Buscando unidad...',
  'setup_registering': 'Registrando dispositivo...',
  'setup_syncing': 'Sincronizando configuración...',
  'setup_connected': '¡Conectado!',
  'setup_stat_properties': 'Propiedades',
  'setup_stat_checkins': 'Check-ins',
  'setup_stat_uptime': 'Tiempo activo',

  // ════════════════════════════════════════════════════════════════════════
  // VALIDATION
  // ════════════════════════════════════════════════════════════════════════
  'validation_required': 'Obligatorio',
  'validation_invalid': 'Entrada no válida',
  'validation_too_short': 'Muy corto',
  'validation_too_long': 'Muy largo',

  // ════════════════════════════════════════════════════════════════════════
  // ADMIN
  // ════════════════════════════════════════════════════════════════════════
  'admin_title': 'Panel Admin',
  'admin_unit_label': 'Unidad:',
  'admin_not_available': 'N/D',
  'admin_debug': 'Panel Debug',
  'admin_kiosk_disable': 'Desactivar Kiosko (5 min)',
  'admin_sync': 'Sincronizar ahora',
  'admin_factory_reset': 'Restablecimiento de fábrica',
  'admin_factory_reset_confirm': 'Esto desconectará esta tablet de la unidad. ¿Estás seguro?',
  'debug_status': 'Estado',
  'debug_firebase': 'Firebase',
  'debug_storage': 'Almacenamiento',
  'debug_tests': 'Pruebas',
  'debug_actions': 'Acciones',

  // ════════════════════════════════════════════════════════════════════════
  // OFFLINE
  // ════════════════════════════════════════════════════════════════════════
  'offline_banner': 'Estás sin conexión',
  'offline_limited': 'Funcionalidad limitada',
  'offline_reconnecting': 'Reconectando...',
  'offline_connected': '¡De vuelta en línea!',

  // ════════════════════════════════════════════════════════════════════════
  // ERRORS
  // ════════════════════════════════════════════════════════════════════════
  'error_generic': 'Algo salió mal',
  'error_network': 'Error de red',
  'error_try_again': 'Por favor intenta de nuevo',
  'error_timeout': 'Tiempo de espera agotado',
  'error_not_found': 'No encontrado',
};
