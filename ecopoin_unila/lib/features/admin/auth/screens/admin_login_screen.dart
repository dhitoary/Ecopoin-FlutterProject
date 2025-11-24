import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../app/config/app_colors.dart';
import '../../../../services/firebase_auth_service.dart';
import '../../../user/auth/widgets/auth_text_field.dart';
import '../../dashboard/screens/admin_dashboard_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuthService _authService = FirebaseAuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleAdminLogin() async {
    setState(() {
      _isLoading = true;
    });

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // Validasi input
    if (email.isEmpty || password.isEmpty) {
      _showError("Email dan Password tidak boleh kosong");
      return;
    }

    try {
      // 1. Login ke Firebase Auth
      UserCredential? user = await _authService.loginWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (user != null && mounted) {
        // 2. Cek role di Firestore
        String? role = await _authService.getUserRole(user.user!.uid);

        // Debug logs
        print("✅ Login berhasil, UID: ${user.user!.uid}");
        print("📋 Email: ${user.user!.email}");
        print("👤 Role dari Firestore: $role");

        if (role == 'admin' || role == 'petugas') {
          // ✅ 3. Jika role benar, langsung masuk dashboard
          print("✅ Role diterima, navigasi ke AdminDashboard");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminDashboardScreen(),
            ),
          );
        } else {
          // ❌ Jika role salah, logout
          print("❌ Role tidak ditemukan atau bukan admin/petugas: $role");
          await FirebaseAuth.instance.signOut();
          _showError("Akun ini bukan admin/petugas. Role: $role");
        }
      }
    } catch (e) {
      print("❌ Error login: $e");
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
          "Login Admin / Petugas",
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
              const SizedBox(height: 40.0),
              const Text(
                "Akses Admin",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12.0),
              const Text(
                "Masukkan kredensial admin Anda",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textDark),
              ),
              const SizedBox(height: 48.0),

              // Form Email
              AuthTextField(
                label: "Email Admin",
                placeholder: "Masukkan email admin",
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
              const SizedBox(height: 24.0),

              // Tombol Login
              ElevatedButton(
                onPressed: _isLoading ? null : _handleAdminLogin,
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
                        "Masuk sebagai Admin",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 24.0),

              // Link kembali ke login user
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Bukan admin? ",
                    style: TextStyle(color: AppColors.textDark),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Kembali ke Login
                    },
                    child: const Text(
                      "Login sebagai User",
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
