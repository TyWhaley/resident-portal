import 'package:flutter/foundation.dart';

class AppNavService {
  AppNavService._();
  static final instance = AppNavService._();

  final ValueNotifier<int> selectedTab = ValueNotifier<int>(0);

  void openPortalTab() {
    selectedTab.value = 0;
  }
}
