import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:vision_gallery_saver/vision_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart' show SharePlus, ShareParams, XFile;

/// Handles converting the on-screen QR widget into PNG bytes, then either
/// saving it to the device gallery or sharing it via the native share sheet.
class QrService {
  QrService._();
  static final QrService instance = QrService._();

  /// Captures the widget wrapped by [boundaryKey] as PNG bytes at the given
  /// [pixelRatio] (higher = higher resolution export).
  Future<Uint8List?> captureBoundary(
    GlobalKey boundaryKey, {
    double pixelRatio = 3.0,
  }) async {
    try {
      final boundaryContext = boundaryKey.currentContext;
      if (boundaryContext == null) return null;
      final boundary =
          boundaryContext.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  /// Requests the storage/photos permission needed to save images, when the
  /// platform requires it. Returns true if permission is granted or not
  /// required on this platform/API level.
  Future<bool> requestSavePermission() async {
    if (!Platform.isAndroid && !Platform.isIOS) return true;
    final status = await Permission.photos.request();
    if (status.isGranted || status.isLimited) return true;

    // Older Android versions use the storage permission instead.
    final storageStatus = await Permission.storage.request();
    return storageStatus.isGranted;
  }

  /// Saves PNG [bytes] to the device gallery. Returns true on success.
/// Saves PNG [bytes] to the device gallery. Returns true on success.
/// Saves PNG [bytes] to the device gallery. Returns true on success.
Future<bool> saveToGallery(Uint8List bytes, {String? fileName}) async {
  try {
    final hasPermission = await requestSavePermission();
    if (!hasPermission) return false;

    final result = await VisionGallerySaver.saveImage(
      bytes,
      name: fileName ?? 'qr_${DateTime.now().millisecondsSinceEpoch}',
    );

    return result['isSuccess'] == true;
  } catch (e) {
    debugPrint('Save error: $e');
    return false;
  }
}
 
  /// Writes PNG [bytes] to a temporary file and opens the native share
  /// sheet so the user can send it via WhatsApp, Gmail, Bluetooth, etc.
  Future<bool> shareImage(Uint8List bytes, {String? fileName}) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/${fileName ?? 'qr_code'}_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'QR Code generated with QR Code Generator',
        ),
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
