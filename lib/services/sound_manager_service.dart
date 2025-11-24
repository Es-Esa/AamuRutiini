import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';

class SoundManagerService {
  static final SoundManagerService _instance = SoundManagerService._internal();
  factory SoundManagerService() => _instance;
  SoundManagerService._internal();

  List<String> _taskSounds = [];
  List<String> _finalSounds = [];
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // First try a bundled index file (safer for release APKs)
      try {
        final indexContent = await rootBundle.loadString('assets/sounds/sounds_index.json');
        final Map<String, dynamic> indexMap = jsonDecode(indexContent);
        final List<dynamic> tasks = indexMap['tasksounds'] ?? [];
        final List<dynamic> finals = indexMap['finalsounds'] ?? [];
        _taskSounds = tasks.map((e) => e.toString()).toList();
        _finalSounds = finals.map((e) => e.toString()).toList();
        _initialized = true;
        print('SoundManager: Loaded sounds_index.json, found ${_taskSounds.length} task sounds and ${_finalSounds.length} final sounds.');
        return;
      } catch (e) {
        print('SoundManager: sounds_index.json not found or invalid: $e');
      }

      // Fallback: try AssetManifest.json (works on debug builds)
      try {
        final manifestContent = await rootBundle.loadString('AssetManifest.json');
        final Map<String, dynamic> manifestMap = jsonDecode(manifestContent);
        _taskSounds = manifestMap.keys
            .where((String key) => key.startsWith('assets/sounds/tasksounds/'))
            .where((String key) => key.endsWith('.mp3'))
            .toList();

        _finalSounds = manifestMap.keys
            .where((String key) => key.startsWith('assets/sounds/finalsounds/'))
            .where((String key) => key.endsWith('.mp3'))
            .toList();

        _initialized = true;
        print('SoundManager: Found ${_taskSounds.length} task sounds: $_taskSounds');
        print('SoundManager: Found ${_finalSounds.length} final sounds: $_finalSounds');
        return;
      } catch (e) {
        print('SoundManager: Error loading AssetManifest.json fallback: $e');
      }
    } catch (e) {
      print('Error loading sound manifest: $e');
      _taskSounds = [];
      _finalSounds = [];
    }
  }

  List<String> get taskSounds => _taskSounds;
  List<String> get finalSounds => _finalSounds;

  String getSoundName(String path) {
    // Extract filename without path and extension
    final parts = path.split('/');
    final filename = parts.last;
    return filename.replaceAll('.mp3', '').replaceAll('_', ' ');
  }
}
