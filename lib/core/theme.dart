import 'package:material_ui/material_ui.dart';

import '../data/models.dart';

// Style komponen (tombol, AppBar) tidak mewarisi ThemeData.fontFamily, jadi diset eksplisit.
const _font = 'PlusJakartaSans';

/// Angka (kWh, Rupiah, durasi) pakai digit selebar sama agar tidak goyang saat update.
const tabularFigures = [FontFeature.tabularFigures()];

/// Token warna NARA per mode. Sumber: DESIGN.md §2. Akses: `context.nara`.
@immutable
class NaraPalette extends ThemeExtension<NaraPalette> {
  const NaraPalette({
    required this.primary,
    required this.onPrimary,
    required this.primaryDark,
    required this.accent,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.success,
    required this.warning,
    required this.error,
    required this.danger,
  });

  final Color primary;
  final Color onPrimary;
  final Color primaryDark; // latar banner sesi aktif, teks putih
  final Color accent; // dekorasi saja, bukan teks
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color success;
  final Color warning;
  final Color error; // teks/border error
  final Color danger; // fill tombol merah dengan teks putih (kontras ≥ 4.5)

  static const light = NaraPalette(
    primary: Color(0xFF2563EB),
    onPrimary: Color(0xFFFFFFFF),
    primaryDark: Color(0xFF1E3A8A),
    accent: Color(0xFF2DD4BF),
    background: Color(0xFFF8FAFC),
    surface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF172033),
    textSecondary: Color(0xFF64748B),
    border: Color(0xFFE2E8F0),
    success: Color(0xFF22C55E),
    warning: Color(0xFFF59E0B),
    error: Color(0xFFEF4444),
    danger: Color(0xFFDC2626),
  );

  static const dark = NaraPalette(
    primary: Color(0xFF60A5FA),
    onPrimary: Color(0xFF0B1220),
    primaryDark: Color(0xFF1E3A8A),
    accent: Color(0xFF2DD4BF),
    background: Color(0xFF0B1220),
    surface: Color(0xFF111A2E),
    textPrimary: Color(0xFFE2E8F0),
    textSecondary: Color(0xFF94A3B8),
    border: Color(0xFF23304A),
    success: Color(0xFF22C55E),
    warning: Color(0xFFF59E0B),
    error: Color(0xFFF87171),
    danger: Color(0xFFDC2626),
  );

  Color connector(ConnectorStatus s) => switch (s) {
    ConnectorStatus.available => success,
    ConnectorStatus.charging => warning,
    ConnectorStatus.faulted => error,
    ConnectorStatus.offline => textSecondary,
  };

  @override
  NaraPalette copyWith() => this;

  @override
  NaraPalette lerp(NaraPalette? other, double t) =>
      t < 0.5 || other == null ? this : other;
}

extension NaraThemeContext on BuildContext {
  NaraPalette get nara => Theme.of(this).extension<NaraPalette>()!;
}

ThemeData buildNaraTheme(Brightness brightness) {
  final p = brightness == Brightness.dark
      ? NaraPalette.dark
      : NaraPalette.light;
  final scheme = ColorScheme(
    brightness: brightness,
    primary: p.primary,
    onPrimary: p.onPrimary,
    primaryContainer: p.primaryDark,
    onPrimaryContainer: Colors.white,
    secondary: p.accent,
    onSecondary: p.primaryDark,
    // Dipakai chip terpilih (ChoiceChip, SegmentedButton): tint biru + teks utama agar terbaca di kedua mode.
    secondaryContainer: p.primary.withValues(alpha: 0.14),
    onSecondaryContainer: p.textPrimary,
    tertiary: p.accent,
    onTertiary: p.primaryDark,
    surface: p.surface,
    onSurface: p.textPrimary,
    onSurfaceVariant: p.textSecondary,
    surfaceContainerLowest: p.surface,
    surfaceContainerLow: p.surface,
    surfaceContainer: p.surface,
    surfaceContainerHigh: p.surface,
    surfaceContainerHighest: p.background,
    error: p.error,
    onError: Colors.white,
    outline: p.border,
    outlineVariant: p.border,
  );

  TextStyle t(double size, double lineHeight, FontWeight w, [Color? c]) =>
      TextStyle(
        fontFamily: _font,
        fontSize: size,
        height: lineHeight / size,
        fontWeight: w,
        color: c ?? p.textPrimary,
      );

  // Skala DESIGN.md §3.1
  final text = TextTheme(
    displaySmall: t(40, 48, FontWeight.w700),
    headlineMedium: t(28, 36, FontWeight.w700),
    headlineSmall: t(24, 32, FontWeight.w600),
    titleLarge: t(18, 26, FontWeight.w600),
    titleMedium: t(16, 24, FontWeight.w600),
    titleSmall: t(14, 20, FontWeight.w600),
    bodyLarge: t(16, 24, FontWeight.w400),
    bodyMedium: t(14, 20, FontWeight.w400),
    bodySmall: t(12, 16, FontWeight.w400, p.textSecondary),
    labelLarge: t(14, 20, FontWeight.w500),
    labelMedium: t(12, 16, FontWeight.w500),
  );

  final buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(14),
  );
  const buttonText = TextStyle(
    fontFamily: _font,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
  const buttonSize = Size(64, 52);
  final selectedTint = p.primary.withValues(alpha: 0.14);
  OutlineInputBorder inputBorder(Color c, [double w = 1]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: c, width: w),
  );

  return ThemeData(
    brightness: brightness,
    colorScheme: scheme,
    extensions: [p],
    fontFamily: _font,
    textTheme: text,
    scaffoldBackgroundColor: p.background,
    appBarTheme: AppBarTheme(
      backgroundColor: p.background,
      foregroundColor: p.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: text.titleLarge,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: buttonSize,
        shape: buttonShape,
        textStyle: buttonText,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: buttonSize,
        shape: buttonShape,
        textStyle: buttonText,
        foregroundColor: p.primary,
        side: BorderSide(color: p.primary),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: buttonShape,
        textStyle: text.labelLarge,
      ),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: p.surface,
      border: inputBorder(p.border),
      enabledBorder: inputBorder(p.border),
      focusedBorder: inputBorder(p.primary, 2),
      errorBorder: inputBorder(p.error),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    cardTheme: CardThemeData(
      color: p.surface,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: p.border),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: const StadiumBorder(),
      side: BorderSide(color: p.border),
      backgroundColor: p.surface,
      selectedColor: selectedTint,
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: selectedTint,
        selectedForegroundColor: p.primary,
        foregroundColor: p.textSecondary,
        side: BorderSide(color: p.border),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: p.surface,
      indicatorColor: selectedTint,
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(
          color: s.contains(WidgetState.selected) ? p.primary : p.textSecondary,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => text.labelMedium!.copyWith(
          color: s.contains(WidgetState.selected) ? p.primary : p.textSecondary,
        ),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: p.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: p.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    snackBarTheme: SnackBarThemeData(
      // Mode gelap: snackbar terang agar menonjol dari latar.
      backgroundColor: p.textPrimary,
      contentTextStyle: text.bodyMedium!.copyWith(color: p.background),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dividerTheme: DividerThemeData(color: p.border, space: 1),
    listTileTheme: ListTileThemeData(iconColor: p.textSecondary),
  );
}
