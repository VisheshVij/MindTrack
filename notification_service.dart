import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {}

class NotificationService {
  static final NotificationService _instance =
      NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse r) {
        debugPrint('Notification tapped: ${r.payload}');
      },
      onDidReceiveBackgroundNotificationResponse:
          notificationTapBackground,
    );
  }

  Future<void> showHighPriority({
    required String title,
    required String body,
  }) {
    return _plugin.show(
      0,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_priority',
          'Safety Alerts',
          importance: Importance.max,
          priority: Priority.high,
          fullScreenIntent: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
    );
  }

  Future<void> showMedicationReminder(String medicineName) {
    return _plugin.show(
      1,
      'Time for your medicine',
      'Please take your $medicineName now.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medication',
          'Medication Reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
    );
  }

  Future<void> showPatientReminder(String message) {
    return _plugin.show(
      2,
      'Remember',
      message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'general',
          'General Info',
          importance: Importance.defaultImportance,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
    );
  }

  Future<void> showInfo(String message) {
    return _plugin.show(
      3,
      'Update',
      message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'general',
          'General Info',
          importance: Importance.low,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
    );
  }
}