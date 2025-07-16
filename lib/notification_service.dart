import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'models/lecture.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Initialize timezones
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Karachi'));

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
    InitializationSettings(android: androidSettings);

    await _notifications.initialize(initSettings);

    // ✅ Request notification permission (Android 13+)
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    print('✅ Notification system initialized');
  }

  static Future<void> scheduleLectureNotification(Lecture lecture) async {
    final TimeOfDay time = lecture.startTime;
    final now = tz.TZDateTime.now(tz.local);

    final dayMapping = {
      'Monday': DateTime.monday,
      'Tuesday': DateTime.tuesday,
      'Wednesday': DateTime.wednesday,
      'Thursday': DateTime.thursday,
      'Friday': DateTime.friday,
      'Saturday': DateTime.saturday,
    };

    final lectureWeekday = dayMapping[lecture.day]!;

    final scheduledDate = _nextInstanceOfWeekdayAndTime(
      weekday: lectureWeekday,
      hour: time.hour,
      minute: time.minute,
    );

    final int notificationId = _generateId(lecture); // 👇 ID based on subject+day

    print('📅 Scheduling notification for ${lecture.subject}');
    print('🕒 Scheduled at: $scheduledDate');

    await _notifications.zonedSchedule(
      notificationId,
      'Lecture Reminder',
      '${lecture.subject}lecture is starting now!',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'lecture_channel_v2',
          'Lecture Notifications',
          channelDescription: 'Reminds you when a lecture starts',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime, // weekly
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static tz.TZDateTime _nextInstanceOfWeekdayAndTime({
    required int weekday,
    required int hour,
    required int minute,
  }) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
    tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    while (scheduledDate.weekday != weekday || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  // ✅ Show a test notification manually
  static Future<void> showTestNotification() async {
    print('🔔 Showing test notification...');
    await _notifications.show(
      999,
      'Test Notification',
      'This is a test notification.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Channel',
          channelDescription: 'Used for testing notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  // ✅ Cancel a notification by ID
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    print('❌ Notification with ID $id cancelled');
  }

  // ✅ Cancel all scheduled notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    print('❌ All notifications cancelled');
  }

  // ✅ List all pending notifications
  static Future<void> listPendingNotifications() async {
    final pending = await _notifications.pendingNotificationRequests();
    print('📋 Pending Notifications: ${pending.length}');
    for (final p in pending) {
      print('📝 [ID: ${p.id}] ${p.title}: ${p.body}');
    }
  }

  // ✅ Generate a unique ID using day + subject hash
  static int _generateId(Lecture lecture) {
    final String key = '${lecture.day}_${lecture.subject}';
    return key.hashCode & 0x7FFFFFFF; // Ensure positive int
  }
}
