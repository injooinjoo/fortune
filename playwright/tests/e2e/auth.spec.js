// auth.spec.js
const { test, expect } = require('@playwright/test');
const { AuthHelper } = require('../../helpers/auth.helper');

test.describe('Authentication Flow', () => {
  let authHelper;

  test.beforeEach(async ({ page }) => {
    authHelper = new AuthHelper(page);
  });

  test('should bypass login in test mode', async ({ page }) => {
    console.log('🧪 [TEST] Starting auth bypass test');

    // Validate authentication helper can complete full bypass flow
    const authResult = await authHelper.authenticate();
    expect(authResult).toBeTruthy();

    // Verify we're not stuck on landing page
    const hasLandingButton = await page.locator('text=시작하기').isVisible().catch(() => false);
    expect(hasLandingButton).toBe(false);
    console.log('🔧 [TEST] Landing page not found - auth bypass is working');

    // Take screenshot for debugging
    await page.screenshot({
      path: 'test-results/auth-bypass-result.png',
      fullPage: true
    });

    console.log('🧪 [TEST] Auth bypass test completed');
  });

  test('should handle test authentication state', async ({ page }) => {
    console.log('🧪 [TEST] Starting authentication state test');

    // Authenticate using helper
    const authResult = await authHelper.authenticate();
    expect(authResult).toBeTruthy();

    // Verify authenticated elements are present
    const pageTitle = await page.title();
    console.log(`🔧 [TEST] Page title: ${pageTitle}`);
    expect(pageTitle).not.toBe('');

    const isAuthenticated = await authHelper.verifyAuthenticated();
    console.log(`🔧 [TEST] Authentication detected: ${isAuthenticated}`);
    expect(isAuthenticated).toBe(true);

    const bodyText = await page.textContent('body');
    expect(bodyText.length).toBeGreaterThan(50);

    // Take screenshot
    await page.screenshot({
      path: 'test-results/authenticated-state.png',
      fullPage: true
    });

    console.log('🧪 [TEST] Authentication state test completed');
  });

  test('should navigate app after authentication', async ({ page }) => {
    console.log('🧪 [TEST] Starting navigation test');

    // Authenticate first
    const authResult = await authHelper.authenticate();
    expect(authResult).toBeTruthy();

    // Wait for app to fully load
    await page.waitForTimeout(2000);

    // Take initial screenshot
    await page.screenshot({
      path: 'test-results/app-loaded.png',
      fullPage: true
    });

    // Try to find and interact with navigation elements
    const navElements = await page.locator('nav, [role="navigation"], .bottom-navigation').count();
    console.log(`🔧 [TEST] Found ${navElements} navigation elements`);

    if (navElements > 0) {
      // Try clicking first navigation element
      await page.locator('nav, [role="navigation"], .bottom-navigation').first().click();
      await page.waitForTimeout(1000);
    }

    // Look for any clickable elements that might be app features
    const buttons = await page.locator('button').count();
    const links = await page.locator('a').count();
    console.log(`🔧 [TEST] Found ${buttons} buttons and ${links} links`);

    // Take final screenshot
    await page.screenshot({
      path: 'test-results/navigation-test.png',
      fullPage: true
    });

    console.log('🧪 [TEST] Navigation test completed');
  });
});
