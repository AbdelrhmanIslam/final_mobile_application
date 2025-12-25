# Appium Test Cases

## Environment
*   **Tool:** Appium v2.x / v3.x
*   **Client:** Appium-Python-Client
*   **Platform:** Android (Emulator: Pixel 7, API 34)
*   **Automation Name:** UiAutomator2

---

## Test Case 1: Authentication Flow
**Description:** Verify that a user can successfully navigate from the Onboarding screen to the Home screen via the Login flow.

**Pre-conditions:**
1.  App is installed fresh (no previous session).
2.  Emulator is running.
3.  Appium Server is listening on port 4723.

**Steps:**
1.  Launch the App.
2.  Wait for Splash Screen (3 seconds).
3.  On Onboarding Screen, click "Skip".
4.  On Get Started Screen, click "Signin".
5.  Enter valid email and password in text fields.
6.  Click the "Login" button.
7.  Wait for navigation.

**Expected Result:**
*   The App navigates to the Home Screen.
*   The text "Hello" or "Choose Brand" is visible.

---

## Test Case 2: Add to Cart Flow
**Description:** Verify that a user can view a product and add it to the cart.

**Pre-conditions:**
1.  User is logged in (Authentication Test passed).
2.  User is on the Home Screen.

**Steps:**
1.  Locate the first product image in the grid.
2.  Click the product image.
3.  Verify Product Details screen opens (check for "Description" text).
4.  Click the "Add to Cart" button at the bottom.
5.  Wait for confirmation (SnackBar or UI update).

**Expected Result:**
*   A success message "Added to Cart" appears.
*   The system logs a successful interaction.