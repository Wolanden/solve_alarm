import 'package:flutter/material.dart';
import 'package:solve_alarm/model/alarms.dart';
import 'package:solve_alarm/pages/add_alarm_screen.dart';
import 'package:solve_alarm/pages/edit_alarm_screen.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:solve_alarm/service/alarm_save_service.dart';
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

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});
  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> { 
  List<Alarm> alarms = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _timer;
  Alarm? _currentlyRingingAlarm;
  DateTime? _lastAlarmTime;

  _loadAlarms() async {
    List<Alarm> fetchedAlarms = await AlarmSaveService().loadAlarms();
    setState(() {
      alarms = fetchedAlarms;
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();    
    _timer?.cancel();
    super.dispose();
  } 

  @override
  void initState() {
    super.initState();
    _loadAlarms();    
    _startAlarmChecker();
  }

  void _startAlarmChecker() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _checkAlarms();
    });
  }

  void _checkAlarms() {
    if (_currentlyRingingAlarm != null) {
      return;
    }

      final now = DateTime.now();
    if (_lastAlarmTime != null && now.difference(_lastAlarmTime!).inMinutes < 1) {
      return;
    }

    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final currentDay = now.weekday - 1; // 0 for Monday, 6 for Sunday

    for (var alarm in alarms) {
      if (alarm.active &&
          alarm.time == currentTime &&
          alarm.weekdays[currentDay]) {
        _ringAlarm(alarm);
        break;
      }
    }
  }

  void _ringAlarm(Alarm alarm) {
    setState(() {
      _currentlyRingingAlarm = alarm;
      _lastAlarmTime = DateTime.now();
    });
    _audioPlayer.play(AssetSource('sounds/${alarm.sound}'));
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    _showAlarmDialog(alarm);
  }

  void _showAlarmDialog(Alarm alarm) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alarm!'),
          content: Text('Zeit: ${alarm.time}'),
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

  void _stopAlarm() {
    _audioPlayer.stop();
    setState(() {
      _currentlyRingingAlarm = null;
    });
  }

  void persistAlarms() async {
    await AlarmSaveService().persistAlarms(alarms);
  }

  void _addAlarm(Alarm newAlarm) {
    setState(() {      
      newAlarm.active = true;
      alarms.add(newAlarm);
    });
    persistAlarms();
  }

  void _removeAlarm(int index) {
    setState(() {
      alarms.removeAt(index);
    });
    persistAlarms();
  }

  void _toggleAlarmActive(int index, bool active) {
    setState(() {
      alarms[index].active = active;
    });
    persistAlarms();
  }

  void _editAlarm(int index, Alarm updatedAlarm) {
    setState(() {
      alarms[index] = updatedAlarm;
    });
    persistAlarms();
  }

  Container alarmPanel(Alarm alarm, int index) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 112, 112, 112),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(alarm.time,
              style: const TextStyle(color: Colors.white, fontSize: 30)),
          const Spacer(),
          Switch(
            value: alarm.active,
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
                      builder: (context) => EditAlarmScreen(
                        alarm: alarm,
                        onAlarmEdited: (updatedAlarm) {
                          _editAlarm(index, updatedAlarm);
                        },
                      )
                    )
                  );
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
                _removeAlarm(index);
              },
              icon: const Icon(Icons.delete),
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
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
          return alarmPanel(alarm, index);
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