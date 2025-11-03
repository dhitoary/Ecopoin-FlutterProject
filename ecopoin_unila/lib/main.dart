import 'package:flutter/material.dart';
import 'package:ecopoin_unila/app/config/app_colors.dart';
import 'package:ecopoin_unila/features/user/auth/screens/onboarding_screen.dart';
import 'package:ecopoin_unila/features/user/dashboard/screens/home_screen.dart';
import 'package:ecopoin_unila/features/user/profile/screens/profile_screen.dart';

void main() {
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
      home: const OnboardingScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
