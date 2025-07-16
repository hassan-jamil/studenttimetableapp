import 'package:flutter/material.dart';

class Lecture {
  final String subject;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String day;

  Lecture({
    required this.subject,
    required this.startTime,
    required this.endTime,
    required this.day,
  });

  Map<String, dynamic> toJson() => {
    'subject': subject,
    'startTime': '${startTime.hour}:${startTime.minute}',
    'endTime': '${endTime.hour}:${endTime.minute}',
    'day': day,
  };

  static Lecture fromJson(Map<String, dynamic> json) {
    List<String> startParts = json['startTime'].split(':');
    List<String> endParts = json['endTime'].split(':');
    return Lecture(
      subject: json['subject'],
      startTime: TimeOfDay(
        hour: int.parse(startParts[0]),
        minute: int.parse(startParts[1]),
      ),
      endTime: TimeOfDay(
        hour: int.parse(endParts[0]),
        minute: int.parse(endParts[1]),
      ),
      day: json['day'],
    );
  }
}
