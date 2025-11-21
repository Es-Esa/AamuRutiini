import 'package:hive_flutter/hive_flutter.dart';
import '../models/morning_task.dart';
import '../models/app_settings.dart';
import '../models/task_completion.dart';

class HiveService {
  static const String tasksBoxName = 'tasks';
  static const String settingsBoxName = 'settings';
  static const String completionsBoxName = 'completions';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(MorningTaskAdapter());
    Hive.registerAdapter(AppSettingsAdapter());
    Hive.registerAdapter(TaskCompletionAdapter());

    // Open boxes
    await Hive.openBox<MorningTask>(tasksBoxName);
    await Hive.openBox<AppSettings>(settingsBoxName);
    await Hive.openBox<TaskCompletion>(completionsBoxName);
  }

  static Box<MorningTask> get tasksBox => Hive.box<MorningTask>(tasksBoxName);
  static Box<AppSettings> get settingsBox => Hive.box<AppSettings>(settingsBoxName);
  static Box<TaskCompletion> get completionsBox => Hive.box<TaskCompletion>(completionsBoxName);

  // Tasks CRUD
  static Future<void> addTask(MorningTask task) async {
    await tasksBox.put(task.id, task);
  }

  static Future<void> updateTask(MorningTask task) async {
    await tasksBox.put(task.id, task);
  }

  static Future<void> deleteTask(String taskId) async {
    await tasksBox.delete(taskId);
  }

  static List<MorningTask> getAllTasks() {
    final tasks = tasksBox.values.toList();
    tasks.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return tasks;
  }

  static MorningTask? getTask(String taskId) {
    return tasksBox.get(taskId);
  }

  // Settings
  static Future<void> saveSettings(AppSettings settings) async {
    await settingsBox.put('main', settings);
  }

  static AppSettings getSettings() {
    return settingsBox.get('main', defaultValue: AppSettings())!;
  }

  // Task Completions
  static Future<void> addCompletion(TaskCompletion completion) async {
    final key = '${completion.taskId}_${completion.date}';
    await completionsBox.put(key, completion);
  }

  static List<TaskCompletion> getCompletionsForDate(String date) {
    return completionsBox.values
        .where((completion) => completion.date == date)
        .toList();
  }

  static bool isTaskCompletedToday(String taskId, String date) {
    final key = '${taskId}_$date';
    return completionsBox.containsKey(key);
  }

  static Future<void> clearCompletionsForDate(String date) async {
    final keys = completionsBox.keys.where((key) {
      final completion = completionsBox.get(key);
      return completion?.date == date;
    }).toList();

    for (final key in keys) {
      await completionsBox.delete(key);
    }
  }

  // Initialize default tasks
  static Future<void> initializeDefaultTasks() async {
    if (tasksBox.isEmpty) {
      final defaultTasks = [
        MorningTask(
          id: '1',
          title: 'Nouse ylös',
          scheduledHour: 7,
          scheduledMinute: 0,
          durationSeconds: 300,
          orderIndex: 0,
          description: 'Herää ja nouse sängystä',
        ),
        MorningTask(
          id: '2',
          title: 'Petaa sänky',
          scheduledHour: 7,
          scheduledMinute: 5,
          durationSeconds: 300,
          orderIndex: 1,
          description: 'Laita sänky siistiksi',
        ),
        MorningTask(
          id: '3',
          title: 'Peseydy',
          scheduledHour: 7,
          scheduledMinute: 10,
          durationSeconds: 600,
          orderIndex: 2,
          description: 'Käy suihkussa tai peseydy',
        ),
        MorningTask(
          id: '4',
          title: 'Pue vaatteet',
          scheduledHour: 7,
          scheduledMinute: 20,
          durationSeconds: 300,
          orderIndex: 3,
          description: 'Pue päivän vaatteet',
        ),
        MorningTask(
          id: '5',
          title: 'Syö aamupala',
          scheduledHour: 7,
          scheduledMinute: 25,
          durationSeconds: 900,
          orderIndex: 4,
          description: 'Syö terveellinen aamupala',
        ),
        MorningTask(
          id: '6',
          title: 'Harjaa hampaat',
          scheduledHour: 7,
          scheduledMinute: 40,
          durationSeconds: 180,
          orderIndex: 5,
          description: 'Pese hampaat huolellisesti',
        ),
        MorningTask(
          id: '7',
          title: 'Lähde kouluun',
          scheduledHour: 7,
          scheduledMinute: 45,
          durationSeconds: 0,
          orderIndex: 6,
          description: 'Ota laukku ja lähde',
        ),
      ];

      for (final task in defaultTasks) {
        await addTask(task);
      }
    }
  }

  static Future<void> close() async {
    await Hive.close();
  }
}
