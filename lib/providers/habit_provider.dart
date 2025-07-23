import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit.dart';

class HabitProvider with ChangeNotifier {
  final Box<Habit> _habitBox = Hive.box<Habit>('habits');
  List<Habit> _habits = [];

  HabitProvider() {
    _loadHabits();
    _habitBox.listenable().addListener(_loadHabits);
  }

  List<Habit> get habits => _habits;

  void _loadHabits() {
    _habits = _habitBox.values.toList();
    _habits.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
  }

  Future<void> addHabit(Habit habit) async {
    await _habitBox.put(habit.id, habit);
  }

  Future<void> toggleHabitStatus(String id, bool status) async {
    final habit = _habitBox.get(id);
    if (habit != null) {
      final today = DateTime.now().toIso8601String().split('T')[0];
      habit.dailyStatus[today] = status;
      await _habitBox.put(id, habit);
    }
  }

  Future<void> deleteHabit(String id) async {
    await _habitBox.delete(id);
  }

  @override
  void dispose() {
    _habitBox.listenable().removeListener(_loadHabits);
    super.dispose();
  }
}
