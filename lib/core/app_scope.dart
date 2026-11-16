import 'package:material_ui/material_ui.dart';

import '../data/models.dart';
import '../data/repositories.dart';

/// Menyediakan repository ke seluruh widget tree.
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.auth,
    required this.stations,
    required this.charging,
    required this.wallet,
    required super.child,
  });

  final AuthRepository auth;
  final StationRepository stations;
  final ChargingRepository charging;
  final WalletRepository wallet;

  static AppScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!;

  @override
  bool updateShouldNotify(AppScope old) => false;
}

/// Jalankan aksi dengan dialog loading; [AppException] tampil sebagai snackbar.
/// Return null jika gagal.
Future<T?> guard<T>(BuildContext context, Future<T> Function() action) async {
  final nav = Navigator.of(context, rootNavigator: true);
  final messenger = ScaffoldMessenger.of(context);
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );
  try {
    return await action();
  } on AppException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.message)));
    return null;
  } finally {
    nav.pop();
  }
}
