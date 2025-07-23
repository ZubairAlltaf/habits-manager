import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../screens/habit_detail_screen.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final Function(String, bool) onToggle;

  const HabitCard({Key? key, required this.habit, required this.onToggle}) : super(key: key);

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Health':
        return Colors.cyan.shade600;
      case 'Productivity':
        return Colors.amber.shade600;
      case 'Learning':
        return Colors.teal.shade600;
      case 'Self-Care':
        return Colors.orange.shade600;
      default:
        return Colors.cyan.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final isChecked = habit.dailyStatus[today] ?? false;
    final streak = habit.calculateStreak();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HabitDetailScreen(habit: habit),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 18,
              offset: const Offset(6, 6),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.8),
              blurRadius: 18,
              offset: const Offset(-6, -6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        _getCategoryColor(habit.category),
                        _getCategoryColor(habit.category).withOpacity(0.6),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(4, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    habit.icon,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Text(
                    habit.name,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: isChecked ? Colors.grey.shade600 : Colors.black87,
                      decoration: isChecked ? TextDecoration.lineThrough : TextDecoration.none,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      streak > 0 ? Icons.local_fire_department_rounded : Icons.schedule,
                      color: streak > 0 ? Colors.amber.shade800 : Colors.grey.shade500,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      streak > 0 ? '$streak Day Streak' : 'Start Today',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: streak > 0 ? Colors.amber.shade900 : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                Transform.scale(
                  scale: 1.6,
                  child: Checkbox(
                    value: isChecked,
                    onChanged: (value) {
                      if (value != null) onToggle(habit.id, value); // Safe null check
                    },
                    activeColor: Colors.cyan.shade700,
                    shape: const CircleBorder(),
                    side: BorderSide(color: Colors.grey.shade300, width: 2),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}