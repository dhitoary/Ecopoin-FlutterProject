import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/config/app_colors.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Silakan login kembali")));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Notifikasi", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Belum ada notifikasi",
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
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final isRead = data['read'] ?? false;
              final timestamp = (data['createdAt'] as Timestamp?)?.toDate();

              return Card(
                elevation: 0,
                color: isRead
                    ? Colors.white
                    : const Color(0xFFE8F5E9), // Hijau muda jika belum dibaca
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: isRead
                      ? BorderSide.none
                      : const BorderSide(color: AppColors.primary, width: 0.5),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getIconColor(data['type']).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIcon(data['type']),
                      color: _getIconColor(data['type']),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    data['title'] ?? 'Info',
                    style: TextStyle(
                      fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        data['message'] ?? '',
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        timestamp != null
                            ? DateFormat('dd MMM, HH:mm').format(timestamp)
                            : 'Baru saja',
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Tandai sudah dibaca saat diklik
                    if (!isRead) {
                      doc.reference.update({'read': true});
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _getIcon(String? type) {
    switch (type) {
      case 'verification_approved':
        return Icons.check_circle;
      case 'verification_rejected':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  Color _getIconColor(String? type) {
    switch (type) {
      case 'verification_approved':
        return Colors.green;
      case 'verification_rejected':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
