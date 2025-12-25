# Firebase Setup Guide

## 1. Project Creation
*   Created project "Laza Ecommerce" in Firebase Console.
*   Enabled **Authentication** (Email/Password, Google).
*   Enabled **Firestore Database** (Test Mode).

## 2. Android Configuration
*   Registered package `com.example.laza_ecommerce`.
*   Generated SHA-1 Key using `./gradlew signingReport` in Android Studio.
*   Added SHA-1 Fingerprint to Firebase Project Settings (Required for Google Sign-In).
*   Downloaded `google-services.json` and placed it in `android/app/`.

## 3. Dependencies
Added the following to `pubspec.yaml`:
*   `cupertino_icons`
*    `flutter_svg`
*    `google_fonts`     
*    `shared_preferences`
*   `firebase_core`
*   `firebase_auth`
*   `cloud_firestore`
*   `google_sign_in`