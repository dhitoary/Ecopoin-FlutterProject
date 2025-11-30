import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/config/app_colors.dart';
import '../../../../services/firestore_service.dart';
import '../screens/user_deposit_detail_screen.dart'; // Import Detail Screen

class HistoryDepositTab extends StatelessWidget {
  const HistoryDepositTab({super.key});

  double _safeDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  int _safeInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return StreamBuilder<QuerySnapshot>(
      stream: firestoreService.getDepositHistory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.history, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "Belum ada riwayat setoran",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final data =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;

            final String type = data['type']?.toString() ?? 'Sampah';
            final double weight = _safeDouble(data['weight']);
            final int points = _safeInt(data['pointsEarned']);
            final String status = data['status'] ?? 'pending';

            String date = 'Baru saja';
            if (data['timestamp'] != null && data['timestamp'] is Timestamp) {
              date = DateFormat(
                'dd MMM yyyy, HH:mm',
              ).format((data['timestamp'] as Timestamp).toDate());
            }

            // Tentukan warna status
            Color statusColor = Colors.orange;
            if (status == 'approved') statusColor = Colors.green;
            if (status == 'rejected') statusColor = Colors.red;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: InkWell(
                onTap: () {
                  // Navigasi ke Detail
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserDepositDetailScreen(data: data),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.recycling, color: statusColor),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                type,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                date,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            status == 'rejected' ? 'Gagal' : "+$points Poin",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: status == 'rejected'
                                  ? Colors.red
                                  : AppColors.primary,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            "${weight.toStringAsFixed(1)} kg",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
