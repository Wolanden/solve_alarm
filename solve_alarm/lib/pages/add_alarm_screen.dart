import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

// Screen for adding a new alarm
class AddAlarmScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onAlarmAdded; // Callback function to add the new alarm

  const AddAlarmScreen({super.key, required this.onAlarmAdded});

  @override
  State<AddAlarmScreen> createState() => _AddAlarmScreenState();
}

class _AddAlarmScreenState extends State<AddAlarmScreen> {
  TimeOfDay _selectedTime = TimeOfDay.now(); // Selected alarm time
  final List<bool> _selectedDays = List.generate(7, (_) => false); // Selected days for the alarm
  String _selectedSound = ''; // Selected alarm sound
  final AudioPlayer _audioPlayer = AudioPlayer(); // Audio player for previewing sounds

  // List of available alarm sounds
  final List<String> _availableSounds = [
    'Allstar.mp3',
    'BlackBanjocore.mp3',
    'CanIGet.mp3',
    'ElSondito.mp3',
    'FaxSound.mp3',
    'HebDini.mp3',
    'KirinJCallinan.mp3',
    'TimerTo.mp3',
    'WindowsError.mp3'
  ];

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // Format TimeOfDay to string
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wecker hinzufügen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time picker button
            ElevatedButton(
              onPressed: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                  builder: (BuildContext context, Widget? child) {
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                      child: child!,
                    );
                  },
                );
                if (picked != null && picked != _selectedTime) {
                  setState(() {
                    _selectedTime = picked;
                  });
                }
              },
              child: Text('Zeit auswählen: ${_formatTimeOfDay(_selectedTime)}'),
            ),
            const SizedBox(height: 20),
            // Day selection
            const Text('Tage auswählen:', style: TextStyle(color: Colors.white)),
            Wrap(
              spacing: 8.0,
              children: List.generate(7, (index) {
                return FilterChip(
                  label: Text(['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'][index]),
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
            // Sound selection dropdown
            DropdownButton<String>(
              value: _selectedSound.isEmpty ? null : _selectedSound,
              hint: const Text('Weckton auswählen'),
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
            // Sound preview button
            if (_selectedSound.isNotEmpty)
              ElevatedButton(
                onPressed: () async {
                  await _audioPlayer
                      .play(AssetSource('sounds/$_selectedSound'));
                },
                child: const Text('Ton abspielen'),
              ),
            const SizedBox(height: 20),
            // Save alarm button
            ElevatedButton(
              onPressed: () {
                final newAlarm = {
                  'time': _formatTimeOfDay(_selectedTime),
                  'days': _selectedDays,
                  'sound': _selectedSound,
                  'isActive': true,
                };
                widget.onAlarmAdded(newAlarm);
                Navigator.pop(context);
              },
              child: const Text('Wecker speichern'),
            ),
          ],
        ),
      ),
    );
  }
}