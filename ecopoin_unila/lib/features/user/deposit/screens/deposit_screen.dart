import 'package:flutter/material.dart';
import '../../../../app/config/app_colors.dart';
import '../widgets/history_deposit_tab.dart';
import '../widgets/schedule_deposit_tab.dart';

class DepositScreen extends StatelessWidget {
  final int initialIndex; // Agar bisa dibuka langsung ke tab Riwayat

  const DepositScreen({
    super.key,
    this.initialIndex = 0, // Defaultnya ke tab pertama (Jadwal)
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Jumlah tab
      initialIndex: initialIndex,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            "Setor Sampah",
            style: TextStyle(color: AppColors.textDark),
          ),
          centerTitle: true,
          backgroundColor: AppColors.background,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.textDark),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            tabs: [
              Tab(text: "Jadwal Penjemputan"),
              Tab(text: "Riwayat Setoran"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ScheduleDepositTab(), // Tab 1
            HistoryDepositTab(), // Tab 2
          ],
        ),
      ),
    );
  }
}
