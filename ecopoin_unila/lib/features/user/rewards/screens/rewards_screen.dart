import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../app/config/app_colors.dart';
import '../../../../services/firestore_service.dart';
import '../widgets/points_header.dart';
import '../widgets/reward_grid_view.dart';
import 'my_vouchers_screen.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

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
        // Tambahkan leading manual untuk kontrol back button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              // Jika tidak bisa pop (misal dibuka langsung), jangan lakukan apa-apa atau ke Home
            }
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyVouchersScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.confirmation_number_outlined,
              color: AppColors.textDark,
            ),
            tooltip: "Voucher Saya",
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: firestoreService.getUserStream(),
        builder: (context, snapshot) {
          int currentPoints = 0;

          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            currentPoints = (data['points'] ?? 0).toInt(); // Pastikan int
          }

          return Column(
            children: [
              PointsHeader(points: currentPoints),
              Expanded(child: RewardGridView(currentPoints: currentPoints)),
            ],
          );
        },
      ),
    );
  }
}
