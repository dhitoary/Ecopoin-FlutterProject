import 'package:flutter/material.dart';
import '../../../../app/config/app_colors.dart';
import '../../deposit/screens/deposit_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../rewards/screens/rewards_screen.dart';
import 'home_screen.dart'; // File ini akan kita buat selanjutnya

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Daftar halaman yang akan ditampilkan
  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    const DepositScreen(),
    const RewardsScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      // HTML: <div class="flex gap-2 border-t ...">
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined), // Mengganti <Package>
            label: 'Setoran',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard_outlined), // Mengganti <Gift>
            label: 'Rewards',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), // Mengganti <User>
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        // Warna item aktif
        selectedItemColor: AppColors.textDark, // text-[#0d1b13]
        // Warna item tidak aktif
        unselectedItemColor: AppColors.textGreen, // text-[#4c9a6c]
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Selalu tampilkan label
        backgroundColor: AppColors.background, // bg-[#f8fcfa]
        elevation: 1.0,
      ),
    );
  }
}
