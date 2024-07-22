import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:solve_alarm/pages/add_alarm_screen.dart';
import 'package:solve_alarm/pages/edit_alarm_screen.dart';

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

class AlarmScreen extends StatelessWidget {
  const AlarmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('S O L V E A L A R M', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: Row(
        children: [
          Column(
            children: [
              const Text("06:30", style: TextStyle(color: Colors.white),),
              IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const EditAlarmScreen()));
                }, 
                color: Colors.white,
                icon: const Icon(Icons.edit),
              ),
              Container(
                color: Colors.red,
                child: IconButton(
                  onPressed: () { },
                  icon: const Icon(Icons.delete),
                  color: Colors.white,
                ),
              )
            ],
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Open new page to add alarm
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddAlarmScreen()),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}