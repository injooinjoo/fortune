/**
 * Fortune App - Mass Screenshot Capture Script
 *
 * 목적: 전체 120개+ 화면을 Light/Dark 모드로 자동 캡처
 * 사용법:
 *   1. Flutter Web 서버 실행: flutter run -d chrome --web-port=3000
 *   2. 스크립트 실행: node playwright/scripts/mass-screenshot.js
 *
 * 출력: screenshots/raw/{category}/{page}_{theme}.png
 *
 * 메타데이터: screen-metadata.js의 상세 정보와 연동
 */

const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');
// Use V2 metadata with detailed screen info
const { SCREENS, FIGMA_CONFIG, getAllScreens } = require('./screen-metadata-v2');

// =============================================================================
// Configuration
// =============================================================================

const defaultDevice = FIGMA_CONFIG.devices[FIGMA_CONFIG.defaultDevice];

const CONFIG = {
  baseUrl: 'http://localhost:3000',
  viewport: { width: defaultDevice.width, height: defaultDevice.height }, // From V2 config
  deviceScaleFactor: defaultDevice.scale, // 3x for retina
  outputDir: path.join(__dirname, '../../screenshots/raw'),
  themes: FIGMA_CONFIG.themes, // ['light', 'dark'] from V2
  waitTime: 2000, // 페이지 로딩 대기 시간 (ms)
  screenshotDelay: 500, // 스크린샷 전 추가 대기 (ms)
};

// =============================================================================
// Route Generation from V2 Metadata
// =============================================================================

/**
 * V2 메타데이터에서 라우트 자동 생성
 */
function generateRoutesFromV2() {
  const routes = {};

  for (const [categoryKey, category] of Object.entries(SCREENS)) {
    routes[categoryKey] = [];

    for (const [screenKey, screen] of Object.entries(category.screens)) {
      routes[categoryKey].push({
        path: screen.path,
        name: screen.id,
        nameKo: screen.nameKo,
        states: screen.states || [{ id: 'default', name: 'Default' }],
        figmaPage: category.figmaPage,
      });
    }
  }

  return routes;
}

// Use V2-generated routes
const ROUTES_V2 = generateRoutesFromV2();

// =============================================================================
// Route Definitions (120+ routes)
// =============================================================================

