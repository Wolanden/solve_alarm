import 'package:flutter/material.dart';
import 'package:solve_alarm/pages/add_alarm_screen.dart';
import 'package:solve_alarm/pages/edit_alarm_screen.dart';
import 'package:audioplayers/audioplayers.dart';

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
  List<Map<String, dynamic>> alarms = [];
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _addAlarm(Map<String, dynamic> newAlarm) {
    setState(() {
      alarms.add(newAlarm);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('S O L V E A L A R M', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 218, 209, 209),
      ),
      body: ListView.builder(
        itemCount: alarms.length,
        itemBuilder: (context, index) {
          final alarm = alarms[index];
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
                Text(alarm['time'], style: const TextStyle(color: Colors.white, fontSize: 30)),
                const Spacer(),
                IconButton(
                  onPressed: () async {
                    if (alarm['sound'] != null && alarm['sound'].isNotEmpty) {
                      await _audioPlayer.play(AssetSource('sounds/${alarm['sound']}'));
                    }
                  },
                  icon: const Icon(Icons.play_arrow),
                  color: Colors.white,
                ),
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const EditAlarmScreen()));
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddAlarmScreen(onAlarmAdded: _addAlarm)),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}