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

  Future<DocumentSnapshot> _getUserData() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return await _firestore.collection('users').doc(user.uid).get();
  }

  // LOGIKA LOGOUT YANG BENAR
  Future<void> _handleLogout() async {
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

    if (confirmed ?? false) {
      try {
        await _auth.signOut();
        if (mounted) {
          // PENTING: Gunakan pushAndRemoveUntil agar user tidak bisa menekan back kembali ke admin
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
        automaticallyImplyLeading: false, // Hilangkan tombol back di AppBar
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          bottom: 100,
        ), // Tambahkan padding bawah agar tidak tertutup navbar
        child: Column(
          children: [
            // 1. Header
            FutureBuilder<DocumentSnapshot>(
              future: _getUserData(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                final userData = snapshot.data!.data() as Map<String, dynamic>?;
                return ProfileHeaderWidget(
                  name: userData?['displayName'] ?? 'Admin',
                  role: 'Administrator',
                  photoUrl: userData?['photoUrl'] ?? '',
                );
              },
            ),

            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: VerificationSummaryWidget(
                verificationService: _verificationService,
              ),
            ),
            const SizedBox(height: 32),

            // 3. Menu Akun
            ProfileMenuSectionWidget(
              title: 'Pengaturan Akun',
              children: [
                ProfileMenuItemWidget(
                  icon: Icons.edit_rounded,
                  label: 'Edit Profil',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  ),
                ),
                ProfileMenuItemWidget(
                  icon: Icons.group_rounded,
                  label: 'Manajemen Pengguna',
                  divider: true,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserManagementScreen(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 4. Menu Aplikasi
            ProfileMenuSectionWidget(
              title: 'Pengaturan Aplikasi',
              children: [
                ProfileMenuItemWidget(
                  icon: Icons.tune_rounded,
                  label: 'Pengaturan',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AppSettingsScreen(),
                    ),
                  ),
                ),
                ProfileMenuItemWidget(
                  icon: Icons.help_outline_rounded,
                  label: 'Bantuan',
                  divider: false,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HelpSupportScreen(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // 5. TOMBOL LOGOUT (Paling Bawah)
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
          ],
        ),
      ),
    );
  }
}
