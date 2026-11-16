import 'package:material_ui/material_ui.dart';

import 'core/app_scope.dart';
import 'core/theme.dart';
import 'data/mock/mock_backend.dart';
import 'data/models.dart';
import 'features/auth/login_page.dart';
import 'features/auth/splash_page.dart';
import 'features/home_shell.dart';

/// `flutter run --dart-define=ENV=mock|dev|prod`
const appEnv = String.fromEnvironment('ENV', defaultValue: 'mock');

void main() {
  if (appEnv != 'mock') {
    throw UnimplementedError(
      'Backend API not available yet (PRD TBD-04), use ENV=mock',
    );
  }
  final backend = MockBackend();
  runApp(
    AppScope(
      auth: backend,
      stations: backend,
      charging: backend,
      wallet: backend,
      child: const NaraApp(),
    ),
  );
}

class NaraApp extends StatelessWidget {
  const NaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NARA',
      debugShowCheckedModeBanner: false,
      theme: buildNaraTheme(Brightness.light),
      darkTheme: buildNaraTheme(Brightness.dark),
      home: const _Root(),
    );
  }
}

/// Splash selama sesi dipulihkan, lalu Login atau Home sesuai status user.
class _Root extends StatefulWidget {
  const _Root();

  @override
  State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> {
  late final _restore = AppScope.of(context).auth.restoreSession();

  @override
  Widget build(BuildContext context) {
    final auth = AppScope.of(context).auth;
    return FutureBuilder<void>(
      future: _restore,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const SplashPage();
        }
        return ValueListenableBuilder<User?>(
          valueListenable: auth.user,
          builder: (_, user, _) =>
              user == null ? const LoginPage() : const HomeShell(),
        );
      },
    );
  }
}
