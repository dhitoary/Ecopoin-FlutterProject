import 'package:flutter/material.dart';
import '../../../../services/firestore_service.dart';
import '../../../../services/user_rewards_service.dart';
import 'reward_card.dart';

class RewardGridView extends StatelessWidget {
  final int currentPoints;

  const RewardGridView({super.key, required this.currentPoints});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();
    final UserRewardsService userRewardsService = UserRewardsService();

    return StreamBuilder<List<RewardModel>>(
      stream: userRewardsService.getRewardsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final rewards = snapshot.data ?? [];

        if (rewards.isEmpty) {
          return const Center(child: Text('Tidak ada reward tersedia'));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Katalog Hadiah",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: rewards.length,
                itemBuilder: (context, index) {
                  final reward = rewards[index];
                  return RewardCard(
                    title: reward.name,
                    points: reward.pointsRequired,
                    imageUrl: reward.imageUrl ?? 'assets/images/reward_default.png',
                    stock: reward.quantity,
                    onTap: () => _handleRedeem(
                      context,
                      firestoreService,
                      userRewardsService,
                      reward.id,
                      reward.name,
                      reward.pointsRequired,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleRedeem(
    BuildContext context,
    FirestoreService firestoreService,
    UserRewardsService userRewardsService,
    String rewardId,
    String rewardName,
    int pointsCost,
  ) async {
    if (currentPoints < pointsCost) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Poin Tidak Cukup 😔"),
            content: Text(
              "Anda butuh $pointsCost Poin, tapi saldo Anda hanya $currentPoints Poin.\n\nYuk setor sampah lagi untuk tambah poin!",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Oke, Siap!"),
              ),
            ],
          ),
        );
      }
      return;
    }

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Konfirmasi Penukaran"),
          content: Text("Tukar $pointsCost Poin untuk $rewardName?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  final userId = firestoreService.currentUserId;
                  if (userId == null) {
                    throw Exception('User not authenticated');
                  }

                  await userRewardsService.redeemReward(
                    rewardId: rewardId,
                    userId: userId,
                    rewardName: rewardName,
                    pointsCost: pointsCost,
                  );

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Berhasil menukar hadiah!"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Gagal: ${e.toString()}"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text("Tukar"),
            ),
          ],
        ),
      );
    }
  }
}
