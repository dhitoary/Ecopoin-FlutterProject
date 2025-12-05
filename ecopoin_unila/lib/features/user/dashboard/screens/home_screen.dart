import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// --- IMPORT CONFIG & WIDGETS ---
import '../../../../app/config/app_colors.dart';
import '../../../../services/article_service.dart'; // Pastikan path ini benar
import '../widgets/hero_card.dart';
import '../widgets/quick_action_button.dart';

// --- IMPORT SCREENS ---
import '../../education/screens/education_guide_screen.dart';
import '../../education/screens/education_detail_screen.dart';
import '../../deposit/screens/deposit_screen.dart';
import '../../rewards/screens/rewards_screen.dart';
import '../../notifications/screens/notification_screen.dart';
import 'info_education_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  String _userName = "Teman Eco";

  // Service untuk mengambil data Artikel
  final ArticleService _articleService = ArticleService();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();

        if (userDoc.exists && mounted) {
          setState(() {
            final data = userDoc.data() as Map<String, dynamic>;
            _userName = data['name'] ?? data['fullName'] ?? "Teman Eco";
          });
        }
      } catch (e) {
        debugPrint("Gagal ambil data user: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
            // 1. HERO CARD (Tanpa Parameter, sesuai kode asli Anda)
            const HeroCard(),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24.0),

                  // 2. AKSI CEPAT
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
                            builder: (_) =>
                                const RewardsScreen(), // Pastikan file ini tidak error
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
                            builder: (_) => const DepositScreen(
                              initialIndex: 1,
                            ), // Pastikan DepositScreen menerima parameter ini
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32.0),

                  // 3. INFO & EDUKASI (Header)
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
                        // Navigasi ke list tanpa parameter 'items'
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const InfoEducationListScreen(),
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

                  // 4. LIST ARTIKEL HORIZONTAL
                  SizedBox(
                    height: 240,
                    child: StreamBuilder<List<ArticleModel>>(
                      stream: _articleService.getArticlesStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        // Jika Error atau Kosong
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.article_outlined,
                                  color: Colors.grey[400],
                                  size: 40,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Belum ada artikel",
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          );
                        }

                        // Ambil max 5 artikel
                        final articles = snapshot.data!.take(5).toList();

                        return ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: articles.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 16),
                          itemBuilder: (context, index) {
                            final article = articles[index];

                            // TAMPILAN KARTU ARTIKEL
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EducationDetailScreen(
                                      title: article.title,
                                      // FIX: Gunakan parameter 'summary' sesuai kode lama Anda.
                                      // Kita isi dengan content (jika ada) agar detailnya lengkap,
                                      // atau fallback ke summary.
                                      summary: article.content.isNotEmpty
                                          ? article.content
                                          : article.summary,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: 200,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // GAMBAR
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                      child: Container(
                                        height: 110,
                                        width: double.infinity,
                                        color: Colors.grey[200],
                                        child:
                                            article.imageUrl != null &&
                                                article.imageUrl!.isNotEmpty
                                            ? Image.network(
                                                article.imageUrl!,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (ctx, err, stack) =>
                                                        const Icon(
                                                          Icons.broken_image,
                                                          color: Colors.grey,
                                                        ),
                                              )
                                            : const Icon(
                                                Icons.image,
                                                color: Colors.grey,
                                              ),
                                      ),
                                    ),
                                    // TEKS
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            article.title,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            article.summary,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
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
