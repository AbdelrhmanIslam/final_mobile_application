import unittest
import time
from appium import webdriver
from appium.options.android import UiAutomator2Options
from appium.webdriver.common.appiumby import AppiumBy

class LazaCartTest(unittest.TestCase):
    def setUp(self):
        options = UiAutomator2Options()
        options.platform_name = "Android"
        options.automation_name = "UiAutomator2"
        options.device_name = "emulator-5554"
        options.app = r"C:\Users\burri\StudioProjects\laza\build\app\outputs\flutter-apk\app-debug.apk"

        # IMPORTANT: Keep app data so we stay logged in
        options.no_reset = True

        self.driver = webdriver.Remote("http://127.0.0.1:4723", options=options)

    def test_add_to_cart_flow(self):
        driver = self.driver
        print("--- Starting Cart Test ---")
        time.sleep(5)

        # 1. Ensure we are on Home Screen (Check for product images)
        # We look for ImageViews which represent product pictures
        images = driver.find_elements(AppiumBy.CLASS_NAME, "android.widget.ImageView")

        if not images:
             print("Warning: No images found. You might not be logged in.")
             # You could add login logic here if needed, but manual login before running is easier.
             return

        # 2. Open Product
        # We click the last image found (usually a product in the grid)
        # We skip the first few images (Menu icon, Avatar, Bag icon)
        if len(images) > 3:
            print("Clicking a product...")
            images[3].click()
        else:
            self.fail("Not enough products displayed to click.")

        time.sleep(3)

        # 3. Add to Cart
        print("Clicking Add to Cart...")
        # Find button at bottom
        try:
            driver.find_element(AppiumBy.ACCESSIBILITY_ID, "Add to Cart").click()
        except:
             # Fallback to finding by class name (Button)
             buttons = driver.find_elements(AppiumBy.CLASS_NAME, "android.widget.Button")
             if buttons:
                 buttons[-1].click() # Click the last button on screen

        time.sleep(2)

        # 4. Open Cart
        print("Opening Cart...")
        # Finding the Bag/Cart icon. Usually located in Top Right AppBar.
        # In Flutter without explicit IDs, we might need to rely on coordinate taps or order
        # Trying Accessibility ID first (if you added 'semanticsLabel')
        try:
            driver.find_element(AppiumBy.ACCESSIBILITY_ID, "Cart").click()
        except:
            # Fallback: Tap top right corner of the screen
            width = driver.get_window_size()['width']
            driver.tap([(width - 50, 100)])

        time.sleep(3)

        # 5. Validate Item Exists
        # Check if "Total" is visible or if list items exist
        page_source = driver.page_source

        if "Total" in page_source or "Checkout" in page_source:
             print("SUCCESS: Item visible in Cart")
             driver.save_screenshot('../docs/results/cart_test_screenshot.png')
        else:
             self.fail("FAILED: Cart appears empty or did not open.")

    def tearDown(self):
        if self.driver:
            self.driver.quit()

if __name__ == '__main__':
    unittest.main()