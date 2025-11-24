import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class NotificationScheduler {
  static final NotificationScheduler _instance = NotificationScheduler._internal();
  factory NotificationScheduler() => _instance;
  NotificationScheduler._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);
    _initialized = true;
    debugPrint('✅ NotificationScheduler initialized');
  }

  /// Generate deterministic ID from string (instead of hashCode)
  /// Currently unused but available for future migration from hashCode-based IDs
  // ignore: unused_element
  int _idFromString(String key) {
    final bytes = utf8.encode(key);
    final digest = md5.convert(bytes);
    // Take first 4 bytes and convert to int32
    return (digest.bytes[0] << 24) |
           (digest.bytes[1] << 16) |
           (digest.bytes[2] << 8) |
           digest.bytes[3];
  }

  Future<void> scheduleSound({
    required int id,
    required DateTime time,
    required String soundFile,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    // Skip if time is in the past
    if (time.isBefore(DateTime.now())) {
      debugPrint('⏭️ Skipping past time: $title at $time');
      return;
    }

    final scheduledTime = tz.TZDateTime.from(time, tz.local);
    
    debugPrint('📅 Scheduling: $title at ${scheduledTime.toString()}');
    debugPrint('   Sound: $soundFile, ID: $id');

    // Schedule notification - repeats handled by TaskSoundScheduler + AudioService
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'morning_routine',
          'Morning Routine Sounds',
          channelDescription: 'Plays sounds for morning routine tasks',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          sound: RawResourceAndroidNotificationSound(
            soundFile.replaceAll('.mp3', ''),
          ),
          visibility: NotificationVisibility.secret,
          showWhen: false,
        ),
        iOS: DarwinNotificationDetails(
          sound: soundFile,
          presentAlert: false,
          presentBadge: false,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  Future<void> cancelAllScheduledSounds() async {
    await _plugin.cancelAll();
    debugPrint('🗑️ Cancelled all scheduled sounds');
  }

  Future<void> cancelSound(int id) async {
    await _plugin.cancel(id);
    debugPrint('🗑️ Cancelled sound ID: $id');
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _plugin.pendingNotificationRequests();
  }
}
