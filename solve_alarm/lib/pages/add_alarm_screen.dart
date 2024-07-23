import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

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
            ElevatedButton(
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.audio,
                  allowedExtensions: ['mp3'],
                );

                if (result != null) {
                  setState(() {
                    _selectedSound = result.files.single.path!;
                  });
                }
              },
              child: Text(_selectedSound.isEmpty ? 'Select Alarm Sound' : 'Sound: ${_selectedSound.split('/').last}'),
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