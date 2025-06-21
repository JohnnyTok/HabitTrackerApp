import 'package:flutter/material.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  void _showFeatureNotAvailable(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This feature is not yet available.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This is a demo. No cache will be cleared.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache "cleared"!')),
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader('Account'),
          _buildSettingItem(
            icon: Icons.person,
            title: 'Account Information',
            onTap: () => _showFeatureNotAvailable(context),
          ),
          _buildSettingItem(
            icon: Icons.lock,
            title: 'Privacy & Security',
            onTap: () => _showFeatureNotAvailable(context),
          ),
          _buildSettingItem(
            icon: Icons.notifications,
            title: 'Notification Preferences',
            onTap: () => _showFeatureNotAvailable(context),
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Preferences'),
          _buildSettingItem(
            icon: Icons.palette,
            title: 'Theme',
            trailing: const Text('System Default', style: TextStyle(color: Colors.grey)),
            onTap: () => _showFeatureNotAvailable(context),
          ),
          _buildSettingItem(
            icon: Icons.language,
            title: 'Language',
            trailing: const Text('English', style: TextStyle(color: Colors.grey)),
             onTap: () => _showFeatureNotAvailable(context),
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Data'),
          _buildSettingItem(
            icon: Icons.backup,
            title: 'Backup & Restore',
            onTap: () => _showFeatureNotAvailable(context),
          ),
          _buildSettingItem(
            icon: Icons.delete_sweep,
            title: 'Clear Cache',
            onTap: () => _showClearCacheDialog(context),
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Support'),
          _buildSettingItem(
            icon: Icons.help,
            title: 'Help Center',
            onTap: () => _showFeatureNotAvailable(context),
          ),
          _buildSettingItem(
            icon: Icons.feedback,
            title: 'Send Feedback',
            onTap: () => _showFeatureNotAvailable(context),
          ),
          
          const SizedBox(height: 40),
          Center(
            child: Text(
              'Habit Tracker v1.0.0',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.teal[800],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
    );
  }
}
