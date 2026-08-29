import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../core/constants/app_constants.dart';
import '../models/qr_history_item.dart';
import '../services/qr_service.dart';
import '../widgets/app_button.dart';
import '../widgets/qr_preview_card.dart';
import '../models/qr_type.dart';

/// Opens a bottom sheet showing the full-size QR code for a history or
/// favorite item, with copy/save/share actions ("reopen" and "regenerate"
/// from history).
Future<void> showQrDetailSheet(BuildContext context, QrHistoryItem item) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => _QrDetailSheet(item: item),
  );
}

class _QrDetailSheet extends StatefulWidget {
  const _QrDetailSheet({required this.item});

  final QrHistoryItem item;

  @override
  State<_QrDetailSheet> createState() => _QrDetailSheetState();
}

class _QrDetailSheetState extends State<_QrDetailSheet> {
  final GlobalKey _boundaryKey = GlobalKey();
  bool _isBusy = false;

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _isBusy = true);
    final bytes = await QrService.instance.captureBoundary(_boundaryKey, pixelRatio: 5);
    if (bytes == null) {
      setState(() => _isBusy = false);
      _showSnack('Could not capture QR code', isError: true);
      return;
    }
    final success = await QrService.instance.saveToGallery(bytes);
    if (!mounted) return;
    setState(() => _isBusy = false);
    _showSnack(success ? 'Saved to gallery' : 'Could not save image', isError: !success);
  }

  Future<void> _share() async {
    setState(() => _isBusy = true);
    final bytes = await QrService.instance.captureBoundary(_boundaryKey);
    setState(() => _isBusy = false);
    if (bytes == null) {
      _showSnack('Could not prepare QR code for sharing', isError: true);
      return;
    }
    await QrService.instance.shareImage(bytes);
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.item.displayContent));
    _showSnack('Copied to clipboard');
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final dateLabel =
        DateFormat('MMM d, yyyy · h:mm a').format(item.createdAt);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppConstants.spacingLg,
          right: AppConstants.spacingLg,
          top: AppConstants.spacingLg,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppConstants.spacingLg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingLg),
            Row(
              children: [
                Icon(item.type.icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(item.type.label, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              dateLabel,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppConstants.spacingLg),
            QrPreviewCard(boundaryKey: _boundaryKey, data: item.payload),
            const SizedBox(height: AppConstants.spacingMd),
            SelectableText(
              item.displayContent,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: AppConstants.spacingLg),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Save',
                    icon: Icons.download_rounded,
                    isOutlined: true,
                    isLoading: _isBusy,
                    onPressed: _save,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingSm),
                Expanded(
                  child: AppButton(
                    label: 'Share',
                    icon: Icons.share_rounded,
                    isOutlined: true,
                    isLoading: _isBusy,
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
          ],
        ),
      ),
    );
  }
}
