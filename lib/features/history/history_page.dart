import 'package:material_ui/material_ui.dart';

import '../../core/app_scope.dart';
import '../../core/format.dart';
import '../../core/motion.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';
import 'transaction_detail_page.dart';

Color sessionStatusColor(BuildContext context, SessionStatus s) =>
    s == SessionStatus.paid ? context.nara.success : context.nara.warning;

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<ChargingSession>> _future = AppScope.of(context).charging
      .history();

  void _reload() =>
      setState(() => _future = AppScope.of(context).charging.history());

  Future<void> _open(ChargingSession s) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => TransactionDetailPage(session: s),
      ),
    );
    if (mounted) _reload();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: FutureBuilder<List<ChargingSession>>(
        future: _future,
        builder: (context, snap) => FadeSwitcher(
          child: KeyedSubtree(
            key: ValueKey(snap.hasData),
            child: _body(snap, text),
          ),
        ),
      ),
    );
  }

  Widget _body(AsyncSnapshot<List<ChargingSession>> snap, TextTheme text) {
    if (!snap.hasData) {
      return const SkeletonList(
        card: SkeletonCard(leading: false, trailing: true),
      );
    }
    if (snap.data!.isEmpty) {
      return const EmptyState(
        icon: Icons.receipt_long_outlined,
        message: 'No charging sessions yet',
      );
    }
    return RefreshIndicator(
      onRefresh: () async => _reload(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          for (final (i, s) in snap.data!.indexed)
            FadeSlideIn(
              index: i,
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => _open(s),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.point.station.name,
                                style: text.titleSmall,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                dateTimeText(s.startedAt),
                                style: text.bodySmall,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${kwh(s.energyKwh)} · ${durationText(s.elapsed)}',
                                style: text.bodySmall!.copyWith(
                                  fontFeatures: tabularFigures,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              rupiah(s.cost),
                              style: text.titleSmall!.copyWith(
                                fontFeatures: tabularFigures,
                              ),
                            ),
                            const SizedBox(height: 6),
                            StatusChip(
                              label: s.status.label,
                              color: sessionStatusColor(context, s.status),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
