import 'package:flutter/material.dart';

import '../config.dart';
import '../services/storage_service.dart';

class PortalSelectorScreen extends StatelessWidget {
  final VoidCallback onSelected;

  const PortalSelectorScreen({super.key, required this.onSelected});

  Future<void> _choose(String type) async {
    await StorageService.instance.setPortalType(type);
    AppConfig.portalType = type;
    onSelected();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/icons/coastal_logo_resized.png',
                  width: 220,
                ),
                const SizedBox(height: 48),
                const Text(
                  'Welcome! Select your portal:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.home),
                    label: const Text('Resident Portal'),
                    onPressed: () => _choose('resident'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.business),
                    label: const Text('Owner Portal'),
                    onPressed: () => _choose('owner'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
