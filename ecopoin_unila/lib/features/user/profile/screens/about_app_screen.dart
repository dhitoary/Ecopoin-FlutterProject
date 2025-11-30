import 'package:flutter/material.dart';
import '../../../../app/config/app_colors.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Tentang Aplikasi",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/auth_banner.png', // Pastikan asset ini ada
              height: 120,
              width: 120,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.eco, size: 100, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            const Text(
              "EcoPoin Unila",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text("Versi 1.0.0", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: const Text(
                "Aplikasi Bank Sampah Digital Universitas Lampung. Mengubah sampah menjadi berkah, mendukung kampus hijau berkelanjutan.",
                textAlign: TextAlign.center,
                style: TextStyle(height: 1.5, color: Colors.black87),
              ),
            ),
            const Spacer(),
            const Text(
              "© 2025 Kelompok 5 PSTI C",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
