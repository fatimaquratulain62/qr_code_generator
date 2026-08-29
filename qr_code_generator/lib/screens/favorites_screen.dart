import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../providers/history_provider.dart';
import '../widgets/history_list_item.dart';
import 'qr_detail_sheet.dart';

/// Shows only the QR codes the user has marked as favorites.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryProvider>(
      builder: (context, history, _) {
        if (history.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final favorites = history.favorites;

        if (favorites.isEmpty) {
          final theme = Theme.of(context);
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingLg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite_border_rounded,
                    size: 56,
                    color: theme.colorScheme.onSurfaceVariant.withOpacity( 0.4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No favorites yet.\nTap the heart on any QR code to save it here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          itemCount: favorites.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppConstants.spacingSm),
          itemBuilder: (context, index) {
            final item = favorites[index];
            return HistoryListItem(
              item: item,
              onTap: () => showQrDetailSheet(context, item),
              onFavoriteToggle: () =>
                  context.read<HistoryProvider>().toggleFavorite(item.id),
              onDelete: () => context.read<HistoryProvider>().delete(item.id),
            );
          },
        );
      },
    );
  }
}
