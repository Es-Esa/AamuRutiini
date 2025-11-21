import 'package:just_audio/just_audio.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();

  Future<void> playSound(String assetPath) async {
    try {
      await _player.setAsset(assetPath);
      await _player.play();
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  Future<void> playTaskComplete() async {
    await playSound('assets/sounds/task_complete.mp3');
  }

  Future<void> playAllTasksComplete() async {
    await playSound('assets/sounds/all_complete.mp3');
  }

  Future<void> playTaskStart() async {
    await playSound('assets/sounds/task_start.mp3');
  }

  Future<void> stop() async {
    await _player.stop();
  }

  void dispose() {
    _player.dispose();
  }
}
