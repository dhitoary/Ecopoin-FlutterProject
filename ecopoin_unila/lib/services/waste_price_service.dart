import 'package:cloud_firestore/cloud_firestore.dart';

class WastePriceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'wasteTypes';

  // 1. Ambil Data (Stream) untuk ditampilkan di GUI Admin
  Stream<QuerySnapshot> getWasteTypesStream() {
    return _firestore.collection(_collection).orderBy('name').snapshots();
  }

  // 2. Tambah Tipe Sampah Baru
  Future<void> addWasteType(String name, int pointsPerKg) async {
    await _firestore.collection(_collection).add({
      'name': name,
      'points': pointsPerKg,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 3. Update Harga/Nama
  Future<void> updateWasteType(String id, String name, int pointsPerKg) async {
    await _firestore.collection(_collection).doc(id).update({
      'name': name,
      'points': pointsPerKg,
    });
  }

  // 4. Hapus Tipe Sampah
  Future<void> deleteWasteType(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  // 5. Helper: Ambil harga berdasarkan nama tipe (dipakai saat verifikasi)
  Future<int> getPointsForType(String typeName) async {
    try {
      // Cari dokumen yang namanya cocok (case-insensitive sebaiknya dihandle di input)
      final snapshot = await _firestore
          .collection(_collection)
          .where('name', isEqualTo: typeName)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return (snapshot.docs.first.data()['points'] ?? 0) as int;
      }
      return 0; // Jika tidak ketemu, default 0
    } catch (e) {
      return 0;
    }
  }
}
