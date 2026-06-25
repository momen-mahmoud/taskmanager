import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Profile / Settings: shows the signed-in user, a dark-mode toggle and logout.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again to continue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (shouldLogout == true) {
      // Clears the secure token; the router redirect navigates to login.
      await ref.read(authProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authProvider).valueOrNull;
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          const SizedBox(height: 8),
          Center(
            child: Container(
              height: 104,
              width: 104,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.seed, AppColors.accents[6]],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.seed.withValues(alpha: 0.4),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _initials(user?.name),
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 38,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: Text(
              user?.name ?? 'Guest',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              user?.email ?? '',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 28),
          _SettingsCard(
            children: [
              _InfoTile(
                icon: Icons.person_rounded,
                color: AppColors.accents[3],
                label: 'Name',
                value: user?.name ?? '—',
              ),
              const Divider(height: 1, indent: 64),
              _InfoTile(
                icon: Icons.email_rounded,
                color: AppColors.accents[5],
                label: 'Email',
                value: user?.email ?? '—',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsCard(
            children: [
              SwitchListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                secondary: _IconBadge(
                  icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: AppColors.accents[2],
                ),
                title: const Text('Dark mode'),
                subtitle: const Text('Toggle the app theme'),
                value: isDark,
                onChanged: (on) => ref
                    .read(themeModeProvider.notifier)
                    .setMode(on ? ThemeMode.dark : ThemeMode.light),
              ),
            ],
          ),
          const SizedBox(height: 28),
          AppButton(
            label: 'Log out',
            icon: Icons.logout_rounded,
            color: theme.colorScheme.error,
            onPressed: () => _confirmLogout(context, ref),
          ),
        ],
      ),
    );
  }

  String _initials(String? name) {
    final parts = (name ?? '').trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(children: children),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      leading: _IconBadge(icon: icon, color: color),
      title: Text(label,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      subtitle: Text(value, style: theme.textTheme.bodyLarge),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      width: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}
