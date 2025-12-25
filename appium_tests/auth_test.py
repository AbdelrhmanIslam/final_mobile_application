import unittest
import time
import random
import string
from appium import webdriver
from appium.options.android import UiAutomator2Options
from appium.webdriver.common.appiumby import AppiumBy

class LazaAuthTest(unittest.TestCase):
    def setUp(self):
        options = UiAutomator2Options()
        options.platform_name = "Android"
        options.automation_name = "UiAutomator2"
        options.device_name = "emulator-5554"
        # CHECK THIS PATH matches your computer exactly
        options.app = r"C:\Users\burri\StudioProjects\laza\build\app\outputs\flutter-apk\app-debug.apk"
        options.no_reset = False

        self.driver = webdriver.Remote("http://127.0.0.1:4723", options=options)

    def test_signup_flow(self):
        driver = self.driver
        print("--- Starting Auth Test ---")

        # 1. Wait for Splash -> Onboarding
        time.sleep(6)

        # 2. Click 'Skip'
        try:
            driver.find_element(AppiumBy.ACCESSIBILITY_ID, "Skip").click()
            print("Clicked Skip")
        except:
            # Tap Top Right corner as backup for Skip
            size = driver.get_window_size()
            driver.tap([(size['width'] - 50, 50)])
            print("Tapped Skip via coordinates")

        time.sleep(3)

        # 3. Click 'Create an Account'
        try:
            driver.find_element(AppiumBy.ACCESSIBILITY_ID, "Create an Account").click()
            print("Clicked Create Account")
        except:
            # Tap Bottom Button area
            size = driver.get_window_size()
            driver.tap([(size['width'] // 2, size['height'] - 50)])
            print("Tapped Create Account via coordinates")

        time.sleep(3)

        # 4. Fill Sign Up Form
        random_str = ''.join(random.choices(string.ascii_lowercase + string.digits, k=5))
        test_email = f"user_{random_str}@test.com"
        print(f"Filling form with: {test_email}")

        text_fields = driver.find_elements(AppiumBy.CLASS_NAME, "android.widget.EditText")

        if len(text_fields) >= 3:
            # Username
            text_fields[0].click()
            text_fields[0].send_keys("Test User")

            # Password
            text_fields[1].click()
            text_fields[1].send_keys("1234567")

            # Email
            text_fields[2].click()
            text_fields[2].send_keys(test_email)

            # --- FORCE CLOSE KEYBOARD ---
            print("Closing keyboard...")
            try:
                driver.hide_keyboard()
            except:
                pass

            # Extra back press just in case keyboard is stubborn
            driver.press_keycode(4) # Android Back Key
            time.sleep(1)
        else:
            self.fail("Could not find input fields")

        time.sleep(2)

        # 5. Click Sign Up Button (BRUTE FORCE COORDINATES)
        print("Attempting to click Sign Up (Bottom of screen)...")

        # Get screen dimensions
        size = driver.get_window_size()
        width = size['width']
        height = size['height']

        # Calculate the bottom center position where the button lives
        # The button is height 75, so we tap 40px up from the bottom
        x_pos = width // 2
        y_pos = height - 50

        print(f"Tapping at coordinates: {x_pos}, {y_pos}")
        driver.tap([(x_pos, y_pos)])

        # 6. Validate Navigation to Home
        print("Waiting 10 seconds for Firebase creation...")
        time.sleep(10)

        page_source = driver.page_source

        # Look for Home Screen indicators
        if "Hello" in page_source or "Choose Brand" in page_source or "Adidas" in page_source:
            print("SUCCESS: Navigated to Home Screen")
            driver.save_screenshot('../docs/results/auth_test_screenshot.png')
        else:
            # Take a failure screenshot to see where it got stuck
            driver.save_screenshot('auth_fail_debug.png')
            print("FAILED: Did not reach Home Screen. Saved debug screenshot.")
            self.fail("Auth Test Failed - Check auth_fail_debug.png")

    def tearDown(self):
        if self.driver:
            self.driver.quit()

if __name__ == '__main__':
    unittest.main()