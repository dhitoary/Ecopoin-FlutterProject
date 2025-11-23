import 'package:flutter/material.dart';
import '../../../../app/config/app_colors.dart';
import '../widgets/article_card.dart';
import '../widgets/hero_card.dart';
import '../widgets/quick_action_button.dart';
import '../../education/screens/education_guide_screen.dart';
import '../../deposit/screens/deposit_screen.dart';
import '../../rewards/screens/rewards_screen.dart';
import 'info_education_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Dummy data untuk konten edukasi
  static final List<Map<String, String>> _eduItems = List.generate(
    12,
    (i) => {
      'title': 'Edukasi Lingkungan #${i + 1}',
      'summary':
          'Pelajari cara menjaga lingkungan di kampus kita (Bagian ${i + 1}).',
    },
  );

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
            onPressed: () {
              // Fitur Notifikasi (Nanti)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Belum ada notifikasi baru")),
              );
            },
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero Card (Sudah diperbaiki sebelumnya)
            const HeroCard(),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24.0),

                  // 2. Quick Actions Section
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
                      // Tombol 1: Setor Sampah (Buka Tab Jadwal - Default)
                      QuickActionButton(
                        title: "Setor Sampah",
                        icon: Icons.inventory_2_outlined,
                        isPrimary: true,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const DepositScreen(initialIndex: 0),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12.0),

                      // Tombol 2: Tukar Poin
                      QuickActionButton(
                        title: "Tukar Poin",
                        icon: Icons.card_giftcard_outlined,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RewardsScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12.0),

                      // Tombol 3: Panduan Pilah
                      QuickActionButton(
                        title: "Panduan Pilah",
                        icon: Icons.info_outline,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EducationGuideScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12.0),

                      // Tombol 4: Riwayat Setoran (Buka Tab Riwayat - Index 1)
                      QuickActionButton(
                        title: "Riwayat Setoran",
                        icon: Icons.history_outlined,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              // PERUBAHAN UTAMA DI SINI: initialIndex: 1
                              builder: (_) =>
                                  const DepositScreen(initialIndex: 1),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 32.0),

                  // 3. Info & Edukasi
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
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  InfoEducationListScreen(items: _eduItems),
                            ),
                          );
                        },
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

                  // Preview List Edukasi
                  Column(
                    children: top3.asMap().entries.map((entry) {
                      final isLast = entry.key == top3.length - 1;
                      final item = entry.value;
                      return Container(
                        margin: EdgeInsets.only(bottom: isLast ? 0 : 12.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8.0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12.0),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const EducationGuideScreen(),
                                ),
                              );
                            },
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
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 32.0),

                  // 4. Artikel & Tips
                  Text(
                    'Artikel & Tips',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),

                  const SizedBox(height: 16.0),

                  // Kartu Artikel 1
                  const LargeArticleCard(
                    title: "Tips Mengurangi Sampah Plastik di Kampus",
                    description:
                        "Bawa tumbler sendiri dan kurangi penggunaan sedotan plastik.",
                    date: "20 Mei 2024",
                    imageUrl: "assets/images/article_1.png",
                  ),

                  const SizedBox(height: 16.0),

                  // Kartu Artikel 2
                  const SmallArticleCard(
                    title: "Manfaat Daur Ulang Sampah Kertas",
                    description:
                        "Daur ulang 1 ton kertas dapat menyelamatkan 17 pohon.",
                    imageUrl: "assets/images/article_2.png",
                  ),

                  const SizedBox(height: 16.0),

                  // Kartu Artikel 3
                  const SmallArticleCard(
                    title: "Bahaya Sampah Elektronik (E-Waste)",
                    description:
                        "Jangan buang baterai sembarangan, mengandung B3!",
                    imageUrl: "assets/images/article_3.png",
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