const ROUTES = {
  // =========================================================================
  // Auth & Onboarding (5)
  // =========================================================================
  auth: [
    { path: '/', name: 'landing' },
    { path: '/splash', name: 'splash' },
    { path: '/signup', name: 'signup' },
    { path: '/onboarding', name: 'onboarding' },
    { path: '/onboarding/toss-style', name: 'onboarding-toss-style' },
  ],

  // =========================================================================
  // Home & Main Navigation (5)
  // =========================================================================
  home: [
    { path: '/home', name: 'home' },
    { path: '/fortune', name: 'fortune-list' },
    { path: '/trend', name: 'trend' },
    { path: '/premium', name: 'premium' },
    { path: '/fortune-cookie', name: 'fortune-cookie' },
  ],

  // =========================================================================
  // Profile & Settings (15)
  // =========================================================================
  profile: [
    { path: '/profile', name: 'profile' },
    { path: '/profile/edit', name: 'profile-edit' },
    { path: '/profile/saju', name: 'profile-saju' },
    { path: '/profile/elements', name: 'profile-elements' },
    { path: '/profile/verification', name: 'profile-verification' },
    { path: '/profile/history', name: 'profile-history' },
    { path: '/settings', name: 'settings' },
    { path: '/settings/social-accounts', name: 'settings-social-accounts' },
    { path: '/settings/phone-management', name: 'settings-phone' },
    { path: '/settings/notifications', name: 'settings-notifications' },
    { path: '/settings/font', name: 'settings-font' },
    { path: '/subscription', name: 'subscription' },
    { path: '/token-purchase', name: 'token-purchase' },
    { path: '/help', name: 'help' },
    { path: '/privacy-policy', name: 'privacy-policy' },
    { path: '/terms-of-service', name: 'terms-of-service' },
  ],

  // =========================================================================
  // Fortune - Basic (10)
  // =========================================================================
  fortune_basic: [
    { path: '/mbti', name: 'mbti' },
    { path: '/wish', name: 'wish' },
    { path: '/compatibility', name: 'compatibility' },
    { path: '/celebrity', name: 'celebrity' },
    { path: '/family', name: 'family' },
    { path: '/pet', name: 'pet-compatibility' },
    { path: '/avoid-people', name: 'avoid-people' },
    { path: '/personality-dna', name: 'personality-dna' },
    { path: '/daily-calendar', name: 'daily-calendar' },
    { path: '/moving', name: 'moving' },
  ],

  // =========================================================================
  // Fortune - Traditional (5)
  // =========================================================================
  fortune_traditional: [
    { path: '/traditional', name: 'traditional' },
    { path: '/traditional-saju', name: 'traditional-saju' },
    { path: '/face-reading', name: 'face-reading' },
    { path: '/tarot', name: 'tarot' },
    { path: '/lucky-talisman', name: 'talisman' },
  ],

  // =========================================================================
  // Fortune - Love & Relationship (5)
  // =========================================================================
  fortune_love: [
    { path: '/love', name: 'love-input' },
    { path: '/ex-lover-simple', name: 'ex-lover' },
    { path: '/blind-date', name: 'blind-date' },
  ],

  // =========================================================================
  // Fortune - Career & Finance (5)
  // =========================================================================
  fortune_career: [
    { path: '/career', name: 'career-coaching' },
    { path: '/investment', name: 'investment' },
    { path: '/lucky-exam', name: 'lucky-exam' },
    { path: '/talent-fortune-input', name: 'talent-input' },
  ],

  // =========================================================================
  // Fortune - Time Based (5)
  // =========================================================================
  fortune_time: [
    { path: '/biorhythm', name: 'biorhythm' },
    { path: '/time', name: 'time-fortune' },
    { path: '/time-based', name: 'time-based' },
    { path: '/yearly', name: 'yearly' },
    { path: '/new-year', name: 'new-year' },
  ],

  // =========================================================================
  // Fortune - Health & Sports (10)
  // =========================================================================
  fortune_health: [
    { path: '/health-toss', name: 'health' },
    { path: '/exercise', name: 'exercise' },
    { path: '/lucky-golf', name: 'lucky-golf' },
    { path: '/lucky-baseball', name: 'lucky-baseball' },
    { path: '/lucky-tennis', name: 'lucky-tennis' },
    { path: '/lucky-running', name: 'lucky-running' },
    { path: '/lucky-cycling', name: 'lucky-cycling' },
    { path: '/lucky-swim', name: 'lucky-swim' },
    { path: '/lucky-fishing', name: 'lucky-fishing' },
    { path: '/lucky-hiking', name: 'lucky-hiking' },
    { path: '/lucky-yoga', name: 'lucky-yoga' },
    { path: '/lucky-fitness', name: 'lucky-fitness' },
  ],

  // =========================================================================
  // Fortune - Special (5)
  // =========================================================================
  fortune_special: [
    { path: '/dream', name: 'dream-fortune' },
    { path: '/dream-chat', name: 'dream-chat' },
    { path: '/lucky-items', name: 'lucky-items' },
  ],

  // =========================================================================
  // Interactive (12)
  // =========================================================================
  interactive: [
    { path: '/interactive', name: 'interactive-list' },
    { path: '/interactive/dream', name: 'dream-interpretation' },
    { path: '/interactive/psychology-test', name: 'psychology-test' },
    { path: '/interactive/tarot', name: 'tarot-chat' },
    { path: '/interactive/tarot/deck-selection', name: 'tarot-deck-selection' },
    { path: '/interactive/tarot/animated-flow', name: 'tarot-animated-flow' },
    { path: '/interactive/face-reading', name: 'face-reading-interactive' },
    { path: '/interactive/taemong', name: 'taemong' },
    { path: '/interactive/worry-bead', name: 'worry-bead' },
    { path: '/interactive/dream-journal', name: 'dream-journal' },
  ],

  // =========================================================================
  // Trend (4) - Dynamic routes, using sample contentId
  // =========================================================================
  trend: [
    { path: '/trend/psychology/sample', name: 'trend-psychology' },
    { path: '/trend/worldcup/sample', name: 'trend-worldcup' },
    { path: '/trend/balance/sample', name: 'trend-balance' },
  ],
};

// =============================================================================
// Helper Functions
// =============================================================================

/**
 * 디렉토리 생성 (없으면)
 */
function ensureDir(dirPath) {
  if (!fs.existsSync(dirPath)) {
    fs.mkdirSync(dirPath, { recursive: true });
    console.log(`Created directory: ${dirPath}`);
  }
}

/**
 * 테마 전환 (localStorage 사용)
 */
async function setTheme(page, theme) {
  await page.evaluate((isDark) => {
    localStorage.setItem('theme_mode', isDark ? 'dark' : 'light');
    // Flutter Web의 테마 변경 트리거
    window.dispatchEvent(new StorageEvent('storage', {
      key: 'theme_mode',
      newValue: isDark ? 'dark' : 'light'
    }));
  }, theme === 'dark');

  // 테마 적용 대기
  await page.waitForTimeout(500);
}

