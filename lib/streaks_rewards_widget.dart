// streaks_rewards_widget.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Habit {
  String name;
  String category;
  String time;
  int currentStreak;
  int longestStreak;
  List<String> badges;

  Habit({
    required this.name,
    required this.category,
    required this.time,
    this.currentStreak = 0,
    this.longestStreak = 0,
    List<String>? badges,
  }) : badges = badges ?? [];

  // Factory constructor for creating a Habit from a Map
  factory Habit.fromMapInternal(Map<String, dynamic> map) {
    return Habit(
      name: map['name'] ?? 'Unnamed Habit',
      category: map['category'] ?? '',
      time: map['time'] ?? '',
      currentStreak:
          map['currentStreak'] is int
              ? map['currentStreak']
              : int.tryParse(map['currentStreak']?.toString() ?? '0') ?? 0,
      longestStreak:
          map['longestStreak'] is int
              ? map['longestStreak']
              : int.tryParse(map['longestStreak']?.toString() ?? '0') ?? 0,
      badges:
          map['badges'] != null ? List<String>.from(map['badges'] as List) : [],
    );
  }

  /// Group and merge habits by name
  static List<Habit> groupAndMergeByName(List<Habit> habits) {
    final Map<String, Habit> merged = {};

    for (var habit in habits) {
      if (!merged.containsKey(habit.name)) {
        merged[habit.name] = Habit(
          name: habit.name,
          category: habit.category,
          time: habit.time,
          currentStreak: habit.currentStreak,
          longestStreak: habit.longestStreak,
          badges: List.from(habit.badges),
        );
      } else {
        final existing = merged[habit.name]!;

        // Keep the earliest time
        DateTime? currentTime = DateTime.tryParse(habit.time);
        DateTime? existingTime = DateTime.tryParse(existing.time);

        if (currentTime != null &&
            existingTime != null &&
            currentTime.isBefore(existingTime)) {
          existing.time = habit.time;
        }

        // Merge streaks
        existing.currentStreak =
            habit.currentStreak > existing.currentStreak
                ? habit.currentStreak
                : existing.currentStreak;

        existing.longestStreak =
            habit.longestStreak > existing.longestStreak
                ? habit.longestStreak
                : existing.longestStreak;

        // Merge badges
        for (var badge in habit.badges) {
          if (!existing.badges.contains(badge)) {
            existing.badges.add(badge);
          }
        }
      }
    }

    return merged.values.toList();
  }

  Future<void> saveStreak() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('streak_${name}_${category}_current', currentStreak);
    await prefs.setInt('streak_${name}_${category}_longest', longestStreak);
    await prefs.setStringList('streak_${name}_${category}_badges', badges);
  }

  Future<void> loadStreak() async {
    final prefs = await SharedPreferences.getInstance();
    currentStreak = prefs.getInt('streak_${name}_${category}_current') ?? 0;
    longestStreak = prefs.getInt('streak_${name}_${category}_longest') ?? 0;
    badges = prefs.getStringList('streak_${name}_${category}_badges') ?? [];
  }

  void updateStreak(bool completedToday) {
    if (completedToday) {
      currentStreak++;
      if (currentStreak > longestStreak) longestStreak = currentStreak;
      _checkAndAwardBadge();
    } else {
      currentStreak = 0;
    }
    saveStreak();
  }

  void _checkAndAwardBadge() {
    // Award badges for 3, 7, 14 days
    if (currentStreak >= 3 && !badges.contains("bronze")) {
      badges.add("bronze");
    }
    if (currentStreak >= 7 && !badges.contains("silver")) {
      badges.add("silver");
    }
    if (currentStreak >= 14 && !badges.contains("gold")) {
      badges.add("gold");
    }
  }
}

class StreaksRewardsWidget extends StatelessWidget {
  final Habit habit;

  const StreaksRewardsWidget({super.key, required this.habit});

  Widget _buildBadge(String badge) {
    String label = "";
    Color color = Colors.brown;
    String emoji = "🥉";
    if (badge == "bronze") {
      label = "Bronze";
      color = Colors.brown;
      emoji = "🥉";
    } else if (badge == "silver") {
      label = "Silver";
      color = Colors.grey;
      emoji = "🥈";
    } else if (badge == "gold") {
      label = "Gold";
      color = Colors.amber[700]!;
      emoji = "🥇";
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Always show all badges in order, even if not yet earned
    final badgeOrder = ['bronze', 'silver', 'gold'];
    final earnedBadges =
        badgeOrder.where((b) => habit.badges.contains(b)).toList();

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Habit info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text("Current Streak: ${habit.currentStreak} days"),
                  Text("Longest Streak: ${habit.longestStreak} days"),
                ],
              ),
            ),
            // Badges at right
            if (earnedBadges.isNotEmpty)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: earnedBadges.map(_buildBadge).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

Future<List<Habit>> getHabitsWithStreaks(
  List<Map<String, String>> habitMaps,
) async {
  final habits = habitMaps.map((m) => Habit.fromMapInternal(m)).toList();
  for (final habit in habits) {
    await habit.loadStreak();
  }
  return habits;
}
