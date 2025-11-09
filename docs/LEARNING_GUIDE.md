# 🎓 Complete Learning Guide - Firebase Database Ecopoin Unila

## 📌 Sebelum Mulai

Anda sudah punya:
- ✅ Flutter project setup
- ✅ Firebase project dibuat
- ✅ Android app terdaftar
- ✅ google-services.json sudah di-place
- ✅ Credentials sudah diisi di firebase_options.dart
- ✅ flutter analyze: No issues found

**Sekarang:** Waktunya setup database!

---

## 📚 Baca File-File Ini Secara Urut

### 1. **DATABASE_SETUP_QUICK_START.md** (5-10 menit)
**Apa:** Step-by-step guide untuk setup database
**Baca jika:** Anda ingin cepat-cepat langsung praktik

**Yang dipelajari:**
- ✅ Buat 4 collections
- ✅ Setup security rules
- ✅ Populate sample data
- ✅ Verify di console

### 2. **DATABASE_STRUCTURE.md** (10-15 menit)
**Apa:** Penjelasan detail setiap koleksi & field
**Baca jika:** Anda ingin PAHAM struktur database secara mendalam

**Yang dipelajari:**
- ✅ Users collection (dan sub-collections)
- ✅ Articles collection
- ✅ Rewards collection
- ✅ Verification requests collection
- ✅ Mengapa setiap koleksi & field ada
- ✅ Workflow example (user deposit sampah)

### 3. **DATABASE_ARCHITECTURE_DIAGRAM.md** (5-10 menit)
**Apa:** Visual diagram & ASCII art tentang database
**Baca jika:** Anda visual learner, butuh gambar

**Yang dipelajari:**
- ✅ Overall architecture
- ✅ Collections structure tree
- ✅ Data flow diagrams
- ✅ Security rules visualization
- ✅ Data relationships

---

## 🚀 Langkah-Langkah Implementasi

### LANGKAH 1: Buat Collections di Firebase Console (2 menit)

```bash
Firebase Console → Firestore Database
Click "Start collection"

Create these 4 collections:
1. users
2. articles
3. rewards
4. verificationRequests

(Jangan perlu isi data dulu, cukup buat collection-nya)
```

### LANGKAH 2: Update Security Rules (3 menit)

```bash
Firestore → Rules tab
Copy-paste dari DATABASE_SETUP_QUICK_START.md
Klik "Publish"
```

### LANGKAH 3: Run Initialization Code (2 menit)

Edit `lib/main.dart`:

```dart
import 'package:ecopoin_unila/services/firebase_db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // UNCOMMENT untuk initialize sekali saja:
  final dbHelper = FirebaseDBHelper();
  await dbHelper.initializeSampleDatabase();
  
  runApp(const MyApp());
}
```

Jalankan: `flutter run`

### LANGKAH 4: Verify Data (2 menit)

```bash
Firebase Console → Firestore Database
Check collections:
- articles: should have 3 items ✓
- rewards: should have 4 items ✓
- users: empty (akan terisi saat register)
- verificationRequests: empty (akan terisi saat deposit)
```

### LANGKAH 5: Comment Kembali (1 menit)

```dart
// COMMENT kembali setelah done:
// final dbHelper = FirebaseDBHelper();
// await dbHelper.initializeSampleDatabase();
```

---

## 📊 Data Structure Summary

### Users Collection
```
Purpose: Menyimpan data user
Access: Private (hanya user sendiri)
Data: name, email, points, role, profilePhoto

Sub-collections:
- depositHistory/ → riwayat setiap deposit
- myRewards/ → rewards yang sudah di-klaim
```

**Mengapa?**
Setiap user perlu profile & riwayat aktivitasnya tersendiri. Sub-collections membuat query lebih cepat.

---

### Articles Collection
```
Purpose: Menyimpan artikel edukasi
Access: Public read, admin write only
Data: title, content, category, image, views, author

Categories: plastik, kertas, kaca, logam, organik
```

