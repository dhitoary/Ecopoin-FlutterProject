# 📊 Database Architecture Diagram - Ecopoin Unila

## 🎯 Arsitektur Keseluruhan

```
┌─────────────────────────────────────────────────────────────┐
│                    FLUTTER MOBILE APP                       │
│                  (Android - Ecopoin Unila)                  │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────────┐  ┌──────────────────────┐        │
│  │   Auth Service       │  │  Firestore Service   │        │
│  │  - Register          │  │  - getArticles()     │        │
│  │  - Login             │  │  - getRewards()      │        │
│  │  - Logout            │  │  - addDeposit()      │        │
│  │  - Reset Password    │  │  - updatePoints()    │        │
│  └──────────────────────┘  └──────────────────────┘        │
│           ↓                          ↓                      │
│  ┌─────────────────────────────────────────────┐           │
│  │     Firebase Core (Initialization)          │           │
│  │     - DefaultFirebaseOptions                │           │
│  │     - Project ID: ecopoin-unila             │           │
│  └─────────────────────────────────────────────┘           │
│           ↓                                                 │
└─────────────────────────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────────────────────────┐
│            FIREBASE BACKEND (CLOUD)                         │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐      ┌──────────────┐                   │
│  │ Authentication │     │ Firestore DB │                   │
│  │ (Email/Pwd)    │     │  (NoSQL)     │                   │
│  └──────────────┘      └──────────────┘                   │
│                              ↓                             │
│                    ┌─────────────────────┐                │
│                    │ Collections:        │                │
│                    ├─────────────────────┤                │
│                    │ • users/            │                │
│                    │ • articles/         │                │
│                    │ • rewards/          │                │
│                    │ • verificationReq/  │                │
│                    └─────────────────────┘                │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 📁 Firestore Collections Structure

```
FIRESTORE DATABASE (ecopoin-unila)
│
├── 📚 users/ (Collection)
│   │
│   └── 👤 {userId} (Document)
│       ├── name: "John Doe"
│       ├── email: "john@ecopoin.com"
│       ├── points: 150
│       ├── role: "user"
│       ├── createdAt: Timestamp
│       │
│       ├── 📋 depositHistory/ (Sub-collection)
│       │   ├── {dep001}
│       │   │   ├── amount: 5.5
│       │   │   ├── category: "plastik"
│       │   │   ├── pointsEarned: 55
│       │   │   ├── status: "approved"
│       │   │   └── timestamp: Timestamp
│       │   │
│       │   └── {dep002}
│       │       └── ...
│       │
│       └── 🎁 myRewards/ (Sub-collection)
│           ├── {claimed001}
│           │   ├── rewardId: "rew123"
│           │   ├── rewardName: "Voucher Indomie"
│           │   ├── pointsUsed: 100
│           │   ├── claimedAt: Timestamp
│           │   └── status: "active"
│           │
│           └── {claimed002}
│               └── ...
│
│
├── 📰 articles/ (Collection)
│   │
│   ├── {art001} (Document)
│   │   ├── title: "Cara Daur Ulang Plastik"
│   │   ├── content: "Lorem ipsum..."
│   │   ├── category: "plastik"
│   │   ├── image: "https://..."
│   │   ├── author: "Admin"
│   │   ├── views: 125
│   │   └── createdAt: Timestamp
│   │
│   ├── {art002}
│   │   ├── title: "Pentingnya Daur Ulang Kertas"
│   │   ├── category: "kertas"
│   │   └── ...
│   │
│   └── {art003}
│       ├── title: "Kaca: Bahan Daur Ulang Selamanya"
│       ├── category: "kaca"
│       └── ...
│
│
├── 🎁 rewards/ (Collection)
│   │
│   ├── {rew001} (Document)
│   │   ├── name: "Voucher Indomie Rp10.000"
│   │   ├── description: "Voucher makanan..."
│   │   ├── pointsRequired: 100
│   │   ├── category: "voucher"
│   │   ├── image: "https://..."
│   │   ├── quantity: 50
│   │   └── createdAt: Timestamp
│   │
│   ├── {rew002}
│   │   ├── name: "Diskon Belanja 20%"
│   │   ├── pointsRequired: 150
│   │   └── ...
│   │
│   ├── {rew003}
│   │   ├── name: "Reusable Tumbler"
│   │   ├── pointsRequired: 200
│   │   └── ...
│   │
│   └── {rew004}
│       ├── name: "Eco-Friendly Bag"
│       ├── pointsRequired: 250
│       └── ...
│
│
└── ✅ verificationRequests/ (Collection)
    │
    ├── {ver001} (Document)
    │   ├── userId: "user123"
    │   ├── depositAmount: 5.5
    │   ├── depositCategory: "plastik"
    │   ├── photoUrl: "https://..."
    │   ├── status: "pending"  ← Admin akan review ini
    │   ├── createdAt: Timestamp
    │   ├── verifiedAt: null   ← Diisi saat approve
    │   ├── verifiedBy: null   ← Admin uid
    │   └── rejectionReason: ""
    │
    ├── {ver002}
    │   ├── status: "approved"  ← Sudah di-approve
    │   └── ...
    │
    └── {ver003}
        ├── status: "rejected"   ← Ditolak
        └── ...
