import 'package:material_ui/material_ui.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';
import '../payment/payment_page.dart';
import 'history_page.dart';

class TransactionDetailPage extends StatelessWidget {
  const TransactionDetailPage({super.key, required this.session});

  final ChargingSession session;

  @override
  Widget build(BuildContext context) {
    final s = session;
    final text = Theme.of(context).textTheme;
    final pending = s.status == SessionStatus.paymentPending;
    return Scaffold(
      appBar: AppBar(title: const Text('Charging session')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  StatusChip(
                    label: s.status.label,
                    color: sessionStatusColor(context, s.status),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    rupiah(s.cost),
                    style: text.displaySmall!.copyWith(
                      fontFeatures: tabularFigures,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${kwh(s.energyKwh)} · ${durationText(s.elapsed)}',
                    style: text.bodyMedium!.copyWith(
                      fontFeatures: tabularFigures,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SectionTitle('Details'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  InfoRow(label: 'Station', value: s.point.station.name),
                  InfoRow(label: 'Charger', value: s.point.charger.name),
                  InfoRow(
                    label: 'Connector',
                    value:
                        '${s.point.connector.type} · ${s.point.connector.powerKw} kW',
                  ),
                  InfoRow(label: 'Started', value: dateTimeText(s.startedAt)),
                  InfoRow(
                    label: 'Rate',
                    value: '${rupiah(s.point.station.tariffPerKwh)}/kWh',
                  ),
                  InfoRow(
                    label: 'Payment',
                    value: s.paymentMethod ?? s.mode.label,
                  ),
                  InfoRow(label: 'Transaction ID', value: s.id),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: pending
          ? BottomAction(
              child: FilledButton(
                onPressed: () async {
                  final paid = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(builder: (_) => PaymentPage(session: s)),
                  );
                  if (paid == true && context.mounted) Navigator.pop(context);
                },
                child: Text('Pay ${rupiah(s.cost)}'),
              ),
            )
          : null,
    );
  }
}
