import 'package:flutter/material.dart';
import '../../../../app/config/app_colors.dart';

class HeroCard extends StatelessWidget {
  const HeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    // HTML: <div class="...min-h-[480px]...bg-cover...gradient...">
    // Responsive height (percentage of viewport with sensible min/max)
    final screenH = MediaQuery.of(context).size.height;
    final heroHeight = screenH * 0.28; // ~28% of screen height
    final height = heroHeight.clamp(220.0, 360.0);

    // Gradient opacity tweaks: adjust these numbers to increase/decrease
    // darkness at top/bottom
    const topGradientAlpha = 0.08; // lighter top overlay
    const bottomGradientAlpha = 0.5; // stronger bottom overlay

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        children: [
          // full-bleed image
          Positioned.fill(
            child: Image.asset(
              'assets/images/home_banner.png',
              fit: BoxFit.cover,
            ),
          ),

          // gradient overlay with tweaked opacity
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(0, 0, 0, topGradientAlpha),
                    Color.fromRGBO(0, 0, 0, bottomGradientAlpha),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // inner rounded content area with subtle shadow
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 12.0,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.all(20.0),
                      // vertical alignment: slightly above bottom for better look
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // greeting (can be nudged up/down by changing SizedBox)
                          const Text(
                            "Halo, Budi!",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6.0),
                          const Text(
                            "Total EcoPoin Kamu:",
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                          const SizedBox(height: 12.0),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.textDark,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                                vertical: 10.0,
                              ),
                            ),
                            child: const Text(
                              "12.345",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
