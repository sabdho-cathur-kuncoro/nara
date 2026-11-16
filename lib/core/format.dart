String rupiah(int value) {
  final digits = value.abs().toString();
  final b = StringBuffer(value < 0 ? '-Rp ' : 'Rp ');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) b.write('.');
    b.write(digits[i]);
  }
  return b.toString();
}

String km(double value) => value < 1
    ? '${(value * 1000).round()} m'
    : '${value.toStringAsFixed(1)} km';

String kwh(double value) => '${value.toStringAsFixed(2)} kWh';

String durationText(Duration d) =>
    '${d.inHours}h ${(d.inMinutes % 60).toString().padLeft(2, '0')}m';

String dateTimeText(DateTime t) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(t.day)}/${two(t.month)}/${t.year} ${two(t.hour)}:${two(t.minute)}';
}
