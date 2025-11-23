import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:ecopoin_unila/app/config/app_colors.dart';
import 'package:ecopoin_unila/features/user/auth/screens/onboarding_screen.dart';
import 'package:ecopoin_unila/features/user/dashboard/screens/main_screen.dart'; // Pastikan arahkan ke MainScreen (bukan HomeScreen langsung agar navigasi bawah muncul)

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
        // Pastikan font default enak dibaca
        fontFamily:
            'Poppins', // Jika Anda punya font Poppins, jika tidak baris ini bisa dihapus
      ),
      // Auth Gate: Cek status login
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 1. Jika masih loading status auth
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // 2. Jika ada data user (Berarti SUDAH LOGIN)
          if (snapshot.hasData) {
            return const MainScreen(); // Masuk ke Dashboard Utama
          }

          // 3. Jika belum login
          return const OnboardingScreen();
        },
      ),
      routes: {'/main': (context) => const MainScreen()},
    );
  }
}
