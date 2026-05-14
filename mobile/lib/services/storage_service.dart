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
  static const _biometricUnlockEnabledKey = 'biometric_unlock_enabled';
  static const _biometricPaymentEnabledKey = 'biometric_payment_enabled';
  static const _appOpenCountKey = 'app_open_count';
  static const _lastReviewPromptAtMsKey = 'last_review_prompt_at_ms';
  static const _portalTypeKey = 'portal_type';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

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

  Future<bool> isLinked() async {
    final tenantId = await getTenantId();
    final linkToken = await getLinkToken();
    return (tenantId != null && tenantId.isNotEmpty) || (linkToken != null && linkToken.isNotEmpty);
  }

  Future<bool> getBiometricUnlockEnabled() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_biometricUnlockEnabledKey) ?? false;
  }

  Future<void> setBiometricUnlockEnabled(bool enabled) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_biometricUnlockEnabledKey, enabled);
  }

  Future<bool> getBiometricPaymentEnabled() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_biometricPaymentEnabledKey) ?? false;
  }

  Future<void> setBiometricPaymentEnabled(bool enabled) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_biometricPaymentEnabledKey, enabled);
  }

  Future<int> incrementAndGetAppOpenCount() async {
    final prefs = await _getPrefs();
    final next = (prefs.getInt(_appOpenCountKey) ?? 0) + 1;
    await prefs.setInt(_appOpenCountKey, next);
    return next;
  }

  Future<int?> getLastReviewPromptAtMs() async {
    final prefs = await _getPrefs();
    return prefs.getInt(_lastReviewPromptAtMsKey);
  }

  Future<void> setLastReviewPromptAtMs(int value) async {
    final prefs = await _getPrefs();
    await prefs.setInt(_lastReviewPromptAtMsKey, value);
  }

  /// Returns 'resident', 'owner', or null if not yet chosen.
  Future<String?> getPortalType() async {
    final prefs = await _getPrefs();
    return prefs.getString(_portalTypeKey);
  }

  Future<void> setPortalType(String type) async {
    final prefs = await _getPrefs();
    await prefs.setString(_portalTypeKey, type);
  }

  Future<NotificationPrefs> loadPrefs() async {
    final prefs = await _getPrefs();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) {
      return NotificationPrefs.defaults();
    }
    return NotificationPrefs.fromJson(raw);
  }

  Future<void> savePrefs(NotificationPrefs prefsData) async {
    final prefs = await _getPrefs();
    await prefs.setString(_prefsKey, prefsData.toJson());
  }
}
