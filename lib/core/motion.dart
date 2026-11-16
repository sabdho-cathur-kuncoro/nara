import 'dart:async';

import 'package:material_ui/material_ui.dart';

/// Durasi standar animasi (DESIGN §8: 150 sampai 250 ms, angka sedikit lebih lama).
abstract final class Motion {
  static const fast = Duration(milliseconds: 150);
  static const medium = Duration(milliseconds: 250);
  static const number = Duration(milliseconds: 600);
  static const curve = Curves.easeOutCubic;

  /// Setting "reduce motion" di device.
  static bool reduced(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);
}

/// Fade + geser sedikit saat ganti konten (mis. skeleton ke data).
class FadeSwitcher extends StatelessWidget {
  const FadeSwitcher({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Motion.reduced(context) ? Duration.zero : Motion.medium,
      switchInCurve: Motion.curve,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, 0.02),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

/// Item list muncul bertahap: fade + geser naik, jeda per [index].
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: Motion.medium * 1.4,
  );
  late final _curved = CurvedAnimation(parent: _c, curve: Motion.curve);
  Timer? _delay;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_c.isAnimating || _c.isCompleted || _delay != null) return;
    if (Motion.reduced(context)) {
      _c.value = 1;
      return;
    }
    // Maks 6 langkah jeda agar list panjang tidak terasa lambat.
    _delay = Timer(Duration(milliseconds: 50 * widget.index.clamp(0, 6)), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _delay?.cancel();
    _curved.dispose();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curved,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(_curved),
        child: widget.child,
      ),
    );
  }
}

/// Angka yang menghitung halus ke nilai baru (kWh, Rupiah, saldo).
class AnimatedNumber extends StatelessWidget {
  const AnimatedNumber({
    super.key,
    required this.value,
    required this.format,
    this.style,
  });

  final double value;
  final String Function(double) format;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value),
      duration: Motion.reduced(context) ? Duration.zero : Motion.number,
      curve: Motion.curve,
      builder: (_, v, _) => Text(format(v), style: style),
    );
  }
}

/// Animasi pulse bersama untuk semua [SkeletonBox] di bawahnya. Statis bila reduce motion aktif.
class Shimmer extends StatefulWidget {
  const Shimmer({super.key, required this.child});

  final Widget child;

  static Animation<double>? _of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ShimmerScope>()?.notifier;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final _curved = CurvedAnimation(parent: _c, curve: Curves.easeInOut);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Motion.reduced(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _curved.dispose();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading',
      child: ExcludeSemantics(
        child: _ShimmerScope(notifier: _curved, child: widget.child),
      ),
    );
  }
}

class _ShimmerScope extends InheritedNotifier<Animation<double>> {
  const _ShimmerScope({required super.notifier, required super.child});
}

/// Kotak placeholder; berdenyut halus di dalam [Shimmer].
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 8,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t = Shimmer._of(context)?.value ?? 0;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Color.lerp(
          scheme.outline,
          scheme.outline.withValues(alpha: 0.45),
          t,
        ),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Skeleton generik untuk card list: lingkaran opsional + baris teks.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({
    super.key,
    this.leading = true,
    this.lines = 3,
    this.trailing = false,
  });

  final bool leading;
  final int lines;
  final bool trailing;

  @override
  Widget build(BuildContext context) {
    const widths = [0.55, 0.85, 0.4, 0.7];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (leading) ...[
              const SkeletonBox(width: 44, height: 44, radius: 22),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: LayoutBuilder(
                builder: (_, c) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < lines; i++) ...[
                      if (i > 0) const SizedBox(height: 8),
                      SkeletonBox(
                        width: c.maxWidth * widths[i % widths.length],
                        height: i == 0 ? 16 : 12,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (trailing) ...[
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SkeletonBox(width: 72, height: 16),
                  SizedBox(height: 8),
                  SkeletonBox(width: 56, height: 20, radius: 10),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// List [count] skeleton card dalam satu shimmer.
class SkeletonList extends StatelessWidget {
  const SkeletonList({
    super.key,
    this.count = 4,
    this.card = const SkeletonCard(),
    this.padding,
  });

  final int count;
  final Widget card;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: padding ?? const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: count,
        itemBuilder: (_, _) => card,
      ),
    );
  }
}
