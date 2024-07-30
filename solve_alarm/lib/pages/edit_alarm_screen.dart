import '../model/alarms.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class EditAlarmScreen extends StatefulWidget {
  final Alarm alarm;
  final Function(Alarm) onAlarmEdited;

  const EditAlarmScreen({
    super.key,
    required this.alarm,
    required this.onAlarmEdited,
  });

  @override
  State<EditAlarmScreen> createState() => _EditAlarmScreenState();
}

class _EditAlarmScreenState extends State<EditAlarmScreen> {
  late TimeOfDay _selectedTime;
  late List<bool> _selectedDays;
  late String _selectedSound;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

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
  void initState() {
    super.initState();
    final timeParts = widget.alarm.time.split(':');
    _selectedTime = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );
    _selectedDays = List<bool>.from(widget.alarm.weekdays);
    _selectedSound = widget.alarm.sound;
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wecker bearbeiten'),
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
                  builder: (BuildContext context, Widget? child) {
                    return MediaQuery(
                      data: MediaQuery.of(context)
                          .copyWith(alwaysUse24HourFormat: true),
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
            const Text('Tage auswählen:',
                style: TextStyle(color: Colors.white)),
            Wrap(
              spacing: 8.0,
              children: List.generate(7, (index) {
                return FilterChip(
                  label:
                      Text(['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'][index]),
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
              value: _selectedSound,
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
                    _isPlaying = false;
                  });
                  _audioPlayer.stop();
                }
              },
            ),
            if (_selectedSound.isNotEmpty)
              ElevatedButton(
                onPressed: () async {
                  if (_isPlaying) {
                    _audioPlayer.stop();
                  } else {
                    await _audioPlayer
                        .play(AssetSource('sounds/$_selectedSound'));
                  }
                  setState(() {
                    _isPlaying = !_isPlaying;
                  });
                },
                child: Text(_isPlaying ? 'Ton stoppen' : 'Ton abspielen'),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Alarm updatedAlarm = Alarm(
                  active: widget.alarm.active, 
                  time: _formatTimeOfDay(_selectedTime), 
                  weekdays: _selectedDays, 
                  sound: _selectedSound
                  );
                  
                widget.onAlarmEdited(updatedAlarm);
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
