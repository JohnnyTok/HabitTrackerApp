import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  final List<Map<String, String>> faqs = const [
    {
      "question": "How do I add a new habit?",
      "answer":
          "Tap the '+' button on the Home screen, fill in the form, then save.",
    },
    {
      "question": "How do I edit or delete a habit?",
      "answer":
          "Go to Habit Management and tap the edit or delete icon next to a habit.",
    },
    {
      "question": "Why are my habits not appearing today?",
      "answer":
          "Make sure they are scheduled for today’s date. Use the date selector at the top.",
    },
    {
      "question": "How is my progress calculated?",
      "answer":
          "Your completion rate is based on the number of habits completed for the day.",
    },
    {
      "question": "Is my data saved permanently?",
      "answer":
          "Currently, data is stored in memory and will reset if the app restarts. Persistent storage is a future enhancement.",
    },
  ];

  void _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@habitracker.com',
      query: Uri.encodeFull(
        'subject=Habit Tracker Support&body=Hi, I need help with...',
      ),
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help & Support"),
        backgroundColor: Colors.teal[800],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Frequently Asked Questions",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 12),
          ...faqs.map(
            (faq) => ExpansionTile(
              title: Text(
                faq['question']!,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    faq['answer']!,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 32),

          const Text(
            "Still need help?",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "If your issue is not listed above, feel free to contact our support team.",
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _launchEmail,
            icon: const Icon(Icons.email),
            label: const Text("Contact Support"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal[800],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
