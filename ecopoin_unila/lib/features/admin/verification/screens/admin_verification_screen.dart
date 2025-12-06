import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // [PENTING] Untuk ambil ID Admin
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/config/app_colors.dart';
import '../../../../services/waste_price_service.dart';
import '../../dashboard/screens/verification_detail_screen.dart';

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
  final WastePriceService _wastePriceService = WastePriceService();

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

  // --- LOGIC: UPDATE STATUS & HITUNG POIN DINAMIS ---
  Future<void> _updateStatus({
    required String docId,
    required String newStatus,
    required String userId,
    required String wasteType,
    required double weight,
  }) async {
    try {
      // 1. Ambil ID Admin yang sedang login
      final adminId = FirebaseAuth.instance.currentUser?.uid;

      int finalPoints = 0;

      // Logika jika disetujui (Approved)
      if (newStatus == 'approved') {
        int pointsPerKg = await _wastePriceService.getPointsForType(wasteType);

        // Jika harga tidak ditemukan, pakai default 100
        if (pointsPerKg == 0) {
          pointsPerKg = 100;
        }

        finalPoints = (pointsPerKg * weight).toInt();

        // Tambah Poin User
        await _firestore.collection('users').doc(userId).update({
          'points': FieldValue.increment(finalPoints),
        });

        // Buat Notifikasi Diterima
        await _firestore.collection('notifications').add({
          'userId': userId,
          'title': 'Setoran Diterima! 🎉',
          'body':
              'Setoran $wasteType seberat $weight kg berhasil. Kamu dapat $finalPoints Poin.',
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      // Logika jika ditolak (Rejected)
      else if (newStatus == 'rejected') {
        await _firestore.collection('notifications').add({
          'userId': userId,
          'title': 'Setoran Ditolak 😔',
          'body': 'Maaf, setoran sampahmu belum memenuhi syarat kami.',
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // 2. UPDATE UTAMA KE DATABASE
      // Menyimpan approvedAt (Waktu Server) dan approvedBy (ID Admin)
      await _firestore.collection('verificationRequests').doc(docId).update({
        'status': newStatus,
        'earnedPoints': finalPoints,
        'approvedAt': FieldValue.serverTimestamp(), // [FIX] Waktu Realtime
        'approvedBy': adminId, // [FIX] ID Admin tersimpan
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Status: ${newStatus == 'approved' ? 'Disetujui' : 'Ditolak'}. Poin: $finalPoints",
            ),
            backgroundColor: newStatus == 'approved'
                ? Colors.green
                : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- UI: CONFIRMATION DIALOG ---
  void _showConfirmationDialog(
    BuildContext context,
    String title,
    String content,
    Color color,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            child: const Text(
              "Ya, Lanjutkan",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Verifikasi Setoran",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
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
      stream: _firestore
          .collection('verificationRequests')
          .where('status', isEqualTo: status)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(status);
        }

        // Sorting Client-side (Agar yang baru diverifikasi muncul paling atas)
        final docs = snapshot.data!.docs;
        docs.sort((a, b) {
          final dA = a.data() as Map<String, dynamic>;
          final dB = b.data() as Map<String, dynamic>;

          // Logika Sorting:
          // Jika pending -> pakai createdAt (waktu upload)
          // Jika selesai -> pakai approvedAt (waktu verifikasi)
          Timestamp? tA = dA['status'] == 'pending'
              ? dA['createdAt']
              : (dA['approvedAt'] ?? dA['createdAt']);

          Timestamp? tB = dB['status'] == 'pending'
              ? dB['createdAt']
              : (dB['approvedAt'] ?? dB['createdAt']);

          if (tA == null) return 1;
          if (tB == null) return -1;
          return tB.compareTo(tA); // Descending (Terbaru diatas)
        });

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            return _buildCard(doc.id, data, status == 'pending');
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String status) {
    String message = "";
    if (status == 'pending') {
      message = "Tidak ada setoran baru";
    } else if (status == 'approved') {
      message = "Belum ada riwayat disetujui";
    } else {
      message = "Belum ada riwayat ditolak";
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String docId, Map<String, dynamic> data, bool isPending) {
    // [FIX] LOGIKA TANGGAL REALTIME
    // 1. Default: Ambil waktu upload user
    Timestamp? displayTimestamp = data['createdAt'] as Timestamp?;

    // 2. Jika status BUKAN pending (Disetujui/Ditolak),
    //    Gunakan waktu 'approvedAt' agar sesuai jam admin klik tombol.
    if (!isPending) {
      displayTimestamp =
          data['approvedAt'] as Timestamp? ??
          data['reviewedAt'] as Timestamp? ??
          displayTimestamp;
    }

    final date = displayTimestamp?.toDate();
    final depositAmount = (data['depositAmount'] ?? 0).toDouble();
    final weight = (data['weight'] ?? depositAmount).toDouble();

    final wasteType = data['wasteType'] ?? data['type'] ?? 'Sampah';
    final userId = data['userId'] ?? '';
    final points = (data['earnedPoints'] ?? data['points'] ?? 0).toInt();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor: Colors.black12,
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
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: const Icon(
                      Icons.person,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: UserNameFetcher(
                      userId: userId,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  // Menampilkan Jam/Tanggal sesuai logika di atas
                  Text(
                    date != null
                        ? DateFormat('dd MMM HH:mm').format(date)
                        : '-',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
              const Divider(height: 24),

              // CONTENT
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey[100],
                      child:
                          data['imageUrl'] != null &&
                              data['imageUrl'].toString().isNotEmpty
                          ? Image.network(data['imageUrl'], fit: BoxFit.cover)
                          : const Icon(Icons.image, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          wasteType,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text("Berat: $weight kg"),
                        // Jika pending, tulis "Hitung Otomatis"
                        Text(
                          isPending
                              ? "Poin: (Hitung Otomatis)"
                              : "Dapat: $points Pts",
                          style: const TextStyle(color: Colors.orange),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // ACTIONS (Hanya muncul jika Pending)
              if (isPending) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _showConfirmationDialog(
                            context,
                            "Tolak Setoran?",
                            "Setoran akan ditolak.",
                            Colors.red,
                            () => _updateStatus(
                              docId: docId,
                              newStatus: 'rejected',
                              userId: userId,
                              wasteType: wasteType,
                              weight: weight,
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.close,
                          size: 18,
                          color: Colors.red,
                        ),
                        label: const Text(
                          "Tolak",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showConfirmationDialog(
                            context,
                            "Terima Setoran?",
                            "Poin akan dihitung otomatis sesuai harga '$wasteType' saat ini.",
                            Colors.green,
                            () => _updateStatus(
                              docId: docId,
                              newStatus: 'approved',
                              userId: userId,
                              wasteType: wasteType,
                              weight: weight,
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.check,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Terima",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Helper Widget: Fetch Nama User
class UserNameFetcher extends StatelessWidget {
  final String userId;
  final TextStyle? style;
  const UserNameFetcher({super.key, required this.userId, this.style});

  @override
  Widget build(BuildContext context) {
    if (userId.isEmpty) return Text("Unknown ID", style: style);

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading...", style: style?.copyWith(color: Colors.grey));
        }

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data == null) return Text("Data Error", style: style);

          final name =
              data['name'] ??
              data['fullName'] ??
              data['email'] ??
              'User Tanpa Nama';

          return Text(
            name,
            style: style,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        }
        return Text(
          "User Tidak Ditemukan",
          style: style?.copyWith(color: Colors.red),
        );
      },
    );
  }
}
