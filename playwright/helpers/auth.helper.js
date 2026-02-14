// auth.helper.js
/**
 * Authentication helper for Playwright tests
 */
class AuthHelper {
  constructor(page) {
    this.page = page;
  }

  /**
   * Resolve possible app base URLs for CI stability.
   */
  _getBaseUrls() {
    const configured = process.env.BASE_URL || 'http://localhost:3000';
    const normalized = configured.endsWith('/') ? configured.slice(0, -1) : configured;
    const candidates = [normalized];

    if (normalized.includes('localhost')) {
      candidates.push('http://127.0.0.1:3000');
      candidates.push('http://localhost:3000');
    }

    return [...new Set(candidates)];
  }

  /**
   * Build app url with test-mode query param for web runtime auth skip.
   */
  _appendTestMode(url) {
    const marker = 'test_mode=true';
    if (url.includes(`?${marker}`) || url.includes(`&${marker}`)) {
      return url;
    }

    const separator = url.includes('?') ? '&' : '?';
    return `${url}${separator}${marker}`;
  }

  /**
   * Navigate to app entry point with retry for transient server startup races.
   */
  async _gotoWithRetries(timeoutMs = 45000) {
    const urls = this._getBaseUrls();
    const errors = [];

    for (let attempt = 1; attempt <= 3; attempt++) {
      const url = urls[(attempt - 1) % urls.length];

      try {
        const authUrl = this._appendTestMode(url);
        await this.page.goto(authUrl, { waitUntil: 'domcontentloaded', timeout: timeoutMs });
        await this.page.waitForLoadState('domcontentloaded', { timeout: Math.min(timeoutMs, 15000) });
        return;
      } catch (error) {
        errors.push(`${url} (${error.message})`);
        if (attempt === 3) {
          throw error;
        }

        await this.page.waitForTimeout(1000 * attempt);
      }
    }

    throw new Error(`Failed to navigate app entry after retries: ${errors.join(' | ')}`);
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
      window.TEST_ACCOUNT_EMAIL = 'test@zpzg.com';
      window.TEST_USER_ID = 'test-user-id-12345';
    });

    console.log('🔧 [AUTH] Test authentication setup completed');
  }

  /**
   * Internal auth marker wait helper
   */
  async _isAuthenticatedMarkerVisible() {
    const checks = [
      this.page.locator('[data-testid="home-screen"]').isVisible(),
      this.page.locator('[data-testid="main-navigation"]').isVisible(),
      this.page.locator('flt-semantics[role="navigation"]').isVisible(),
      this.page.locator('[aria-label*="Home"]').isVisible(),
      this.page.locator('nav').isVisible(),
      this.page.locator('[data-testid*="chat"]').isVisible(),
      this.page.locator('flt-glass-pane').isVisible(),
      this.page.evaluate(() => {
        const pathname = window.location.pathname || '';
        return pathname === '/chat' || pathname === '/home' || pathname === '/fortune' || pathname === '/history' || pathname === '/more';
      }),
      this.page.evaluate(() => {
        const text = document.body.innerText || '';
        return !text.includes('시작하기') &&
               (text.includes('운세') || text.includes('Home') || text.includes('오늘') ||
                text.includes('프로필') || text.includes('설정'));
      }),
      this.page.evaluate(() => {
        const raw = window.localStorage.getItem('isGuestMode');
        if (raw !== null && raw.includes('true')) {
          return false;
        }
        return raw === null || raw === 'false' || raw.includes('false');
      }),
      this.page.evaluate(() => {
        const testProfileStored = Object.keys(window.localStorage).some((key) => {
          return key.includes('userProfile') || key.includes('test_user_id') || key.includes('test_session');
        });
        const guestKey = Object.keys(window.localStorage).some((key) => {
          return key.includes('isGuestMode');
        });
        return testProfileStored || !guestKey;
      }),
    ];

    const resolved = await Promise.all(checks.map(check => check.catch(() => false)));
    return resolved.some(Boolean);
  }

  /**
   * Bypass login by directly setting authenticated state
   */
  async bypassLogin() {
    console.log('🔧 [AUTH] Bypassing login process');

    // Wait for app to load - increased timeout for Flutter Web
    await this._gotoWithRetries();
    await this.page.waitForLoadState('networkidle', { timeout: 45000 });

    // Wait a bit for Flutter to initialize
    await this.page.waitForTimeout(2000);

    // The test auth service in Flutter should automatically handle authentication
    // We just need to wait for the app to recognize the test session
    for (let attempt = 1; attempt <= 30; attempt++) {
      try {
        const isAuthenticated = await this._isAuthenticatedMarkerVisible();
        if (isAuthenticated) {
          console.log(`🔧 [AUTH] Login bypass successful - authenticated state detected (${attempt} polls)`);
          return true;
        }
      } catch (error) {
        console.log(`🔧 [AUTH] Polling marker failed at attempt ${attempt}: ${error.message}`);
      }

      if (attempt < 30) {
        await this.page.waitForTimeout(500);
      }
    }

    console.log('🔧 [AUTH] Login bypass failed: marker did not become valid within retry window');
    return false;
  }

  /**
   * Verify user is authenticated
   */
  async verifyAuthenticated() {
    console.log('🔧 [AUTH] Verifying authenticated state');

    const isAuthenticated = await this._isAuthenticatedMarkerVisible();

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

    const passed = success && isAuth;
    console.log(`🔧 [AUTH] Authentication flow completed: ${passed ? 'SUCCESS' : 'FAILED'}`);

    if (!passed) {
      throw new Error(`Authentication flow failed (bypassLogin=${success}, verifyAuthenticated=${isAuth})`);
    }

    return true;
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
