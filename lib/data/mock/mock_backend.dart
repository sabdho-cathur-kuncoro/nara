import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models.dart';
import '../repositories.dart';
import 'mock_data.dart';

/// Backend dummy in-memory: simulasi auth, SPKLU, sesi charging (pengganti WebSocket), wallet.
class MockBackend
    implements
        AuthRepository,
        StationRepository,
        ChargingRepository,
        WalletRepository {
  MockBackend({
    this.latency = const Duration(milliseconds: 600),
    this.tick = const Duration(seconds: 1),
    this.simMinutesPerTick = 1,
  });

  final Duration latency;
  final Duration tick;

  /// Percepat simulasi: 1 tick = N menit charging.
  final int simMinutesPerTick;

  final _user = ValueNotifier<User?>(null);
  final _active = ValueNotifier<ChargingSession?>(null);
  final _balance = ValueNotifier<int>(100000);
  final _mutations = <WalletMutation>[];
  final _history = <ChargingSession>[];
  final _occupied = <String>{};
  Timer? _timer;

  Future<void> _wait() => Future.delayed(latency);

  // ---------- Auth ----------

  @override
  ValueListenable<User?> get user => _user;

  void _validate(String email, String password) {
    if (!email.contains('@')) {
      throw const AppException('Please enter a valid email.');
    }
    if (password.length < 6) {
      throw const AppException('Password must be at least 6 characters.');
    }
  }

  @override
  Future<void> restoreSession() => _wait(); // mock: tidak ada token tersimpan

  @override
  Future<void> login(String email, String password) async {
    await _wait();
    _validate(email, password);
    _user.value = User(name: email.split('@').first, email: email);
  }

  @override
  Future<void> register(String name, String email, String password) async {
    await _wait();
    if (name.trim().isEmpty) {
      throw const AppException('Please enter your name.');
    }
    _validate(email, password);
    _user.value = User(name: name.trim(), email: email);
  }

  @override
  Future<void> loginWithGoogle() async {
    await _wait();
    _user.value = const User(
      name: 'Google User',
      email: 'google.user@example.com',
    );
  }

  @override
  Future<void> loginWithApple() async {
    await _wait();
    _user.value = const User(
      name: 'Apple User',
      email: 'apple.user@example.com',
    );
  }

  @override
  Future<void> forgotPassword(String email) async {
    await _wait();
    if (!email.contains('@')) {
      throw const AppException('Please enter a valid email.');
    }
  }

  @override
  Future<void> logout() async {
    _user.value = null;
  }

  // ---------- SPKLU ----------

  @override
  Future<List<Station>> stations() async {
    await _wait();
    return mockStations;
  }

  @override
  Future<ChargePoint> resolveQr(String code) async {
    await _wait();
    final id = code.trim();
    if (!id.startsWith('NARA-')) {
      throw const AppException("We don't recognize this QR code.");
    }
    for (final s in mockStations) {
      for (final ch in s.chargers) {
        for (final c in ch.connectors) {
          if ('NARA-${c.id}' != id) continue;
          switch (c.status) {
            case ConnectorStatus.offline:
              throw const AppException('This charger is offline right now.');
            case ConnectorStatus.faulted:
              throw const AppException('This charger is out of service.');
            case ConnectorStatus.charging:
              throw const AppException('This connector is in use.');
            case ConnectorStatus.available:
              if (_occupied.contains(c.id)) {
                throw const AppException('This connector is in use.');
              }
              return (station: s, charger: ch, connector: c);
          }
        }
      }
    }
    throw const AppException("We couldn't find this charger.");
  }

  // ---------- Charging ----------

  @override
  ValueListenable<ChargingSession?> get active => _active;

  @override
  Future<void> start(ChargePoint point, PaymentMode mode) async {
    if (_active.value?.status.isRunning ?? false) {
      throw const AppException('You already have an active charging session.');
    }
    if (mode == PaymentMode.prepaid && _balance.value < minPrepaidBalance) {
      throw const AppException('Top up to start charging.');
    }
    if (mode == PaymentMode.postpaid &&
        _history.any((s) => s.status == SessionStatus.paymentPending)) {
      throw const AppException('Please pay for your last session first.');
    }
    _occupied.add(point.connector.id);
    _active.value = ChargingSession(
      id: 'TRX${DateTime.now().millisecondsSinceEpoch}',
      point: point,
      mode: mode,
      status: SessionStatus.starting,
      startedAt: DateTime.now(),
    );
    await _wait(); // simulasi RemoteStartTransaction → charger accepted
    _active.value = _active.value!.copyWith(status: SessionStatus.charging);
    _timer = Timer.periodic(tick, (_) => _onMeterValues());
  }

  void _onMeterValues() {
    final s = _active.value!;
    final energy =
        s.energyKwh + s.point.connector.powerKw * simMinutesPerTick / 60;
    var cost = (energy * s.point.station.tariffPerKwh).round();
    final outOfBalance =
        s.mode == PaymentMode.prepaid && cost >= _balance.value;
    if (outOfBalance) cost = _balance.value;
    _active.value = s.copyWith(
      elapsed: s.elapsed + Duration(minutes: simMinutesPerTick),
      energyKwh: energy,
      cost: cost,
    );
    // Asumsi TBD-38: saldo prepaid habis → backend stop otomatis.
    if (outOfBalance) stop();
  }

  @override
  Future<void> stop() async {
    final s = _active.value;
    if (s == null || s.status != SessionStatus.charging) return;
    _timer?.cancel();
    _active.value = s.copyWith(status: SessionStatus.stopping);
    await _wait(); // simulasi RemoteStopTransaction → StopTransaction (meter akhir)
    _occupied.remove(s.point.connector.id);

    var done = _active.value!;
    if (done.mode == PaymentMode.prepaid) {
      _balance.value -= done.cost;
      _mutations.insert(
        0,
        WalletMutation(
          amount: -done.cost,
          note: 'Charging ${done.point.station.name}',
          at: DateTime.now(),
        ),
      );
      done = done.copyWith(
        status: SessionStatus.paid,
        paymentMethod: 'Balance',
      );
    } else {
      done = done.copyWith(status: SessionStatus.paymentPending);
    }
    _history.insert(0, done);
    _active.value = done;
  }

  @override
  Future<List<ChargingSession>> history() async {
    await _wait();
    return List.of(_history);
  }

  @override
  Future<void> pay(String sessionId, String method) async {
    await _wait();
    final i = _history.indexWhere((s) => s.id == sessionId);
    if (i < 0) throw const AppException('Transaction not found.');
    final paid = _history[i].copyWith(
      status: SessionStatus.paid,
      paymentMethod: method,
    );
    _history[i] = paid;
    if (_active.value?.id == sessionId) _active.value = paid;
  }

  // ---------- Wallet ----------

  @override
  ValueListenable<int> get balance => _balance;

  @override
  int get minPrepaidBalance => 20000; // asumsi, TBD-17

  @override
  Future<void> topUp(int amount, String method) async {
    await _wait();
    if (amount < 10000) {
      throw const AppException('Minimum top-up is Rp 10.000.');
    }
    _balance.value += amount;
    _mutations.insert(
      0,
      WalletMutation(
        amount: amount,
        note: 'Top-up via $method',
        at: DateTime.now(),
      ),
    );
  }

  @override
  Future<List<WalletMutation>> mutations() async {
    await _wait();
    return List.of(_mutations);
  }
}
