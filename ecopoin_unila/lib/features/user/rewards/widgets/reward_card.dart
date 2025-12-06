import 'dart:convert'; // WAJIB ADA untuk decode base64
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
    // Fungsi pintar untuk mendeteksi tipe gambar
    Widget buildImage() {
      if (imageUrl.isEmpty) {
        return const Icon(Icons.card_giftcard, size: 50, color: Colors.grey);
      }

      // 1. Jika URL Internet (http/https)
      if (imageUrl.startsWith('http')) {
        return Image.network(
          imageUrl,
          fit: BoxFit.contain,
          errorBuilder: (ctx, err, stack) =>
              const Icon(Icons.broken_image, color: Colors.grey),
        );
      }
      // 2. Jika Base64 Data (data:image/...)
      else if (imageUrl.startsWith('data:')) {
        try {
          final base64String = imageUrl.split(',').last;
          return Image.memory(
            base64Decode(base64String),
            fit: BoxFit.contain,
            errorBuilder: (ctx, err, stack) =>
                const Icon(Icons.image_not_supported, color: Colors.grey),
          );
        } catch (e) {
          return const Icon(Icons.error, color: Colors.red);
        }
      }
      // 3. Jika Asset Lokal
      else {
        return Image.asset(
          imageUrl,
          fit: BoxFit.contain,
          errorBuilder: (ctx, err, stack) =>
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
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                  child: buildImage(), // Panggil fungsi gambar baru
                ),
              ),
            ),
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
