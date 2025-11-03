import 'package:flutter/material.dart';
import '../../../../app/config/app_colors.dart';
import '../widgets/history_deposit_tab.dart';
import '../widgets/schedule_deposit_tab.dart';

// Ubah dari StatelessWidget ke StatefulWidget
class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

// Tambahkan "with TickerProviderStateMixin"
class _DepositScreenState extends State<DepositScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Inisialisasi TabController dengan 2 tab
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        // Kita tidak pakai back button di sini karena ini adalah tab utama
        backgroundColor: AppColors.background,
        elevation: 0,
        // HTML: <h2 class="...text-lg font-bold...">
        title: const Text(
          "Setoran Sampah", // Judul umum untuk halaman
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        // HTML: <div class="flex border-b...">
        bottom: TabBar(
          controller: _tabController,
          // Garis indikator
          indicatorColor: AppColors.primary,
          indicatorWeight: 3.0,
          // Warna label aktif
          labelColor: AppColors.textDark,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          // Warna label tidak aktif
          unselectedLabelColor: AppColors.textGreen,
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          tabs: const [
            // HTML: <p class="...Jadwalkan Setoran">
            Tab(text: "Jadwalkan Setoran"),
            // HTML: <p class="...Riwayat Setoran">
            Tab(text: "Riwayat Setoran"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          // Konten Tab 1
          ScheduleDepositTab(),

          // Konten Tab 2
          HistoryDepositTab(),
        ],
      ),
    );
  }
}
