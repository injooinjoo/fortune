const { test, expect } = require('@playwright/test');
const { AuthHelper } = require('../helpers/auth.helper');

test.describe('Core Smoke Flow', () => {
  let authHelper;

  test.beforeEach(async ({ page }) => {
    authHelper = new AuthHelper(page);
  });

  test('loads the authenticated chat shell', async ({ page }) => {
    await authHelper.authenticate();
    await page.waitForTimeout(2000);

    const isAuthenticated = await authHelper.verifyAuthenticated();
    expect(isAuthenticated).toBe(true);

    const bodyText = (await page.textContent('body')) || '';
    expect(bodyText.length).toBeGreaterThan(100);

    const hasLandingCta = await page.getByText('시작하기').isVisible().catch(() => false);
    expect(hasLandingCta).toBe(false);

    await page.screenshot({
      path: 'test-results/smoke/chat-shell.png',
      fullPage: true,
    });
  });

  test('keeps the session after a reload', async ({ page }) => {
    await authHelper.authenticate();
    await page.reload({ waitUntil: 'domcontentloaded' });
    await page.waitForLoadState('networkidle', { timeout: 45000 });

    const isAuthenticated = await authHelper.verifyAuthenticated();
    expect(isAuthenticated).toBe(true);

    await page.screenshot({
      path: 'test-results/smoke/reload-session.png',
      fullPage: true,
    });
  });
});
