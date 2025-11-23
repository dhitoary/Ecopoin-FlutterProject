import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../app/config/app_colors.dart';
import '../widgets/profile_menu_item.dart';
import '../widgets/stat_card.dart';
import '../../auth/screens/onboarding_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Fungsi Logout
  void _handleLogout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Ambil User saat ini
    final User? user = FirebaseAuth.instance.currentUser;
    final String displayName = user?.displayName ?? "Pengguna";
    final String email = user?.email ?? "email@unila.ac.id";

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 40),

            // --- HEADER PROFILE ---
            Center(
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 3),
                      color: Colors.white,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/profile_avatar.png',
                        fit: BoxFit.cover,
                        // Error builder agar tidak crash jika gambar tidak ada
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.grey,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nama User Asli
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),

                  // Email User Asli
                  Text(
                    email,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),

                  // Badge / Level
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "🌱 Eco Warrior",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // --- STATISTIK (Hapus const di sini) ---
            Row(
              children: [
                // Pastikan StatCard menerima parameter ini
                Expanded(
                  child: StatCard(
                    label: "Setoran",
                    value: "0",
                    icon: Icons.history,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCard(label: "Poin", value: "0", icon: Icons.star),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // --- MENU OPSI (Hapus const di ProfileMenuItem) ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ProfileMenuItem(
                    icon: Icons.person_outline,
                    title: "Edit Profil",
                    onTap: () {}, // Tambahkan onTap kosong jika wajib
                  ),
                  const Divider(height: 1),
                  ProfileMenuItem(
                    icon: Icons.lock_outline,
                    title: "Ganti Password",
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ProfileMenuItem(
                    icon: Icons.help_outline,
                    title: "Bantuan & FAQ",
                    onTap: () {},
                  ),
                  const Divider(height: 1),

                  // Tombol Logout
                  ProfileMenuItem(
                    icon: Icons.logout,
                    title: "Keluar",
                    isDestructive: true,
                    onTap: () => _handleLogout(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
