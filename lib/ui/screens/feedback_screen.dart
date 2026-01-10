// FILE: lib/ui/screens/feedback_screen.dart
// OPIS: Ekran za ocjenjivanje prije odjave.
// LOGIKA: 5 zvjezdica = QR za Google Review, <5 = interno web panelu
// VERZIJA: 3.0 - FAZA 2: OfflineBanner + Offline queue
// DATUM: 2026-01-10

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:animate_do/animate_do.dart';

import '../../data/services/storage_service.dart';
import '../../data/services/firestore_service.dart';
import '../../data/services/connectivity_service.dart';
import '../../data/services/offline_queue_service.dart';
import '../../utils/translations.dart';
import '../widgets/offline_indicator.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;
  bool _isSubmitted = false;

  // Dohvaćamo iz Web Panela
  String _googleReviewUrl = "";
  String _guestName = "";
  String _villaName = "";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _googleReviewUrl = StorageService.getGoogleReviewUrl();
      _guestName = StorageService.getGuestName();
      _villaName = StorageService.getVillaName();
    });
  }

  void _finishCheckOut() {
    // Idemo na Cleaner Login (čistačica resetira za novog gosta)
    Navigator.pushNamedAndRemoveUntil(context, '/cleaner_login', (r) => false);
  }

  Future<void> _submitFeedback() async {
    if (_rating == 0) return;

    // 5 zvjezdica -> Prikaži QR za Google Review
    if (_rating == 5) {
      // Ipak spremi pozitivnu recenziju u bazu
      await _saveFeedbackToFirebase();
      setState(() => _isSubmitted = true);
      return;
    }

    // 1-4 zvjezdice -> Šalji u bazu (privatno za vlasnika)
    setState(() => _isSubmitting = true);

    try {
      await _saveFeedbackToFirebase();

      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _isSubmitted = true;
        });
      }
    } catch (e) {
      debugPrint("Error saving feedback: $e");
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${Translations.t('error')}: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveFeedbackToFirebase() async {
    // ⭐ FAZA 2: Provjeri internet konekciju
    final isOnline = ConnectivityService.isOnline;

    if (isOnline) {
      // Online - spremi direktno
      await FirestoreService.saveFeedback(
        rating: _rating,
        comment: _commentController.text.trim(),
      );
    } else {
      // Offline - stavi u queue
      await OfflineQueueService.queueSaveFeedback(
        rating: _rating,
        comment: _commentController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.cloud_queue, color: Colors.white),
                SizedBox(width: 10),
                Text("Feedback saved. Will sync when online."),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Column(
        children: [
          // ⭐ FAZA 2: OFFLINE BANNER
          const OfflineBanner(),

          // GLAVNI SADRŽAJ
          Expanded(
            child: Center(
              child: _isSubmitted ? _buildThankYouView() : _buildRatingForm(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingForm() {
    return SingleChildScrollView(
      child: FadeInUp(
        child: Container(
          width: 550,
          padding: const EdgeInsets.all(45),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              const Icon(
                Icons.rate_review,
                color: Color(0xFFD4AF37),
                size: 50,
              ),
              const SizedBox(height: 20),
              Text(
                Translations.t('feedback_title'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                Translations.t('feedback_subtitle'),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[400], fontSize: 15),
              ),

              // Personalizirani pozdrav
              if (_guestName.isNotEmpty) ...[
                const SizedBox(height: 15),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${Translations.t('thank_you')}, $_guestName! 👋",
                    style: const TextStyle(
                      color: Color(0xFFD4AF37),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 35),

              // ZVJEZDICE
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final isSelected = index < _rating;
                  return GestureDetector(
                    onTap: () => setState(() => _rating = index + 1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        isSelected
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 50,
                        color: isSelected ? Colors.amber : Colors.grey[600],
                      ),
                    ),
                  );
                }),
              ),

              // Rating label
              if (_rating > 0) ...[
                const SizedBox(height: 15),
                FadeIn(
                  child: Text(
                    _getRatingLabel(_rating),
                    style: TextStyle(
                      color: _rating >= 4 ? Colors.green : Colors.orange,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 30),

              // KOMENTAR (Za 1-4 zvjezdice)
              if (_rating > 0 && _rating < 5) ...[
                FadeInDown(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Translations.t('feedback_comment_label'),
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _commentController,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: Translations.t('feedback_comment_hint'),
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          filled: true,
                          fillColor: Colors.black.withValues(alpha: 0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Color(0xFFD4AF37)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
              ],

              // GUMB ZA SLANJE
              if (_rating > 0)
                FadeInUp(
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitFeedback,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _rating == 5
                            ? Colors.green
                            : const Color(0xFFD4AF37),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _rating == 5 ? Icons.favorite : Icons.send,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  Translations.t('submit_feedback'),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),

              const SizedBox(height: 25),

              // SKIP gumb
              TextButton(
                onPressed: _finishCheckOut,
                child: Text(
                  Translations.t('skip_feedback'),
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThankYouView() {
    final bool isPerfect = _rating == 5;
    final bool hasReviewUrl = _googleReviewUrl.isNotEmpty;

    return FadeInUp(
      child: Container(
        width: 550,
        padding: const EdgeInsets.all(45),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isPerfect ? const Color(0xFFD4AF37) : Colors.green,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isPerfect ? const Color(0xFFD4AF37) : Colors.green)
                  .withValues(alpha: 0.2),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animirana ikona
            FadeInDown(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color:
                      (isPerfect ? Colors.red : Colors.green).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPerfect ? Icons.favorite : Icons.check_circle,
                  size: 50,
                  color: isPerfect ? Colors.red : Colors.green,
                ),
              ),
            ),
            const SizedBox(height: 25),

            Text(
              isPerfect
                  ? Translations.t('thank_you_perfect')
                  : Translations.t('thank_you_feedback'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isPerfect
                  ? Translations.t('perfect_stay_message')
                  : Translations.t('feedback_received_message'),
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: Colors.grey[400], fontSize: 15, height: 1.5),
            ),

            // QR KOD ZA GOOGLE REVIEW (samo za 5 zvjezdica i ako ima URL)
            if (isPerfect && hasReviewUrl) ...[
              const SizedBox(height: 35),
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: _googleReviewUrl,
                        version: QrVersions.auto,
                        size: 160.0,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 5),
                        Text(
                          Translations.t('scan_for_review'),
                          style: const TextStyle(
                            color: Color(0xFFD4AF37),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            // Ako nema Review URL, prikaži poruku
            if (isPerfect && !hasReviewUrl) ...[
              const SizedBox(height: 25),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.thumb_up, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        Translations.t('glad_you_enjoyed'),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 40),

            // Villa name
            if (_villaName.isNotEmpty)
              Text(
                _villaName,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),

            const SizedBox(height: 20),

            // GUMB ZA ZAVRŠETAK
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _finishCheckOut,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.logout, size: 20),
                label: Text(
                  Translations.t('complete_checkout'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 1:
        return Translations.t('rating_1');
      case 2:
        return Translations.t('rating_2');
      case 3:
        return Translations.t('rating_3');
      case 4:
        return Translations.t('rating_4');
      case 5:
        return Translations.t('rating_5');
      default:
        return '';
    }
  }
}
