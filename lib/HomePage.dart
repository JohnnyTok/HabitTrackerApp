import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'ProfilePage.dart';
import 'HabitManagementPage.dart';
import 'LogoutPage.dart';
import 'ProgressPage.dart';
import 'HelpSupportPage.dart';
import 'SettingsPage.dart'; // <-- Add this import

class HomePage extends StatefulWidget {
  final String username;

  const HomePage({super.key, required this.username});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, String>> habits = [];
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  int selectedDayIndex = DateTime.now().weekday - 1;
  Map<int, bool> habitCompletionStatus = {};

  @override
  void initState() {
    super.initState();
    // Initialize completion status for all habits
    for (int i = 0; i < habits.length; i++) {
      habitCompletionStatus[i] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> weekDates = _getCurrentWeekDates();

    return Scaffold(
      appBar: AppBar(
        title:
            isSearching
                ? TextField(
                  controller: searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: "Search habits...",
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, color: Colors.white70),
                    hintStyle: TextStyle(color: Colors.white70),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (query) => setState(() => searchQuery = query),
                )
                : const Text(
                  'Today',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
        backgroundColor: Colors.teal[800],
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed:
                () => setState(() {
                  isSearching = !isSearching;
                  if (!isSearching) {
                    searchController.clear();
                    searchQuery = '';
                  }
                }),
          ),
        ],
      ),
      drawer: AppDrawer(
        username: widget.username,
        habits: habits,
        onUpdateHabits: updateHabits,
      ),
      body: Column(
        children: [
          // Date selector container with fixed height
          Container(
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _buildDateSelector(weekDates),
          ),

          // Main content area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header showing selected date
                  Padding(
                    padding: const EdgeInsets.only(top: 16, left: 8),
                    child: Text(
                      'Habits for ${DateFormat('EEEE, MMMM dd').format(weekDates[selectedDayIndex])}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stats summary
                  _buildStatsSummary(),
                  const SizedBox(height: 16),

                  // FIX: Use Flexible instead of Expanded for variable content
                  Flexible(
                    flex: 1,
                    child:
                        habits.isEmpty ? _buildEmptyState() : _buildHabitList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal[800],
        child: const Icon(Icons.add, color: Colors.white),
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => HabitManagementPage(
                      habits: habits,
                      onUpdateHabits: updateHabits,
                    ),
              ),
            ),
      ),
    );
  }

  // FIX: Updated empty state with constrained height
  Widget _buildEmptyState() {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.checklist,
                size: 60,
                color: Colors.teal[200],
              ), // Reduced size
              const SizedBox(height: 16), // Reduced spacing
              const Text(
                'No habits scheduled',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8), // Reduced spacing
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Add habits using the + button below or from Habit Management',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSummary() {
    int completedCount =
        habitCompletionStatus.values.where((status) => status).length;
    int totalCount = getFilteredHabits().length;
    double progress = totalCount > 0 ? completedCount / totalCount : 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.teal[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DAILY PROGRESS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  color: Colors.teal,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$completedCount of $totalCount habits completed',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitList() {
    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children:
          getFilteredHabits()
              .asMap()
              .entries
              .map((entry) => _buildHabitCard(entry.key, entry.value))
              .toList(),
    );
  }

