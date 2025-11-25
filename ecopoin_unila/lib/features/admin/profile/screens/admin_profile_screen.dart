import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../services/verification_service.dart';
import '../widgets/profile_header_widget.dart';
import '../widgets/verification_summary_widget.dart';
import '../widgets/profile_menu_section_widget.dart';
import '../widgets/profile_menu_item_widget.dart';

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

  Future<void> _handleLogout() async {
    // Show confirmation dialog
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
                child: const Text('Logout', style: TextStyle(color: Color(0xFFFF3B30))),
              ),
            ],
          );
        },
      );

      if (confirmed ?? false) {
        try {
          await _auth.signOut();
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error logout: $e')),
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
        title: const Text('Profil'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            FutureBuilder<DocumentSnapshot>(
              future: _getUserData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 300,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: Text('Error loading profile')),
                  );
                }

                final userData = snapshot.data!.data() as Map<String, dynamic>?;
                if (userData == null) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: Text('User data not found')),
                  );
                }

                final name = userData['name'] as String? ?? 'Admin';
                final photoUrl = userData['photoUrl'] as String? ?? '';
                final role = userData['role'] as String? ?? 'Admin';

                return ProfileHeaderWidget(
                  name: name,
                  role: role,
                  photoUrl: photoUrl,
                );
              },
            ),
            const SizedBox(height: 16),

            // Verification Summary Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: VerificationSummaryWidget(
                verificationService: _verificationService,
              ),
            ),
            const SizedBox(height: 32),

            // Menu Section: Pengaturan Akun
            ProfileMenuSectionWidget(
              title: 'Pengaturan Akun',
              children: [
                ProfileMenuItemWidget(
                  icon: Icons.edit_rounded,
                  label: 'Edit Profil',
                  onTap: () {
                    // TODO: Navigate to edit profile screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Edit profil coming soon')),
                    );
                  },
                ),
                ProfileMenuItemWidget(
                  icon: Icons.group_rounded,
                  label: 'Manajemen Pengguna',
                  divider: true,
                  onTap: () {
                    // TODO: Navigate to user management screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User management coming soon')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Menu Section: Pengaturan Aplikasi
            ProfileMenuSectionWidget(
              title: 'Pengaturan Aplikasi',
              children: [
                ProfileMenuItemWidget(
                  icon: Icons.tune_rounded,
                  label: 'Pengaturan Aplikasi',
                  onTap: () {
                    // TODO: Navigate to app settings screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('App settings coming soon')),
                    );
                  },
                ),
                ProfileMenuItemWidget(
                  icon: Icons.help_outline_rounded,
                  label: 'Bantuan & Dukungan',
                  divider: false,
                  onTap: () {
                    // TODO: Navigate to help screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Help & Support coming soon')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Logout Button
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