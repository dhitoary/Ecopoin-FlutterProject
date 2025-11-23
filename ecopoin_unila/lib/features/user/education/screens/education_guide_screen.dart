import 'package:flutter/material.dart';
import '../../../../app/config/app_colors.dart';
import '../widgets/category_card.dart';

class EducationGuideScreen extends StatelessWidget {
  const EducationGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Data Kategori Sampah
    final List<Map<String, dynamic>> categories = [
      {
        "title": "Sampah Organik",
        "desc": "Sampah yang mudah terurai secara alami.",
        "image": "assets/images/category_organik.png",
        "color": Colors.green,
        "examples": [
          "Sisa Makanan",
          "Daun Kering",
          "Kulit Buah",
          "Sisa Sayuran",
        ],
      },
      {
        "title": "Sampah Anorganik",
        "desc": "Sampah yang sulit terurai dan dapat didaur ulang.",
        "image": "assets/images/category_anorganik.png",
        "color": Colors.orange,
        "examples": [
          "Botol Plastik",
          "Kaleng Minuman",
          "Kertas & Kardus",
          "Kaca",
        ],
      },
      {
        "title": "Sampah B3",
        "desc": "Bahan Berbahaya dan Beracun.",
        "image": "assets/images/category_b3.png",
        "color": Colors.red,
        "examples": [
          "Baterai Bekas",
          "Lampu Neon",
          "Kemasan Pestisida",
          "Obat Kadaluarsa",
        ],
      },
    ];

    void showDetail(BuildContext context, Map<String, dynamic> item) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: item['color'].withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.info_outline, color: item['color']),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      item['title'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  item['desc'],
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Contoh Sampah:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (item['examples'] as List<String>).map((ex) {
                    return Chip(
                      label: Text(ex),
                      backgroundColor: item['color'].withValues(alpha: 0.1),
                      labelStyle: TextStyle(color: item['color']),
                      side: BorderSide.none,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Panduan Pilah Sampah",
          style: TextStyle(color: AppColors.textDark),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return CategoryCard(
            title: categories[index]['title'],
            description: categories[index]['desc'],
            imageAsset: categories[index]['image'],
            accentColor: categories[index]['color'],
            onTap: () => showDetail(context, categories[index]),
          );
        },
      ),
    );
  }
}
