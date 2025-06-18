import 'package:flutter/material.dart';
import 'streaks_rewards_widget.dart'; // <-- Import the widget and Habit class

class StreakPage extends StatelessWidget {
  final List<Habit> habits;

  const StreakPage({super.key, required this.habits});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Streaks & Rewards'),
        backgroundColor: Colors.teal[800],
      ),
      body:
          habits.isEmpty
              ? const Center(child: Text("No habits yet."))
              : ListView.builder(
                itemCount: habits.length,
                itemBuilder: (context, index) {
                  return StreaksRewardsWidget(habit: habits[index]);
                },
              ),
    );
  }
}
