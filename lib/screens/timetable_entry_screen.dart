import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lecture.dart';
import '../providers/timetable_provider.dart';
import '../notification_service.dart';

class TimetableEntryScreen extends StatefulWidget {
  @override
  _TimetableEntryScreenState createState() => _TimetableEntryScreenState();
}

class _TimetableEntryScreenState extends State<TimetableEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  String _selectedDay = 'Monday';
  TimeOfDay _startTime = TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = TimeOfDay(hour: 10, minute: 0);

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Lecture'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subject Field
                  TextFormField(
                    controller: _subjectController,
                    decoration: InputDecoration(
                      labelText: 'Subject',
                      prefixIcon: Icon(Icons.book),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter subject' : null,
                  ),
                  SizedBox(height: 20),

                  // Start Time
                  Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.deepPurple),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text('Start Time: ${_startTime.format(context)}',
                            style: TextStyle(fontSize: 16)),
                      ),
                      TextButton(
                        onPressed: () => _pickTime(isStart: true),
                        child: Text('Pick Start'),
                      ),
                    ],
                  ),
                  Divider(),

                  // End Time
                  Row(
                    children: [
                      Icon(Icons.timer_off, color: Colors.deepPurple),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text('End Time: ${_endTime.format(context)}',
                            style: TextStyle(fontSize: 16)),
                      ),
                      TextButton(
                        onPressed: () => _pickTime(isStart: false),
                        child: Text('Pick End'),
                      ),
                    ],
                  ),
                  Divider(),

                  // Day Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedDay,
                    decoration: InputDecoration(
                      labelText: 'Select Day',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
                        .map((day) =>
                        DropdownMenuItem(value: day, child: Text(day)))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedDay = value!),
                  ),
                  SizedBox(height: 30),

                  // Save Button
                  Center(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.save),
                      label: Text('Save Lecture'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final lecture = Lecture(
                            subject: _subjectController.text,
                            startTime: _startTime,
                            endTime: _endTime,
                            day: _selectedDay,
                          );

                          Provider.of<TimetableProvider>(context, listen: false)
                              .addLecture(lecture);

                          NotificationService.scheduleLectureNotification(lecture);

                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
