import 'package:flutter/material.dart';
import '../../../../app/config/app_colors.dart';
import '../widgets/points_header.dart';
import '../widgets/reward_grid_view.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Tukar Poin",
          style: TextStyle(color: AppColors.textDark),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: Column(
        children: const [
          // 1. Header Poin (Bagian Atas)
          PointsHeader(),

          // 2. Grid Hadiah (Daftar Barang)
          Expanded(child: RewardGridView()),
        ],
      ),
    );
  }
}
