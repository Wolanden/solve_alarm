import 'package:flutter/material.dart';

class EditAlarmScreen extends StatefulWidget {
  const EditAlarmScreen({super.key});

  @override
  State<EditAlarmScreen> createState() => _EditAlarmScreenState();
}

class _EditAlarmScreenState extends State<EditAlarmScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Alarm'),
      ),
      body: const Center(
        child: Text(
          'Edit alarm #1',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