**Mengapa?**
User butuh edukasi tentang setiap jenis sampah. Kategori memudahkan filter.

---

### Rewards Collection
```
Purpose: Menyimpan hadiah yang bisa ditukar
Access: Public read, admin write only
Data: name, description, pointsRequired, category, quantity

Categories: voucher, discount, merchandise
```

**Mengapa?**
User bisa lihat apa aja reward yang tersedia. Admin manage stok & harga (dalam poin).

---

### Verification Requests Collection
```
Purpose: Menyimpan request verifikasi deposit
Access: Private (user create, admin manage)
Data: userId, depositAmount, depositCategory, photoUrl, status

Status: pending, approved, rejected
```

**Mengapa?**
Admin perlu verify setiap deposit real atau tidak. Mencegah fraud & dokumentasi.

---

## 🔄 Workflow: Dari User Sampai Database

### Workflow 1: User Deposit Sampah

```
1. User buka app
   ↓
2. Go to Deposit screen
   ↓
3. Take photo → Select category (plastik) → Input weight (5kg)
   ↓
4. Click "Submit Deposit"
   ↓
5. App creates document di:
   /verificationRequests/{ver001}
   status: "pending" ← ADMIN PERLU REVIEW!
   ↓
6. Admin dashboard notified ada pending request
   ↓
7. Admin review foto & approve
   ↓
8. System update:
   - verificationRequests status → "approved"
   - Create /users/{userId}/depositHistory/{dep001}
   - Update /users/{userId}/points += 50
   ↓
9. User app real-time update:
   - See new deposit di history ✓
   - Points updated ✓
```

### Workflow 2: User Klaim Reward

```
1. User buka app
   ↓
2. Go to Rewards screen
   ↓
3. See "Voucher Indomie" - requires 100 poin
   ↓
4. User punya 200 poin → Click "Claim"
   ↓
5. App creates document di:
   /users/{userId}/myRewards/{claimed001}
   ↓
6. App update:
   /users/{userId}/points -= 100
   ↓
7. User app real-time update:
   - See reward di "My Rewards" ✓
   - Points decreased ✓
```

---

## 🛡️ Security: Kenapa Rules Penting?

Tanpa rules: Semua orang bisa akses & edit semua data (BAHAYA!)

Dengan rules:
```javascript
match /users/{userId} {
  allow read, write: if request.auth.uid == userId;
  // Artinya: User hanya bisa akses data milik sendiri
}

match /articles/{document=**} {
  allow read: if true;
  allow write: if request.auth.token.isAdmin == true;
  // Artinya: Semua bisa baca, hanya admin bisa tulis
}
```

---

## 💡 Key Concepts

### 1. Collections & Documents
```
Collection (folder) → /users/
Document (file) → /users/user123

Document field:
{
  "name": "John",       ← field
  "email": "john@..."   ← field
}
```

### 2. Sub-collections
```
Normal: /users/{userId}/depositHistory

Why sub-collection?
- Data organized by user
- Query faster (no need to filter by userId)
- Auto-delete saat user dihapus
```

### 3. Real-time
```
App listening to /users/user123/points
Admin changes points
All clients see update instantly (no refresh!)

Ini POWER dari Firestore!
```

### 4. Timestamps
```
❌ WRONG: FieldValue.clientTimestamp() atau DateTime.now()
✅ RIGHT: FieldValue.serverTimestamp()

Kenapa? Tidak terpengaruh clock user (bisa salah)
```

---

## 🔍 Testing: Cek Apakah Setup Bekerja

### Test 1: Data ada di Firestore?

```bash
Firebase Console → Firestore Database
Klik collection "articles" → lihat 3 articles
Klik collection "rewards" → lihat 4 rewards

If yes: ✅ Database setup successful!
If no: ❌ Check console error messages
```

### Test 2: Query dari Flutter

