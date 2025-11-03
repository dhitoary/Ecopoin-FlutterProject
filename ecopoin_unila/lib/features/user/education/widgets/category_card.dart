import 'package:flutter/material.dart';
import '../../../../app/config/app_colors.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;

  const CategoryCard({
    super.key,
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    // HTML: <div class="flex flex-col items-stretch...">
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HTML: <div class="...aspect-video bg-cover rounded-lg">
        ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Image.asset(
            imageUrl,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 12.0),
        // HTML: <p class="...text-lg font-bold...">
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4.0),
        // HTML: <p class="text-[#4c9a6c]...">
        Text(
          description,
          style: const TextStyle(color: AppColors.textGreen, fontSize: 16),
        ),
      ],
    );
  }
}
