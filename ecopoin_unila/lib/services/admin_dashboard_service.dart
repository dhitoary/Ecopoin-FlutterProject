import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Service untuk query dashboard metrics yang sinkron dengan Firestore
class AdminDashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===== VERIFICATION RELATED =====

  /// Stream total registered users dengan role 'mahasiswa' atau 'user'
  Stream<int> getTotalUsersStream() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      // Filter manual di client side untuk keamanan dan menghindari index error
      return snapshot.docs.where((doc) {
        final role = (doc.data()['role'] ?? 'user').toString().toLowerCase();
        return role == 'mahasiswa' || role == 'user';
      }).length;
    });
  }

  /// Stream total sampah (kg) dari semua approved verifications
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
