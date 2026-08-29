import 'qr_type.dart';

/// Represents a single previously generated QR code, persisted locally.
class QrHistoryItem {
  final String id;
  final QrType type;

  /// The raw encoded QR payload (what actually goes into the QR image).
  final String payload;

  /// A human-readable version of what the user entered, shown in lists.
  final String displayContent;

  final DateTime createdAt;
  final bool isFavorite;

  const QrHistoryItem({
    required this.id,
    required this.type,
    required this.payload,
    required this.displayContent,
    required this.createdAt,
    this.isFavorite = false,
  });

  QrHistoryItem copyWith({
    String? id,
    QrType? type,
    String? payload,
    String? displayContent,
    DateTime? createdAt,
    bool? isFavorite,
  }) {
    return QrHistoryItem(
      id: id ?? this.id,
      type: type ?? this.type,
      payload: payload ?? this.payload,
      displayContent: displayContent ?? this.displayContent,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'payload': payload,
        'displayContent': displayContent,
        'createdAt': createdAt.toIso8601String(),
        'isFavorite': isFavorite,
      };

  factory QrHistoryItem.fromJson(Map<String, dynamic> json) {
    return QrHistoryItem(
      id: json['id'] as String,
      type: QrTypeX.fromName(json['type'] as String? ?? 'text'),
      payload: json['payload'] as String? ?? '',
      displayContent: json['displayContent'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
              DateTime.now(),
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }
}
