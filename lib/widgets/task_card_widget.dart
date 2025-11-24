import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import '../models/morning_task.dart';

class TaskCardWidget extends StatefulWidget {
  final MorningTask task;
  final bool isCompleted;
  final bool isCurrent;
  final bool canComplete;
  final bool hasTaskStarted;
  final VoidCallback onComplete;

  const TaskCardWidget({
    Key? key,
    required this.task,
    required this.isCompleted,
    required this.isCurrent,
    required this.canComplete,
    required this.hasTaskStarted,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<TaskCardWidget> createState() => _TaskCardWidgetState();
}

class _TaskCardWidgetState extends State<TaskCardWidget> {
  Timer? _timer;
  Duration _timeRemaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateTimeRemaining();
    // Päivitä ajastin joka sekunti
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        _updateTimeRemaining();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTimeRemaining() {
    if (widget.isCompleted) {
      setState(() {
        _timeRemaining = Duration.zero;
      });
      return;
    }

    final now = DateTime.now();
    final taskStartTime = widget.task.getScheduledDateTime(now);
    final taskEndTime = taskStartTime.add(Duration(seconds: widget.task.durationSeconds));
    
    final remaining = taskEndTime.difference(now);
    setState(() {
      _timeRemaining = remaining.isNegative ? Duration.zero : remaining;
    });
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative || duration.inSeconds == 0) {
      return '0:00';
    }
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Opacity(
        opacity: !widget.hasTaskStarted && !widget.isCompleted ? 0.5 : 1.0,
        child: Card(
          elevation: widget.isCurrent ? 8 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: widget.isCurrent
                ? const BorderSide(color: Color(0xFF3B82F6), width: 3)
                : BorderSide.none,
          ),
          color: widget.isCompleted
              ? const Color(0xFFD1FAE5) // Vaalea vihreä
              : widget.isCurrent && widget.hasTaskStarted
                  ? const Color(0xFFDBeafe) // Vaalea sininen kun tehtävä alkanut
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
                      child: widget.task.imagePath != null
                          ? Image.file(
                              File(widget.task.imagePath!),
                              fit: BoxFit.cover,
                            )
                          : Icon(
                              _getIconForTask(widget.task.title),
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
                                widget.task.title,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: widget.isCompleted
                                      ? const Color(0xFF059669) // Tumma vihreä
                                      : const Color(0xFF1F2937), // Lähes musta, hyvä kontrasti
                                  decoration: widget.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                            if (!widget.canComplete && !widget.isCompleted)
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
                              '${widget.task.scheduledHour.toString().padLeft(2, '0')}:${widget.task.scheduledMinute.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF374151), // Tumma harmaa
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Countdown timer
                            if (!widget.isCompleted && widget.isCurrent) ...
                              [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _timeRemaining.inSeconds > 0 
                                      ? const Color(0xFFDBeafe) 
                                      : const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _timeRemaining.inSeconds > 0
                                        ? const Color(0xFF3B82F6)
                                        : const Color(0xFFEF4444),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.timer_outlined,
                                      size: 16,
                                      color: _timeRemaining.inSeconds > 0
                                          ? const Color(0xFF3B82F6)
                                          : const Color(0xFFEF4444),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatDuration(_timeRemaining),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: _timeRemaining.inSeconds > 0
                                            ? const Color(0xFF1E40AF)
                                            : const Color(0xFFDC2626),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (widget.task.description != null) ...
                          [
                          const SizedBox(height: 4),
                          Text(
                            widget.task.description!,
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
                  if (widget.isCompleted)
                    const Icon(
                      Icons.check_circle,
                      size: 50,
                      color: Color(0xFF10B981), // Kirkas vihreä
                    ),
                ],
              ),

              // Complete button
              if (!widget.isCompleted && widget.isCurrent) ...[
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: widget.canComplete ? widget.onComplete : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 60),
                    backgroundColor: widget.canComplete ? const Color(0xFF10B981) : const Color(0xFF9CA3AF), // Vihreä tai harmaa
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
                        widget.canComplete ? Icons.check : Icons.lock_outline,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.canComplete ? 'Valmis!' : 'Odota aikaa',
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
