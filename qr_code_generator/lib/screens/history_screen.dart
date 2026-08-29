import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../models/qr_history_item.dart';
import '../providers/history_provider.dart';
import '../widgets/history_list_item.dart';
import 'qr_detail_sheet.dart';

/// Shows all previously generated QR codes with search, favoriting,
/// deleting, and a "clear all" action.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  Future<void> _confirmClearAll(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all history?'),
        content: const Text(
          'This will permanently delete every saved QR code from your history. Favorites will also be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear all'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<HistoryProvider>().clearAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryProvider>(
      builder: (context, history, _) {
        if (history.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = history.filtered;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.spacingMd,
                AppConstants.spacingMd,
                AppConstants.spacingMd,
                0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: history.setSearchQuery,
                      decoration: const InputDecoration(
                        hintText: 'Search history',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                  ),
                  if (history.all.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Semantics(
                      button: true,
                      label: 'Clear all history',
                      child: IconButton.filledTonal(
                        onPressed: () => _confirmClearAll(context),
                        icon: const Icon(Icons.delete_sweep_rounded),
                        constraints:
                            const BoxConstraints(minWidth: 48, minHeight: 48),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? _EmptyState(isSearching: history.searchQuery.isNotEmpty)
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppConstants.spacingMd),
                      itemCount: items.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppConstants.spacingSm),
                      itemBuilder: (context, index) {
                        final QrHistoryItem item = items[index];
                        return HistoryListItem(
                          item: item,
                          onTap: () => showQrDetailSheet(context, item),
                          onFavoriteToggle: () =>
                              context.read<HistoryProvider>().toggleFavorite(item.id),
                          onDelete: () =>
                              context.read<HistoryProvider>().delete(item.id),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isSearching});

  final bool isSearching;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSearching ? Icons.search_off_rounded : Icons.qr_code_2_rounded,
              size: 56,
              color: theme.colorScheme.onSurfaceVariant.withOpacity( 0.4),
            ),
            const SizedBox(height: 12),
            Text(
              isSearching
                  ? 'No results found'
                  : 'No QR codes yet.\nGenerate one to see it here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
