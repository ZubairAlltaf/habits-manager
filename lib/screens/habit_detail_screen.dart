import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/habit.dart';
import 'dart:collection';

class HabitDetailScreen extends StatefulWidget {
  final Habit habit;

  const HabitDetailScreen({Key? key, required this.habit}) : super(key: key);

  @override
  _HabitDetailScreenState createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  late final LinkedHashMap<DateTime, bool> _dailyStatusMap;
  late final DateTime _firstDay;
  late final DateTime _lastDay;

  @override
  void initState() {
    super.initState();
    _dailyStatusMap = _getDailyStatusMap();
    _firstDay = widget.habit.createdAt;
    _lastDay = DateTime.now();
  }

  LinkedHashMap<DateTime, bool> _getDailyStatusMap() {
    final map = <DateTime, bool>{};
    widget.habit.dailyStatus.forEach((dateString, status) {
      final date = DateTime.parse(dateString);
      map[DateTime.utc(date.year, date.month, date.day)] = status;
    });

    return LinkedHashMap<DateTime, bool>.from(
        Map.fromEntries(map.entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key))));
  }

  int _calculateLongestStreak() {
    if (_dailyStatusMap.isEmpty) return 0;

    int longestStreak = 0;
    int currentStreak = 0;
    DateTime? previousDay;

    for (var entry in _dailyStatusMap.entries) {
      if (entry.value) {
        if (previousDay != null && entry.key.difference(previousDay!).inDays == 1) {
          currentStreak++;
        } else {
          currentStreak = 1;
        }
      } else {
        currentStreak = 0;
      }

      if (currentStreak > longestStreak) {
        longestStreak = currentStreak;
      }
      previousDay = entry.key;
    }
    return longestStreak;
  }

  double _calculateCompletionRate() {
    if (widget.habit.dailyStatus.isEmpty) return 0.0;
    final completedCount = widget.habit.dailyStatus.values.where((status) => status).length;
    final totalDays = DateTime.now().difference(widget.habit.createdAt).inDays + 1;
    return (totalDays > 0) ? completedCount / totalDays : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final longestStreak = _calculateLongestStreak();
    final completionRate = _calculateCompletionRate();
    final totalCompletions = widget.habit.dailyStatus.values.where((s) => s).length;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsCard(longestStreak, completionRate, totalCompletions),
                  const SizedBox(height: 24),
                  Text(
                    'Progress Calendar',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildCalendar(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120.0,
      pinned: true,
      backgroundColor: Colors.teal,
      elevation: 2,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(
          widget.habit.name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        background: Hero(
          tag: 'habit-icon-${widget.habit.id}',
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade400, Colors.teal.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(
              widget.habit.icon,
              size: 60.0,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(int longestStreak, double completionRate, int totalCompletions) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Current\nStreak', '${widget.habit.calculateStreak()}d', Colors.orange),
            _buildStatItem('Longest\nStreak', '${longestStreak}d', Colors.blue),
            _buildStatItem('Completion\nRate', '${(completionRate * 100).toStringAsFixed(0)}%', Colors.green),
            _buildStatItem('Total\nDone', '$totalCompletions', Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: TableCalendar(
        firstDay: _firstDay,
        lastDay: _lastDay,
        focusedDay: _lastDay,
        calendarFormat: CalendarFormat.month,
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            final status = _dailyStatusMap[day];
            if (status == true) {
              return Center(child: CircleAvatar(backgroundColor: Colors.green.shade300, radius: 14, child: Text(day.day.toString(), style: const TextStyle(color: Colors.white))));
            } else if (status == false) {
              return Center(child: CircleAvatar(backgroundColor: Colors.red.shade200, radius: 14, child: Text(day.day.toString(), style: const TextStyle(color: Colors.white))));
            }
            return null;
          },
          todayBuilder: (context, day, focusedDay) {
            return Center(child: CircleAvatar(backgroundColor: Colors.teal.withOpacity(0.8), radius: 14, child: Text(day.day.toString(), style: const TextStyle(color: Colors.white))));
          },
        ),
        eventLoader: (day) {
          return _dailyStatusMap[day] != null ? [_dailyStatusMap[day]!] : [];
        },
      ),
    );
  }
}