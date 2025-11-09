# Firebase Setup Guide untuk Ecopoin Unila

## ✅ Yang Sudah Selesai
1. ✅ Dependencies Firebase sudah ditambahkan ke `pubspec.yaml`
2. ✅ Firebase sudah diinisialisasi di `main.dart`
3. ✅ Firebase Auth Service dibuat di `lib/services/firebase_auth_service.dart`
4. ✅ Firestore Service dibuat di `lib/services/firestore_service.dart`
5. ✅ File konfigurasi template sudah ada di `lib/firebase_options.dart`

## 📋 Langkah-Langkah Setup Firebase Console

### 1. Buat Project Firebase Baru
- Buka https://console.firebase.google.com/
- Klik "Create a project"
- Isi nama project: `Ecopoin Unila`
- Pilih region yang sesuai (misal: `asia-southeast1` untuk Indonesia)
- Klik "Create project"

### 2. Setup Android Firebase

**Langkah 2.1: Register Android App**
- Di Firebase Console, klik "Add app" → Pilih "Android"
- Android package name: `com.example.ecopoin_unila` (atau sesuaikan dengan AndroidManifest.xml)
- App nickname: `Ecopoin Unila Android`
- Klik "Register app"

**Langkah 2.2: Download google-services.json**
- Download file `google-services.json`
- Pindahkan ke folder: `android/app/`

**Langkah 2.3: Ambil Config dan Masukkan ke firebase_options.dart**
- Di Firebase Console, klik "Continue to console"
- Klik Project Settings (⚙️ di atas)
- Tab "General"
- Scroll ke bawah, cari bagian "Your apps"
- Klik Android app
- Copy config values (API Key, App ID, Project ID, etc.)
- Paste ke `lib/firebase_options.dart` di bagian `android`

### 3. Setup iOS Firebase (Optional - jika mau build iOS)

**Langkah 3.1: Register iOS App**
- Di Firebase Console, klik "Add app" → Pilih "iOS"
- iOS bundle ID: `com.ecopoin.unila`
- App nickname: `Ecopoin Unila iOS`
- Klik "Register app"

**Langkah 3.2: Download GoogleService-Info.plist**
- Download file
- Pindahkan ke folder: `ios/Runner/`

**Langkah 3.3: Ambil Config dan Masukkan ke firebase_options.dart**
- Copy config values dari Firebase Console
- Paste ke `lib/firebase_options.dart` di bagian `ios`

### 4. Enable Firebase Services

Di Firebase Console, klik "Build" di menu kiri:

**4.1: Enable Authentication**
- Klik "Authentication"
- Klik "Get started"
- Pilih "Email/Password" → klik "Enable"
- Klik "Save"

**4.2: Enable Firestore Database**
- Klik "Firestore Database"
- Klik "Create database"
- Pilih region: `asia-southeast1`
- Pilih "Start in test mode" (untuk development)
- Klik "Create"

**4.3: Enable Cloud Storage (Optional - untuk upload foto)**
- Klik "Storage"
- Klik "Get started"
- Pilih region: `asia-southeast1`
- Klik "Done"

### 5. Setup Firestore Security Rules (Important!)

Di Firestore Database → Rules tab, ganti dengan rules di bawah untuk development:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read/write untuk user yang sudah login
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
      
      match /depositHistory/{document=**} {
        allow read, write: if request.auth.uid == userId;
      }
      
      match /myRewards/{document=**} {
        allow read: if request.auth.uid == userId;
      }
    }
    
    // Allow semua orang baca articles
    match /articles/{document=**} {
      allow read: if true;
    }
    
    // Allow semua orang baca rewards
    match /rewards/{document=**} {
      allow read: if true;
    }
    
    // Admin only untuk verifikasi
    match /verificationRequests/{document=**} {
      allow create: if request.auth != null;
      allow read, write: if request.auth.token.isAdmin == true;
    }
  }
}
```

### 6. Setup Storage Security Rules (Jika menggunakan Cloud Storage)

Di Cloud Storage → Rules tab:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Allow user upload profile photo
    match /users/{userId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth.uid == userId;
    }
  }
}
```

## 🔧 Cara Menggunakan di Flutter Code

