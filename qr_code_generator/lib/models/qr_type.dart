import 'package:flutter/material.dart';

/// All QR content categories supported by the app.
enum QrType {
  text,
  url,
  email,
  phone,
  sms,
  wifi,
  contact,
  location,
}

extension QrTypeX on QrType {
  String get label {
    switch (this) {
      case QrType.text:
        return 'Text';
      case QrType.url:
        return 'Website';
      case QrType.email:
        return 'Email';
      case QrType.phone:
        return 'Phone';
      case QrType.sms:
        return 'SMS';
      case QrType.wifi:
        return 'WiFi';
      case QrType.contact:
        return 'Contact';
      case QrType.location:
        return 'Location';
    }
  }

  IconData get icon {
    switch (this) {
      case QrType.text:
        return Icons.notes_rounded;
      case QrType.url:
        return Icons.link_rounded;
      case QrType.email:
        return Icons.email_rounded;
      case QrType.phone:
        return Icons.phone_rounded;
      case QrType.sms:
        return Icons.sms_rounded;
      case QrType.wifi:
        return Icons.wifi_rounded;
      case QrType.contact:
        return Icons.contact_page_rounded;
      case QrType.location:
        return Icons.location_on_rounded;
    }
  }

  static QrType fromName(String name) {
    return QrType.values.firstWhere(
      (e) => e.name == name,
      orElse: () => QrType.text,
    );
  }
}

/// WiFi authentication types recognized by the QR WiFi standard.
enum WifiSecurity { wpa, wep, none }

extension WifiSecurityX on WifiSecurity {
  String get label {
    switch (this) {
      case WifiSecurity.wpa:
        return 'WPA/WPA2';
      case WifiSecurity.wep:
        return 'WEP';
      case WifiSecurity.none:
        return 'None';
    }
  }

  String get code {
    switch (this) {
      case WifiSecurity.wpa:
        return 'WPA';
      case WifiSecurity.wep:
        return 'WEP';
      case WifiSecurity.none:
        return 'nopass';
    }
  }
}

/// Builds the raw string payload that gets encoded into the QR code
/// for each [QrType], following standard QR conventions (mailto:, tel:,
/// smsto:, WIFI:, MECARD:, geo: etc.) so generated codes are readable by
/// any standard QR scanner.
class QrPayloadBuilder {
  QrPayloadBuilder._();

  static String text(String value) => value;

  static String url(String value) => value;

  static String email(String address, {String subject = '', String body = ''}) {
    final buffer = StringBuffer('mailto:$address');
    final params = <String>[];
    if (subject.isNotEmpty) params.add('subject=${Uri.encodeComponent(subject)}');
    if (body.isNotEmpty) params.add('body=${Uri.encodeComponent(body)}');
    if (params.isNotEmpty) buffer.write('?${params.join('&')}');
    return buffer.toString();
  }

  static String phone(String number) => 'tel:$number';

  static String sms(String number, {String message = ''}) {
    if (message.isEmpty) return 'smsto:$number';
    return 'smsto:$number:$message';
  }

  static String wifi({
    required String ssid,
    required String password,
    required WifiSecurity security,
    bool hidden = false,
  }) {
    String esc(String s) => s
        .replaceAll('\\', '\\\\')
        .replaceAll(';', '\\;')
        .replaceAll(',', '\\,')
        .replaceAll(':', '\\:');
    return 'WIFI:T:${security.code};S:${esc(ssid)};'
        '${security == WifiSecurity.none ? '' : 'P:${esc(password)};'}'
        'H:${hidden ? 'true' : 'false'};;';
  }

  static String contact({
    required String name,
    String phone = '',
    String email = '',
    String org = '',
    String address = '',
  }) {
    final buffer = StringBuffer('MECARD:N:$name;');
    if (phone.isNotEmpty) buffer.write('TEL:$phone;');
    if (email.isNotEmpty) buffer.write('EMAIL:$email;');
    if (org.isNotEmpty) buffer.write('ORG:$org;');
    if (address.isNotEmpty) buffer.write('ADR:$address;');
    buffer.write(';');
    return buffer.toString();
  }

  static String location(String latitude, String longitude) {
    return 'geo:$latitude,$longitude';
  }
}
