import 'package:flutter/material.dart';
import '../../../../app/config/app_colors.dart';
import '../widgets/auth_text_field.dart';
import 'register_screen.dart';
import '../../dashboard/screens/main_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // HTML: <h2 class="...flex-1 text-center...">
      appBar: AppBar(
        title: const Text(
          "EcoPoin Unila",
          style: TextStyle(color: AppColors.textDark),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // HTML: <div class="w-full bg-center...aspect-[2/3]...">
              // (Gambar placeholder opsional)
              Image.asset(
                'assets/images/auth_banner.png', // Ganti dengan aset Anda
                height: 250,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24.0),

              // Form Email/NPM
              const AuthTextField(
                label: "Email/NPM",
                placeholder: "Enter your email or NPM",
              ),
              const SizedBox(height: 16.0),

              // Form Password
              const AuthTextField(
                label: "Password",
                placeholder: "Enter your password",
                isPassword: true,
              ),
              const SizedBox(height: 12.0),

              // HTML: <p class="...underline">Forgot Password?</p>
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: AppColors.textGreen,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24.0),

              // HTML: <button class="...flex-1 bg-[#13e76b]...">
              ElevatedButton(
                onPressed: () {
                  // DEVELOPMENT: bypass login and go to MainScreen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textDark,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Login",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24.0),

              // Bagian untuk navigasi ke Register
              // (Diambil dari HTML Register: "Already have an account?")
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(color: AppColors.textDark),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                        color: AppColors.textGreen,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
