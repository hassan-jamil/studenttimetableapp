import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/timetable_provider.dart';
import 'screens/home_screen.dart';
import 'notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local notifications
  await NotificationService.initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TimetableProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Student Timetable App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: HomeScreen(),
      ),
    );
  }
}
