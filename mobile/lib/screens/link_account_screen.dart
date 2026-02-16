import 'package:flutter/material.dart';

import '../services/backend_api_service.dart';
import '../services/storage_service.dart';

class LinkAccountScreen extends StatefulWidget {
  const LinkAccountScreen({super.key});

  @override
  State<LinkAccountScreen> createState() => _LinkAccountScreenState();
}

class _LinkAccountScreenState extends State<LinkAccountScreen> {
  final _contactController = TextEditingController();
  final _otpController = TextEditingController();
  String? _linkRequestId;
  bool _busy = false;
  String? _status;

  Future<void> _requestOtp() async {
    setState(() {
      _busy = true;
      _status = null;
    });
    try {
      final contact = _contactController.text.trim();
      final response = contact.contains('@')
          ? await BackendApiService.instance.requestLink(email: contact)
          : await BackendApiService.instance.requestLink(phone: contact);
      setState(() {
        _linkRequestId = response['link_request_id'] as String;
        _status = 'Code sent to ${response['masked_destination']}';
      });
    } catch (e) {
      setState(() => _status = 'Request failed: $e');
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _confirmOtp() async {
    if (_linkRequestId == null) return;
    setState(() {
      _busy = true;
      _status = null;
    });
    try {
      final installationId = await StorageService.instance.getOrCreateInstallationId();
      final response = await BackendApiService.instance.confirmLink(
        linkRequestId: _linkRequestId!,
        otp: _otpController.text.trim(),
        installationId: installationId,
      );

      final tenantId = response['tenant_id'] as String;
      final token = response['link_token'] as String;
      await StorageService.instance.saveLink(tenantId, token);

      if (mounted) {
        setState(() => _status = 'Account linked successfully.');
      }
    } catch (e) {
      setState(() => _status = 'Verification failed: $e');
    } finally {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Link Account', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _contactController,
              decoration: const InputDecoration(
                labelText: 'Email or phone',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _busy ? null : _requestOtp,
              child: const Text('Request Code'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _otpController,
              decoration: const InputDecoration(
                labelText: 'OTP code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _busy ? null : _confirmOtp,
              child: const Text('Confirm Link'),
            ),
            if (_status != null) ...[
              const SizedBox(height: 12),
              Text(_status!),
            ],
          ],
        ),
      ),
    );
  }
}
