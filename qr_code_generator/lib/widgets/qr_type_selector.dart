import 'package:flutter/material.dart';

import '../models/qr_type.dart';

/// Horizontally scrollable row of chips letting the user pick which kind
/// of QR code to generate.
class QrTypeSelector extends StatelessWidget {
  const QrTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final QrType selected;
  final ValueChanged<QrType> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: QrType.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final type = QrType.values[index];
          final isSelected = type == selected;

          return Semantics(
            button: true,
            selected: isSelected,
            label: '${type.label} QR type',
            child: ChoiceChip(
              avatar: Icon(
                type.icon,
                size: 18,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              label: Text(type.label),
              selected: isSelected,
              onSelected: (_) => onChanged(type),
              showCheckmark: false,
              backgroundColor: theme.colorScheme.surfaceContainerHigh,
              selectedColor: theme.colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          );
        },
      ),
    );
  }
}
