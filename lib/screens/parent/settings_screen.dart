import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../services/secure_storage_service.dart';
import 'app_info_screen.dart';
import 'sound_settings_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _pinController = TextEditingController();

  Future<void> _changeDepartureTime() async {
    final settings = ref.read(settingsProvider);
    final currentTime = TimeOfDay(
      hour: settings.departureHour,
      minute: settings.departureMinute,
    );

    final time = await showTimePicker(
      context: context,
      initialTime: currentTime,
    );

    if (time != null) {
      await ref.read(settingsProvider.notifier).setDepartureTime(
            time.hour,
            time.minute,
          );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lähtöaika päivitetty')),
      );
    }
  }

  Future<void> _changePin() async {
    final hasPin = await SecureStorageService.hasPin();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(hasPin ? 'Vaihda PIN-koodi' : 'Aseta PIN-koodi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              decoration: const InputDecoration(
                labelText: 'Uusi PIN-koodi (4 numeroa)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _pinController.clear();
              Navigator.pop(context);
            },
            child: const Text('Peruuta'),
          ),
          TextButton(
            onPressed: () async {
              final pin = _pinController.text;
              if (pin.length == 4) {
                await SecureStorageService.savePin(pin);
                await ref.read(settingsProvider.notifier).updatePin(pin);
                _pinController.clear();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN-koodi tallennettu')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('PIN-koodin tulee olla 4 numeroa'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Tallenna'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asetukset'),
        backgroundColor: Colors.orange,
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Yleiset asetukset',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),

          // Departure time
          ListTile(
            leading: const Icon(Icons.schedule, color: Colors.orange),
            title: const Text('Lähtöaika'),
            subtitle: Text(
              '${settings.departureHour.toString().padLeft(2, '0')}:${settings.departureMinute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            trailing: const Icon(Icons.edit),
            onTap: _changeDepartureTime,
          ),

          const Divider(),

          // PIN code
          ListTile(
            leading: const Icon(Icons.lock, color: Colors.deepPurple),
            title: const Text('PIN-koodi'),
            subtitle: const Text('Suojaa vanhempien näkymä'),
            trailing: const Icon(Icons.edit),
            onTap: _changePin,
          ),

          const Divider(),

          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Ilmoitukset ja äänet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),

          // Notifications
          SwitchListTile(
            secondary: const Icon(Icons.notifications, color: Colors.green),
            title: const Text('Ilmoitukset'),
            subtitle: const Text('Näytä muistutukset tehtävistä'),
            value: settings.notificationsEnabled,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).toggleNotifications(value);
            },
          ),

          const Divider(),

          // Sounds
          SwitchListTile(
            secondary: const Icon(Icons.volume_up, color: Colors.blue),
            title: const Text('Äänet'),
            subtitle: const Text('Toista äänimerkkejä'),
            value: settings.soundsEnabled,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).toggleSounds(value);
            },
          ),

          ListTile(
            leading: const Icon(Icons.music_note, color: Colors.purple),
            title: const Text('Ääniasetus'),
            subtitle: const Text('Valitse hälytysäänet'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SoundSettingsScreen(),
                ),
              );
            },
          ),

          const Divider(),

          // Vibrate
          SwitchListTile(
            secondary: const Icon(Icons.vibration, color: Colors.purple),
            title: const Text('Värinä'),
            subtitle: const Text('Äänien yhteydessä laite värisee'),
            value: settings.vibrateEnabled,
            onChanged: (value) {
              final updated = settings.copyWith(vibrateEnabled: value);
              ref.read(settingsProvider.notifier).updateSettings(updated);
            },
          ),

          const SizedBox(height: 32),

          // App info
          ListTile(
            leading: const Icon(Icons.info, color: Colors.orange),
            title: const Text('Sovelluksen tiedot'),
            subtitle: const Text('Versio, tekijä, tietosuoja ja lisenssit'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AppInfoScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              '© 2025 Henrik Viljanen',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }
}
