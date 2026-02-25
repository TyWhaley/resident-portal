import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'config.dart';
import 'screens/notifications_screen.dart';
import 'screens/portal_screen.dart';
import 'screens/portal_selector_screen.dart';
import 'screens/support_screen.dart';
import 'services/app_nav_service.dart';
import 'services/biometric_auth_service.dart';
import 'services/local_notification_service.dart';
import 'services/portal_controller.dart';
import 'services/push_service.dart';
import 'services/review_prompt_service.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load saved portal type before building UI.
  final savedType = await StorageService.instance.getPortalType();
  if (savedType != null) {
    AppConfig.portalType = savedType;
  }

  runApp(ResidentPortalApp(needsPortalSelection: savedType == null));
  unawaited(_bootstrapServices());
}

Future<void> _bootstrapServices() async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}

  try {
    await LocalNotificationService.instance.init();
  } catch (_) {}

  try {
    await PushService.instance.initialize((deepLink) {
      AppNavService.instance.openPortalTab();
      PortalNavigationController.instance.openDeepLink(deepLink);
    });
  } catch (_) {}

  try {
    final appLinks = AppLinks();
    appLinks.uriLinkStream.listen((uri) {
      if (uri.scheme == 'app') {
        AppNavService.instance.openPortalTab();
        PortalNavigationController.instance.openDeepLink(uri.toString());
      }
    });
  } catch (_) {}
}

class ResidentPortalApp extends StatelessWidget {
  final bool needsPortalSelection;

  const ResidentPortalApp({super.key, this.needsPortalSelection = false});

  @override
  Widget build(BuildContext context) {
    const brandBlue = Color(0xFF0072BC);

    return MaterialApp(
      title: 'Coastal Realty Portal',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: brandBlue,
          brightness: Brightness.light,
        ),
        navigationBarTheme: const NavigationBarThemeData(
          indicatorColor: Color(0xFFD6E8F7),
        ),
      ),
      home: needsPortalSelection
          ? _PortalSelectionWrapper()
          : const HomeTabs(),
    );
  }
}

class _PortalSelectionWrapper extends StatefulWidget {
  @override
  State<_PortalSelectionWrapper> createState() =>
      _PortalSelectionWrapperState();
}

class _PortalSelectionWrapperState extends State<_PortalSelectionWrapper> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    if (_selected) return const HomeTabs();
    return PortalSelectorScreen(
      onSelected: () => setState(() => _selected = true),
    );
  }
}

class HomeTabs extends StatefulWidget {
  const HomeTabs({super.key});

  @override
  State<HomeTabs> createState() => _HomeTabsState();
}

class _HomeTabsState extends State<HomeTabs> with WidgetsBindingObserver {
  bool _locked = false;
  bool _authInProgress = false;
  bool _sessionUnlocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_refreshLockState());
      unawaited(ReviewPromptService.instance.checkAndPromptIfEligible());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _sessionUnlocked = false;
    }
    if (state == AppLifecycleState.resumed) {
      if (!_authInProgress) {
        unawaited(_refreshLockState());
      }
    }
  }

  Future<bool> _shouldRequireUnlock() async {
    if (AppConfig.disableBiometricLock) return false;
    try {
      return await StorageService.instance.getBiometricUnlockEnabled();
    } catch (_) {
      return false;
    }
  }

  Future<void> _enforceBiometricUnlock() async {
    if (_authInProgress || !mounted) return;
    if (!await _shouldRequireUnlock()) return;

    setState(() => _locked = true);
    _authInProgress = true;
    final unlocked = await BiometricAuthService.instance.authenticateForAppUnlock();
    _authInProgress = false;

    if (mounted && unlocked) {
      _sessionUnlocked = true;
      setState(() => _locked = false);
    }
  }

  Future<void> _refreshLockState() async {
    if (!mounted) return;
    final shouldLock = await _shouldRequireUnlock();
    if (!mounted) return;
    setState(() => _locked = shouldLock && !_sessionUnlocked);
  }

  @override
  Widget build(BuildContext context) {
    const pages = [PortalScreen(), NotificationsScreen(), SupportScreen()];

    return ValueListenableBuilder<int>(
      valueListenable: AppNavService.instance.selectedTab,
      builder: (context, index, _) {
        return Scaffold(
          body: SafeArea(
            child: _locked
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lock, size: 48),
                        const SizedBox(height: 12),
                        const Text('App is locked'),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _enforceBiometricUnlock,
                          child: const Text('Unlock with biometrics'),
                        ),
                      ],
                    ),
                  )
                : pages[index],
          ),
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
