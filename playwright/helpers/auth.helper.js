// auth.helper.js
const { expect } = require('@playwright/test');

/**
 * Authentication helper for Playwright tests
 */
class AuthHelper {
  constructor(page) {
    this.page = page;
  }

  /**
   * Setup test authentication by injecting test session
   */
  async setupTestAuth() {
    console.log('🔧 [AUTH] Setting up test authentication');

    // Inject test environment variables into browser context
    await this.page.addInitScript(() => {
      window.FLUTTER_TEST_MODE = true;
      window.TEST_MODE = true;
      window.BYPASS_AUTH = true;
      window.TEST_ACCOUNT_EMAIL = 'test@fortune.com';
      window.TEST_USER_ID = 'test-user-id-12345';
    });

    console.log('🔧 [AUTH] Test authentication setup completed');
  }

  /**
   * Bypass login by directly setting authenticated state
   */
  async bypassLogin() {
    console.log('🔧 [AUTH] Bypassing login process');

    // Wait for app to load - increased timeout for Flutter Web
    await this.page.goto('/', { timeout: 45000 });
    await this.page.waitForLoadState('networkidle', { timeout: 45000 });

    // Wait a bit for Flutter to initialize
    await this.page.waitForTimeout(2000);

    // The test auth service in Flutter should automatically handle authentication
    // We just need to wait for the app to recognize the test session

    // Wait for authenticated state (either home screen or authenticated UI)
    try {
      // Wait for either home screen or main app content to appear - Flutter specific selectors
      await Promise.race([
        // Standard test IDs
        this.page.waitForSelector('[data-testid="home-screen"]', { timeout: 20000 }),
        this.page.waitForSelector('[data-testid="main-navigation"]', { timeout: 20000 }),
        // Flutter-specific selectors
        this.page.waitForSelector('flt-semantics[role="navigation"]', { timeout: 20000 }),
        this.page.waitForSelector('flt-semantics[aria-label*="navigation"]', { timeout: 20000 }),
        this.page.waitForSelector('[aria-label*="Home"]', { timeout: 20000 }),
        // Generic navigation
        this.page.waitForSelector('nav', { timeout: 20000 }),
        // Content-based verification - wait for authenticated content
        this.page.waitForFunction(() => {
          const text = document.body.innerText || '';
          return !text.includes('시작하기') &&
                 (text.includes('운세') || text.includes('Home') || text.includes('오늘') ||
                  text.includes('프로필') || text.includes('설정'));
        }, { timeout: 20000 })
      ]);

      console.log('🔧 [AUTH] Login bypass successful - authenticated state detected');
      return true;
    } catch (error) {
      console.log('🔧 [AUTH] Login bypass may have failed, continuing anyway:', error.message);
      return false;
    }
  }

  /**
   * Verify user is authenticated
   */
  async verifyAuthenticated() {
    console.log('🔧 [AUTH] Verifying authenticated state');

    // Check for authenticated UI elements with Flutter-specific selectors
    const isAuthenticated = await Promise.race([
      this.page.locator('[data-testid="home-screen"]').isVisible(),
      this.page.locator('[data-testid="main-navigation"]').isVisible(),
      this.page.locator('flt-semantics[role="navigation"]').isVisible(),
      this.page.locator('[aria-label*="Home"]').isVisible(),
      this.page.locator('nav').isVisible(),
      // Content-based authentication check
      this.page.evaluate(() => {
        const text = document.body.innerText || '';
        return !text.includes('시작하기') &&
               (text.includes('운세') || text.includes('오늘') ||
                text.includes('프로필') || text.includes('설정') ||
                text.includes('Home') || document.title.includes('Fortune'));
      })
    ]).catch(() => false);

    console.log(`🔧 [AUTH] Authentication state: ${isAuthenticated ? 'AUTHENTICATED' : 'NOT AUTHENTICATED'}`);
    return isAuthenticated;
  }

  /**
   * Complete authentication flow (used by other tests)
   */
  async authenticate() {
    await this.setupTestAuth();
    const success = await this.bypassLogin();
    const isAuth = await this.verifyAuthenticated();

    console.log(`🔧 [AUTH] Authentication flow completed: ${success && isAuth ? 'SUCCESS' : 'PARTIAL/FAILED'}`);
    return success && isAuth;
  }

  /**
   * Logout (clear test session)
   */
  async logout() {
    console.log('🔧 [AUTH] Logging out test user');

    // Clear browser storage
    await this.page.evaluate(() => {
      localStorage.clear();
      sessionStorage.clear();
    });

    // Clear cookies
    await this.page.context().clearCookies();

    console.log('🔧 [AUTH] Logout completed');
  }
}

module.exports = { AuthHelper };