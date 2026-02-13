// @ts-check
const { defineConfig, devices } = require('@playwright/test');

/**
 * @see https://playwright.dev/docs/test-configuration
 */
module.exports = defineConfig({
  testDir: './playwright/tests',
  /* Run tests in files in parallel */
  fullyParallel: true,
  /* Fail the build on CI if you accidentally left test.only in the source code. */
  forbidOnly: !!process.env.CI,
  /* Retry on CI only */
  retries: process.env.CI ? 2 : 0,
  /* Opt out of parallel tests on CI. */
  workers: process.env.CI ? 1 : undefined,
  /* Reporter to use. See https://playwright.dev/docs/test-reporters */
  reporter: [
    ['html'],
    ['json', { outputFile: 'test-results/results.json' }],
    ['junit', { outputFile: 'test-results/junit.xml' }]
  ],
  /* Shared settings for all the projects below. See https://playwright.dev/docs/api/class-testoptions. */
  use: {
    /* Base URL to use in actions like `await page.goto('/')`. */
    baseURL: process.env.BASE_URL || 'http://localhost:3000',

    /* Collect trace when retrying the failed test. See https://playwright.dev/docs/trace-viewer */
    trace: 'on-first-retry',

    /* Take screenshot on failure */
    screenshot: 'only-on-failure',

    /* Record video on failure */
    video: 'retain-on-failure',

    /* Global timeout for all tests - increased for Flutter Web */
    timeout: 60000,

    /* Test timeout for a single test - increased for Flutter Web */
    actionTimeout: 15000,

    /* Ignore HTTPS errors */
    ignoreHTTPSErrors: true,
  },

  /* Configure projects for major browsers */
  projects: [
    {
      name: 'chromium',
      use: {
        ...devices['Desktop Chrome'],
        // Override some settings for better test stability
        viewport: { width: 1280, height: 720 },
        launchOptions: {
          args: [
            '--disable-web-security',
            '--disable-features=VizDisplayCompositor',
            '--no-sandbox',
            '--disable-setuid-sandbox'
          ]
        }
      },
    },

    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },

    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },

    /* Test against mobile viewports. */
    {
      name: 'Mobile Chrome',
      use: { ...devices['Pixel 5'] },
    },
    {
      name: 'Mobile Safari',
      use: { ...devices['iPhone 12'] },
    },

    /* Test against branded browsers. */
    // {
    //   name: 'Microsoft Edge',
    //   use: { ...devices['Desktop Edge'], channel: 'msedge' },
    // },
    // {
    //   name: 'Google Chrome',
    //   use: { ...devices['Desktop Chrome'], channel: 'chrome' },
    // },
  ],

  /* Run your local dev server before starting the tests */
  webServer: process.env.PLAYWRIGHT_SKIP_WEBSERVER === 'true' ? undefined : (
    process.env.CI ? {
      // CI: 빌드된 정적 파일 서빙 (빠름)
      command: 'npx serve build/web -l 3000',
      url: 'http://localhost:3000',
      reuseExistingServer: true,  // CI에서 이미 실행 중인 서버 재사용
      timeout: 30 * 1000,
    } : {
      // Local: Flutter 개발 서버 (핫 리로드)
      command: 'flutter run -d chrome --web-port=3000',
      url: 'http://localhost:3000',
      reuseExistingServer: true,
      timeout: 120 * 1000,
    }
  ),

  /* Global setup */
  globalSetup: require.resolve('./playwright/global-setup.js'),

  /* Global teardown */
  globalTeardown: require.resolve('./playwright/global-teardown.js'),

  /* Expect options */
  expect: {
    /* Timeout for expect assertions */
    timeout: 10000,

    /* Threshold for visual comparisons */
    threshold: 0.2,
  },

  /* Test output directory */
  outputDir: 'test-results/',

  /* Maximum time one test can run for - increased for Flutter Web */
  timeout: 60000,
});