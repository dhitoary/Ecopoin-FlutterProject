import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ===== USER COLLECTION =====

  // Tambah atau update user data
  Future<void> addOrUpdateUser({
    required String userId,
    required Map<String, dynamic> userData,
  }) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .set(userData, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Gagal menyimpan data user: $e');
    }
  }

  // Ambil data user
  Future<DocumentSnapshot> getUser(String userId) async {
    try {
      return await _db.collection('users').doc(userId).get();
    } catch (e) {
      throw Exception('Gagal mengambil data user: $e');
    }
  }

  // Stream data user (real-time)
  Stream<DocumentSnapshot> getUserStream(String userId) {
    return _db.collection('users').doc(userId).snapshots();
  }

  // ===== ARTICLES/EDUCATION COLLECTION =====

  // Tambah artikel
  Future<String> addArticle({required Map<String, dynamic> articleData}) async {
    try {
      DocumentReference docRef = await _db
          .collection('articles')
          .add(articleData);
      return docRef.id;
    } catch (e) {
      throw Exception('Gagal menambah artikel: $e');
    }
  }

  // Ambil semua artikel
  Future<List<QueryDocumentSnapshot>> getArticles() async {
    try {
      QuerySnapshot snapshot = await _db.collection('articles').get();
      return snapshot.docs;
    } catch (e) {
      throw Exception('Gagal mengambil artikel: $e');
    }
  }

  // Stream artikel berdasarkan kategori
  Stream<QuerySnapshot> getArticlesByCategory(String category) {
    return _db
        .collection('articles')
        .where('category', isEqualTo: category)
        .snapshots();
  }

  // ===== DEPOSIT/REWARD HISTORY COLLECTION =====

  // Tambah history deposit
  Future<String> addDepositHistory({
    required String userId,
    required Map<String, dynamic> depositData,
  }) async {
    try {
      DocumentReference docRef = await _db
          .collection('users')
          .doc(userId)
          .collection('depositHistory')
          .add(depositData);
      return docRef.id;
    } catch (e) {
      throw Exception('Gagal menambah history deposit: $e');
    }
  }

  // Stream deposit history user
  Stream<QuerySnapshot> getUserDepositHistory(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('depositHistory')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // ===== REWARDS COLLECTION =====

  // Ambil semua rewards
  Future<List<QueryDocumentSnapshot>> getRewards() async {
    try {
      QuerySnapshot snapshot = await _db.collection('rewards').get();
      return snapshot.docs;
    } catch (e) {
      throw Exception('Gagal mengambil rewards: $e');
    }
  }

  // Ambil reward berdasarkan ID
  Future<DocumentSnapshot> getRewardById(String rewardId) async {
    try {
      return await _db.collection('rewards').doc(rewardId).get();
    } catch (e) {
      throw Exception('Gagal mengambil reward: $e');
    }
  }

  // Tambah reward untuk user (sub-collection)
  Future<void> addUserReward({
    required String userId,
    required Map<String, dynamic> rewardData,
  }) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('myRewards')
          .add(rewardData);
    } catch (e) {
      throw Exception('Gagal menambah reward user: $e');
    }
  }

  // Stream user rewards
  Stream<QuerySnapshot> getUserRewards(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('myRewards')
        .snapshots();
  }

  // ===== POINTS/BALANCE COLLECTION =====

  // Update poin user
  Future<void> updateUserPoints({
    required String userId,
    required int points,
  }) async {
    try {
      await _db.collection('users').doc(userId).update({
        'points': FieldValue.increment(points),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Gagal mengupdate poin: $e');
    }
  }

  // ===== VERIFICATION/ADMIN COLLECTION =====

  // Tambah request verifikasi
  Future<String> addVerificationRequest({
    required String userId,
    required Map<String, dynamic> verificationData,
  }) async {
    try {
      DocumentReference docRef = await _db
          .collection('verificationRequests')
          .add({
            'userId': userId,
            'status': 'pending',
            'createdAt': FieldValue.serverTimestamp(),
            ...verificationData,
          });
      return docRef.id;
    } catch (e) {
      throw Exception('Gagal membuat request verifikasi: $e');
    }
  }

  // Ambil verification requests (untuk admin)
  Future<List<QueryDocumentSnapshot>> getPendingVerifications() async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('verificationRequests')
          .where('status', isEqualTo: 'pending')
          .get();
      return snapshot.docs;
    } catch (e) {
      throw Exception('Gagal mengambil verifikasi: $e');
    }
  }

  // ===== GENERIC METHODS =====

  // Hapus dokumen
  Future<void> deleteDocument({
    required String collection,
    required String documentId,
  }) async {
    try {
      await _db.collection(collection).doc(documentId).delete();
    } catch (e) {
      throw Exception('Gagal menghapus dokumen: $e');
    }
  }

  // Update dokumen
  Future<void> updateDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _db.collection(collection).doc(documentId).update(data);
    } catch (e) {
      throw Exception('Gagal mengupdate dokumen: $e');
    }
  }
}
