import 'package:flutter/material.dart';
import 'package:ecopoin_unila/app/config/app_colors.dart';

class EducationDetailScreen extends StatelessWidget {
  final String title;
  final String summary;

  const EducationDetailScreen({
    super.key,
    required this.title,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Detail Edukasi",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Placeholder Gambar Besar
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                size: 80,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),

            // Judul
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),

            // Meta Info
            Row(
              children: [
                const Icon(Icons.verified_user, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  "Tim EcoPoin Unila",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
            const Divider(height: 32),

            // Konten Utama
            Text(
              summary,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Teks dummy tambahan agar terlihat penuh
            const Text(
              "Pengelolaan sampah yang baik dimulai dari pemilahan di sumbernya. Pisahkan sampah organik (sisa makanan), anorganik (plastik, kertas), dan B3 (baterai, elektronik). \n\nDengan memilah sampah, kita membantu petugas kebersihan dan mempermudah proses daur ulang. Sampah yang tercampur akan sulit diolah dan berakhir menumpuk di TPA. Mari jaga lingkungan kampus Universitas Lampung agar tetap asri dan hijau.",
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
