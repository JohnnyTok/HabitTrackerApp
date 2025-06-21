import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ProgressPage extends StatefulWidget {
  final List<Map<String, String>> habits;
  final Map<String, bool> completionStatus; // Pass the completion status from HomePage

  const ProgressPage({
    super.key,
    required this.habits,
    required this.completionStatus, // Make completionStatus required
  });

  @override
  _ProgressPageState createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  // Use a map to store completion status for each habit based on its name (unique identifier)
  // This makes it more robust if the list order changes.
  // Note: For actual persistent completion status across sessions, this data
  // would need to be loaded from and saved to a database (e.g., Firestore).
  late Map<String, bool> _habitCompletionStatus; // Now mutable state

  // For a true streak calculation, you'd need historical completion data per day.
  // For this demo, currentStreak will represent 'habits completed today'.
  int _currentStreak = 0; // Initialize dynamically
  
  // Longest streak has been removed as per your request.
  // The concept of a longest streak would require persistent historical data,
  // which is beyond the scope of this demo's current data management.

  @override
  void initState() {
    super.initState();
    // Initialize completion status from passed habits from HomePage
    // Ensure that habits coming from HomePage are used to initialize _habitCompletionStatus
    _habitCompletionStatus = Map.from(widget.completionStatus);
    _calculateProgressStats(); // Calculate initial stats
  }

  // Method to calculate current progress and streak
  void _calculateProgressStats() {
    int completed = _habitCompletionStatus.values.where((status) => status).length;
    setState(() {
      _currentStreak = completed; // For demo, current streak is habits completed today
    });
  }

  // Helper method to get the current completion rate
  double _getOverallCompletionRate() {
    int completedCount = _habitCompletionStatus.values.where((status) => status).length;
    int totalCount = widget.habits.length;
    return totalCount > 0 ? completedCount / totalCount : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    int completedCount = _habitCompletionStatus.values.where((status) => status).length;
    int totalCount = widget.habits.length;
    double overallCompletionRate = _getOverallCompletionRate();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Progress', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal[800],
        iconTheme: const IconThemeData(color: Colors.white), // Set back icon color to white
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Overview Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Progress Overview',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Circular progress indicator
                    CircularPercentIndicator(
                      radius: 80,
                      lineWidth: 12,
                      percent: overallCompletionRate,
                      center: Text(
                        '${(overallCompletionRate * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      progressColor: Colors.teal,
                      backgroundColor: Colors.teal.shade100,
                      circularStrokeCap: CircularStrokeCap.round,
                    ),
                    const SizedBox(height: 20),

                    // Stats row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          icon: Icons.check_circle,
                          value: completedCount.toString(),
                          label: 'Completed',
                          color: Colors.green,
                        ),
                        _buildStatItem(
                          icon: Icons.timelapse,
                          value: (totalCount - completedCount).toString(),
                          label: 'Pending',
                          color: Colors.orange,
                        ),
                        _buildStatItem(
                          icon: Icons.local_fire_department,
                          value: '$_currentStreak habits', // Display current streak
                          label: 'Completed Today', // Label updated for clarity
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Completion Rate Card (now only showing Overall Completion Rate)
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overall Completion Rate',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 15),
                    LinearProgressIndicator(
                      value: overallCompletionRate,
                      minHeight: 12,
                      backgroundColor: Colors.grey[300],
                      color: Colors.teal,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    const SizedBox(height: 10), // Spacing after the progress bar
                    Center( // Center the completion rate text
                      child: Text(
                        '${(overallCompletionRate * 100).toStringAsFixed(1)}% Success',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Habits header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Your Habits (${widget.habits.length})',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Habit list
            widget.habits.isEmpty
                ? _buildEmptyState()
                : Column(
                    children: widget.habits.map((habit) {
                      final String habitId = habit['id'] ?? ''; // Use ID as key if available
                      final bool isCompleted = _habitCompletionStatus[habitId] ?? false;

                      final formattedTime = habit['time'] != null && habit['time']!.isNotEmpty
                          ? DateFormat('EEE, MMM d • h:mm a').format(
                              DateFormat('yyyy-MM-dd HH:mm').parse(habit['time']!))
                          : 'No time set';

                      return _buildHabitCard(
                        habit: habit,
                        formattedTime: formattedTime,
                        isCompleted: isCompleted,
                        onChanged: (value) {
                          setState(() {
                            _habitCompletionStatus[habitId] = value ?? false;
                            _calculateProgressStats(); // Recalculate when a habit is toggled
                          });
                        },
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  // Builds a single stat item for the overview
  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  // Builds an individual habit card for the list
  Widget _buildHabitCard({
    required Map<String, String> habit,
    required String formattedTime,
    required bool isCompleted,
    required ValueChanged<bool?> onChanged, // Callback for checkbox
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getCategoryColor(habit['category']).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getCategoryIcon(habit['category']),
            color: _getCategoryColor(habit['category']),
            size: 24,
          ),
        ),
        title: Text(
          habit['name'] ?? 'Unnamed Habit',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formattedTime,
              style: TextStyle(
                color: isCompleted ? Colors.grey[400] : Colors.grey[600],
                fontSize: 13,
              ),
            ),
            if (habit['category'] != null && habit['category']!.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getCategoryColor(habit['category']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  habit['category']!,
                  style: TextStyle(
                    color: _getCategoryColor(habit['category']),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        trailing: SizedBox(
          width: 100, // Adjusted width to prevent overflow
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CircularPercentIndicator(
                radius: 20,
                lineWidth: 3,
                percent: isCompleted ? 1.0 : 0.0,
                center: Icon(
                  isCompleted ? Icons.check : Icons.access_time,
                  size: 16,
                  color: isCompleted ? Colors.green : Colors.grey,
                ),
                progressColor: Colors.green,
                backgroundColor: Colors.grey.shade300,
              ),
              const SizedBox(width: 12),
              Checkbox(
                activeColor: Colors.green,
                value: isCompleted,
                onChanged: onChanged, // Use the passed onChanged callback
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Builds the empty state widget for the progress page
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.insights,
            size: 100,
            color: Colors.teal[200],
          ),
          const SizedBox(height: 20),
          const Text(
            'No Habits to Track Yet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            'Add some habits to start tracking your progress and building better routines.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Navigate back to the Home page, assuming it will then lead to Habit Management
              Navigator.pop(context);
            },
            style: Theme.of(context).elevatedButtonTheme.style, // Apply consistent style from main.dart
            child: const Text('Add Habits Now'),
          ),
        ],
      ),
    );
  }

  // Determines the icon for a given habit category
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

  // Determines the color for a given habit category
  Color _getCategoryColor(String? category) {
    final colors = {
      'Health': Colors.green,
      'Work': Colors.blue,
      'Study': Colors.purple,
      'Exercise': Colors.orange,
      'Personal': Colors.pink,
      'Social': Colors.teal,
      'General': Colors.grey, // Added a default color
    };
    return colors[category] ?? Colors.grey;
  }
}
