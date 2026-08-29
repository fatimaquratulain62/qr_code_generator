import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/qr_type.dart';
import '../providers/qr_provider.dart';

/// Renders the correct set of text fields for whichever [QrType] is
/// currently selected, wiring each field's value into [QrProvider] so the
/// live preview updates as the user types.
class QrInputForm extends StatefulWidget {
  const QrInputForm({super.key});

  @override
  State<QrInputForm> createState() => _QrInputFormState();
}

class _QrInputFormState extends State<QrInputForm> {
  final Map<String, TextEditingController> _controllers = {};
  QrType? _lastType;

  TextEditingController _controllerFor(String key) {
    return _controllers.putIfAbsent(key, () => TextEditingController());
  }

  /// Disposes and clears all field controllers, used when the selected QR
  /// type changes so stale text from the previous type doesn't linger.
  void _resetControllers() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
  }

  void _onChanged(String key, String value) {
    context.read<QrProvider>().setField(key, value);
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final type = context.select<QrProvider, QrType>((p) => p.selectedType);
    final error = context.select<QrProvider, String?>((p) => p.errorMessage);

    if (_lastType != null && _lastType != type) {
      _resetControllers();
    }
    _lastType = type;

    return Column(
      key: ValueKey(type),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._fieldsForType(type),
        if (error != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 16, color: Theme.of(context).colorScheme.error),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  error,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  List<Widget> _fieldsForType(QrType type) {
    switch (type) {
      case QrType.text:
        return [
          _field(
            key: 'text',
            label: 'Text content',
            hint: 'Type anything you want to encode',
            maxLines: 4,
          ),
        ];
      case QrType.url:
        return [
          _field(
            key: 'url',
            label: 'Website URL',
            hint: 'example.com',
            keyboardType: TextInputType.url,
          ),
        ];
      case QrType.email:
        return [
          _field(
            key: 'email',
            label: 'Email address',
            hint: 'name@example.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          _field(key: 'emailSubject', label: 'Subject (optional)'),
          const SizedBox(height: 12),
          _field(key: 'emailBody', label: 'Message (optional)', maxLines: 3),
        ];
      case QrType.phone:
        return [
          _field(
            key: 'phone',
            label: 'Phone number',
            hint: '+1 555 123 4567',
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d\s\-+()]')),
            ],
          ),
        ];
      case QrType.sms:
        return [
          _field(
            key: 'smsPhone',
            label: 'Phone number',
            hint: '+1 555 123 4567',
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d\s\-+()]')),
            ],
          ),
          const SizedBox(height: 12),
          _field(key: 'smsMessage', label: 'Message (optional)', maxLines: 3),
        ];
      case QrType.wifi:
  return [
    _field(key: 'ssid', label: 'Network name (SSID)'),
    const SizedBox(height: 12),
    Consumer<QrProvider>(
      builder: (context, provider, _) {
        return DropdownButtonFormField<WifiSecurity>(
          value: provider.wifiSecurity,
          decoration: const InputDecoration(
            labelText: 'Security',
          ),
          items: WifiSecurity.values
              .map(
                (s) => DropdownMenuItem<WifiSecurity>(
                  value: s,
                  child: Text(s.label),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              provider.setWifiSecurity(value);
            }
          },
        );
      },
    ),
    if (context.watch<QrProvider>().wifiSecurity != WifiSecurity.none) ...[
      const SizedBox(height: 12),
      _field(
        key: 'wifiPassword',
        label: 'Password',
        obscure: true,
      ),
    ],
  ];
      case QrType.contact:
        return [
          _field(key: 'contactName', label: 'Full name'),
          const SizedBox(height: 12),
          _field(
            key: 'contactPhone',
            label: 'Phone (optional)',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          _field(
            key: 'contactEmail',
            label: 'Email (optional)',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          _field(key: 'contactOrg', label: 'Organization (optional)'),
        ];
      case QrType.location:
        return [
          Row(
            children: [
              Expanded(
                child: _field(
                  key: 'latitude',
                  label: 'Latitude',
                  hint: '37.7749',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true, signed: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _field(
                  key: 'longitude',
                  label: 'Longitude',
                  hint: '-122.4194',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true, signed: true),
                ),
              ),
            ],
          ),
        ];
    }
  }

  Widget _field({
    required String key,
    required String label,
    String? hint,
    int maxLines = 1,
    bool obscure = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final controller = _controllerFor(key);
    // Keep controller text in sync if provider was reset externally
    // (e.g. switching types clears fields) without fighting user input.
    final providerValue = context.read<QrProvider>().field(key);
    if (controller.text.isEmpty && providerValue.isNotEmpty) {
      controller.text = providerValue;
    }

    return Semantics(
      textField: true,
      label: label,
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        obscureText: obscure,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
        ),
        onChanged: (value) => _onChanged(key, value),
      ),
    );
  }
}
