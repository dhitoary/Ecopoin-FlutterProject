import 'package:flutter/material.dart';
import '../../../../services/firestore_service.dart';
import 'reward_card.dart';

class RewardGridView extends StatelessWidget {
  final int currentPoints; // Data poin user saat ini

  const RewardGridView({super.key, required this.currentPoints});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    final List<Map<String, dynamic>> rewards = [
      {
        "title": "Voucher Kantin",
        "points": 500,
        "image": "assets/images/reward_voucher.png",
        "stock": 50,
      },
      {
        "title": "Totebag Unila",
        "points": 1500,
        "image": "assets/images/reward_totebag.png",
        "stock": 15,
      },
      {
        "title": "Kopi Gratis",
        "points": 300,
        "image": "assets/images/reward_coffee.png",
        "stock": 100,
      },
      {
        "title": "Saldo E-Wallet",
        "points": 2500,
        "image": "assets/images/reward_giftcard.png",
        "stock": 10,
      },
    ];

    void handleRedeem(String title, int cost) {
      // --- LOGIKA BARU: CEK SALDO DULU ---
      if (currentPoints < cost) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Poin Tidak Cukup 😔"),
            content: Text(
              "Anda butuh $cost Poin, tapi saldo Anda hanya $currentPoints Poin.\n\nYuk setor sampah lagi untuk tambah poin!",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Oke, Siap!"),
              ),
            ],
          ),
        );
        return; // Stop proses di sini
      }
      // -----------------------------------

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Konfirmasi Penukaran"),
          content: Text("Tukar $cost Poin untuk $title?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await firestoreService.redeemReward(
                    rewardTitle: title,
                    cost: cost,
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
              return RewardCard(
                title: rewards[index]['title'],
                points: rewards[index]['points'],
                imageUrl: rewards[index]['image'],
                stock: rewards[index]['stock'],
                onTap: () => handleRedeem(
                  rewards[index]['title'],
                  rewards[index]['points'],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
