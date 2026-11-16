import 'package:material_ui/material_ui.dart';

import '../core/app_scope.dart';
import '../core/format.dart';
import '../core/motion.dart';
import '../core/theme.dart';
import '../data/models.dart';
import 'account/account_page.dart';
import 'charging/charging_page.dart';
import 'history/history_page.dart';
import 'scan/scan_page.dart';
import 'stations/stations_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  var _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Tab dibangun ulang tiap dipilih agar data (mis. riwayat) selalu segar.
      body: FadeSwitcher(
        child: KeyedSubtree(
          key: ValueKey(_tab),
          child: switch (_tab) {
            0 => const StationsPage(),
            1 => const ScanPage(),
            2 => const HistoryPage(),
            _ => const AccountPage(),
          },
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _ActiveSessionBanner(),
          NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: (i) => setState(() => _tab = i),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.map_outlined),
                label: 'Stations',
              ),
              NavigationDestination(
                icon: Icon(Icons.qr_code_scanner),
                label: 'Scan',
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                label: 'History',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                label: 'Account',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActiveSessionBanner extends StatelessWidget {
  const _ActiveSessionBanner();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ChargingSession?>(
      valueListenable: AppScope.of(context).charging.active,
      builder: (context, s, _) => AnimatedSize(
        duration: Motion.reduced(context) ? Duration.zero : Motion.medium,
        curve: Motion.curve,
        child: s == null || !s.status.isRunning
            ? const SizedBox(width: double.infinity)
            : _banner(context, s),
      ),
    );
  }

  Widget _banner(BuildContext context, ChargingSession s) {
    return Material(
      color: context.nara.primaryDark,
      child: ListTile(
        textColor: Colors.white,
        iconColor: Colors.white,
        leading: Icon(Icons.bolt_rounded, color: context.nara.accent),
        title: Text('${s.status.label} · ${s.point.station.name}'),
        subtitle: AnimatedNumber(
          value: s.energyKwh,
          format: (v) =>
              '${kwh(v)} · ${rupiah((v * s.point.station.tariffPerKwh).round())}',
          style: const TextStyle(fontFeatures: tabularFigures),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => const ChargingPage()),
        ),
      ),
    );
  }
}
