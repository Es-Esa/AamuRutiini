import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../models/morning_task.dart';
import 'tts_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    // Initialize timezones
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Helsinki'));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) async {
    // Handle notification tap
    // Speak the notification payload if available
    if (response.payload != null && response.payload!.isNotEmpty) {
      await TtsService().speak(response.payload!);
    }
  }

  Future<bool> requestPermissions() async {
    final android = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }

    final ios = _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    
    if (ios != null) {
      return await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      ) ?? false;
    }

    return false;
  }

  Future<void> scheduleTaskNotification({
    required MorningTask task,
    required DateTime scheduledDate,
    bool useTts = false,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'morning_tasks',
      'Aamurutiinit',
      channelDescription: 'Muistutukset aamun tehtävistä',
      importance: Importance.max,
      priority: Priority.high,
      visibility: NotificationVisibility.public,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);
    final ttsMessage = 'Aika tehdä: ${task.title}';

    await _notifications.zonedSchedule(
      task.id.hashCode,
      'Aika tehdä: ${task.title}',
      task.description ?? 'Tee tämä tehtävä nyt',
      tzScheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: useTts ? ttsMessage : null,
    );
  }

  Future<void> scheduleAllTasks(
    List<MorningTask> tasks,
    DateTime date, {
    bool useTts = false,
  }) async {
    // Cancel existing notifications
    await cancelAllNotifications();

    // Schedule new ones
    for (final task in tasks) {
      final scheduledDate = task.getScheduledDateTime(date);
      
      // Only schedule future notifications
      if (scheduledDate.isAfter(DateTime.now())) {
        await scheduleTaskNotification(
          task: task,
          scheduledDate: scheduledDate,
          useTts: useTts,
        );
      }
    }
  }

  Future<void> cancelNotification(String taskId) async {
    await _notifications.cancel(taskId.hashCode);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // Immediate notification for testing or urgent reminders
  Future<void> showImmediateNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'immediate',
      'Välittömät ilmoitukset',
      channelDescription: 'Välittömät muistutukset',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      notificationDetails,
    );
  }
}
