import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Service untuk query dashboard metrics yang sinkron dengan Firestore
class AdminDashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===== VERIFICATION RELATED =====

  /// Stream total registered users dengan role 'mahasiswa' atau 'user'
  Stream<int> getTotalUsersStream() {
    return _firestore
        .collection('users')
        .where('role', whereIn: ['mahasiswa', 'user'])
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Future untuk one-time query total users
  Future<int> getTotalUsers() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', whereIn: ['mahasiswa', 'user'])
          .get();
      return snapshot.docs.length;
    } catch (e) {
      debugPrint('Error getting total users: $e');
      return 0;
    }
  }

  /// Stream total sampah (kg) dari semua approved verifications
  /// Dijumlahkan dari field depositAmount
  Stream<double> getTotalWasteStream() {
    return _firestore
        .collection('verificationRequests')
        .where('status', isEqualTo: 'approved')
        .snapshots()
        .map((snapshot) {
      double total = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final amount = _safeDouble(data['depositAmount'] ?? 0);
        total += amount;
      }
      return total;
    });
  }

  /// Future untuk one-time query total waste
  Future<double> getTotalWaste() async {
    try {
      final snapshot = await _firestore
          .collection('verificationRequests')
          .where('status', isEqualTo: 'approved')
          .get();

      double total = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final amount = _safeDouble(data['depositAmount'] ?? 0);
        total += amount;
      }
      return total;
    } catch (e) {
      debugPrint('Error getting total waste: $e');
      return 0;
    }
  }

  // ===== HELPER FUNCTIONS =====

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
}
