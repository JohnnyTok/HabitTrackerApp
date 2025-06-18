import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ProgressPage extends StatefulWidget {
  final List<Map<String, String>> habits;

  const ProgressPage({super.key, required this.habits});

  @override
  _ProgressPageState createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  late List<bool> completionStatus;
  final int _currentStreak = 7;
  final int _longestStreak = 14;
  double _completionRate = 0.75;

  @override
  void initState() {
    super.initState();
    completionStatus = List<bool>.filled(widget.habits.length, false);
  }

  @override
  Widget build(BuildContext context) {
    int completedCount = completionStatus.where((status) => status).length;
    int totalCount = widget.habits.length;
    double progress = totalCount > 0 ? completedCount / totalCount : 0;

    // Calculate completion rate
    if (totalCount > 0) {
      _completionRate = completedCount / totalCount;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Progress'),
        backgroundColor: Colors.teal[800],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Overview
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
                      percent: progress,
                      center: Text(
                        '${(progress * 100).toStringAsFixed(0)}%',
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
                          value: '$_currentStreak days',
                          label: 'Current Streak',
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Completion Rate Card
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
                      'Completion Rate',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 15),
                    LinearProgressIndicator(
                      value: _completionRate,
                      minHeight: 12,
                      backgroundColor: Colors.grey[300],
                      color: Colors.teal,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(_completionRate * 100).toStringAsFixed(1)}% Success',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Longest streak: $_longestStreak days',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
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
                  children:
                      widget.habits.asMap().entries.map((entry) {
                        final index = entry.key;
                        final habit = entry.value;
                        final formattedTime =
                            habit['time'] != null
                                ? DateFormat(
                                  'EEE, MMM d • h:mm a',
                                ).format(DateTime.parse(habit['time']!))
                                : 'No time set';

                        return _buildHabitCard(
                          index: index,
                          habit: habit,
                          formattedTime: formattedTime,
                          isCompleted: completionStatus[index],
                        );
                      }).toList(),
                ),
          ],
        ),
      ),
    );
  }

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
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  Widget _buildHabitCard({
    required int index,
    required Map<String, String> habit,
    required String formattedTime,
    required bool isCompleted,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.teal[50],
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getCategoryIcon(habit['category']),
            color: Colors.teal[800],
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
          width: 100,
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
                onChanged: (value) {
                  setState(() {
                    completionStatus[index] = value ?? false;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.insights, size: 100, color: Colors.teal[200]),
          const SizedBox(height: 20),
          const Text(
            'No Habits to Track Yet',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            'Add some habits to start tracking your progress and building better routines.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal[800],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            child: const Text('Add Habits Now'),
          ),
        ],
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

  Color _getCategoryColor(String? category) {
    final colors = {
      'Health': Colors.green,
      'Work': Colors.blue,
      'Study': Colors.purple,
      'Exercise': Colors.orange,
      'Personal': Colors.pink,
      'Social': Colors.teal,
    };
    return colors[category] ?? Colors.grey;
  }
}
