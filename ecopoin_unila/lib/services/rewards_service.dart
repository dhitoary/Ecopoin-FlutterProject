import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class RewardModel {
  final String id;
  final String category;
  final String name;
  final int pointsRequired;
  final int quantity;
  final String? imageUrl;
  final DateTime createdAt;

  RewardModel({
    required this.id,
    required this.category,
    required this.name,
    required this.pointsRequired,
    required this.quantity,
    this.imageUrl,
    required this.createdAt,
  });

  // Convert model to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'name': name,
      'pointsRequired': pointsRequired,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
    };
  }

  // Create model from Firestore document
  factory RewardModel.fromMap(String id, Map<String, dynamic> data) {
    return RewardModel(
      id: id,
      category: data['category'] ?? '',
      name: data['name'] ?? '',
      pointsRequired: data['pointsRequired'] ?? 0,
      quantity: data['quantity'] ?? 0,
      imageUrl: data['imageUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class RewardsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _rewardsCollection = 'rewards';

  // CREATE - Tambah reward baru
  Future<String> createReward({
    required String category,
    required String name,
    required int pointsRequired,
    required int quantity,
    String? imageUrl,
  }) async {
    try {
      // ✅ CHECK ROLE FROM FIRESTORE
      final isAdmin = await _isUserAdmin();
      if (!isAdmin) {
        throw Exception('Hanya admin yang bisa membuat reward');
      }

      final docRef = await _firestore.collection(_rewardsCollection).add({
        'category': category,
        'name': name,
        'pointsRequired': pointsRequired,
        'quantity': quantity,
        'imageUrl': imageUrl,
        'createdAt': DateTime.now(),
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Error creating reward: $e');
    }
  }

  // READ - Ambil semua rewards
  Future<List<RewardModel>> getAllRewards() async {
    try {
      final snapshot = await _firestore
          .collection(_rewardsCollection)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => RewardModel.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error fetching rewards: $e');
    }
  }

  // READ - Stream rewards (real-time)
  Stream<List<RewardModel>> getRewardsStream() {
    return _firestore
        .collection(_rewardsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => RewardModel.fromMap(doc.id, doc.data()))
              .toList();
        });
  }

  // READ - Cari reward berdasarkan query
  Future<List<RewardModel>> searchRewards(String query) async {
    try {
      if (query.isEmpty) {
        return getAllRewards();
      }

      // Firestore doesn't support full-text search, so we fetch all and filter
      final rewards = await getAllRewards();
      final lowerQuery = query.toLowerCase();

      return rewards
          .where(
            (reward) =>
                reward.name.toLowerCase().contains(lowerQuery) ||
                reward.category.toLowerCase().contains(lowerQuery),
          )
          .toList();
    } catch (e) {
      throw Exception('Error searching rewards: $e');
    }
  }

  // READ - Stream search results (real-time)
  Stream<List<RewardModel>> searchRewardsStream(String query) {
    if (query.isEmpty) {
      return getRewardsStream();
    }

    return getRewardsStream().map((rewards) {
      final lowerQuery = query.toLowerCase();
      return rewards
          .where(
            (reward) =>
                reward.name.toLowerCase().contains(lowerQuery) ||
                reward.category.toLowerCase().contains(lowerQuery),
          )
          .toList();
    });
  }

  // UPDATE - Perbarui reward
  Future<void> updateReward({
    required String rewardId,
    required String category,
    required String name,
    required int pointsRequired,
    required int quantity,
    String? imageUrl,
  }) async {
    try {
      // ✅ CHECK ROLE FROM FIRESTORE
      final isAdmin = await _isUserAdmin();
      if (!isAdmin) {
        throw Exception('Hanya admin yang bisa update reward');
      }

      await _firestore.collection(_rewardsCollection).doc(rewardId).update({
        'category': category,
        'name': name,
        'pointsRequired': pointsRequired,
        'quantity': quantity,
        'imageUrl': imageUrl,
      });
    } catch (e) {
      throw Exception('Error updating reward: $e');
    }
  }

  // UPDATE - Kurangi stok ketika user menukar reward
  Future<void> decrementRewardQuantity(String rewardId) async {
    try {
      final doc = await _firestore
          .collection(_rewardsCollection)
          .doc(rewardId)
          .get();

      if (doc.exists) {
        final currentQuantity = doc.data()?['quantity'] as int? ?? 0;
        if (currentQuantity > 0) {
          await _firestore.collection(_rewardsCollection).doc(rewardId).update({
            'quantity': currentQuantity - 1,
          });
        } else {
          throw Exception('Reward quantity is 0');
        }
      }
    } catch (e) {
      throw Exception('Error decrementing reward quantity: $e');
    }
  }

  // DELETE - Hapus reward
  Future<void> deleteReward(String rewardId) async {
    try {
      // ✅ CHECK ROLE FROM FIRESTORE
      final isAdmin = await _isUserAdmin();
      if (!isAdmin) {
        throw Exception('Hanya admin yang bisa delete reward');
      }

      await _firestore.collection(_rewardsCollection).doc(rewardId).delete();
    } catch (e) {
      throw Exception('Error deleting reward: $e');
    }
  }

  // GET - Ambil single reward by ID
  Future<RewardModel?> getRewardById(String rewardId) async {
    try {
      final doc = await _firestore
          .collection(_rewardsCollection)
          .doc(rewardId)
          .get();

      if (doc.exists) {
        return RewardModel.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching reward: $e');
    }
  }

  // UTILITY - Ambil rewards berdasarkan kategori
  Future<List<RewardModel>> getRewardsByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection(_rewardsCollection)
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => RewardModel.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error fetching rewards by category: $e');
    }
  }

  // ✅ CHECK ROLE FROM FIRESTORE
  Future<bool> _isUserAdmin() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      final role = userDoc.data()?['role'] as String?;
      return role == 'admin' || role == 'petugas';
    } catch (e) {
      debugPrint('Error checking admin role: $e');
      return false;
    }
  }
}
