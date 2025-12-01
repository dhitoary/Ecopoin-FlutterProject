import 'package:flutter/material.dart';

import 'package:ecopoin_unila/app/config/app_colors.dart';
import 'package:ecopoin_unila/features/user/dashboard/widgets/article_card.dart';
import 'package:ecopoin_unila/features/user/dashboard/widgets/hero_card.dart';
import 'package:ecopoin_unila/features/user/dashboard/widgets/quick_action_button.dart';

import 'package:ecopoin_unila/features/user/education/screens/education_guide_screen.dart';
import 'package:ecopoin_unila/features/user/education/screens/education_detail_screen.dart'; // Make sure this file exists
import 'package:ecopoin_unila/features/user/deposit/screens/deposit_screen.dart';
import 'package:ecopoin_unila/features/user/rewards/screens/rewards_screen.dart';
import 'package:ecopoin_unila/features/user/notifications/screens/notification_screen.dart';
import 'info_education_list_screen.dart';
import 'article_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // DATA EDUKASI STATIS (Bukan Dummy Loop)
  static final List<Map<String, String>> _eduItems = [
    {
      'title': 'Jenis-jenis Sampah Plastik',
      'summary':
          'Kenali 7 kode segitiga pada kemasan plastik agar daur ulang lebih efektif.',
    },
    {
      'title': 'Cara Membuat Kompos',
      'summary':
          'Panduan mengubah sisa makanan menjadi pupuk alami yang menyuburkan tanah.',
    },
    {
      'title': 'Bahaya Limbah B3',
      'summary': 'Baterai dan lampu bekas berbahaya! Jangan buang sembarangan.',
    },
    {
      'title': 'Diet Kantong Plastik',
      'summary':
          'Tips mudah mengurangi penggunaan kantong kresek di kehidupan sehari-hari.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final top3 = _eduItems.take(3).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          "EcoPoin Unila",
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationScreen(),
              ),
            ),
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HeroCard(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24.0),
                  Text(
                    'Aksi Cepat',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Column(
                    children: [
                      QuickActionButton(
                        title: "Setor Sampah",
                        icon: Icons.inventory_2_outlined,
                        isPrimary: true,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const DepositScreen(initialIndex: 0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      QuickActionButton(
                        title: "Tukar Poin",
                        icon: Icons.card_giftcard_outlined,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RewardsScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      QuickActionButton(
                        title: "Panduan Pilah",
                        icon: Icons.info_outline,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EducationGuideScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      QuickActionButton(
                        title: "Riwayat Setoran",
                        icon: Icons.history_outlined,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const DepositScreen(initialIndex: 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32.0),

                  // INFO & EDUKASI SECTION
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Info & Edukasi',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                InfoEducationListScreen(items: _eduItems),
                          ),
                        ),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: const Text(
                          'Lihat Semua',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  Column(
                    children: top3.asMap().entries.map((entry) {
                      final isLast = entry.key == top3.length - 1;
                      final item = entry.value;
                      return Container(
                        margin: EdgeInsets.only(bottom: isLast ? 0 : 12.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Material(
                            color: Colors.white,
                            child: InkWell(
                              splashColor: AppColors.primary.withOpacity(0.1),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EducationDetailScreen(
                                    title: item['title']!,
                                    summary: item['summary']!,
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 14.0,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['title']!,
                                            style: const TextStyle(
                                              color: AppColors.textDark,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6.0),
                                          Text(
                                            item['summary']!,
                                            style: const TextStyle(
                                              color: AppColors.textGreen,
                                              fontSize: 12,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12.0),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32.0),

                  // ARTIKEL & TIPS SECTION
                  Text(
                    'Artikel & Tips',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  LargeArticleCard(
                    title: "Tips Mengurangi Sampah Plastik",
                    description:
                        "Bawa tumbler sendiri dan kurangi penggunaan sedotan plastik.",
                    date: "20 Mei 2024",
                    imageUrl: "assets/images/article_1.png",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ArticleDetailScreen(
                          title: "Tips Mengurangi Sampah Plastik",
                          date: "20 Mei 2024",
                          imageUrl: "assets/images/article_1.png",
                          description:
                              "Sampah plastik menjadi masalah utama...",
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  SmallArticleCard(
                    title: "Manfaat Daur Ulang Kertas",
                    description:
                        "Daur ulang 1 ton kertas dapat menyelamatkan 17 pohon.",
                    imageUrl: "assets/images/article_2.png",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ArticleDetailScreen(
                          title: "Manfaat Daur Ulang Kertas",
                          date: "18 Mei 2024",
                          imageUrl: "assets/images/article_2.png",
                          description: "Kertas bekas tugas kuliah...",
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  SmallArticleCard(
                    title: "Bahaya Sampah Elektronik",
                    description:
                        "Jangan buang baterai sembarangan, mengandung B3!",
                    imageUrl: "assets/images/article_3.png",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ArticleDetailScreen(
                          title: "Bahaya Sampah Elektronik",
                          date: "15 Mei 2024",
                          imageUrl: "assets/images/article_3.png",
                          description: "Baterai bekas...",
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
