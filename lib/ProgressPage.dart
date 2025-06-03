import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Ensure intl is added in pubspec.yaml

class ProgressPage extends StatefulWidget {
  final List<Map<String, String>> habits; // Receive habit data from Habit Management

  const ProgressPage({super.key, required this.habits});

  @override
  _ProgressPageState createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  // Track which habits are completed. Initialize based on the number of habits.
  late List<bool> completionStatus;

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Progress'),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header and progress card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Scheduled Habits',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    // Rounded progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 12,
                        backgroundColor: Colors.grey[300],
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$completedCount of $totalCount habits completed',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            // Expanded habit list
            Expanded(
              child: widget.habits.isEmpty
                  ? const Center(
                      child: Text(
                        'No habits scheduled yet.\nAdd some habits to track your progress.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: widget.habits.length,
                      itemBuilder: (context, index) {
                        final habit = widget.habits[index];
                        // Format the scheduled time string using intl
                        final formattedTime = habit['time'] != null
                            ? DateFormat('EEE, d MMM yyyy • h:mm a').format(
                                DateTime.parse(habit['time']!))
                            : 'No time set';

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            title: Text(
                              habit['name'] ?? 'Unnamed Habit',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text("Scheduled for: $formattedTime"),
                            trailing: Checkbox(
                              activeColor: Colors.green,
                              value: completionStatus[index],
                              onChanged: (value) {
                                setState(() {
                                  completionStatus[index] = value ?? false;
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
