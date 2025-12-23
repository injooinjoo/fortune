import asyncio
from playwright import async_api
from playwright.async_api import expect

async def run_test():
    pw = None
    browser = None
    context = None

    try:
        # Start a Playwright session in asynchronous mode
        pw = await async_api.async_playwright().start()

        # Launch a Chromium browser in headless mode with custom arguments
        browser = await pw.chromium.launch(
            headless=True,
            args=[
                "--window-size=1280,720",         # Set the browser window size
                "--disable-dev-shm-usage",        # Avoid using /dev/shm which can cause issues in containers
                "--ipc=host",                     # Use host-level IPC for better stability
                "--single-process"                # Run the browser in a single process mode
            ],
        )

        # Create a new browser context (like an incognito window)
        context = await browser.new_context()
        context.set_default_timeout(10000)  # Increased timeout

        # Open a new page in the browser context
        page = await context.new_page()

        # Navigate with test_mode=true - this will auto-login and redirect to /home
        await page.goto("http://localhost:3000/?test_mode=true", wait_until="commit", timeout=15000)

        # Wait for the auto-redirect to /home after test_mode login
        await page.wait_for_url("**/home**", timeout=10000)

        # Wait for DOM content to load
        try:
            await page.wait_for_load_state("domcontentloaded", timeout=5000)
        except async_api.Error:
            pass

        # Wait for any animations/rendering
        await page.wait_for_timeout(3000)

        # Verify we're on the home page
        current_url = page.url
        assert "/home" in current_url, f"Expected to be on home page, but URL is: {current_url}"

        # Take a screenshot for verification
        await page.screenshot(path="testsprite_tests/tmp/home_dashboard_screenshot.png")

        # Scroll to look for fortune cards
        await page.mouse.wheel(0, 300)
        await page.wait_for_timeout(1000)

        # Verify the page has loaded with some content (Flutter renders to canvas)
        page_content = await page.content()
        assert len(page_content) > 1000, "Page content seems empty"

        print("✅ Test passed: Home dashboard loaded successfully with test_mode")
        await asyncio.sleep(2)

    except Exception as e:
        print(f"❌ Test failed: {str(e)}")
        # Take screenshot on failure
        if page:
            await page.screenshot(path="testsprite_tests/tmp/home_dashboard_error.png")
        raise

    finally:
        if context:
            await context.close()
        if browser:
            await browser.close()
        if pw:
            await pw.stop()

asyncio.run(run_test())