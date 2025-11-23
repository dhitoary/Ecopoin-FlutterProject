import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:device_preview/device_preview.dart'; // Pastikan ini ada
import 'firebase_options.dart';
import 'package:ecopoin_unila/app/config/app_colors.dart';
import 'package:ecopoin_unila/features/user/auth/screens/onboarding_screen.dart';
import 'package:ecopoin_unila/features/user/dashboard/screens/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    DevicePreview(
      // KITA PAKSA AKTIF (ganti kIsWeb jadi true)
      enabled: true,

      // Default ke iPhone 13 Pro Max biar langsung kelihatan mewah
      defaultDevice: Devices.ios.iPhone13ProMax,

      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ecopoin Unila',
      debugShowCheckedModeBanner: false,

      // --- BAGIAN INI WAJIB ADA AGAR BINGKAI MUNCUL ---
      locale: DevicePreview.locale(context), // <--- PENTING 1
      builder: DevicePreview.appBuilder, // <--- PENTING 2 (Jangan dihapus)

      // -----------------------------------------------
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Poppins',
      ),
      // Auth Gate: Cek status login
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            return const MainScreen();
          }
          return const OnboardingScreen();
        },
      ),
      routes: {'/main': (context) => const MainScreen()},
    );
  }
}
