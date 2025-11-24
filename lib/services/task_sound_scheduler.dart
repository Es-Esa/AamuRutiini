import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/morning_task.dart';
import '../models/app_settings.dart';
import 'notification_scheduler.dart';
import 'audio_service.dart';

class TaskSoundScheduler {
  static final TaskSoundScheduler _instance = TaskSoundScheduler._internal();
  factory TaskSoundScheduler() => _instance;
  TaskSoundScheduler._internal();

  final _scheduler = NotificationScheduler();
  final List<Timer> _activeTimers = [];

  /// Schedule all sounds for all tasks
  Future<void> scheduleAllTaskSounds({
    required List<MorningTask> tasks,
    required AppSettings settings,
  }) async {
    try {
      debugPrint('🔔 Scheduling sounds for ${tasks.length} tasks');
      
      // Cancel all previous timers
      for (final timer in _activeTimers) {
        timer.cancel();
      }
      _activeTimers.clear();
      debugPrint('🗑️ Cancelled ${_activeTimers.length} old timers');
      
      // Cancel all previous schedules
      try {
        await _scheduler.cancelAllScheduledSounds();
      } catch (e) {
        debugPrint('⚠️ Error canceling previous schedules: $e');
        // Continue anyway
      }

      if (!settings.soundsEnabled) {
        debugPrint('⏭️ Sounds disabled, skipping scheduling');
        return;
      }

      final now = DateTime.now();
      
      // Schedule sounds for each task
      for (final task in tasks) {
        try {
          await _scheduleTaskSounds(task, now, settings);
        } catch (e) {
          debugPrint('❌ Error scheduling sounds for task ${task.title}: $e');
        }
      }

      // Schedule departure alert
      try {
        await _scheduleDepartureSound(settings, now);
      } catch (e) {
        debugPrint('❌ Error scheduling departure sound: $e');
      }

      // Debug: Show all pending notifications
      try {
        final pending = await _scheduler.getPendingNotifications();
        debugPrint('📋 Total scheduled sounds: ${pending.length}');
        for (final notif in pending) {
          debugPrint('   - ID ${notif.id}: ${notif.title}');
        }
      } catch (e) {
        debugPrint('⚠️ Could not get pending notifications: $e');
      }
    } catch (e) {
      debugPrint('❌ Critical error in scheduleAllTaskSounds: $e');
    }
  }

  Future<void> _scheduleTaskSounds(MorningTask task, DateTime now, AppSettings settings) async {
    var taskStartTime = task.getScheduledDateTime(now);
    
    // If task start time has passed today, schedule for tomorrow
    if (taskStartTime.isBefore(now) || taskStartTime.isAtSameMomentAs(now)) {
      taskStartTime = taskStartTime.add(const Duration(days: 1));
    }
    
    final taskEndTime = taskStartTime.add(Duration(seconds: task.durationSeconds));
    
    debugPrint('🎯 Task: ${task.title}');
    debugPrint('   📋 Settings.taskTimeoutSound: ${settings.taskTimeoutSound}');
    debugPrint('   📋 Settings.departureSound: ${settings.departureSound}');

    // ===== START-ÄÄNI ===== (VAIN AUDIOSERVICE)
    if (taskStartTime.isAfter(now)) {
      _scheduleOneRepeat(
        startTime: taskStartTime,
        soundFile: 'start',
        delaySeconds: 0,
        debugLabel: 'Start (${task.title})',
      );
      debugPrint('   ✅ Start sound for ${task.title} at ${taskStartTime.year}-${taskStartTime.month}-${taskStartTime.day} ${taskStartTime.hour}:${taskStartTime.minute}');
    }

    // ===== TIMEOUT-ÄÄNI ===== (VAIN AUDIOSERVICE)
    if (task.durationSeconds > 0 && taskEndTime.isAfter(now)) {
      debugPrint('   🔧 Scheduling timeout with sound: ${settings.taskTimeoutSound}');
      _scheduleOneRepeat(
        startTime: taskEndTime,
        soundFile: 'timeout',
        delaySeconds: 0,
        debugLabel: 'Timeout (${task.title})',
        taskTimeoutSound: settings.taskTimeoutSound,
      );
      debugPrint('   ✅ Timeout sound for ${task.title} at ${taskEndTime.year}-${taskEndTime.month}-${taskEndTime.day} ${taskEndTime.hour}:${taskEndTime.minute}');
    }
  }

  void _scheduleOneRepeat({
    required DateTime startTime,
    required String soundFile,
    required int delaySeconds,
    required String debugLabel,
    String? taskTimeoutSound,
    String? departureSound,
  }) {
    final targetTime = startTime.add(Duration(seconds: delaySeconds));
    final delay = targetTime.difference(DateTime.now());
    
    if (delay.isNegative) {
      debugPrint('   ⏭️ Skip repeat (already passed)');
      return;
    }
    
    debugPrint('   🔔 Repeat at ${targetTime.hour}:${targetTime.minute}:${targetTime.second} (delay: ${delay.inSeconds}s)');
    debugPrint('   🎵 Sound parameters: soundFile=$soundFile, taskTimeoutSound=$taskTimeoutSound, departureSound=$departureSound');
    
    final timer = Timer(delay, () async {
      debugPrint('▶️ Playing repeat for $debugLabel');
      debugPrint('   📞 Calling playSoundByName($soundFile, taskTimeoutSound: $taskTimeoutSound, departureSound: $departureSound)');
      try {
        await AudioService().playSoundByName(
          soundFile,
          taskTimeoutSound: taskTimeoutSound,
          departureSound: departureSound,
        );
      } catch (e) {
        debugPrint('❌ Error playing sound: $e');
      }
    });
    
    _activeTimers.add(timer);
  }

  Future<void> _scheduleDepartureSound(AppSettings settings, DateTime now) async {
    var departureTime = DateTime(
      now.year,
      now.month,
      now.day,
      settings.departureHour,
      settings.departureMinute,
    );

    // If departure time has passed today, schedule for tomorrow
    if (departureTime.isBefore(now) || departureTime.isAtSameMomentAs(now)) {
      departureTime = departureTime.add(const Duration(days: 1));
    }

    // VAIN AUDIOSERVICE (käyttää oikeaa ääntä asetuksista)
    _scheduleOneRepeat(
      startTime: departureTime,
      soundFile: 'departure',
      delaySeconds: 0,
      debugLabel: 'Departure',
      departureSound: settings.departureSound,
    );
    debugPrint('   ✅ Departure sound at ${departureTime.year}-${departureTime.month}-${departureTime.day} ${departureTime.hour}:${departureTime.minute}');
  }

  /// Cancel all scheduled sounds
  Future<void> cancelAll() async {
    await _scheduler.cancelAllScheduledSounds();
  }
}
