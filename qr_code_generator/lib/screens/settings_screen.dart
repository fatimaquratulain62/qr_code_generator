import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart' show SharePlus, ShareParams;
import 'package:url_launcher/url_launcher.dart' show launchUrl, LaunchMode;

import '../core/constants/app_constants.dart';
import '../providers/qr_provider.dart';
import '../providers/theme_provider.dart';

/// Settings screen: theme selection, export quality, and app info actions
/// (about, privacy policy, share app, rate app, version).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      children: [
        _SectionCard(
          title: 'Appearance',
          children: [
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                return Column(
                  children: ThemeMode.values.map((mode) {
                    return RadioListTile<ThemeMode>(
                      contentPadding: EdgeInsets.zero,
                      title: Text(_themeModeLabel(mode)),
                      value: mode,
                      groupValue: themeProvider.themeMode,
                      onChanged: (value) {
                        if (value != null) themeProvider.setThemeMode(value);
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingMd),
        _SectionCard(
          title: 'Downloads',
          children: [
            Consumer<QrProvider>(
              builder: (context, qrProvider, _) {
                return Column(
                  children: DownloadQuality.values.map((quality) {
                    return RadioListTile<DownloadQuality>(
                      contentPadding: EdgeInsets.zero,
                      title: Text(quality.label),
                      value: quality,
                      groupValue: qrProvider.quality,
                      onChanged: (value) {
                        if (value != null) qrProvider.setQuality(value);
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingMd),
        _SectionCard(
          title: 'About',
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.info_outline_rounded),
              title: const Text('About App'),
              onTap: () => _showAboutDialog(context),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Privacy Policy'),
              onTap: () => launchUrl(
                Uri.parse(AppConstants.privacyPolicyUrl),
                mode: LaunchMode.externalApplication,
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share App'),
              onTap: () => SharePlus.instance.share(
                ShareParams(
                  text:
                      'Check out ${AppConstants.appName} — generate and share QR codes instantly!',
                ),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.star_border_rounded),
              title: const Text('Rate App'),
              onTap: () => _showComingSoon(context),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.numbers_rounded),
              title: const Text('Version'),
              trailing: Text(
                AppConstants.appVersion,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System default';
    }
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opens your app store listing to rate.')),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationIcon: const Icon(Icons.qr_code_2_rounded, size: 40),
      children: const [
        SizedBox(height: 12),
        Text(
          'Generate, save, and share QR codes for text, websites, emails, '
          'phone numbers, SMS, WiFi, contacts, and locations — all in one '
          'clean, fast app.',
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            ...children,
          ],
        ),
      ),
    );
  }
}