```

---

## 🔄 Data Flow - User Deposit Sampah

```
┌─────────────────────────────────────────────────────────────┐
│ STEP 1: USER SUBMITS DEPOSIT                                │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  User App:                                                   │
│  1. Upload photo sampah                                      │
│  2. Select kategori: "plastik"                              │
│  3. Input berat: "5.5 kg"                                   │
│  4. Submit                                                   │
│                           ↓                                 │
│  Create doc di:                                             │
│  /verificationRequests/{ver001}                             │
│  ├── userId: "user123"                                      │
│  ├── depositAmount: 5.5                                     │
│  ├── depositCategory: "plastik"                             │
│  ├── photoUrl: "<URL from storage>"                         │
│  ├── status: "pending" ← WAITING ADMIN!                    │
│  └── createdAt: 2025-11-09                                  │
│                                                              │
└─────────────────────────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────────────────────────┐
│ STEP 2: ADMIN REVIEWS & APPROVES                            │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Admin Dashboard:                                            │
│  1. See pending requests                                     │
│  2. Review photo                                             │
│  3. Approve ✓                                               │
│                           ↓                                 │
│  Update verification doc:                                   │
│  /verificationRequests/{ver001}                             │
│  ├── status: "approved" ← CHANGED                           │
│  ├── verifiedAt: 2025-11-09                                │
│  ├── verifiedBy: "admin123"                                │
│  └── rejectionReason: ""                                   │
│                           ↓                                 │
│  Firebase Trigger (rules) atau App Logic:                  │
│  1. Add ke /users/user123/depositHistory/{dep001}          │
│     ├── amount: 5.5                                         │
│     ├── category: "plastik"                                 │
│     ├── pointsEarned: 55  (5.5 × 10)                       │
│     ├── status: "approved"                                  │
│     └── timestamp: 2025-11-09                               │
│                                                              │
│  2. Update /users/user123                                   │
│     points: 150 + 55 = 205 ← POINTS ADDED!                │
│                                                              │
└─────────────────────────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────────────────────────┐
│ STEP 3: USER SEES UPDATED DATA                              │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  User App (Real-time Update):                               │
│  1. Deposit History: new deposit visible ✓                  │
│  2. Points: 205 points (dari 150) ← UPDATED!              │
│  3. User bisa sekarang klaim reward!                        │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎁 Data Flow - User Klaim Reward

