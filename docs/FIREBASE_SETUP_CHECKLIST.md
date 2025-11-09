# ✅ Firebase Setup Checklist - Android Only

## 🎯 Tujuan
Menghubungkan Ecopoin Unila Flutter App dengan Firebase Backend sebagai BaaS (Backend as a Service) menggunakan Spark Plan (Free).

## 📋 Phase 1: Firebase Console Setup

### Step 1 - Buat Firebase Project
- [ ] Buka https://console.firebase.google.com/
- [ ] Klik "Create a project"
- [ ] Isi nama project: `ecopoin-unila`
- [ ] Pilih region: `asia-southeast1` (Indonesia)
- [ ] Tunggu project selesai dibuat (~1-2 menit)

### Step 2 - Register Android App di Firebase
- [ ] Di Firebase Console, klik "Add app" → pilih Android
- [ ] **Android package name**: `com.ecopoin.unila`
- [ ] **App nickname**: `Ecopoin Unila`
- [ ] Klik "Register app"
- [ ] **Download** file `google-services.json`
- [ ] Pindahkan ke folder: `android/app/` (di proyek lokal Anda)

### Step 3 - Copy Credentials
Buka file `google-services.json` yang sudah di-download, cari informasi:
- [ ] `apiKey` → copy ke `firebase_options.dart`
- [ ] `appId` → copy ke `firebase_options.dart`
- [ ] `messagingSenderId` → copy ke `firebase_options.dart`
- [ ] `projectId` → copy ke `firebase_options.dart`
- [ ] `storageBucket` → copy ke `firebase_options.dart`

**Lokasi file untuk update:** `lib/firebase_options.dart`

Contoh setelah di-isi:
```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'AIzaSyD...',           // dari google-services.json
  appId: '1:123456:android:abc...', // dari google-services.json
  messagingSenderId: '123456789',   // dari google-services.json
  projectId: 'ecopoin-unila',       // project ID
  storageBucket: 'ecopoin-unila.appspot.com', // storage bucket
);
```

### Step 4 - Enable Firebase Services

#### Authentication (Email/Password)
- [ ] Di Firebase Console, klik **"Authentication"** (di menu Build)
- [ ] Klik **"Get started"**
- [ ] Pilih provider: **"Email/Password"**
- [ ] Toggle **"Enable"**
- [ ] Klik **"Save"**

#### Firestore Database
- [ ] Di Firebase Console, klik **"Firestore Database"** (di menu Build)
- [ ] Klik **"Create database"**
- [ ] Pilih region: `asia-southeast1`
- [ ] Pilih mode: **"Start in test mode"** (untuk development)
- [ ] Klik **"Create"**
- [ ] Buka tab **"Rules"**, ganti dengan security rules (lihat di bawah)

#### Cloud Storage (Optional - untuk upload foto)
- [ ] Di Firebase Console, klik **"Storage"** (di menu Build)
- [ ] Klik **"Get started"**
- [ ] Pilih region: `asia-southeast1`
- [ ] Klik **"Done"**

### Step 5 - Setup Security Rules

#### Firestore Security Rules
Di Firestore Database → Tab "Rules", ganti dengan:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User data - hanya bisa akses data sendiri
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
      
      // Sub-collection: Deposit History
      match /depositHistory/{document=**} {
        allow read, write: if request.auth.uid == userId;
      }
      
      // Sub-collection: My Rewards
      match /myRewards/{document=**} {
        allow read: if request.auth.uid == userId;
      }
    }
    
    // Articles - semua orang bisa baca
    match /articles/{document=**} {
      allow read: if true;
      allow write: if request.auth.token.isAdmin == true; // hanya admin bisa tulis
    }
    
    // Rewards - semua orang bisa baca
    match /rewards/{document=**} {
      allow read: if true;
      allow write: if request.auth.token.isAdmin == true; // hanya admin bisa tulis
    }
    
    // Verification Requests - admin only
    match /verificationRequests/{document=**} {
      allow create: if request.auth != null; // user bisa create request
      allow read, write: if request.auth.token.isAdmin == true; // admin bisa manage
    }
  }
}
```

Klik **"Publish"**

#### Cloud Storage Rules (jika menggunakan storage)
Di Cloud Storage → Tab "Rules", ganti dengan:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // User profile photos
    match /users/{userId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth.uid == userId;
    }
  }
}
```

