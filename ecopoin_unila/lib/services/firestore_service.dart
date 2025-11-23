import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // --- FUNGSI PENGAMAN SUPER (Bisa baca String/Int/Double) ---
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
  // -----------------------------------------------------------

  // 1. STREAM USER DATA
  Stream<DocumentSnapshot> getUserStream() {
    if (currentUserId == null) return const Stream.empty();
    return _db.collection('users').doc(currentUserId).snapshots();
  }

  // 2. INISIALISASI DATA USER
  Future<void> syncUserData() async {
    if (currentUserId == null) return;
    final userDoc = _db.collection('users').doc(currentUserId);
    final snapshot = await userDoc.get();

    if (!snapshot.exists) {
      await userDoc.set({
        'displayName': _auth.currentUser?.displayName ?? 'User',
        'email': _auth.currentUser?.email,
        'phoneNumber': '-',
        'points': 0,
        'totalDepositWeight': 0.0,
        'joinedAt': FieldValue.serverTimestamp(),
        'role': 'mahasiswa',
      });
    }
  }

  // 3. FITUR SETOR SAMPAH (Updated)
  Future<void> submitDeposit({
    required String type,
    required double weight,
    required String note,
    required int pointsEarned,
  }) async {
    if (currentUserId == null) return;

    try {
      await _db.runTransaction((transaction) async {
        final userRef = _db.collection('users').doc(currentUserId);
        final userSnapshot = await transaction.get(userRef);

        if (!userSnapshot.exists) {
          throw Exception("Data user tidak ditemukan. Silakan relogin.");
        }

        final data = userSnapshot.data() as Map<String, dynamic>;

        // PENGAMANAN: Baca data dengan fungsi safe
        int currentPoints = _safeInt(data['points']);
        double currentWeight = _safeDouble(data['totalDepositWeight']);

        // Update Poin & Berat (Pastikan hasil akhirnya sesuai format)
        transaction.update(userRef, {
          'points': currentPoints + pointsEarned,
          'totalDepositWeight': currentWeight + weight,
        });

        // Catat Riwayat
        final depositRef = _db.collection('deposits').doc();
        transaction.set(depositRef, {
          'userId': currentUserId,
          'type': type,
          'weight': weight,
          'note': note,
          'pointsEarned': pointsEarned,
          'status': 'Menunggu',
          'timestamp': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      // Lempar error asli agar muncul di snackbar
      throw Exception("Gagal transaksi database: $e");
    }
  }

  // 4. FITUR TUKAR POIN (Updated)
  Future<void> redeemReward({
    required String rewardTitle,
    required int cost,
  }) async {
    if (currentUserId == null) return;

    try {
      await _db.runTransaction((transaction) async {
        final userRef = _db.collection('users').doc(currentUserId);
        final userSnapshot = await transaction.get(userRef);

        if (!userSnapshot.exists) {
          throw Exception("User data not found");
        }

        final data = userSnapshot.data() as Map<String, dynamic>;
        int currentPoints = _safeInt(data['points']);

        if (currentPoints < cost) {
          throw Exception("Poin tidak mencukupi!");
        }

        transaction.update(userRef, {'points': currentPoints - cost});

        final transRef = _db.collection('transactions').doc();
        transaction.set(transRef, {
          'userId': currentUserId,
          'rewardTitle': rewardTitle,
          'cost': cost,
          'status': 'Berhasil',
          'timestamp': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      rethrow;
    }
  }

  // 5. AMBIL RIWAYAT DEPOSIT
  Stream<QuerySnapshot> getDepositHistory() {
    if (currentUserId == null) return const Stream.empty();
    return _db
        .collection('deposits')
        .where('userId', isEqualTo: currentUserId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // 6. UPDATE PROFILE
  Future<void> updateProfile({
    required String name,
    required String phone,
  }) async {
    if (currentUserId == null) return;
    try {
      await _db.collection('users').doc(currentUserId).update({
        'displayName': name,
        'phoneNumber': phone,
      });
      await _auth.currentUser?.updateDisplayName(name);
    } catch (e) {
      rethrow;
    }
  }

  // 7. RESET PASSWORD
  Future<void> sendPasswordResetEmail() async {
    if (_auth.currentUser?.email != null) {
      await _auth.sendPasswordResetEmail(email: _auth.currentUser!.email!);
    }
  }
}
