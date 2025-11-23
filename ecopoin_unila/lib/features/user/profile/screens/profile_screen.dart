import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../app/config/app_colors.dart';
import '../../../../services/firestore_service.dart';
import '../widgets/profile_menu_item.dart';
import '../widgets/stat_card.dart';
import '../../auth/screens/onboarding_screen.dart';
import 'edit_profile_screen.dart'; // Import halaman edit

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
    final FirestoreService firestoreService = FirestoreService();
    final User? user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<DocumentSnapshot>(
      stream: firestoreService.getUserStream(),
      builder: (context, snapshot) {
        // Data Default
        String displayName = user?.displayName ?? "Pengguna";
        String email = user?.email ?? "";
        String phoneNumber = "-";
        int points = 0;
        double totalWeight = 0.0;

        // Jika data ada, ambil dari Firestore
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          displayName =
              data['displayName'] ?? displayName; // Ambil nama terbaru
          phoneNumber = (data['phoneNumber'] ?? "-").toString();
          points = data['points'] ?? 0;
          totalWeight = (data['totalDepositWeight'] ?? 0.0).toDouble();
        }

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
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 3,
                          ),
                          color: Colors.white,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/profile_avatar.png',
                            fit: BoxFit.cover,
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
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
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

                // --- STATISTIK ---
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: "Setoran (kg)",
                        value: totalWeight.toStringAsFixed(1),
                        icon: Icons.history,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        label: "Poin",
                        value: points.toString(),
                        icon: Icons.star,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // --- MENU OPSI ---
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Tombol Edit Profil
                      ProfileMenuItem(
                        icon: Icons.person_outline,
                        title: "Edit Profil",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfileScreen(
                                currentName: displayName,
                                currentPhone: phoneNumber,
                              ),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),

                      // Tombol Ganti Password
                      ProfileMenuItem(
                        icon: Icons.lock_outline,
                        title: "Ganti Password",
                        onTap: () async {
                          await firestoreService.sendPasswordResetEmail();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Link reset password telah dikirim ke $email",
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      const Divider(height: 1),

                      // Tombol Bantuan
                      ProfileMenuItem(
                        icon: Icons.help_outline,
                        title: "Bantuan & FAQ",
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Pusat Bantuan"),
                              content: const Text(
                                "Jika mengalami kendala, silakan hubungi admin di help@ecopoin.unila.ac.id",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Tutup"),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),

                      // Tombol Keluar
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
      },
    );
  }
}
