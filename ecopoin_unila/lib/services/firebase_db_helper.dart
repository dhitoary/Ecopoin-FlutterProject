/// Database Structure Documentation dan Helper Functions
///
/// Firestore Collections dan Structure untuk Ecopoin Unila
///
/// Created: November 9, 2025
/// Purpose: Define dan manage database schema

import 'package:cloud_firestore/cloud_firestore.dart';

/// ============================================================================
/// COLLECTIONS STRUCTURE
/// ============================================================================

/// 1. USERS Collection
///
/// Path: /users/{userId}
/// Purpose: Menyimpan data pengguna aplikasi
/// Access: Hanya user sendiri yang bisa akses (security rules)
///
/// Struktur:
/// {
///   "userId": "abc123",          // Auto dari auth UID
///   "name": "John Doe",           // Nama user
///   "email": "john@example.com",  // Email (sama dengan auth)
///   "points": 150,                // Total poin user (diupdate saat deposit)
///   "profilePhoto": "https://...", // URL foto profil (opsional)
///   "role": "user",               // "user" atau "admin"
///   "createdAt": Timestamp,       // Waktu akun dibuat
///   "lastLogin": Timestamp,       // Waktu login terakhir
///   "isVerified": false,          // Status verifikasi (untuk admin)
/// }
///
/// Sub-collections:
/// - depositHistory/: Riwayat deposit sampah user
/// - myRewards/: Rewards yang user telah klaim

/// 2. ARTICLES Collection
///
/// Path: /articles/{articleId}
/// Purpose: Menyimpan artikel edukasi tentang sampah & lingkungan
/// Access: Semua user bisa baca, hanya admin yang bisa tulis
///
/// Struktur:
/// {
///   "articleId": "art123",        // Auto-generated saat create
///   "title": "Cara Daur Ulang Plastik", // Judul artikel
///   "content": "Lorem ipsum...",  // Isi artikel (markdown supported)
///   "category": "plastik",        // Kategori: plastik, kertas, kaca, logam, dll
///   "image": "https://...",       // URL gambar artikel
///   "author": "Admin Name",       // Nama penulis
///   "createdAt": Timestamp,       // Tanggal publish
///   "updatedAt": Timestamp,       // Tanggal update terakhir
///   "views": 250,                 // Jumlah view (increment setiap dibuka)
/// }

/// 3. REWARDS Collection
///
/// Path: /rewards/{rewardId}
/// Purpose: Menyimpan daftar rewards yang bisa ditukar dengan poin
/// Access: Semua user bisa baca, hanya admin yang bisa tulis
///
/// Struktur:
/// {
///   "rewardId": "rew123",         // Auto-generated
///   "name": "Voucher Indomie Rp10.000", // Nama reward
///   "description": "Voucher makanan instan...", // Deskripsi
///   "pointsRequired": 100,        // Poin yang diperlukan untuk klaim
///   "image": "https://...",       // URL gambar reward
///   "category": "voucher",        // Kategori: voucher, discount, gift, dll
///   "quantity": 50,               // Jumlah tersedia (inventory)
///   "expiryDate": Timestamp,      // Tanggal expired reward
///   "createdAt": Timestamp,       // Tanggal dibuat
/// }

/// 4. VERIFICATION REQUESTS Collection
///
/// Path: /verificationRequests/{requestId}
/// Purpose: Menyimpan request verifikasi deposit yang perlu approval admin
/// Access: User bisa create request, admin bisa read dan approve
///
/// Struktur:
/// {
///   "requestId": "ver123",        // Auto-generated
///   "userId": "user123",          // ID user yang request
///   "depositAmount": 5,           // Berat sampah dalam kg
///   "depositCategory": "plastik", // Jenis sampah
///   "photoUrl": "https://...",    // Foto bukti deposit
///   "status": "pending",          // pending, approved, rejected
///   "createdAt": Timestamp,       // Waktu request dibuat
///   "verifiedAt": Timestamp,      // Waktu diverifikasi (null jika pending)
///   "verifiedBy": "admin123",     // UID admin yang verify (null jika pending)
///   "rejectionReason": "",        // Alasan reject (kosong jika approved)
/// }

/// ============================================================================
/// SUB-COLLECTIONS
/// ============================================================================

/// 5. DEPOSIT HISTORY (Sub-collection)
///
/// Path: /users/{userId}/depositHistory/{depositId}
/// Purpose: Menyimpan riwayat setiap deposit sampah yang dilakukan user
/// Access: Hanya user yang bisa akses data miliknya sendiri
///
/// Struktur:
/// {
///   "depositId": "dep123",        // Auto-generated
///   "amount": 5.5,                // Berat sampah dalam kg
///   "category": "plastik",        // Jenis: plastik, kertas, kaca, logam, dll
///   "pointsEarned": 55,           // Poin yang diperoleh (amount * pointPerKg)
///   "status": "approved",         // pending, approved, rejected
///   "photoUrl": "https://...",    // Foto bukti
///   "timestamp": Timestamp,       // Waktu deposit
///   "verificationId": "ver123",   // Reference ke verification request (opsional)
/// }

