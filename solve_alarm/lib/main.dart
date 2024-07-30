import 'package:flutter/material.dart';
import 'package:solve_alarm/pages/add_alarm_screen.dart';
import 'package:solve_alarm/pages/edit_alarm_screen.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alarm App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color.fromARGB(255, 49, 49, 49),
      ),
      home: const AlarmScreen(),
    );
  }
}
// Main screen of the alarm app
class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  List<Map<String, dynamic>> alarms = []; // List to store all alarms
  final AudioPlayer _audioPlayer = AudioPlayer(); // Audio player for alarm sounds
  Timer? _timer; // Timer to periodically check alarms
  Map<String, dynamic>? _currentlyRingingAlarm; // Currently active alarm
  DateTime? _lastAlarmTime;

  @override
  void initState() {
    super.initState();
    _startAlarmChecker();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
  // Start a periodic timer to check alarms
  void _startAlarmChecker() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _checkAlarms();
    });
  }
  // Check if any alarms should ring
  void _checkAlarms() {
    if (_currentlyRingingAlarm != null) {
      // An alarm is already ringing, don't check for new alarms
      return;
    }

      final now = DateTime.now();
    if (_lastAlarmTime != null && now.difference(_lastAlarmTime!).inMinutes < 1) {
      return;
    }

    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final currentDay = now.weekday - 1; // 0 for Monday, 6 for Sunday

    for (var alarm in alarms) {
      if (alarm['isActive'] && 
          alarm['time'] == currentTime && 
          alarm['days'][currentDay]) {
        _ringAlarm(alarm);
        break;
      }
    }
  }
  // Trigger the alarm
  void _ringAlarm(Map<String, dynamic> alarm) {
    setState(() {
      _currentlyRingingAlarm = alarm;
      _lastAlarmTime = DateTime.now();
    });
    _audioPlayer.play(AssetSource('sounds/${alarm['sound']}'));
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    _showAlarmDialog(alarm);
  }
  
  // Show a dialog when an alarm is ringing
  void _showAlarmDialog(Map<String, dynamic> alarm) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alarm!'),
          content: Text('Zeit: ${alarm['time']}'),
          actions: <Widget>[
            TextButton(
              child: const Text('Stoppen'),
              onPressed: () {
                _stopAlarm();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  // Stop the currently ringing alarm
  void _stopAlarm() {
    _audioPlayer.stop();
    setState(() {
      _currentlyRingingAlarm = null;
    });
  }
  // Add a new alarm to the list
  void _addAlarm(Map<String, dynamic> newAlarm) {
    setState(() {
      alarms.add({...newAlarm, 'isActive': true});
    });
  }
  // Toggle an alarm's active state
  void _toggleAlarmActive(int index, bool isActive) {
    setState(() {
      alarms[index]['isActive'] = isActive;
    });
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('S O L V E A L A R M',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 218, 209, 209),
      ),
      body: ListView.builder(
        itemCount: alarms.length,
        itemBuilder: (context, index) {
          final alarm = alarms[index];
          return Container(
            // ... (UI code for each alarm item)
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 112, 112, 112),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(alarm['time'],
                        style: const TextStyle(color: Colors.white, fontSize: 30)),
                    const Spacer(),
                    Switch(
                      value: alarm['isActive'],
                      onChanged: (value) {
                        _toggleAlarmActive(index, value);
                      },
                      activeColor: Colors.blue,
                    ),
                     Container(
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const EditAlarmScreen()));
                        },
                        color: Colors.white,
                        icon: const Icon(Icons.settings),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            alarms.removeAt(index);
                          });
                        },
                        icon: const Icon(Icons.delete),
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < 7; i++)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: alarm['days'][i] ? Colors.blue : Colors.grey,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'][i],
                          style: TextStyle(
                            color: alarm['days'][i] ? Colors.white : Colors.black,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddAlarmScreen(onAlarmAdded: _addAlarm)),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}