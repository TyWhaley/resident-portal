import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/notification_prefs.dart';

class LocalNotificationService {
  LocalNotificationService._();
  static final instance = LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );
  }

  Future<bool> requestPermission() async {
    if (Platform.isIOS) {
      return await _plugin
              .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    }
    if (Platform.isAndroid) {
      return await _plugin
              .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
              ?.requestNotificationsPermission() ??
          false;
    }
    return false;
  }

  Future<void> rescheduleRentReminders(NotificationPrefs prefs) async {
    await _plugin.cancelAll();
    if (!prefs.notificationsEnabled) {
      return;
    }

    final offsets = <int>[];
    if (prefs.remindDaysBefore) offsets.add(-3);
    if (prefs.remindOnDueDay) offsets.add(0);
    if (prefs.remindDaysAfter) offsets.add(3);

    final now = DateTime.now();
    int idCounter = 1000;

    for (int monthOffset = 0; monthOffset < 6; monthOffset++) {
      final monthDate = DateTime(now.year, now.month + monthOffset, 1);
      final dueDate = DateTime(
        monthDate.year,
        monthDate.month,
        prefs.dueDay.clamp(1, DateTime(monthDate.year, monthDate.month + 1, 0).day),
      );

      for (final offset in offsets) {
        final target = dueDate.add(Duration(days: offset));
        final scheduled = DateTime(
          target.year,
          target.month,
          target.day,
          _preferredNotificationHour(prefs),
          0,
        );

        if (scheduled.isAfter(now)) {
          await _plugin.zonedSchedule(
            id: idCounter,
            title: 'Rent reminder',
            body: offset == 0
                ? 'Your rent is due today.'
                : offset < 0
                    ? 'Rent is due in ${offset.abs()} days.'
                    : 'Your rent was due ${offset.abs()} days ago.',
            scheduledDate: tz.TZDateTime.from(scheduled, tz.local),
            notificationDetails: const NotificationDetails(
              android: AndroidNotificationDetails(
                'rent_reminders',
                'Rent Reminders',
                channelDescription: 'Scheduled resident rent reminders',
                importance: Importance.high,
                priority: Priority.high,
              ),
              iOS: DarwinNotificationDetails(),
            ),
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          );
          idCounter += 1;
        }
      }
    }
  }

  int _preferredNotificationHour(NotificationPrefs prefs) {
    if (prefs.quietStartHour <= prefs.quietEndHour) {
      return prefs.quietEndHour;
    }
    if (9 >= prefs.quietEndHour && 9 < prefs.quietStartHour) {
      return 9;
    }
    return prefs.quietEndHour;
  }
}
