import 'package:flutter/foundation.dart';

import 'models.dart';

/// Kontrak data untuk UI. Implementasi sekarang: `MockBackend`.
/// Implementasi API asli (REST + WebSocket) menyusul saat kontrak backend siap (TBD-04).
/// Semua method melempar [AppException] dengan pesan siap tampil.

abstract interface class AuthRepository {
  ValueListenable<User?> get user;

  /// Dipanggil saat splash: pulihkan sesi dari token tersimpan.
  Future<void> restoreSession();
  Future<void> login(String email, String password);
  Future<void> register(String name, String email, String password);
  Future<void> loginWithGoogle();
  Future<void> loginWithApple();
  Future<void> forgotPassword(String email);
  Future<void> logout();
}

abstract interface class StationRepository {
  Future<List<Station>> stations();
  Future<ChargePoint> resolveQr(String code);
}

abstract interface class ChargingRepository {
  /// Sesi terakhir (berjalan atau baru selesai). Asli: di-update via WebSocket.
  ValueListenable<ChargingSession?> get active;
  Future<void> start(ChargePoint point, PaymentMode mode);
  Future<void> stop();
  Future<List<ChargingSession>> history();
  Future<void> pay(String sessionId, String method);
}

abstract interface class WalletRepository {
  ValueListenable<int> get balance;
  int get minPrepaidBalance;
  Future<void> topUp(int amount, String method);
  Future<List<WalletMutation>> mutations();
}
