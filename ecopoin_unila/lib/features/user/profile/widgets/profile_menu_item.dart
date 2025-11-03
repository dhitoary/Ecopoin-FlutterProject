import 'package:flutter/material.dart';
import '../../../../app/config/app_colors.dart';

class ProfileMenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isLogout;

  const ProfileMenuItem({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    // HTML: <div class="flex items-center gap-4...min-h-14">
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 4.0,
      ),
      // HTML: <div class="...bg-[#e7f3ec] shrink-0 size-10">
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isLogout
              ? const Color.fromRGBO(255, 0, 0, 0.1)
              : AppColors.inputBackground,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Icon(
          icon,
          color: isLogout ? Colors.red : AppColors.textDark,
          size: 24,
        ),
      ),
      // HTML: <p class="...text-base font-normal...">
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? Colors.red : AppColors.textDark,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      // HTML: <div class="...ArrowRight...">
      trailing: isLogout
          ? null
          : const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textDark,
            ),
    );
  }
}
