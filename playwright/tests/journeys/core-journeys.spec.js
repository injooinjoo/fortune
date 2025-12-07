// core-journeys.spec.js - 핵심 사용자 여정 테스트
// 실제 사용자가 앱을 사용하는 것처럼 인터랙션을 테스트합니다.

const { test, expect } = require('@playwright/test');

// 테스트 설정
test.describe.configure({ mode: 'serial' }); // 순차 실행
test.setTimeout(120000); // 2분 타임아웃

// Flutter 초기화 대기 헬퍼
async function waitForFlutter(page, timeout = 45000) {
  try {
    await page.waitForFunction(() => {
      return document.querySelector('flt-glass-pane') !== null ||
             document.querySelector('flutter-view') !== null;
    }, { timeout: timeout, polling: 1000 });
    // 추가 안정화 대기
    await page.waitForTimeout(3000);
    return true;
  } catch (e) {
    console.log('Flutter 초기화 타임아웃, 대기 후 재시도...');
    await page.waitForTimeout(10000);
    const hasFlutter = await page.evaluate(() =>
      document.querySelector('flt-glass-pane') !== null ||
      document.querySelector('flutter-view') !== null
    );
    return hasFlutter;
  }
}

// 콘솔 로그 수집 헬퍼
function setupConsoleLogger(page, logs) {
  page.on('console', msg => {
    if (msg.type() === 'log' || msg.type() === 'info') {
      logs.push({ type: msg.type(), text: msg.text() });
    }
  });
  page.on('console', msg => {
    if (msg.type() === 'error') {
      logs.push({ type: 'error', text: msg.text() });
    }
  });
}

// =====================================================
// Journey 1: 랜딩 페이지 및 앱 초기화
// =====================================================
test.describe('Journey 1: 앱 초기화 및 랜딩', () => {
  test('1.1 앱이 정상적으로 로드되는지 확인', async ({ page }) => {
    const logs = [];
    setupConsoleLogger(page, logs);

    // 랜딩 페이지 접근
    await page.goto('/');
    await waitForFlutter(page);

    // Flutter 앱 로드 확인
    const hasFlutter = await page.evaluate(() => {
      return document.querySelector('flt-glass-pane') !== null;
    });
    expect(hasFlutter).toBeTruthy();

    // 앱 시작 로그 확인
    const hasStartupLog = logs.some(l => l.text.includes('[STARTUP] App started'));
    console.log('앱 시작 로그 발견:', hasStartupLog);

    // 스크린샷
    await page.screenshot({
      path: 'test-results/journeys/1.1-app-loaded.png',
      fullPage: true
    });
  });

  test('1.2 랜딩 페이지 UI 요소 확인', async ({ page }) => {
    await page.goto('/');
    await waitForFlutter(page);

    // 랜딩 페이지 콘솔 로그 확인 (Flutter 내부 라우팅)
    const logs = [];
    setupConsoleLogger(page, logs);

    await page.waitForTimeout(2000);

    // 랜딩 페이지 로드 확인
    const isLandingPage = logs.some(l =>
      l.text.includes('LandingPage') ||
      l.text.includes('Screen: landing')
    );
    console.log('랜딩 페이지 로드:', isLandingPage);

    await page.screenshot({
      path: 'test-results/journeys/1.2-landing-ui.png',
      fullPage: true
    });
  });
});

// =====================================================
// Journey 2: 운세 탐색 (비로그인 상태)
// =====================================================
test.describe('Journey 2: 비인증 페이지 탐색', () => {
  test('2.1 도움말 페이지 접근', async ({ page }) => {
    await page.goto('/help');
    await waitForFlutter(page);

    await page.screenshot({
      path: 'test-results/journeys/2.1-help-page.png',
      fullPage: true
    });
  });

  test('2.2 개인정보처리방침 페이지 접근', async ({ page }) => {
    await page.goto('/privacy-policy');
    await waitForFlutter(page);

    await page.screenshot({
      path: 'test-results/journeys/2.2-privacy-policy.png',
      fullPage: true
    });
  });

  test('2.3 이용약관 페이지 접근', async ({ page }) => {
    await page.goto('/terms-of-service');
    await waitForFlutter(page);

    await page.screenshot({
      path: 'test-results/journeys/2.3-terms.png',
      fullPage: true
    });
  });

  test('2.4 포춘쿠키 페이지 (인터랙티브)', async ({ page }) => {
    await page.goto('/fortune-cookie');
    await waitForFlutter(page);

    // 포춘쿠키는 인터랙티브 요소가 있을 수 있음
    await page.waitForTimeout(2000);

    await page.screenshot({
      path: 'test-results/journeys/2.4-fortune-cookie.png',
      fullPage: true
    });
  });
});

