import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';

class BackendApiService {
  BackendApiService._();
  static final instance = BackendApiService._();

  Uri _uri(String path) => Uri.parse('${AppConfig.backendBaseUrl}$path');

  Future<void> registerDevice({
    required String installationId,
    required String platform,
    required String pushToken,
    required String appVersion,
    String? tenantLinkToken,
    String? tenantId,
  }) async {
    final response = await http.post(
      _uri('/v1/devices/register'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({
        'installation_id': installationId,
        'platform': platform,
        'push_token': pushToken,
        'tenant_link_token': tenantLinkToken,
        'tenant_id': tenantId,
        'app_version': appVersion,
      }),
    );

    if (response.statusCode >= 300) {
      throw Exception('Device registration failed (${response.statusCode})');
    }
  }

  Future<Map<String, dynamic>> requestLink({String? email, String? phone}) async {
    final payload = <String, String>{};
    if (email != null && email.trim().isNotEmpty) {
      payload['email'] = email.trim();
    }
    if (phone != null && phone.trim().isNotEmpty) {
      payload['phone'] = phone.trim();
    }

    final response = await http.post(
      _uri('/v1/tenants/request-link'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode >= 300) {
      throw Exception('Link request failed (${response.statusCode})');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> confirmLink({
    required String linkRequestId,
    required String otp,
    required String installationId,
  }) async {
    final response = await http.post(
      _uri('/v1/tenants/confirm-link'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({
        'link_request_id': linkRequestId,
        'otp_code': otp,
        'installation_id': installationId,
      }),
    );

    if (response.statusCode >= 300) {
      throw Exception('Link confirmation failed (${response.statusCode})');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
