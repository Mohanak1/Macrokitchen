# MacroKitchen 🍽️

**Smart Nutrition & Meal Recommendation App**  
University of Jeddah · College of Computer Science · Software Engineering Dept.  
Team: Muhana Kembaity · Osama Al-zaidi · Khaled Al-jehani  
Supervisor: Dr. Sultan Al-harthi

---

## Overview

MacroKitchen is a Flutter mobile app that helps users make healthier food choices using personalized BMI-based meal recommendations, allergen filtering, and macro tracking — bridging restaurant meals with personal health data.

---

## Architecture

```
Clean Layered Architecture
├── Presentation Layer  — Screens, Widgets, Riverpod Providers
├── Application Layer   — Notifiers, Use Cases
├── Domain Layer        — Entities, Repository Interfaces, Business Logic
└── Data Layer          — Firebase Datasources, Models (DTOs), Repo Impls
```

**Key Tech Stack:**
| Concern | Choice |
|---|---|
| Framework | Flutter 3.x (Dart 3.x) |
| State Management | Riverpod 2.x |
| Routing | go_router |
| Backend | Firebase (Auth + Firestore + Storage) |
| Charts | fl_chart |
| Localization | flutter_localizations + ARB files |
| Local cache | SharedPreferences |

---

## Project Structure

```
lib/
├── main.dart                       # App entry point
├── firebase_options.dart           # Firebase config (auto-generated)
├── core/
│   ├── constants/                  # Colors, TextStyles, Dimensions
│   ├── errors/                     # Failures + Exceptions
│   ├── router/                     # go_router config
│   ├── theme/                      # AppTheme
│   ├── utils/                      # BMI + Calorie calculators, Recommendation engine
│   └── widgets/                    # Shared widgets: AppButton, MealCard, MacroRingChart...
├── l10n/                           # app_en.arb, app_ar.arb
└── features/
    ├── auth/                       # Login, Register, Forgot Password
    ├── bmi/                        # BMI Setup + BMI Page
    ├── home/                       # Home screen + Weekly Progress
    ├── meals/                      # Restaurant Menus + Meal Detail
    ├── home_meals/                 # Home Meal logging (CRUD)
    ├── history/                    # Meal history + daily totals
    ├── restaurant_dashboard/       # Restaurant login + dashboard + add meal
    └── settings/                   # Language toggle + account settings
```

---

## Getting Started

### Prerequisites

- Flutter SDK `>=3.0.0` installed: https://flutter.dev/docs/get-started/install
- Dart SDK `>=3.0.0` (bundled with Flutter)
- Firebase project created at https://console.firebase.google.com
- FlutterFire CLI installed

### 1. Clone and Install Dependencies

```bash
cd macrokitchen
flutter pub get
```

### 2. Firebase Setup (Required)

#### a. Create a Firebase Project
1. Go to https://console.firebase.google.com
2. Create a new project named `macrokitchen`
3. Enable **Authentication** → Email/Password provider
4. Enable **Cloud Firestore** → Start in production mode
5. Enable **Firebase Storage**

#### b. Generate firebase_options.dart

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Login to Firebase
firebase login

# Configure your project (generates firebase_options.dart)
flutterfire configure --project=YOUR_PROJECT_ID
```

This replaces the placeholder `lib/firebase_options.dart` with your real credentials.

#### c. Deploy Firestore Rules and Indexes

```bash
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
```

### 3. Firestore Initial Data

After deploying, seed a test restaurant account:

1. In Firebase Auth, create a user with email: `restaurant@test.com`, password: `Test123`
2. In Firestore → `users` collection, add a document with ID = that user's UID:
```json
{
  "uid": "<user_uid>",
  "name": "Test Restaurant",
  "email": "restaurant@test.com",
  "role": "restaurant",
  "language": "en",
  "createdAt": "<timestamp>"
}
```
3. In Firestore → `restaurants` collection, add:
```json
{
  "name": "McDonald's",
  "ownerId": "<user_uid>",
  "contactEmail": "restaurant@test.com",
  "isActive": true,
  "logoUrl": ""
}
```

### 4. Add Cairo Font (Required for Arabic support)

Download Cairo font from Google Fonts: https://fonts.google.com/specimen/Cairo

Place font files in:
```
assets/fonts/
├── Cairo-Regular.ttf
├── Cairo-Medium.ttf
├── Cairo-SemiBold.ttf
└── Cairo-Bold.ttf
```

Create placeholder asset folders:
```bash
mkdir -p assets/images assets/icons assets/lottie assets/fonts
```

### 5. Run the App

```bash
# Check connected devices
flutter devices

# Run on Android
flutter run

# Run on iOS (macOS required)
flutter run -d ios

# Run in release mode
flutter run --release
```

---

## User Roles

| Role | Access | Login Path |
|---|---|---|
| Regular User | Register/Login → BMI Setup → Browse & recommend meals | `/login` |
| Restaurant Owner | Login → Dashboard → Add/Edit meals + nutrition | `/restaurant-login` |

---

## Key Features

### BMI + Recommendation Engine
- **BMI formula:** `weight(kg) / height(m)²`
- **Calorie target:** Mifflin-St Jeor equation × activity multiplier ± goal adjustment
- **Recommendation scoring (0–100):**
  - Calorie proximity to single-meal target (40 pts)
  - Macro distribution matching user goal (40 pts)
  - Allergen/condition penalty (up to −20 pts)

### Health Concerns
- **Conditions:** Diabetes (flags high sugar >15g), High BP (flags high sodium >800mg)
- **Allergies:** Milk, Peanuts, Shellfish, Fish, Eggs, Tree Nut, Soy, Wheat, Sesame
- Conflicting meals display **red allergen banners** on meal detail screen

### Localization (EN/AR)
- Language toggle in Settings
- Full RTL layout when Arabic is selected
- All UI strings in `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb`

---

## Running Tests

```bash
# Unit tests
flutter test

# With coverage
flutter test --coverage
```

---

## Build for Release

```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS (macOS only)
flutter build ios --release
```

---

## Assumptions Made

1. No real delivery/ordering — app recommends and logs meals only
2. Restaurant accounts are pre-created by admin (no self-signup for restaurants)
3. Step counter on home screen is a static placeholder (not sensor-integrated in v1)
4. Meal ratings are stored data, not user-submitted
5. Weight history chart uses simulated data (real history would need a `weight_history` collection)
6. Single meal target = daily calorie target ÷ 3
7. Offline mode shows previously cached Riverpod data
8. Dark mode not implemented (UI is light-only per Figma)

---

## Environment

No `.env` file is needed. All secrets are handled by Firebase SDK via `firebase_options.dart`.  
**Never commit `firebase_options.dart` with real keys to a public repository.**

Add to `.gitignore`:
```
lib/firebase_options.dart
google-services.json
GoogleService-Info.plist
```

---

## License

Academic project — University of Jeddah, 2025
