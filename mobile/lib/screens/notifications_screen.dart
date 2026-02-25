import 'package:flutter/material.dart';

import '../models/notification_prefs.dart';
import '../services/biometric_auth_service.dart';
import '../services/local_notification_service.dart';
import '../services/push_service.dart';
import '../services/storage_service.dart';
import 'link_account_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  NotificationPrefs _prefs = NotificationPrefs.defaults();
  bool _loading = true;
  bool _biometricAvailable = false;
  bool _biometricUnlockEnabled = false;
  bool _biometricPaymentEnabled = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final loaded = await StorageService.instance.loadPrefs();
    final biometricAvailable = await BiometricAuthService.instance.isAvailable();
    final biometricUnlockEnabled = await StorageService.instance.getBiometricUnlockEnabled();
    final biometricPaymentEnabled = await StorageService.instance.getBiometricPaymentEnabled();
    if (loaded.notificationsEnabled) {
      await PushService.instance.registerForPushIfLinked();
    }
    setState(() {
      _prefs = loaded;
      _biometricAvailable = biometricAvailable;
      _biometricUnlockEnabled = biometricUnlockEnabled;
      _biometricPaymentEnabled = biometricPaymentEnabled;
      _loading = false;
    });
  }

  Future<void> _toggleBiometricUnlock(bool enabled) async {
    if (enabled && !_biometricAvailable) return;
    await StorageService.instance.setBiometricUnlockEnabled(enabled);
    setState(() => _biometricUnlockEnabled = enabled);
  }

  Future<void> _toggleBiometricPayment(bool enabled) async {
    if (enabled && !_biometricAvailable) return;
    await StorageService.instance.setBiometricPaymentEnabled(enabled);
    setState(() => _biometricPaymentEnabled = enabled);
  }

  Future<void> _update(NotificationPrefs updated) async {
    setState(() => _prefs = updated);
    await StorageService.instance.savePrefs(updated);
    await LocalNotificationService.instance.rescheduleRentReminders(updated);
    if (updated.notificationsEnabled) {
      await PushService.instance.registerForPushIfLinked();
    }
  }

  Future<void> _toggleNotifications(bool enabled) async {
    if (enabled) {
      final granted = await LocalNotificationService.instance.requestPermission();
      if (!granted) return;
    }
    await _update(_prefs.copyWith(notificationsEnabled: enabled));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final hours = List.generate(24, (i) => i);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SwitchListTile(
          title: const Text('Enable notifications'),
          value: _prefs.notificationsEnabled,
          onChanged: _toggleNotifications,
        ),
        SwitchListTile(
          title: const Text('Unlock app with biometrics'),
          subtitle: Text(_biometricAvailable ? 'Use Face ID / Touch ID on app open.' : 'Biometrics unavailable on this device.'),
          value: _biometricUnlockEnabled,
          onChanged: _biometricAvailable ? _toggleBiometricUnlock : null,
        ),
        SwitchListTile(
          title: const Text('Require biometrics for payments'),
          subtitle: Text(_biometricAvailable ? 'Prompt before payment actions in portal.' : 'Biometrics unavailable on this device.'),
          value: _biometricPaymentEnabled,
          onChanged: _biometricAvailable ? _toggleBiometricPayment : null,
        ),
        ListTile(
          title: const Text('Rent due day of month'),
          subtitle: Text('${_prefs.dueDay}'),
          trailing: DropdownButton<int>(
            value: _prefs.dueDay,
            items: List.generate(28, (i) => i + 1)
                .map((d) => DropdownMenuItem(value: d, child: Text('$d')))
                .toList(),
            onChanged: (value) {
              if (value != null) _update(_prefs.copyWith(dueDay: value));
            },
          ),
        ),
        SwitchListTile(
          title: const Text('3 days before due date'),
          value: _prefs.remindDaysBefore,
          onChanged: (v) => _update(_prefs.copyWith(remindDaysBefore: v)),
        ),
        SwitchListTile(
          title: const Text('Due day reminder'),
          value: _prefs.remindOnDueDay,
          onChanged: (v) => _update(_prefs.copyWith(remindOnDueDay: v)),
        ),
        SwitchListTile(
          title: const Text('3 days after due date'),
          value: _prefs.remindDaysAfter,
          onChanged: (v) => _update(_prefs.copyWith(remindDaysAfter: v)),
        ),
        ListTile(
          title: const Text('Quiet hours start'),
          trailing: DropdownButton<int>(
            value: _prefs.quietStartHour,
            items: hours
                .map((h) => DropdownMenuItem(value: h, child: Text('${h.toString().padLeft(2, '0')}:00')))
                .toList(),
            onChanged: (value) {
              if (value != null) _update(_prefs.copyWith(quietStartHour: value));
            },
          ),
        ),
        ListTile(
          title: const Text('Quiet hours end'),
          trailing: DropdownButton<int>(
            value: _prefs.quietEndHour,
            items: hours
                .map((h) => DropdownMenuItem(value: h, child: Text('${h.toString().padLeft(2, '0')}:00')))
                .toList(),
            onChanged: (value) {
              if (value != null) _update(_prefs.copyWith(quietEndHour: value));
            },
          ),
        ),
        SwitchListTile(
          title: const Text('Maintenance updates (push)'),
          value: _prefs.maintenanceUpdates,
          onChanged: (v) => _update(_prefs.copyWith(maintenanceUpdates: v)),
        ),
        SwitchListTile(
          title: const Text('Payment receipts (push)'),
          value: _prefs.paymentReceipts,
          onChanged: (v) => _update(_prefs.copyWith(paymentReceipts: v)),
        ),
        SwitchListTile(
          title: const Text('General announcements (push)'),
          value: _prefs.generalAnnouncements,
          onChanged: (v) => _update(_prefs.copyWith(generalAnnouncements: v)),
        ),
        const SizedBox(height: 16),
        const LinkAccountScreen(),
      ],
    );
  }
}
