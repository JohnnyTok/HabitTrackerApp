import 'package:flutter/material.dart';

class Habit {
  final String name;
  int currentStreak;
  int longestStreak;
  List<String> badges;

  Habit({
    required this.name,
    this.currentStreak = 0,
    this.longestStreak = 0,
    List<String>? badges,
  }) : badges = badges ?? [];

  // Named constructor for creating a Habit from a Map
  Habit.fromMapInternal(Map<String, dynamic> map)
    : name = map['name'] ?? 'Unnamed Habit',
      currentStreak =
          map['currentStreak'] is int
              ? map['currentStreak']
              : int.tryParse(map['currentStreak']?.toString() ?? '0') ?? 0,
      longestStreak =
          map['longestStreak'] is int
              ? map['longestStreak']
              : int.tryParse(map['longestStreak']?.toString() ?? '0') ?? 0,
      badges = map['badges'] != null ? List<String>.from(map['badges']) : [];

  void updateStreak(bool completedToday) {
    if (completedToday) {
      currentStreak++;
      if (currentStreak > longestStreak) longestStreak = currentStreak;
      _checkAndAwardBadge();
    } else {
      currentStreak = 0;
    }
  }

  void _checkAndAwardBadge() {
    const milestones = [3, 7, 30];
    for (var milestone in milestones) {
      if (currentStreak == milestone && !badges.contains("$milestone-day")) {
        badges.add("$milestone-day");
      }
    }
  }
}

class StreaksRewardsWidget extends StatelessWidget {
  final Habit habit;

  const StreaksRewardsWidget({super.key, required this.habit});

  Widget _buildBadge(String label) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.teal[700],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              habit.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Current Streak: ${habit.currentStreak} days"),
            Text("Longest Streak: ${habit.longestStreak} days"),
            const SizedBox(height: 8),
            Wrap(
              children: habit.badges.map((b) => _buildBadge("🏅 $b")).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
