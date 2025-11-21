import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../models/morning_task.dart';
import '../../providers/app_providers.dart';
import 'pecs_search_screen.dart';

class TaskEditScreen extends ConsumerStatefulWidget {
  final MorningTask? task;

  const TaskEditScreen({Key? key, this.task}) : super(key: key);

  @override
  ConsumerState<TaskEditScreen> createState() => _TaskEditScreenState();
}

class _TaskEditScreenState extends ConsumerState<TaskEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  TimeOfDay _selectedTime = const TimeOfDay(hour: 7, minute: 0);
  int _durationMinutes = 5;
  String? _imagePath;
  bool _isRequired = true;
  bool _playSound = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description ?? '';
      _selectedTime = widget.task!.scheduledTime;
      _durationMinutes = widget.task!.durationSeconds ~/ 60;
      _imagePath = widget.task!.imagePath;
      _isRequired = widget.task!.isRequired;
      _playSound = widget.task!.playSound;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Copy image to app directory
      final directory = await getApplicationDocumentsDirectory();
      final fileName = '${const Uuid().v4()}.jpg';
      final savedImage = File('${directory.path}/$fileName');
      await File(pickedFile.path).copy(savedImage.path);

      setState(() {
        _imagePath = savedImage.path;
      });
    }
  }

  Future<void> _pickFromArasaac() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const PecsSearchScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        _imagePath = result;
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    final tasks = ref.read(tasksProvider);
    final orderIndex = widget.task?.orderIndex ?? tasks.length;

    final task = MorningTask(
      id: widget.task?.id ?? const Uuid().v4(),
      title: _titleController.text,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      scheduledHour: _selectedTime.hour,
      scheduledMinute: _selectedTime.minute,
      durationSeconds: _durationMinutes * 60,
      imagePath: _imagePath,
      isRequired: _isRequired,
      playSound: _playSound,
      orderIndex: orderIndex,
    );

    if (widget.task == null) {
      await ref.read(tasksProvider.notifier).addTask(task);
    } else {
      await ref.read(tasksProvider.notifier).updateTask(task);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Uusi tehtävä' : 'Muokkaa tehtävää'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveTask,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Image section
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: _imagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_imagePath!),
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate,
                                size: 50, color: Colors.grey[600]),
                            const SizedBox(height: 8),
                            Text(
                              'Lisää kuva',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Image source buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galleria'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _pickFromArasaac,
                  icon: const Icon(Icons.search),
                  label: const Text('Hae PECS'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Tehtävän nimi',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Syötä tehtävän nimi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Kuvaus (valinnainen)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Time
            ListTile(
              title: const Text('Ajankohta'),
              subtitle: Text(
                '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              leading: const Icon(Icons.access_time),
              trailing: const Icon(Icons.edit),
              onTap: _selectTime,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            const SizedBox(height: 16),

            // Duration
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.timer),
                        const SizedBox(width: 8),
                        const Text(
                          'Kesto',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _durationMinutes.toDouble(),
                            min: 1,
                            max: 30,
                            divisions: 29,
                            label: '$_durationMinutes min',
                            onChanged: (value) {
                              setState(() {
                                _durationMinutes = value.toInt();
                              });
                            },
                          ),
                        ),
                        Text(
                          '$_durationMinutes min',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Options
            SwitchListTile(
              title: const Text('Pakollinen tehtävä'),
              subtitle: const Text('Tehtävä täytyy suorittaa'),
              value: _isRequired,
              onChanged: (value) {
                setState(() {
                  _isRequired = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Soita ääni'),
              subtitle: const Text('Toista äänimerkki tehtävän alkaessa'),
              value: _playSound,
              onChanged: (value) {
                setState(() {
                  _playSound = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
