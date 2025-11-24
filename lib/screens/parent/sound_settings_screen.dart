import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../services/sound_manager_service.dart';
import '../../services/audio_service.dart';

class SoundSettingsScreen extends ConsumerStatefulWidget {
  const SoundSettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SoundSettingsScreen> createState() => _SoundSettingsScreenState();
}

class _SoundSettingsScreenState extends ConsumerState<SoundSettingsScreen> {
  final _soundManager = SoundManagerService();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSounds();
  }

  Future<void> _loadSounds() async {
    await _soundManager.initialize();
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Ääniasetus'),
          backgroundColor: Colors.orange,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ääniasetus'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(settings.soundsEnabled ? Icons.volume_up : Icons.volume_off),
            onPressed: () {
              final updated = settings.copyWith(soundsEnabled: !settings.soundsEnabled);
              ref.read(settingsProvider.notifier).updateSettings(updated);
            },
            tooltip: settings.soundsEnabled ? 'Mykistä' : 'Äänet päälle',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Mute/Unmute toggle
          Card(
            child: SwitchListTile(
              title: const Text('Äänet käytössä'),
              subtitle: Text(settings.soundsEnabled ? 'Äänet soivat' : 'Äänet mykistetty'),
              value: settings.soundsEnabled,
              onChanged: (value) {
                final updated = settings.copyWith(soundsEnabled: value);
                ref.read(settingsProvider.notifier).updateSettings(updated);
              },
              secondary: Icon(
                settings.soundsEnabled ? Icons.notifications_active : Icons.notifications_off,
                color: settings.soundsEnabled ? Colors.blue : Colors.grey,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Task timeout sound
          const Text(
            'Tehtävän aikahälytys',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Soitetaan kun tehtävän aika loppuu',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 12),

          if (_soundManager.taskSounds.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Ei ääniä saatavilla. Lisää MP3-tiedostoja kansioon assets/sounds/tasksounds/',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ..._soundManager.taskSounds.map((sound) {
              final isSelected = settings.taskTimeoutSound == sound;
              return Card(
                color: isSelected ? Colors.blue[50] : null,
                child: ListTile(
                  leading: Icon(
                    isSelected ? Icons.check_circle : Icons.music_note,
                    color: isSelected ? Colors.blue : Colors.grey,
                  ),
                  title: Text(
                    _soundManager.getSoundName(sound),
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: InkWell(
                    onTap: () {
                      debugPrint('🔊 Preview sound: $sound');
                      AudioService().previewSound(sound);
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_arrow, size: 16),
                          SizedBox(width: 4),
                          Text('Esikuuntelu', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
                  onTap: () {
                    debugPrint('📝 Task timeout sound tapped: $sound');
                    final updated = settings.copyWith(taskTimeoutSound: sound);
                    ref.read(settingsProvider.notifier).updateSettings(updated);
                  },
                ),
              );
            }).toList(),

          const SizedBox(height: 24),

          // Departure sound
          const Text(
            'Lähtöhälytys',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Soitetaan kun on aika lähteä',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 12),

          if (_soundManager.finalSounds.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Ei ääniä saatavilla. Lisää MP3-tiedostoja kansioon assets/sounds/finalsounds/',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ..._soundManager.finalSounds.map((sound) {
              final isSelected = settings.departureSound == sound;
              return Card(
                color: isSelected ? Colors.green[50] : null,
                child: ListTile(
                  leading: Icon(
                    isSelected ? Icons.check_circle : Icons.music_note,
                    color: isSelected ? Colors.green : Colors.grey,
                  ),
                  title: Text(
                    _soundManager.getSoundName(sound),
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: InkWell(
                    onTap: () {
                      debugPrint('🔊 Preview sound: $sound');
                      AudioService().previewSound(sound);
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_arrow, size: 16),
                          SizedBox(width: 4),
                          Text('Esikuuntelu', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
                  onTap: () {
                    debugPrint('📝 Departure sound tapped: $sound');
                    final updated = settings.copyWith(departureSound: sound);
                    ref.read(settingsProvider.notifier).updateSettings(updated);
                  },
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    AudioService().stopPreview();
    super.dispose();
  }
}
