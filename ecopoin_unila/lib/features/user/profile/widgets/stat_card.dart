import 'package:flutter/material.dart';
import '../../../../app/config/app_colors.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;

  const StatCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    // HTML: <div class="flex min-w-[158px] flex-1...border...">
    // Kita gunakan Expanded di parent, jadi di sini kita buat isinya.
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HTML: <p class="...text-base font-medium...">
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 14, // 16 (base) terlalu besar, kita sesuaikan
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8.0),
          // HTML: <p class="...text-2xl font-bold...">
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
