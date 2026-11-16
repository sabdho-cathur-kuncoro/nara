import 'dart:math' as math;

class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;
}

class User {
  const User({required this.name, required this.email});
  final String name;
  final String email;
}

enum ConnectorStatus {
  available('Available'),
  charging('In use'),
  faulted('Faulted'),
  offline('Offline');

  const ConnectorStatus(this.label);
  final String label;
}

class Connector {
  const Connector({
    required this.id,
    required this.type,
    required this.powerKw,
    required this.status,
  });
  final String id;
  final String type;
  final double powerKw;
  final ConnectorStatus status;
}

class Charger {
  const Charger({
    required this.id,
    required this.name,
    required this.connectors,
  });
  final String id;
  final String name;
  final List<Connector> connectors;
}

class Station {
  const Station({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.tariffPerKwh,
    required this.chargers,
  });
  final String id;
  final String name;
  final String address;
  final double lat;
  final double lng;

  /// Rupiah per kWh.
  final int tariffPerKwh;
  final List<Charger> chargers;

  Iterable<Connector> get connectors => chargers.expand((c) => c.connectors);
  int get availableCount =>
      connectors.where((c) => c.status == ConnectorStatus.available).length;

  /// Jenis connector unik, mis. "CCS2 · Type 2".
  String get connectorTypes =>
      connectors.map((c) => c.type).toSet().join(' · ');

  /// Jarak garis lurus (haversine) dalam km.
  double distanceKm(double fromLat, double fromLng) {
    double rad(double d) => d * math.pi / 180;
    final dLat = rad(lat - fromLat);
    final dLng = rad(lng - fromLng);
    final a =
        math.pow(math.sin(dLat / 2), 2) +
        math.cos(rad(fromLat)) *
            math.cos(rad(lat)) *
            math.pow(math.sin(dLng / 2), 2);
    return 6371 * 2 * math.asin(math.sqrt(a));
  }
}

/// Hasil scan QR: satu connector beserta charger & lokasinya.
typedef ChargePoint = ({Station station, Charger charger, Connector connector});

enum PaymentMode {
  prepaid('Prepaid'),
  postpaid('Postpaid');

  const PaymentMode(this.label);
  final String label;
}

enum SessionStatus {
  starting('Starting…'),
  charging('Charging'),
  stopping('Stopping…'),
  paymentPending('Payment due'),
  paid('Paid');

  const SessionStatus(this.label);
  final String label;

  bool get isRunning =>
      this == starting || this == charging || this == stopping;
}

class ChargingSession {
  const ChargingSession({
    required this.id,
    required this.point,
    required this.mode,
    required this.status,
    required this.startedAt,
    this.elapsed = Duration.zero,
    this.energyKwh = 0,
    this.cost = 0,
    this.paymentMethod,
  });
  final String id;
  final ChargePoint point;
  final PaymentMode mode;
  final SessionStatus status;
  final DateTime startedAt;
  final Duration elapsed;
  final double energyKwh;

  /// Rupiah.
  final int cost;
  final String? paymentMethod;

  ChargingSession copyWith({
    SessionStatus? status,
    Duration? elapsed,
    double? energyKwh,
    int? cost,
    String? paymentMethod,
  }) => ChargingSession(
    id: id,
    point: point,
    mode: mode,
    status: status ?? this.status,
    startedAt: startedAt,
    elapsed: elapsed ?? this.elapsed,
    energyKwh: energyKwh ?? this.energyKwh,
    cost: cost ?? this.cost,
    paymentMethod: paymentMethod ?? this.paymentMethod,
  );
}

class WalletMutation {
  const WalletMutation({
    required this.amount,
    required this.note,
    required this.at,
  });

  /// Rupiah; positif = top-up, negatif = pemakaian.
  final int amount;
  final String note;
  final DateTime at;
}
