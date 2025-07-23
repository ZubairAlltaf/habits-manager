import 'package:flutter/material.dart';
import 'package:habitmanager/screens/splash_screen.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/habit.dart';
import 'providers/habit_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.initFlutter();
  Hive.registerAdapter(HabitAdapter());
  await Hive.openBox<Habit>('habits');


  runApp(
    ChangeNotifierProvider(
      create: (_) => HabitProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        primaryColor: Color(0xFF4CAF50),
        cardColor: Color(0xFFE1F5FE),
        scaffoldBackgroundColor: Color(0xFFF5F5F5),
      ),
      home: SplashScreen(),
    );
  }
}

class HabitAdapter extends TypeAdapter<Habit> {
  @override
  final typeId = 0;

  @override
  Habit read(BinaryReader reader) {
    return Habit(
      id: reader.read(),
      name: reader.read(),
      icon: IconData(reader.read(), fontFamily: 'MaterialIcons'),
      createdAt: DateTime.parse(reader.read()),
      dailyStatus: Map<String, bool>.from(reader.read()),
      category: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer.write(obj.id);
    writer.write(obj.name);
    writer.write(obj.icon.codePoint);
    writer.write(obj.createdAt.toIso8601String());
    writer.write(obj.dailyStatus);
    writer.write(obj.category);
  }
}