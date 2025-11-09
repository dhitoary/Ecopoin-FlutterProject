import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:ecopoin_unila/app/config/app_colors.dart';
import 'package:ecopoin_unila/features/user/auth/screens/onboarding_screen.dart';
import 'package:ecopoin_unila/features/user/dashboard/screens/home_screen.dart';
import 'package:ecopoin_unila/features/user/profile/screens/profile_screen.dart';
// import 'article_test_screen.dart'; // Import untuk testing CRUD artikel

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ecopoin Unila',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: AppColors.background,
      ),
      // home: const ArticleTestScreen(), // Untuk testing CRUD artikel
      home: const OnboardingScreen(), // Kembali ke sini setelah selesai testing
      routes: {
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
