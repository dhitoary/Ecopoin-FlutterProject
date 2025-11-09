# ⚡ QUICK REFERENCE CARD - Firebase Ecopoin Unila

**Print this or bookmark!**

---

## 🎯 3 LANGKAH SETUP DATABASE (10 MINUTES)

### LANGKAH 1: Create Collections (Firebase Console)
```
Firestore Database → Start collection
✓ users
✓ articles
✓ rewards
✓ verificationRequests
```

### LANGKAH 2: Update Security Rules
```
Firestore → Rules → Copy dari DATABASE_SETUP_QUICK_START.md → Publish
```

### LANGKAH 3: Initialize Data
```dart
// lib/main.dart - uncomment:
final dbHelper = FirebaseDBHelper();
await dbHelper.initializeSampleDatabase();
```
```bash
flutter run
# Wait: ✅ Database initialized successfully!
```

---

## 📋 WHAT YOU HAVE

| Component | Status | Details |
|-----------|--------|---------|
| Firebase Project | ✅ | ecopoin-unila |
| Android App | ✅ | com.ecopoin.unila |
| Credentials | ✅ | In firebase_options.dart |
| Auth Service | ✅ | firebase_auth_service.dart |
| DB Service | ✅ | firestore_service.dart |
| DB Helper | ✅ | firebase_db_helper.dart |
| Documentation | ✅ | 11 files |

---

## 📊 COLLECTIONS STRUCTURE

```
/users/{userId}
├── name, email, points, role
├── depositHistory/ {dep}
│   └── amount, category, points, status, photo
└── myRewards/ {reward}
    └── rewardId, pointsUsed, claimedAt, status

/articles/{article}
├── title, content, category, image, views

/rewards/{reward}
├── name, pointsRequired, category, quantity

/verificationRequests/{req}
├── userId, amount, status, photo
```

---

## 🔐 SECURITY MODEL

```
User data:           Private (uid == userId)
Articles/Rewards:    Public read, Admin write
Verifications:       User create, Admin approve
```

---

## 💻 CODE EXAMPLES

### Register
```dart
final auth = FirebaseAuthService();
await auth.registerWithEmailAndPassword(
  email: 'user@example.com',
  password: 'pass123',
  displayName: 'John',
);
```

### Get Articles
```dart
final db = FirestoreService();
final articles = await db.getArticles();
```

### Add Deposit
```dart
await db.addDepositHistory(
  userId: 'uid',
  depositData: {
    'amount': 5.5,
    'category': 'plastik',
    'pointsEarned': 55,
    'status': 'pending',
  },
);
```

---

## 📚 READ FIRST

1. **DATABASE_SETUP_QUICK_START.md** ← 5-10 min
2. **DATABASE_STRUCTURE.md** ← 10-15 min

---

## ✅ VERIFY

```
Firebase Console → Firestore Database
✓ articles: 3 items
✓ rewards: 4 items
✓ users, verificationRequests: empty
```

---

## 🚨 COMMON MISTAKES

❌ Run initializeSampleDatabase() twice  
❌ Forget to publish security rules  
❌ Use client timestamp  
❌ Share security keys  

---

## 📞 STUCK?

→ Read `LEARNING_GUIDE.md` FAQ section  
→ Read `DOCUMENTATION_INDEX.md` for navigation

---

**Status:** ✅ 95% Ready  
**Next:** UI Integration  
**Time to Setup:** 10 min

GO! 🚀
