import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/lecture.dart';
import '../notification_service.dart'; // ✅ Import the NotificationService

class TimetableProvider extends ChangeNotifier {
  List<Lecture> _lectures = [];
  List<Lecture> get lectures => _lectures;

  TimetableProvider() {
    loadLectures();
  }

  void addLecture(Lecture lecture) {
    _lectures.add(lecture);
    NotificationService.scheduleLectureNotification(lecture); // ✅ Schedule notification when added
    saveLectures();
    notifyListeners();
  }

  void deleteLecture(int index) {
    _lectures.removeAt(index);
    saveLectures();
    notifyListeners();
    // ❌ Optional: Cancel notification here if using fixed IDs
  }

  void saveLectures() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonList = _lectures.map((e) => json.encode(e.toJson())).toList();
    prefs.setStringList('timetable', jsonList);
  }

  void loadLectures() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? jsonList = prefs.getStringList('timetable');
    if (jsonList != null) {
      _lectures = jsonList.map((e) => Lecture.fromJson(json.decode(e))).toList();

      // ✅ Reschedule notifications when loading lectures
      for (final lecture in _lectures) {
        NotificationService.scheduleLectureNotification(lecture);
      }

      notifyListeners();
    }
  }

  List<Lecture> getLecturesByDay(String day) {
    return _lectures.where((lecture) => lecture.day == day).toList();
  }
}
