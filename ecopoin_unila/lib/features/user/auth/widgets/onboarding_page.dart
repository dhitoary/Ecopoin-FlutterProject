import 'package:flutter/material.dart';
import '../../../../app/config/app_colors.dart';

class OnboardingPage extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;

  const OnboardingPage({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 1. Gambar Ilustrasi
          // HTML: <div class="...min-h-80...bg-cover...">
          Flexible(flex: 3, child: Image.asset(imageUrl, fit: BoxFit.contain)),
          const SizedBox(height: 48.0), // Spasi
          // 2. Judul
          // HTML: <h2 class="...text-[28px] font-bold...">
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16.0), // Spasi (pt-5 ke pb-3)
          // 3. Deskripsi
          // HTML: <p class="...text-base font-normal...">
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: AppColors.textDark,
            ),
          ),
          const Flexible(flex: 1, child: SizedBox.shrink()),
        ],
      ),
    );
  }
}
