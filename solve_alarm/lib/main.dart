import 'package:flutter/material.dart';
import 'package:solve_alarm/model/alarms.dart';
import 'package:solve_alarm/pages/add_alarm_screen.dart';
import 'package:solve_alarm/pages/edit_alarm_screen.dart';
import 'package:solve_alarm/pages/sudoku.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:solve_alarm/service/alarm_save_service.dart';
import 'dart:async';
import 'dart:math';

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
    if (_lastAlarmTime != null &&
        now.difference(_lastAlarmTime!).inMinutes < 1) {
      return;
    }

    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
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
    Random random = Random();
    int choice = random.nextInt(2);
    
  switch (choice) {
      case 0:
        _askFirstQuestion(alarm);
        break;
      case 1:
        _openSudokuPage();
        break;
      case 2:
        _askMathQuestion(alarm);
        break;
    }
  }

  void _askMathQuestion(Alarm alarm) {
    int number1 = Random().nextInt(20);
    int number2 = Random().nextInt(20);

    String operation = '+';
    int correctAnswer = 0;
    int wrongAnswer = Random().nextInt(20);

    if (Random().nextInt(0) == 1) {
      operation = '-';
      correctAnswer = number1 - number2;
    } else {
      correctAnswer = number1 + number2;
    }

    String question = number1.toString() + " " + operation + " " + number2.toString();

    TextButton correctButton = TextButton(
      child: Text(correctAnswer.toString()),
      onPressed: () {
        Navigator.of(context).pop();
        _stopAlarm();
      },
    );
    
    TextButton wrongButton = TextButton(
      child: Text(wrongAnswer.toString()),
      onPressed: () {
        Navigator.of(context).pop();
        _askMathQuestion(alarm);
      },
    );

    List<Widget> buttons = [];

    if (Random().nextInt(0) == 1) {
      buttons.add(wrongButton);
      buttons.add(correctButton);
    } else {
      buttons.add(correctButton);
      buttons.add(wrongButton);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(question),
          actions: buttons,
        );
      },
    );
  }

  void _askFirstQuestion(Alarm alarm) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Do you want to turn the alarm off?'),
          actions: <Widget>[
            TextButton(

              child: const Text('YES', style: TextStyle(color: Colors.green)),
              onPressed: () {
                Navigator.of(context).pop();
                _askSecondQuestion(alarm);
              },
            ),
            TextButton(
              child: const Text('NO', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _askFirstQuestion(alarm);
              },
            ),
          ],
        );
      },
    );
  }

  void _askSecondQuestion(Alarm alarm) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          actions: <Widget>[
            TextButton(
              child: const Text('NO', style: TextStyle(color: Colors.green)),
              onPressed: () {
                Navigator.of(context).pop();
                _askFirstQuestion(alarm);
              },
            ),
            TextButton(
              child: const Text('YES', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _askThirdQuestion(alarm);
              },
            ),
          ],
        );
      },
    );
  }

  void _askThirdQuestion(Alarm alarm) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you awake?'),
          actions: <Widget>[
            TextButton(
              child: const Text('YES', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _askFourthQuestion(alarm);
              },
            ),
            TextButton(
              child: const Text('NO', style: TextStyle(color: Colors.green)),
              onPressed: () {
                Navigator.of(context).pop();
                _askFirstQuestion(alarm);
              },
            ),
          ],
        );
      },
    );
  }

  void _askFourthQuestion(Alarm alarm) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you lying to me?'),
          actions: <Widget>[
            TextButton(
              child: const Text('YES', style: TextStyle(color: Colors.green)),
              onPressed: () {
                Navigator.of(context).pop();
                _askFirstQuestion(alarm);
              },
            ),
            TextButton(
              child: const Text('NO', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _askFifthQuestion(alarm);
              },
            ),
          ],
        );
      },
    );
  }

  void _askFifthQuestion(Alarm alarm) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Do you regret getting this app?'),
          actions: <Widget>[
            TextButton(
              child: const Text('YES', style: TextStyle(color: Colors.green)),
              onPressed: () {
                Navigator.of(context).pop();
                _askFirstQuestion(alarm);
              },
            ),
            TextButton(
              child: const Text('NO', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _askSixthQuestion(alarm);
              },
            ),
          ],
        );
      },
    );
  }

  void _askSixthQuestion(Alarm alarm) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Have a nice day.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK', style: TextStyle(color: Colors.green)),
              onPressed: () {
                Navigator.of(context).pop();
                _stopAlarm();
              },
            ),
          ],
        );
      },
    );
  }

  void _openSudokuPage() {
    Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => SudokuPage(
          onSudokuSolved: () {
            _stopAlarm();
          },
        ),
      ),
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
                            )));
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