/// 6. MY REWARDS (Sub-collection)
///
/// Path: /users/{userId}/myRewards/{claimedRewardId}
/// Purpose: Menyimpan rewards yang sudah user klaim
/// Access: Hanya user yang bisa akses data miliknya sendiri
///
/// Struktur:
/// {
///   "claimedId": "claimed123",    // Auto-generated
///   "rewardId": "rew123",         // Reference ke reward di /rewards
///   "rewardName": "Voucher Indomie", // Copy dari reward.name
///   "pointsUsed": 100,            // Poin yang digunakan
///   "claimedAt": Timestamp,       // Waktu di-klaim
///   "expiryDate": Timestamp,      // Tanggal expired untuk claim ini
///   "status": "active",           // active, used, expired
/// }

/// ============================================================================
/// HELPER CLASS UNTUK INITIALIZE DATABASE
/// ============================================================================

class FirebaseDBHelper {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Initialize database dengan sample data (untuk testing)
  /// Jalankan ini sekali saja setelah first setup
  Future<void> initializeSampleDatabase() async {
    try {
      // 1. Add sample articles
      await _addSampleArticles();

      // 2. Add sample rewards
      await _addSampleRewards();

      print('✅ Database initialized successfully!');
    } catch (e) {
      throw Exception('Failed to initialize database: $e');
    }
  }

  /// ===== SAMPLE ARTICLES =====
  Future<void> _addSampleArticles() async {
    final articles = [
      {
        'title': 'Cara Daur Ulang Plastik yang Benar',
        'content':
            'Plastik adalah salah satu sampah terbesar di dunia. Untuk mendaur ulang plastik dengan benar, pastikan Anda memisahkan jenis plastik yang berbeda...',
        'category': 'plastik',
        'image': 'https://via.placeholder.com/400x200?text=Plastik',
        'author': 'Admin',
        'views': 0,
      },
      {
        'title': 'Pentingnya Daur Ulang Kertas',
        'content':
            'Kertas adalah salah satu material yang paling mudah didaur ulang. Dengan mendaur ulang kertas, kita bisa menyelamatkan banyak pohon...',
        'category': 'kertas',
        'image': 'https://via.placeholder.com/400x200?text=Kertas',
        'author': 'Admin',
        'views': 0,
      },
      {
        'title': 'Kaca: Bahan Daur Ulang Selamanya',
        'content':
            'Kaca adalah material yang bisa didaur ulang tanpa batas. Tidak ada batasan siklus daur ulang untuk kaca...',
        'category': 'kaca',
        'image': 'https://via.placeholder.com/400x200?text=Kaca',
        'author': 'Admin',
        'views': 0,
      },
    ];

    for (var article in articles) {
      await _db.collection('articles').add({
        ...article,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    print('✅ Added ${articles.length} sample articles');
  }

  /// ===== SAMPLE REWARDS =====
  Future<void> _addSampleRewards() async {
    final rewards = [
      {
        'name': 'Voucher Indomie Rp10.000',
        'description': 'Voucher makanan instan senilai Rp10.000',
        'pointsRequired': 100,
        'category': 'voucher',
        'image': 'https://via.placeholder.com/400x200?text=Indomie',
        'quantity': 50,
      },
      {
        'name': 'Diskon Belanja 20% di Toko Kami',
        'description': 'Diskon 20% untuk semua produk ramah lingkungan',
        'pointsRequired': 150,
        'category': 'discount',
        'image': 'https://via.placeholder.com/400x200?text=Discount',
        'quantity': 100,
      },
      {
        'name': 'Reusable Tumbler Premium',
        'description': 'Tumbler ramah lingkungan dengan desain eksklusif',
        'pointsRequired': 200,
        'category': 'merchandise',
        'image': 'https://via.placeholder.com/400x200?text=Tumbler',
        'quantity': 20,
      },
      {
        'name': 'Eco-Friendly Bag Tote',
        'description': 'Tas belanja ramah lingkungan dengan kapasitas besar',
        'pointsRequired': 250,
        'category': 'merchandise',
        'image': 'https://via.placeholder.com/400x200?text=Bag',
        'quantity': 15,
      },
    ];

    for (var reward in rewards) {
      await _db.collection('rewards').add({
        ...reward,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    print('✅ Added ${rewards.length} sample rewards');
  }

  /// ===== UTILITY: Get Statistics =====
  /// Gunakan untuk dashboard admin
  Future<Map<String, dynamic>> getDatabaseStats() async {
    try {
      final articlesCount = await _db.collection('articles').count().get();
      final rewardsCount = await _db.collection('rewards').count().get();
      final usersCount = await _db.collection('users').count().get();
      final verificationCount = await _db
          .collection('verificationRequests')
          .where('status', isEqualTo: 'pending')
          .count()
          .get();

      return {
        'articles': articlesCount.count,
        'rewards': rewardsCount.count,
        'users': usersCount.count,
        'pendingVerifications': verificationCount.count,
      };
    } catch (e) {
      throw Exception('Failed to get database stats: $e');
    }
  }
}
