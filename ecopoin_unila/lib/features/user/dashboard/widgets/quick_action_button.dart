import 'package:flutter/material.dart';
import '../../../../app/config/app_colors.dart';

class QuickActionButton extends StatelessWidget {
  final String title;
  final bool isPrimary;
  final VoidCallback onPressed;
  final IconData icon;

  const QuickActionButton({
    super.key,
    required this.title,
    required this.onPressed,
    required this.icon,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    // HTML: <button class="...bg-[#13e76b]..."> atau <...bg-[#e7f3ec]...">
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary
            ? AppColors.primary
            : AppColors.inputBackground,
        foregroundColor: AppColors.textDark,
        minimumSize: const Size(double.infinity, 52), // h-10 (40px) + padding
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 0,
      ),
    );
  }
}
