import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../providers/history_provider.dart';
import '../providers/qr_provider.dart';
import '../services/qr_service.dart';
import '../widgets/app_button.dart';
import '../widgets/qr_input_form.dart';
import '../widgets/qr_preview_card.dart';
import '../widgets/qr_type_selector.dart';
import 'favorites_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

/// App shell: bottom navigation between the QR generator, History,
/// Favorites, and Settings tabs.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  static const _titles = ['QR Code Generator', 'History', 'Favorites', 'Settings'];

  final _tabs = const [
    _GeneratorTab(),
    HistoryScreen(),
    FavoritesScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_currentIndex])),
      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: _tabs),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.qr_code_rounded),
            label: 'Generate',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border_rounded),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

/// The main "create a QR code" experience: type selector, dynamic input
/// form, live preview, and generate/save/share/copy actions.
class _GeneratorTab extends StatefulWidget {
  const _GeneratorTab();

  @override
  State<_GeneratorTab> createState() => _GeneratorTabState();
}

class _GeneratorTabState extends State<_GeneratorTab> {
  final GlobalKey _boundaryKey = GlobalKey();
  bool _isSaving = false;
  bool _isSharing = false;

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : null,
      ),
    );
  }

  Future<void> _generate() async {
    final qrProvider = context.read<QrProvider>();
    final payload = qrProvider.buildPayload();

    if (payload == null) {
      _showSnack(qrProvider.errorMessage ?? 'Please check your input', isError: true);
      return;
    }

    final historyProvider = context.read<HistoryProvider>();
    await historyProvider.add(
      type: qrProvider.selectedType,
      payload: payload,
      displayContent: qrProvider.buildDisplayContent(),
    );
    _showSnack('QR code generated and saved to history');
  }

  Future<void> _save() async {
    final payload = context.read<QrProvider>().buildPayload(silent: true);
    if (payload == null) {
      _showSnack('Fill in valid details first', isError: true);
      return;
    }
    setState(() => _isSaving = true);
    final quality = context.read<QrProvider>().quality;
    final pixelRatio = quality.pixelSize / 200;
    final bytes = await QrService.instance
        .captureBoundary(_boundaryKey, pixelRatio: pixelRatio);

    if (bytes == null) {
      setState(() => _isSaving = false);
      _showSnack('Could not capture QR code', isError: true);
      return;
    }

    final success = await QrService.instance.saveToGallery(bytes);
    if (!mounted) return;
    setState(() => _isSaving = false);
    _showSnack(
      success ? 'Saved to gallery' : 'Could not save image. Check permissions.',
      isError: !success,
    );
  }

  Future<void> _share() async {
    final payload = context.read<QrProvider>().buildPayload(silent: true);
    if (payload == null) {
      _showSnack('Fill in valid details first', isError: true);
      return;
    }
    setState(() => _isSharing = true);
    final bytes = await QrService.instance.captureBoundary(_boundaryKey);
    setState(() => _isSharing = false);

    if (bytes == null) {
      _showSnack('Could not prepare QR code for sharing', isError: true);
      return;
    }
    await QrService.instance.shareImage(bytes);
  }

  Future<void> _copy() async {
    final qrProvider = context.read<QrProvider>();
    final content = qrProvider.buildDisplayContent();
    if (content.trim().isEmpty) {
      _showSnack('Nothing to copy yet', isError: true);
      return;
    }
    await Clipboard.setData(ClipboardData(text: content));
    _showSnack('Copied to clipboard');
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            child: Consumer<QrProvider>(
              builder: (context, provider, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'QR type',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    QrTypeSelector(
                      selected: provider.selectedType,
                      onChanged: provider.setType,
                    ),
                    const SizedBox(height: AppConstants.spacingMd),
                    const QrInputForm(),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spacingMd),
        Selector<QrProvider, String?>(
          selector: (_, provider) => provider.buildPayload(silent: true),
          builder: (context, payload, _) {
            return QrPreviewCard(boundaryKey: _boundaryKey, data: payload);
          },
        ),
        const SizedBox(height: AppConstants.spacingMd),
        AppButton(
          label: 'Generate & Save to History',
          icon: Icons.qr_code_2_rounded,
          onPressed: _generate,
        ),
        const SizedBox(height: AppConstants.spacingSm),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Save',
                icon: Icons.download_rounded,
                isOutlined: true,
                isLoading: _isSaving,
                onPressed: _save,
              ),
            ),
            const SizedBox(width: AppConstants.spacingSm),
            Expanded(
              child: AppButton(
                label: 'Share',
                icon: Icons.share_rounded,
                isOutlined: true,
                isLoading: _isSharing,
                onPressed: _share,
              ),
            ),
            const SizedBox(width: AppConstants.spacingSm),
            Expanded(
              child: AppButton(
                label: 'Copy',
                icon: Icons.copy_rounded,
                isOutlined: true,
                onPressed: _copy,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingLg),
      ],
    );
  }
}
