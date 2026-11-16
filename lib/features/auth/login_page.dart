import 'package:material_ui/material_ui.dart';

import '../../core/app_scope.dart';
import '../../core/theme.dart';
import 'forgot_password_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = AppScope.of(context).auth;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 48),
            // shortcut: ikon sementara, ganti logo NARA saat tersedia (DESIGN TBD-D07).
            Icon(Icons.bolt_rounded, size: 64, color: context.nara.accent),
            const SizedBox(height: 8),
            Text(
              'NARA',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              'Power for the journey.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium!
                  .copyWith(color: context.nara.textSecondary),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: true,
              autofillHints: const [AutofillHints.password],
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => ForgotPasswordPage(email: _email.text),
                  ),
                ),
                child: const Text('Forgot password?'),
              ),
            ),
            FilledButton(
              onPressed: () =>
                  guard(context, () => auth.login(_email.text, _password.text)),
              child: const Text('Sign in'),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('or'),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => guard(context, auth.loginWithGoogle),
              icon: const Icon(Icons.g_mobiledata),
              label: const Text('Continue with Google'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => guard(context, auth.loginWithApple),
              icon: const Icon(Icons.apple),
              label: const Text('Continue with Apple'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => const RegisterPage()),
              ),
              child: const Text("Don't have an account? Sign up"),
            ),
          ],
        ),
      ),
    );
  }
}
