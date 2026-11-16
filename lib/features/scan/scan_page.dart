import 'package:material_ui/material_ui.dart';

import '../../core/app_scope.dart';
import '../../core/widgets.dart';
import '../../data/mock/mock_data.dart';
import '../charging/confirm_charge_page.dart';

/// shortcut: belum pakai kamera; pilih QR contoh / input manual. Tambah `mobile_scanner` saat format QR final (PRD TBD-12).
class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _resolve(String code) async {
    final repo = AppScope.of(context).stations;
    final point = await guard(context, () => repo.resolveQr(code));
    if (point == null || !mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => ConfirmChargePage(point: point)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Scan to charge')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          const _Viewfinder(),
          const SizedBox(height: 12),
          Text(
            'Point your camera at the QR code on the charger.',
            textAlign: TextAlign.center,
            style: text.bodyMedium!.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SectionTitle('Try a sample code'),
          Card(
            child: Column(
              children: [
                for (final e in mockQrCodes.entries)
                  ListTile(
                    leading: const Icon(Icons.qr_code_2),
                    title: Text(e.key, style: text.titleSmall),
                    subtitle: Text(e.value),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _resolve(e.key),
                  ),
              ],
            ),
          ),
          const SectionTitle('Or enter the charger ID'),
          TextField(
            controller: _code,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: 'Charger ID',
              hintText: 'NARA-c1',
              suffixIcon: IconButton(
                tooltip: 'Continue',
                icon: const Icon(Icons.arrow_forward),
                onPressed: () => _resolve(_code.text),
              ),
            ),
            onSubmitted: _resolve,
          ),
        ],
      ),
    );
  }
}

class _Viewfinder extends StatelessWidget {
  const _Viewfinder();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black, // viewfinder kamera selalu gelap
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.center,
        child: FractionallySizedBox(
          widthFactor: 0.6,
          heightFactor: 0.6,
          child: CustomPaint(
            painter: _CornerPainter(Theme.of(context).colorScheme.secondary),
            child: const Center(
              child: Text(
                'Camera preview',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bingkai sudut viewfinder.
class _CornerPainter extends CustomPainter {
  const _CornerPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    const l = 28.0;
    final w = size.width, h = size.height;
    for (final (x, y, dx, dy) in [
      (0.0, 0.0, 1, 1),
      (w, 0.0, -1, 1),
      (0.0, h, 1, -1),
      (w, h, -1, -1),
    ]) {
      canvas.drawLine(Offset(x, y), Offset(x + l * dx, y), p);
      canvas.drawLine(Offset(x, y), Offset(x, y + l * dy), p);
    }
  }

  @override
  bool shouldRepaint(_CornerPainter old) => old.color != color;
}
