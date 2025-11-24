import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz_zone;
import 'services/hive_service.dart';
import 'services/notification_service.dart';
import 'services/tts_service.dart';
import 'services/notification_scheduler.dart';
import 'services/task_sound_scheduler.dart';
import 'providers/app_providers.dart';
import 'screens/first_launch_screen.dart';
import 'screens/kid/kid_mode_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone
  tz.initializeTimeZones();
  tz_zone.setLocalLocation(tz_zone.getLocation('Europe/Helsinki'));

  // Initialize services
  await HiveService.init();
  // Always ensure default tasks exist
  await HiveService.ensureDefaultTasks();
  await NotificationService().init();
  await NotificationScheduler().initialize();
  await TtsService().init();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Schedule all sounds on app startup
    _scheduleInitialSounds();
  }

  Future<void> _scheduleInitialSounds() async {
    // Wait a bit to ensure providers are ready
    await Future.delayed(const Duration(milliseconds: 500));
    final tasks = ref.read(tasksProvider);
    final settings = ref.read(settingsProvider);
    await TaskSoundScheduler().scheduleAllTaskSounds(
      tasks: tasks,
      settings: settings,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'Aamurutiini',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: settings.isFirstLaunch
          ? const FirstLaunchScreen()
          : const KidModeScreen(),
    );
  }
}
