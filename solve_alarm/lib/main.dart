import 'package:flutter/material.dart';


// Entry point of the application
void main() {
  runApp(const MyApp());
}

/// The root widget of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solve Alarm',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const AlarmScreen(),
    );
  }
}

/// The main screen of the alarm app
class AlarmScreen extends StatelessWidget {
  const AlarmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('S O L V E A L A R M', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: const Center(
        child: Text(
          'No alarms set',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the AddAlarmScreen when the button is pressed
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

/// Screen for adding a new alarm
class AddAlarmScreen extends StatelessWidget {
  const AddAlarmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Alarm'),
      ),
      body: const Center(
        child: Text('Add new alarm here'),
      ),
    );
  }
}

// TODO: Future improvements
// 1. Implement state management (e.g., using Provider or Riverpod) to handle alarm data
// 2. Create a model class for Alarm to store alarm details
// 3. Implement local storage to persist alarms (e.g., using SharedPreferences or SQLite)
// 4. Add functionality to set alarm time, repeat options, and alarm sound
// 5. Implement alarm triggering and notification system
// 6. Add a list view to display multiple alarms on the main screen
// 7. Implement edit and delete functionality for existing alarms
// 8. Add settings page for app-wide configurations
// 9. Implement dark mode toggle and other theme options
// 10. Add animations for smoother transitions between screens