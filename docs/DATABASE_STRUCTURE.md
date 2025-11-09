# 📊 Firestore Database Setup Guide - Ecopoin Unila

## 🎯 Apa itu Firestore?

**Firestore** adalah NoSQL cloud database dari Firebase yang:
- ✅ Real-time: Data update otomatis ke semua client
- ✅ Scalable: Bisa handle jutaan users
- ✅ Structured: Pakai Collections dan Documents (mirip folder dan file)
- ✅ Secure: Built-in authentication dan security rules

---

## 📁 Struktur Database (Collections & Documents)

### Level 0: Root Collections

Firestore tidak punya "tables" seperti SQL, tapi punya **Collections** (mirip folder):

```
Firestore Database
├── users/                    ← Collection
├── articles/                 ← Collection
├── rewards/                  ← Collection
└── verificationRequests/     ← Collection
```

---

## 📋 Penjelasan Setiap Koleksi

### 1. **USERS** Collection
**Fungsi:** Menyimpan data semua pengguna aplikasi

```
/users/{userId}
{
  "userId": "abc123xyz",
  "name": "John Doe",
  "email": "john@ecopoin.com",
  "points": 250,              ← Total poin (dari deposit)
  "profilePhoto": "https://...",
  "role": "user",             ← "user" atau "admin"
  "createdAt": 2025-11-09,
  "lastLogin": 2025-11-09,
  "isVerified": false
}
```

**Sub-collections dalam user:**
- `depositHistory/` → Riwayat setiap deposit sampah
- `myRewards/` → Rewards yang sudah di-klaim user

**Mengapa?** 
- Setiap user punya profile sendiri
- Poin dihitung dari total deposit yang disetujui admin
- Role "admin" untuk akses panel admin

---

### 2. **ARTICLES** Collection
**Fungsi:** Menyimpan artikel edukasi tentang sampah & daur ulang

```
/articles/{articleId}
{
  "title": "Cara Daur Ulang Plastik",
  "content": "Plastik adalah...",
  "category": "plastik",      ← Kategori sampah
  "image": "https://...",
  "author": "Admin Name",
  "createdAt": 2025-11-09,
  "updatedAt": 2025-11-09,
  "views": 125                ← Jumlah pembaca
}
```

**Kategori yang Disupport:**
- `plastik` - Sampah plastik
- `kertas` - Sampah kertas
- `kaca` - Sampah kaca
- `logam` - Sampah logam
- `organik` - Sampah organik

**Mengapa?**
- User bisa belajar tentang setiap jenis sampah
- Admin bisa manage artikel dari panel
- Kategori membantu user filter artikel sesuai jenis sampah

---

### 3. **REWARDS** Collection
**Fungsi:** Menyimpan daftar hadiah yang bisa ditukar dengan poin

```
/rewards/{rewardId}
{
  "name": "Voucher Indomie Rp10.000",
  "description": "Voucher makanan...",
  "pointsRequired": 100,      ← Poin yang diperlukan
  "category": "voucher",      ← Jenis reward
  "image": "https://...",
  "quantity": 50,             ← Stok tersedia
  "expiryDate": 2025-12-31,
  "createdAt": 2025-11-09
}
```

**Kategori Reward:**
- `voucher` - Voucher makanan/belanja
- `discount` - Diskon di toko tertentu
- `merchandise` - Barang fisik (tas, tumbler, dll)

**Mengapa?**
- User bisa lihat rewards apa aja yang bisa ditukar
- Admin atur harga (dalam poin) dan stok setiap reward
- User klaim reward dengan menukar poin mereka

---

### 4. **VERIFICATION REQUESTS** Collection
**Fungsi:** Menyimpan request verifikasi deposit yang menunggu approval admin

```
/verificationRequests/{requestId}
{
  "userId": "abc123xyz",
  "depositAmount": 5.5,        ← Berat sampah (kg)
  "depositCategory": "plastik",
  "photoUrl": "https://...",   ← Foto bukti
  "status": "pending",         ← pending/approved/rejected
  "createdAt": 2025-11-09,
  "verifiedAt": null,          ← Diisi saat approve
  "verifiedBy": null,          ← Admin yang verify
  "rejectionReason": ""        ← Alasan reject
}
```

