// Add the path_provider package to your pubspec.yaml file.
import 'dart:io';
import 'package:path_provider/path_provider.dart';

// Get the application documents directory
Future<String> getFilePath() async {
  final directory = await getApplicationDocumentsDirectory();
  return File('${directory.path}/alarms.json').path;
}

// Write data to a file
Future<void> writeToFile(String data) async {
  final file = File(await getFilePath());
  await file.writeAsString(data);
}

// Read data from a file
Future<String> readFromFile() async {
  final file = File(await getFilePath());
  return file.readAsString();
}