### 1. Gunakan Firebase Auth Service

```dart
import 'package:ecopoin_unila/services/firebase_auth_service.dart';

final authService = FirebaseAuthService();

// Register
try {
  await authService.registerWithEmailAndPassword(
    email: 'user@example.com',
    password: 'password123',
    displayName: 'John Doe',
  );
} catch (e) {
  print('Error: $e');
}

// Login
try {
  await authService.loginWithEmailAndPassword(
    email: 'user@example.com',
    password: 'password123',
  );
} catch (e) {
  print('Error: $e');
}

// Logout
await authService.logout();

// Get current user
User? user = authService.currentUser;

// Listen to auth state changes
authService.authStateChanges.listen((user) {
  if (user != null) {
    print('User logged in: ${user.email}');
  } else {
    print('User logged out');
  }
});
```

### 2. Gunakan Firestore Service

```dart
import 'package:ecopoin_unila/services/firestore_service.dart';

final firestoreService = FirestoreService();

// Tambah user data
await firestoreService.addOrUpdateUser(
  userId: 'user_id_here',
  userData: {
    'name': 'John Doe',
    'email': 'john@example.com',
    'points': 0,
    'createdAt': FieldValue.serverTimestamp(),
  },
);

// Ambil artikel
final articles = await firestoreService.getArticles();

// Stream artikel berdasarkan kategori
firestoreService.getArticlesByCategory('plastik').listen((snapshot) {
  final articles = snapshot.docs;
  print('Articles: $articles');
});

// Update poin user
await firestoreService.updateUserPoints(
  userId: 'user_id_here',
  points: 50,
);
```

## 📊 Struktur Database Firestore (Recommended)

```
users/
  ├── {userId}
  │   ├── name: string
  │   ├── email: string
  │   ├── points: number
  │   ├── profilePhoto: string (URL)
  │   ├── createdAt: timestamp
  │   ├── depositHistory/
  │   │   ├── {depositId}
  │   │   │   ├── amount: number
  │   │   │   ├── category: string
  │   │   │   ├── timestamp: timestamp
  │   ├── myRewards/
  │   │   ├── {rewardId}
  │   │   │   ├── rewardName: string
  │   │   │   ├── pointsUsed: number
  │   │   │   ├── claimedAt: timestamp

articles/
  ├── {articleId}
  │   ├── title: string
  │   ├── content: string
  │   ├── category: string (plastik, kertas, dll)
  │   ├── image: string (URL)
  │   ├── createdAt: timestamp

rewards/
  ├── {rewardId}
  │   ├── name: string
  │   ├── description: string
  │   ├── pointsRequired: number
  │   ├── image: string (URL)

verificationRequests/
  ├── {requestId}
  │   ├── userId: string
  │   ├── status: string (pending, approved, rejected)
  │   ├── documents: array
  │   ├── createdAt: timestamp
  │   ├── verifiedBy: string (admin uid)
  │   ├── verifiedAt: timestamp
```

## 🎯 Checklist Sebelum Deploy

- [ ] Firebase project sudah dibuat di Firebase Console
- [ ] Android app sudah terdaftar di Firebase
- [ ] `google-services.json` sudah ada di `android/app/`
- [ ] Config values sudah diisi di `lib/firebase_options.dart`
- [ ] Authentication sudah di-enable
- [ ] Firestore Database sudah di-enable
- [ ] Security Rules sudah diatur
- [ ] `flutter pub get` sudah dijalankan
- [ ] Aplikasi bisa di-build tanpa error

## 🐛 Troubleshooting

### Error: "Failed to initialize Firebase"
- Pastikan `google-services.json` ada di `android/app/`
- Pastikan config values di `firebase_options.dart` benar
- Run: `flutter clean` dan `flutter pub get`

### Error: "Permission denied" di Firestore
- Periksa Security Rules di Firestore Console
- Pastikan user sudah login sebelum access database

### Error: "Wrong package name"
- Pastikan package name di `AndroidManifest.xml` sesuai dengan di Firebase Console

## 📚 Dokumentasi Lebih Lanjut
- https://firebase.flutter.dev/
- https://cloud.google.com/firestore/docs
- https://firebase.google.com/docs/auth