  Widget _buildHabitCard(int index, Map<String, String> habit) {
    bool isCompleted = habitCompletionStatus[index] ?? false;
    String timeString = habit['time'] ?? '';
    DateTime? habitTime;

    try {
      habitTime = DateFormat('yyyy-MM-dd HH:mm').parse(timeString);
    } catch (e) {
      // Handle parsing error
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.teal[50],
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getCategoryIcon(habit['category']),
            color: Colors.teal[800],
          ),
        ),
        title: Text(
          habit['name'] ?? 'Unnamed Habit',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration:
                isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
            color: isCompleted ? Colors.grey : Colors.black,
          ),
        ),
        subtitle:
            habitTime != null
                ? Text(
                  DateFormat('h:mm a').format(habitTime),
                  style: TextStyle(
                    color: isCompleted ? Colors.grey[400] : Colors.grey[600],
                  ),
                )
                : null,
        trailing: Checkbox(
          value: isCompleted,
          activeColor: Colors.teal,
          onChanged:
              (value) =>
                  setState(() => habitCompletionStatus[index] = value ?? false),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'health':
        return Icons.favorite;
      case 'work':
        return Icons.work;
      case 'study':
        return Icons.school;
      case 'exercise':
        return Icons.directions_run;
      case 'personal':
        return Icons.person;
      case 'social':
        return Icons.people;
      default:
        return Icons.check_circle;
    }
  }

  List<Map<String, String>> getFilteredHabits() {
    List<DateTime> weekDates = _getCurrentWeekDates();
    DateTime selectedDate = weekDates[selectedDayIndex];

    return habits.where((habit) {
      bool matchesSearch = habit['name']!.toLowerCase().contains(
        searchQuery.toLowerCase(),
      );
      try {
        DateTime habitDate = DateFormat(
          'yyyy-MM-dd HH:mm',
        ).parse(habit['time']!);
        bool matchesDate =
            habitDate.year == selectedDate.year &&
            habitDate.month == selectedDate.month &&
            habitDate.day == selectedDate.day;
        return matchesSearch && matchesDate;
      } catch (e) {
        return false;
      }
    }).toList();
  }

  void updateHabits(List<Map<String, String>> updatedHabits) {
    setState(() {
      habits = updatedHabits;
      // Update completion status for new habits
      for (int i = 0; i < habits.length; i++) {
        habitCompletionStatus.putIfAbsent(i, () => false);
      }
    });
  }

  Widget _buildDateSelector(List<DateTime> dates) {
    DateTime today = DateTime.now();
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: dates.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final date = dates[index];
        bool isSelected = selectedDayIndex == index;
        bool isToday =
            date.day == today.day &&
            date.month == today.month &&
            date.year == today.year;

        return GestureDetector(
          onTap: () => setState(() => selectedDayIndex = index),
          child: Container(
            width: 64,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: isSelected ? Colors.teal[800] : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: isToday ? Border.all(color: Colors.teal, width: 2) : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('E').format(date),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.teal[50],
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.teal[800] : Colors.teal,
                    ),
                  ),
                ),
                if (isToday && !isSelected)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Colors.teal,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<DateTime> _getCurrentWeekDates() {
    DateTime now = DateTime.now();
    int currentWeekday = now.weekday;
    DateTime monday = now.subtract(Duration(days: currentWeekday - 1));
    return List.generate(7, (index) => monday.add(Duration(days: index)));
  }
}

class AppDrawer extends StatelessWidget {
  final String username;
  final List<Map<String, String>> habits;
  final Function(List<Map<String, String>>) onUpdateHabits;

  const AppDrawer({
    super.key,
    required this.username,
    required this.habits,
    required this.onUpdateHabits,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Drawer header with user info
            UserAccountsDrawerHeader(
              accountName: Text(
                username,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text("$username@habitracker.com"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.teal[800],
                child: Text(
                  username.substring(0, 1).toUpperCase(),
                  style: const TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
              decoration: BoxDecoration(color: Colors.teal[800]),
            ),

            // Navigation items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    context,
                    icon: Icons.person,
                    title: 'Profile',
                    page: ProfilePage(username: username),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.list,
                    title: 'Habit Management',
                    page: HabitManagementPage(
                      habits: habits,
                      onUpdateHabits: onUpdateHabits,
                    ),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.bar_chart,
                    title: 'Progress',
                    page: ProgressPage(habits: habits),
                  ),
                  const Divider(),

                  _buildDrawerItem(
                    context,
                    icon: Icons.settings,
                    title: 'Settings',
                    page: SettingsPage(), // Placeholder
                  ),
                  // FIX: Link Help & Support to the real page
                  _buildDrawerItem(
                    context,
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    page: HelpSupportPage(),
                  ),
                  const Divider(),
                  _buildDrawerItem(
                    context,
                    icon: Icons.logout,
                    title: 'Logout',
                    page: const LogoutPage(),
                    isLogout: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget page,
    bool isLogout = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.red : Colors.teal[800]),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? Colors.red : Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing:
          isLogout ? null : const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {
        Navigator.pop(context); // Close drawer
        if (isLogout) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => page),
            (route) => false,
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        }
      },
    );
  }
}
