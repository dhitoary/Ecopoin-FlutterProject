import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// Model Data Reward
class RewardModel {
  final String id;
  final String name;
  final String category;
  final int pointsRequired;
  final int quantity;
  final String? imageUrl;
  final DateTime? createdAt;

  RewardModel({
    required this.id,
    required this.name,
    required this.category,
    required this.pointsRequired,
    required this.quantity,
    this.imageUrl,
    this.createdAt,
  });

  factory RewardModel.fromMap(String id, Map<String, dynamic> map) {
    return RewardModel(
      id: id,
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      pointsRequired: (map['pointsRequired'] ?? 0).toInt(),
      quantity: (map['quantity'] ?? 0).toInt(),
      imageUrl: map['imageUrl'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

class UserRewardsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream List Reward
  Stream<List<RewardModel>> getRewardsStream() {
    return _firestore
        .collection('rewards')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => RewardModel.fromMap(doc.id, doc.data()))
              .toList();
        });
  }

  // --- FUNGSI REDEEM YANG SUDAH DIPERBAIKI ---
  Future<void> redeemReward({
    required String rewardId,
    required String userId,
    required String rewardName,
    required int pointsCost,
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // 1. BACA SEMUA DATA DULU (Rules Firestore Wajib Baca Sebelum Tulis)
        final rewardRef = _firestore.collection('rewards').doc(rewardId);
        final userRef = _firestore.collection('users').doc(userId);

        final rewardSnapshot = await transaction.get(rewardRef);
        final userSnapshot = await transaction.get(userRef);

        // 2. CEK VALIDASI
        if (!rewardSnapshot.exists) throw Exception("Hadiah tidak ditemukan!");
        if (!userSnapshot.exists) throw Exception("User tidak ditemukan!");

        final rewardData = rewardSnapshot.data()!;
        final userData = userSnapshot.data()!;

        // Ambil stok dan poin saat ini
        int currentQuantity = (rewardData['quantity'] ?? 0).toInt();
        int currentPoints = (userData['points'] ?? 0).toInt();

        if (currentQuantity <= 0) throw Exception("Stok hadiah habis!");
        if (currentPoints < pointsCost) throw Exception("Poin tidak cukup!");

        // 3. LAKUKAN UPDATE (TULIS DATA)
        // Kurangi Stok
        transaction.update(rewardRef, {'quantity': currentQuantity - 1});

        // Kurangi Poin User
        transaction.update(userRef, {'points': currentPoints - pointsCost});

        // Buat Voucher Baru
        final voucherRef = _firestore.collection('userVouchers').doc();
        transaction.set(voucherRef, {
          'userId': userId,
          'rewardId': rewardId,
          'rewardName': rewardName,
          'pointsCost': pointsCost,
          'status': 'active',
          'voucherCode': _generateVoucherCode(),
          'redeemedAt': FieldValue.serverTimestamp(),
          'expiresAt': DateTime.now().add(
            const Duration(days: 90),
          ), // Expired 90 hari
        });
      });
    } catch (e) {
      debugPrint("Gagal redeem: $e");
      rethrow;
    }
  }

  // Generate Kode Unik
  String _generateVoucherCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    // Ambil 10 karakter acak
    return List.generate(
      10,
      (index) => chars[(random + index) % chars.length],
    ).join();
  }
}