```
┌─────────────────────────────────────────────────────────────┐
│ STEP 1: USER SELECTS REWARD                                 │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  User sees in app:                                           │
│  • Voucher Indomie - Requires 100 points ← Can buy!       │
│  • User points: 205 ← Enough!                              │
│                                                              │
│  Click "Claim Reward"                                        │
│                           ↓                                 │
│  Create doc di:                                             │
│  /users/user123/myRewards/{claimed001}                      │
│  ├── rewardId: "rew001"                                     │
│  ├── rewardName: "Voucher Indomie Rp10.000"                │
│  ├── pointsUsed: 100 ← WILL BE DEDUCTED                   │
│  ├── claimedAt: 2025-11-09                                │
│  ├── expiryDate: 2025-12-09                                │
│  └── status: "active"                                       │
│                           ↓                                 │
│  Update /users/user123:                                     │
│  points: 205 - 100 = 105 ← POINTS DEDUCTED!               │
│                                                              │
└─────────────────────────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────────────────────────┐
│ STEP 2: USER SEES UPDATED DATA                              │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  User App (Real-time Update):                               │
│  1. My Rewards: new reward visible ✓                        │
│  2. Points: 105 (dari 205) ← UPDATED!                      │
│  3. Can see reward expiry date                              │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔐 Security Rules Visualization

```
┌─────────────────────────────────────────────────────────────┐
│                  FIRESTORE SECURITY RULES                   │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  /users/{userId}                                             │
│  ├── READ:  ✅ Only owner (user123 read own data)          │
│  ├── WRITE: ✅ Only owner (user123 write own data)         │
│  └── PUBLIC: ❌ Other users can't access                   │
│                                                              │
│  /users/{userId}/depositHistory/**                          │
│  ├── READ:  ✅ Only owner                                  │
│  ├── WRITE: ✅ Only owner                                  │
│  └── PUBLIC: ❌ Other users can't access                   │
│                                                              │
│  /users/{userId}/myRewards/**                               │
│  ├── READ:  ✅ Only owner                                  │
│  ├── WRITE: ✅ Only owner                                  │
│  └── PUBLIC: ❌ Other users can't access                   │
│                                                              │
│  /articles/**                                                │
│  ├── READ:  ✅ Everyone (public)                           │
│  ├── WRITE: ✅ Only admin                                  │
│  └── PUBLIC: ✅ All users read                             │
│                                                              │
│  /rewards/**                                                 │
│  ├── READ:  ✅ Everyone (public)                           │
│  ├── WRITE: ✅ Only admin                                  │
│  └── PUBLIC: ✅ All users read                             │
│                                                              │
│  /verificationRequests/**                                    │
│  ├── CREATE: ✅ Logged in users                            │
│  ├── READ:   ✅ Only admin (to review)                     │
│  ├── UPDATE: ✅ Only admin (to approve/reject)             │
│  └── PUBLIC: ❌ Users only see own requests (not implemented) │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 💾 Data Relationships

```
┌─────────────────────────────────────────────────────────────┐
│                   DATA RELATIONSHIPS                         │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│          users/{userId}                                      │
│                 │                                            │
│        ┌────────┼────────┐                                  │
│        │                 │                                  │
│        ▼                 ▼                                  │
│   depositHistory/    myRewards/                             │
│   (own deposits)     (claimed rewards)                      │
│                                                              │
│                                                              │
│   verificationRequests/{ver} ──→ references ──→ userId      │
│                                                              │
│                                                              │
│   articles/{art}  ← (read-only, public)                    │
│                                                              │
│   rewards/{rew}   ← (read-only, public)                    │
│                                                              │
│                                                              │
│                  FLOW:                                       │
│   USER → deposits → VERIFICATION → (admin approve)          │
│                                  ↓                          │
│                        depositHistory + points              │
│                                  ↓                          │
│                      (user can claim reward)                │
│                                  ↓                          │
│                      points deducted, reward added          │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 📊 Database Query Examples

```
QUERY 1: Get user data
Location: /users/user123
Result: Name, email, total points, role

QUERY 2: Get user deposit history
Location: /users/user123/depositHistory
Filter: timestamp DESC (newest first)
Result: All deposits user ever made

QUERY 3: Get articles by category
Location: /articles
Filter: category == "plastik"
Result: All plastic-related articles

QUERY 4: Get pending verification requests
Location: /verificationRequests
Filter: status == "pending"
Result: Requests waiting admin approval

QUERY 5: Get user claimed rewards
Location: /users/user123/myRewards
Filter: status != "expired"
Result: Active rewards user has
```

---

## 🎓 Key Concepts

### 1. **Collections** vs **Documents**
```
Collection = Folder (contains many documents)
Document = File (contains data fields)

/users/            ← Collection
/users/user123     ← Document
/users/user123/depositHistory/  ← Sub-collection
```

### 2. **Real-time Updates**
```
App listening to /users/user123/points
Admin updates points
All clients see update instantly (no refresh needed!)
```

### 3. **Security Rules**
```
Every read/write checked against rules
if request.auth.uid == userId:
    ALLOW
else:
    DENY
```

### 4. **Sub-collections vs Fields**
```
Sub-collection: Use when many related documents
Example: 1000 deposits per user → use sub-collection

Field: Use for simple data
Example: user name → use field
```

---

**Understanding this diagram = Understanding Ecopoin Database!** ✅
