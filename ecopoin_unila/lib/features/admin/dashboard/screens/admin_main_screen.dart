import 'package:flutter/material.dart';
import '../../../../app/config/app_colors.dart';
import '../../profile/screens/admin_profile_screen.dart';
import '../../rewards/screens/admin_rewards_management_screen.dart';
import '../../verification/screens/admin_verification_screen.dart';
import 'admin_dashboard_screen.dart'; // Kita buat ini sebentar lagi

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({Key? key}) : super(key: key);

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const AdminDashboardScreen(),
    const AdminVerificationScreen(),
    const AdminRewardsManagementScreen(),
    const AdminProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      // HTML: Bottom Navigation Bar structure
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          // HTML: Icon House
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          // HTML: Icon CheckSquare
          BottomNavigationBarItem(
            icon: Icon(Icons.fact_check_outlined),
            label: 'Verifikasi',
          ),
          // HTML: Icon Gift
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard_outlined),
            label: 'Rewards',
          ),
          // HTML: Icon User
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.textDark, // HTML: text-[#0d1b13]
        unselectedItemColor: AppColors.textGreen, // HTML: text-[#4c9a6c]
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.background,
        elevation: 1.0,
      ),
    );
  }
}