import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 1)
class AppSettings extends HiveObject {
  @HiveField(0)
  bool isFirstLaunch;

  @HiveField(1)
  bool notificationsEnabled;

  @HiveField(2)
  bool soundsEnabled;

  @HiveField(3)
  String? pinCode;

  @HiveField(4)
  int departureHour;

  @HiveField(5)
  int departureMinute;

  @HiveField(6)
  String language;

  @HiveField(7)
  bool vibrateEnabled;

  @HiveField(8)
  int themeColorIndex;

  @HiveField(9)
  bool ttsEnabled;

  @HiveField(10)
  String taskTimeoutSound;

  @HiveField(11)
  String departureSound;

  @HiveField(12)
  int soundRepeatCount;

  AppSettings({
    this.isFirstLaunch = true,
    this.notificationsEnabled = true,
    this.soundsEnabled = true,
    this.pinCode,
    this.departureHour = 8,
    this.departureMinute = 45,
    this.language = 'fi',
    this.vibrateEnabled = true,
    this.themeColorIndex = 0,
    this.ttsEnabled = true,
    this.taskTimeoutSound = 'assets/sounds/tasksounds/alarm.mp3',
    this.departureSound = 'assets/sounds/finalsounds/hei_kouluun.mp3',
    this.soundRepeatCount = 3,
  });

  AppSettings copyWith({
    bool? isFirstLaunch,
    bool? notificationsEnabled,
    bool? soundsEnabled,
    String? pinCode,
    int? departureHour,
    int? departureMinute,
    String? language,
    bool? vibrateEnabled,
    int? themeColorIndex,
    bool? ttsEnabled,
    String? taskTimeoutSound,
    String? departureSound,
    int? soundRepeatCount,
  }) {
    return AppSettings(
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundsEnabled: soundsEnabled ?? this.soundsEnabled,
      pinCode: pinCode ?? this.pinCode,
      departureHour: departureHour ?? this.departureHour,
      departureMinute: departureMinute ?? this.departureMinute,
      language: language ?? this.language,
      vibrateEnabled: vibrateEnabled ?? this.vibrateEnabled,
      themeColorIndex: themeColorIndex ?? this.themeColorIndex,
      ttsEnabled: ttsEnabled ?? this.ttsEnabled,
      taskTimeoutSound: taskTimeoutSound ?? this.taskTimeoutSound,
      departureSound: departureSound ?? this.departureSound,
      soundRepeatCount: soundRepeatCount ?? this.soundRepeatCount,
    );
  }

  DateTime getDepartureTime(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      departureHour,
      departureMinute,
    );
  }
}
