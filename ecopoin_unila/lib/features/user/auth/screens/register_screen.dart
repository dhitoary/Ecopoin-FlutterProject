import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../app/config/app_colors.dart';
import '../../../../services/firebase_auth_service.dart';
import '../widgets/auth_text_field.dart';
import 'login_screen.dart';
import '../../dashboard/screens/main_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controller untuk input text
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final FirebaseAuthService _authService = FirebaseAuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    setState(() {
      _isLoading = true;
    });

    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    // 1. Validasi Input
    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showError("Semua kolom harus diisi");
      return;
    }

    if (password != confirmPassword) {
      _showError("Password dan Konfirmasi Password tidak sama");
      return;
    }

    if (password.length < 6) {
      _showError("Password minimal 6 karakter");
      return;
    }

    // 2. Proses Register ke Firebase
    try {
      UserCredential? user = await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        displayName: name,
      );

      if (user != null && mounted) {
        // Jika sukses, langsung masuk ke MainScreen dan hapus history route sebelumnya
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      _showError(e.toString().replaceAll("Exception: ", ""));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Daftar Akun",
          style: TextStyle(color: AppColors.textDark),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Form Nama
              AuthTextField(
                label: "Nama Lengkap",
                placeholder: "Masukkan nama lengkap",
                controller: _nameController,
              ),
              const SizedBox(height: 16.0),

              // Form Email
              AuthTextField(
                label: "Email",
                placeholder: "Masukkan email aktif",
                controller: _emailController,
              ),
              const SizedBox(height: 16.0),

              // Form Password
              AuthTextField(
                label: "Password",
                placeholder: "Masukkan password",
                isPassword: true,
                controller: _passwordController,
              ),
              const SizedBox(height: 16.0),

              // Form Konfirmasi Password
              AuthTextField(
                label: "Konfirmasi Password",
                placeholder: "Ulangi password",
                isPassword: true,
                controller: _confirmPasswordController,
              ),
              const SizedBox(height: 24.0),

              // Tombol Daftar
              ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
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
                        "Daftar Sekarang",
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
                    "Sudah punya akun? ",
                    style: TextStyle(color: AppColors.textDark),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Kembali ke Login
                    },
                    child: const Text(
                      "Masuk",
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
