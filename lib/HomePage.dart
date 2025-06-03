import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'ProfilePage.dart';
import 'HabitManagementPage.dart';
import 'LogoutPage.dart';
import 'ProgressPage.dart';

class HomePage extends StatefulWidget {
  final String username;

  const HomePage({super.key, required this.username});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // The habits list holds maps with keys 'name' and 'time'
  List<Map<String, String>> habits = [];
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();
  bool isSearching = false;

  // The selected day index (0 for Monday ... 6 for Sunday)
  int selectedDayIndex = DateTime.now().weekday - 1;

  @override
  Widget build(BuildContext context) {
    List<DateTime> weekDates = _getCurrentWeekDates();

    return Scaffold(
      // AppBar now uses a dynamic title: a seach field when activated or a simple "Today" title.
      appBar: AppBar(
        title: isSearching
            ? TextField(
                controller: searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: "Search habits...",
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (query) {
                  setState(() {
                    searchQuery = query;
                  });
                },
                style: const TextStyle(color: Colors.white),
              )
            : const Text('Today'),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) {
                  searchController.clear();
                  searchQuery = '';
                }
              });
            },
          ),
        ],
        backgroundColor: const Color.fromARGB(255, 15, 57, 196),
      ),
      // The drawer receives the habit list and update callback.
      drawer: AppDrawer(
        username: widget.username,
        habits: habits,
        onUpdateHabits: updateHabits,
      ),
      // The page body starts with a bit of padding and uses a column layout.
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Horizontal date selector for the current week.
            _buildDateSelector(weekDates),
            const SizedBox(height: 12),
            // Dynamic header showing the selected date.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Habits for ${DateFormat('EEEE, dd MMMM yyyy').format(weekDates[selectedDayIndex])}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            // Habit list area: using Expanded so it fills remaining space.
            Expanded(
              child: habits.isEmpty
                  ? const Center(
                      child: Text(
                        'No habits yet.\nAdd some using the + button below in Habit Management.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView(
                      children: getFilteredHabits()
                          .map(
                            (habit) => Card(
                              elevation: 3,
                              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                title: Text(
                                  habit['name'] ?? '',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text("Scheduled for: ${habit['time'] ?? ''}"),
                                // You could add a trailing icon to mark as complete, etc.
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
      // Optional Floating Action Button to quickly launch Habit Management.
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HabitManagementPage(
                habits: habits,
                onUpdateHabits: updateHabits,
              ),
            ),
          );
        },
      ),
    );
  }

  /// Filters habits based on both the search query and the selected date.
  List<Map<String, String>> getFilteredHabits() {
    List<DateTime> weekDates = _getCurrentWeekDates();
    DateTime selectedDate = weekDates[selectedDayIndex];

    return habits.where((habit) {
      bool matchesSearch = habit['name']!
          .toLowerCase()
          .contains(searchQuery.toLowerCase());
      try {
        DateTime habitDate = DateFormat('yyyy-MM-dd HH:mm').parse(habit['time']!);
        bool matchesDate = habitDate.year == selectedDate.year &&
            habitDate.month == selectedDate.month &&
            habitDate.day == selectedDate.day;
        return matchesSearch && matchesDate;
      } catch (e) {
        // If parsing fails, skip the habit.
        return false;
      }
    }).toList();
  }

  /// Callback to update the list of habits (e.g., after adding/updating in Habit Management).
  void updateHabits(List<Map<String, String>> updatedHabits) {
    setState(() {
      habits = updatedHabits;
    });
  }

  /// Builds a horizontal date selector for the current week.
  Widget _buildDateSelector(List<DateTime> dates) {
    DateTime today = DateTime.now();
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          bool isSelected = selectedDayIndex == index;
          bool isToday = date.day == today.day &&
              date.month == today.month &&
              date.year == today.year;
          Color bgColor = isSelected ? (isToday ? Colors.red : Colors.teal) : Colors.grey.shade300;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDayIndex = index;
              });
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat.E().format(date), // Example: Mon, Tue, ...
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Returns a list of dates for the current week (starting on Monday).
  List<DateTime> _getCurrentWeekDates() {
    DateTime now = DateTime.now();
    int currentWeekday = now.weekday; // Monday = 1
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
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome,',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                Text(
                  username,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile Page'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage(username: username)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Habit Management'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HabitManagementPage(
                    habits: habits,
                    onUpdateHabits: onUpdateHabits,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Progress'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProgressPage(habits: habits)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LogoutPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