```dart
// Test di main.dart atau test file
void testFirestoreQuery() async {
  final service = FirestoreService();
  
  // Get articles
  final articles = await service.getArticles();
  print('Articles: ${articles.length}'); // Should be 3
  
  // Get rewards
  final rewards = await service.getRewards();
  print('Rewards: ${rewards.length}'); // Should be 4
  
  // Get plastic articles
  service.getArticlesByCategory('plastik').listen((snapshot) {
    print('Plastic articles: ${snapshot.docs.length}'); // Should be 1
  });
}
```

---

## ❓ FAQ

### Q: Apa itu FieldValue.serverTimestamp()?
**A:** Timestamp dari Firebase server (bukan client). 
- Akurat (timezone independent)
- Konsisten untuk semua users
- Secure (user tidak bisa manipulate)

### Q: Kenapa sub-collection, bukan field?
**A:** 
- Field: Terbatas ukuran, lambat saat banyak data
- Sub-collection: Unlimited, scalable, organized

### Q: Apakah security rules bisa di-bypass?
**A:** Tidak! Rules dijalankan di server, user tidak bisa bypass.

### Q: Bagaimana if rules ketat tapi user butuh baca data lain?
**A:** Update rules di Firebase Console sesuai kebutuhan.

### Q: Berapa max documents per collection?
**A:** Unlimited! Firestore scalable.

---

## 📞 Debugging

### Error: "Permission denied"
- Check security rules di Firebase Console
- Ensure rules sudah di-publish
- Ensure user sudah login (request.auth != null)

### Error: "Collection not found"
- Check di Firebase Console apakah collection ada
- Spelling must exactly match

### Data tidak muncul
- Check initializeSampleDatabase() sudah dijalankan
- Check console untuk error messages
- Check Firebase Console apakah data ada

### Duplicate data
- Jangan run initializeSampleDatabase() berkali-kali
- If happened: Delete collection & run sekali lagi

---

## 🎯 Next After Database Setup

1. **Login/Register Integration**
   - User register → create user doc di Firestore
   - User login → load data dari Firestore

2. **Deposit Screen Integration**
   - User submit → create verificationRequests doc
   - Show pending status

3. **Admin Panel**
   - List pending verifications
   - Approve/reject

4. **Real-time Updates**
   - Listen to user points (real-time update)
   - Listen to deposit history (real-time update)

---

## 📚 File Reference

**Documentation:**
- `DATABASE_SETUP_QUICK_START.md` ← Start here!
- `DATABASE_STRUCTURE.md` ← For understanding
- `DATABASE_ARCHITECTURE_DIAGRAM.md` ← Visual learners
- `FIREBASE_SETUP_CHECKLIST.md` ← Reference

**Code:**
- `lib/services/firebase_auth_service.dart` ← Auth
- `lib/services/firestore_service.dart` ← Database
- `lib/services/firebase_db_helper.dart` ← Initialization
- `lib/firebase_options.dart` ← Configuration

---

## ✅ Checklist: Database Setup Done!

- [ ] Read DATABASE_SETUP_QUICK_START.md
- [ ] Read DATABASE_STRUCTURE.md
- [ ] Read DATABASE_ARCHITECTURE_DIAGRAM.md
- [ ] Created 4 collections di Firebase Console
- [ ] Updated Security Rules
- [ ] Uncommented initializeSampleDatabase() code
- [ ] Ran `flutter run`
- [ ] Verified data di Firebase Console (articles & rewards)
- [ ] Commented back initialization code
- [ ] Understand keseluruhan architecture

---

## 🚀 Sekarang Siap Untuk:

✅ User Registration (create user doc)
✅ User Login (read user doc)
✅ User Deposit (create verification request)
✅ Admin Approval (update status)
✅ Claim Rewards (deduct points)
✅ Real-time Updates (listen to collections)

**Backend siap! Tinggal integrate ke UI!** 🎉

---

**Created:** November 9, 2025
**Purpose:** Comprehensive learning guide
**Time to Read:** 30 minutes
**Time to Implement:** 10 minutes

Selamat belajar! 🎓
