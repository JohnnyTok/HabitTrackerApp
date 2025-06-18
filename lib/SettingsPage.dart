import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;

  void _confirmResetHabits() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Reset All Habits"),
            content: const Text(
              "Are you sure you want to delete all habits? This action cannot be undone.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.teal),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Reset all habits logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("All habits have been reset."),
                    ),
                  );
                },
                child: const Text("Reset", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.teal[800],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Preferences",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),

          const SizedBox(height: 16),

          SwitchListTile(
            title: const Text("Dark Mode"),
            value: _isDarkMode,
            activeColor: Colors.teal,
            onChanged: (value) {
              setState(() {
                _isDarkMode = value;
              });
            },
          ),

          SwitchListTile(
            title: const Text("Enable Notifications"),
            value: _notificationsEnabled,
            activeColor: Colors.teal,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),

          const Divider(height: 32),

          const Text(
            "App Info",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.teal),
            title: const Text("App Version"),
            subtitle: const Text("1.0.0"),
          ),

          const Divider(height: 32),

          const Text(
            "Danger Zone",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text("Reset All Habits"),
            onTap: _confirmResetHabits,
          ),
        ],
      ),
    );
  }
}
