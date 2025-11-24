import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../models/morning_task.dart';
import 'task_edit_screen.dart';

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tehtävät'),
        backgroundColor: Colors.blue,
      ),
      body: tasks.isEmpty
          ? const Center(
              child: Text(
                'Ei tehtäviä.\nLisää ensimmäinen tehtävä.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tasks.length,
              onReorder: (oldIndex, newIndex) {
                ref.read(tasksProvider.notifier).reorderTasks(oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final task = tasks[index];
                return _buildTaskCard(context, ref, task, index, key: ValueKey(task.id));
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TaskEditScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Lisää tehtävä'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildTaskCard(
    BuildContext context,
    WidgetRef ref,
    MorningTask task,
    int index, {
    required Key key,
  }) {
    return Card(
      key: key,
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withOpacity(0.2),
          child: Text(
            '${index + 1}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        title: Text(
          task.title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${task.scheduledHour.toString().padLeft(2, '0')}:${task.scheduledMinute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.timer, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${task.durationSeconds ~/ 60} min',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            if (task.description != null) ...[
              const SizedBox(height: 4),
              Text(
                task.description!,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskEditScreen(task: task),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context, ref, task),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    MorningTask task,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Poista tehtävä'),
        content: Text('Haluatko varmasti poistaa tehtävän "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Peruuta'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Poista', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await ref.read(tasksProvider.notifier).deleteTask(task.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tehtävä "${task.title}" poistettu')),
        );
      }
    }
  }
}
