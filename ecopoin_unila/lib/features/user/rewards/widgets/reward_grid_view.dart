import 'package:flutter/material.dart';
import 'reward_card.dart';

class RewardGridView extends StatelessWidget {
  // Data dummy (seharusnya di-pass dari luar)
  final List<Map<String, String>> rewards = const [
    {
      "title": "Free Coffee",
      "points": "500 Points",
      "image": "assets/images/article_1.png",
    },
    {
      "title": "Eco-Friendly Tote Bag",
      "points": "1000 Points",
      "image": "assets/images/article_2.png",
    },
    {
      "title": "Discount Voucher",
      "points": "250 Points",
      "image": "assets/images/article_3.png",
    },
    {
      "title": "Campus Store Gift Card",
      "points": "750 Points",
      "image": "assets/images/home_banner.png",
    },
    {
      "title": "Free Coffee",
      "points": "500 Points",
      "image": "assets/images/profile_avatar.png",
    },
    {
      "title": "Eco-Friendly Tote Bag",
      "points": "1000 Points",
      "image": "assets/images/article_1.png",
    },
  ];

  const RewardGridView({super.key});

  @override
  Widget build(BuildContext context) {
    // HTML: <div class="grid grid-cols-[repeat(auto-fit,minmax(158px,1fr))]...">
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 kolom
        crossAxisSpacing: 16.0, // gap-3
        mainAxisSpacing: 16.0, // gap-3
        childAspectRatio: 0.8, // Aspek rasio (1:1 gambar + teks)
      ),
      itemCount: rewards.length,
      itemBuilder: (context, index) {
        final reward = rewards[index];
        return RewardCard(
          title: reward['title']!,
          points: reward['points']!,
          imageUrl: reward['image']!,
        );
      },
    );
  }
}
