// @ts-check
/**
 * Regression suite for the Ondo public web hub (the static site published from `public/`).
 *
 * Runs against a configurable target:
 *   BASE_URL=https://fortune-mocha.vercel.app PLAYWRIGHT_SKIP_WEBSERVER=true npx playwright test ...
 *
 * With no BASE_URL the suite boots `scripts/validate-ondo-web-readiness.mjs --serve`, which
 * replays `vercel.json` rewrite/header/404 semantics locally so routing and security headers
 * are asserted against the committed configuration rather than a deployment.
 */

const { spawn } = require('node:child_process');
const path = require('node:path');

const { test, expect } = require('@playwright/test');

const REPO_ROOT = path.resolve(__dirname, '..', '..');
const SERVER_SCRIPT = path.join(REPO_ROOT, 'scripts', 'validate-ondo-web-readiness.mjs');

const PUBLIC_PAGE_ROUTES = ['/', '/privacy', '/terms', '/support', '/delete-account'];
const NATIVE_LANDING_ROUTES = [
  '/auth/callback',
  '/chat',
  '/onboarding',
  '/premium',
  '/account-deletion',
];
const ALL_PAGE_ROUTES = [...PUBLIC_PAGE_ROUTES, ...NATIVE_LANDING_ROUTES];
const DEAD_MAIL_DOMAIN = 'zpzg.co.kr';
const SUPPORT_EMAIL = 'injooinjoo@gmail.com';
const MISSING_ROUTE = '/this-route-should-never-exist-9f2a';

const DESKTOP_VIEWPORT = { width: 1440, height: 1000 };
const MOBILE_VIEWPORT = { width: 390, height: 844 };

// Escape hatch for machines where Playwright's bundled browser download is unavailable
// (for example a locked-down workstation). `PLAYWRIGHT_CHANNEL=chrome` reuses an installed
// Chrome/Edge instead. CI keeps the bundled browser by leaving this unset.
if (process.env.PLAYWRIGHT_CHANNEL) {
  test.use({ channel: process.env.PLAYWRIGHT_CHANNEL });
}

/** @type {{ baseUrl: string, stop: () => Promise<void> }} */
let target;

function startLocalServer() {
  return new Promise((resolve, reject) => {
    const child = spawn(process.execPath, [SERVER_SCRIPT, '--serve'], {
      cwd: REPO_ROOT,
      stdio: ['ignore', 'pipe', 'pipe'],
    });

    let stderr = '';
    const timer = setTimeout(() => {
      child.kill('SIGKILL');
      reject(new Error(`local web server did not start in time. stderr: ${stderr}`));
    }, 20000);

    child.stderr.on('data', (chunk) => {
      stderr += String(chunk);
    });

    child.stdout.on('data', (chunk) => {
      const match = /ONDO_WEB_SERVER_READY (\S+)/.exec(String(chunk));
      if (!match) return;
      clearTimeout(timer);
      resolve({
        baseUrl: match[1],
        stop: () =>
          new Promise((done) => {
            child.once('exit', () => done());
            child.kill('SIGTERM');
          }),
      });
    });

    child.once('error', (error) => {
      clearTimeout(timer);
      reject(error);
    });
  });
}

test.beforeAll(async () => {
  if (process.env.BASE_URL) {
    target = { baseUrl: process.env.BASE_URL.replace(/\/$/, ''), stop: async () => {} };
    return;
  }
  target = await startLocalServer();
});

test.afterAll(async () => {
  await target?.stop();
});

/** @param {string} route */
function url(route) {
  return `${target.baseUrl}${route}`;
}

