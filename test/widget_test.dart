import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nara/core/app_scope.dart';
import 'package:nara/core/format.dart';
import 'package:nara/core/motion.dart';
import 'package:nara/core/theme.dart';
import 'package:nara/core/widgets.dart';
import 'package:nara/features/history/history_page.dart';
import 'package:nara/data/mock/mock_backend.dart';
import 'package:nara/data/mock/mock_data.dart';
import 'package:nara/data/models.dart';
import 'package:nara/main.dart';

MockBackend fastBackend() => MockBackend(
  latency: Duration.zero,
  tick: const Duration(milliseconds: 5),
  simMinutesPerTick: 60,
);

void main() {
  test('rupiah format', () {
    expect(rupiah(0), 'Rp 0');
    expect(rupiah(2467), 'Rp 2.467');
    expect(rupiah(1234567), 'Rp 1.234.567');
    expect(rupiah(-50000), '-Rp 50.000');
  });

  test('distance & km format', () {
    final sudirman = mockStations.first;
    final d = sudirman.distanceKm(mockUserLocation.lat, mockUserLocation.lng);
    expect(d, closeTo(4.4, 0.2)); // Monas ke Sudirman ~4.4 km
    expect(km(0.35), '350 m');
    expect(km(4.36), '4.4 km');
  });

  test('QR validation', () async {
    final b = fastBackend();
    final p = await b.resolveQr('NARA-c1');
    expect(p.connector.id, 'c1');
    for (final code in ['NARA-c2', 'NARA-c4', 'NARA-c6', 'NARA-xx', 'abc']) {
      await expectLater(b.resolveQr(code), throwsA(isA<AppException>()));
    }
  });

  test('postpaid: start → charging → stop → pending → pay', () async {
    final b = fastBackend();
    final p = await b.resolveQr('NARA-c3'); // 22 kW
    await b.start(p, PaymentMode.postpaid);
    expect(b.active.value!.status, SessionStatus.charging);
    await expectLater(b.resolveQr('NARA-c3'), throwsA(isA<AppException>()));

    await Future<void>.delayed(const Duration(milliseconds: 30));
    await b.stop();
    final s = b.active.value!;
    expect(s.status, SessionStatus.paymentPending);
    expect(s.energyKwh, greaterThan(0));
    expect(s.cost, (s.energyKwh * 2467).round());
    expect(b.balance.value, 100000); // postpaid tidak potong saldo

    // tagihan tertunggak blokir postpaid berikutnya
    await expectLater(
      b.start(p, PaymentMode.postpaid),
      throwsA(isA<AppException>()),
    );
    await b.pay(s.id, 'QRIS');
    expect((await b.history()).single.status, SessionStatus.paid);
  });

  test('prepaid: auto-stop saat saldo habis, saldo terpotong', () async {
    final b = fastBackend();
    final p = await b.resolveQr(
      'NARA-c1',
    ); // 60 kW × 2467 ≈ 148rb/jam sim > saldo 100rb
    await b.start(p, PaymentMode.prepaid);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final s = b.active.value!;
    expect(s.status, SessionStatus.paid);
    expect(s.cost, 100000);
    expect(b.balance.value, 0);
    await expectLater(
      b.start(p, PaymentMode.prepaid),
      throwsA(isA<AppException>()),
    );
  });

  testWidgets('history: skeleton saat loading, lalu konten', (tester) async {
    final b = MockBackend(latency: const Duration(milliseconds: 500));
    await tester.pumpWidget(
      AppScope(
        auth: b,
        stations: b,
        charging: b,
        wallet: b,
        child: MaterialApp(
          theme: buildNaraTheme(Brightness.light),
          home: const HistoryPage(),
        ),
      ),
    );
    expect(find.byType(Shimmer), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 600)); // data datang
    await tester.pump(
      const Duration(milliseconds: 400),
    ); // transisi fade selesai
    expect(find.byType(Shimmer), findsNothing);
    expect(find.byType(EmptyState), findsOneWidget);
  });

  testWidgets('login → home', (tester) async {
    final b = fastBackend();
    await tester.pumpWidget(
      AppScope(
        auth: b,
        stations: b,
        charging: b,
        wallet: b,
        child: const NaraApp(),
      ),
    );
    expect(find.text('Power for the journey.'), findsOneWidget); // splash
    await tester.pumpAndSettle();
    expect(find.text('Sign in'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'budi@mail.com');
    await tester.enterText(find.byType(TextField).last, 'rahasia');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Nearby stations'), findsOneWidget);
    expect(
      find.text('NARA Sudirman'),
      findsOneWidget,
    ); // kartu SPKLU terdekat di atas peta
  });
}
