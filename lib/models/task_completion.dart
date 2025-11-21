import 'package:hive/hive.dart';

part 'task_completion.g.dart';

@HiveType(typeId: 2)
class TaskCompletion extends HiveObject {
  @HiveField(0)
  String taskId;

  @HiveField(1)
  DateTime completedAt;

  @HiveField(2)
  String date; // Format: YYYY-MM-DD

  TaskCompletion({
    required this.taskId,
    required this.completedAt,
    required this.date,
  });
}
