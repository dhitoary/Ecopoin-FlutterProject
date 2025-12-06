import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class VerificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // Safe parsing functions
  double _safeDouble(dynamic value) {
    try {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  int _safeInt(dynamic value) {
    try {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    } catch (e) {
      return 0;
    }
  }

  // 1. SUBMIT VERIFICATION REQUEST (User)
  Future<void> submitVerificationRequest({
    required double depositAmount,
    required String photoUrl,
    required String type,
    required String note,
  }) async {
    if (currentUserId == null) throw Exception("User not authenticated");

    try {
      await _db.collection('verificationRequests').add({
        'userId': currentUserId,
        'depositAmount': depositAmount,
        'photoUrl': photoUrl,
        'type': type,
        'note': note,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'approvedAt': null,
        'approvedBy': null,
        'rejectionReason': null,
      });
    } catch (e) {
      debugPrint('Error submitting verification request: $e');
      rethrow;
    }
  }

  // 2. GET ALL PENDING REQUESTS (Admin)
  Stream<QuerySnapshot> getPendingVerifications() {
    return _db
        .collection('verificationRequests')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // 3. GET ALL VERIFICATIONS (Admin - All status)
  Stream<QuerySnapshot> getAllVerifications() {
    return _db
        .collection('verificationRequests')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // 4. GET VERIFICATIONS FOR CURRENT USER
  Stream<QuerySnapshot> getUserVerifications() {
    if (currentUserId == null) return const Stream.empty();
    return _db
        .collection('verificationRequests')
        .where('userId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // 5. APPROVE VERIFICATION REQUEST (Admin)
  Future<void> approveVerification({
    required String verificationId,
    required String userId,
    required double depositAmount,
  }) async {
    try {
      // 1. HITUNG POIN (Misal: 1kg = 500 Poin)
      // Sesuaikan angka pengali ini dengan kebijakan aplikasi kamu
      int pointsEarned = (depositAmount * 500).toInt();

      await _db.runTransaction((transaction) async {
        final userRef = _db.collection('users').doc(userId);
        final verificationRef = _db
            .collection('verificationRequests')
            .doc(verificationId);

        // Baca User
        final userSnapshot = await transaction.get(userRef);
        if (!userSnapshot.exists) throw Exception('User tidak ditemukan');

        final userData = userSnapshot.data() as Map<String, dynamic>;
        int currentPoints = _safeInt(userData['points']);
        double currentWeight = _safeDouble(userData['totalDepositWeight']);

        // 2. UPDATE STATUS & SIMPAN POIN KE RIWAYAT
        transaction.update(verificationRef, {
          'status': 'approved',
          'approvedAt': FieldValue.serverTimestamp(),
          'approvedBy': currentUserId,
          'earnedPoints':
              pointsEarned, // <--- INI KUNCINYA AGAR MUNCUL DI RIWAYAT
        });

        // 3. TAMBAH POIN KE USER
        transaction.update(userRef, {
          'points': currentPoints + pointsEarned,
          'totalDepositWeight': currentWeight + depositAmount,
        });

        // 4. BUAT NOTIFIKASI
        final notificationRef = _db.collection('notifications').doc();
        transaction.set(notificationRef, {
          'userId': userId,
          'title': 'Setoran Diterima! 🎉',
          'message':
              'Setoran $depositAmount kg berhasil. Kamu dapat $pointsEarned Poin.',
          'type': 'verification_approved',
          'read': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      debugPrint('Error approving: $e');
      rethrow;
    }
  }

  // 6. REJECT VERIFICATION REQUEST (Admin)
  Future<void> rejectVerification({
    required String verificationId,
    required String userId,
    required String rejectionReason,
  }) async {
    try {
      await _db.runTransaction((transaction) async {
        // Update verification request
        final verificationRef = _db
            .collection('verificationRequests')
            .doc(verificationId);
        transaction.update(verificationRef, {
          'status': 'rejected',
          'approvedAt': FieldValue.serverTimestamp(),
          'approvedBy': currentUserId,
          'rejectionReason': rejectionReason,
        });

        // Create notification for user
        final notificationRef = _db.collection('notifications').doc();
        transaction.set(notificationRef, {
          'userId': userId,
          'title': 'Setoran Ditolak',
          'message': 'Setoran Anda ditolak. Alasan: $rejectionReason',
          'type': 'verification_rejected',
          'verificationId': verificationId,
          'read': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      debugPrint('Error rejecting verification: $e');
      rethrow;
    }
  }

  // 7. GET USER DATA BY ID (For Admin to see user info)
  Future<DocumentSnapshot> getUserData(String userId) async {
    try {
      return await _db.collection('users').doc(userId).get();
    } catch (e) {
      debugPrint('Error getting user data: $e');
      rethrow;
    }
  }

  // 8. GET VERIFICATION COUNT BY STATUS (For Admin Dashboard)
  Future<Map<String, int>> getVerificationCounts() async {
    try {
      final pendingSnapshot = await _db
          .collection('verificationRequests')
          .where('status', isEqualTo: 'pending')
          .count()
          .get();

      final approvedSnapshot = await _db
          .collection('verificationRequests')
          .where('status', isEqualTo: 'approved')
          .count()
          .get();

      final rejectedSnapshot = await _db
          .collection('verificationRequests')
          .where('status', isEqualTo: 'rejected')
          .count()
          .get();

      return {
        'pending': pendingSnapshot.count ?? 0,
        'approved': approvedSnapshot.count ?? 0,
        'rejected': rejectedSnapshot.count ?? 0,
      };
    } catch (e) {
      debugPrint('Error getting verification counts: $e');
      return {'pending': 0, 'approved': 0, 'rejected': 0};
    }
  }

  // 9. GET TODAY'S VERIFICATION COUNT (STREAM - Real-time)
  Stream<int> getTodaysVerificationCountStream() {
    return _db
        .collection('verificationRequests')
        .where(
          'status',
          isEqualTo: 'approved',
        ) // Ambil semua yang approved dulu
        .snapshots()
        .map((snapshot) {
          int count = 0;
          final now = DateTime.now();

          for (var doc in snapshot.docs) {
            final data = doc.data();

            // Ambil field approvedAt, pastikan tidak null dan tipe datanya benar
            if (data['approvedAt'] != null && data['approvedAt'] is Timestamp) {
              final approvedDate = (data['approvedAt'] as Timestamp).toDate();

              // Logika Perbandingan: HANYA Tanggal, Bulan, dan Tahun (Abaikan Jam)
              if (approvedDate.year == now.year &&
                  approvedDate.month == now.month &&
                  approvedDate.day == now.day) {
                count++;
              }
            }
          }
          return count;
        });
  }

  // 10. GET TODAY'S VERIFICATION COUNT (FUTURE - One-time query)
  Future<int> getTodaysVerificationCount() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    try {
      final snapshot = await _db
          .collection('verificationRequests')
          .where('status', isEqualTo: 'approved')
          .where(
            'approvedAt',
            isGreaterThanOrEqualTo: startOfDay,
            isLessThanOrEqualTo: endOfDay,
          )
          .get();

      return snapshot.docs.length;
    } catch (e) {
      debugPrint('Error getting todays verification count: $e');
      return 0;
    }
  }
}