**Status:**
- `pending` - Menunggu admin verifikasi
- `approved` - Sudah disetujui, poin ditambahkan ke user
- `rejected` - Ditolak admin, poin tidak ditambahkan

**Mengapa?**
- Admin perlu verify deposit real atau tidak
- Mencegah fraud (orang klaim deposit palsu)
- Dokumentasi foto sebagai bukti

---

## 🔗 SUB-COLLECTIONS (Collections dalam Collections)

### 5. **DEPOSIT HISTORY** (Sub-collection)
**Path:** `/users/{userId}/depositHistory/{depositId}`
**Fungsi:** Riwayat setiap deposit yang dilakukan user

```
{
  "amount": 5.5,               ← Berat (kg)
  "category": "plastik",
  "pointsEarned": 55,          ← Poin yang diperoleh (5.5 kg × 10 poin/kg)
  "status": "approved",        ← pending/approved/rejected
  "photoUrl": "https://...",
  "timestamp": 2025-11-09,
  "verificationId": "ver123"   ← Link ke verification request
}
```

**Formula Poin:**
```
points = weight (kg) × pointsPerKg
Contoh: 5 kg plastik = 5 × 10 = 50 poin
```

**Mengapa sub-collection?**
- Setiap user punya riwayat depositnya sendiri
- Query lebih cepat (tidak perlu filter userId)
- Auto-delete saat user dihapus (cascade delete)

---

### 6. **MY REWARDS** (Sub-collection)
**Path:** `/users/{userId}/myRewards/{claimedId}`
**Fungsi:** Rewards yang sudah user klaim/tukar

```
{
  "rewardId": "rew123",        ← Link ke reward di /rewards
  "rewardName": "Voucher Indomie",
  "pointsUsed": 100,           ← Poin yang digunakan untuk klaim
  "claimedAt": 2025-11-09,
  "expiryDate": 2025-12-09,    ← Reward expired kapan
  "status": "active"           ← active/used/expired
}
```

**Mengapa sub-collection?**
- Track rewards mana aja yang user sudah klaim
- Tau mana yang sudah dipakai dan mana yang expired
- User bisa lihat history reward-nya

---

## ⚙️ Setup Database di Firebase Console

### Step 1: Buka Firestore Database

1. Firebase Console → Project Anda → Build → Firestore Database
2. Klik "Create Database" (jika belum ada)
3. Pilih region: `asia-southeast1`
4. Pilih mode: **"Test mode"** (untuk development)

### Step 2: Buat Collections

Di Firestore Console, buat 4 collections ini:

1. Klik "Start collection"
2. Collection ID: `users` → Create collection
3. Ulangi untuk: `articles`, `rewards`, `verificationRequests`

**Jangan perlu buat documents dulu**, nanti akan diisi dari code.

### Step 3: Setup Security Rules

