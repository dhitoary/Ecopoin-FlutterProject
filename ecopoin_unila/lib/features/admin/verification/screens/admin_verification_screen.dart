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
      // Gunakan stream tanpa orderBy jika index belum siap
      stream: _firestore
          .collection('verificationRequests')
          .where('status', isEqualTo: status)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Error Database: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  "Tidak ada data '$status'",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        // Proses sorting di client-side agar lebih aman
        final docs = snapshot.data!.docs;
        docs.sort((a, b) {
          // Ambil data dengan aman
          final dataA = a.data() as Map<String, dynamic>;
          final dataB = b.data() as Map<String, dynamic>;

          // Cek keberadaan field createdAt
          final tA = dataA.containsKey('createdAt')
              ? (dataA['createdAt'] as Timestamp?)
              : null;
          final tB = dataB.containsKey('createdAt')
              ? (dataB['createdAt'] as Timestamp?)
              : null;

          // Handle null timestamp (anggap paling lama jika null)
          if (tA == null) return 1;
          if (tB == null) return -1;

          return tB.compareTo(tA); // Descending (Terbaru di atas)
        });

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            return _buildCard(doc.id, data);
          },
        );
      },
    );
  }

  Widget _buildCard(String docId, Map<String, dynamic> data) {
    DateTime? date;
    // --- PERBAIKAN PENTING: Safe Parsing untuk CreatedAt ---
    try {
      if (data.containsKey('createdAt') && data['createdAt'] != null) {
        final timestamp = data['createdAt'];
        if (timestamp is Timestamp) {
          date = timestamp.toDate();
        }
      }
    } catch (e) {
      debugPrint("Error parsing date for doc $docId: $e");
    }
    // -------------------------------------------------------

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
              // Foto Thumbnail
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
              // Info Text
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
              // Status Icon
              Icon(Icons.chevron_right, color: statusIconColor),
            ],
          ),
        ),
      ),
    );
  }
}
