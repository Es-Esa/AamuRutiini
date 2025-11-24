import 'package:just_audio/just_audio.dart';
import 'dart:async';
import 'package:vibration/vibration.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  final AudioPlayer _previewPlayer = AudioPlayer();
  StreamSubscription? _currentSubscription;
  bool _vibrateEnabled = true;

  void setVibrateEnabled(bool enabled) {
    _vibrateEnabled = enabled;
  }

  Future<void> playSound(String assetPath, {int repeatCount = 1, Function? onComplete, bool vibrate = true}) async {
    try {
      debugPrint('🔊 AudioService.playSound: $assetPath repeatCount=$repeatCount');
      
      // Vibrate when sound starts
      if (vibrate && _vibrateEnabled) {
        final hasVibrator = await Vibration.hasVibrator();
        if (hasVibrator == true) {
          Vibration.vibrate(duration: 500);
        }
      }
      
      if (repeatCount <= 1) {
        await _player.setAsset(assetPath);
        await _player.play();
        // Wait for completion if callback provided
        if (onComplete != null) {
          _player.playerStateStream.listen((state) {
            if (state.processingState == ProcessingState.completed) {
              onComplete();
            }
          });
        }
      } else {
        // Play with repetition
        await _player.setAsset(assetPath);
        await _player.setLoopMode(LoopMode.off);
        
        int playCount = 0;
        
        // Cancel any previous subscriptions
        _currentSubscription?.cancel();
        
        // Listen to completion and replay
        _currentSubscription = _player.playerStateStream.listen((state) async {
          if (state.processingState == ProcessingState.completed && playCount < repeatCount) {
            playCount++;
            debugPrint('🔊 AudioService: Completed play $playCount of $repeatCount');
            if (playCount < repeatCount) {
              // Vibrate on each repeat
              if (vibrate && _vibrateEnabled) {
                final hasVibrator = await Vibration.hasVibrator();
                if (hasVibrator == true) {
                  Vibration.vibrate(duration: 500);
                }
              }
              await _player.seek(Duration.zero);
              await _player.play();
            } else {
              debugPrint('🔊 AudioService: Finished all $repeatCount repetitions');
              _currentSubscription?.cancel();
              // Call callback when all repetitions are done
              if (onComplete != null) {
                onComplete();
              }
            }
          }
        });
        
        await _player.play();
      }
    } catch (e) {
      debugPrint('❌ AudioService error playing sound: $e');
      if (onComplete != null) {
        onComplete();
      }
    }
  }

  Future<void> previewSound(String assetPath) async {
    try {
      await _previewPlayer.stop();
      await _previewPlayer.setAsset(assetPath);
      await _previewPlayer.play();
    } catch (e) {
      print('Error previewing sound: $e');
    }
  }

  Future<void> stopPreview() async {
    await _previewPlayer.stop();
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

  Future<void> playTaskStartSound() async {
    debugPrint('🔊 AudioService.playTaskStartSound: Playing on_aika_suorittaa_tehtava.mp3');
    // Play the specific task start sound
    await playSound('assets/sounds/tasksounds/on_aika_suorittaa_tehtava.mp3');
  }

  Future<void> playTaskTimeout() async {
    // Play alert when task time is up
    await playSound('assets/sounds/task_timeout.mp3');
  }

  Future<void> playTaskTimeoutCustom(String soundPath, int repeatCount, {Function? onComplete}) async {
    debugPrint('🔊 AudioService.playTaskTimeoutCustom: soundPath=$soundPath, repeatCount=$repeatCount');
    await playSound(soundPath, repeatCount: repeatCount, onComplete: onComplete);
  }

  Future<void> playDepartureAlert() async {
    // Play alert when it's time to leave
    await playSound('assets/sounds/departure_alert.mp3');
  }

  Future<void> playDepartureAlertCustom(String soundPath, int repeatCount) async {
    await playSound(soundPath, repeatCount: repeatCount);
  }

  // Yksinkertainen metodi notifikaatio-äänille (ilman toistoja)
  // HUOM: Ottaa ääniasetukset käyttöön - hakee oikeat äänet AppSettings:stä
  Future<void> playSoundByName(String soundFile, {String? taskTimeoutSound, String? departureSound}) async {
    String assetPath;
    switch (soundFile) {
      case 'start':
        assetPath = 'assets/sounds/tasksounds/on_aika_suorittaa_tehtava.mp3';
        break;
      case 'timeout':
        // Käytä asetuksista tulevaa timeout-ääntä
        assetPath = taskTimeoutSound ?? 'assets/sounds/tasksounds/alarm.mp3';
        break;
      case 'departure':
        // Käytä asetuksista tulevaa departure-ääntä
        assetPath = departureSound ?? 'assets/sounds/finalsounds/hei_kouluun.mp3';
        break;
      default:
        debugPrint('❌ Unknown sound file: $soundFile');
        return;
    }
    
    debugPrint('🔊 Playing sound: $soundFile → $assetPath');
    await playSound(assetPath, repeatCount: 1, vibrate: true);
  }

  Future<void> stop() async {
    _currentSubscription?.cancel();
    await _player.stop();
  }

  void dispose() {
    _currentSubscription?.cancel();
    _player.dispose();
    _previewPlayer.dispose();
  }
}
