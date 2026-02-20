import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tobi_todo/core/theme/app_colors.dart';
import 'package:tobi_todo/providers/auth_provider.dart';
import 'package:tobi_todo/providers/gamification_provider.dart';
import 'package:tobi_todo/shared/services/tobi_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final gamificationStats = ref.watch(gamificationStatsProvider);

    return Scaffold(
      body: authState.when(
        data: (user) {
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Not logged in', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Navigating to login...')),
                      );
                    },
                    child: const Text('Login'),
                  ),
                ],
              ),
            );
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    '👤 Profile',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Profile Card
                  _buildProfileCard(context, user),
                  const SizedBox(height: 24),

                  // XP & Level Details
                  gamificationStats.when(
                    data: (stats) => _buildXPDetails(context, stats),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 24),

                  // Settings
                  _buildSettingsSection(context),
                  const SizedBox(height: 24),

                  // Integrations
                  _buildIntegrationsSection(context),
                  const SizedBox(height: 24),

                  // Account Management
                  _buildAccountSection(context, ref),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, dynamic user) {
    String initials = (user?.fullName ?? 'U')
        .split(' ')
        .map((word) => word.isNotEmpty ? word[0] : '')
        .join()
        .toUpperCase()
        .substring(0, 1);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary,
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.fullName ?? 'User',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? 'user@example.com',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildProfileStat('Member Since', 'Dec 2024'),
                _buildProfileStat('Verified', '✓'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildXPDetails(BuildContext context, dynamic stats) {
    return Card(
      elevation: 2,
      color: AppColors.primary.withAlpha((0.1 * 255).round()),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🎮 XP & Level Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailItem('Level', '${stats.level}', Colors.blue),
                _buildDetailItem('Total XP', '${stats.xp}', Colors.green),
                _buildDetailItem('Tier', 'Pro', Colors.purple),
              ],
            ),
            const SizedBox(height: 16),
            Text('Next Level Progress', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: 0.65,
                minHeight: 12,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(height: 8),
            Text('6,500 / 10,000 XP', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildSettingItem(Icons.notifications, 'Notifications', 'Manage alerts and reminders', context),
        _buildSettingItem(Icons.palette, 'Appearance', 'Dark mode, themes & colors', context),
        _buildSettingItem(Icons.calendar_month, 'Calendar', 'Connect your calendar', context),
        _buildSettingItem(Icons.language, 'Language', 'English (US)', context),
      ],
    );
  }

  Widget _buildSettingItem(IconData icon, String title, String subtitle, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening $title...')),
          );
        },
      ),
    );
  }

  Widget _buildIntegrationsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Integrations',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildIntegrationCard(context, 'Google Calendar', 'Sync your schedule', '✓ Connected', true),
        _buildIntegrationCard(context, 'Slack', 'Daily notifications', '⚠ Not connected', false),
        _buildIntegrationCard(context, 'GitHub', 'Track coding contributions', 'Not set up', false),
      ],
    );
  }

  Widget _buildIntegrationCard(BuildContext context, String name, String description, String status, bool connected) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: connected ? Colors.green[100] : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(name[0], style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        title: Text(name),
        subtitle: Text(description, style: const TextStyle(fontSize: 12)),
        trailing: ElevatedButton(
          onPressed: () {
            if (connected) {
              TobiService.instance.wave();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Manage integration — not implemented')));
            } else {
              TobiService.instance.wave();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connecting... (mock)')));
            }
          },
          child: Text(connected ? 'Manage' : 'Connect'),
        ),
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Opening account settings...')),
            );
          },
          icon: const Icon(Icons.security),
          label: const Text('Change Password'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Opening privacy settings...')),
            );
          },
          icon: const Icon(Icons.privacy_tip),
          label: const Text('Privacy Settings'),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              await ref.read(authProvider.notifier).logout();
              messenger.showSnackBar(
                const SnackBar(content: Text('Logged out successfully')),
              );
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            'Version 1.0.0 • Build 2024.12.01',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ),
      ],
    );
  }
}

