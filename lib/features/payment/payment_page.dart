import 'package:material_ui/material_ui.dart';

import '../../core/app_scope.dart';
import '../../core/format.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';

/// Metode dummy; daftar asli tergantung payment gateway (PRD TBD-23).
const paymentMethods = {
  'QRIS': Icons.qr_code_2,
  'Virtual Account': Icons.account_balance_outlined,
  'E-Wallet': Icons.account_balance_wallet_outlined,
};

/// Pilih metode bayar. Dipakai untuk postpaid & top-up.
class MethodPicker extends StatelessWidget {
  const MethodPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final m in paymentMethods.entries)
          SelectableCard(
            selected: m.key == selected,
            icon: m.value,
            title: m.key,
            onTap: () => onChanged(m.key),
          ),
      ],
    );
  }
}

/// Pembayaran postpaid setelah sesi selesai.
class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key, required this.session});

  final ChargingSession session;

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  var _method = paymentMethods.keys.first;

  Future<void> _pay() async {
    final charging = AppScope.of(context).charging;
    final ok = await guard(context, () async {
      await charging.pay(widget.session.id, _method);
      return true;
    });
    if (ok == true && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Payment complete.')));
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.session;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text('Amount due', style: text.bodySmall),
                  const SizedBox(height: 4),
                  Text(
                    rupiah(s.cost),
                    style: text.displaySmall!.copyWith(
                      fontFeatures: tabularFigures,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${s.point.station.name} · ${kwh(s.energyKwh)} · ${durationText(s.elapsed)}',
                    textAlign: TextAlign.center,
                    style: text.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SectionTitle('Payment method'),
          MethodPicker(
            selected: _method,
            onChanged: (m) => setState(() => _method = m),
          ),
        ],
      ),
      bottomNavigationBar: BottomAction(
        child: FilledButton(
          onPressed: _pay,
          child: Text('Pay ${rupiah(s.cost)}'),
        ),
      ),
    );
  }
}
