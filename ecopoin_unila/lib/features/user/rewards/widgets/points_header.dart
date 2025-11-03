import 'package:flutter/material.dart';

class PointsHeader extends StatelessWidget {
  const PointsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    // HTML: <div class="...min-h-[480px]...gradient...">
    // Note: min-h-480px terlalu besar, kita sesuaikan jadi 180.
    return Container(
      height: 180,
      width: double.infinity,
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        image: const DecorationImage(
          image: AssetImage(
            'assets/images/rewards_banner.png',
          ), // Ganti aset Anda
          fit: BoxFit.cover,
        ),
        gradient: const LinearGradient(
          colors: [Color.fromRGBO(0, 0, 0, 0.1), Color.fromRGBO(0, 0, 0, 0.4)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          // HTML: <h1 class="...text-4xl font-black...">
          Text(
            "Your Points",
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.0),
          // HTML: <h2 class="...text-sm font-normal...">
          Text(
            "1.250",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20, // Ukuran disesuaikan agar lebih terlihat
            ),
          ),
        ],
      ),
    );
  }
}
