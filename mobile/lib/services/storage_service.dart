import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/notification_prefs.dart';

class StorageService {
  StorageService._();
  static final instance = StorageService._();

  static const _prefsKey = 'notification_prefs';
  static const _linkTokenKey = 'tenant_link_token';
  static const _tenantIdKey = 'tenant_id';
  static const _installationIdKey = 'installation_id';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<String> getOrCreateInstallationId() async {
    final existing = await _secureStorage.read(key: _installationIdKey);
    if (existing != null) {
      return existing;
    }
    final created = const Uuid().v4();
    await _secureStorage.write(key: _installationIdKey, value: created);
    return created;
  }

  Future<void> saveLink(String tenantId, String linkToken) async {
    await _secureStorage.write(key: _tenantIdKey, value: tenantId);
    await _secureStorage.write(key: _linkTokenKey, value: linkToken);
  }

  Future<String?> getTenantId() => _secureStorage.read(key: _tenantIdKey);
  Future<String?> getLinkToken() => _secureStorage.read(key: _linkTokenKey);

  Future<NotificationPrefs> loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) {
      return NotificationPrefs.defaults();
    }
    return NotificationPrefs.fromJson(raw);
  }

  Future<void> savePrefs(NotificationPrefs prefsData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, prefsData.toJson());
  }
}
