import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'screens/notifications_screen.dart';
import 'screens/portal_screen.dart';
import 'screens/support_screen.dart';
import 'services/app_nav_service.dart';
import 'services/local_notification_service.dart';
import 'services/portal_controller.dart';
import 'services/push_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await LocalNotificationService.instance.init();
  await PushService.instance.initialize((deepLink) {
    AppNavService.instance.openPortalTab();
    PortalNavigationController.instance.openDeepLink(deepLink);
  });

  final appLinks = AppLinks();
  appLinks.uriLinkStream.listen((uri) {
    if (uri.scheme == 'app') {
      AppNavService.instance.openPortalTab();
      PortalNavigationController.instance.openDeepLink(uri.toString());
    }
  });

  runApp(const ResidentPortalApp());
}

class ResidentPortalApp extends StatelessWidget {
  const ResidentPortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Resident Portal',
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const HomeTabs(),
    );
  }
}

class HomeTabs extends StatefulWidget {
  const HomeTabs({super.key});

  @override
  State<HomeTabs> createState() => _HomeTabsState();
}

class _HomeTabsState extends State<HomeTabs> {
  @override
  Widget build(BuildContext context) {
    final pages = const [PortalScreen(), NotificationsScreen(), SupportScreen()];

    return ValueListenableBuilder<int>(
      valueListenable: AppNavService.instance.selectedTab,
      builder: (context, index, _) {
        return Scaffold(
          body: SafeArea(child: pages[index]),
          bottomNavigationBar: NavigationBar(
            selectedIndex: index,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.language), label: 'Portal'),
              NavigationDestination(icon: Icon(Icons.notifications), label: 'Notifications'),
              NavigationDestination(icon: Icon(Icons.support_agent), label: 'Support'),
            ],
            onDestinationSelected: (next) {
              AppNavService.instance.selectedTab.value = next;
            },
          ),
        );
      },
    );
  }
}
