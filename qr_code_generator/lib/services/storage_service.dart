import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../models/qr_history_item.dart';

/// Thin persistence layer over [SharedPreferences]. All read/write access
/// to local storage should flow through this service so the rest of the
/// app never talks to SharedPreferences directly.
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _prefsInstance async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  // ---------------- Theme ----------------

  Future<void> saveThemeMode(String modeName) async {
    final prefs = await _prefsInstance;
    await prefs.setString(AppConstants.prefThemeMode, modeName);
  }

  Future<String?> loadThemeMode() async {
    final prefs = await _prefsInstance;
    return prefs.getString(AppConstants.prefThemeMode);
  }

  // ---------------- Download quality ----------------

  Future<void> saveDownloadQuality(String qualityName) async {
    final prefs = await _prefsInstance;
    await prefs.setString(AppConstants.prefDownloadQuality, qualityName);
  }

  Future<String?> loadDownloadQuality() async {
    final prefs = await _prefsInstance;
    return prefs.getString(AppConstants.prefDownloadQuality);
  }

  // ---------------- History ----------------

  Future<void> saveHistory(List<QrHistoryItem> items) async {
    final prefs = await _prefsInstance;
    final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(AppConstants.prefHistory, encoded);
  }

  Future<List<QrHistoryItem>> loadHistory() async {
    final prefs = await _prefsInstance;
    final raw = prefs.getString(AppConstants.prefHistory);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => QrHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> clearHistory() async {
    final prefs = await _prefsInstance;
    await prefs.remove(AppConstants.prefHistory);
  }
}
