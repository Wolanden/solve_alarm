import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AddAlarmScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onAlarmAdded;

  const AddAlarmScreen({super.key, required this.onAlarmAdded});

  @override
  State<AddAlarmScreen> createState() => _AddAlarmScreenState();
}

class _AddAlarmScreenState extends State<AddAlarmScreen> {
  TimeOfDay _selectedTime = TimeOfDay.now();
  final List<bool> _selectedDays = List.generate(7, (_) => false);
  String _selectedSound = '';
  final AudioPlayer _audioPlayer = AudioPlayer();

  // List of available sounds (update this with your actual sound file names)
  final List<String> _availableSounds = [
    'Allstar.mp3',
    'BlackBanjocore.mp3',
    'alarm3.mp3',
  ];

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Alarm'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                );
                if (picked != null && picked != _selectedTime) {
                  setState(() {
                    _selectedTime = picked;
                  });
                }
              },
              child: Text('Select Time: ${_selectedTime.format(context)}'),
            ),
            const SizedBox(height: 20),
            const Text('Select Days:', style: TextStyle(color: Colors.white)),
            Wrap(
              spacing: 8.0,
              children: List.generate(7, (index) {
                return FilterChip(
                  label: Text(['M', 'T', 'W', 'T', 'F', 'S', 'S'][index]),
                  selected: _selectedDays[index],
                  onSelected: (bool selected) {
                    setState(() {
                      _selectedDays[index] = selected;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 20),
            DropdownButton<String>(
              value: _selectedSound.isEmpty ? null : _selectedSound,
              hint: const Text('Select Alarm Sound'),
              items: _availableSounds.map((String sound) {
                return DropdownMenuItem<String>(
                  value: sound,
                  child: Text(sound),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedSound = newValue;
                  });
                }
              },
            ),
            if (_selectedSound.isNotEmpty)
              ElevatedButton(
                onPressed: () async {
                  await _audioPlayer.play(AssetSource('sounds/$_selectedSound'));
                },
                child: const Text('Preview Sound'),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final newAlarm = {
                  'time': '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                  'days': _selectedDays,
                  'sound': _selectedSound,
                };
                widget.onAlarmAdded(newAlarm);
                Navigator.pop(context);
              },
              child: const Text('Save Alarm'),
            ),
          ],
        ),
      ),
    );
  }
}