import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../core/constants/app_constants.dart';
import '../models/qr_history_item.dart';
import '../models/qr_type.dart';
import '../services/storage_service.dart';

/// Owns the list of previously generated QR codes: persistence, search,
/// favoriting, and deletion. The Favorites screen is simply a filtered view
/// over this same list.
class HistoryProvider extends ChangeNotifier {
  HistoryProvider() {
    _restore();
  }

  final _uuid = const Uuid();
  final List<QrHistoryItem> _items = [];
  String _searchQuery = '';
  bool _isLoading = true;

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  List<QrHistoryItem> get all => List.unmodifiable(_items);

  List<QrHistoryItem> get filtered {
    final query = _searchQuery.trim().toLowerCase();
    final sorted = [..._items]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (query.isEmpty) return sorted;
    return sorted
        .where((item) =>
            item.displayContent.toLowerCase().contains(query) ||
            item.type.label.toLowerCase().contains(query))
        .toList();
  }

  List<QrHistoryItem> get favorites {
    final favs = _items.where((item) => item.isFavorite).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return favs;
  }

  Future<void> _restore() async {
    final loaded = await StorageService.instance.loadHistory();
    _items
      ..clear()
      ..addAll(loaded);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _persist() async {
    await StorageService.instance.saveHistory(_items);
  }

  /// Adds a newly generated QR code to the top of the history list.
  Future<QrHistoryItem> add({
    required QrType type,
    required String payload,
    required String displayContent,
  }) async {
    final item = QrHistoryItem(
      id: _uuid.v4(),
      type: type,
      payload: payload,
      displayContent: displayContent,
      createdAt: DateTime.now(),
    );
    _items.insert(0, item);
    if (_items.length > AppConstants.maxHistoryItems) {
      _items.removeRange(AppConstants.maxHistoryItems, _items.length);
    }
    notifyListeners();
    await _persist();
    return item;
  }

  Future<void> toggleFavorite(String id) async {
    final index = _items.indexWhere((e) => e.id == id);
    if (index == -1) return;
    _items[index] = _items[index].copyWith(
      isFavorite: !_items[index].isFavorite,
    );
    notifyListeners();
    await _persist();
  }

  Future<void> delete(String id) async {
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
    await _persist();
  }

  Future<void> clearAll() async {
    _items.clear();
    notifyListeners();
    await StorageService.instance.clearHistory();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