Klik **"Publish"**

---

## 📋 Phase 2: Update Credentials di Flutter Project

### Step 6 - Update firebase_options.dart

File: `lib/firebase_options.dart`

Isi placeholder dengan credentials dari Firebase Console:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'ANDROID_API_KEY_PLACEHOLDER',        // ganti dengan API key
  appId: 'ANDROID_APP_ID_PLACEHOLDER',          // ganti dengan app ID
  messagingSenderId: 'MESSAGING_SENDER_ID_PLACEHOLDER', // ganti dengan sender ID
  projectId: 'PROJECT_ID_PLACEHOLDER',          // ganti dengan project ID
  storageBucket: 'STORAGE_BUCKET_PLACEHOLDER',  // ganti dengan storage bucket
);
```

- [ ] Update file `lib/firebase_options.dart` dengan credentials
- [ ] Run: `flutter pub get`
- [ ] Run: `flutter clean` (optional, untuk clear cache)

---

## 🧪 Phase 3: Testing

### Step 7 - Test Firebase Connection

Di terminal, jalankan:
```bash
cd c:\Users\lenovo\Documents\Ecopoin-FlutterProject\ecopoin_unila
flutter run
```

- [ ] Aplikasi berjalan tanpa error
- [ ] Firebase initialization berhasil (check console untuk warning)
- [ ] Build berhasil tanpa error

---

## 📊 Struktur Database Firestore (untuk referensi)

```
Firestore Database Structure:
├── users/
│   └── {userId}
│       ├── name: string
│       ├── email: string
│       ├── points: number
│       ├── profilePhoto: string (URL)
│       ├── createdAt: timestamp
│       ├── depositHistory/ (sub-collection)
│       │   └── {depositId}
│       │       ├── amount: number
│       │       ├── category: string
│       │       ├── timestamp: timestamp
│       └── myRewards/ (sub-collection)
│           └── {rewardId}
│               ├── rewardName: string
│               ├── pointsUsed: number
│               ├── claimedAt: timestamp
├── articles/
│   └── {articleId}
│       ├── title: string
│       ├── content: string
│       ├── category: string
│       ├── image: string (URL)
│       ├── createdAt: timestamp
├── rewards/
│   └── {rewardId}
│       ├── name: string
│       ├── description: string
│       ├── pointsRequired: number
│       ├── image: string (URL)
└── verificationRequests/
    └── {requestId}
        ├── userId: string
        ├── status: string (pending/approved/rejected)
        ├── documents: array
        ├── createdAt: timestamp
```

---

## 🛠️ File yang Sudah Disiapkan

✅ **Services (Backend Logic)**
- `lib/services/firebase_auth_service.dart` - Authentication service
- `lib/services/firestore_service.dart` - Firestore database service

✅ **Configuration**
- `lib/firebase_options.dart` - Firebase credentials (perlu diisi)
- `lib/main.dart` - Firebase initialization

✅ **Dependencies**
- `pubspec.yaml` - Firebase packages sudah ditambahkan

---

## ❓ FAQ / Troubleshooting

**Q: Error "Failed to initialize Firebase"?**
- Pastikan `google-services.json` ada di `android/app/`
- Pastikan credentials di `firebase_options.dart` benar
- Run: `flutter clean && flutter pub get`

**Q: Error "Permission denied" di Firestore?**
- Periksa Security Rules di Firestore Console
- Pastikan user sudah login sebelum akses database

**Q: Bagaimana cara test login/register?**
- Gunakan Firebase Auth Service yang sudah disiapkan
- Contoh code ada di `lib/services/firebase_auth_service.dart`

---

## 📚 Next Steps

Setelah setup selesai:
1. Integrasikan Firebase Auth ke login/register screen
2. Test login dan data penyimpanan ke Firestore
3. Implementasi fitur deposit dan reward
4. Setup admin panel untuk manage articles & rewards
5. Implementasi verification system untuk admin approval

---

## 📞 Kontribusi

Jika ada error atau pertanyaan, hubungi team development.

Last Updated: November 9, 2025