test.describe('public routes', () => {
  for (const route of PUBLIC_PAGE_ROUTES) {
    test(`${route} responds 200 and keeps its final URL`, async ({ page }) => {
      const response = await page.goto(url(route));

      expect(response, `no response for ${route}`).not.toBeNull();
      expect(response.status(), `unexpected status for ${route}`).toBe(200);
      expect(new URL(page.url()).pathname).toBe(route);
      await expect(page.locator('h1')).toBeVisible();
    });
  }

  for (const route of NATIVE_LANDING_ROUTES) {
    test(`${route} lands on the explicit native-route notice`, async ({ page }) => {
      const response = await page.goto(url(route));

      expect(response.status(), `unexpected status for ${route}`).toBe(200);
      expect(new URL(page.url()).pathname, `${route} must not redirect`).toBe(route);
      await expect(page.getByTestId('native-route-notice')).toBeVisible();
      await expect(page.getByTestId('home-link')).toBeVisible();
    });
  }

  test('an unknown URL returns a real 404 with a working home link', async ({ page }) => {
    const response = await page.goto(url(MISSING_ROUTE));

    expect(response.status()).toBe(404);
    await expect(page.locator('h1')).toBeVisible();

    await page.getByTestId('home-link').click();
    await expect(page).toHaveURL(`${target.baseUrl}/`);
    await expect(page.locator('h1')).toBeVisible();
  });
});

test.describe('layout', () => {
  for (const [label, viewport] of [
    ['desktop 1440x1000', DESKTOP_VIEWPORT],
    ['mobile 390x844', MOBILE_VIEWPORT],
  ]) {
    test(`${label} renders every page without horizontal overflow`, async ({ browser }) => {
      const context = await browser.newContext({ viewport });
      const page = await context.newPage();

      try {
        for (const route of ALL_PAGE_ROUTES) {
          await page.goto(url(route));

          const overflow = await page.evaluate(() => ({
            scrollWidth: document.documentElement.scrollWidth,
            clientWidth: document.documentElement.clientWidth,
          }));

          expect(
            overflow.scrollWidth,
            `${route} overflows horizontally at ${viewport.width}px`,
          ).toBeLessThanOrEqual(overflow.clientWidth + 1);

          await expect(page.locator('h1'), `${route} hides its heading`).toBeVisible();
          await expect(page.getByTestId('page-nav'), `${route} hides its nav`).toBeVisible();
        }
      } finally {
        await context.close();
      }
    });
  }
});

test.describe('keyboard access', () => {
  test('Tab reaches primary links with a visible focus ring and Enter follows them', async ({
    page,
  }) => {
    await page.goto(url('/'));

    await page.keyboard.press('Tab');
    await expect(page.getByTestId('skip-link')).toBeFocused();

    const skipLinkOutline = await page.evaluate(() => {
      const style = getComputedStyle(document.activeElement);
      return { style: style.outlineStyle, width: parseFloat(style.outlineWidth) };
    });
    expect(skipLinkOutline.style).not.toBe('none');
    expect(skipLinkOutline.width).toBeGreaterThan(0);

    await page.keyboard.press('Enter');
    await expect(page.locator('main#main')).toBeFocused();

    let reachedPrivacyLink = false;
    for (let index = 0; index < 15; index += 1) {
      await page.keyboard.press('Tab');
      const href = await page.evaluate(() => document.activeElement?.getAttribute('href') ?? '');
      if (href === '/privacy') {
        reachedPrivacyLink = true;
        break;
      }
    }
    expect(reachedPrivacyLink, 'privacy link is not keyboard reachable from the home page').toBe(
      true,
    );

    const focusedOutline = await page.evaluate(() => {
      const style = getComputedStyle(document.activeElement);
      return { style: style.outlineStyle, width: parseFloat(style.outlineWidth) };
    });
    expect(focusedOutline.style).not.toBe('none');
    expect(focusedOutline.width).toBeGreaterThan(0);

    await page.keyboard.press('Enter');
    await expect(page).toHaveURL(`${target.baseUrl}/privacy`);
  });
});

test.describe('document semantics', () => {
  for (const route of ALL_PAGE_ROUTES) {
    test(`${route} exposes a title, language, one main landmark and headings`, async ({ page }) => {
      await page.goto(url(route));

      const title = await page.title();
      expect(title.trim().length, `${route} has an empty title`).toBeGreaterThan(0);
      expect(title, `${route} title is not branded`).toContain('Ondo');

      await expect(page.locator('html')).toHaveAttribute('lang', 'ko');
      await expect(page.locator('main')).toHaveCount(1);
      await expect(page.locator('h1')).toHaveCount(1);

      const headingText = (await page.locator('h1').innerText()).trim();
      expect(headingText.length, `${route} has an empty h1`).toBeGreaterThan(2);

      const emptyHeadings = await page.evaluate(() =>
        [...document.querySelectorAll('h1, h2, h3')].filter(
          (heading) => heading.textContent.trim().length === 0,
        ).length,
      );
      expect(emptyHeadings, `${route} has empty headings`).toBe(0);
    });
  }
});

