import 'package:flutter/material.dart';
import '../../../../app/config/app_colors.dart';
import '../widgets/onboarding_page.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Data untuk 3 Halaman Onboarding
  final List<Map<String, String>> _onboardingData = const [
    {
      "image": "assets/images/onboarding_1.png",
      "title": "Welcome to EcoPoin Unila",
      "description":
          "Transform your waste into valuable points. Earn rewards while making a difference.",
    },
    {
      "image": "assets/images/onboarding_2.png",
      "title": "Pilah & Setor Sampah",
      "description":
          "Kumpulkan dan pilah sampahmu sesuai kategori. Setorkan ke Bank Sampah terdekat.",
    },
    {
      "image": "assets/images/onboarding_3.png",
      "title": "Dapatkan Poin & Reward",
      "description":
          "Setiap setoran akan diverifikasi dan dikonversi menjadi poin yang bisa ditukar!",
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Fungsi untuk Tombol "Next"
  void _onNextPressed() {
    if (_currentPage == _onboardingData.length - 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  // Fungsi untuk Tombol "Skip"
  void _onSkipPressed() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Bagian Utama: PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingData.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return OnboardingPage(
                    imageUrl: _onboardingData[index]['image']!,
                    title: _onboardingData[index]['title']!,
                    description: _onboardingData[index]['description']!,
                  );
                },
              ),
            ),

            // 2. Indikator Dot
            // HTML: <div class="flex...gap-3 py-5">
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _onboardingData.length,
                (index) => _buildDot(index: index),
              ),
            ),
            const SizedBox(height: 48), // Spasi ke tombol
            // 3. Tombol Bawah (Next & Skip)
            // HTML: <div class="flex...justify-between">
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 24.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tombol "Skip"
                  // HTML: <button class="...bg-transparent...">
                  TextButton(
                    onPressed: _onSkipPressed,
                    child: const Text(
                      "Skip",
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),

                  // Tombol "Next" atau "Mulai"
                  // HTML: <button class="...bg-[#13e76b]...">
                  ElevatedButton(
                    onPressed: _onNextPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textDark, // Teks warna gelap
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _currentPage == _onboardingData.length - 1
                          ? "Mulai"
                          : "Next",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget private untuk membuat 1 dot
  Widget _buildDot({required int index}) {
    bool isActive = _currentPage == index;
    // HTML: <div class="h-2 w-2 rounded-full bg-[#...]"
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: 8.0,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.border,
        borderRadius: BorderRadius.circular(4.0),
      ),
    );
  }
}
