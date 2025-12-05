import 'package:cloud_firestore/cloud_firestore.dart';

class ArticleModel {
  final String id;
  final String title;
  final String summary; // Deskripsi singkat
  final String content; // Isi lengkap
  final String? imageUrl;
  final DateTime createdAt;

  ArticleModel({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    this.imageUrl,
    required this.createdAt,
  });

  factory ArticleModel.fromMap(String id, Map<String, dynamic> map) {
    return ArticleModel(
      id: id,
      title: map['title'] ?? '',
      summary: map['summary'] ?? '',
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class ArticleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'articles';

  // 1. Ambil Semua Artikel (Stream) - Untuk Admin & User
  Stream<List<ArticleModel>> getArticlesStream() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ArticleModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  // 2. Tambah Artikel Baru (Admin)
  Future<void> addArticle({
    required String title,
    required String summary,
    required String content,
    String? imageUrl,
  }) async {
    await _firestore.collection(_collection).add({
      'title': title,
      'summary': summary,
      'content': content,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 3. Update Artikel (Admin)
  Future<void> updateArticle({
    required String id,
    required String title,
    required String summary,
    required String content,
    String? imageUrl,
  }) async {
    await _firestore.collection(_collection).doc(id).update({
      'title': title,
      'summary': summary,
      'content': content,
      'imageUrl': imageUrl,
    });
  }

  // 4. Hapus Artikel (Admin)
  Future<void> deleteArticle(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
