import 'package:flutter/material.dart';
import '../../../../app/config/app_colors.dart';

class RewardCard extends StatelessWidget {
  final String title;
  final String points;
  final String imageUrl;

  const RewardCard({
    super.key,
    required this.title,
    required this.points,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    // HTML: <div class="flex flex-col gap-3...">
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HTML: <div class="...aspect-square bg-cover...">
        ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: AspectRatio(
            aspectRatio: 1.0, // aspect-square
            child: Image.asset(imageUrl, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 8.0),
        // HTML: <p class="...text-base font-medium...">
        Flexible(
          fit: FlexFit.loose,
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // HTML: <p class="text-[#4c9a6c]...">
        Text(
          points,
          style: const TextStyle(color: AppColors.textGreen, fontSize: 14),
        ),
      ],
    );
  }
}
