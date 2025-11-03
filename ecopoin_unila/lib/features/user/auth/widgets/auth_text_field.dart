import 'package:flutter/material.dart';
import '../../../../app/config/app_colors.dart';

class AuthTextField extends StatelessWidget {
  final String label;
  final String placeholder;
  final bool isPassword;

  const AuthTextField({
    super.key,
    required this.label,
    required this.placeholder,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    // HTML: <label class="flex flex-col...">
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HTML: <p class="...pb-2">
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8.0), // pb-2
        // HTML: <input class="form-input...">
        TextFormField(
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(
              color: AppColors.textGreen, // placeholder:text-[#4c9a6c]
            ),
            filled: true,
            fillColor: AppColors.inputBackground, // bg-[#e7f3ec]
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none, // border-none
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 18.0, // h-14
            ),
          ),
        ),
      ],
    );
  }
}
