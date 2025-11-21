import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/morning_task.dart';
import '../models/app_settings.dart';
import '../models/task_completion.dart';
import '../services/hive_service.dart';
import '../services/notification_service.dart';

// Tasks Provider
final tasksProvider = StateNotifierProvider<TasksNotifier, List<MorningTask>>((ref) {
  return TasksNotifier();
});

class TasksNotifier extends StateNotifier<List<MorningTask>> {
  TasksNotifier() : super([]) {
    loadTasks();
  }

  void loadTasks() {
    state = HiveService.getAllTasks();
  }

  Future<void> addTask(MorningTask task) async {
    await HiveService.addTask(task);
    loadTasks();
  }

  Future<void> updateTask(MorningTask task) async {
    await HiveService.updateTask(task);
    loadTasks();
  }

  Future<void> deleteTask(String taskId) async {
    await HiveService.deleteTask(taskId);
    await NotificationService().cancelNotification(taskId);
    loadTasks();
  }

  Future<void> reorderTasks(int oldIndex, int newIndex) async {
    final tasks = List<MorningTask>.from(state);
    
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    
    final task = tasks.removeAt(oldIndex);
    tasks.insert(newIndex, task);

    // Update order indices
    for (int i = 0; i < tasks.length; i++) {
      tasks[i] = tasks[i].copyWith(orderIndex: i);
      await HiveService.updateTask(tasks[i]);
    }

    loadTasks();
  }
}

// Settings Provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(AppSettings()) {
    loadSettings();
  }

  void loadSettings() {
    state = HiveService.getSettings();
  }

  Future<void> updateSettings(AppSettings settings) async {
    await HiveService.saveSettings(settings);
    state = settings;
  }

  Future<void> setFirstLaunchComplete() async {
    final updated = state.copyWith(isFirstLaunch: false);
    await updateSettings(updated);
  }

  Future<void> updatePin(String pin) async {
    final updated = state.copyWith(pinCode: pin);
    await updateSettings(updated);
  }

  Future<void> toggleNotifications(bool enabled) async {
    final updated = state.copyWith(notificationsEnabled: enabled);
    await updateSettings(updated);
  }

  Future<void> toggleSounds(bool enabled) async {
    final updated = state.copyWith(soundsEnabled: enabled);
    await updateSettings(updated);
  }

  Future<void> toggleTts(bool enabled) async {
    final updated = state.copyWith(ttsEnabled: enabled);
    await updateSettings(updated);
  }

  Future<void> setDepartureTime(int hour, int minute) async {
    final updated = state.copyWith(
      departureHour: hour,
      departureMinute: minute,
    );
    await updateSettings(updated);
  }
}

// Task Completion Provider
final taskCompletionsProvider = StateNotifierProvider<TaskCompletionsNotifier, Map<String, bool>>((ref) {
  return TaskCompletionsNotifier();
});

class TaskCompletionsNotifier extends StateNotifier<Map<String, bool>> {
  TaskCompletionsNotifier() : super({}) {
    loadCompletions();
  }

  String get todayString => DateFormat('yyyy-MM-dd').format(DateTime.now());

  void loadCompletions() {
    final completions = HiveService.getCompletionsForDate(todayString);
    final map = <String, bool>{};
    for (final completion in completions) {
      map[completion.taskId] = true;
    }
    state = map;
  }

  Future<void> markTaskComplete(String taskId) async {
    final completion = TaskCompletion(
      taskId: taskId,
      completedAt: DateTime.now(),
      date: todayString,
    );
    await HiveService.addCompletion(completion);
    state = {...state, taskId: true};
  }

  bool isTaskCompleted(String taskId) {
    return state[taskId] ?? false;
  }

  Future<void> resetToday() async {
    await HiveService.clearCompletionsForDate(todayString);
    state = {};
  }

  int getCompletedCount() {
    return state.values.where((completed) => completed).length;
  }
}

// Current Task Provider (which task should be shown now)
final currentTaskIndexProvider = StateProvider<int>((ref) => 0);

// Time to departure provider
final timeToDepartureProvider = StreamProvider<Duration>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (_) {
    final settings = ref.read(settingsProvider);
    final now = DateTime.now();
    final departure = settings.getDepartureTime(now);
    
    if (departure.isBefore(now)) {
      // If departure time has passed, calculate for tomorrow
      final tomorrow = now.add(const Duration(days: 1));
      final tomorrowDeparture = settings.getDepartureTime(tomorrow);
      return tomorrowDeparture.difference(now);
    }
    
    return departure.difference(now);
  });
});

// Next task provider (what task is coming next)
final nextTaskProvider = Provider<MorningTask?>((ref) {
  final tasks = ref.watch(tasksProvider);
  final completions = ref.watch(taskCompletionsProvider);
  
  for (final task in tasks) {
    if (!completions[task.id]!) {
      return task;
    }
  }
  
  return null; // All tasks completed
});
