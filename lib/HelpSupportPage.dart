import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSupportCard(
            icon: Icons.help_outline,
            title: 'FAQs',
            subtitle: 'Find answers to common questions',
            onTap: () => _showInfoDialog(
              context,
              'FAQs',
              'The Frequently Asked Questions section is coming soon!',
            ),
          ),
          _buildSupportCard(
            icon: Icons.contact_support,
            title: 'Contact Support',
            subtitle: 'Get in touch with our support team',
            onTap: () => _showInfoDialog(
              context,
              'Contact Support',
              'To contact support, please email us at support@habittracker.com.',
            ),
          ),
          _buildSupportCard(
            icon: Icons.video_library,
            title: 'Video Tutorials',
            subtitle: 'Watch guides on using the app',
            onTap: () => _showInfoDialog(
              context,
              'Video Tutorials',
              'Video tutorials are currently in production and will be available shortly.',
            ),
          ),
          _buildSupportCard(
            icon: Icons.bug_report,
            title: 'Report a Bug',
            subtitle: 'Found an issue? Let us know',
            onTap: () => _showInfoDialog(
              context,
              'Report a Bug',
              'To report a bug, please send a detailed description to bugs@habittracker.com.',
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionHeader('Contact Information'),
          _buildContactInfo(Icons.email, 'Email', 'support@habittracker.com'),
          _buildContactInfo(Icons.phone, 'Phone', '+1 (555) 123-4567'),
          _buildContactInfo(Icons.language, 'Website', 'www.habittracker.com'),
          const SizedBox(height: 40),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Our support team is available Monday-Friday, 9AM-5PM EST. '
              'We typically respond within 24 hours.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.teal[50],
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.teal, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildContactInfo(IconData icon, String type, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                type,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
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
}
