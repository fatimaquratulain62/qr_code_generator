/// Centralized constant values used across the app.
class AppConstants {
  AppConstants._();

  static const String appName = 'QR Code Generator';
  static const String appVersion = '1.0.0';

  // SharedPreferences keys
  static const String prefThemeMode = 'pref_theme_mode';
  static const String prefHistory = 'pref_qr_history';
  static const String prefFavorites = 'pref_qr_favorites';
  static const String prefDownloadQuality = 'pref_download_quality';

  // Spacing
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;

  // Radius
  static const double radiusSm = 8;
  static const double radiusMd = 16;
  static const double radiusLg = 24;

  // Misc
  static const int maxHistoryItems = 200;
  static const String privacyPolicyUrl = 'https://example.com/privacy-policy';
  static const String supportEmail = 'support@example.com';
}

/// Supported PNG export resolutions.
enum DownloadQuality { standard, hd, ultraHd }

extension DownloadQualityX on DownloadQuality {
  String get label {
    switch (this) {
      case DownloadQuality.standard:
        return 'Standard (512px)';
      case DownloadQuality.hd:
        return 'HD (1024px)';
      case DownloadQuality.ultraHd:
        return 'Ultra HD (2048px)';
    }
  }

  double get pixelSize {
    switch (this) {
      case DownloadQuality.standard:
        return 512;
      case DownloadQuality.hd:
        return 1024;
      case DownloadQuality.ultraHd:
        return 2048;
    }
  }
}
