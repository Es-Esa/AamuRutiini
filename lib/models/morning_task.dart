import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'morning_task.g.dart';

@HiveType(typeId: 0)
class MorningTask extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? imagePath;

  @HiveField(3)
  int scheduledHour;

  @HiveField(4)
  int scheduledMinute;

  @HiveField(5)
  int durationSeconds;

  @HiveField(6)
  bool isRequired;

  @HiveField(7)
  int orderIndex;

  @HiveField(8)
  String? description;

  @HiveField(9)
  bool playSound;

  MorningTask({
    required this.id,
    required this.title,
    this.imagePath,
    required this.scheduledHour,
    required this.scheduledMinute,
    this.durationSeconds = 300,
    this.isRequired = true,
    this.orderIndex = 0,
    this.description,
    this.playSound = false,
  });

  TimeOfDay get scheduledTime => TimeOfDay(hour: scheduledHour, minute: scheduledMinute);

  DateTime getScheduledDateTime(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      scheduledHour,
      scheduledMinute,
    );
  }

  Duration get duration => Duration(seconds: durationSeconds);

  MorningTask copyWith({
    String? id,
    String? title,
    String? imagePath,
    int? scheduledHour,
    int? scheduledMinute,
    int? durationSeconds,
    bool? isRequired,
    int? orderIndex,
    String? description,
    bool? playSound,
  }) {
    return MorningTask(
      id: id ?? this.id,
      title: title ?? this.title,
      imagePath: imagePath ?? this.imagePath,
      scheduledHour: scheduledHour ?? this.scheduledHour,
      scheduledMinute: scheduledMinute ?? this.scheduledMinute,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isRequired: isRequired ?? this.isRequired,
      orderIndex: orderIndex ?? this.orderIndex,
      description: description ?? this.description,
      playSound: playSound ?? this.playSound,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imagePath': imagePath,
      'scheduledHour': scheduledHour,
      'scheduledMinute': scheduledMinute,
      'durationSeconds': durationSeconds,
      'isRequired': isRequired,
      'orderIndex': orderIndex,
      'description': description,
      'playSound': playSound,
    };
  }

  factory MorningTask.fromJson(Map<String, dynamic> json) {
    return MorningTask(
      id: json['id'] as String,
      title: json['title'] as String,
      imagePath: json['imagePath'] as String?,
      scheduledHour: json['scheduledHour'] as int,
      scheduledMinute: json['scheduledMinute'] as int,
      durationSeconds: json['durationSeconds'] as int? ?? 300,
      isRequired: json['isRequired'] as bool? ?? true,
      orderIndex: json['orderIndex'] as int? ?? 0,
      description: json['description'] as String?,
      playSound: json['playSound'] as bool? ?? false,
    );
  }
}
