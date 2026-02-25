import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../services/backend_api_service.dart';
import '../services/storage_service.dart';

typedef PushTapHandler = void Function(String deepLink);

class PushService {
  PushService._();
  static final instance = PushService._();

  Future<void> initialize(PushTapHandler onTap) async {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final deepLink = message.data['deep_link'];
      if (deepLink is String && deepLink.isNotEmpty) {
        onTap(deepLink);
      }
    });

    final launchMessage = await FirebaseMessaging.instance.getInitialMessage();
    final launchDeepLink = launchMessage?.data['deep_link'];
    if (launchDeepLink is String && launchDeepLink.isNotEmpty) {
      onTap(launchDeepLink);
    }
  }

  Future<void> registerForPushIfLinked() async {
    if (Firebase.apps.isEmpty) {
      return;
    }

    final storage = StorageService.instance;
    final linkToken = await storage.getLinkToken();
    final tenantId = await storage.getTenantId();
    if (linkToken == null && tenantId == null) {
      return;
    }

    await FirebaseMessaging.instance.requestPermission();
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) {
      return;
    }

    final installId = await storage.getOrCreateInstallationId();
    final package = await PackageInfo.fromPlatform();

    await BackendApiService.instance.registerDevice(
      installationId: installId,
      platform: Platform.isIOS ? 'ios' : 'android',
      pushToken: token,
      appVersion: package.version,
      tenantLinkToken: linkToken,
      tenantId: tenantId,
    );
  }
}
