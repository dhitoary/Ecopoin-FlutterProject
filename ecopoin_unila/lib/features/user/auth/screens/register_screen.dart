import 'package:flutter/material.dart';
import '../../../../app/config/app_colors.dart';
import '../widgets/auth_text_field.dart';
import '../../dashboard/screens/main_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // HTML: <div class="flex items-center...">
      appBar: AppBar(
        // HTML: <div class="...size-12...ArrowLeft">
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // HTML: <h2 class="...text-center pr-12">Register</h2>
        title: const Text(
          "Register",
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
              const SizedBox(height: 16.0),

              // Form Name
              const AuthTextField(
                label: "Name",
                placeholder: "Enter your name",
              ),
              const SizedBox(height: 16.0),

              // Form NPM
              const AuthTextField(label: "NPM", placeholder: "Enter your NPM"),
              const SizedBox(height: 16.0),

              // Form Email
              const AuthTextField(
                label: "Email",
                placeholder: "Enter your email",
              ),
              const SizedBox(height: 16.0),

              // Form Password
              const AuthTextField(
                label: "Password",
                placeholder: "Enter your password",
                isPassword: true,
              ),
              const SizedBox(height: 32.0),

              // HTML: <button class="...flex-1 bg-[#13e76b]...">
              ElevatedButton(
                onPressed: () {
                  // DEVELOPMENT: after register, go to MainScreen (bypass)
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
                  "Register",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24.0),

              // HTML: <p class="...text-center underline">Already have an account? Sign In</p>
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account? ",
                    style: TextStyle(color: AppColors.textDark),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigasi kembali ke Login
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      "Sign In",
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
