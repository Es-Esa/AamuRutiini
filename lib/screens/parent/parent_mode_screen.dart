import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/app_providers.dart';
import '../../services/secure_storage_service.dart';
import '../../widgets/parent_tutorial_dialog.dart';
import 'task_list_screen.dart';
import 'settings_screen.dart';

class ParentModeScreen extends ConsumerStatefulWidget {
  const ParentModeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ParentModeScreen> createState() => _ParentModeScreenState();
}

class _ParentModeScreenState extends ConsumerState<ParentModeScreen> {
  bool _isUnlocked = false;
  final _pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkPinRequired();
  }

  Future<void> _checkPinRequired() async {
    final hasPin = await SecureStorageService.hasPin();
    if (!hasPin) {
      setState(() => _isUnlocked = true);
    }
    
    // Check if tutorial should be shown
    if (hasPin) {
      // Will show after PIN unlock
    } else {
      _checkAndShowTutorial();
    }
  }
  
  Future<void> _checkAndShowTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenTutorial = prefs.getBool('parent_mode_tutorial_shown') ?? false;
    
    if (!hasSeenTutorial && mounted) {
      // Small delay to let the UI settle
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        _showTutorial();
        await prefs.setBool('parent_mode_tutorial_shown', true);
      }
    }
  }
  
  void _showTutorial() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ParentTutorialDialog(),
    );
  }

  Future<void> _verifyPin() async {
    final inputPin = _pinController.text;
    final isValid = await SecureStorageService.verifyPin(inputPin);

    if (isValid) {
      setState(() => _isUnlocked = true);
      _checkAndShowTutorial();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Väärä PIN-koodi'),
          backgroundColor: Colors.red,
        ),
      );
      _pinController.clear();
    }
  }

  Future<void> _resetTodayProgress() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nollaa päivän edistyminen'),
        content: const Text(
          'Haluatko varmasti nollata kaikki tänään tehdyt tehtävät?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Peruuta'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Nollaa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(taskCompletionsProvider.notifier).resetToday();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Päivän edistyminen nollattu')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isUnlocked) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('PIN-koodi vaaditaan'),
          backgroundColor: Colors.deepPurple,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 80, color: Colors.deepPurple),
              const SizedBox(height: 24),
              const Text(
                'Syötä PIN-koodi',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 32, letterSpacing: 16),
                decoration: const InputDecoration(
                  hintText: '••••',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                onSubmitted: (_) => _verifyPin(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _verifyPin,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.deepPurple,
                ),
                child: const Text('Avaa', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vanhempien näkymä'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetTodayProgress,
            tooltip: 'Nollaa päivän edistyminen',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMenuCard(
            icon: Icons.list_alt,
            title: 'Tehtävät',
            subtitle: 'Hallinnoi aamun tehtäviä',
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TaskListScreen()),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildMenuCard(
            icon: Icons.settings,
            title: 'Asetukset',
            subtitle: 'Muokkaa sovelluksen asetuksia',
            color: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          _buildStatsSection(),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 36, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    final tasks = ref.watch(tasksProvider);
    final completions = ref.watch(taskCompletionsProvider);
    final settings = ref.watch(settingsProvider);

    final completedCount = completions.values.where((v) => v).length;
    final totalCount = tasks.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tämän päivän tilastot',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Tehtäviä', totalCount.toString(), Colors.blue),
            _buildStatItem('Tehty', completedCount.toString(), Colors.green),
            _buildStatItem(
              'Jäljellä',
              (totalCount - completedCount).toString(),
              Colors.orange,
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Icon(Icons.access_time, color: Colors.deepPurple),
            const SizedBox(width: 8),
            Text(
              'Lähtöaika: ${settings.departureHour.toString().padLeft(2, '0')}:${settings.departureMinute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }
}
