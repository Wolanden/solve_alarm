import 'dart:convert';

import 'package:solve_alarm/model/alarms.dart';
import 'package:solve_alarm/service/file_service.dart';

class JsonService {
  Future<List<Alarm>> loadAlarmsFromJson() async {
    await writeToFile("[{\"active\": true,\"time\": \"06:12\",\"weekdays\": [true, false, false, false, false, true, false],\"sound\": \"Allstar.mp3\"},{\"active\": false,\"time\":\"20:12\",\"weekdays\": [false, true, false, false, true, false, false], \"sound\": \"BlackBanjocore.mp3\"},{\"active\": true,\"time\": \"11:12\",\"weekdays\": [false, false, true, true, false, false, false], \"sound\": \"BlackBanjocore.mp3\"}]");

    List<Alarm> alarms = [];

    //var jsonString = await readFromFile();
//
    //var alarmsJson = jsonDecode(jsonString);

    //for (var alarm in alarmsJson) {
    //  alarms.add(Alarm.fromJson(alarm));
    //}

    return alarms;
  }
}
  

