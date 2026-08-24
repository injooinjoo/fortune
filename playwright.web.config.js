// @ts-check
const { defineConfig, devices } = require('@playwright/test');

/**
 * @fortune/web (Next.js) 전용 Playwright 설정.
 *
 * 포트 3100 — 3000 은 루트 playwright.config.js 가 RN web export 를
 * `serve` 로 띄우는 데 이미 쓰고 있다. 두 설정은 서로 건드리지 않는다.
 *
 * 실행: npx playwright test --config playwright.web.config.js
 */
const baseURL = process.env.WEB_BASE_URL || 'http://localhost:3100';
const shouldRunWebServer = process.env.PLAYWRIGHT_SKIP_WEBSERVER !== 'true';
const isCI = process.env.CI === 'true' || process.env.CI === '1';

module.exports = defineConfig({
  testDir: './playwright/tests/web',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: isCI ? 2 : 0,
  workers: isCI ? 1 : undefined,
  reporter: [['list'], ['html', { outputFolder: 'playwright-report/web', open: 'never' }]],
  use: {
    baseURL,
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    actionTimeout: 15000,
    launchOptions: process.env.PLAYWRIGHT_EXECUTABLE_PATH
      ? { executablePath: process.env.PLAYWRIGHT_EXECUTABLE_PATH }
      : undefined,
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'], viewport: { width: 1280, height: 720 } },
    },
  ],
  webServer: shouldRunWebServer
    ? {
        command:
          'pnpm --filter @fortune/web build && pnpm --filter @fortune/web start',
        url: baseURL,
        reuseExistingServer: true,
        timeout: (isCI ? 300 : 420) * 1000,
      }
    : undefined,
  outputDir: 'test-results/web/',
  timeout: 60000,
  expect: { timeout: 10000 },
});
