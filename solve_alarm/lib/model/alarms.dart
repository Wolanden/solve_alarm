
import 'dart:convert';

class Alarms {
  List<Alarm> alarms = [];

  String toJson() {
    return jsonEncode(alarms);
  }
}

class Alarm {
  bool active = true;
  String time = "";
  List<bool> weekdays = [false, false, false, false, false, false, false];
  String sound = "";

  Alarm({
    required this.active, 
    required this.time, 
    required this.weekdays, 
    required this.sound
    });

  Alarm.fromJson(Map<String, dynamic> json) {
    active = json['active'];
    time = json['time'];
    weekdays = json['weekdays'].cast<bool>();
    sound = json['sound'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['active'] = active;
    data['time'] = time;
    data['weekdays'] = weekdays;
    data['sound'] = sound;
    return data;
  }
}