import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk SystemNavigator
import 'package:ecopoin_unila/app/config/app_colors.dart';

// Import Services
import '../../../../services/verification_service.dart';
import '../../../../services/admin_dashboard_service.dart';

// Import Screens (PASTIKAN FILE-FILE INI ADA DI FOLDER YANG BENAR)
import '../../verification/screens/admin_verification_screen.dart';
import '../../rewards/screens/admin_rewards_management_screen.dart';
import '../../profile/screens/admin_profile_screen.dart';
import 'admin_report_screen.dart'; // Pastikan file ini ada di folder dashboard/screens

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key}); // Gunakan super.key

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final VerificationService _verificationService = VerificationService();
  final AdminDashboardService _dashboardService = AdminDashboardService();
  int _selectedTabIndex = 0;

  // LOGIKA BACK BUTTON (Anti Logout Tidak Sengaja)
  Future<bool> _onWillPop() async {
    if (_selectedTabIndex != 0) {
      // Jika sedang di tab lain (selain Home), kembali ke Home dulu
      setState(() => _selectedTabIndex = 0);
      return false;
    }

    // Jika sudah di Home, tanya konfirmasi keluar
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar Aplikasi?'),
        content: const Text('Apakah Anda yakin ingin menutup aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => SystemNavigator.pop(), // Keluar total dari app
            child: const Text(
              'Ya, Keluar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // Bungkus dengan WillPopScope agar tombol back terkontrol
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(
          index: _selectedTabIndex,
          children: [
            _buildDashboardTab(), // Index 0
            const AdminVerificationScreen(), // Index 1
            const AdminRewardsManagementScreen(), // Index 2
            const AdminProfileScreen(), // Index 3
          ],
        ),
        bottomNavigationBar: _buildBottomNavBar(),
      ),
    );
  }

  // --- TAB DASHBOARD UTAMA ---
  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader("Dashboard Admin"),

          // Statistik Verifikasi Pending
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder<Map<String, int>>(
              future: _verificationService.getVerificationCounts(),
              builder: (context, snapshot) {
                final counts = snapshot.data ?? {'pending': 0};
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xffe7f3ec),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Setoran Perlu Diverifikasi",
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        counts['pending'].toString(),
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        counts['pending']! > 0
                            ? "Segera proses!"
                            : "Semua beres",
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Statistik User & Sampah
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: StreamBuilder<int>(
                    stream: _dashboardService.getTotalUsersStream(),
                    builder: (context, snapshot) => _buildStatCard(
                      "Total Mahasiswa",
                      (snapshot.data ?? 0).toString(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StreamBuilder<double>(
                    stream: _dashboardService.getTotalWasteStream(),
                    builder: (context, snapshot) => _buildStatCard(
                      "Total Sampah (Kg)",
                      (snapshot.data ?? 0).toStringAsFixed(1),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Tombol Navigasi Cepat
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                _buildActionButton(
                  "Verifikasi Setoran",
                  true,
                  () => setState(() => _selectedTabIndex = 1),
                ),
                const SizedBox(height: 12),
                _buildActionButton(
                  "Manajemen Rewards",
                  false,
                  () => setState(() => _selectedTabIndex = 2),
                ),
                const SizedBox(height: 12),
                // Navigasi ke Laporan
                _buildActionButton(
                  "Lihat Laporan",
                  false,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminReportScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---
  Widget _buildHeader(String title) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.textDark),
              onPressed: () => setState(() {}), // Refresh dashboard
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(Icons.dashboard_rounded, "Dashboard", 0),
              _buildNavItem(Icons.fact_check_rounded, "Verifikasi", 1),
              _buildNavItem(Icons.card_giftcard_rounded, "Rewards", 2),
              _buildNavItem(Icons.person_rounded, "Profil", 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedTabIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedTabIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xffcfe7d9)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, bool isPrimary, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? AppColors.primary
              : const Color(0xffe7f3ec),
          foregroundColor: AppColors.textDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
