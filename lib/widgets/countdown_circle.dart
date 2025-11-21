import 'package:flutter/material.dart';

class CountdownCircle extends StatelessWidget {
  final Duration timeRemaining;
  final TimeOfDay departureTime;

  const CountdownCircle({
    Key? key,
    required this.timeRemaining,
    required this.departureTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate total time (assume 2 hours max for morning routine)
    const totalMinutes = 120.0;
    final remainingMinutes = timeRemaining.inMinutes.toDouble();
    final progress = (totalMinutes - remainingMinutes) / totalMinutes;

    return Container(
      width: 250,
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),

          // Progress indicator
          SizedBox(
            width: 230,
            height: 230,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: 12,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getColorForProgress(progress),
              ),
            ),
          ),

          // Time display
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.alarm,
                size: 40,
                color: Colors.blue,
              ),
              const SizedBox(height: 8),
              Text(
                _formatDuration(timeRemaining),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'aikaa lähtöön',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Lähtö klo ${departureTime.hour.toString().padLeft(2, '0')}:${departureTime.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) {
      return '00:00';
    }

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  Color _getColorForProgress(double progress) {
    if (progress < 0.5) {
      return Colors.green;
    } else if (progress < 0.75) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
