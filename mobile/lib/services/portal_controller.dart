import 'package:flutter/foundation.dart';

class PortalNavigationController {
  PortalNavigationController._();
  static final instance = PortalNavigationController._();

  final ValueNotifier<String?> pendingDeepLink = ValueNotifier<String?>(null);

  void openDeepLink(String deepLink) {
    pendingDeepLink.value = deepLink;
  }

  void clear() {
    pendingDeepLink.value = null;
  }
}
