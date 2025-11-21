import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/morning_task.dart';
import '../../providers/app_providers.dart';
import '../../services/audio_service.dart';
import '../../services/tts_service.dart';
import '../../widgets/countdown_circle.dart';
import '../../widgets/task_card_widget.dart';
import '../parent/parent_mode_screen.dart';

class KidModeScreen extends ConsumerStatefulWidget {
  const KidModeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<KidModeScreen> createState() => _KidModeScreenState();
}

class _KidModeScreenState extends ConsumerState<KidModeScreen> {
  int _parentModeClickCount = 0;
  DateTime? _lastParentModeClick;

  void _onParentModeAccess() {
    final now = DateTime.now();
    
    // Reset counter if more than 2 seconds have passed
    if (_lastParentModeClick == null ||
        now.difference(_lastParentModeClick!) > const Duration(seconds: 2)) {
      _parentModeClickCount = 1;
    } else {
      _parentModeClickCount++;
    }
    
    _lastParentModeClick = now;

    // Navigate to parent mode after 5 taps
    if (_parentModeClickCount >= 5) {
      _parentModeClickCount = 0;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const ParentModeScreen()),
      );
    }
  }

  bool _canCompleteTask(MorningTask task) {
    final now = DateTime.now();
    final taskTime = task.getScheduledDateTime(now);
    // Tehtävän voi merkitä valmiiksi vasta kun sen aika on saavutettu
    return now.isAfter(taskTime) || now.isAtSameMomentAs(taskTime);
  }

  Future<void> _markTaskComplete(String taskId) async {
    final allTasks = ref.read(tasksProvider);
    final task = allTasks.firstWhere((t) => t.id == taskId);
    
    // Tarkista onko tehtävän aika
    if (!_canCompleteTask(task)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Odota vielä! Tehtävän aika on ${task.scheduledHour.toString().padLeft(2, '0')}:${task.scheduledMinute.toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 16),
          ),
          backgroundColor: Colors.orange[700],
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }
    
    final settings = ref.read(settingsProvider);
    
    // Play sound if enabled
    if (settings.soundsEnabled) {
      await AudioService().playTaskComplete();
    }

    // Speak task completion if TTS enabled
    if (settings.ttsEnabled) {
      await TtsService().speak('${task.title} valmis! Hienoa työtä!');
    }

    // Mark task as complete
    await ref.read(taskCompletionsProvider.notifier).markTaskComplete(taskId);

    // Check if all tasks are complete
    final completions = ref.read(taskCompletionsProvider);
    
    final allComplete = allTasks.every((task) => completions[task.id] == true);
    
    if (allComplete) {
      if (settings.soundsEnabled) {
        await AudioService().playAllTasksComplete();
      }
      if (settings.ttsEnabled) {
        await TtsService().speak('Kaikki tehtävät tehty! Olet valmis lähtemään!');
      }
      _showCelebration();
    }
  }

  void _showCelebration() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '🎉 Hienoa työtä! 🎉',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Olet tehnyt kaikki tehtävät!\nOlet tosi ahkera!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kiitos!', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(tasksProvider);
    final completions = ref.watch(taskCompletionsProvider);
    final timeToDepartureAsync = ref.watch(timeToDepartureProvider);
    final settings = ref.watch(settingsProvider);

    // Find current/next task
    final currentTask = tasks.firstWhere(
      (task) => completions[task.id] != true,
      orElse: () => tasks.isNotEmpty ? tasks.last : null as dynamic,
    );

    final completedCount = completions.values.where((v) => v).length;
    final totalCount = tasks.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8), // Moderni vaalea harmaa-sininen
      body: SafeArea(
        child: Column(
          children: [
            // Header with parent mode access
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Aamurutiini',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A), // Tumma sininen, hyvä kontrasti
                    ),
                  ),
                  GestureDetector(
                    onTap: _onParentModeAccess,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.settings, color: Colors.grey, size: 24),
                    ),
                  ),
                ],
              ),
            ),

            // Countdown circle
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: timeToDepartureAsync.when(
                data: (duration) => CountdownCircle(
                  timeRemaining: duration,
                  departureTime: TimeOfDay(
                    hour: settings.departureHour,
                    minute: settings.departureMinute,
                  ),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const Text('Virhe ajastimessa'),
              ),
            ),

            // Progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Edistyminen',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        '$completedCount / $totalCount',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A), // Tumma sininen
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: totalCount > 0 ? completedCount / totalCount : 0,
                      minHeight: 12,
                      backgroundColor: const Color(0xFFE2E8F0), // Vaalea harmaa
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)), // Kirkas vihreä (esteettömyysstandardi)
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Current task (only one visible at a time)
            Expanded(
              child: tasks.isEmpty
                  ? const Center(
                      child: Text(
                        'Ei tehtäviä.\nPyydä vanhempaa lisäämään tehtäviä.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, color: Colors.grey),
                      ),
                    )
                  : completedCount == totalCount
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                size: 120,
                                color: Color(0xFF10B981), // Kirkas vihreä
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Kaikki tehtävät tehty!',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF059669), // Tumma vihreä, hyvä kontrasti
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Olet valmis lähtemään! 🎉',
                                style: TextStyle(fontSize: 20, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Task number indicator
                                Text(
                                  'Tehtävä ${completedCount + 1} / $totalCount',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 32),
                                // Single task card - larger and centered
                                TaskCardWidget(
                                  task: currentTask,
                                  isCompleted: false,
                                  isCurrent: true,
                                  canComplete: _canCompleteTask(currentTask),
                                  onComplete: () => _markTaskComplete(currentTask.id),
                                ),
                              ],
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
