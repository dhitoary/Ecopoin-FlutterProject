import 'package:flutter/material.dart';
import '../../../../app/config/app_colors.dart';
import '../widgets/points_header.dart';
import '../widgets/reward_grid_view.dart';

// Ubah dari StatelessWidget ke StatefulWidget
class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

// Tambahkan "with TickerProviderStateMixin"
class _RewardsScreenState extends State<RewardsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Inisialisasi TabController dengan 3 tab
    _tabController = TabController(length: 3, vsync: this);
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
        backgroundColor: AppColors.background,
        elevation: 0,
        // Judul AppBar (bukan dari HTML)
        title: const Text(
          "Rewards",
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        // HTML: <div class="flex border-b..."> (TabBar)
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3.0,
          labelColor: AppColors.textDark,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelColor: AppColors.textGreen,
          tabs: const [
            Tab(text: "All"),
            Tab(text: "Food & Beverage"),
            Tab(text: "Merchandise"),
          ],
        ),
      ),
      body: Column(
        children: [
          // 1. Kartu Poin di atas TabBarView
          const PointsHeader(),

          // 2. Konten Tab
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                // Tab 1: All
                RewardGridView(),

                // Tab 2: Food & Beverage
                // (Gunakan data yang difilter di sini)
                RewardGridView(),

                // Tab 3: Merchandise
                // (Gunakan data yang difilter di sini)
                RewardGridView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