test.describe('runtime health', () => {
  test('no console errors and no failed same-origin requests', async ({ page }) => {
    /** @type {string[]} */
    const problems = [];

    page.on('console', (message) => {
      if (message.type() === 'error') problems.push(`console: ${message.text()}`);
    });
    page.on('pageerror', (error) => problems.push(`pageerror: ${error.message}`));
    page.on('requestfailed', (request) => {
      if (request.url().startsWith(target.baseUrl)) {
        problems.push(`requestfailed: ${request.url()}`);
      }
    });
    page.on('response', (response) => {
      if (!response.url().startsWith(target.baseUrl)) return;
      if (response.status() >= 400) problems.push(`${response.status()}: ${response.url()}`);
    });

    for (const route of ALL_PAGE_ROUTES) {
      await page.goto(url(route));
      await expect(page.locator('h1')).toBeVisible();
    }

    expect(problems).toEqual([]);
  });

  test('favicon.ico is served', async ({ request }) => {
    const response = await request.get(url('/favicon.ico'));

    expect(response.status()).toBe(200);
    expect((await response.body()).length).toBeGreaterThan(100);
  });

  test('the shared stylesheet is served', async ({ request }) => {
    const response = await request.get(url('/assets/site.css'));

    expect(response.status()).toBe(200);
    expect(response.headers()['content-type']).toContain('text/css');
  });

  test('robots.txt permits indexing of the public site', async ({ request }) => {
    const response = await request.get(url('/robots.txt'));

    expect(response.status()).toBe(200);
    expect(response.headers()['content-type']).toContain('text/plain');
    expect(await response.text()).toMatch(/User-agent:\s*\*/i);
  });

  test('the Korean 404 heading does not break inside words on narrow screens', async ({ page }) => {
    await page.setViewportSize({ width: 360, height: 800 });
    await page.goto(url('/does-not-exist'));

    const wordBreak = await page.locator('h1').evaluate((heading) => getComputedStyle(heading).wordBreak);
    expect(wordBreak).toBe('keep-all');
  });
});

test.describe('contact details', () => {
  for (const route of ['/', '/privacy', '/terms', '/support', '/delete-account']) {
    test(`${route} does not publish the unroutable ${DEAD_MAIL_DOMAIN} address`, async ({
      page,
    }) => {
      await page.goto(url(route));

      const html = await page.content();
      expect(html, `${route} still references ${DEAD_MAIL_DOMAIN}`).not.toContain(
        DEAD_MAIL_DOMAIN,
      );
    });
  }

  for (const route of ['/support', '/delete-account']) {
    test(`${route} publishes the canonical support mailbox`, async ({ page }) => {
      await page.goto(url(route));
      await expect(page.locator(`a[href="mailto:${SUPPORT_EMAIL}"]`).first()).toBeVisible();
    });
  }

  test('the deletion page explains the in-app path and the email fallback', async ({ page }) => {
    await page.goto(url('/delete-account'));

    await expect(page.getByTestId('in-app-deletion-steps')).toBeVisible();
    await expect(page.getByTestId('deletion-request-fallback')).toBeVisible();

    const steps = await page.getByTestId('in-app-deletion-steps').locator('li').count();
    expect(steps).toBeGreaterThanOrEqual(3);
  });
});