/**
 * Flutter 앱 로딩 대기
 */
async function waitForFlutterLoad(page) {
  try {
    // Flutter 앱이 로드될 때까지 대기 (최대 30초)
    await page.waitForSelector('flt-glass-pane', { timeout: 30000 });
    await page.waitForTimeout(CONFIG.waitTime);
  } catch (e) {
    console.warn('Flutter load timeout, continuing anyway...');
  }
}

/**
 * 스크린샷 파일명 생성
 */
function generateFileName(category, name, theme) {
  return `${category}_${name}_${theme}.png`;
}

/**
 * 단일 페이지 스크린샷 캡처
 */
async function captureScreenshot(page, category, route, theme) {
  const url = `${CONFIG.baseUrl}${route.path}`;
  const fileName = generateFileName(category, route.name, theme);
  const outputPath = path.join(CONFIG.outputDir, category, fileName);

  try {
    console.log(`  Capturing: ${route.name} (${theme})`);

    // 페이지 이동
    await page.goto(url, { waitUntil: 'networkidle', timeout: 30000 });

    // Flutter 로딩 대기
    await waitForFlutterLoad(page);

    // 추가 대기 (애니메이션 완료)
    await page.waitForTimeout(CONFIG.screenshotDelay);

    // 스크린샷 캡처
    await page.screenshot({
      path: outputPath,
      fullPage: false,
    });

    return { success: true, path: outputPath };
  } catch (error) {
    console.error(`  Failed: ${route.name} - ${error.message}`);
    return { success: false, error: error.message };
  }
}

// =============================================================================
// Main Execution
// =============================================================================

async function main() {
  console.log('='.repeat(60));
  console.log('Fortune App - Mass Screenshot Capture');
  console.log('='.repeat(60));
  console.log(`Base URL: ${CONFIG.baseUrl}`);
  console.log(`Viewport: ${CONFIG.viewport.width}x${CONFIG.viewport.height}`);
  console.log(`Output: ${CONFIG.outputDir}`);
  console.log('='.repeat(60));

  // 브라우저 시작
  const browser = await chromium.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  const context = await browser.newContext({
    viewport: CONFIG.viewport,
    deviceScaleFactor: CONFIG.deviceScaleFactor, // 고해상도 캡처 (from V2 config)
  });

  const page = await context.newPage();

  // 결과 추적
  const results = {
    total: 0,
    success: 0,
    failed: 0,
    errors: []
  };

  // 카테고리별 순회 (V2 메타데이터 우선, fallback으로 기존 ROUTES)
  const routesToUse = Object.keys(ROUTES_V2).length > 0 ? ROUTES_V2 : ROUTES;
  console.log(`\nUsing ${Object.keys(ROUTES_V2).length > 0 ? 'V2 metadata' : 'legacy ROUTES'}`);

  for (const [category, routes] of Object.entries(routesToUse)) {
    console.log(`\n[${category.toUpperCase()}] ${routes.length} routes`);

    // 카테고리 디렉토리 생성
    ensureDir(path.join(CONFIG.outputDir, category));

    for (const route of routes) {
      for (const theme of CONFIG.themes) {
        results.total++;

        // 테마 설정
        await setTheme(page, theme);

        // 스크린샷 캡처
        const result = await captureScreenshot(page, category, route, theme);

        if (result.success) {
          results.success++;
        } else {
          results.failed++;
          results.errors.push({
            route: route.path,
            theme,
            error: result.error
          });
        }
      }
    }
  }

  // 브라우저 종료
  await browser.close();

  // 결과 출력
  console.log('\n' + '='.repeat(60));
  console.log('CAPTURE COMPLETE');
  console.log('='.repeat(60));
  console.log(`Total: ${results.total}`);
  console.log(`Success: ${results.success}`);
  console.log(`Failed: ${results.failed}`);

  if (results.errors.length > 0) {
    console.log('\nFailed routes:');
    results.errors.forEach(e => {
      console.log(`  - ${e.route} (${e.theme}): ${e.error}`);
    });
  }

  // 결과 JSON 저장
  const manifestPath = path.join(CONFIG.outputDir, 'manifest.json');
  fs.writeFileSync(manifestPath, JSON.stringify({
    timestamp: new Date().toISOString(),
    config: CONFIG,
    routes: ROUTES,
    results
  }, null, 2));

  console.log(`\nManifest saved: ${manifestPath}`);

  return results;
}

// 실행
main().catch(console.error);
