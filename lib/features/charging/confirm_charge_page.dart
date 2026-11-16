import 'package:material_ui/material_ui.dart';

import '../../core/app_scope.dart';
import '../../core/format.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';
import '../payment/wallet_page.dart';
import 'charging_page.dart';

class ConfirmChargePage extends StatefulWidget {
  const ConfirmChargePage({super.key, required this.point});

  final ChargePoint point;

  @override
  State<ConfirmChargePage> createState() => _ConfirmChargePageState();
}

class _ConfirmChargePageState extends State<ConfirmChargePage> {
  // Cara pilih mode masih PRD TBD-22; sementara user pilih per sesi.
  var _mode = PaymentMode.prepaid;

  Future<void> _start() async {
    final charging = AppScope.of(context).charging;
    final ok = await guard(context, () async {
      await charging.start(widget.point, _mode);
      return true;
    });
    if (ok == true && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(builder: (_) => const ChargingPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.point;
    final wallet = AppScope.of(context).wallet;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text('Ready when you are.', style: text.headlineSmall),
          const SizedBox(height: 4),
          Text(
            'Plug in your car, then tap Start charging.',
            style: text.bodyMedium,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  InfoRow(label: 'Station', value: p.station.name),
                  InfoRow(label: 'Charger', value: p.charger.name),
                  InfoRow(
                    label: 'Connector',
                    value: '${p.connector.type} · ${p.connector.powerKw} kW',
                  ),
                  InfoRow(
                    label: 'Rate',
                    value: '${rupiah(p.station.tariffPerKwh)}/kWh',
                  ),
                ],
              ),
            ),
          ),
          const SectionTitle('How do you want to pay?'),
          ValueListenableBuilder<int>(
            valueListenable: wallet.balance,
            builder: (context, balance, _) => SelectableCard(
              selected: _mode == PaymentMode.prepaid,
              icon: Icons.account_balance_wallet_outlined,
              title: 'Balance · ${rupiah(balance)}',
              subtitle:
                  'Deducted when you finish. Min. ${rupiah(wallet.minPrepaidBalance)}.',
              onTap: () => setState(() => _mode = PaymentMode.prepaid),
            ),
          ),
          SelectableCard(
            selected: _mode == PaymentMode.postpaid,
            icon: Icons.receipt_long_outlined,
            title: 'Pay after charging',
            subtitle: 'QRIS, virtual account, or e-wallet.',
            onTap: () => setState(() => _mode = PaymentMode.postpaid),
          ),
          if (_mode == PaymentMode.prepaid)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (_) => const WalletPage()),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Top up balance'),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomAction(
        child: FilledButton.icon(
          onPressed: _start,
          icon: const Icon(Icons.bolt_rounded),
          label: const Text('Start charging'),
        ),
      ),
    );
  }
}
