import 'package:flutter/material.dart';
import 'dart:io';
import '../models/morning_task.dart';

class TaskCardWidget extends StatelessWidget {
  final MorningTask task;
  final bool isCompleted;
  final bool isCurrent;
  final bool canComplete;
  final VoidCallback onComplete;

  const TaskCardWidget({
    Key? key,
    required this.task,
    required this.isCompleted,
    required this.isCurrent,
    required this.canComplete,
    required this.onComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Opacity(
        opacity: !canComplete && !isCompleted ? 0.5 : 1.0,
        child: Card(
          elevation: isCurrent ? 8 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: isCurrent
                ? const BorderSide(color: Color(0xFF3B82F6), width: 3)
                : BorderSide.none,
          ),
          color: isCompleted
              ? const Color(0xFFD1FAE5) // Vaalea vihreä
              : isCurrent
                  ? const Color(0xFFDBeafe) // Vaalea sininen
                  : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  // Image
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.grey[200],
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: task.imagePath != null
                          ? Image.file(
                              File(task.imagePath!),
                              fit: BoxFit.cover,
                            )
                          : Icon(
                              _getIconForTask(task.title),
                              size: 50,
                              color: Colors.grey[600],
                            ),
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Task info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                task.title,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: isCompleted
                                      ? const Color(0xFF059669) // Tumma vihreä
                                      : const Color(0xFF1F2937), // Lähes musta, hyvä kontrasti
                                  decoration: isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                            if (!canComplete && !isCompleted)
                              const Icon(
                                Icons.lock_outline,
                                size: 24,
                                color: Color(0xFF9CA3AF), // Harmaa
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 18,
                              color: Color(0xFF6B7280), // Keskiharmaa
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${task.scheduledHour.toString().padLeft(2, '0')}:${task.scheduledMinute.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF374151), // Tumma harmaa
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        if (task.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            task.description!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280), // Keskiharmaa
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Completion status
                  if (isCompleted)
                    const Icon(
                      Icons.check_circle,
                      size: 50,
                      color: Color(0xFF10B981), // Kirkas vihreä
                    ),
                ],
              ),

              // Complete button
              if (!isCompleted && isCurrent) ...[
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: canComplete ? onComplete : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 60),
                    backgroundColor: canComplete ? const Color(0xFF10B981) : const Color(0xFF9CA3AF), // Vihreä tai harmaa
                    disabledBackgroundColor: const Color(0xFF9CA3AF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        canComplete ? Icons.check : Icons.lock_outline,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        canComplete ? 'Valmis!' : 'Odota aikaa',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      ),
    );
  }

  IconData _getIconForTask(String title) {
    final titleLower = title.toLowerCase();
    
    if (titleLower.contains('nouse') || titleLower.contains('herää')) {
      return Icons.bedtime;
    } else if (titleLower.contains('petaa')) {
      return Icons.king_bed;
    } else if (titleLower.contains('peseydy') || titleLower.contains('suihku')) {
      return Icons.shower;
    } else if (titleLower.contains('pue') || titleLower.contains('vaatteet')) {
      return Icons.checkroom;
    } else if (titleLower.contains('syö') || titleLower.contains('aamupala')) {
      return Icons.restaurant;
    } else if (titleLower.contains('hampaat') || titleLower.contains('harjaa')) {
      return Icons.cleaning_services;
    } else if (titleLower.contains('lähde') || titleLower.contains('koulu')) {
      return Icons.school;
    } else {
      return Icons.task_alt;
    }
  }
}
