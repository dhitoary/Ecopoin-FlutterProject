import 'package:flutter/material.dart';
import '../../../../app/config/app_colors.dart';
import '../widgets/category_card.dart';

class EducationGuideScreen extends StatelessWidget {
  const EducationGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // HTML: <div class="flex items-center...">
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        // HTML: <div class="...ArrowLeft...">
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // HTML: <h2 class="...text-center pr-12">
        title: const Text(
          "Panduan Klasifikasi Sampah",
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HTML: <div class="px-4 py-3"> (Search Bar)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: TextFormField(
                decoration: InputDecoration(
                  // HTML: placeholder="Cari panduan..."
                  hintText: "Cari panduan...",
                  // HTML: placeholder:text-[#4c9a6c]
                  hintStyle: const TextStyle(color: AppColors.textGreen),
                  // HTML: <div class="...MagnifyingGlass...">
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.textGreen,
                  ),
                  filled: true,
                  // HTML: bg-[#e7f3ec]
                  fillColor: AppColors.inputBackground,
                  // HTML: border-none rounded-lg
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
              ),
            ),

            // HTML: <h2 class="...text-[22px] font-bold...">
            const Padding(
              padding: EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
              child: Text(
                "Kategori Sampah",
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Daftar Kategori
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: const [
                  CategoryCard(
                    title: "Anorganik",
                    description: "Plastik, Kaca, Logam",
                    imageUrl: "assets/images/category_anorganik.png",
                  ),
                  SizedBox(height: 24.0),
                  CategoryCard(
                    title: "Organik",
                    description: "Sisa makanan, daun kering, ranting",
                    imageUrl: "assets/images/category_organik.png",
                  ),
                  SizedBox(height: 24.0),
                  CategoryCard(
                    title: "B3",
                    description: "Baterai, Elektronik",
                    imageUrl: "assets/images/category_b3.png",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),
          ],
        ),
      ),
    );
  }
}
