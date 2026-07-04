import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

final FlutterLocalNotificationsPlugin flnp = FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  tz.initializeTimeZones();
  // Qurilmaning haqiqiy vaqt zonasi — aks holda eslatmalar UTC bo'yicha
  // (Toshkentda 5 soat kech) tushadi
  try {
    final tzName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzName.identifier));
  } catch (_) {
    tz.setLocalLocation(tz.getLocation('Asia/Tashkent'));
  }

  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const ios = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  await flnp.initialize(
    const InitializationSettings(android: android, iOS: ios),
  );
}

Future<bool> requestPermission() async {
  final android = flnp.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  if (android != null) {
    final granted = await android.requestNotificationsPermission();
    return granted ?? false;
  }
  final ios = flnp.resolvePlatformSpecificImplementation<
      IOSFlutterLocalNotificationsPlugin>();
  if (ios != null) {
    final granted = await ios.requestPermissions(alert: true, badge: true, sound: true);
    return granted ?? false;
  }
  return true;
}

const _androidDetails = AndroidNotificationDetails(
  'pulkam_reminder',
  'Eslatmalar',
  channelDescription: 'Kunlik xarajat eslatmalari',
  importance: Importance.high,
  priority: Priority.high,
);
const _notifDetails = NotificationDetails(
  android: _androidDetails,
  iOS: DarwinNotificationDetails(),
);

Future<void> scheduleDaily(int id, int hour, int minute, String title, String body) async {
  Future<void> qoy(AndroidScheduleMode mode) => flnp.zonedSchedule(
        id,
        title,
        body,
        _nextInstanceOf(hour, minute),
        _notifDetails,
        androidScheduleMode: mode,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

  try {
    await qoy(AndroidScheduleMode.exactAllowWhileIdle);
  } catch (_) {
    // Android 12+ da exact alarm ruxsati berilmagan bo'lsa —
    // taxminiy rejimda baribir ishlasin (bir necha daqiqa farq bilan)
    await qoy(AndroidScheduleMode.inexactAllowWhileIdle);
  }
}

Future<void> cancelNotification(int id) async {
  await flnp.cancel(id);
}

tz.TZDateTime _nextInstanceOf(int hour, int minute) {
  final now = tz.TZDateTime.now(tz.local);
  var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
  if (scheduled.isBefore(now)) {
    scheduled = scheduled.add(const Duration(days: 1));
  }
  return scheduled;
}
