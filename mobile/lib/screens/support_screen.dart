import 'dart:io';

import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config.dart';
import '../services/app_nav_service.dart';
import '../services/portal_controller.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _review = InAppReview.instance;

  Future<void> _launch(String uri) async {
    await launchUrl(Uri.parse(uri), mode: LaunchMode.externalApplication);
  }

  Future<void> _sendFeedback() async {
    final subject = Uri.encodeComponent('Resident Portal App Feedback');
    final body = Uri.encodeComponent(
      'Please describe the issue or suggestion:\n\n'
      'Device: ${Platform.operatingSystem}\n'
      'App: Resident Portal Mobile\n',
    );
    await _launch('mailto:${AppConfig.feedbackEmail}?subject=$subject&body=$body');
  }

  Future<void> _rateApp() async {
    final available = await _review.isAvailable();
    if (available) {
      await _review.requestReview();
      return;
    }

    if (AppConfig.iosAppStoreId.isNotEmpty) {
      await _review.openStoreListing(appStoreId: AppConfig.iosAppStoreId);
    }
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
        ElevatedButton(
          onPressed: _sendFeedback,
          child: const Text('Send App Feedback'),
        ),
        ElevatedButton(
          onPressed: _rateApp,
          child: const Text('Rate This App'),
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
