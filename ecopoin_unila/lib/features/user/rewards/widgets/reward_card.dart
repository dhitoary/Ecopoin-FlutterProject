// FILE: lib/features/user/rewards/widgets/reward_card.dart

import 'package:flutter/material.dart';
import '../../../../app/config/app_colors.dart';

class RewardCard extends StatelessWidget {
  final String title;
  final int points;
  final String imageUrl;
  final int stock;
  final VoidCallback onTap;

  const RewardCard({
    super.key,
    required this.title,
    required this.points,
    required this.imageUrl,
    required this.stock,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // LOGIKA PENGECEKAN TIPE GAMBAR
    Widget buildImage() {
      // Jika URL dimulai dengan 'http', pakai Image.network
      if (imageUrl.startsWith('http')) {
        return Image.network(
          imageUrl,
          fit: BoxFit.contain, // atau BoxFit.cover agar full
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.broken_image, size: 50, color: Colors.grey),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
        );
      }
      // Jika tidak, pakai Image.asset (untuk gambar lokal)
      else {
        return Image.asset(
          imageUrl,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.card_giftcard, size: 50, color: Colors.grey),
        );
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                0.05,
              ), // Perbaikan .withValues -> .withOpacity (lebih umum)
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Gambar Hadiah (SUDAH DIPERBAIKI)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: buildImage(), // Panggil fungsi gambar di sini
                ),
              ),
            ),

            // 2. Info Hadiah
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        size: 14,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "$points Pts",
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Tombol Tukar
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Tukar",
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
