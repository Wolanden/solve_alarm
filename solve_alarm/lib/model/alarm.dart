import 'dart:ffi';

class Alarm {
  final Bool active;
  final String time;
  final List weekdays;
  final String sound;

  Alarm(this.active, this.time, this.weekdays, this.sound);
}