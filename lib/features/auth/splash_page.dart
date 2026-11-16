import 'package:material_ui/material_ui.dart';

import '../../core/motion.dart';
import '../../core/theme.dart';

/// Tampil selama sesi dipulihkan.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Motion.reduced(context)
              ? Duration.zero
              : const Duration(milliseconds: 500),
          curve: Motion.curve,
          builder: (_, t, child) => Opacity(
            opacity: t,
            child: Transform.scale(scale: 0.92 + 0.08 * t, child: child),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // shortcut: ikon sementara, ganti logo NARA saat tersedia (DESIGN TBD-D07).
              Icon(Icons.bolt_rounded, size: 72, color: context.nara.accent),
              const SizedBox(height: 8),
              Text('NARA', style: text.headlineMedium),
              Text(
                'Power for the journey.',
                style: text.bodyMedium!.copyWith(
                  color: context.nara.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
