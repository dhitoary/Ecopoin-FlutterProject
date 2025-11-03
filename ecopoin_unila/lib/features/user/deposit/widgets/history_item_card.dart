import 'package:flutter/material.dart';
import '../../../../app/config/app_colors.dart';

class HistoryItemCard extends StatelessWidget {
  final String date;
  final String status;
  final String type;
  final String points;

  const HistoryItemCard({
    super.key,
    required this.date,
    required this.status,
    required this.type,
    required this.points,
  });

  // Helper untuk menentukan warna status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Selesai':
        return Colors.green;
      case 'Ditolak':
        return Colors.red;
      case 'Menunggu':
        return Colors.orange;
      default:
        return AppColors.textGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    // HTML: <div class="flex gap-4...justify-between">
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // HTML: <div class="flex flex-1 flex-col...">
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HTML: <p class="...text-base font-medium...">
                Text(
                  date,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4.0),
                // HTML: <p class="text-[#4c9a6c]...">
                Text(
                  status,
                  style: TextStyle(
                    color: _getStatusColor(status),
                    fontSize: 14,
                  ),
                ),
                Text(
                  type,
                  style: const TextStyle(
                    color: AppColors.textGreen,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // HTML: <div class="shrink-0">
          Text(
            points,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