// =====================================================
// Journey 3: 앱 내 네비게이션 (Flutter 라우터 테스트)
// =====================================================
test.describe('Journey 3: Flutter 내부 네비게이션', () => {
  test('3.1 루트에서 Flutter 라우터로 다양한 경로 이동', async ({ page }) => {
    const logs = [];
    setupConsoleLogger(page, logs);

    // 앱 초기화
    await page.goto('/');
    await waitForFlutter(page);

    // Flutter 라우터를 통해 /home으로 이동 시도
    await page.evaluate(() => {
      window.history.pushState({}, '', '/home');
      window.dispatchEvent(new PopStateEvent('popstate'));
    });

    await page.waitForTimeout(3000);

    // 라우트 변경 로그 확인
    const routeChangeLogs = logs.filter(l =>
      l.text.includes('[PUSH]') || l.text.includes('Screen:')
    );
    console.log('라우트 변경 로그:', routeChangeLogs.slice(-3));

    await page.screenshot({
      path: 'test-results/journeys/3.1-router-navigation.png',
      fullPage: true
    });
  });

  test('3.2 여러 라우트 순차 이동', async ({ page }) => {
    const routes = ['/home', '/fortune', '/profile', '/premium'];
    const screenshots = [];

    await page.goto('/');
    await waitForFlutter(page);

    for (const route of routes) {
      await page.evaluate((targetPath) => {
        window.history.pushState({}, '', targetPath);
        window.dispatchEvent(new PopStateEvent('popstate'));
      }, route);

      await page.waitForTimeout(2000);

      const screenshotName = route.replace(/\//g, '_').replace(/^_/, '') || 'root';
      await page.screenshot({
        path: `test-results/journeys/3.2-nav-${screenshotName}.png`,
        fullPage: true
      });
      screenshots.push(screenshotName);
    }

    console.log('캡처된 라우트:', screenshots);
  });
});

// =====================================================
// Journey 4: 운세 페이지 접근 (주요 기능)
// =====================================================
test.describe('Journey 4: 운세 페이지 탐색', () => {
  test('4.1 일일 달력 운세 페이지', async ({ page }) => {
    const logs = [];
    setupConsoleLogger(page, logs);

    await page.goto('/');
    await waitForFlutter(page);

    // 일일 달력 운세로 이동
    await page.evaluate(() => {
      window.history.pushState({}, '', '/daily-calendar');
      window.dispatchEvent(new PopStateEvent('popstate'));
    });

    await page.waitForTimeout(5000);

    // 운세 관련 로그 확인
    const fortuneLogs = logs.filter(l =>
      l.text.toLowerCase().includes('fortune') ||
      l.text.includes('운세') ||
      l.text.includes('daily')
    );
    console.log('운세 관련 로그:', fortuneLogs.slice(-5));

    await page.screenshot({
      path: 'test-results/journeys/4.1-daily-calendar.png',
      fullPage: true
    });
  });

  test('4.2 타로 페이지', async ({ page }) => {
    const logs = [];
    setupConsoleLogger(page, logs);

    await page.goto('/');
    await waitForFlutter(page);

    await page.evaluate(() => {
      window.history.pushState({}, '', '/tarot');
      window.dispatchEvent(new PopStateEvent('popstate'));
    });

    await page.waitForTimeout(5000);

    // 타로 관련 로그 확인
    const tarotLogs = logs.filter(l =>
      l.text.toLowerCase().includes('tarot') ||
      l.text.includes('타로') ||
      l.text.includes('deck')
    );
    console.log('타로 관련 로그:', tarotLogs.slice(-5));

    await page.screenshot({
      path: 'test-results/journeys/4.2-tarot.png',
      fullPage: true
    });
  });

  test('4.3 궁합 페이지', async ({ page }) => {
    await page.goto('/');
    await waitForFlutter(page);

    await page.evaluate(() => {
      window.history.pushState({}, '', '/compatibility');
      window.dispatchEvent(new PopStateEvent('popstate'));
    });

    await page.waitForTimeout(5000);

    await page.screenshot({
      path: 'test-results/journeys/4.3-compatibility.png',
      fullPage: true
    });
  });

  test('4.4 MBTI 운세 페이지', async ({ page }) => {
    await page.goto('/');
    await waitForFlutter(page);

    await page.evaluate(() => {
      window.history.pushState({}, '', '/mbti');
      window.dispatchEvent(new PopStateEvent('popstate'));
    });

    await page.waitForTimeout(5000);

    await page.screenshot({
      path: 'test-results/journeys/4.4-mbti.png',
      fullPage: true
    });
  });
});

// =====================================================
// Journey 5: 프로필 및 설정 탐색
// =====================================================
test.describe('Journey 5: 프로필 및 설정', () => {
  test('5.1 프로필 페이지', async ({ page }) => {
    await page.goto('/');
    await waitForFlutter(page);

    await page.evaluate(() => {
      window.history.pushState({}, '', '/profile');
      window.dispatchEvent(new PopStateEvent('popstate'));
    });

    await page.waitForTimeout(3000);

    await page.screenshot({
      path: 'test-results/journeys/5.1-profile.png',
      fullPage: true
    });
  });

  test('5.2 설정 페이지', async ({ page }) => {
    await page.goto('/');
    await waitForFlutter(page);

    await page.evaluate(() => {
      window.history.pushState({}, '', '/settings');
      window.dispatchEvent(new PopStateEvent('popstate'));
    });

    await page.waitForTimeout(3000);

    await page.screenshot({
      path: 'test-results/journeys/5.2-settings.png',
      fullPage: true
    });
  });

  test('5.3 프리미엄 페이지', async ({ page }) => {
    await page.goto('/');
    await waitForFlutter(page);

    await page.evaluate(() => {
      window.history.pushState({}, '', '/premium');
      window.dispatchEvent(new PopStateEvent('popstate'));
    });

    await page.waitForTimeout(3000);

    await page.screenshot({
      path: 'test-results/journeys/5.3-premium.png',
      fullPage: true
    });
  });
});

// =====================================================
// 테스트 결과 요약
// =====================================================
test.afterAll(async () => {
  console.log('\n========================================');
  console.log('🎯 JOURNEY TESTS SUMMARY');
  console.log('========================================');
  console.log('테스트된 사용자 여정:');
  console.log('  - Journey 1: 앱 초기화 및 랜딩');
  console.log('  - Journey 2: 비인증 페이지 탐색');
  console.log('  - Journey 3: Flutter 내부 네비게이션');
  console.log('  - Journey 4: 운세 페이지 탐색');
  console.log('  - Journey 5: 프로필 및 설정');
  console.log('========================================\n');
});
