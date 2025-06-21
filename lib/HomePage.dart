import 'package:flutter/material.dart';
import 'package:habit_tracker_app/HelpSupportPage.dart';
import 'package:habit_tracker_app/SettingPage.dart';
import 'package:intl/intl.dart';
import 'ProfilePage.dart';
import 'HabitManagementPage.dart';
import 'LogoutPage.dart';
import 'ProgressPage.dart';

class HomePage extends StatefulWidget {
  final String username;
  final String email;

  const HomePage({super.key, required this.username, required this.email});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // State for user profile data
  late String _currentUsername;
  late String _currentEmail;
  
  // State for habits
  List<Map<String, String>> habits = [];
  Map<String, bool> habitCompletionStatus = {};

  // State for UI
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Initialize profile state with data passed from SignInPage
    _currentUsername = widget.username;
    _currentEmail = widget.email;
  }

  // Callback function to update user profile from ProfilePage
  void _updateUserProfile(String newName, String newEmail) {
    setState(() {
      _currentUsername = newName;
      _currentEmail = newEmail;
    });
  }

  // Callback function to update habits from HabitManagementPage
  void updateHabits(List<Map<String, String>> updatedHabits) {
    setState(() {
      habits = updatedHabits;
      for (var habit in habits) {
        habitCompletionStatus.putIfAbsent(habit['id']!, () => false);
      }
    });
  }

  List<DateTime> get currentMonthDates {
    final now = selectedDate;
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    return List.generate(lastDayOfMonth.day, (i) => firstDayOfMonth.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSearching
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
            : const Text('Today'),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: () => setState(() {
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
        username: _currentUsername,
        email: _currentEmail,
        onUpdateProfile: _updateUserProfile, // Pass callback
        habits: habits,
        onUpdateHabits: updateHabits,
        habitCompletionStatus: habitCompletionStatus,
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: _buildVerticalDateScroller(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16, left: 8),
                    child: Text(
                      isSearching
                          ? 'Search results for "$searchQuery"'
                          : 'Habits for ${DateFormat('EEEE, MMMM dd').format(selectedDate)}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!isSearching) ...[
                    _buildStatsSummary(),
                    const SizedBox(height: 16),
                  ],
                  Expanded(
                    child: getFilteredHabits().isEmpty
                        ? _buildEmptyState()
                        : _buildHabitList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Habit',
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HabitManagementPage(
                habits: habits,
                onUpdateHabits: updateHabits,
              ),
            ),
          );
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.start, size: 80, color: Colors.teal[200]),
          const SizedBox(height: 16),
          const Text(
            'Ready to build habits?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Let's add your first one! Tap the + button to get started.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary() {
    final todaysHabits = getFilteredHabits();
    int completedCount = todaysHabits.where((h) => habitCompletionStatus[h['id']] == true).length;
    int totalCount = todaysHabits.length;
    double progress = totalCount > 0 ? completedCount / totalCount : 0;
    
    if (totalCount == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal[50],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('DAILY PROGRESS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.teal)),
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
              Text('${(progress * 100).toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Text('$completedCount of $totalCount habits completed', style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildHabitList() {
    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: getFilteredHabits().map((habit) => _buildHabitCard(habit)).toList(),
    );
  }

  Widget _buildHabitCard(Map<String, String> habit) {
    bool isCompleted = habitCompletionStatus[habit['id']] ?? false;
    String timeString = habit['time'] ?? '';
    DateTime? habitTime;
    try {
      habitTime = DateFormat('yyyy-MM-dd HH:mm').parse(timeString);
    } catch (e) {
      // Handle error
    }
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
            color: isCompleted ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: habitTime != null
            ? Text(
                isSearching 
                    ? DateFormat('MMM dd, h:mm a').format(habitTime)
                    : DateFormat('h:mm a').format(habitTime),
                style: TextStyle(color: isCompleted ? Colors.grey[400] : Colors.grey[600]),
              )
            : null,
        trailing: Checkbox(
          value: isCompleted,
          activeColor: Colors.teal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          onChanged: (value) => setState(() => habitCompletionStatus[habit['id']!] = value ?? false),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'health': return Icons.favorite;
      case 'work': return Icons.work;
      case 'study': return Icons.school;
      case 'exercise': return Icons.directions_run;
      case 'personal': return Icons.person;
      case 'social': return Icons.people;
      default: return Icons.check_circle;
    }
  }

  List<Map<String, String>> getFilteredHabits() {
    return habits.where((habit) {
      bool matchesSearch = habit['name']!.toLowerCase().contains(searchQuery.toLowerCase());
      if (!isSearching) {
        try {
          DateTime habitDate = DateFormat('yyyy-MM-dd HH:mm').parse(habit['time']!);
          bool matchesDate = habitDate.year == selectedDate.year &&
              habitDate.month == selectedDate.month &&
              habitDate.day == selectedDate.day;
          return matchesSearch && matchesDate;
        } catch (e) {
          return false;
        }
      }
      return matchesSearch;
    }).toList();
  }

  Widget _buildVerticalDateScroller() {
    DateTime today = DateTime.now();
    return ListView.builder(
      itemCount: currentMonthDates.length,
      itemBuilder: (context, index) {
        final date = currentMonthDates[index];
        bool isSelected = selectedDate.day == date.day && selectedDate.month == date.month;
        bool isToday = date.day == today.day && date.month == today.month && date.year == today.year;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedDate = date;
              if (isSearching) {
                isSearching = false;
                searchController.clear();
                searchQuery = '';
              }
            });
          },
          child: Container(
            height: 72,
            color: isSelected ? Colors.teal[800] : Colors.white,
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
                Text(
                  date.day.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.teal[800],
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
}

class AppDrawer extends StatelessWidget {
  final String username;
  final String email;
  final Function(String, String) onUpdateProfile;
  final List<Map<String, String>> habits;
  final Function(List<Map<String, String>>) onUpdateHabits;
  final Map<String, bool> habitCompletionStatus;
  
  const AppDrawer({
    super.key,
    required this.username,
    required this.email,
    required this.onUpdateProfile,
    required this.habits,
    required this.onUpdateHabits,
    required this.habitCompletionStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(username, style: const TextStyle(fontWeight: FontWeight.bold)),
              accountEmail: Text(email),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.teal[900],
                child: Text(
                  username.isNotEmpty ? username.substring(0, 1).toUpperCase() : 'U',
                  style: const TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.teal[800],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    context,
                    icon: Icons.person,
                    title: 'Profile',
                    page: ProfilePage(
                      username: username,
                      email: email,
                      onUpdateProfile: onUpdateProfile,
                    ),
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
                    page: ProgressPage(habits: habits, completionStatus: habitCompletionStatus),
                  ),
                  const Divider(),
                  _buildDrawerItem(
                    context,
                    icon: Icons.settings,
                    title: 'Settings',
                    page: const SettingPage(), 
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.help,
                    title: 'Help & Support',
                    page: const HelpSupportPage(), 
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
          color: isLogout ? Colors.red : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: isLogout ? null : const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {
        Navigator.pop(context);
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
