import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Displays the live QR preview inside a [RepaintBoundary] so the exact
/// rendered widget can be captured as a PNG for saving/sharing.
class QrPreviewCard extends StatelessWidget {
  const QrPreviewCard({
    super.key,
    required this.boundaryKey,
    required this.data,
  });

  final GlobalKey boundaryKey;

  /// The raw payload to encode. When null/empty, a placeholder is shown
  /// instead of an empty QR code.
  final String? data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasData = data != null && data!.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity( 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Semantics(
        label: hasData ? 'Generated QR code preview' : 'No QR code yet',
        image: true,
        child: AspectRatio(
          aspectRatio: 1,
          child: hasData
              ? RepaintBoundary(
                  key: boundaryKey,
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: QrImageView(
                      data: data!,
                      version: QrVersions.auto,
                      backgroundColor: Colors.white,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Colors.black,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Colors.black,
                      ),
                      errorCorrectionLevel: QrErrorCorrectLevel.M,
                    ),
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.qr_code_2_rounded,
                        size: 64,
                        color: theme.colorScheme.onSurfaceVariant
                            .withOpacity(0.4),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Fill in the details to\ngenerate your QR code',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
