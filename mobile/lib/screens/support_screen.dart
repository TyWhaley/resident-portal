import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config.dart';
import '../services/app_nav_service.dart';
import '../services/portal_controller.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  Future<void> _launch(String uri) async {
    await launchUrl(Uri.parse(uri), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Support', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => _launch('tel:${AppConfig.supportPhone}'),
          child: const Text('Call Office'),
        ),
        ElevatedButton(
          onPressed: () => _launch('mailto:${AppConfig.supportEmail}'),
          child: const Text('Email Office'),
        ),
        if (AppConfig.supportSms.isNotEmpty)
          ElevatedButton(
            onPressed: () => _launch('sms:${AppConfig.supportSms}'),
            child: const Text('Text Office'),
          ),
        if (AppConfig.supportSms.isEmpty)
          const ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('SMS support'),
            subtitle: Text('Not available yet. We can add this once a number is ready.'),
          ),
        const Divider(height: 24),
        ListTile(
          title: const Text('Open portal messages'),
          onTap: () {
            AppNavService.instance.openPortalTab();
            PortalNavigationController.instance.openDeepLink('app://messages');
          },
        ),
        const ListTile(
          title: Text('FAQ: How do I pay rent?'),
          subtitle: Text('Go to Portal tab and choose Payments.'),
        ),
        const ListTile(
          title: Text('FAQ: How do I submit maintenance?'),
          subtitle: Text('Use app://maintenance/new or Portal > Maintenance.'),
        ),
        const SizedBox(height: 12),
        const Text(
          'Privacy policy placeholder: This app stores minimal preferences, installation ID, and link status only.',
        ),
      ],
    );
  }
}
