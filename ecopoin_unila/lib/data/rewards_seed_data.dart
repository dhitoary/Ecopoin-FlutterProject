/// File ini berisi data rewards yang akan di-seed ke Firestore
/// Jalankan setup ini melalui Cloud Firestore console atau
/// gunakan function di bawah untuk seed otomatis

const List<Map<String, dynamic>> INLINE_REWARDS = [
  {
    "name": "Voucher Kantin",
    "category": "Makanan & Minuman",
    "pointsRequired": 500,
    "quantity": 50,
    "imageUrl": "assets/images/reward_voucher.png",
  },
  {
    "name": "Totebag Unila",
    "category": "Merchandise",
    "pointsRequired": 1500,
    "quantity": 15,
    "imageUrl": "assets/images/reward_totebag.png",
  },
  {
    "name": "Kopi Gratis",
    "category": "Makanan & Minuman",
    "pointsRequired": 300,
    "quantity": 100,
    "imageUrl": "assets/images/reward_coffee.png",
  },
  {
    "name": "Saldo E-Wallet",
    "category": "Digital",
    "pointsRequired": 2500,
    "quantity": 10,
    "imageUrl": "assets/images/reward_giftcard.png",
  },
];

/// Dokumentasi cara seed rewards ke Firestore:
/// 
/// 1. Via Firebase Console:
///    - Buka Firebase Console > Firestore Database
///    - Create collection: "rewards"
///    - Untuk setiap reward dalam list di atas, buat document baru dengan fields:
///      * name (string)
///      * category (string)
///      * pointsRequired (number)
///      * quantity (number)
///      * imageUrl (string)
///      * createdAt (timestamp)
///
/// 2. Via Flutter Code (dalam main.dart atau initialization):
///    ```dart
///    import 'package:cloud_firestore/cloud_firestore.dart';
///    
///    Future<void> seedRewards() async {
///      final firestore = FirebaseFirestore.instance;
///      
///      for (var reward in INLINE_REWARDS) {
///        await firestore.collection('rewards').add({
///          ...reward,
///          'createdAt': FieldValue.serverTimestamp(),
///        });
///      }
///      
///      print('Rewards seeding completed!');
///    }
///    ```
///
/// 3. Cara menjalankan:
///    - Tambahkan call ke seedRewards() di startup app
///    - Atau buat admin button untuk trigger seeding
///    - Atau manual insert via Firebase Console
