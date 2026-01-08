// FILE: lib/data/services/tablet_auth_service.dart
// OPIS: Upravlja Firebase autentifikacijom za tablet uređaje.
// VERZIJA: 1.1 - Popravljeni importi i exception handling

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'storage_service.dart';

/// Rezultat registracije tableta
class TabletRegistrationResult {
  final bool success;
  final String? errorMessage;
  final String? ownerId;
  final String? unitId;
  final String? unitName;

  TabletRegistrationResult({
    required this.success,
    this.errorMessage,
    this.ownerId,
    this.unitId,
    this.unitName,
  });
}

/// Podaci iz JWT tokena
class TabletClaims {
  final String? ownerId;
  final String? unitId;
  final String? role;
  final bool isValid;

  TabletClaims({
    this.ownerId,
    this.unitId,
    this.role,
    this.isValid = false,
  });

  bool get isTablet => role == 'tablet' && ownerId != null && unitId != null;
}

/// Glavni servis za tablet autentifikaciju
class TabletAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'europe-west3');

  // ═══════════════════════════════════════════════════════════════════
  // REGISTRACIJA TABLETA (Setup Screen poziva ovo)
  // ═══════════════════════════════════════════════════════════════════

  /// Registrira tablet za određeni unit.
  /// Poziva Cloud Function koja kreira auth user i vraća customToken.
  static Future<TabletRegistrationResult> registerTablet({
    required String tenantId,
    required String unitId,
  }) async {
    try {
      debugPrint("🔐 TabletAuthService: Starting registration...");
      debugPrint("   TenantID: $tenantId");
      debugPrint("   UnitID: $unitId");

      // 1. POZOVI CLOUD FUNCTION
      final callable = _functions.httpsCallable('registerTablet');

      final response = await callable.call<Map<String, dynamic>>({
        'tenantId': tenantId.trim().toUpperCase(),
        'unitId': unitId.trim(),
      });

      final data = response.data;

      if (data['success'] != true) {
        throw Exception(data['message']?.toString() ?? 'Registration failed');
      }

      debugPrint("✅ Cloud Function success!");
      debugPrint("   CustomToken received: ${data['customToken'] != null}");

      // 2. PRIJAVI SE S CUSTOM TOKENOM
      final customToken = data['customToken'] as String;

      debugPrint("🔑 Signing in with custom token...");

      final userCredential = await _auth.signInWithCustomToken(customToken);

      if (userCredential.user == null) {
        throw Exception('Failed to sign in with custom token');
      }

      debugPrint("✅ Signed in! UID: ${userCredential.user!.uid}");

      // 3. FORCE REFRESH TOKEN DA DOBIJEMO CLAIMS
      debugPrint("🔄 Refreshing token to get claims...");

      await userCredential.user!.getIdToken(true);

      // 4. SPREMI U LOKALNI STORAGE
      final ownerId = data['ownerId'] as String;
      final unitIdResult = data['unitId'] as String;
      final unitName = data['unitName'] as String? ?? 'Unknown';

      await StorageService.setOwnerId(ownerId);
      await StorageService.setUnitId(unitIdResult);

      debugPrint("💾 Auth state saved to storage");
      debugPrint("✅ REGISTRATION COMPLETE!");

      return TabletRegistrationResult(
        success: true,
        ownerId: ownerId,
        unitId: unitIdResult,
        unitName: unitName,
      );
    } on FirebaseFunctionsException catch (e) {
      debugPrint("❌ Cloud Function error: ${e.code} - ${e.message}");
      return TabletRegistrationResult(
        success: false,
        errorMessage: e.message ?? 'Cloud Function error: ${e.code}',
      );
    } on FirebaseAuthException catch (e) {
      debugPrint("❌ Auth error: ${e.code} - ${e.message}");
      return TabletRegistrationResult(
        success: false,
        errorMessage: e.message ?? 'Authentication error: ${e.code}',
      );
    } catch (e) {
      debugPrint("❌ Registration error: $e");
      return TabletRegistrationResult(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // AUTO-LOGIN PRI POKRETANJU
  // ═══════════════════════════════════════════════════════════════════

  /// Provjerava je li tablet već autenticiran.
  /// Poziva se u main.dart prije određivanja početne rute.
  static Future<bool> isAuthenticated() async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        debugPrint("🔐 No current user");
        return false;
      }

      // Provjeri claims
      final claims = await getClaims();

      if (!claims.isTablet) {
        debugPrint("⚠️ User exists but not a tablet role");
        return false;
      }

      debugPrint("✅ Tablet authenticated: ${claims.unitId}");
      return true;
    } catch (e) {
      debugPrint("❌ Auth check error: $e");
      return false;
    }
  }

  /// Pokušava obnoviti sesiju ako postoji.
  /// Vraća true ako je sesija validna.
  static Future<bool> tryRestoreSession() async {
    try {
      debugPrint("🔄 Trying to restore session...");

      final user = _auth.currentUser;

      if (user == null) {
        debugPrint("   No saved session");
        return false;
      }

      // Force refresh token
      debugPrint("   Refreshing token...");
      await user.getIdToken(true);

      // Provjeri claims
      final claims = await getClaims();

      if (!claims.isTablet) {
        debugPrint("   Invalid claims, signing out");
        await signOut();
        return false;
      }

      // Ažuriraj storage ako treba
      if (claims.ownerId != null && claims.unitId != null) {
        await StorageService.setOwnerId(claims.ownerId!);
        await StorageService.setUnitId(claims.unitId!);
      }

      debugPrint("✅ Session restored: ${claims.unitId}");
      return true;
    } catch (e) {
      debugPrint("❌ Session restore error: $e");
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // JWT CLAIMS
  // ═══════════════════════════════════════════════════════════════════

  /// Dohvaća custom claims iz JWT tokena.
  static Future<TabletClaims> getClaims() async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        return TabletClaims(isValid: false);
      }

      // Dohvati token result s claimsima
      final tokenResult = await user.getIdTokenResult();
      final claims = tokenResult.claims;

      if (claims == null) {
        return TabletClaims(isValid: false);
      }

      return TabletClaims(
        ownerId: claims['ownerId'] as String?,
        unitId: claims['unitId'] as String?,
        role: claims['role'] as String?,
        isValid: true,
      );
    } catch (e) {
      debugPrint("❌ Error getting claims: $e");
      return TabletClaims(isValid: false);
    }
  }

  /// Dohvaća ownerId iz claims-a (ili iz storage-a kao fallback).
  static Future<String?> getOwnerId() async {
    final claims = await getClaims();
    return claims.ownerId ?? StorageService.getOwnerId();
  }

  /// Dohvaća unitId iz claims-a (ili iz storage-a kao fallback).
  static Future<String?> getUnitId() async {
    final claims = await getClaims();
    return claims.unitId ?? StorageService.getUnitId();
  }

  // ═══════════════════════════════════════════════════════════════════
  // TOKEN REFRESH
  // ═══════════════════════════════════════════════════════════════════

  /// Forsirano osvježava JWT token.
  /// Pozovi ovo prije važnih operacija da osiguraš svježi token.
  static Future<String?> refreshToken() async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        debugPrint("⚠️ Cannot refresh - no user");
        return null;
      }

      debugPrint("🔄 Refreshing token...");
      final token = await user.getIdToken(true); // true = force refresh
      debugPrint("✅ Token refreshed");

      return token;
    } catch (e) {
      debugPrint("❌ Token refresh error: $e");
      return null;
    }
  }

  /// Automatski refresh svakih 50 minuta (token traje 60 min).
  /// Pozovi ovo jednom pri pokretanju app-a.
  static void startAutoRefresh() {
    debugPrint("⏰ Starting auto token refresh (every 50 min)");

    Future.doWhile(() async {
      await Future.delayed(const Duration(minutes: 50));

      if (_auth.currentUser != null) {
        await refreshToken();
        return true; // Nastavi loop
      }

      return false; // Zaustavi ako nema usera
    });
  }

  // ═══════════════════════════════════════════════════════════════════
  // SIGN OUT & RESET
  // ═══════════════════════════════════════════════════════════════════

  /// Odjavljuje tablet (koristi se pri Factory Reset).
  static Future<void> signOut() async {
    try {
      debugPrint("🚪 Signing out...");

      await _auth.signOut();

      debugPrint("✅ Signed out");
    } catch (e) {
      debugPrint("❌ Sign out error: $e");
    }
  }

  /// Kompletni reset - briše sve auth podatke.
  /// Koristi se pri Master Reset PIN-u.
  static Future<void> fullReset() async {
    try {
      debugPrint("🔴 FULL RESET starting...");

      // 1. Sign out
      await signOut();

      // 2. Očisti storage
      await StorageService.factoryReset();

      debugPrint("✅ FULL RESET complete");
    } catch (e) {
      debugPrint("❌ Full reset error: $e");
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // HEARTBEAT (Opcijski - za tracking aktivnosti)
  // ═══════════════════════════════════════════════════════════════════

  /// Šalje heartbeat Cloud Function-u da označi da je tablet aktivan.
  static Future<void> sendHeartbeat() async {
    try {
      final callable = _functions.httpsCallable('tabletHeartbeat');
      await callable.call();
      debugPrint("💓 Heartbeat sent");
    } catch (e) {
      // Tiho ignoriraj greške - heartbeat nije kritičan
      debugPrint("⚠️ Heartbeat failed (non-critical): $e");
    }
  }

  /// Pokreće periodički heartbeat (svakih 5 minuta).
  static void startHeartbeat() {
    debugPrint("💓 Starting heartbeat (every 5 min)");

    Future.doWhile(() async {
      await Future.delayed(const Duration(minutes: 5));

      if (_auth.currentUser != null) {
        await sendHeartbeat();
        return true;
      }

      return false;
    });
  }

  // ═══════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════

  /// Listener za auth state promjene.
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Trenutni user (ili null).
  static User? get currentUser => _auth.currentUser;

  /// Je li trenutno ulogiran?
  static bool get isLoggedIn => _auth.currentUser != null;
}
