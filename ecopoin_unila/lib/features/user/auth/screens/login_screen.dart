import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../app/config/app_colors.dart';
import '../../../../services/firebase_auth_service.dart'; // Pastikan import ini benar
import '../widgets/auth_text_field.dart';
import 'register_screen.dart';
import 'admin_login_screen.dart';
import '../../dashboard/screens/main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 1. Controller untuk menangkap input user
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Service Auth
  final FirebaseAuthService _authService = FirebaseAuthService();

  // State untuk loading
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Fungsi Login
  void _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // Validasi sederhana
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email dan Password tidak boleh kosong")),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Panggil service login
      UserCredential? user = await _authService.loginWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (user != null && mounted) {
        // Jika sukses, navigasi ke MainScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } catch (e) {
      // Tampilkan error jika gagal
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll("Exception: ", "")),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
              Image.asset(
                'assets/images/auth_banner.png',
                height: 250,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24.0),

              // Form Email/NPM
              // Pastikan AuthTextField menerima parameter 'controller'
              AuthTextField(
                label: "Email",
                placeholder: "Masukkan email Anda",
                controller: _emailController, // Hubungkan controller
              ),
              const SizedBox(height: 16.0),

              // Form Password
              AuthTextField(
                label: "Password",
                placeholder: "Masukkan password Anda",
                isPassword: true,
                controller: _passwordController, // Hubungkan controller
              ),
              const SizedBox(height: 12.0),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Tambahkan fitur lupa password nanti
                  },
                  child: const Text(
                    "Lupa Password?",
                    style: TextStyle(
                      color: AppColors.textGreen,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24.0),

              // Tombol Login
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : _handleLogin, // Disable saat loading
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textDark,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.textDark,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Masuk",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 24.0),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Belum punya akun? ",
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
                      "Daftar",
                      style: TextStyle(
                        color: AppColors.textGreen,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminLoginScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Login sebagai Admin / Petugas",
                  style: TextStyle(
                    color: AppColors.textGreen,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
