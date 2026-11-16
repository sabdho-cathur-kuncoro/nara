import 'package:material_ui/material_ui.dart';

import '../../core/app_scope.dart';
import '../../core/format.dart';
import '../../core/motion.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';
import 'payment_page.dart';

const _topUpAmounts = [50000, 100000, 200000, 500000];

/// Saldo prepaid, top-up, dan aktivitas.
class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  late Future<List<WalletMutation>> _mutations = AppScope.of(context).wallet
      .mutations();
  var _amount = _topUpAmounts[1];
  var _method = paymentMethods.keys.first;

  Future<void> _topUp() async {
    final wallet = AppScope.of(context).wallet;
    final ok = await guard(context, () async {
      await wallet.topUp(_amount, _method);
      return true;
    });
    if (ok == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${rupiah(_amount)} added to your balance.')),
      );
      setState(() => _mutations = wallet.mutations());
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallet = AppScope.of(context).wallet;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Balance')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.nara.primaryDark,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.bolt_rounded, color: context.nara.accent),
                    const SizedBox(width: 8),
                    Text(
                      'NARA balance',
                      style: text.labelLarge!.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ValueListenableBuilder<int>(
                  valueListenable: wallet.balance,
                  builder: (_, b, _) => AnimatedNumber(
                    value: b.toDouble(),
                    format: (v) => rupiah(v.round()),
                    style: text.displaySmall!.copyWith(
                      color: Colors.white,
                      fontFeatures: tabularFigures,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SectionTitle('Top up'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final a in _topUpAmounts)
                ChoiceChip(
                  label: Text(rupiah(a)),
                  selected: a == _amount,
                  onSelected: (_) => setState(() => _amount = a),
                ),
            ],
          ),
          const SizedBox(height: 12),
          MethodPicker(
            selected: _method,
            onChanged: (m) => setState(() => _method = m),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _topUp,
            child: Text('Top up ${rupiah(_amount)}'),
          ),
          const SectionTitle('Activity'),
          FutureBuilder<List<WalletMutation>>(
            future: _mutations,
            builder: (context, snap) => FadeSwitcher(
              child: KeyedSubtree(
                key: ValueKey(snap.hasData),
                child: _activity(snap, text),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _activity(AsyncSnapshot<List<WalletMutation>> snap, TextTheme text) {
    if (!snap.hasData) {
      return const Shimmer(
        child: Column(
          children: [
            SkeletonCard(lines: 2, trailing: true),
            SkeletonCard(lines: 2, trailing: true),
          ],
        ),
      );
    }
    if (snap.data!.isEmpty) {
      return const EmptyState(
        icon: Icons.account_balance_wallet_outlined,
        message: 'No activity yet',
      );
    }
    return Card(
      child: Column(
        children: [
          for (final (i, m) in snap.data!.indexed)
            FadeSlideIn(
              index: i,
              child: ListTile(
                leading: Icon(
                  m.amount > 0 ? Icons.south_west : Icons.north_east,
                  color: m.amount > 0
                      ? context.nara.success
                      : context.nara.error,
                ),
                title: Text(m.note),
                subtitle: Text(dateTimeText(m.at)),
                trailing: Text(
                  '${m.amount > 0 ? '+' : ''}${rupiah(m.amount)}',
                  style: text.titleSmall!.copyWith(
                    fontFeatures: tabularFigures,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