test.describe('internal links', () => {
  test('every internal link on every page resolves without a 404', async ({ page, request }) => {
    /** @type {Map<string, string[]>} */
    const seen = new Map();

    for (const route of ALL_PAGE_ROUTES) {
      await page.goto(url(route));
      const hrefs = await page.evaluate(() =>
        [...document.querySelectorAll('a[href]')]
          .map((anchor) => anchor.getAttribute('href') ?? '')
          .filter((href) => href.startsWith('/')),
      );

      expect(hrefs.length, `${route} exposes no internal links`).toBeGreaterThan(0);

      for (const href of hrefs) {
        seen.set(href, [...(seen.get(href) ?? []), route]);
      }
    }

    /** @type {string[]} */
    const broken = [];
    for (const [href, sources] of seen) {
      const response = await request.get(url(href));
      if (response.status() !== 200) {
        broken.push(`${href} -> ${response.status()} (linked from ${sources.join(', ')})`);
      }
    }

    expect(broken).toEqual([]);
  });

  test('the open-in-app page routes an account-deletion deep link to the deletion guide', async ({
    page,
  }) => {
    await page.goto(url('/account-deletion'));

    await expect(page.getByTestId('native-route-notice')).toBeVisible();
    await page.getByTestId('account-deletion-fallback').getByRole('link').click();

    await expect(page).toHaveURL(`${target.baseUrl}/delete-account`);
    await expect(page.getByTestId('in-app-deletion-steps')).toBeVisible();
  });
});

test.describe('well-known association files', () => {
  test('apple-app-site-association stays valid JSON with the existing app identifier', async ({
    request,
  }) => {
    const response = await request.get(url('/.well-known/apple-app-site-association'));

    expect(response.status()).toBe(200);
    expect(response.headers()['content-type']).toContain('application/json');

    const payload = JSON.parse(await response.text());
    expect(payload.applinks.details[0].appIDs).toContain('5F7CN7Y54D.com.beyond.fortune');
    expect(payload.webcredentials.apps).toContain('5F7CN7Y54D.com.beyond.fortune');
  });

  test('assetlinks.json stays valid JSON with the existing package', async ({ request }) => {
    const response = await request.get(url('/.well-known/assetlinks.json'));

    expect(response.status()).toBe(200);
    expect(response.headers()['content-type']).toContain('application/json');

    const payload = JSON.parse(await response.text());
    expect(payload[0].target.package_name).toBe('com.beyond.fortune');
    expect(payload[0].relation).toContain('delegate_permission/common.handle_all_urls');
  });
});

test.describe('security headers', () => {
  test('every public page ships the expected security headers', async ({ request }) => {
    for (const route of ALL_PAGE_ROUTES) {
      const response = await request.get(url(route));
      const headers = response.headers();

      expect(headers['strict-transport-security'], `${route} HSTS`).toMatch(/max-age=\d{8,}/);
      expect(headers['x-content-type-options'], `${route} nosniff`).toBe('nosniff');
      expect(headers['referrer-policy'], `${route} referrer policy`).toBe(
        'strict-origin-when-cross-origin',
      );
      expect(headers['x-frame-options'], `${route} frame options`).toBe('DENY');

      const csp = headers['content-security-policy'] ?? '';
      expect(csp, `${route} CSP default-src`).toContain("default-src 'none'");
      expect(csp, `${route} CSP frame-ancestors`).toContain("frame-ancestors 'none'");
      expect(csp, `${route} CSP script-src`).toContain("script-src 'none'");
      expect(csp, `${route} CSP style-src`).toContain("style-src 'self'");
      expect(csp, `${route} CSP same-origin fetches`).toContain("connect-src 'self'");
      expect(csp, `${route} CSP must not allow inline styles`).not.toContain(
        "style-src 'self' 'unsafe-inline'",
      );
    }
  });

  test('the .well-known files keep their JSON content type under the security headers', async ({
    request,
  }) => {
    for (const wellKnown of [
      '/.well-known/apple-app-site-association',
      '/.well-known/assetlinks.json',
    ]) {
      const response = await request.get(url(wellKnown));

      expect(response.status(), `${wellKnown} status`).toBe(200);
      expect(response.headers()['content-type'], `${wellKnown} content type`).toContain(
        'application/json',
      );
      expect(response.headers()['x-content-type-options'], `${wellKnown} nosniff`).toBe('nosniff');
    }
  });
});