Di Firestore → Rules tab, ganti dengan:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User hanya bisa akses data milik sendiri
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
      
      // Sub-collections
      match /depositHistory/{document=**} {
        allow read, write: if request.auth.uid == userId;
      }
      match /myRewards/{document=**} {
        allow read: if request.auth.uid == userId;
      }
    }
    
    // Semua user bisa baca articles & rewards
    match /articles/{document=**} {
      allow read: if true;
      allow write: if request.auth.token.isAdmin == true;
    }
    match /rewards/{document=**} {
      allow read: if true;
      allow write: if request.auth.token.isAdmin == true;
    }
    
    // Verification: user bisa create, admin bisa manage
    match /verificationRequests/{document=**} {
      allow create: if request.auth != null;
      allow read, update: if request.auth.token.isAdmin == true;
    }
  }
}
```

---

## 🛠️ Populate Database dari Flutter Code

Sudah ada helper class di: `lib/services/firebase_db_helper.dart`

Gunakan di `main.dart` atau setup screen:

```dart
import 'package:ecopoin_unila/services/firebase_db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Initialize sample data (jalankan sekali saja!)
  // final dbHelper = FirebaseDBHelper();
  // await dbHelper.initializeSampleDatabase();
  
  runApp(const MyApp());
}
```

**Caranya:**
1. Uncomment 2 baris di atas
2. Jalankan app sekali (`flutter run`)
3. Comment kembali agar tidak double insert
4. Check di Firebase Console apakah data sudah ada

---

## 📊 Melihat Data di Firebase Console

1. Firebase Console → Firestore Database
2. Klik collection name (misal: `articles`)
3. Lihat documents dan values-nya
4. Bisa edit/delete dari console langsung

---

## 🔍 Query Examples (dari Flutter Code)

### Get All Articles
```dart
final articles = await FirestoreService().getArticles();
```

### Get Articles by Category
```dart
final plasticArticles = FirestoreService()
    .getArticlesByCategory('plastik')
    .listen((snapshot) {
  print(snapshot.docs);
});
```

### Add Deposit
```dart
await FirestoreService().addDepositHistory(
  userId: 'user123',
  depositData: {
    'amount': 5.5,
    'category': 'plastik',
    'pointsEarned': 55,
    'status': 'pending',
    'photoUrl': 'https://...',
    'timestamp': FieldValue.serverTimestamp(),
  },
);
```

### Update User Points
```dart
await FirestoreService().updateUserPoints(
  userId: 'user123',
  points: 55, // tambah 55 poin
);
```

---

## ✅ Checklist Setup Database

- [ ] Firestore Database sudah buat di Firebase Console
- [ ] 4 Collections sudah dibuat: users, articles, rewards, verificationRequests
- [ ] Security Rules sudah update
- [ ] Jalankan `FirebaseDBHelper.initializeSampleDatabase()` untuk populate data
- [ ] Check di Firebase Console data sudah ada
- [ ] Test query dari Flutter

---

## 🚨 Common Issues & Solutions

### ❌ Error: Permission denied

**Penyebab:** Security rules belum diupdate  
**Solusi:** Paste security rules di Firestore → Rules → Publish

### ❌ Error: Collection not found

**Penyebab:** Collection belum dibuat di console  
**Solusi:** Buat collections dulu di Firebase Console

### ❌ Data tidak muncul

**Penyebab:** `initializeSampleDatabase()` belum dijalankan  
**Solusi:** Uncomment di main.dart dan jalankan app sekali

### ❌ Double data di database

**Penyebab:** `initializeSampleDatabase()` dijalankan berkali-kali  
**Solusi:** Hapus collections dan jalankan sekali lagi, atau delete manual di console

---

## 📚 Database Design Principles

**1. Denormalization**
```
Tidak simpan reference articles penuh, cukup ID + nama
Contoh: rewardName di myRewards bukan object rewards penuh
Alasan: Query lebih cepat, bandwidth lebih hemat
```

**2. Sub-collections**
```
Deposit history jadi sub-collection di user
Alasan: Data lebih organize, cascade delete otomatis
```

**3. Timestamps**
```
Selalu pakai FieldValue.serverTimestamp()
Tidak boleh DateTime.now() dari client
Alasan: Consistency, tidak terpengaruh clock user
```

**4. Security First**
```
Rules ketat: user hanya akses data milik sendiri
Articles/rewards: read semua, write admin only
Verification: create user, read/update admin
```

---

## 🎓 Workflow Example: User Deposit Sampah

```
1. User ambil foto sampah
2. User input: jenis (plastik) + berat (5 kg)
3. Create di verificationRequests dengan status "pending"
   → Admin notified ada request baru

4. Admin review foto dan approve
5. Update verificationRequests status → "approved"
6. System otomatis:
   - Add ke users//{userId}/depositHistory
   - Update users//{userId}/points += 50

7. User bisa lihat di Deposit History screen
8. Poin bertambah (bisa klaim reward)
```

---

## 📊 Data Relationships

```
USER → multiple DEPOSITs ← VERIFICATION REQUEST
   ↓
   └─→ multiple REWARDs (claimed)

ARTICLE (public read)
REWARD (public read)
```

---

**Setiap Koleksi & Field Sudah Explained!** ✅

Sekarang Anda bisa:
1. ✅ Understand database structure
2. ✅ Buat collections di Firebase Console
3. ✅ Setup security rules
4. ✅ Populate data dari Flutter
5. ✅ Query data untuk UI

Next: Integrasikan dengan UI screens!
