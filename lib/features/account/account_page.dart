import 'package:material_ui/material_ui.dart';

import '../../core/app_scope.dart';
import '../../core/format.dart';
import '../../core/theme.dart';
import '../payment/wallet_page.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  Future<void> _signOut(BuildContext context) async {
    final auth = AppScope.of(context).auth;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (ok == true) await auth.logout();
  }

  // Halaman bantuan & kebijakan belum ada (PRD TBD-34).
  void _comingSoon(BuildContext context) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Coming soon.')));

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final user = scope.auth.user.value;
    final text = Theme.of(context).textTheme;
    final initial = (user?.name.isNotEmpty ?? false)
        ? user!.name[0].toUpperCase()
        : '?';
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: context.nara.primary.withValues(alpha: 0.14),
                foregroundColor: context.nara.primary,
                child: Text(
                  initial,
                  style: text.titleLarge!.copyWith(color: context.nara.primary),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.name ?? '-', style: text.titleMedium),
                    Text(user?.email ?? '-', style: text.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                ValueListenableBuilder<int>(
                  valueListenable: scope.wallet.balance,
                  builder: (context, b, _) => ListTile(
                    leading: const Icon(Icons.account_balance_wallet_outlined),
                    title: const Text('Balance'),
                    subtitle: Text(rupiah(b)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const WalletPage(),
                      ),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Help & support'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _comingSoon(context),
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Privacy & terms'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _comingSoon(context),
                ),
              ],
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.logout, color: context.nara.error),
              title: Text(
                'Sign out',
                style: TextStyle(color: context.nara.error),
              ),
              onTap: () => _signOut(context),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'NARA 1.0.0 · demo data',
            textAlign: TextAlign.center,
            style: text.bodySmall,
          ),
        ],
      ),
    );
  }
}
