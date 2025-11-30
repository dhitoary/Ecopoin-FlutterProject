import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import Service & Widgets
import '../../../../services/verification_service.dart';
import '../widgets/profile_header_widget.dart';
import '../widgets/verification_summary_widget.dart';
import '../widgets/profile_menu_section_widget.dart';
import '../widgets/profile_menu_item_widget.dart';

// Import Halaman Tujuan (Navigasi)
import 'edit_profile_screen.dart';
import 'user_management_screen.dart';
import 'app_settings_screen.dart';
import 'help_support_screen.dart';
import '../../../user/auth/screens/login_screen.dart'; // Untuk navigasi logout

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({Key? key}) : super(key: key);

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  late final VerificationService _verificationService;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _verificationService = VerificationService();
  }

  // Mengambil data admin dari Firestore
  Future<DocumentSnapshot> _getUserData() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return await _firestore.collection('users').doc(user.uid).get();
  }

  // Fungsi Logout
  Future<void> _handleLogout() async {
    // Tampilkan dialog konfirmasi
    if (mounted) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Logout'),
            content: const Text('Apakah Anda yakin ingin logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Color(0xFFFF3B30)),
                ),
              ),
            ],
          );
        },
      );

      // Jika user klik 'Logout'
      if (confirmed ?? false) {
        try {
          await _auth.signOut();
          if (mounted) {
            // Navigasi kembali ke halaman Login Utama & hapus semua route sebelumnya
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error logout: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Admin'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        automaticallyImplyLeading: false, // Hilangkan tombol back default
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Profile Header (Foto, Nama, Role)
            FutureBuilder<DocumentSnapshot>(
              future: _getUserData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 250,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: Text('Gagal memuat profil')),
                  );
                }

                final userData = snapshot.data!.data() as Map<String, dynamic>?;

                // Fallback data jika null
                final name =
                    userData?['displayName'] ?? userData?['name'] ?? 'Admin';
                final photoUrl = userData?['photoUrl'] ?? '';
                final role = (userData?['role'] ?? 'Admin')
                    .toString()
                    .toUpperCase();

                return ProfileHeaderWidget(
                  name: name,
                  role: role,
                  photoUrl: photoUrl,
                );
              },
            ),

            const SizedBox(height: 16),

            // 2. Verification Summary Card (Ringkasan Kinerja)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: VerificationSummaryWidget(
                verificationService: _verificationService,
              ),
            ),

            const SizedBox(height: 32),

            // 3. Menu Section: Pengaturan Akun
            ProfileMenuSectionWidget(
              title: 'Pengaturan Akun',
              children: [
                ProfileMenuItemWidget(
                  icon: Icons.edit_rounded,
                  label: 'Edit Profil',
                  onTap: () {
                    // Navigasi ke Edit Profil
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    ).then((_) => setState(() {})); // Refresh setelah kembali
                  },
                ),
                ProfileMenuItemWidget(
                  icon: Icons.group_rounded,
                  label: 'Manajemen Pengguna',
                  divider: true,
                  onTap: () {
                    // Navigasi ke Manajemen Pengguna
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserManagementScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 4. Menu Section: Pengaturan Aplikasi
            ProfileMenuSectionWidget(
              title: 'Pengaturan Aplikasi',
              children: [
                ProfileMenuItemWidget(
                  icon: Icons.tune_rounded,
                  label: 'Pengaturan Aplikasi',
                  onTap: () {
                    // Navigasi ke Settings
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AppSettingsScreen(),
                      ),
                    );
                  },
                ),
                ProfileMenuItemWidget(
                  icon: Icons.help_outline_rounded,
                  label: 'Bantuan & Dukungan',
                  divider: false,
                  onTap: () {
                    // Navigasi ke Help
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HelpSupportScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            // 5. Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _handleLogout,
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF3B30),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
