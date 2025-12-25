# Laza E-commerce App

## 1. Project Overview
Laza is a mobile e-commerce MVP built with Flutter. It allows users to browse products, manage a cart, create a wishlist, and perform a mock checkout. The app features a modern UI based on the Laza UI Kit, supports Dark Mode, and uses Firebase for backend services.

**Platform:** Android
**SDK:** Flutter 3.x

## 2. Features
*   **Authentication:** Email/Password & Google Sign-In (Firebase Auth).
*   **Product Catalog:** Fetches real products from Platzi Fake Store API.
*   **Shopping Cart:** Add/Remove items, update quantities, persist data in Firestore.
*   **Wishlist:** Save favorite items to Firestore.
*   **Order History:** View past orders after checkout.
*   **Dark Mode:** Fully responsive Dark/Light theme toggle.
*   **Search & Filter:** Search products by name and filter by Brand (Adidas, Nike, etc.).

## 3. Installation & Setup
1.  **Prerequisites:** Flutter SDK installed, Android Studio, Java 17.
2.  **Clone/Open Project:** Open the folder in Android Studio.
3.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```
4.  **Firebase Setup:**
    *   Ensure `google-services.json` is present in `android/app/`.
    *   Ensure SHA-1 fingerprint is added to Firebase Console for Google Sign-In.
5.  **Run App:**
    ```bash
    flutter run
    ```

## 4. Architecture
The project follows a clean, modular architecture:
*   `lib/core/`: Services (Auth, Cart, API) and Constants (Colors, Theme).
*   `lib/models/`: Data models (Product).
*   `lib/ui/screens/`: Individual app screens (Home, Cart, Details, etc.).
*   `lib/ui/widgets/`: Reusable widgets (Drawer, Custom Buttons).

## 5. Testing
Appium scripts are located in the `/appium_tests` directory.
*   **Auth Test:** Verifies login flow.
*   **Cart Test:** Verifies adding an item to the cart.

## 6. Screenshots
(Screenshots are stored in the /docs folder)
