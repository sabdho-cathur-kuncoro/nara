import 'package:material_ui/material_ui.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';
import '../scan/scan_page.dart';
import 'station_card.dart';

class StationDetailPage extends StatelessWidget {
  const StationDetailPage({super.key, required this.station});

  final Station station;

  @override
  Widget build(BuildContext context) {
    final s = station;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(s.name, style: text.headlineSmall),
          const SizedBox(height: 4),
          Text(
            '${s.address} · ${km(distanceFromUser(s))}',
            style: text.bodyMedium!.copyWith(color: context.nara.textSecondary),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _Stat(
                icon: Icons.bolt_rounded,
                label: 'Available',
                value: '${s.availableCount} of ${s.connectors.length}',
              ),
              const SizedBox(width: 12),
              _Stat(
                icon: Icons.payments_outlined,
                label: 'Rate',
                value: '${rupiah(s.tariffPerKwh)}/kWh',
              ),
            ],
          ),
          const SectionTitle('Chargers'),
          for (final ch in s.chargers)
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Text(ch.name, style: text.titleSmall),
                    ),
                    for (final c in ch.connectors)
                      ListTile(
                        leading: const Icon(Icons.power_outlined),
                        title: Text(c.type),
                        subtitle: Text(
                          '${c.powerKw} kW · ${c.powerKw >= 50 ? 'DC fast' : 'AC'}',
                        ),
                        trailing: StatusChip(
                          label: c.status.label,
                          color: context.nara.connector(c.status),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomAction(
        child: FilledButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => const ScanPage()),
          ),
          icon: const Icon(Icons.qr_code_scanner),
          label: const Text('Scan QR to start'),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Expanded(
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: context.nara.primary),
              const SizedBox(height: 8),
              Text(label, style: text.bodySmall),
              Text(
                value,
                style: text.titleSmall!.copyWith(fontFeatures: tabularFigures),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
