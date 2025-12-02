// lib/screens/settings_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6D4C41),
        foregroundColor: Colors.white,
        title: const Text("সেটিংস"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text(
                FirebaseAuth.instance.currentUser?.displayName ?? "User",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                FirebaseAuth.instance.currentUser?.email ?? "No email",
              ),
            ),
          ),
          const SizedBox(height: 20),

          // DARK MODE – FIXED
          Consumer<ThemeProvider>(
            builder: (context, theme, child) {
              return Card(
                child: SwitchListTile(
                  secondary:
                      const Icon(Icons.dark_mode, color: Color(0xFF6D4C41)),
                  title:
                      const Text("ডার্ক মোড", style: TextStyle(fontSize: 17)),
                  value: theme.isDark,
                  onChanged: (value) {
                    theme.toggleDarkMode(); // CORRECT METHOD
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // FONT SIZE
          Consumer<ThemeProvider>(
            builder: (context, theme, child) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.font_download, color: Color(0xFF6D4C41)),
                          SizedBox(width: 12),
                          Text("ফন্ট সাইজ", style: TextStyle(fontSize: 17)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Slider(
                        min: 12,
                        max: 26,
                        divisions: 7,
                        value: theme.fontSize,
                        label: theme.fontSize.round().toString(),
                        onChanged: (value) => theme.setFontSize(value),
                      ),
                      Center(
                        child: Text(
                          "এটি পুরো অ্যাপে প্রয়োগ হবে",
                          style: TextStyle(
                              fontSize: theme.fontSize,
                              color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 40),

          // Logout
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("লগ আউট হয়েছে!")),
              );
            },
            child: const Text("লগ আউট",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
