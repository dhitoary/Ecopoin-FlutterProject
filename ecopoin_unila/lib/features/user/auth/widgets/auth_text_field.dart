import 'package:flutter/material.dart';
import '../../../../app/config/app_colors.dart';

class AuthTextField extends StatelessWidget {
  final String label;
  final String placeholder;
  final bool isPassword;
  final TextEditingController? controller; // 1. Menambahkan variabel controller

  const AuthTextField({
    super.key,
    required this.label,
    required this.placeholder,
    this.isPassword = false,
    this.controller, // 2. Menambahkan ke konstruktor (opsional agar tidak merusak RegisterScreen)
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        // Gunakan TextFormField atau TextField
        TextField(
          controller: controller, // 3. Pasang controller di sini
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}
