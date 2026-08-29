import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/validators.dart';
import '../models/qr_type.dart';
import '../services/storage_service.dart';

/// Drives the Home screen's "create a QR code" experience: which type is
/// selected, the raw field values for that type, live-generated payload,
/// validation errors, and the preferred export quality.
class QrProvider extends ChangeNotifier {
  QrProvider() {
    _restoreQuality();
  }

  QrType _selectedType = QrType.text;
  QrType get selectedType => _selectedType;

  DownloadQuality _quality = DownloadQuality.hd;
  DownloadQuality get quality => _quality;

  // Raw field values, keyed by field name. Kept generic so each QR type
  // can define its own set of fields without needing a new provider.
  final Map<String, String> _fields = {};

  WifiSecurity _wifiSecurity = WifiSecurity.wpa;
  WifiSecurity get wifiSecurity => _wifiSecurity;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String field(String key) => _fields[key] ?? '';

  void setType(QrType type) {
    if (_selectedType == type) return;
    _selectedType = type;
    _fields.clear();
    _errorMessage = null;
    notifyListeners();
  }

  void setField(String key, String value) {
    _fields[key] = value;
    _errorMessage = null;
    notifyListeners();
  }

  void setWifiSecurity(WifiSecurity security) {
    _wifiSecurity = security;
    notifyListeners();
  }

  Future<void> _restoreQuality() async {
    final saved = await StorageService.instance.loadDownloadQuality();
    if (saved != null) {
      _quality = DownloadQuality.values.firstWhere(
        (q) => q.name == saved,
        orElse: () => DownloadQuality.hd,
      );
      notifyListeners();
    }
  }

  Future<void> setQuality(DownloadQuality quality) async {
    _quality = quality;
    notifyListeners();
    await StorageService.instance.saveDownloadQuality(quality.name);
  }

  /// Validates current fields for the selected type. Returns an error
  /// string, or null when the input is valid.
  String? validate() {
    switch (_selectedType) {
      case QrType.text:
        return Validators.notEmpty(field('text'), field: 'Text');
      case QrType.url:
        return Validators.url(field('url'));
      case QrType.email:
        return Validators.email(field('email'));
      case QrType.phone:
        return Validators.phone(field('phone'));
      case QrType.sms:
        return Validators.phone(field('smsPhone'));
      case QrType.wifi:
        return Validators.notEmpty(field('ssid'), field: 'Network name');
      case QrType.contact:
        return Validators.notEmpty(field('contactName'), field: 'Name');
      case QrType.location:
        return Validators.latitude(field('latitude')) ??
            Validators.longitude(field('longitude'));
    }
  }

  /// Builds the raw QR payload for the current type and field values.
  /// Returns null when the current input is invalid.
  ///
  /// When [silent] is true (used for the live preview as the user types),
  /// no error message is recorded/surfaced - the preview simply stays
  /// blank until the input becomes valid. When false (used by the
  /// explicit "Generate" action), an error message is set for display.
  String? buildPayload({bool silent = false}) {
    final error = validate();
    if (error != null) {
      if (!silent) _errorMessage = error;
      return null;
    }
    if (!silent) _errorMessage = null;

    switch (_selectedType) {
      case QrType.text:
        return QrPayloadBuilder.text(field('text'));
      case QrType.url:
        return QrPayloadBuilder.url(Validators.normalizeUrl(field('url')));
      case QrType.email:
        return QrPayloadBuilder.email(
          field('email'),
          subject: field('emailSubject'),
          body: field('emailBody'),
        );
      case QrType.phone:
        return QrPayloadBuilder.phone(field('phone'));
      case QrType.sms:
        return QrPayloadBuilder.sms(
          field('smsPhone'),
          message: field('smsMessage'),
        );
      case QrType.wifi:
        return QrPayloadBuilder.wifi(
          ssid: field('ssid'),
          password: field('wifiPassword'),
          security: _wifiSecurity,
        );
      case QrType.contact:
        return QrPayloadBuilder.contact(
          name: field('contactName'),
          phone: field('contactPhone'),
          email: field('contactEmail'),
          org: field('contactOrg'),
        );
      case QrType.location:
        return QrPayloadBuilder.location(field('latitude'), field('longitude'));
    }
  }

  /// A short, human-friendly summary of the current input, used when
  /// saving to history (e.g. shown in list items instead of raw payload).
  String buildDisplayContent() {
    switch (_selectedType) {
      case QrType.text:
        return field('text');
      case QrType.url:
        return Validators.normalizeUrl(field('url'));
      case QrType.email:
        return field('email');
      case QrType.phone:
        return field('phone');
      case QrType.sms:
        return field('smsPhone');
      case QrType.wifi:
        return field('ssid');
      case QrType.contact:
        return field('contactName');
      case QrType.location:
        return '${field('latitude')}, ${field('longitude')}';
    }
  }

  void reset() {
    _fields.clear();
    _errorMessage = null;
    notifyListeners();
  }
}
