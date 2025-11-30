import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/config/app_colors.dart';

class MyVouchersScreen extends StatelessWidget {
  const MyVouchersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Silakan login kembali")));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Voucher Saya",
          style: TextStyle(color: AppColors.textDark),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // PERBAIKAN: Mengarah ke collection 'userVouchers'
        stream: FirebaseFirestore.instance
            .collection('userVouchers')
            .where('userId', isEqualTo: user.uid)
            .orderBy('redeemedAt', descending: true)
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
                    Icons.confirmation_number_outlined,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Belum ada voucher yang ditukar",
                    style: TextStyle(color: Colors.grey.shade600),
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

              // Mapping data dari 'userVouchers'
              final title = data['rewardName'] ?? 'Hadiah';
              final cost = data['pointsCost'] ?? 0;
              final status = data['status'] ?? 'active';
              final voucherCode = data['voucherCode'] ?? 'CODE-ERROR';

              final Timestamp? ts = data['redeemedAt'];
              final date = ts != null
                  ? DateFormat('dd MMM yyyy, HH:mm').format(ts.toDate())
                  : 'Baru saja';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  // Border kiri warna hijau jika aktif, abu jika terpakai
                  border: Border(
                    left: BorderSide(
                      color: status == 'active'
                          ? AppColors.primary
                          : Colors.grey,
                      width: 4,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Icon Tiket
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.local_activity, // Ganti icon biar beda
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Info Voucher
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Doloar: $date",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Harga Poin
                        Text(
                          "-$cost Pts",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Area Kode Voucher (Dotted Border Style sederhana)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "KODE VOUCHER",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                voucherCode,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                          // Tombol Salin (Copy)
                          IconButton(
                            icon: const Icon(
                              Icons.copy,
                              size: 20,
                              color: AppColors.primary,
                            ),
                            tooltip: "Salin Kode",
                            onPressed: () {
                              // Implementasi Copy to Clipboard sederhana
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Kode $voucherCode disalin!"),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
