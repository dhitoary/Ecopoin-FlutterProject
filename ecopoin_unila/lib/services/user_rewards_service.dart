import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

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
      pointsRequired: map['pointsRequired'] ?? 0,
      quantity: map['quantity'] ?? 0,
      imageUrl: map['imageUrl'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'pointsRequired': pointsRequired,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

/// Service untuk mengelola rewards untuk user
class UserRewardsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get all available rewards from Firestore (real-time stream)
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

  /// Get all available rewards (one-time query)
  Future<List<RewardModel>> getRewards() async {
    try {
      final snapshot = await _firestore
          .collection('rewards')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => RewardModel.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error getting rewards: $e');
      return [];
    }
  }

  /// Redeem a reward - decrement stock and create voucher for user
  Future<void> redeemReward({
    required String rewardId,
    required String userId,
    required String rewardName,
    required int pointsCost,
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // Get reward document
        final rewardRef = _firestore.collection('rewards').doc(rewardId);
        final rewardSnapshot = await transaction.get(rewardRef);

        if (!rewardSnapshot.exists) {
          throw Exception('Reward not found');
        }

        final rewardData = rewardSnapshot.data()!;
        int currentQuantity = rewardData['quantity'] ?? 0;

        if (currentQuantity <= 0) {
          throw Exception('Stock tidak cukup');
        }

        // Update reward quantity
        transaction.update(rewardRef, {'quantity': currentQuantity - 1});

        // Create voucher/redemption record for user
        final voucherRef = _firestore.collection('userVouchers').doc();
        transaction.set(voucherRef, {
          'userId': userId,
          'rewardId': rewardId,
          'rewardName': rewardName,
          'pointsCost': pointsCost,
          'status': 'active', // active, used, expired
          'redeemedAt': FieldValue.serverTimestamp(),
          'expiresAt': DateTime.now().add(const Duration(days: 90)),
          'voucherCode': _generateVoucherCode(),
        });

        // Update user points (deduct)
        final userRef = _firestore.collection('users').doc(userId);
        final userSnapshot = await transaction.get(userRef);

        if (userSnapshot.exists) {
          final userData = userSnapshot.data()!;
          int currentPoints = userData['points'] ?? 0;

          transaction.update(userRef, {'points': currentPoints - pointsCost});
        }
      });
    } catch (e) {
      debugPrint('Error redeeming reward: $e');
      rethrow;
    }
  }

  /// Get user's active vouchers
  Stream<QuerySnapshot> getUserVouchersStream(String userId) {
    return _firestore
        .collection('userVouchers')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .orderBy('redeemedAt', descending: true)
        .snapshots();
  }

  /// Generate unique voucher code
  String _generateVoucherCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    final code = List.generate(
      10,
      (index) => chars[(random + index) % chars.length],
    ).join();
    return code;
  }
}
