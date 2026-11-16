import 'package:material_ui/material_ui.dart';

import '../../core/app_scope.dart';
import '../../core/format.dart';
import '../../core/motion.dart';
import '../../core/widgets.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../payment/payment_page.dart';

/// Kalimat status natural (DESIGN §5.1).
String _headline(SessionStatus s) => switch (s) {
  SessionStatus.starting => 'Getting the charger ready…',
  SessionStatus.charging => "You're charging.",
  SessionStatus.stopping => 'Stopping…',
  SessionStatus.paymentPending => 'Done charging. Time to pay.',
  SessionStatus.paid => "You're ready to go.",
};

/// Sesi aktif (real-time) + ringkasan. Hierarki DESIGN §4.3: status → kWh besar → durasi & biaya → satu aksi.
class ChargingPage extends StatelessWidget {
  const ChargingPage({super.key});

  Future<void> _confirmStop(BuildContext context) async {
    final charging = AppScope.of(context).charging;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Stop charging?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep charging'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: context.nara.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Stop'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) await guard(context, charging.stop);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ValueListenableBuilder<ChargingSession?>(
        valueListenable: AppScope.of(context).charging.active,
        builder: (context, s, _) {
          if (s == null) {
            return const EmptyState(
              icon: Icons.ev_station_outlined,
              message: 'No active charging session',
            );
          }
          final text = Theme.of(context).textTheme;
          final number = text.displaySmall!.copyWith(
            fontFeatures: tabularFigures,
          );
          final busy =
              s.status == SessionStatus.starting ||
              s.status == SessionStatus.stopping;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FadeSwitcher(
                    child: Text(
                      _headline(s.status),
                      key: ValueKey(s.status),
                      textAlign: TextAlign.center,
                      style: text.headlineSmall,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.point.station.name,
                    textAlign: TextAlign.center,
                    style: text.bodySmall,
                  ),
                  const Spacer(),
                  _EnergyRing(
                    active: s.status == SessionStatus.charging,
                    busy: busy,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedNumber(
                          value: s.energyKwh,
                          format: (v) => v.toStringAsFixed(2),
                          style: number,
                        ),
                        Text(
                          'kWh',
                          style: text.titleMedium!.copyWith(
                            color: context.nara.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      _Metric(
                        label: 'Duration',
                        value: s.elapsed.inMinutes.toDouble(),
                        format: (v) =>
                            durationText(Duration(minutes: v.round())),
                      ),
                      const SizedBox(width: 12),
                      _Metric(
                        label: s.status.isRunning ? 'Estimated cost' : 'Total',
                        value: s.cost.toDouble(),
                        format: (v) => rupiah(v.round()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${s.point.charger.name} · ${s.point.connector.type} ${s.point.connector.powerKw} kW · ${s.mode.label}',
                    textAlign: TextAlign.center,
                    style: text.bodySmall,
                  ),
                  if (s.paymentMethod != null)
                    Text(
                      'Paid with ${s.paymentMethod}',
                      textAlign: TextAlign.center,
                      style: text.bodySmall,
                    ),
                  const SizedBox(height: 24),
                  FadeSwitcher(
                    child: KeyedSubtree(
                      key: ValueKey(s.status),
                      child: switch (s.status) {
                        SessionStatus.charging => FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: context.nara.danger,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => _confirmStop(context),
                          child: const Text('Stop charging'),
                        ),
                        SessionStatus.paymentPending => FilledButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => PaymentPage(session: s),
                            ),
                          ),
                          child: Text('Pay ${rupiah(s.cost)}'),
                        ),
                        SessionStatus.paid => FilledButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Done'),
                        ),
                        _ => const SizedBox(height: 52),
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Lingkaran fokus di tengah layar charging; berdenyut pelan saat charging.
class _EnergyRing extends StatefulWidget {
  const _EnergyRing({
    required this.active,
    required this.busy,
    required this.child,
  });

  final bool active;
  final bool busy;
  final Widget child;

  @override
  State<_EnergyRing> createState() => _EnergyRingState();
}

class _EnergyRingState extends State<_EnergyRing>
    with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(_EnergyRing old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    // Hormati setting "reduce motion" (DESIGN §8).
    final animate = widget.active && !MediaQuery.disableAnimationsOf(context);
    if (animate && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!animate && _pulse.isAnimating) {
      _pulse.stop();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.active ? context.nara.success : context.nara.primary;
    return Center(
      child: SizedBox.square(
        dimension: 240,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulse,
              builder: (_, _) => Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.08 + 0.06 * _pulse.value),
                ),
              ),
            ),
            SizedBox.square(
              dimension: 200,
              child: CircularProgressIndicator(
                value: widget.busy ? null : 1,
                strokeWidth: 6,
                color: widget.active
                    ? context.nara.success
                    : context.nara.accent,
              ),
            ),
            Positioned(
              top: 44,
              child: Icon(
                widget.active ? Icons.bolt_rounded : Icons.check_circle_rounded,
                color: widget.active
                    ? context.nara.accent
                    : context.nara.primary,
              ),
            ),
            widget.child,
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.format,
  });

  final String label;
  final double value;
  final String Function(double) format;

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
              Text(label, style: text.bodySmall),
              const SizedBox(height: 4),
              FittedBox(
                child: AnimatedNumber(
                  value: value,
                  format: format,
                  style: text.titleLarge!.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFeatures: tabularFigures,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
