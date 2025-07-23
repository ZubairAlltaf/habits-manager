import 'package:flutter/cupertino.dart';

class Habit {
  final String id;
  final String name;
  final IconData icon;
  final DateTime createdAt;
  final Map<String, bool> dailyStatus;
  final String category;

  Habit({
    required this.id,
    required this.name,
    required this.icon,
    required this.createdAt,
    required this.dailyStatus,
    this.category = 'General',
  });

  int calculateStreak() {
    int streak = 0;
    DateTime current = DateTime.now();

    final today = current.toIso8601String().split('T')[0];
    bool todayChecked = dailyStatus[today] == true;

    if (todayChecked) {
      while (true) {
        final date = current.toIso8601String().split('T')[0];
        if (dailyStatus[date] == true) {
          streak++;
          current = current.subtract(Duration(days: 1));
        } else {
          break;
        }
      }
    } else {

      current = current.subtract(Duration(days: 1));
      final yesterday = current.toIso8601String().split('T')[0];
      if (dailyStatus[yesterday] != true) return 0;

      while (true) {
        final date = current.toIso8601String().split('T')[0];
        if (dailyStatus[date] == true) {
          streak++;
          current = current.subtract(Duration(days: 1));
        } else {
          break;
        }
      }
    }
    return streak;
  }
}