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
        // Hapus orderBy sementara jika index belum ada
        // .orderBy('createdAt', descending: true)
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

  // 5. APPROVE VERIFICATION REQUEST (Admin) - FIXED & ROBUST
  Future<void> approveVerification({
    required String verificationId,
    required String userId,
    required double depositAmount,
  }) async {
    try {
      // Hitung poin (1kg = 10 poin)
      int pointsEarned = (depositAmount * 10).toInt();

      await _db.runTransaction((transaction) async {
        // 1. Ambil referensi dokumen user
        final userRef = _db.collection('users').doc(userId);
        final userSnapshot = await transaction.get(userRef);

        // 2. Siapkan data baru
        int newPoints = pointsEarned;
        double newTotalWeight = depositAmount;

        // 3. Jika user ada, tambahkan ke data lama
        if (userSnapshot.exists) {
          final data = userSnapshot.data() as Map<String, dynamic>;

          // Gunakan safe parsing untuk data yang ada di database
          int currentPoints = _safeInt(data['points']);
          double currentWeight = _safeDouble(data['totalDepositWeight']);

          newPoints += currentPoints;
          newTotalWeight += currentWeight;

          // Update user
          transaction.update(userRef, {
            'points': newPoints,
            'totalDepositWeight': newTotalWeight,
          });
        } else {
          // Jika user entah kenapa tidak ada (jarang terjadi), buat doc baru/abaikan
          // Untuk keamanan, kita bisa log atau throw error, tapi di sini kita abaikan update user
          debugPrint("User $userId not found during approval transaction");
        }

        // 4. Update status verifikasi
        final verificationRef = _db
            .collection('verificationRequests')
            .doc(verificationId);
        transaction.update(verificationRef, {
          'status': 'approved',
          'pointsEarned':
              pointsEarned, // Simpan juga berapa poin yang didapat di history
          'approvedAt': FieldValue.serverTimestamp(),
          'approvedBy': currentUserId,
        });

        // 5. Buat notifikasi
        final notificationRef = _db.collection('notifications').doc();
        transaction.set(notificationRef, {
          'userId': userId,
          'title': 'Setoran Disetujui',
          'message':
              'Setoran sampah seberat ${depositAmount}kg telah disetujui! Kamu dapat $pointsEarned poin.',
          'type': 'verification_approved',
          'verificationId': verificationId,
          'read': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      debugPrint('Error approving verification: $e');
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
          'message': 'Maaf, setoranmu ditolak. Alasan: $rejectionReason',
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

  // ... (Sisa method lainnya tetap sama: getUserData, getVerificationCounts, dll)
  // Copy-paste method lainnya dari file sebelumnya jika diperlukan, atau biarkan jika sudah ada.

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

  Stream<int> getTodaysVerificationCountStream() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    return _db
        .collection('verificationRequests')
        .where('status', isEqualTo: 'approved')
        .where(
          'approvedAt',
          isGreaterThanOrEqualTo: startOfDay,
          isLessThanOrEqualTo: endOfDay,
        )
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
