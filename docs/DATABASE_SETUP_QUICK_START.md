# 🚀 Quick Start: Initialize Database - Ecopoin Unila

## ✅ Status: Anda Sudah Sampai Sini!

- ✅ Firebase Project dibuat
- ✅ Android app registered
- ✅ Firestore Database dibuat
- ✅ Credentials sudah terisi
- ✅ Flutter project sudah setup
- ⏳ **Tinggal: Initialize database structure**

---

## 📋 Langkah 1: Buat Collections di Firebase Console

### Buat 4 Collections:

1. **Buka Firebase Console** → Firestore Database
2. Klik **"Start collection"**
3. Collection ID: `users` → Create

Ulangi untuk:
- `articles`
- `rewards`
- `verificationRequests`

**Hasil akhir:**
```
Firestore Root
├── users/           ← Created
├── articles/        ← Created
├── rewards/         ← Created
└── verificationRequests/ ← Created
```

---

## 🔐 Langkah 2: Update Security Rules

### Buka Firestore → Rules Tab

Ganti dengan rules ini:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users - hanya bisa akses data sendiri
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
      match /depositHistory/{document=**} {
        allow read, write: if request.auth.uid == userId;
      }
      match /myRewards/{document=**} {
        allow read: if request.auth.uid == userId;
      }
    }
    
    // Articles - semua baca, admin tulis
    match /articles/{document=**} {
      allow read: if true;
      allow write: if request.auth.token.isAdmin == true;
    }
    
    // Rewards - semua baca, admin tulis
    match /rewards/{document=**} {
      allow read: if true;
      allow write: if request.auth.token.isAdmin == true;
    }
    
    // Verification - user create, admin manage
    match /verificationRequests/{document=**} {
      allow create: if request.auth != null;
      allow read, update: if request.auth.token.isAdmin == true;
    }
  }
}
```

Klik **"Publish"**

---

## 🛠️ Langkah 3: Populate Database dari Flutter

### A. Edit `main.dart`

Tambahkan import dan uncomment initialization code:

```dart
import 'package:ecopoin_unila/services/firebase_db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize sample database (jalankan SEKALI saja!)
  final dbHelper = FirebaseDBHelper();
  await dbHelper.initializeSampleDatabase();
  
  runApp(const MyApp());
}
```

### B. Jalankan App

```bash
flutter run
```

### C. Lihat Output Console

Tunggu sampai muncul:
```
✅ Added 3 sample articles
✅ Added 4 sample rewards
✅ Database initialized successfully!
```

### D. Verify di Firebase Console

1. Buka Firebase Console → Firestore Database
2. Klik collection `articles` → Lihat 3 articles
3. Klik collection `rewards` → Lihat 4 rewards
4. Selesai! ✅

---

## 📝 Langkah 4: Comment Kembali (PENTING!)

**Setelah data berhasil di-insert**, comment kembali:

```dart
// Initialize sample database (jalankan SEKALI saja!)
// final dbHelper = FirebaseDBHelper();
// await dbHelper.initializeSampleDatabase();
```

**Mengapa?** Agar tidak double insert setiap kali run app.

---

## 📊 Data Structure yang Sudah Diisi

### ✅ Articles (3 items)
- Cara Daur Ulang Plastik
- Pentingnya Daur Ulang Kertas
- Kaca: Bahan Daur Ulang Selamanya

### ✅ Rewards (4 items)
- Voucher Indomie Rp10.000 (100 poin)
- Diskon Belanja 20% (150 poin)
- Reusable Tumbler Premium (200 poin)
- Eco-Friendly Bag Tote (250 poin)

### ✅ Users (empty)
- Akan terisi saat user register

### ✅ Verification Requests (empty)
- Akan terisi saat user submit deposit

---

## 🔍 Testing Database Connection

Jalankan di Flutter untuk test query:

```dart
// Test 1: Get all articles
final articles = await FirestoreService().getArticles();
print('Articles: ${articles.length}'); // Should print: 3

// Test 2: Get rewards
final rewards = await FirestoreService().getRewards();
print('Rewards: ${rewards.length}'); // Should print: 4

// Test 3: Stream articles by category
FirestoreService()
    .getArticlesByCategory('plastik')
    .listen((snapshot) {
  print('Plastik articles: ${snapshot.docs.length}'); // Should print: 1
});
```

---

## ✅ Checklist

- [ ] Buat 4 collections di Firebase Console
- [ ] Update Security Rules dan Publish
- [ ] Edit main.dart dan uncomment initialization code
- [ ] Run app dengan `flutter run`
- [ ] Lihat success message di console
- [ ] Verify data di Firebase Console
- [ ] Comment kembali initialization code
- [ ] Test query dari Flutter

---

## 📚 Penjelasan: Apa Itu Setiap Collection?

**Lihat file `DATABASE_STRUCTURE.md` untuk penjelasan lengkap setiap koleksi!**

### Quick Summary:

| Collection | Tujuan | Public? | Edit By |
|----------|--------|---------|---------|
| **users** | Data pengguna | Private | User sendiri |
| **articles** | Edukasi sampah | Public (read) | Admin only |
| **rewards** | Daftar hadiah | Public (read) | Admin only |
| **verificationRequests** | Verifikasi deposit | Private | Admin |

---

## 🎯 Next Steps

Setelah database setup:

1. **Test Login/Register**
   - Create akun test di Firebase Auth
   - Create data user di Firestore

2. **Test Deposit Flow**
   - User submit deposit
   - Create verification request
   - Admin approve/reject

3. **Test Reward Redemption**
   - User klaim reward
   - Points berkurang

---

## 🚨 Troubleshooting

### ❌ Error: "Permission denied"
**Solusi:** Rules belum di-publish di Firebase Console

### ❌ Data tidak muncul
**Solusi:** Uncomment initialization code dan run app sekali lagi

### ❌ Duplicate data
**Solusi:** Hapus collections, run sekali, comment initialization code

### ❌ Error: "Collection not found"
**Solusi:** Buat collections dulu di Firebase Console

---

## ✨ Setelah Ini Done!

Database Anda siap untuk:
- ✅ Login/Register
- ✅ Deposit sampah
- ✅ Claim rewards
- ✅ Read edukasi artikel
- ✅ Admin verification

**Semua data akan tersimpan di Firestore Cloud!** ☁️

---

**Created:** November 9, 2025  
**Est. Time:** 5-10 menit untuk setup lengkap
