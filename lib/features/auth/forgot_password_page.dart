import 'package:material_ui/material_ui.dart';

import '../../core/app_scope.dart';
import '../../core/widgets.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key, this.email = ''});

  final String email;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  late final _email = TextEditingController(text: widget.email);
  var _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final auth = AppScope.of(context).auth;
    final ok = await guard(context, () async {
      await auth.forgotPassword(_email.text);
      return true;
    });
    if (ok == true && mounted) setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    if (_sent) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyState(
          icon: Icons.mark_email_read_outlined,
          message: 'Check your inbox.\nWe sent a reset link to ${_email.text}.',
        ),
        bottomNavigationBar: BottomAction(
          child: FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back to sign in'),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Forgot your password?', style: text.headlineSmall),
          const SizedBox(height: 8),
          Text(
            "Enter your email and we'll send you a link to reset it.",
            style: text.bodyMedium!.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(labelText: 'Email'),
            onSubmitted: (_) => _send(),
          ),
        ],
      ),
      bottomNavigationBar: BottomAction(
        child: FilledButton(
          onPressed: _send,
          child: const Text('Send reset link'),
        ),
      ),
    );
  }
}
