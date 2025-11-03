import 'package:flutter/material.dart';
import '../../../../app/config/app_colors.dart';
import '../widgets/profile_menu_item.dart';
import '../widgets/stat_card.dart';

// Ganti StatelessWidget dengan isi yang baru
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        // Judul AppBar (bukan dari HTML)
        title: const Text(
          "Profil",
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24.0),
            // --- PROFILE HEADER ---
            // HTML: <div class="...rounded-full...w-32">
            const CircleAvatar(
              radius: 64, // w-32 (128px) / 2 = 64
              backgroundImage: AssetImage('assets/images/profile_avatar.png'),
            ),
            const SizedBox(height: 16.0),
            // HTML: <p class="...text-[22px] font-bold...">
            const Text(
              "Arfan Andhika Pramudya",
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4.0),
            // HTML: <p class="text-[#4c9a6c]...">
            const Text(
              "2315061019",
              style: TextStyle(color: AppColors.textGreen, fontSize: 16),
            ),
            const SizedBox(height: 24.0),

            // --- STATS CARDS ---
            // HTML: <div class="flex flex-wrap gap-4 p-4">
            // Kita gunakan Row + Expanded agar rapi dan responsif
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: const [
                  Expanded(
                    child: StatCard(title: "Poin Didapat", value: "1200"),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: StatCard(title: "Poin Tersedia", value: "300"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: StatCard(
                // Kartu ketiga
                title: "Total Setoran Selesai",
                value: "25",
              ),
            ),
            const SizedBox(height: 24.0),

            // --- MENU LIST ---
            // HTML: <div class="flex items-center gap-4...">
            ProfileMenuItem(
              title: "Edit Profil",
              icon: Icons.person_outline,
              onTap: () {},
            ),
            ProfileMenuItem(
              title: "Pengaturan Notifikasi",
              icon: Icons.notifications_none,
              onTap: () {},
            ),
            ProfileMenuItem(
              title: "Bantuan & FAQ",
              icon: Icons.help_outline,
              onTap: () {},
            ),
            ProfileMenuItem(
              title: "Tentang Aplikasi",
              icon: Icons.info_outline,
              onTap: () {},
            ),
            const Divider(height: 32, indent: 16, endIndent: 16),
            ProfileMenuItem(
              title: "Logout",
              icon: Icons.logout,
              onTap: () {
                // Tambahkan logika logout di sini
              },
              isLogout: true,
            ),
            const SizedBox(height: 24.0),
          ],
        ),
      ),
    );
  }
}
