import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:confetti/confetti.dart';
import '../providers/habit_provider.dart';
import '../widgets/habit_card.dart';
import 'add_habit_screen.dart';
import 'start_walk_screen.dart';
import '../models/habit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';
  final ConfettiController _confettiController = ConfettiController(duration: const Duration(seconds: 1));

  final List<String> motivationalQuotes = [
    "The secret of getting ahead is getting started.",
    "You don't have to be great to start, but you have to start to be great.",
    "A year from now you may wish you had started today.",
    "Success is the sum of small efforts, repeated day in and day out.",
    "The journey of a thousand miles begins with a single step."
  ];

  late final String _currentQuote = motivationalQuotes[Random().nextInt(motivationalQuotes.length)];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF2c3e50);
    const Color accentColor = Color(0xFF1abc9c);
    const Color backgroundColor = Color(0xFFf4f6f8);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("HabitFlow", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.directions_walk, size: 28),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => StartWalkScreen())),
          ),
        ],
      ),
      body: Consumer<HabitProvider>(
        builder: (context, habitProvider, child) {
          final habits = habitProvider.habits;
          final filteredHabits = _selectedCategory == 'All'
              ? habits
              : habits.where((h) => h.category == _selectedCategory).toList();

          final today = DateTime.now().toIso8601String().split('T')[0];
          int completedToday = habits.where((h) => h.dailyStatus[today] == true).length;
          double progress = habits.isEmpty ? 0.0 : completedToday / habits.length;

          if (progress == 1.0 && completedToday > 0) {
            _confettiController.play();
          }

          return Stack(
            alignment: Alignment.topCenter,
            children: [
              ListView(
                children: [
                  _Header(progress: progress, quote: _currentQuote),
                  _WeeklyChart(habits: habits),
                  _CategoryPills(
                    selectedCategory: _selectedCategory,
                    onCategorySelected: (category) => setState(() => _selectedCategory = category),
                  ),
                  if (filteredHabits.isEmpty)
                    _EmptyState(category: _selectedCategory)
                  else
                    _HabitList(habits: filteredHabits, habitProvider: habitProvider),
                  const SizedBox(height: 80),
                ],
              ),
              ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddHabitScreen())),
        backgroundColor: accentColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}


class _Header extends StatelessWidget {
  final double progress;
  final String quote;
  const _Header({required this.progress, required this.quote});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF2c3e50),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '"$quote"',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Today's Progress", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(
                width: 70,
                height: 70,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: progress),
                  duration: const Duration(milliseconds: 1000),
                  builder: (context, value, child) => Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: value,
                        strokeWidth: 7,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1abc9c)),
                      ),
                      Center(child: Text("${(value * 100).toInt()}%", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final List<Habit> habits;
  const _WeeklyChart({required this.habits});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(20),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Weekly Consistency", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              height: 120,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          return Text(days[value.toInt()], style: const TextStyle(fontSize: 10));
                        },
                        reservedSize: 16,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barGroups: _getChartData(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _getChartData() {
    final List<double> dailyPercentages = List.filled(7, 0.0);
    final today = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final day = today.subtract(Duration(days: today.weekday - 1 - i));
      if (habits.isNotEmpty) {
        final dayKey = day.toIso8601String().split('T')[0];
        final completed = habits.where((h) => h.dailyStatus[dayKey] == true).length;
        dailyPercentages[i] = (completed / habits.length) * 100;
      }
    }

    return List.generate(7, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: dailyPercentages[i],
            color: const Color(0xFF1abc9c),
            width: 12,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    });
  }
}

class _CategoryPills extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;
  const _CategoryPills({required this.selectedCategory, required this.onCategorySelected});

  @override
  Widget build(BuildContext context) {
    final categories = ['All', 'Health', 'Productivity', 'Learning', 'Self-Care', 'Others'];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_) => onCategorySelected(category),
              selectedColor: const Color(0xFF2c3e50),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          );
        },
      ),
    );
  }
}

class _HabitList extends StatelessWidget {
  final List<Habit> habits;
  final HabitProvider habitProvider;
  const _HabitList({required this.habits, required this.habitProvider});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      itemCount: habits.length,
      itemBuilder: (context, index) {
        final habit = habits[index];
        return Slidable(
          key: ValueKey(habit.id),
          endActionPane: ActionPane(
            motion: const StretchMotion(),
            children: [
              SlidableAction(
                onPressed: (context) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Delete Habit"),
                      content: Text("Are you sure you want to delete '${habit.name}'?"),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                        TextButton(
                          onPressed: () {
                            habitProvider.deleteHabit(habit.id);
                            Navigator.pop(context);
                          },
                          child: const Text("Delete", style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Delete',
                borderRadius: BorderRadius.circular(16),
              ),
            ],
          ),
          child: HabitCard(
            habit: habit,
            onToggle: (id, status) => habitProvider.toggleHabitStatus(id, status),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String category;
  const _EmptyState({required this.category});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50.0),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.inbox_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            Text("No habits in '$category'", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
