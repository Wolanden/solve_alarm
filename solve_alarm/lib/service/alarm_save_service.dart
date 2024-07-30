import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:solve_alarm/model/alarms.dart';

class AlarmSaveService {
  String key = 'alarms';
  String defaultAlarms = "[{\"active\": true,\"time\": \"06:12\",\"weekdays\": [true, false, false, false, false, true, false],\"sound\": \"Allstar.mp3\"},{\"active\": false,\"time\":\"20:12\",\"weekdays\": [false, true, false, false, true, false, false], \"sound\": \"BlackBanjocore.mp3\"},{\"active\": true,\"time\": \"11:12\",\"weekdays\": [false, false, true, true, false, false, false], \"sound\": \"BlackBanjocore.mp3\"}]";

  Future<List<Alarm>> loadAlarms() async {
    String key = 'alarms';
    
    final prefs = await SharedPreferences.getInstance();

    String? savedContent = prefs.getString(key);

    if (savedContent == "" || savedContent == null) {
      await prefs.setString(key, defaultAlarms);
    }
    
    var jsonString = prefs.getString(key);

    var alarmsJson = jsonDecode(jsonString!);

    List<Alarm> alarms = [];

    for (var alarm in alarmsJson) {
      alarms.add(Alarm.fromJson(alarm));
    }

    return alarms;
  }

  Future<void> persistAlarms(List<Alarm> persistingAlarms) async {
    final prefs = await SharedPreferences.getInstance();
    Alarms alarms = Alarms();
    alarms.alarms = persistingAlarms;
    prefs.setString(key, alarms.toJson());
  }
}