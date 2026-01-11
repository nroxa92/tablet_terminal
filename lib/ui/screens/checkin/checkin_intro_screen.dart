// FILE: lib/ui/screens/checkin/checkin_intro_screen.dart
// OPIS: Uvodni ekran za check-in s GDPR pristankom.
// VERZIJA: 2.2 - Landscape bez scrollanja, dokumenti na klik

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../utils/translations/translations.dart';
import '../../../data/services/storage_service.dart';
import '../../../data/services/checkin_service.dart';

class CheckInIntroScreen extends StatefulWidget {
  const CheckInIntroScreen({super.key});

  @override
  State<CheckInIntroScreen> createState() => _CheckInIntroScreenState();
}

class _CheckInIntroScreenState extends State<CheckInIntroScreen> {
  // Praćenje je li dokument otvoren i prihvaćen
  bool _gdprOpened = false;
  bool _truthOpened = false;
  bool _gdprAccepted = false;
  bool _truthAccepted = false;
  bool _isLoading = false;

  // Gumb je aktivan samo ako su OBJE kvačice true
  bool get _canProceed => _gdprAccepted && _truthAccepted && !_isLoading;

  Future<void> _startProcess() async {
    if (!_canProceed) return;

    setState(() => _isLoading = true);

    try {
      final unitId = StorageService.getUnitId();

      if (unitId == null || unitId.isEmpty) {
        _showError('Unit ID nije pronađen. Molimo ponovno pokrenite setup.');
        return;
      }

      final booking = await CheckInService.getActiveBooking(unitId);

      if (booking == null) {
        _showError('Nema aktivne rezervacije za ovaj smještaj.');
        return;
      }

      final bookingId = booking['id'] as String;

      if (booking['is_scanned'] == true) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
        return;
      }

      if (mounted) {
        Navigator.pushNamed(
          context,
          '/guest-scan',
          arguments: {
            'bookingId': bookingId,
            'unitId': unitId,
          },
        );
      }
    } catch (e) {
      debugPrint('❌ Error starting process: $e');
      _showError('Greška: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _skipProcess() {
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  /// Otvara dokument u popup-u
  void _openDocument({
    required String title,
    required String content,
    required bool isGdpr,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (context) => _DocumentDialog(
        title: title,
        content: content,
        onAccept: () {
          Navigator.pop(context);
          setState(() {
            if (isGdpr) {
              _gdprOpened = true;
              _gdprAccepted = true;
            } else {
              _truthOpened = true;
              _truthAccepted = true;
            }
          });
        },
        onDecline: () {
          Navigator.pop(context);
          setState(() {
            if (isGdpr) {
              _gdprOpened = true;
              _gdprAccepted = false;
            } else {
              _truthOpened = true;
              _truthAccepted = false;
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Stack(
          children: [
            // Pozadina s gradijentom
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black, Color(0xFF1E1E1E)],
                  ),
                ),
              ),
            ),

            // Dekorativni elementi
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0x1AD4AF37),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // ═══════════════════════════════════════════════════════════
            // GLAVNI SADRŽAJ - LANDSCAPE LAYOUT (BEZ SCROLLANJA)
            // ═══════════════════════════════════════════════════════════
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
              child: Row(
                children: [
                  // ─────────────────────────────────────────────────────
                  // LIJEVA STRANA - Info
                  // ─────────────────────────────────────────────────────
                  Expanded(
                    flex: 4,
                    child: FadeInLeft(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Ikona
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(0x1AD4AF37),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0x4DD4AF37),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.verified_user_outlined,
                              size: 40,
                              color: Color(0xFFD4AF37),
                            ),
                          ),
                          const SizedBox(height: 25),

                          // Naslov
                          Text(
                            Translations.t('intro_title'),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Podnaslov
                          Text(
                            Translations.t('intro_desc'),
                            style: const TextStyle(
                              color: Color(0x99FFFFFF),
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 25),

                          // Info kartica
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0x1A2196F3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0x332196F3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: Colors.blue,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _getPrivacyExplanation(),
                                    style: const TextStyle(
                                      color: Color(0x99FFFFFF),
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // GDPR badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0x1A4CAF50),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0x334CAF50),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.shield_outlined,
                                  color: Colors.green,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _getGdprBadgeText(),
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 50),

                  // ─────────────────────────────────────────────────────
                  // DESNA STRANA - Dokumenti i gumbi
                  // ─────────────────────────────────────────────────────
                  Expanded(
                    flex: 5,
                    child: FadeInRight(
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0x1AFFFFFF),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _getConsentTitle(),
                              style: const TextStyle(
                                color: Color(0xFFD4AF37),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getConsentSubtitle(),
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 25),

                            // 1. GDPR DOKUMENT
                            _buildDocumentCard(
                              title: _getGdprTitle(),
                              subtitle: Translations.t('consent_gdpr'),
                              icon: Icons.document_scanner,
                              isOpened: _gdprOpened,
                              isAccepted: _gdprAccepted,
                              onTap: () => _openDocument(
                                title: _getGdprTitle(),
                                content: _getGdprFullText(),
                                isGdpr: true,
                              ),
                            ),

                            const SizedBox(height: 15),

                            // 2. TRUTH DOKUMENT
                            _buildDocumentCard(
                              title: _getTruthTitle(),
                              subtitle: Translations.t('consent_truth'),
                              icon: Icons.fact_check,
                              isOpened: _truthOpened,
                              isAccepted: _truthAccepted,
                              onTap: () => _openDocument(
                                title: _getTruthTitle(),
                                content: _getTruthFullText(),
                                isGdpr: false,
                              ),
                            ),

                            const SizedBox(height: 30),

                            // START GUMB
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _canProceed ? _startProcess : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD4AF37),
                                  foregroundColor: Colors.black,
                                  disabledBackgroundColor:
                                      const Color(0xFF333333),
                                  disabledForegroundColor:
                                      const Color(0xFF808080),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: _canProceed ? 8 : 0,
                                  shadowColor: const Color(0x80D4AF37),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.black,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            Translations.t('start_btn'),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          const Icon(Icons.arrow_forward,
                                              size: 20),
                                        ],
                                      ),
                              ),
                            ),

                            const SizedBox(height: 15),

                            // SKIP GUMB
                            TextButton.icon(
                              onPressed: _skipProcess,
                              icon: const Icon(
                                Icons.skip_next,
                                color: Color(0xFF808080),
                                size: 18,
                              ),
                              label: Text(
                                Translations.t('skip_btn'),
                                style: const TextStyle(
                                  color: Color(0xFF808080),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Back button
            Positioned(
              top: 15,
              left: 15,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isOpened,
    required bool isAccepted,
    required VoidCallback onTap,
  }) {
    final Color borderColor = isAccepted
        ? Colors.green
        : isOpened
            ? Colors.orange
            : const Color(0x1AFFFFFF);

    final Color bgColor = isAccepted
        ? const Color(0x1A4CAF50)
        : isOpened
            ? const Color(0x1AFF9800)
            : const Color(0x0DFFFFFF);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isAccepted
                    ? const Color(0x334CAF50)
                    : const Color(0x1AD4AF37),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isAccepted ? Colors.green : const Color(0xFFD4AF37),
                size: 26,
              ),
            ),
            const SizedBox(width: 15),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isAccepted ? Colors.green : Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Status icon
            Icon(
              isAccepted
                  ? Icons.check_circle
                  : isOpened
                      ? Icons.remove_circle_outline
                      : Icons.chevron_right,
              color: isAccepted
                  ? Colors.green
                  : isOpened
                      ? Colors.orange
                      : Colors.grey,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // PRIJEVODI
  // ═══════════════════════════════════════════════════════════

  String _getPrivacyExplanation() {
    final lang = StorageService.getLanguage();
    if (lang == 'hr') {
      return "Vaši dokumenti se skeniraju samo za izdvajanje podataka. "
          "Fotografije se NE pohranjuju.";
    }
    return "Your documents are scanned only to extract data. "
        "Photos are NOT stored.";
  }

  String _getGdprBadgeText() {
    final lang = StorageService.getLanguage();
    if (lang == 'hr') return "GDPR sukladno • Podaci zaštićeni";
    return "GDPR Compliant • Data Protected";
  }

  String _getConsentTitle() {
    final lang = StorageService.getLanguage();
    if (lang == 'hr') return "POTREBNI PRISTANCI";
    return "REQUIRED CONSENTS";
  }

  String _getConsentSubtitle() {
    final lang = StorageService.getLanguage();
    if (lang == 'hr') return "Molimo pročitajte i prihvatite oba dokumenta";
    return "Please read and accept both documents";
  }

  String _getGdprTitle() {
    final lang = StorageService.getLanguage();
    if (lang == 'hr') return "Pristanak za obradu podataka (GDPR)";
    return "Data Processing Consent (GDPR)";
  }

  String _getTruthTitle() {
    final lang = StorageService.getLanguage();
    if (lang == 'hr') return "Izjava i suglasnost za skeniranje";
    return "Declaration & Scanning Consent";
  }

  String _getGdprFullText() {
    final lang = StorageService.getLanguage();
    if (lang == 'hr') {
      return '''
INFORMIRANI PRISTANAK ZA OBRADU OSOBNIH PODATAKA
u skladu s Uredbom (EU) 2016/679 (GDPR)

VODITELJ OBRADE: Vlasnik smještajnog objekta registriran pri nadležnoj turističkoj zajednici.

PRAVNA OSNOVA OBRADE: Članak 6. stavak 1. točka (c) GDPR-a – obrada je nužna radi poštovanja pravnih obveza voditelja obrade sukladno:
• Zakonu o ugostiteljskoj djelatnosti (NN 85/15, 121/16, 99/18, 25/19, 98/19, 32/20, 42/20, 126/21)
• Pravilniku o načinu vođenja popisa turista te o obliku i sadržaju obrasca prijave turista turističkoj zajednici (NN 126/15)
• Zakonu o strancima (NN 133/20, 114/22, 151/22)

KATEGORIJE OSOBNIH PODATAKA KOJI SE OBRAĐUJU:
• Identifikacijski podaci: ime, prezime, spol, datum i mjesto rođenja
• Podaci o državljanstvu i nacionalnosti
• Podaci o identifikacijskoj ispravi: vrsta, broj i država izdavanja
• Adresa stalnog prebivališta

SVRHA OBRADE: Izvršavanje zakonske obveze prijave i odjave gostiju u sustav eVisitor te vođenje evidencije turista.

PRIMATELJI PODATAKA: Turistička zajednica, Ministarstvo unutarnjih poslova RH putem sustava eVisitor.

ROK ČUVANJA: Osobni podaci čuvaju se do odjave gosta iz smještajnog objekta, nakon čega se trajno i nepovratno brišu iz sustava. Iznimno, podaci potrebni za izvršenje zakonskih obveza mogu se čuvati sukladno zakonskim rokovima.

PRAVA ISPITANIKA: Imate pravo zatražiti pristup, ispravak, brisanje ili ograničenje obrade Vaših osobnih podataka, pravo na prenosivost podataka te pravo podnošenja prigovora nadzornom tijelu (AZOP).

Davanjem ovog pristanka potvrđujete da ste informirani o svim aspektima obrade Vaših osobnih podataka.
''';
    }
    return '''
INFORMED CONSENT FOR PERSONAL DATA PROCESSING
pursuant to Regulation (EU) 2016/679 (GDPR)

DATA CONTROLLER: The accommodation property owner registered with the competent tourist board.

LEGAL BASIS FOR PROCESSING: Article 6(1)(c) of GDPR – processing is necessary for compliance with a legal obligation to which the controller is subject, in accordance with:
• Act on Hospitality Industry
• Regulations on Tourist Registration
• Act on Foreigners

CATEGORIES OF PERSONAL DATA PROCESSED:
• Identification data: first name, surname, gender, date and place of birth
• Citizenship and nationality data
• Identity document data: type, number, and issuing country
• Permanent residence address

PURPOSE OF PROCESSING: Fulfillment of legal obligation to register and deregister guests in the eVisitor system and maintain tourist records.

DATA RECIPIENTS: Tourist Board, Ministry of Interior through the eVisitor system.

RETENTION PERIOD: Personal data shall be retained until guest check-out, after which it shall be permanently and irreversibly deleted from the system. Exceptionally, data required for legal compliance may be retained in accordance with statutory periods.

DATA SUBJECT RIGHTS: You have the right to request access, rectification, erasure, or restriction of processing of your personal data, the right to data portability, and the right to lodge a complaint with the supervisory authority.

By providing this consent, you confirm that you have been informed of all aspects of the processing of your personal data.
''';
  }

  String _getTruthFullText() {
    final lang = StorageService.getLanguage();
    if (lang == 'hr') {
      return '''
IZJAVA O VJERODOSTOJNOSTI PODATAKA I SUGLASNOST ZA SKENIRANJE DOKUMENATA

IZJAVLJUJEM POD KAZNENOM I MATERIJALNOM ODGOVORNOŠĆU:

1. VJERODOSTOJNOST IDENTITETA
Identifikacijska isprava koju predočujem (osobna iskaznica ili putovnica) jest moja vlastita, originalna i pravovaljana isprava izdana od nadležnog tijela.

2. TOČNOST PODATAKA
Svi podaci sadržani u mojoj identifikacijskoj ispravi te svi dodatni podaci koje usmeno ili pisano navodim su istiniti, točni, potpuni i ažurni. Nisam zatajio/la niti lažno prikazao/la bilo koju informaciju relevantnu za prijavu boravka.

3. SVRHA BORAVKA
Moj boravak u ovom smještajnom objektu je turistički/poslovni naravi te ću smještaj koristiti isključivo u zakonite svrhe, u skladu s kućnim redom i pozitivnim propisima Republike Hrvatske.

SUGLASNOST ZA POSTUPAK SKENIRANJA DOKUMENATA:

4. TEHNIČKI POSTUPAK
Suglasan/na sam da se moja identifikacijska isprava fotografira isključivo u svrhu automatskog očitavanja podataka putem OCR (Optical Character Recognition) tehnologije.

5. PRIVREMENA PRIRODA FOTOGRAFIJA
Izričito sam informiran/a i razumijem da:
• Fotografije dokumenata služe ISKLJUČIVO za jednokratno strojno očitavanje podataka
• Fotografije se NE pohranjuju, NE arhiviraju i NE prenose trećim stranama
• Fotografije se AUTOMATSKI I NEPOVRATNO BRIŠU odmah nakon završetka postupka check-in-a
• Na uređaju ne ostaje nikakav vizualni zapis mojih dokumenata

6. POHRANA I BRISANJE PODATAKA
Očitani tekstualni podaci (ime, prezime, datum rođenja, broj dokumenta i sl.) pohranjuju se isključivo za vrijeme trajanja mojeg boravka. Svi osobni podaci TRAJNO SE BRIŠU iz sustava prilikom check-out-a, odnosno odjave iz smještajnog objekta.

7. KAZNENA ODGOVORNOST
Svjestan/na sam da je davanje lažnih podataka kazneno djelo kažnjivo prema članku 311. Kaznenog zakona Republike Hrvatske (Lažno prijavljivanje).

8. PRIVOLA ZA PRIJENOS PODATAKA
Suglasan/na sam da se moji osobni podaci proslijede nadležnim tijelima (MUP RH, turistička zajednica) putem sustava eVisitor, sukladno pozitivnim propisima o prijavi turista.

Potpisom/prihvatom ove izjave potvrđujem da sam u cijelosti pročitao/la, razumio/la i prihvatio/la sve gore navedene uvjete.
''';
    }
    return '''
DECLARATION OF DATA AUTHENTICITY AND CONSENT FOR DOCUMENT SCANNING

I HEREBY DECLARE UNDER CRIMINAL AND CIVIL LIABILITY:

1. AUTHENTICITY OF IDENTITY
The identification document I present (ID card or passport) is my own, original, and valid document issued by the competent authority.

2. DATA ACCURACY
All data contained in my identification document and all additional information I provide verbally or in writing is true, accurate, complete, and up-to-date. I have not concealed or misrepresented any information relevant to the registration of my stay.

3. PURPOSE OF STAY
My stay at this accommodation property is for tourist/business purposes and I shall use the accommodation exclusively for lawful purposes, in accordance with house rules and applicable laws.

CONSENT FOR DOCUMENT SCANNING PROCEDURE:

4. TECHNICAL PROCEDURE
I consent to my identification document being photographed solely for the purpose of automatic data extraction using OCR (Optical Character Recognition) technology.

5. TEMPORARY NATURE OF PHOTOGRAPHS
I am expressly informed and understand that:
• Document photographs serve EXCLUSIVELY for one-time machine reading of data
• Photographs are NOT stored, NOT archived, and NOT transferred to third parties
• Photographs are AUTOMATICALLY AND IRREVERSIBLY DELETED immediately upon completion of the check-in procedure
• No visual record of my documents remains on the device

6. DATA STORAGE AND DELETION
Extracted textual data (name, surname, date of birth, document number, etc.) is stored exclusively for the duration of my stay. All personal data is PERMANENTLY DELETED from the system upon check-out, i.e., upon departure from the accommodation property.

7. CRIMINAL LIABILITY
I am aware that providing false information constitutes a criminal offense punishable under applicable criminal law.

8. CONSENT FOR DATA TRANSFER
I consent to my personal data being forwarded to competent authorities (Ministry of Interior, Tourist Board) through the eVisitor system, in accordance with applicable regulations on tourist registration.

By signing/accepting this declaration, I confirm that I have fully read, understood, and accepted all the above conditions.
''';
  }
}

// ═══════════════════════════════════════════════════════════
// POPUP DIALOG ZA DOKUMENT
// ═══════════════════════════════════════════════════════════
class _DocumentDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _DocumentDialog({
    required this.title,
    required this.content,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final lang = StorageService.getLanguage();
    final acceptText = lang == 'hr' ? "PRIHVAĆAM" : "I ACCEPT";
    final declineText = lang == 'hr' ? "ODBIJAM" : "DECLINE";

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(40),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 500),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF252525),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.description,
                    color: Color(0xFFD4AF37),
                    size: 26,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    content,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
            ),

            // Buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF252525),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  // Decline button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onDecline,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey,
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        declineText,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  // Accept button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: onAccept,
                      icon: const Icon(Icons.check, size: 20),
                      label: Text(
                        acceptText,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
