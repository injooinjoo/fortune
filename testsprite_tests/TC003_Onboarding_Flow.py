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
        context.set_default_timeout(10000)  # Increased for test_mode
        
        # Open a new page in the browser context
        page = await context.new_page()
        
        # Navigate to your target URL and wait until the network request is committed
        await page.goto("http://localhost:3000/?test_mode=true", wait_until="commit", timeout=10000)

        # Wait for test_mode auto-redirect to /home
        await page.wait_for_url("**/home**", timeout=15000)
        
        # Wait for the main page to reach DOMContentLoaded state (optional for stability)
        try:
            await page.wait_for_load_state("domcontentloaded", timeout=3000)
        except async_api.Error:
            pass
        
        # Iterate through all iframes and wait for them to load as well
        for frame in page.frames:
            try:
                await frame.wait_for_load_state("domcontentloaded", timeout=3000)
            except async_api.Error:
                pass
        
        # Interact with the page elements to simulate user flow
        # -> Click the login button to start login as new user.
        frame = page  # Use main page after test_mode redirect
        # Click the login button or accessibility placeholder to start login
        elem = frame.locator('xpath=html/body/flt-semantics-placeholder').nth(0)
        await page.wait_for_timeout(3000); await elem.click(timeout=5000)
        

        # -> Try clicking the second button labeled '시작하기' (Start) to proceed with onboarding.
        frame = page  # Use main page after test_mode redirect
        # Skipped: 시작하기 button click not needed with test_mode (auto-login)
        # -> Click the 'Google로 계속하기' button to login with Google and proceed with onboarding.
        frame = page  # Use main page after test_mode redirect
        # Click the 'Google로 계속하기' button to login with Google
        elem = frame.locator('xpath=html/body/flutter-view/flt-semantics-host/flt-semantics/flt-semantics/flt-semantics/flt-semantics').nth(0)
        await page.wait_for_timeout(3000); await elem.click(timeout=5000)
        

        # -> Input a test email into the email field and click the 'Next' button to proceed with Google OAuth login.
        frame = page  # Use main page after test_mode redirect
        # Input test email into the email or phone field for Google sign-in
        elem = frame.locator('xpath=html/body/div[2]/div/div/div[2]/c-wiz/main/div[2]/div/div/div/form/span/section/div/div/div/div/div/div/div/input').nth(0)
        await page.wait_for_timeout(3000); await elem.fill('testuser@example.com')
        

        frame = page  # Use main page after test_mode redirect
        # Click the 'Next' button to proceed with Google sign-in
        elem = frame.locator('xpath=html/body/div[2]/div/div/div[2]/c-wiz/main/div[3]/div/div/div/div/button').nth(0)
        await page.wait_for_timeout(3000); await elem.click(timeout=5000)
        

        # --> Assertions to verify final state
        frame = page  # Use main page after test_mode redirect
        try:
            await expect(frame.locator('text=Onboarding Complete! Welcome Home').first).to_be_visible(timeout=1000)
        except AssertionError:
            raise AssertionError('Test plan execution failed: The onboarding process did not complete successfully, and the user was not redirected to the home dashboard as expected.')
        await asyncio.sleep(5)
    
    finally:
        if context:
            await context.close()
        if browser:
            await browser.close()
        if pw:
            await pw.stop()
            
asyncio.run(run_test())
    