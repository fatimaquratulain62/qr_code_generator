/// Collection of stateless validation helpers for user input.
class Validators {
  Validators._();

  static final RegExp _emailRegex =
      RegExp(r'^[\w\.\-+]+@[\w\-]+\.[a-zA-Z]{2,}$');

  static final RegExp _urlRegex = RegExp(
    r'^(https?:\/\/)?([\w\-]+\.)+[a-zA-Z]{2,}(:\d+)?(\/[^\s]*)?$',
  );

  static final RegExp _phoneRegex = RegExp(r'^\+?[0-9\s\-()]{7,15}$');

  /// Returns an error message, or null if [value] is valid.
  static String? notEmpty(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field cannot be empty';
    }
    return null;
  }

  static String? url(String? value) {
    final emptyCheck = notEmpty(value, field: 'URL');
    if (emptyCheck != null) return emptyCheck;
    if (!_urlRegex.hasMatch(value!.trim())) {
      return 'Enter a valid website URL';
    }
    return null;
  }

  static String? email(String? value) {
    final emptyCheck = notEmpty(value, field: 'Email');
    if (emptyCheck != null) return emptyCheck;
    if (!_emailRegex.hasMatch(value!.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? phone(String? value) {
    final emptyCheck = notEmpty(value, field: 'Phone number');
    if (emptyCheck != null) return emptyCheck;
    if (!_phoneRegex.hasMatch(value!.trim())) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? latitude(String? value) {
    final emptyCheck = notEmpty(value, field: 'Latitude');
    if (emptyCheck != null) return emptyCheck;
    final parsed = double.tryParse(value!.trim());
    if (parsed == null || parsed < -90 || parsed > 90) {
      return 'Latitude must be between -90 and 90';
    }
    return null;
  }

  static String? longitude(String? value) {
    final emptyCheck = notEmpty(value, field: 'Longitude');
    if (emptyCheck != null) return emptyCheck;
    final parsed = double.tryParse(value!.trim());
    if (parsed == null || parsed < -180 || parsed > 180) {
      return 'Longitude must be between -180 and 180';
    }
    return null;
  }

  /// Normalizes a URL by prefixing https:// if no scheme is present.
  static String normalizeUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    return 'https://$trimmed';
  }
}
