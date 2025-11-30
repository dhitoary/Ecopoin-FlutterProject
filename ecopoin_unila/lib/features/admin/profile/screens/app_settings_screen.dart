import 'package:flutter/material.dart';
// Import Absolute
import 'package:ecopoin_unila/app/config/app_colors.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  bool _emailNotif = true;
  bool _pushNotif = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Pengaturan Aplikasi',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16, bottom: 8),
            child: Text(
              "Notifikasi",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text("Notifikasi Email"),
                  subtitle: const Text("Terima laporan harian via email"),
                  value: _emailNotif,
                  activeColor: AppColors.primary,
                  onChanged: (val) => setState(() => _emailNotif = val),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text("Push Notification"),
                  subtitle: const Text("Notifikasi setoran baru di HP"),
                  value: _pushNotif,
                  activeColor: AppColors.primary,
                  onChanged: (val) => setState(() => _pushNotif = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.only(left: 16, bottom: 8),
            child: Text(
              "Tampilan",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              title: const Text("Mode Gelap"),
              value: _darkMode,
              activeColor: AppColors.primary,
              onChanged: (val) {
                setState(() => _darkMode = val);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Fitur tema sedang dalam pengembangan"),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
