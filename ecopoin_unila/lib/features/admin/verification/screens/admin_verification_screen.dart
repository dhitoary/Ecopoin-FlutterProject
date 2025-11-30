import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ecopoin_unila/app/config/app_colors.dart';
import 'package:ecopoin_unila/features/admin/dashboard/screens/verification_detail_screen.dart';

class AdminVerificationScreen extends StatefulWidget {
  const AdminVerificationScreen({super.key});

  @override
  State<AdminVerificationScreen> createState() =>
      _AdminVerificationScreenState();
}

class _AdminVerificationScreenState extends State<AdminVerificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Verifikasi Setoran",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: "Menunggu"),
            Tab(text: "Disetujui"),
            Tab(text: "Ditolak"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildListByStatus('pending'),
          _buildListByStatus('approved'),
          _buildListByStatus('rejected'),
        ],
      ),
    );
  }

  Widget _buildListByStatus(String status) {
    return StreamBuilder<QuerySnapshot>(
      // PERBAIKAN: Hapus .orderBy('createdAt') agar data muncul tanpa Index Firestore
      stream: _firestore
          .collection('verificationRequests')
          .where('status', isEqualTo: status)
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
                Icon(Icons.inbox, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  "Tidak ada data $status",
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
            return _buildCard(doc.id, data);
          },
        );
      },
    );
  }

  Widget _buildCard(String docId, Map<String, dynamic> data) {
    // Handling null timestamp gracefully
    DateTime? date;
    if (data['createdAt'] != null && data['createdAt'] is Timestamp) {
      date = (data['createdAt'] as Timestamp).toDate();
    }

    final depositAmount = data['depositAmount'] ?? 0;
    final type = data['type'] ?? 'Sampah';

    Color statusIconColor;
    if (data['status'] == 'approved') {
      statusIconColor = Colors.green;
    } else if (data['status'] == 'rejected') {
      statusIconColor = Colors.red;
    } else {
      statusIconColor = Colors.orange;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerificationDetailScreen(
                verificationId: docId,
                verificationData: data,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[200],
                  child:
                      data['photoUrl'] != null &&
                          data['photoUrl'].toString().isNotEmpty
                      ? Image.network(
                          data['photoUrl'],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        )
                      : const Icon(Icons.image, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$type - $depositAmount kg",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date != null
                          ? DateFormat('dd MMM yyyy, HH:mm').format(date)
                          : 'Tanggal tidak tersedia',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: statusIconColor),
            ],
          ),
        ),
      ),
    );
  }
}
