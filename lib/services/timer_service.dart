import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/morning_task.dart';
import '../models/app_settings.dart';
import 'audio_service.dart';

class TimerService extends ChangeNotifier {
  static final TimerService _instance = TimerService._internal();
  factory TimerService() => _instance;
  TimerService._internal();

  Timer? _timer;
  final Set<String> _alertedTasks = {};
  final Set<String> _startedTasks = {};
  DateTime? _departureAlertStartTime;
  bool _departureAlertMuted = false;
  
  // Callbacks to get current state
  List<MorningTask> Function()? _getTasks;
  Map<String, bool> Function()? _getCompletions;
  AppSettings Function()? _getSettings;

  void startMonitoring({
    required List<MorningTask> Function() getTasks,
    required Map<String, bool> Function() getCompletions,
    required AppSettings Function() getSettings,
    Function(String)? onTaskTimeoutComplete,
  }) {
    // Cancel existing timer
    _timer?.cancel();

    // Store callbacks
    _getTasks = getTasks;
    _getCompletions = getCompletions;
    _getSettings = getSettings;
    
    // Update AudioService vibrate setting
    AudioService().setVibrateEnabled(getSettings().vibrateEnabled);

    // Reset alerts daily
    _resetAlertsIfNewDay();

    // Start new timer that checks every 10 seconds
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      final tasks = _getTasks!();
      final completions = _getCompletions!();
      final settings = _getSettings!();
      
      _checkTaskStarts(tasks, completions, settings);
      _checkTaskTimeouts(tasks, completions, settings);
      _checkDepartureTime(settings);
    });
  }

  void _resetAlertsIfNewDay() {
    final now = DateTime.now();
    final lastReset = _lastResetDate;
    
    if (lastReset == null || 
        now.day != lastReset.day || 
        now.month != lastReset.month || 
        now.year != lastReset.year) {
      _alertedTasks.clear();
      _startedTasks.clear();
      _departureAlertMuted = false;
      _departureAlertStartTime = null;
      _lastResetDate = now;
    }
  }

  DateTime? _lastResetDate;

  void _checkTaskStarts(
    List<MorningTask> tasks,
    Map<String, bool> completions,
    AppSettings settings,
  ) {
    // DISABLED: Now using OS-level notification scheduling
    // This function is kept for reference but does not play sounds anymore
    /* 
    if (!settings.soundsEnabled) return;

    final now = DateTime.now();

    // Find the CURRENT uncompleted task (not all tasks)
    try {
      final currentTask = tasks.firstWhere((task) => completions[task.id] != true);
      
      // Skip if already started playing sound for this task
      if (_startedTasks.contains(currentTask.id)) {
        return;
      }

      final taskStartTime = currentTask.getScheduledDateTime(now);
      final taskEndTime = taskStartTime.add(Duration(seconds: currentTask.durationSeconds));

      // Check if task has started (now is between start and end time)
      final isAfterStart = now.isAfter(taskStartTime) || now.isAtSameMomentAs(taskStartTime);
      final isBeforeEnd = now.isBefore(taskEndTime);
      
      if (isAfterStart && isBeforeEnd) {
        _startedTasks.add(currentTask.id);
        debugPrint('🔊 TASK START: ${currentTask.title} at ${now.hour}:${now.minute}:${now.second} (scheduled: ${taskStartTime.hour}:${taskStartTime.minute})');
        _playTaskStartSound();
      }
    } catch (e) {
      // No uncompleted tasks
      return;
    }
    */
  }

  void _checkTaskTimeouts(
    List<MorningTask> tasks,
    Map<String, bool> completions,
    AppSettings settings,
  ) {
    // DISABLED: Now using OS-level notification scheduling
    // This function is kept for reference but does not play sounds anymore
    /*
    if (!settings.soundsEnabled) {
      debugPrint('⏭️ Skipping timeout check: sounds disabled');
      return;
    }

    final now = DateTime.now();
    debugPrint('⏰ Checking timeouts at ${now.hour}:${now.minute}:${now.second}');

    // Find the CURRENT uncompleted task (not all tasks)
    try {
      final currentTask = tasks.firstWhere((task) => completions[task.id] != true);
      
      // Skip if already alerted for this task
      if (_alertedTasks.contains(currentTask.id)) {
        debugPrint('  ⏭️ ${currentTask.title}: already alerted, skipping');
        return;
      }

      final taskStartTime = currentTask.getScheduledDateTime(now);
      final taskEndTime = taskStartTime.add(Duration(seconds: currentTask.durationSeconds));

      debugPrint('  📋 Current task: ${currentTask.title}');
      debugPrint('  📋 Start: ${taskStartTime.hour}:${taskStartTime.minute}:${taskStartTime.second}');
      debugPrint('  📋 End: ${taskEndTime.hour}:${taskEndTime.minute}:${taskEndTime.second}');
      debugPrint('  📋 Now: ${now.hour}:${now.minute}:${now.second}');

      // Check if current time is past task end time
      if (now.isAfter(taskEndTime) || now.isAtSameMomentAs(taskEndTime)) {
        // Mark as alerted to prevent multiple sound starts
        _alertedTasks.add(currentTask.id);
        debugPrint('🔊 TIMEOUT: ${currentTask.title} ended at ${taskEndTime.hour}:${taskEndTime.minute}:${taskEndTime.second}');
        // Play the alert (it will handle the completion callback)
        _playTaskTimeoutAlert(currentTask.id);
      }
    } catch (e) {
      // No uncompleted tasks
      debugPrint('  ⏭️ No current task');
      return;
    }
    */
  }

  void _checkDepartureTime(AppSettings settings) {
    // DISABLED: Now using OS-level notification scheduling
    // This function is kept for reference but does not play sounds anymore
    /*
    if (!settings.soundsEnabled) return;

    final now = DateTime.now();
    final departureTime = DateTime(
      now.year,
      now.month,
      now.day,
      settings.departureHour,
      settings.departureMinute,
    );

    // Check if it's time to leave (within 2 minute window - before and after)
    final difference = now.difference(departureTime);
    if (difference.inSeconds >= -60 && difference.inSeconds <= 120) {
      if (!_departureAlertShown && !_departureAlertMuted) {
        _departureAlertShown = true;
        _departureAlertStartTime = now;
        debugPrint('🔊 PLAYING DEPARTURE ALERT at ${now.hour}:${now.minute}:${now.second} (departure time: ${departureTime.hour}:${departureTime.minute})');
        // Play alert only once when alert starts
        _playDepartureAlert();
      }
    }
    */
  }

  void taskCompleted(String taskId) {
    // Only remove from started tasks when manually completed
    // Keep in alerted tasks so timeout sound doesn't re-trigger
    _startedTasks.remove(taskId);
  }

  // Getters for departure alert state
  DateTime? get departureAlertStartTime => _departureAlertStartTime;
  bool get isDepartureAlertMuted => _departureAlertMuted;
  bool get canMuteDepartureAlert {
    // Can mute immediately when departure alert has started
    return _departureAlertStartTime != null;
  }

  void muteDepartureAlert() {
    if (canMuteDepartureAlert) {
      _departureAlertMuted = true;
      AudioService().stop(); // Stop currently playing sound
      notifyListeners();
      debugPrint('Departure alert muted');
    }
  }

  void unmuteDepartureAlert() {
    _departureAlertMuted = false;
    notifyListeners();
    print('Departure alert unmuted');
  }

  void stopMonitoring() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    stopMonitoring();
    super.dispose();
  }
}
