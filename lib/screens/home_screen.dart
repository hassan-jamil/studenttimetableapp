import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timetable_provider.dart';
import 'timetable_entry_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TimetableProvider>(context);
    final today = DateTime.now().weekday;
    final todayStr = days[today - 1];
    final todayLectures = provider.getLecturesByDay(todayStr);

    return Scaffold(
      appBar: AppBar(
        title: const Text("📘 My Timetable"),
        backgroundColor: Colors.deepPurple,
        elevation: 4,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: todayLectures.isEmpty
            ? Center(
          child: Text(
            'No lectures scheduled for today.',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        )
            : ListView.builder(
          itemCount: todayLectures.length,
          itemBuilder: (context, index) {
            final lecture = todayLectures[index];
            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                leading: CircleAvatar(
                  backgroundColor: Colors.deepPurple,
                  child: Text(
                    lecture.subject[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  lecture.subject,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${lecture.startTime.format(context)} - ${lecture.endTime.format(context)}',
                ),
                trailing: Icon(Icons.schedule, color: Colors.deepPurple),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TimetableEntryScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Lecture"),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}
