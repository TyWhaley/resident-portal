import 'dart:convert';

class NotificationPrefs {
  final bool notificationsEnabled;
  final int dueDay;
  final bool remindDaysBefore;
  final bool remindOnDueDay;
  final bool remindDaysAfter;
  final int quietStartHour;
  final int quietEndHour;
  final bool maintenanceUpdates;
  final bool paymentReceipts;
  final bool generalAnnouncements;

  const NotificationPrefs({
    required this.notificationsEnabled,
    required this.dueDay,
    required this.remindDaysBefore,
    required this.remindOnDueDay,
    required this.remindDaysAfter,
    required this.quietStartHour,
    required this.quietEndHour,
    required this.maintenanceUpdates,
    required this.paymentReceipts,
    required this.generalAnnouncements,
  });

  factory NotificationPrefs.defaults() => const NotificationPrefs(
        notificationsEnabled: false,
        dueDay: 1,
        remindDaysBefore: true,
        remindOnDueDay: true,
        remindDaysAfter: false,
        quietStartHour: 22,
        quietEndHour: 8,
        maintenanceUpdates: true,
        paymentReceipts: true,
        generalAnnouncements: true,
      );

  NotificationPrefs copyWith({
    bool? notificationsEnabled,
    int? dueDay,
    bool? remindDaysBefore,
    bool? remindOnDueDay,
    bool? remindDaysAfter,
    int? quietStartHour,
    int? quietEndHour,
    bool? maintenanceUpdates,
    bool? paymentReceipts,
    bool? generalAnnouncements,
  }) {
    return NotificationPrefs(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dueDay: dueDay ?? this.dueDay,
      remindDaysBefore: remindDaysBefore ?? this.remindDaysBefore,
      remindOnDueDay: remindOnDueDay ?? this.remindOnDueDay,
      remindDaysAfter: remindDaysAfter ?? this.remindDaysAfter,
      quietStartHour: quietStartHour ?? this.quietStartHour,
      quietEndHour: quietEndHour ?? this.quietEndHour,
      maintenanceUpdates: maintenanceUpdates ?? this.maintenanceUpdates,
      paymentReceipts: paymentReceipts ?? this.paymentReceipts,
      generalAnnouncements: generalAnnouncements ?? this.generalAnnouncements,
    );
  }

  Map<String, dynamic> toMap() => {
        'notificationsEnabled': notificationsEnabled,
        'dueDay': dueDay,
        'remindDaysBefore': remindDaysBefore,
        'remindOnDueDay': remindOnDueDay,
        'remindDaysAfter': remindDaysAfter,
        'quietStartHour': quietStartHour,
        'quietEndHour': quietEndHour,
        'maintenanceUpdates': maintenanceUpdates,
        'paymentReceipts': paymentReceipts,
        'generalAnnouncements': generalAnnouncements,
      };

  factory NotificationPrefs.fromMap(Map<String, dynamic> map) => NotificationPrefs(
        notificationsEnabled: map['notificationsEnabled'] as bool? ?? false,
        dueDay: map['dueDay'] as int? ?? 1,
        remindDaysBefore: map['remindDaysBefore'] as bool? ?? true,
        remindOnDueDay: map['remindOnDueDay'] as bool? ?? true,
        remindDaysAfter: map['remindDaysAfter'] as bool? ?? false,
        quietStartHour: map['quietStartHour'] as int? ?? 22,
        quietEndHour: map['quietEndHour'] as int? ?? 8,
        maintenanceUpdates: map['maintenanceUpdates'] as bool? ?? true,
        paymentReceipts: map['paymentReceipts'] as bool? ?? true,
        generalAnnouncements: map['generalAnnouncements'] as bool? ?? true,
      );

  String toJson() => jsonEncode(toMap());

  factory NotificationPrefs.fromJson(String source) {
    final decoded = jsonDecode(source) as Map<String, dynamic>;
    return NotificationPrefs.fromMap(decoded);
  }
}
