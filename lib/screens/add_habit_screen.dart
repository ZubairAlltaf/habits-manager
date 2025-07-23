import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({Key? key}) : super(key: key);

  @override
  _AddHabitScreenState createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedCategory = 'Health';
  IconData _selectedIcon = Icons.fitness_center;

  final Map<String, Color> _categories = {
    'Health': Colors.green.shade600,
    'Productivity': Colors.blue.shade600,
    'Learning': Colors.purple.shade600,
    'Self-Care': Colors.orange.shade600,
    'Finance': Colors.pink.shade600,
    'Others': Colors.teal.shade600,
  };

  final List<IconData> _iconOptions = [
    Icons.fitness_center, Icons.local_drink, Icons.book, Icons.spa,
    Icons.nightlight_round, Icons.directions_run, Icons.brush, Icons.music_note,
    Icons.fastfood, Icons.computer, Icons.attach_money, Icons.family_restroom,
    Icons.palette, Icons.code, Icons.headset, Icons.mediation,
  ];

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );
    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _createHabit() {
    if (!_formKey.currentState!.validate()) return;

    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    final name = _nameController.text.trim();
    if (habitProvider.habits.any((h) => h.name.toLowerCase() == name.toLowerCase())) {
      _showSnackbar("Habit already exists!", isError: true);
      return;
    }

    final newHabit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      category: _selectedCategory,
      icon: _selectedIcon,
      createdAt: DateTime.now(),
      dailyStatus: {},
    );

    habitProvider.addHabit(newHabit);
    _showSnackbar("Habit created successfully!");
    Navigator.pop(context);
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        duration: const Duration(seconds: 3),
        elevation: 10,
        action: SnackBarAction(
          label: 'DISMISS',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 24),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Craft Your Habit',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
                letterSpacing: 0.8,
              ),
            ),
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade100, Colors.teal.shade300],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            expandedHeight: 120.0,
          ),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPreviewCard(),
                      const SizedBox(height: 24),
                      _buildSectionHeader(
                        title: "Habit Name",
                        subtitle: "Choose a memorable name to stay motivated.",
                      ),
                      _buildNameField(),
                      const SizedBox(height: 32),
                      _buildSectionHeader(
                        title: "Category",
                        subtitle: "Group your habits for easy tracking.",
                      ),
                      _buildCategorySelector(),
                      const SizedBox(height: 32),
                      _buildSectionHeader(
                        title: "Icon",
                        subtitle: "Pick an icon to make it yours.",
                      ),
                      _buildIconSelector(),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildCreateButton(),
    );
  }

  Widget _buildPreviewCard() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 15,
              offset: const Offset(5, 5),
            ),
            BoxShadow(
              color: Colors.white,
              blurRadius: 15,
              offset: const Offset(-5, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [_categories[_selectedCategory]!, _categories[_selectedCategory]!.withOpacity(0.7)],
                ),
              ),
              child: Icon(_selectedIcon, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _nameController.text.isEmpty ? 'Your Habit' : _nameController.text,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    _selectedCategory,
                    style: TextStyle(
                      fontSize: 16,
                      color: _categories[_selectedCategory],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildNameField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: const Offset(4, 4),
          ),
          BoxShadow(
            color: Colors.white,
            blurRadius: 10,
            offset: const Offset(-4, -4),
          ),
        ],
      ),
      child: TextFormField(
        controller: _nameController,
        decoration: InputDecoration(
          hintText: 'e.g., Daily Meditation',
          hintStyle: TextStyle(color: Colors.grey.shade400),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        ),
        validator: (value) => (value == null || value.trim().isEmpty)
            ? 'Please enter a habit name'
            : null,
        onChanged: (value) => setState(() {}),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: _categories.entries.map((entry) {
        final category = entry.key;
        final color = entry.value;
        final isSelected = _selectedCategory == category;

        return GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            setState(() {
              _selectedCategory = category;
              _scaleController.reset();
              _scaleController.forward();
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: isSelected
                  ? [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(4, 4),
                ),
                BoxShadow(
                  color: Colors.white,
                  blurRadius: 12,
                  offset: const Offset(-4, -4),
                ),
              ]
                  : [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 6,
                  offset: const Offset(2, 2),
                ),
                BoxShadow(
                  color: Colors.white,
                  blurRadius: 6,
                  offset: const Offset(-2, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedOpacity(
                  opacity: isSelected ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.check_circle,
                    size: 20,
                    color: isSelected ? color : Colors.transparent,
                  ),
                ),
                if (isSelected) const SizedBox(width: 8),
                Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? color : Colors.black87,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIconSelector() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double padding = 24.0;
        const double spacing = 16.0;
        const int crossAxisCount = 4;
        final double iconSize = (constraints.maxWidth - padding * 2 - spacing * (crossAxisCount - 1)) / crossAxisCount;

        return Container(
          padding: const EdgeInsets.all(padding),
          margin: const EdgeInsets.symmetric(horizontal: 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 10,
                offset: const Offset(4, 4),
              ),
              BoxShadow(
                color: Colors.white,
                blurRadius: 10,
                offset: const Offset(-4, -4),
              ),
            ],
          ),
          child: GridView.count(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: _iconOptions.map((icon) {
              final isSelected = _selectedIcon == icon;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  setState(() {
                    _selectedIcon = icon;
                    _scaleController.reset();
                    _scaleController.forward();
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: isSelected
                        ? [
                      BoxShadow(
                        color: _categories[_selectedCategory]!.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(4, 4),
                      ),
                      BoxShadow(
                        color: Colors.white,
                        blurRadius: 12,
                        offset: const Offset(-4, -4),
                      ),
                    ]
                        : [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 6,
                        offset: const Offset(2, 2),
                      ),
                      BoxShadow(
                        color: Colors.white,
                        blurRadius: 6,
                        offset: const Offset(-2, -2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      size: iconSize * 0.5,
                      color: isSelected ? _categories[_selectedCategory] : Colors.grey.shade500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildCreateButton() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 24),
        child: ElevatedButton(
          onPressed: _createHabit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
            shadowColor: Colors.transparent,
            side: BorderSide(color: _categories[_selectedCategory]!, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle,
                color: _categories[_selectedCategory],
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'CREATE HABIT',
                style: TextStyle(
                  color: _categories[_selectedCategory],
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}