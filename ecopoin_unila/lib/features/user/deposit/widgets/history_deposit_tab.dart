import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/config/app_colors.dart';
import '../../../../services/verification_service.dart';
import '../screens/user_deposit_detail_screen.dart';

class HistoryDepositTab extends StatelessWidget {
  const HistoryDepositTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Pastikan menggunakan VerificationService agar datanya sama dengan Admin
    final VerificationService verificationService = VerificationService();

    return StreamBuilder<QuerySnapshot>(
      stream: verificationService.getUserVerifications(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          // DEBUG: Pesan ini akan muncul jika Index belum dibuat
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Data belum siap (Index Error). Cek Console.",
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  "Belum ada riwayat setoran",
                  style: TextStyle(color: Colors.grey[600]),
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

            // Ambil data dengan aman
            final status = data['status'] ?? 'pending';
            final type = data['type'] ?? 'Sampah';
            final weight = (data['depositAmount'] ?? 0).toString();
            final points = (data['earnedPoints'] ?? 0)
                .toString(); // Poin dari Service baru

            // Tanggal
            Timestamp? timestamp = data['createdAt'];
            if (status == 'approved' && data['approvedAt'] != null) {
              timestamp = data['approvedAt'];
            }
            final dateStr = timestamp != null
                ? DateFormat('dd MMM, HH:mm').format(timestamp.toDate())
                : '-';

            Color statusColor = Colors.orange;
            String statusText = "Menunggu";
            if (status == 'approved') {
              statusColor = Colors.green;
              statusText = "Berhasil";
            } else if (status == 'rejected') {
              statusColor = Colors.red;
              statusText = "Ditolak";
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserDepositDetailScreen(data: data),
                    ),
                  );
                },
                leading: CircleAvatar(
                  backgroundColor: statusColor.withOpacity(0.1),
                  child: Icon(Icons.recycling, color: statusColor, size: 20),
                ),
                title: Text(
                  type,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("$dateStr • $statusText"),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      status == 'approved' ? "+$points Poin" : "$weight Kg",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: status == 'approved'
                            ? AppColors.primary
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
